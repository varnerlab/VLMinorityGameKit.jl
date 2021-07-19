using VLMinorityGameKit

# setup call -
actions = [-1,0,1]
memory = 4
numberOfStrategiesPerAgent = 2
numberOfAgents = 100

# build the game world -
# args: numberOfAgents::Int64, agentMemorySize::Int64, numberOfStrategiesPerAgent::Int64; actions::Array{Int64,1} = [-1,0,1]
game_world = build_game_world(numberOfAgents, memory, numberOfStrategiesPerAgent; actions = actions)