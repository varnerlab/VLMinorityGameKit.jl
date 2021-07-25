# === PRIVATE METHODS BELOW HERE ====================================================================================== #
function design(n::Int64)

    # initialize -
    bitStringArray = Array{String,1}()

    # build the bit strings -
    for i = 0:((2^n) - 1)
        stmp = bitstring(i)
        value = stmp[end - n + 1:end]
        push!(bitStringArray, value)
    end

    # return -
    return bitStringArray
end
# === PRIVATE METHODS ABOVE HERE ====================================================================================== #


# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function build_agent_strategy(memory::Int64, score::Int64)::VLMinorityGameStrategy

    try

        # initialize -
        size_of_alphabet = 2
        number_of_elements = (size_of_alphabet)^memory
        outcome_vector = Array{Int,1}(undef, number_of_elements)
        actions = [-1,1]

        # generate an outcome vector -
        for index = 1:number_of_elements
            
            # generate an index -
            r_index = rand(1:2)

            # outcome -
            outcome_vector[index] = actions[r_index]
        end

        # return -
        return VLMinorityGameStrategy(outcome_vector, score)  # default: score = 0 strategy
    catch error
        rethrow(error)
    end
end

function build_game_agent(numberOfStrategiesPerAgent::Int64, agentMemorySize::Int64)::VLMinorityGameAgent

    try

        # build a collection of strategies for this agent -
        # each agent is going to need numberOfStrategiesPerAgent strategies 
        local_strategy_cache = Array{VLMinorityGameStrategy,1}(undef, numberOfStrategiesPerAgent)
        for strategy_index = 1:numberOfStrategiesPerAgent
            
            # build the strategy - initially all strategies will have a score of zero -
            strategy = build_agent_strategy(agentMemorySize, 0)

            # package -
            local_strategy_cache[strategy_index] = strategy
        end

        # build agent object - use the first strategy as the best -
        return VLMinorityGameAgent(local_strategy_cache; bestStrategy=first(local_strategy_cache))
    catch error
        # just rethrow the error for now ...
        rethrow(error)
    end
end

function build_game_world(numberOfAgents::Int64, agentMemorySize::Int64, numberOfStrategiesPerAgent::Int64)::VLMinorityGameWorld

    try

        # in order to create a game world, we need:
        # numberOfAgents::Int64
        # agentMemorySize::Int64
        # gameAgentArray::Array{VLMinorityGameAgent,1}

        # iniialize -
        gameAgentArray = Array{VLMinorityGameAgent,1}(undef, numberOfAgents)

        # we have two of the three, lets create an array of game agents -
        for agent_index = 1:numberOfAgents

            println("Building agent $(agent_index) of $(numberOfAgents)")

            # create an agent -
            agent = build_game_agent(numberOfStrategiesPerAgent, agentMemorySize)

            # package -
            gameAgentArray[agent_index] = agent
        end

        # build the game world -
        return VLMinorityGameWorld(numberOfAgents, agentMemorySize, gameAgentArray)
    catch error
        # just rethrow the error for now ...
        rethrow(error)
    end
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #