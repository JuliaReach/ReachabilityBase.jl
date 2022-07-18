"""
    _in(x, itr)

Approximate containment check.

### Input

- `x`   -- element
- `itr` -- iterable

### Output

A boolean that is `true` iff `y ∈ itr` for some `y ≈ x`.
"""
function _in(x, itr)
    return x ∈ itr
end

# number
function _in(x::T, itr) where {T<:AbstractFloat}
    return any(y -> _isapprox(x, y), itr)
end

# vector
function _in(x::AbstractVector{T}, itr) where {T<:AbstractFloat}
    return any(y -> _isapprox(x, y), itr)
end
