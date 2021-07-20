using VLMinorityGameKit

# setup call -
actionArray = [-1,1]
memory = 8
numberOfStrategiesPerAgent = 5
numberOfAgents = 1001

println("Building the game world - start")

# build the game world -
# args: numberOfAgents::Int64, agentMemorySize::Int64, numberOfStrategiesPerAgent::Int64; actions::Array{Int64,1} = [-1,0,1]
gameWorld = build_game_world(numberOfAgents, memory, numberOfStrategiesPerAgent; actions=actionArray)

println("Building the game world - finished. Starting the simulation ...")

# setup the number of time steps -
numberOfTimeSteps = 201
result = simulate(gameWorld, numberOfTimeSteps; actions=actionArray);
nothing