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

    function VLMinorityGameWorld(numberOfAgents::Int64, agentMemorySize::Int64, agentArray::Array{VLMinorityGameAgent,1})
        _ = new(numberOfAgents, agentMemorySize, agentArray)
    end
end

struct VLMinorityGameStrategy <: VLAbstractGameStrategy

    # data -
    array::Array{Int64,2}

    function VLMinorityGameStrategy(strategyData::Array{Int64,2})
        _ = new(strategyData)
    end
end

mutable struct VLMinorityGameAgent <: VLAbstractGameAgent

    # data -
    gameStrategyCollection::Array{VLMinorityGameStrategy,1}

    function VLMinorityGameAgent(strategyObjectArray::Array{VLMinorityGameStrategy,1})
        _ = new(strategyObjectArray)
    end
end

