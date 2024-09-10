# setup project paths -
const _PATH_TO_SRC = dirname(pathof(@__MODULE__))
const _PATH_TO_BASE = joinpath(_PATH_TO_SRC, "base")

# import packages that we will use -
using DataFrames
using Distributions
using JLD2
using Random
using StatsBase
using Statistics
using CSV
using FileIO
using Test
using DataStructures
using UUIDs

# set the seed -
Random.seed!(Random.make_seed())

# include our codes -
include(joinpath(_PATH_TO_BASE, "Types.jl"))
include(joinpath(_PATH_TO_BASE, "Factory.jl"))
include(joinpath(_PATH_TO_BASE, "Engine.jl"))
include(joinpath(_PATH_TO_BASE, "Analysis.jl"))