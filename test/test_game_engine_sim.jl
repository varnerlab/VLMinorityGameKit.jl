using VLMinorityGameKit
using BSON

# setup -
actionArray = [-1,1]
path_to_game_world = "/Users/jeffreyvarner/Desktop/julia_work/VLMinorityGameKit.jl/test/data/GW-M10-S5-NA1001.bson"
d = BSON.load(path_to_game_world)
gameWorld = d[:gameworld]

println("Building the game world - finished. Starting the simulation ...")

# setup the number of time steps -
numberOfTimeSteps = 301
result = simulate(gameWorld, numberOfTimeSteps; actions=actionArray);
nothing