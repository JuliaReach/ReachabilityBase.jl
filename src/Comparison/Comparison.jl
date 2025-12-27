"""
    Comparison

This module provides convenience functions to compare numerical values up to
some user-controlled precision.
"""
module Comparison

using SparseArrays

export set_rtol, set_ztol, set_atol, set_tolerance,
       _rtol, _ztol, _atol, default_tolerance,
       _geq, _leq, _in, _isapprox, isapproxzero, isidentical

include("tolerance.jl")
include("isapproxzero.jl")
include("isapprox.jl")
include("inequality.jl")
include("in.jl")
include("isidentical.jl")

end  # module
