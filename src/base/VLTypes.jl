using Base:NamedTuple
# abstract types -
abstract type VLAbstractGameWorld end
abstract type VLAbstractGameAgent end
abstract type VLAbstractGameStrategy end

struct VLMinorityGameStrategy <: VLAbstractGameStrategy

    # data -
    strategy::Dict{UInt64,Int64}

    function VLMinorityGameStrategy(strategy::Dict{UInt64,Int64})
        _ = new(strategy)
    end
end

mutable struct VLMinorityGameStrategyScoreWrapper
    score::Int64
    strategy::VLMinorityGameStrategy 

    function VLMinorityGameStrategyScoreWrapper()
        _ = new()
    end
end

mutable struct VLMinorityGameAgent <: VLAbstractGameAgent

    # data -
    agentStrategyCollection::Array{VLMinorityGameStrategyScoreWrapper,1}
    bestAgentStrategy::Union{Nothing, VLMinorityGameStrategy}
    wealth::Union{Int64, Float64}

    function VLMinorityGameAgent(agentStrategyCollection::Array{VLMinorityGameStrategyScoreWrapper,1}; 
        bestStrategy::Union{Nothing, VLMinorityGameStrategy} = nothing, wealth::Union{Int64, Float64} = 1)
        _ = new(agentStrategyCollection, bestStrategy, wealth)
    end
end

# concrete types -
struct VLMinorityGameWorld <: VLAbstractGameWorld

    # data -
    numberOfAgents::Int64
    agentMemorySize::Int64
    gameAgentArray::Array{VLMinorityGameAgent,1}

    function VLMinorityGameWorld(numberOfAgents::Int64, agentMemorySize::Int64, agentArray::Array{VLMinorityGameAgent,1})
        _ = new(numberOfAgents, agentMemorySize, agentArray)
    end
end

