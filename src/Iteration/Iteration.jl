"""
    Iteration

This module provides convenience functionality for iteration.
"""
module Iteration

export EmptyIterator, SingletonIterator, VectorIterator,
       StrictlyIncreasingIndices

include("EmptyIterator.jl")
include("SingletonIterator.jl")
include("VectorIterator.jl")
include("StrictlyIncreasingIndices.jl")

end  # module
