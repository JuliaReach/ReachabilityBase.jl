"""
    _leq(x::Real, y::Real; [kwargs...])

Determine if `x` is smaller than or equal to `y`.

### Input

- `x`    -- number
- `y`    -- number
- `rtol` -- (optional; default: `_rtol(N)`) relative tolerance
- `ztol` -- (optional; default: `_ztol(N)`) absolute tolerance for comparison
            against zero
- `atol` -- (optional; default: `_atol(N)`) absolute tolerance

### Output

A boolean that is `true` iff `x <= y`.

### Algorithm

The `x <= y` comparison is split into `x < y` or `x ≈ y`; the latter is
implemented by extending Juila's built-in `isapprox(x, y)` with an absolute
tolerance that is used to compare against zero.
"""
function _leq end

# fallback implementation: exact comparison
function _leq(x::N, y::N; kwargs...) where {N<:Real}
    return x <= y
end

# promotion implementation
function _leq(x::N, y::M; kwargs...) where {N<:Real,M<:Real}
    return _leq(promote(x, y)...; kwargs...)
end

# float implementation: consider tolerance
function _leq(x::N, y::N;
              rtol::Real=_rtol(N),
              ztol::Real=_ztol(N),
              atol::Real=_atol(N)) where {N<:AbstractFloat}
    return x <= y || _isapprox(x, y; rtol=rtol, ztol=ztol, atol=atol)
end

"""
    _geq(x::Real, y::Real; [kwargs...])

Determine if `x` is greater than or equal to `y`.

### Input

- `x`    -- number
- `y`    -- number
- `rtol` -- (optional; default: `_rtol(N)`) relative tolerance
- `ztol` -- (optional; default: `_ztol(N)`) absolute tolerance for comparison
            against zero
- `atol` -- (optional; default: `_atol(N)`) absolute tolerance

### Output

A boolean that is `true` iff `x >= y`.

### Algorithm

This function falls back to `_leq(y, x)`, with type promotion if needed. See the
documentation of [`_leq`](@ref) for further details.
"""
_geq(x::Real, y::Real; kwargs...) = _leq(y, x; kwargs...)
