
function test(signalVector)

    memory = length(signalVector)
    
    # we use binary 0,1 under the covers - so lets get rid of the -1 and replace w/0 -
    binarySignal = replace(signalVector, -1 => 0)
    iv = range(memory, stop=1, step=-1) |> collect

    # convert the binarySignal to an int -
    strategy_index = 0
    for index in iv
        value = binarySignal[index]
        strategy_index += value * 2^(memory - index)
    end

    return (strategy_index)
end

signalVector = [-1,-1, 1]
r = test(signalVector)