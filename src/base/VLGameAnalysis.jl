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
            r = log(tomorrow_price/today_price)
        
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

function compute_autocorrelation()
end
# === PUBLIC METHODS ABOVE HERE ======================================================================================= #