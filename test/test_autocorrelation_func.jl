using VLMinorityGameKit
using BSON
using DataFrames
using Plots

# helper functions -
function load_simulation_data(path_to_data::String, keyname::String)::Dict
    d = BSON.load(path_to_data)
    return d[Symbol(keyname)]
end

function compute_return_array(path_to_sim_data_file::String)::Array{Float64,2}

    keyname = "data"
    simulation_dictionary = load_simulation_data(path_to_sim_data_file, keyname)
    number_of_samples = simulation_dictionary["number_of_samples"]
    number_of_timesteps = simulation_dictionary["number_of_timesteps"]
    simulation_result_array = simulation_dictionary["simulation_result_array"]

    # initialize some space, collect the data and make the plot
    sim_return_array = Array{Float64,2}(undef, (number_of_timesteps - 1), number_of_samples)
    for sample_index = 1:number_of_samples

        # grab the sim -
        M = simulation_result_array[sample_index]

        # grab the market data, and get the price -
        P = M[!,:price]

        # the price data into the price_array -
        for time_step_index = 1:(number_of_timesteps - 1)
            
            # get prices -
            today_price = P[time_step_index]
            tomorrow_price = P[time_step_index + 1]

            # compute r -
            r = log(tomorrow_price / today_price)

            # package -
            sim_return_array[time_step_index, sample_index] = r
        end
    end

    return sim_return_array
end

# path to simulation file -
path_to_sim_data_file = "/Users/jeffreyvarner/Desktop/julia_work/VLMinorityGameKit.jl/test/data/results/SIM-T-M10-S5-NA1001-L3.bson"
L3_return_array = compute_return_array(path_to_sim_data_file)

# test the autocorrelation -
(number_of_timesteps, number_of_samples) = size(L3_return_array)
lag_array = range(0,stop=(number_of_timesteps - 1),step=1) |> collect
acr = compute_autocorrelation_array(L3_return_array[:,2], lag_array)

