
function _build(modeltype::Type{VLBasicMinorityGameWorld}, data::NamedTuple)::VLBasicMinorityGameWorld

    # build an empty model -
    model = modeltype();

    # return -
    return model;
end

function _build(modeltype::Type{VLBasicMinorityGameAgent}, data::NamedTuple)::VLBasicMinorityGameAgent

    # build an empty model -
    model = modeltype();

    # return -
    return model;
end

function _build(modeltype::Type{VLBasicMinorityGameStrategy}, data::NamedTuple)::VLBasicMinorityGameStrategy

    # build an empty model -
    model = modeltype();

    # return -
    return model;
end


# -- PUBLIC FUNCTIONS BELOW HERE ------------------------------------------------------------------ #
function build(modeltype::Type{T}, data::NamedTuple) where T <: VLAbstractGameWorld
    return _build(modeltype, data);
end

function build(modeltype::Type{T}, data::NamedTuple) where T <: VLAbstractGameAgent
    return _build(modeltype, data);
end

function build(modeltype::Type{T}, data::NamedTuple) where T <: VLAbstractGameStrategy
    return _build(modeltype, data);
end

function basic(; data::NamedTuple)::VLBasicMinorityGameWorld

    # get data from the named tuple -
    number_of_agents = data.number_of_agents;
    agent_memory_dictionary = data.agent_memory_dictionary;

    # 1. build a list of agents -



    # build the world -
    world = build(VLBasicMinorityGameWorld, data);

    # return -
    return world;
end
# -- PUBLIC FUNCTIONS ABOVE HERE ------------------------------------------------------------------ #