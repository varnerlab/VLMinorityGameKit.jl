# === PRIVATE METHODS BELOW HERE ====================================================================================== #
function _basic_prediction(signalVector::Array{Int64,1}, strategyObject::VLAbstractGameStrategy)::Int64

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

function _basic_minority(gameAgentArray::Array{VLBasicMinorityGameAgent,1}, signalVector::Array{Int64,1})::NamedTuple

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
        predicted_action = _basic_prediction(signalVector, strategy_object)

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

    # setup the return tuple -
    return_tuple = (winningAction = minority_action_value, sell = dim_output_array[1], buy = dim_output_array[2], collectiveAction = collective_action, agentActions = agentPredictionArray)

    # return -
    return return_tuple
end

function _thermal_minority(gameAgentArray::Array{VLThermalMinorityGameAgent,1}, 
    signalVector::Array{Int64,1})::NamedTuple

    # iniialize -
    dim_output_array = Array{Int64,1}()
    numberOfAgents = length(gameAgentArray)
    actions = [-1,1]

    # ask the agents what their prediction will be, given this signal vector -
    agentPredictionArray = Array{Int64,1}(undef, numberOfAgents)
    for agent_index = 1:numberOfAgents
                
        # grab the agent -
        agentObject = gameAgentArray[agent_index]

        # roll a rand number -
        r = rand()

        # Pick a strategy -
        agentStrategyCollection = agentObject.agentStrategyCollection
        strategy_probability_array = Array{Float64,1}()
        for strategy_object in agentStrategyCollection
            push!(strategy_probability_array, strategy_object.probability)
        end        

        # how many strategies does this agent have?
        number_of_strategies = length(strategy_probability_array)

        # sort from the probabilities from smallest, to largest -
        idx_sort_probabilities = sortperm(strategy_probability_array)
        strategy_probability_array = strategy_probability_array[idx_sort_probabilities]

        # now, compute the partial sum -       
        partial_sum_value = 0.0
        partial_sum_array = Array{Float64,1}()
        for strategy_index = 1:number_of_strategies
            
            partial_sum_value += strategy_probability_array[strategy_index]
            push!(partial_sum_array, partial_sum_value)
        end

        # compute the selected strategy index, and get the selected strategy -
        idx_selected_strategy = findfirst(x->x>=r,partial_sum_array)
        if (isnothing(idx_selected_strategy) == true)
            idx_selected_strategy = 1
            @show r, partial_sum_array, P
        end

        actual_strategy_index = idx_sort_probabilities[idx_selected_strategy]
        strategy_object = agentObject.agentStrategyCollection[actual_strategy_index]

        # what is predcited?
        predicted_action = _basic_prediction(signalVector, strategy_object)

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

    # setup the return tuple -
    return_tuple = (winningAction = minority_action_value, sell = dim_output_array[1], buy = dim_output_array[2], collectiveAction = collective_action, agentActions = agentPredictionArray)

    # return -
    return return_tuple
end

function _thermal_cooling_function(temperature::Float64)
    
    # default behavior -
    α = 0.9
    temperature =  α * temperature
    return temperature
end

# === PRIVATE METHODS ABOVE HERE ====================================================================================== #

# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function execute(worldObject::VLThermalMinorityGameWorld, numberOfTimeSteps::Int64; 
    voteManagerFunction::Function = _thermal_minority, predictionFuntion::Function = _basic_prediction,
    coolingFunction::Function = _thermal_cooling_function, temperatureMinimum::Float64=0.1, 
    liquidity::Float64=10001.0, σ::Float64 = 0.0005)::VLMinorityGameSimulationResult

    try

        # get parameters from the gameworld -
        temperature = worldObject.temperature
        numberOfAgents = worldObject.numberOfAgents
        agentMemorySize = worldObject.agentMemorySize
        gameAgentArray = worldObject.gameAgentArray

        # actions -
        actions = [-1,1]    # we always use the binary model 
        length_of_actions = length(actions)  

        # initialize data structures -
        gameWorldMemoryBuffer = CircularBuffer{Int64}(agentMemorySize)
        game_state_table = DataFrame(temperature=Float64[], sell=Int[], buy=Int[], winner=Int[], A=Int[], price=Float64[])
        agent_state_table = Array{Int,2}(undef, numberOfTimeSteps, numberOfAgents)
        logAssetPriceArray = Array{Float64,1}(undef, (numberOfTimeSteps + 1))

        # initialze gameWorldMemoryBuffer -
        r = rand(1:length_of_actions, (agentMemorySize + 1))
        for x = 1:(agentMemorySize + 1)
            push!(gameWorldMemoryBuffer, actions[r[x]])
        end
        
        # initially asset price is 1.0 -
        logAssetPriceArray[1] = 1.0

        # add normal to perturbation -
        d = Normal(0, σ)

        # main run loop -
        # outer loop: we repeat this loop while T > T_min
        while (temperature>temperatureMinimum)

            # lets define the beta -
            β = (1/temperature)
            
            # inner loop: we repeat this loop for 1 -> numberOfTimeSteps
            for time_step_index = 1:numberOfTimeSteps
                
                # grab the last agentMemorySize block -
                signalVector = gameWorldMemoryBuffer[(length(gameWorldMemoryBuffer) - (agentMemorySize - 1)):end]

                # ok, so let's ask all the agents what they voted to do, and get data on the minority position -
                results_tuple = voteManagerFunction(gameAgentArray, signalVector)
                winning_action = results_tuple.winningAction
                collective_action = results_tuple.collectiveAction
                sell = results_tuple.sell
                buy = results_tuple.buy
                agentPredictionArray = results_tuple.agentActions

                # update the price -
                old_price = logAssetPriceArray[time_step_index]
                r = ((1 / liquidity) * collective_action) + rand(d)
                logAssetPriceArray[time_step_index + 1] = old_price * (exp(r))

                # update the agents data with the winning outcome -
                for agent_index = 1:numberOfAgents
                
                    # grab the agent -
                    agentObject = gameAgentArray[agent_index]

                    # what did this agent predict?
                    agentPrediction = agentPredictionArray[agent_index]

                    # capture the current score, then update -
                    # if the agent predicted correctly, then increase personal score -
                    agent_state_table[time_step_index, agent_index] = agentObject.score
                    agentObject.score += -1 * sign(agentPrediction * collective_action)

                    # so now we need to compute the probabaility for each strategy for this 
                    # agent -
                    agentStrategyCollection = agentObject.agentStrategyCollection
                    factor_array = Array{Float64,1}()
                    for strategy_object in agentStrategyCollection
                        
                        # update the score for this strategy -
                        strategy_prediction = predictionFuntion(signalVector, strategy_object)

                        # update the score -
                        strategy_object.score += -1 * sign(strategy_prediction * collective_action)

                        # compute the factors -
                        factorVal = exp(β*strategy_object.score)
                        push!(factor_array, factorVal)
                    end

                    # ok, so know that we that updated scores, lets compute the facrors -
                    numberOfStrategiesPerAgent = length(agentStrategyCollection)
                    denom_value = sum(factor_array)
                    for agent_strategy_index = 1:numberOfStrategiesPerAgent

                        # for this agent, get the strategy -
                        strategy_object = agentStrategyCollection[agent_strategy_index]
                        strategy_object.probability = factor_array[agent_strategy_index]/denom_value
                    end
                end # end agent update for loop 

                # populate state table -
                data_row = [temperature, sell, buy, winning_action, collective_action, logAssetPriceArray[time_step_index]]
                push!(game_state_table, data_row)
            
            end # end time for loop

            # after each time range, update the temperature using the cooling function 
            temperature = coolingFunction(temperature)
        end # end Temp while loop

        # package up and return -
        return VLMinorityGameSimulationResult(game_state_table)

    catch error
        rethrow(error)
    end
end

function execute(worldObject::VLBasicMinorityGameWorld, numberOfTimeSteps::Int64; 
    voteManagerFunction::Function = _basic_minority, predictionFuntion::Function = _basic_prediction,
    liquidity::Float64=10001.0, σ::Float64 = 0.0005)::NamedTuple

    try

        # setup -
        numberOfAgents = worldObject.numberOfAgents
        agentMemorySize = worldObject.agentMemorySize
        gameAgentArray = worldObject.gameAgentArray
        actions = [-1,1]    # we always use the binary model 
        length_of_actions = length(actions)   

        # initialize data structures -
        gameWorldMemoryBuffer = CircularBuffer{Int64}(agentMemorySize)
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
            results_tuple = voteManagerFunction(gameAgentArray, signalVector)
            winning_action = results_tuple.winningAction
            collective_action = results_tuple.collectiveAction
            sell = results_tuple.sell
            buy = results_tuple.buy
            agentPredictionArray = results_tuple.agentActions

            # update the price -
            old_price = logAssetPriceArray[time_step_index]
            r = ((1 / liquidity) * collective_action) + rand(d)
            logAssetPriceArray[time_step_index + 1] = old_price * (exp(r))

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
                    strategy_prediction = predictionFuntion(signalVector, strategy_object)

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

                # ok, so grab the best strategy, and update the best strategy pointer 
                agentObject.bestAgentStrategy = agentStrategyCollection[last(idx_sort_score)]
            end

            # add the winning outcome to the system memory -
            push!(gameWorldMemoryBuffer, winning_action)

            # populate state table -
            data_row = [sell, buy, winning_action, collective_action, logAssetPriceArray[time_step_index]]
            push!(game_state_table, data_row)
        end

        # return tuple -
        return_tuple = (market_table = game_state_table, agent_score_table = agent_state_table)
        
        # return -
        return return_tuple
    catch error
        # if we get here ... something bad has happend. do nothing for now 
        rethrow(error)
    end
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #