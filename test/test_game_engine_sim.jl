using VLMinorityGameKit
using BSON
using Plots

# setup -
actionArray = [-1,1]
path_to_game_world = "/Users/jeffreyvarner/Desktop/julia_work/VLMinorityGameKit.jl/test/data/GW-M10-S5-NA1001.bson"
d = BSON.load(path_to_game_world)
gameWorld = d[:gameworld]

println("Building the game world - finished. Starting the simulation ...")

# setup the number of time steps -
number_of_samples = 100
numberOfTimeSteps = 140
numberOfTraders = 1001
price_array = Array{Float64,2}(undef,(numberOfTimeSteps+1),number_of_samples) 

for sample_index = 1:number_of_samples
    result = simulate(gameWorld, numberOfTimeSteps; actions=actionArray, liquidity = 10.0*numberOfTraders);
    P = result.price
    for time_index = 1:(numberOfTimeSteps+1)
        price_array[time_index,sample_index] = P[time_index]
    end
end

result = simulate(gameWorld, numberOfTimeSteps; actions=actionArray, liquidity = 10.0*numberOfTraders);
println("Simulation is finished .... enjoy.")

nothing