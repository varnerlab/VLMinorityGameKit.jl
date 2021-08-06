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

# ---------------------------------------------------------------------------------------------------- #
# basic -
function _build_basic_agent_strategy(memory::Int64, score::Int64)::VLBasicMinorityGameStrategy

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
        return VLBasicMinorityGameStrategy(outcome_vector, score)  # default: score = 0 strategy
    catch error
        rethrow(error)
    end
end

function _build_basic_game_agent(numberOfStrategiesPerAgent::Int64, 
    agentMemorySize::Int64)::VLBasicMinorityGameAgent

    try

        # build a collection of strategies for this agent -
        # each agent is going to need numberOfStrategiesPerAgent strategies 
        local_strategy_cache = Array{VLBasicMinorityGameStrategy,1}(undef, numberOfStrategiesPerAgent)
        for strategy_index = 1:numberOfStrategiesPerAgent
            
            # build the strategy - initially all strategies will have a score of zero -
            strategy = _build_basic_agent_strategy(agentMemorySize, 0)

            # package -
            local_strategy_cache[strategy_index] = strategy
        end

        # build agent object - use the first strategy as the best -
        return VLBasicMinorityGameAgent(local_strategy_cache; bestStrategy=first(local_strategy_cache))
    catch error
        # just rethrow the error for now ...
        rethrow(error)
    end
end

function _build_basic_game_world(kwargs_dictionary::Dict)

    try

        # in order to create a game world, we need:
        # numberOfAgents::Int64
        # agentMemorySize::Int64
        # gameAgentArray::Array{VLMinorityGameAgent,1}

        # get data from the args -
        numberOfAgents = kwargs_dictionary[:numberOfAgents]
        agentMemorySize = kwargs_dictionary[:memory]
        numberOfStrategiesPerAgent = kwargs_dictionary[:numberOfStrategiesPerAgent]

        # iniialize -
        gameAgentArray = Array{VLBasicMinorityGameAgent,1}(undef, numberOfAgents)

        # we have two of the three, lets create an array of game agents -
        for agent_index = 1:numberOfAgents

            println("Building agent $(agent_index) of $(numberOfAgents)")

            # package -
            gameAgentArray[agent_index] = _build_basic_game_agent(numberOfStrategiesPerAgent, agentMemorySize)
        end

        # build the game world -
        return VLBasicMinorityGameWorld(numberOfAgents, agentMemorySize, gameAgentArray)
    catch error
        # just rethrow the error for now ...
        rethrow(error)
    end
end
# ---------------------------------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------------------------------- #
# thermal -
function _build_thermal_agent_strategy(memory::Int64, score::Int64, probability::Float64)::VLThermalMinorityGameStrategy

    try
        
        # initialize -
        actions = [-1,1]
        size_of_alphabet = length(actions)
        number_of_elements = (size_of_alphabet)^memory
        outcome_vector = Array{Int,1}(undef, number_of_elements)
        
        # generate an outcome vector -
        for index = 1:number_of_elements
            
            # generate an index -
            r_index = rand(1:2)

            # outcome -
            outcome_vector[index] = actions[r_index]
        end

        # return -
        return VLThermalMinorityGameStrategy(outcome_vector, score, probability)  # default: score = 0 strategy
    catch error
        rethrow(error)
    end
end

function _build_thermal_game_agent(numberOfStrategiesPerAgent::Int64, agentMemorySize::Int64)::VLThermalMinorityGameAgent

    try
    
        # initialize -
        probability = (1.0/numberOfStrategiesPerAgent)

        # ok, let's build the collection of strategies for this agent, and the ranking array -
        strategyCollection = Array{VLThermalMinorityGameStrategy,1}(undef, numberOfStrategiesPerAgent)
        for strategy_index = 1:numberOfStrategiesPerAgent
            
            # build a strategy -
            strategyCollection[strategy_index] = _build_thermal_agent_strategy(agentMemorySize, 0, probability)            
        end

        # return -
        return VLThermalMinorityGameAgent(strategyCollection, 0)
    catch error
        rethrow(error)
    end
end

function _build_thermal_game_world(kwargs_dictionary::Dict)::VLThermalMinorityGameWorld

    try

        # initialize -
        numberOfAgents = kwargs_dictionary[:numberOfAgents]
        agentMemorySize = kwargs_dictionary[:memory]
        numberOfStrategiesPerAgent = kwargs_dictionary[:numberOfStrategiesPerAgent]
        temperatute = kwargs_dictionary[:temperature]

        # build an array of game agents -
        agentArray = Array{VLThermalMinorityGameAgent,1}(undef, numberOfAgents)
        for agent_index = 1:numberOfAgents

            # build agents, package -
            agentArray[agent_index] = _build_thermal_game_agent(numberOfStrategiesPerAgent, agentMemorySize)
        end

        # build -
        return VLThermalMinorityGameWorld(agentArray, numberOfAgents, agentMemorySize, temperatute)
    catch error
        rethrow(error)
    end
end
# ---------------------------------------------------------------------------------------------------- #

# ---------------------------------------------------------------------------------------------------- #
# grand cannonical -
function _build_gc_agent_strategy(memory::Int64, score::Int64)::VLGCMinorityGameStrategy

    try
    catch error
        rethrow(error)
    end
end

function _build_gc_game_agent(numberOfStrategiesPerAgent::Int64, 
    agentMemorySize::Int64, temperatute::Float64)::VLGCMinorityGameAgent

    try
    catch error
        rethrow(error)
    end
end

function _build_gc_game_world(kwargs_dictionary::Dict)::VLGCMinorityGameWorld

    try
    catch error
        rethrow(error)
    end
end
# ---------------------------------------------------------------------------------------------------- #

# === PRIVATE METHODS ABOVE HERE ====================================================================================== #


# === PUBLIC METHODS BELOW HERE ======================================================================================= #

# generic -
function build_minority_game_world(game::Union{Type{VLBasicMinorityGameWorld},Type{VLThermalMinorityGameWorld},Type{VLGCMinorityGameWorld}}; 
    kwargs...) 

    try

        # initialize -
        kwargs_dictionary = Dict(kwargs)
        function_dictionarty = Dict()

        # setup function dictionary -
        function_dictionarty[VLBasicMinorityGameWorld] = _build_basic_game_world
        function_dictionarty[VLThermalMinorityGameWorld] = _build_thermal_game_world
        function_dictionarty[VLGCMinorityGameWorld] = _build_gc_game_world

        # ok, call the linked function -
        return function_dictionarty[game](kwargs_dictionary)
    catch error
        rethrow(error)
    end
end

# === PUBLIC METHODS ABOVE HERE ======================================================================================= #