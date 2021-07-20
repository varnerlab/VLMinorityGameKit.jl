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

function _minority(agentPredictionArray::Array{Int64,1}; actions::Array{Int64,1}=[-1,0,1])::Int64

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
    
    # return -
    return actions[arg_min_index]
end

function _agent_update(agent::VLMinorityGameAgent, signal::Array{Int64,1}, winningOutcome::Int64, 
    globalOutcome::Int64)::VLMinorityGameAgent

    # ok, so we used the *first* strategy, what was the *predicted* outcome?
    predicted_outcome = _prediction(agent, signal)

    # ok, let's update the wealth -
    current_wealth = agent.wealth
    ΔW = sign(predicted_outcome * globalOutcome)
    new_wealth = current_wealth - ΔW
    agent.wealth = new_wealth

    # let's re-rank all the strategies for this agent, and then put the new scores in an array that we can sort them
    agentStrategyCollection = agent.agentStrategyCollection
    tmp_score_array = Array{Int64,1}()
    for strategy_tuple in agentStrategyCollection
        
        # update scores -
        if (predicted_outcome == winningOutcome)
            strategy_tuple.score += 1
        end

        # cache new score -
        new_score = strategy_tuple.score
        push!(tmp_score_array, new_score)
    end

    # sort the scores -
    idx_sort_score = sortperm(tmp_score_array)
    
    # ok, so grab the best strategy, and update the best strategy pointer -
    agent.bestAgentStrategy = agentStrategyCollection[first(idx_sort_score)].strategy

    # return -
    return agent
end

# === PRIVATE METHODS ABOVE HERE ====================================================================================== #

# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function simulate(worldObject::VLMinorityGameWorld, numberOfTimeSteps::Int64; actions::Array{Int64,1}=[-1,0,1],
    gameWorldVoteManager::Function=_minority, gameAgentUpdateManager::Function=_agent_update)::NamedTuple

    try

        # setup -
        numberOfAgents = worldObject.numberOfAgents
        agentMemorySize = worldObject.agentMemorySize
        gameAgentArray = worldObject.gameAgentArray

        gameWorldMemoryBuffer = Array{Int64,1}() 
        agentPredictionArray = Array{Int64,1}(undef, numberOfAgents)
        agentWealthCache = Array{Int64,2}(undef,numberOfAgents, numberOfTimeSteps)

        # initialize -
        for _ = 1:(agentMemorySize + 1)
            push!(gameWorldMemoryBuffer, 1)
        end
        
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

            # ok, so we asked all the agents what they voted to do, now lets id the minority position -
            winning_action = gameWorldVoteManager(agentPredictionArray; actions=actions)
            collective_action = sum(agentPredictionArray)

            # update the agents data with the winning outcome -
            for agent_index = 1:numberOfAgents
                
                # grab the agent -
                agentObject = gameAgentArray[agent_index]

                # update the agent -
                updated_agent = gameAgentUpdateManager(agentObject, signalVector, winning_action, collective_action)

                # update the array (not required ...?)
                gameAgentArray[agent_index] = updated_agent

                # lets cache the wealth -
                agentWealthCache[agent_index, time_step_index] = updated_agent.wealth
            end

            # add the winning outcome to the system memory -
            push!(gameWorldMemoryBuffer, winning_action)
        end

        # return -
        return_tuple = (agents = gameAgentArray, memory = gameWorldMemoryBuffer, agentWealthCache = agentWealthCache)
        return return_tuple
    catch error
        # if we get here ... something bad has happend. do nothing for now 
        rethrow(error)
    end
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #