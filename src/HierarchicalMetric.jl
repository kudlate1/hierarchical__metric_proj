module HierarchicalMetric

using Pkg
using Random, Distances
using Flux
using Mill
using HSTreeDistance
using JsonGrinder
using JSON3
using Plots
using Colors


abstract type TripletSelectionMethod end

struct SelectRandom <: TripletSelectionMethod end
struct SelectHard <: TripletSelectionMethod end

export TripletSelectionMethod, SelectHard, SelectRandom

include("triplet-loss.jl")
export pairwiseDistance
export selectTriplet
export tripletLoss
export distance
export splitClasses

include("datatraining.jl")
export train

include("dataloading.jl")
export load

function test()
    Pkg.test("HierarchicalMetric.jl")
end

export test

end