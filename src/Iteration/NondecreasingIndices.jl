"""
    NondecreasingIndices

Iterator over the vectors of `m` nondecreasing indices from 1 to `n`.

### Fields

- `n` -- size of the index domain
- `m` -- number of indices to choose (resp. length of the vectors)

### Notes

The vectors are modified in-place.

The iterator ranges over ``\\binom{n + m - 1}{m}`` (`n + m - 1` choose `m`)
possible vectors.

This implementation results in a lexicographic order with the last index growing
first.

See also [`StrictlyIncreasingIndices`](@ref) for a strictly increasing iterator.

### Examples

```jldoctest; setup = :(using ReachabilityBase.Iteration)
julia> for v in NondecreasingIndices(4, 2)
           println(v)
       end
[1, 1]
[1, 2]
[1, 3]
[1, 4]
[2, 2]
[2, 3]
[2, 4]
[3, 3]
[3, 4]
[4, 4]
```
"""
struct NondecreasingIndices
    n::Int
    m::Int

    function NondecreasingIndices(n::Int, m::Int)
        @assert n > 0 && m > 0 "require n > 0 and m > 0"
        return new(n, m)
    end
end

Base.eltype(::Type{NondecreasingIndices}) = Vector{Int}

# https://math.stackexchange.com/a/432508
Base.length(ndi::NondecreasingIndices) = binomial(ndi.n + ndi.m - 1, ndi.m)

# initialization
function Base.iterate(ndi::NondecreasingIndices)
    v = ones(Int, ndi.m)
    next = ndi.n == 1 ? nothing : v
    return (v, next)
end

# normal iteration
function Base.iterate(ndi::NondecreasingIndices, state::AbstractVector{Int})
    v = state
    # search to the left for first non-maximal entry
    i = ndi.m
    while v[i] == ndi.n
        i -= 1
    end
    # update vector
    v[i] += 1
    val = v[i]
    for j in (i + 1):(ndi.m)  # update all values to the right
        v[j] = val
    end
    # detect termination: first index has maximum value
    if i == 1 && v[1] == ndi.n
        return (v, nothing)
    end
    return (v, v)
end

# termination
function Base.iterate(::NondecreasingIndices, ::Nothing)
    return nothing
end
