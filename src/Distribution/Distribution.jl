"""
    Distribution

This module provides some light-weight random number functionality.
"""
module Distribution

import Base: rand
using Random: AbstractRNG, seed!

export reseed!, DefaultUniform, rand, rand!

include("reseed.jl")
include("DefaultUniform.jl")

end  # module
