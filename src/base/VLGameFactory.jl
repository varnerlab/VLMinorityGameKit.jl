# === PRIVATE METHODS BELOW HERE ====================================================================================== #
# === PRIVATE METHODS ABOVE HERE ====================================================================================== #

# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function build_agent_strategy(actions::Array{Int64,1}, memory::Int64)::VLMinorityGameStrategy

    try

        # initialize -
        strategy_dictionary = Dict{UInt64,Int64}()

        # ok, so lets build a strategy -
        size_of_alphabet = length(actions)
        number_of_elements = (size_of_alphabet)^memory

        # get the min, and max of the alphabet -
        min_value = minimum(actions)
        max_value = maximum(actions)

        # generate the design matrix -
        M = Matrix(FullFactorial(fill(actions, memory)).matrix)

        # generate an outcome vector -
        outcome_vector = rand(min_value:max_value, number_of_elements)

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

        # TODO: fill me in ...

    catch error
        # just rethrow the error for now ...
        rethrow(error)
    end
end

function build_game_world(numberOfAgents::Int64, agentMemorySize::Int64; 
    actions::Array{Int64,1} = [-1,0,1])::VLMinorityGameWorld

    try

        # TODO: fill me in ...

    catch error
        # just rethrow the error for now ...
        rethrow(error)
    end
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #