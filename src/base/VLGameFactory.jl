
# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function build_agent_strategy(actions::Array{Int64,1}, memory::Int64)::VLMinorityGameStrategy

    try

        # initialize -
        strategy_dictionary = Dict{UInt64,Int64}()

        # ok, so lets build a strategy -
        size_of_alphabet = length(actions)
        number_of_elements = (size_of_alphabet)^memory
        outcome_vector = Array{Int64,1}(undef,number_of_elements)

        # generate the design matrix -
        M = Matrix(FullFactorial(fill(actions, memory)).matrix)

        # generate an outcome vector -
        outcome_index_vector = rand(1:size_of_alphabet, number_of_elements)
        for index = 1:number_of_elements
            outcome_vector[index] = actions[outcome_index_vector[index]]
        end

        # mush the M and outcomes together -
        strategy_array = hcat(M, outcome_vector)

        # convert array to dictionary -
        (number_of_rows, number_of_cols) = size(strategy_array)
        for row_index = 1:number_of_rows
            
            # row -
            row_data = strategy_array[row_index, 1:(number_of_cols - 1)]
            outcome_value = strategy_array[row_index, end]
            key_data = hash(row_data)
            
            # build the dictionary -
            strategy_dictionary[key_data] = outcome_value
        end

        # return -
        return VLMinorityGameStrategy(strategy_dictionary)
    catch error
        rethrow(error)
    end
end

function build_game_agent(numberOfStrategiesPerAgent::Int64, agentMemorySize::Int64; 
    actions::Array{Int64,1} = [-1,0,1])::VLMinorityGameAgent

    try

        # build a collection of strategies for this agent -
        # each agent is going to need numberOfStrategiesPerAgent strategies 
        local_strategy_cache = Array{VLMinorityGameStrategyScoreWrapper,1}(undef,numberOfStrategiesPerAgent)
        for strategy_index = 1:numberOfStrategiesPerAgent
            
            # build the strategy -
            strategy = build_agent_strategy(actions, agentMemorySize)

            # initially all strategies will have a score of zero -
            score = 0

            # package -
            strategy_wrapper = VLMinorityGameStrategyScoreWrapper()
            strategy_wrapper.score = score
            strategy_wrapper.strategy = strategy
            local_strategy_cache[strategy_index] = strategy_wrapper
        end

        # build agent object - use the first strategy as the best -
        return VLMinorityGameAgent(local_strategy_cache; bestStrategy = first(local_strategy_cache).strategy)
    catch error
        # just rethrow the error for now ...
        rethrow(error)
    end
end

function build_game_world(numberOfAgents::Int64, agentMemorySize::Int64, numberOfStrategiesPerAgent::Int64; 
    actions::Array{Int64,1} = [-1,0,1])::VLMinorityGameWorld

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
            agent = build_game_agent(numberOfStrategiesPerAgent, agentMemorySize; actions=actions)

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