module VLMinorityGameKit

# include -
include("Include.jl")

# method and type exports -
# types -
export VLAbstractGameWorld
export VLAbstractGameAgent
export VLAbstractGameStrategy

export VLMinorityGameWorld
export VLMinorityGameAgent
export VLMinorityGameStrategy
export VLMinorityGameStrategyScoreWrapper

# methods -
export simulate
export build_agent_strategy
export build_game_agent
export build_game_world

# for debug -
export design

end # module
