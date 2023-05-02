"""
    reseed(rng::AbstractRNG, seed::Union{Int, Nothing})

Reset the RNG seed if the seed argument is a number.

### Input

- `rng`  -- random number generator
- `seed` -- seed for reseeding

### Output

The input RNG if the seed is `nothing`, and a reseeded RNG otherwise.
"""
function reseed(rng::AbstractRNG, seed::Union{Int,Nothing})
    if seed != nothing
        return seed!(rng, seed)
    end
    return rng
end
