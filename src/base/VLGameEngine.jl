# === PRIVATE METHODS BELOW HERE ====================================================================================== #
function prediction(signalVector::Array{Int64,1}, strategyObject::VLMinorityGameStrategy)::Int64

    # we use binary 0,1 under the covers - so lets get rid of the -1 and replace w/0 -
    memory = length(signalVector)
    binarySignal = replace(signalVector, -1 => 0)
    iv = range(memory, stop=1, step=-1) |> collect

    # convert the binarySignal to an int -
    strategy_index = 0
    for index in iv
        value = binarySignal[index]
        strategy_index += value * 2^(memory - index)
    end

    # from the strategy object, get the actual impl of the strategy -
    strategyImpl = strategyObject.strategy

    # compute the predicted outcome -
    return strategyImpl[strategy_index + 1]
end


function minority(gameAgentArray::Array{VLMinorityGameAgent,1}, signalVector::Array{Int64,1})::NamedTuple

    # iniialize -
    dim_output_array = Array{Int64,1}()
    numberOfAgents = length(gameAgentArray)
    actions = [-1,1]

    # ask the agents what their prediction will be, given this signal vector -
    agentPredictionArray = Array{Int64,1}(undef, numberOfAgents)
    for agent_index = 1:numberOfAgents
                
        # grab the agent -
        agentObject = gameAgentArray[agent_index]

        # get the strategy object -
        strategy_object = agentObject.bestAgentStrategy

        # what is predcited?
        predicted_action = prediction(signalVector, strategy_object)

        # grab -
        agentPredictionArray[agent_index] = predicted_action
    end

    # process each element of the alphabet -
    for value in actions
        
        # number of items -
        number_of_values = length(findall(x -> x == value, agentPredictionArray)) 

        # grab -
        push!(dim_output_array, number_of_values)
    end

    # find the argmin -
    arg_min_index = argmin(dim_output_array)
    minority_action_value = actions[arg_min_index]
    collective_action = sum(agentPredictionArray)

    # introduce some randomness: oops, we pick the majoity 1% of the time by mistake 
    bias_value = rand()
    if (bias_value <= 0.95)
        
        # setup the return tuple -
        return_tuple = (winningAction = minority_action_value, sell = dim_output_array[1], buy = dim_output_array[2], collectiveAction = collective_action, agentActions = agentPredictionArray)
    else
        
        # ooops - we made a mistake. the majority wins ..
        return_tuple = (winningAction = -1 * minority_action_value, sell = dim_output_array[1], buy = dim_output_array[2], collectiveAction = collective_action, agentActions = agentPredictionArray)
    end

    # return -
    return return_tuple
end
# === PRIVATE METHODS ABOVE HERE ====================================================================================== #

# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function simulate(worldObject::VLMinorityGameWorld, numberOfTimeSteps::Int64; 
    liquidity::Float64=10001.0, σ::Float64 = 0.0005)::NamedTuple

    try

        # setup -
        numberOfAgents = worldObject.numberOfAgents
        agentMemorySize = worldObject.agentMemorySize
        gameAgentArray = worldObject.gameAgentArray
        actions = [-1,1]    # we always use the binary model 
        length_of_actions = length(actions)   

        # initialize data structures -
        gameWorldMemoryBuffer = Array{Int64,1}()
        game_state_table = DataFrame(sell=Int[], buy=Int[], winner=Int[], A=Int[], price=Float64[])
        agent_state_table = Array{Int,2}(undef, numberOfTimeSteps, numberOfAgents)
        logAssetPriceArray = Array{Float64,1}(undef, (numberOfTimeSteps + 1))

        # add normal to perturbation -
        d = Normal(0, σ)
        
        # initialize -
        for _ = 1:(agentMemorySize + 1)
            
            # generate a random number {0,1}
            r = rand(1:length_of_actions)

            # capture -
            push!(gameWorldMemoryBuffer, actions[r])
        end

        # initially asset price is 1.0 -
        logAssetPriceArray[1] = 1.0
        
        # main loop -
        for time_step_index = 1:numberOfTimeSteps

            # grab the last agentMemorySize block -
            signalVector = gameWorldMemoryBuffer[(length(gameWorldMemoryBuffer) - (agentMemorySize - 1)):end]

            # ok, so let's ask all the agents what they voted to do, and get data on the minority position -
            results_tuple = minority(gameAgentArray, signalVector)
            winning_action = results_tuple.winningAction
            collective_action = results_tuple.collectiveAction
            sell = results_tuple.sell
            buy = results_tuple.buy
            agentPredictionArray = results_tuple.agentActions

            # update the price -
            old_price = logAssetPriceArray[time_step_index]
            r = ((1 / liquidity) * collective_action) + rand(d)
            logAssetPriceArray[time_step_index + 1] = old_price * (exp(r))

            # populate state table -
            data_row = [sell, buy, winning_action, collective_action, logAssetPriceArray[time_step_index]]
            push!(game_state_table, data_row)

            # update the agents data with the winning outcome -
            for agent_index = 1:numberOfAgents
                
                # grab the agent -
                agentObject = gameAgentArray[agent_index]

                # what did this agent predict?
                agentPrediction = agentPredictionArray[agent_index]

                # old score -
                old_score = agentObject.score
                agent_state_table[time_step_index, agent_index] = old_score

                # if the agent predicted correctly, then increase personal score -
                agentObject.score += -1 * sign(agentPrediction * collective_action)

                # let's re-rank all the strategies for this agent, and then put the new scores in an array that we can sort them
                agentStrategyCollection = agentObject.agentStrategyCollection
                tmp_score_array = Array{Int64,1}()
                for strategy_object in agentStrategyCollection
        
                    # compute the prediction for this strategy -
                    strategy_prediction = prediction(signalVector, strategy_object)

                    # update the score -
                    old_score = strategy_object.score
                    ΔS = -1 * sign(strategy_prediction * collective_action)
                    new_score = old_score + ΔS
                    strategy_object.score = new_score
                    
                    # cache new score -
                    push!(tmp_score_array, new_score)
                end

                # sort the scores -
                idx_sort_score = sortperm(tmp_score_array)

                # @show tmp_score_array
                # println("ai=$(agent_index) new best index = $(last(idx_sort_score))")

                # ok, so grab the best strategy, and update the best strategy pointer 
                agentObject.bestAgentStrategy = agentStrategyCollection[last(idx_sort_score)]
                
                # lets cache the wealth -
                # agentWealthCache[agent_index, time_step_index + 1] = agentObject.wealth
            end

            # add the winning outcome to the system memory -
            push!(gameWorldMemoryBuffer, winning_action)
        end

        # return tuple -
        return_tuple = (market_table = game_state_table, memory = gameWorldMemoryBuffer, agent_score_table = agent_state_table)
        
        # return -
        return return_tuple
    catch error
        # if we get here ... something bad has happend. do nothing for now 
        rethrow(error)
    end
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #