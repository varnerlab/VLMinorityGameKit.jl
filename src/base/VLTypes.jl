# abstract types -
abstract type VLAbstractGameWorld end
abstract type VLAbstractGameAgent end
abstract type VLAbstractGameStrategy end

# concrete types -
struct VLMinorityGameWorld <: VLAbstractGameWorld

    # data -
    numberOfAgents::Int64
    agentMemorySize::Int64
    gameAgentArray::Array{VLMinorityGameAgent,1}
    gameStrategyCollection::Array{VLMinorityGameStrategy,1}

    function VLMinorityGameWorld(numberOfAgents::Int64, agentMemorySize::Int64, agentArray::Array{VLMinorityGameAgent,1}, 
        gameStrategyCollection::Array{VLMinorityGameStrategy,1})
        _ = new(numberOfAgents, agentMemorySize, agentArray, gameStrategyCollection)
    end
end

struct VLMinorityGameStrategy <: VLAbstractGameStrategy

    # data -
    array::Dict{UInt64,Int64}

    function VLMinorityGameStrategy(strategyData::Array{Int64,2})
        _ = new(strategyData)
    end
end

mutable struct VLMinorityGameAgent <: VLAbstractGameAgent

    # data -
    agentStrategyCollection::Array{VLMinorityGameStrategy,1}
    strategyRankArray::Array{Int64,1}
    wealth::Int64

    function VLMinorityGameAgent(agentStrategyCollection::Array{VLMinorityGameStrategy,1}, strategyRankArray::Array{Int64,1}, wealth::Int64)
        _ = new(agentStrategyCollection, strategyRankArray, wealth)
    end
end

