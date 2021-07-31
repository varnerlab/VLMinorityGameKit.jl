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

# methods -
export basic
export build_agent_strategy
export build_game_agent
export build_game_world

# analysis functions -
export compute_price_return
export compute_autocorrelation_array

# for debug -
export design

end # module
