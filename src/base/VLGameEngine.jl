# === PRIVATE METHODS BELOW HERE ====================================================================================== #
function _prediction(agent::VLMinorityGameAgent, signal::Array{Int64,1})::Int64
end

function _minority(agentPredictionArray::Array{Int64,1})::Int64

    # alphabet_array -
    alphabet_array = [-1,0,1]

    # for now, lets assume we do a three component alphabet: sell = -1, hold = 0, buy = 1
    number_of_sell = length(findall(x->x==-1,agentPredictionArray))
    number_of_hold = length(findall(x->x==0,agentPredictionArray))
    number_of_buy = length(findall(x->x==1,agentPredictionArray))

    # setup the output array -
    dim_output_array = [number_of_sell, number_of_hold, number_of_buy]

    # find the argmin -
    arg_min_index = argmin(dim_output_array)

    # return -
    return alphabet_array[arg_min_index]
end

function _agent_update(agent::VLMinorityGameAgent, winningOutcome::Int64)
end

# === PRIVATE METHODS ABOVE HERE ====================================================================================== #

# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function simulate(worldObject::VLMinorityGameWorld, numberOfTimeSteps::Int64;
    gameWorldVoteManager::Function = _minority, gameAgentUpdateManager::Function = _agent_update)::NamedTuple

    try

        # setup -
        numberOfAgents = worldObject.numberOfAgents
        agentMemorySize = worldObject.agentMemorySize
        gameAgentArray = worldObject.gameAgentArray

        gameWorldMemoryBuffer = Array{Int64,1}() 
        agentPredictionArray = Array{Int64,1}(undef,agentMemorySize)

        # initialize -
        for _ = 1:(agentMemorySize+1)
            push!(gameWorldMemoryBuffer,1)
        end
        
        # main loop -
        for _ = 1:numberOfTimeSteps

            # grab the last agentMemorySize block -
            signalVector = gameWorldMemoryBuffer[(length(gameWorldMemoryBuffer) - gameWorldMemoryBuffer):end]

            # ask the agents what their prediction will be, given this signal vector -
            for agent_index = 1:numberOfAgents
                
                # grab the agent -
                agentObject = gameAgentArray[agent_index]

                # compute the prediction -
                agent_prediction = _prediction(agentObject, signalVector)

                # grab -
                push!(agentPredictionArray, agent_prediction)
            end

            # ok, so we asked all the agents what they voted to do, now lets id the minority position -
            winning_outcome = gameWorldVoteManager(agentPredictionArray)

            # update the agents data with the winning outcome -
            for agent_index = 1:numberOfAgents
                
                # grab the agent -
                agentObject = gameAgentArray[agent_index]

                # update the agent -
                gameAgentUpdateManager(agentObject, winning_outcome)
            end

            # add the winning outcome to the system memory -
            push!(gameWorldMemoryBuffer,winning_outcome)
        end

        # return -
        return_tuple = (agents = gameAgentArray, memory = gameWorldMemoryBuffer)
        return return_tuple
    catch error
        # if we get here ... something bad has happend. do nothing for now ...
    end
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #