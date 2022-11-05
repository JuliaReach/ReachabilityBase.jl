"""
    Iteration

This module provides convenience functionality for iteration.
"""
module Iteration

using SparseArrays

export EmptyIterator, SingletonIterator, VectorIterator, ColumnIterator,
       StrictlyIncreasingIndices

include("EmptyIterator.jl")
include("SingletonIterator.jl")
include("VectorIterator.jl")
include("ColumnIterator.jl")
include("StrictlyIncreasingIndices.jl")

end  # module
