# setup project paths -
const _PATH_TO_SRC = dirname(pathof(@__MODULE__))
const _PATH_TO_BASE = joinpath(_PATH_TO_SRC, "base")

# import packages that we will use -
using JSON
using Logging
using DataFrames
using Plots
using BSON
using Distributions
using Random

# set the seed -
Random.seed!(Random.make_seed())

# include our codes -
include(joinpath(_PATH_TO_BASE, "VLTypes.jl"))
include(joinpath(_PATH_TO_BASE, "VLGameEngine.jl"))
include(joinpath(_PATH_TO_BASE, "VLGameFactory.jl"))