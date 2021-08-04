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

export VLThermalMinorityGameWorld
export VLThermalMinorityGameAgent
export VLThermalMinorityGameStrategy

export VLGCMinorityGameStrategy
export VLGCMinorityGameAgent
export VLGCMinorityGameWorld

export VLMinorityGameSimulationResult

# methods -
export execute
export build_minority_game_world

# analysis functions -
export compute_price_return
export compute_autocorrelation_array

# for debug -
export design

end # module
