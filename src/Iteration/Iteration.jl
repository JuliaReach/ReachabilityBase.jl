"""
    Iteration

This module provides convenience functionality for iteration.
"""
module Iteration

using SparseArrays

export EmptyIterator, SingletonIterator, VectorIterator,
       StrictlyIncreasingIndices, NondecreasingIndices, BitvectorIterator

include("EmptyIterator.jl")
include("SingletonIterator.jl")
include("VectorIterator.jl")
include("StrictlyIncreasingIndices.jl")
include("NondecreasingIndices.jl")
include("BitvectorIterator.jl")

end  # module
