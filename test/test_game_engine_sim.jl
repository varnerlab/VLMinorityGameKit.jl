using VLMinorityGameKit

# setup call -
actions = [-1,0,1]
memory = 5
numberOfStrategiesPerAgent = 4
numberOfAgents = 100

# build the game world -
# args: numberOfAgents::Int64, agentMemorySize::Int64, numberOfStrategiesPerAgent::Int64; actions::Array{Int64,1} = [-1,0,1]
gameWorld = build_game_world(numberOfAgents, memory, numberOfStrategiesPerAgent; actions = actions)

# setup the number of time steps -
numberOfTimeSteps = 1000
result = simulate(gameWorld, numberOfTimeSteps)