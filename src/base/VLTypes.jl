using Base:NamedTuple
# abstract types -
abstract type VLAbstractGameWorld end
abstract type VLAbstractGameAgent end
abstract type VLAbstractGameStrategy end

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

# concrete types -
struct VLBasicMinorityGameWorld <: VLAbstractGameWorld

    # data -
    numberOfAgents::Int64
    agentMemorySize::Int64
    gameAgentArray::Array{VLBasicMinorityGameAgent,1}

    function VLBasicMinorityGameWorld(numberOfAgents::Int64, agentMemorySize::Int64, agentArray::Array{VLBasicMinorityGameAgent,1})
        _ = new(numberOfAgents, agentMemorySize, agentArray)
    end
end

