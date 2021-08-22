using VLMinorityGameKit
using BSON

# setup call -
memory = 10
numberOfStrategiesPerAgent = 5
numberOfAgents = 1001

# setup -
# path_to_game_world = "/Users/jeffreyvarner/Desktop/julia_work/VLMinorityGameKit.jl/test/data/GW-T-M10-S5-NA1001.bson"
path_to_game_world = "/Users/jeffreyvarner/Desktop/proposals/VLMinorityGameKit.jl/test/data/GW-GC-M10-S5-NA1001.bson"

# build the game world -
# args: numberOfAgents::Int64, agentMemorySize::Int64, numberOfStrategiesPerAgent::Int64; actions::Array{Int64,1} = [-1,0,1]
game_world = build_minority_game_world(VLGCMinorityGameWorld; numberOfAgents=numberOfAgents, memory=memory, numberOfStrategiesPerAgent=numberOfStrategiesPerAgent)

# write the gameworld to disk -
bson(path_to_game_world, gameworld=game_world)