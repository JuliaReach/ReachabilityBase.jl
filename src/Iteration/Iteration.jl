"""
    Iteration

This module provides convenience functionality for iteration.
"""
module Iteration

export EmptyIterator, SingletonIterator,
       StrictlyIncreasingIndices, NondecreasingIndices, BitvectorIterator,
       CartesianIterator

include("EmptyIterator.jl")
include("SingletonIterator.jl")
include("StrictlyIncreasingIndices.jl")
include("NondecreasingIndices.jl")
include("BitvectorIterator.jl")
include("CartesianIterator.jl")

end  # module
