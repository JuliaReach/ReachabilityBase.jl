"""
    isapproxzero(x::N; ztol::Real=_ztol(N)) where {N<:Real}

Determine if `x` is approximately zero.

### Input

- `x`    -- number
- `ztol` -- (optional, default: `_ztol(N)`) tolerance against zero

### Output

A boolean that is `true` iff `x ≈ 0`.

### Algorithm

It is considered that `x ≈ 0` whenever `x` (in absolute value) is smaller than
the tolerance for zero, `ztol`.
"""
function isapproxzero(x::N; ztol::Real=_ztol(N)) where {N<:Real}
    return abs(x) <= ztol
end
