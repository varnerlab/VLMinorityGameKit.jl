# === PRIVATE METHODS BELOW HERE ====================================================================================== #
# === PRIVATE METHODS ABOVE HERE ====================================================================================== #

# === PUBLIC METHODS BELOW HERE ======================================================================================= #
function compute_price_return(price_vector::Array{Float64,1})::Array{Float64,1}
    
    try

        # initialize -
        number_of_items = length(price_vector)
        price_return_array = Array{Float64,1}(undef, (number_of_items - 1))

        # main loop -
        for time_index = 1:(number_of_items - 1)
            
            # grab the prices -
            today_price = price_vector[time_index]
            tomorrow_price = price_vector[time_index + 1]

            # calculate the return -
            r = log(tomorrow_price / today_price)
        
            # cache -
            price_return_array[time_index] = r
        end

        # return -
        return price_return_array
    catch error
        rethrow(error)
    end
end

function compute_price_return(price_array::Array{Float64,2})::Array{Float64,2}

    try

        # initialize -
        (number_of_steps, number_of_cols) = size(price_array)
        price_return_array = Array{Float64,2}(undef, (number_of_steps - 1), number_of_cols)

        # main loop -
        for col_index = 1:number_of_cols
            
            # grab a col -
            data_vector = price_array[:,col_index]
        
            # compute the return for this sequence -
            local_return_array = compute_price_return(data_vector)

            # package -
            for time_index = 1:(number_of_steps - 1)
                price_return_array[time_index,col_index] = local_return_array[time_index]
            end
        end

        # return -
        return price_return_array
    catch error
        rethrow(error)
    end
end

function compute_price_return(simulation_result_array::Array{DataFrame,1})::Array{Float64,2}

    try

        # how many sample tables do we have?
        number_of_samples = length(simulation_result_array)

        # grab a table to get the dimensions -
        tmp_table = simulation_result_array[1]
        (number_of_steps, _) = size(tmp_table)

        # initialize storage -
        price_return_array = Array{Float64,2}(undef, (number_of_steps - 1), number_of_samples)
        
        # process each sample -
        for sample_index = 1:number_of_samples
            
            # grab the price data -
            P = simulation_result_array[sample_index][!,:price]
        
            # compute the return -
            r_array = compute_price_return(P) # this has number_of_steps - 1 elements

            # copy the data into the storage -
            for step_index = 1:(number_of_steps - 1)
                price_return_array[step_index, sample_index] = r_array[step_index]
            end
        end

        # return -
        return price_return_array
    catch error
        rethrow(error)
    end
end

function compute_autocorrelation_array(price_return_vector::Array{Float64,1}, 
    lag_array::Array{Int64,1})::Array{Float64,1}

    try

        # return -
        return autocor(price_return_vector, lag_array)
    catch error
        rethrow(error)
    end
end

function compute_autocorrelation_array(price_return_array::Array{Float64,2}, 
    lag_array::Array{Int64,1})::Array{Float64,2}

    try

        # initialize -
        (number_of_steps, number_of_samples) = size(price_return_array)
        number_of_lags = length(lag_array)
        autocor_array = Array{Float64,2}(undef, number_of_lags, number_of_samples)

        # process each sample -
        for sample_index = 1:number_of_samples
            
            # data -
            data_col = price_return_array[:, sample_index]
            local_autocor_array = compute_autocorrelation_array(data_col, lag_array)
        
            # package -
            for lag_index = 1:number_of_lags
                autocor_array[lag_index, sample_index] = local_autocor_array[lag_index]
            end
        end

        # return -
        return autocor_array
    catch error
        rethrow(error)
    end
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #