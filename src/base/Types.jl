using Base:NamedTuple

# abstract types -
abstract type VLAbstractGameWorld end
abstract type VLAbstractGameAgent end
abstract type VLAbstractGameStrategy end

# ----------------------------------------------------------------------------- #
# General -
struct VLMinorityGameSimulationResult
    data::Union{Nothing, DataFrame}
end
# ----------------------------------------------------------------------------- #

# ----------------------------------------------------------------------------- #
# Basic -
mutable struct VLBasicMinorityGameStrategy <: VLAbstractGameStrategy

    # data -
    strategy::Array{Int,1}
    score::Int64

    # constructor -
    VLBasicMinorityGameStrategy() = new();
end

mutable struct VLBasicMinorityGameAgent <: VLAbstractGameAgent

    # data -
    id::UUID
    memorySize::Int64
    score::Int64
    strategy::VLBasicMinorityGameStrategy

    # constructor -
    VLBasicMinorityGameAgent() = new();
end

"""
    mutable struct VLBasicMinorityGameWorld <: VLAbstractGameWorld

A mutable struct that represents the world of the basic minority game. It contains the following fields:

### Fields
- `gameAgentSet::Set{VLBasicMinorityGameAgent}`: A set of agents in the game world.
"""
struct VLBasicMinorityGameWorld <: VLAbstractGameWorld

    # data -
    agents::Set{VLBasicMinorityGameAgent}

    # constructor -
    VLBasicMinorityGameWorld() = new();
end
# ----------------------------------------------------------------------------- #
