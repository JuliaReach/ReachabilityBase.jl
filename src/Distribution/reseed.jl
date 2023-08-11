"""
    reseed!(rng::AbstractRNG, seed::Union{Int, Nothing})

Reset the RNG seed if the seed argument is a number.

### Input

- `rng`  -- random number generator
- `seed` -- seed for reseeding, or `nothing`

### Output

The input RNG if the seed is `nothing`, and a reseeded RNG otherwise.

### Notes

This is a convenience function to be called unconditionally. The motivation is
to simplify library code, with `seed` as user input.
"""
function reseed! end

function reseed!(rng::AbstractRNG, seed::Int)
    return seed!(rng, seed)
end

function reseed!(rng::AbstractRNG, seed::Nothing)
    return rng
end
