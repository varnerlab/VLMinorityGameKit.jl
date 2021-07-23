# === PRIVATE METHODS BELOW HERE ====================================================================================== #
function _prediction(agent::VLMinorityGameAgent, signal::Array{Int64,1})::Int64

    # get the output -
    hash_signal_key = hash(signal)
    
    # get the strategy object -
    strategy_object = agent.bestAgentStrategy

    # from the strategy object, get the actual impl of the strategy -
    strategy = strategy_object.strategy
    if (haskey(strategy, hash_signal_key) == false)
        @show signal
    end

    # what is predcited?
    predicted_action = strategy[hash_signal_key]
    
    # return -
    return predicted_action
end

function _minority(agentPredictionArray::Array{Int64,1}; actions::Array{Int64,1}=[-1,1])::NamedTuple

    # iniialize -
    dim_output_array = Array{Int64,1}()

    # process each element of the alphabet -
    for value in actions
        
        # number of items -
        number_of_values = length(findall(x -> x == value, agentPredictionArray)) 

        # grab -
        push!(dim_output_array, number_of_values)
    end

    # find the argmin -
    arg_min_index = argmin(dim_output_array)
    action_value = actions[arg_min_index]

    # we have a bias towards sell -
    bias_value = rand()
    if (bias_value<=0.95)
        
        # setup the return tuple -
        return_tuple = (action = action_value, volume = dim_output_array)
    else
        
        # ooops - we made a mistake. the majority wins ..
        return_tuple = (action = -1*action_value, volume = dim_output_array)
    end

    # return -
    return return_tuple
end

# === PRIVATE METHODS ABOVE HERE ====================================================================================== #

# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function simulate(worldObject::VLMinorityGameWorld, numberOfTimeSteps::Int64; 
    liquidity::Float64 = 10001.0, actions::Array{Int64,1}=[-1,1],
    gameWorldVoteManager::Function=_minority)::NamedTuple

    try

        # setup -
        numberOfAgents = worldObject.numberOfAgents
        agentMemorySize = worldObject.agentMemorySize
        gameAgentArray = worldObject.gameAgentArray
        length_of_actions = length(actions)

        # initialize data structures -
        gameWorldMemoryBuffer = Array{Int64,1}() 
        agentPredictionArray = Array{Int64,1}(undef, numberOfAgents)
        agentWealthCache = Array{Union{Int64, Float64},2}(undef, numberOfAgents, numberOfTimeSteps + 1)
        collectiveActionArray = Array{Int64,1}(undef, numberOfTimeSteps)
        orderVolumeArray = Array{Int64,2}(undef, numberOfTimeSteps, length_of_actions+2)
        logAssetPriceArray = Array{Float64,1}(undef,(numberOfTimeSteps + 1))
        
        # initialize -
        for _ = 1:(agentMemorySize + 1)
            r = rand(1:length_of_actions)
            push!(gameWorldMemoryBuffer, actions[r])
        end

        for agent_index = 1:numberOfAgents
            agentWealthCache[agent_index,1] = 1
        end

        # initially asset price is 1.0 -
        logAssetPriceArray[1] = 1.0
        
        # main loop -
        for time_step_index = 1:numberOfTimeSteps

            # grab the last agentMemorySize block -
            signalVector = gameWorldMemoryBuffer[(length(gameWorldMemoryBuffer) - (agentMemorySize - 1)):end]

            # ask the agents what their prediction will be, given this signal vector -
            for agent_index = 1:numberOfAgents
                
                # grab the agent -
                agentObject = gameAgentArray[agent_index]

                # compute the prediction -
                agent_prediction = _prediction(agentObject, signalVector)

                # grab -
                agentPredictionArray[agent_index] = agent_prediction
            end

            # what is the collective action?
            collective_action = sum(agentPredictionArray)

            # ok, so we asked all the agents what they voted to do, now lets id the minority position -
            results_tuple = gameWorldVoteManager(agentPredictionArray; actions=actions)
            winning_action = results_tuple.action
            volume = results_tuple.volume

            # capture the order volume for this time point -
            for action_index = 1:length_of_actions
                orderVolumeArray[time_step_index,(action_index)] = volume[action_index]
            end
            orderVolumeArray[time_step_index,(length_of_actions + 1)] = winning_action
            orderVolumeArray[time_step_index,(length_of_actions + 2)] = collective_action


            # grab the collective action -
            collectiveActionArray[time_step_index] = collective_action

            # update the price -
            old_price = logAssetPriceArray[time_step_index]
            r = ((1/liquidity)*collective_action)
            logAssetPriceArray[time_step_index+1] = old_price*(exp(r))

            # update the agents data with the winning outcome -
            for agent_index = 1:numberOfAgents
                
                # grab the agent -
                agentObject = gameAgentArray[agent_index]

                # what did this agent predict?
                agentPrediction = agentPredictionArray[agent_index]

                # let's update the wealth -
                current_wealth = agentObject.wealth
                ΔW = -1 * (agentPrediction * (collective_action / numberOfAgents))
                new_wealth = current_wealth + ΔW
                agentObject.wealth = new_wealth

                # let's re-rank all the strategies for this agent, and then put the new scores in an array that we can sort them
                agentStrategyCollection = agentObject.agentStrategyCollection
                tmp_score_array = Array{Int64,1}()
                for strategy_tuple in agentStrategyCollection
        
                    # update scores -
                    if (agentPrediction == winning_action)
                        strategy_tuple.score += 1
                    else
                        strategy_tuple.score -= 1
                    end

                    # cache new score -
                    new_score = strategy_tuple.score
                    push!(tmp_score_array, new_score)
                end

                # sort the scores -
                idx_sort_score = sortperm(tmp_score_array)

                # ok, so lets interject a little randomness into the process ...
                mistake_chance = rand()
                if (mistake_chance<=0.95)
                    
                    # ok, so grab the best strategy, and update the best strategy pointer -
                    agentObject.bestAgentStrategy = agentStrategyCollection[first(idx_sort_score)].strategy
                else
                    
                    # ooops - pick the worst ...
                    agentObject.bestAgentStrategy = agentStrategyCollection[last(idx_sort_score)].strategy
                end

                # lets cache the wealth -
                agentWealthCache[agent_index, time_step_index + 1] = agentObject.wealth
            end

            # add the winning outcome to the system memory -
            push!(gameWorldMemoryBuffer, winning_action)
        end

        # return tuple -
        return_tuple = (volume = orderVolumeArray, price = logAssetPriceArray, memory = gameWorldMemoryBuffer, wealth = agentWealthCache, collective = collectiveActionArray)
        
        # return -
        return return_tuple
    catch error
        # if we get here ... something bad has happend. do nothing for now 
        rethrow(error)
    end
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #