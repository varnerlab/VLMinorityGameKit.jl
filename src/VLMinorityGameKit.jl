module VLMinorityGameKit

# include -
include("Include.jl")

# method and type exports -
# types -
export VLAbstractGameWorld
export VLAbstractGameAgent
export VLAbstractGameStrategy

export VLBasicMinorityGameWorld
export VLBasicMinorityGameAgent
export VLBasicMinorityGameStrategy

# methods -
export execute_basic_game
export execute_thermal_game
export execute_grand_cannonical_game
export build_basic_agent_strategy
export build_basic_game_agent
export build_basic_game_world

# analysis functions -
export compute_price_return
export compute_autocorrelation_array

# for debug -
export design

end # module
