using Base:NamedTuple
# abstract types -
abstract type VLAbstractGameWorld end
abstract type VLAbstractGameAgent end
abstract type VLAbstractGameStrategy end

# ----------------------------------------------------------------------------- #
# General -
struct VLMinorityGameSimulationResults
end
# ----------------------------------------------------------------------------- #

# ----------------------------------------------------------------------------- #
# Basic -
mutable struct VLBasicMinorityGameStrategy <: VLAbstractGameStrategy

    # data -
    strategy::Array{Int,1}
    score::Int64

    function VLBasicMinorityGameStrategy(strategy::Array{Int,1}, score::Int64)
        _ = new(strategy, score)
    end
end

mutable struct VLBasicMinorityGameAgent <: VLAbstractGameAgent

    # data -
    agentStrategyCollection::Array{VLBasicMinorityGameStrategy,1}
    bestAgentStrategy::Union{Nothing,VLBasicMinorityGameStrategy}
    score::Union{Int64,Float64}

    function VLBasicMinorityGameAgent(agentStrategyCollection::Array{VLBasicMinorityGameStrategy,1}; 
        bestStrategy::Union{Nothing,VLBasicMinorityGameStrategy}=nothing, score::Union{Int64,Float64}=1)
        _ = new(agentStrategyCollection, bestStrategy, score)
    end
end

struct VLBasicMinorityGameWorld <: VLAbstractGameWorld

    # data -
    numberOfAgents::Int64
    agentMemorySize::Int64
    gameAgentArray::Array{VLBasicMinorityGameAgent,1}

    function VLBasicMinorityGameWorld(numberOfAgents::Int64, agentMemorySize::Int64, agentArray::Array{VLBasicMinorityGameAgent,1})
        _ = new(numberOfAgents, agentMemorySize, agentArray)
    end
end
# ----------------------------------------------------------------------------- #

# ----------------------------------------------------------------------------- #
# Thermal -
mutable struct VLThermalMinorityGameStrategy <: VLAbstractGameStrategy

    # data -
    strategy::Array{Int,1}
    score::Int64
    probability::Float64

    function VLThermalMinorityGameStrategy(strategy::Array{Int,1}, score::Int64, probability::Float64)
        _ = new(strategy, score, probability)
    end
end

mutable struct VLThermalMinorityGameAgent <: VLAbstractGameAgent
    
    # data -
    agentStrategyCollection::Array{VLThermalMinorityGameStrategy,1}
    strategyRankArray::Array{Float64,1}
    score::Int64

    function VLThermalMinorityGameAgent(agents::Array{VLThermalMinorityGameStrategy,1}, 
        ranks::Array{Float64,1}, score::Int64)
        _ = new(agents, ranks, score)
    end
end

struct VLThermalMinorityGameWorld <: VLAbstractGameWorld

    # data -
    gameAgentArray::Array{VLThermalMinorityGameAgent,1}
    numberOfAgents::Int64
    agentMemorySize::Int64
    temperature::Float64
    
    function VLThermalMinorityGameWorld(gameAgentArray::Array{VLThermalMinorityGameAgent,1}, numberOfAgents::Int64, 
        agentMemorySize::Int64, temperature::Float64)
        _ = new(gameAgentArray, numberOfAgents, agentMemorySize, temperature)
    end
end
# ----------------------------------------------------------------------------- #

# ----------------------------------------------------------------------------- #
# Grand cannonical  -
mutable struct VLGCMinorityGameStrategy <: VLAbstractGameStrategy
end

mutable struct VLGCMinorityGameAgent <: VLAbstractGameAgent
    
    # data -
    agentStrategyCollection::Array{VLGCMinorityGameStrategy,1}
    score::Union{Int64,Float64}

end

struct VLGCMinorityGameWorld <: VLAbstractGameWorld

    # data -
    numberOfAgents::Int64
    agentMemorySize::Int64
    temperature::Float64
    gameAgentArray::Array{VLGCMinorityGameAgent,1}
end
# ----------------------------------------------------------------------------- #
