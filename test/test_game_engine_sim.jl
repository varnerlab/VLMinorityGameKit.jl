using VLMinorityGameKit
using BSON
using Plots
using DataFrames

# setup -
# path_to_game_world = "/Users/jeffreyvarner/Desktop/julia_work/VLMinorityGameKit.jl/test/data/GW-M10-S5-NA1001.bson"
path_to_game_world = "/Users/jeffreyvarner/Desktop/julia_work/VLMinorityGameKit.jl/test/data/GW-M10-S5-NA1001.bson"
path_to_results_dir = "/Users/jeffreyvarner/Desktop/julia_work/VLMinorityGameKit.jl/test/data/results/SIM-M10-S5-NA1001-L3.bson"
d = BSON.load(path_to_game_world)
gameWorld = d[:gameworld]

println("Building the game world - finished. Starting the simulation ...")

# setup the number of time steps -
number_of_samples = 100
numberOfTimeSteps = 140
numberOfTraders = 1001
price_array = Array{Float64,2}(undef, (numberOfTimeSteps), number_of_samples)
simulation_result_array = Array{DataFrame,1}(undef, number_of_samples)

for sample_index = 1:number_of_samples
    result = execute(gameWorld, numberOfTimeSteps; liquidity=3.0 * numberOfTraders);
    simulation_result_array[sample_index] = result.market_table
    println("Completed sample = $(sample_index) ...")
end

# package -
simulation_dictionary = Dict()
simulation_dictionary["number_of_samples"] = number_of_samples
simulation_dictionary["number_of_timesteps"] = numberOfTimeSteps
simulation_dictionary["number_of_traders"] = numberOfTraders
simulation_dictionary["memory"] = 10
simulation_dictionary["strategies_per_agent"] = 5
simulation_dictionary["liquidity"] = 3.0 * numberOfTraders
simulation_dictionary["simulation_result_array"] = simulation_result_array

# dump -
bson(path_to_results_dir, data=simulation_dictionary)

# result = simulate(gameWorld, numberOfTimeSteps; liquidity=10.0 * numberOfTraders);
println("Simulation is finished .... enjoy.")