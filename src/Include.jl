# setup project paths -
const _PATH_TO_SRC = dirname(pathof(@__MODULE__))
const _PATH_TO_BASE = joinpath(_PATH_TO_SRC, "base")

# import packages that we will use -
using JSON
using Logging
using ExperimentalDesign
using DataFrames
using Plots
using BSON

# include our codes -
include(joinpath(_PATH_TO_BASE, "VLTypes.jl"))
include(joinpath(_PATH_TO_BASE, "VLGameEngine.jl"))
include(joinpath(_PATH_TO_BASE, "VLGameFactory.jl"))