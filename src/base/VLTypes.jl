using Base:NamedTuple
# abstract types -
abstract type VLAbstractGameWorld end
abstract type VLAbstractGameAgent end
abstract type VLAbstractGameStrategy end

mutable struct VLMinorityGameStrategy <: VLAbstractGameStrategy

    # data -
    strategy::Array{Int,1}
    score::Int64

    function VLMinorityGameStrategy(strategy::Array{Int,1}, score::Int64)
        _ = new(strategy, score)
    end
end

mutable struct VLMinorityGameAgent <: VLAbstractGameAgent

    # data -
    agentStrategyCollection::Array{VLMinorityGameStrategy,1}
    bestAgentStrategy::Union{Nothing,VLMinorityGameStrategy}
    score::Union{Int64,Float64}

    function VLMinorityGameAgent(agentStrategyCollection::Array{VLMinorityGameStrategy,1}; 
        bestStrategy::Union{Nothing,VLMinorityGameStrategy}=nothing, score::Union{Int64,Float64}=1)
        _ = new(agentStrategyCollection, bestStrategy, score)
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

