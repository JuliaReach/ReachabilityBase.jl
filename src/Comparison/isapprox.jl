"""
    _isapprox(x::N, y::N;
              rtol::Real=_rtol(N),
              ztol::Real=_ztol(N),
              atol::Real=_atol(N)) where {N<:Real}

Determine if `x` is approximately equal to `y`.

### Input

- `x`    -- number
- `y`    -- another number (of the same numeric type as `x`)
- `rtol` -- (optional, default: `_rtol(N)`) relative tolerance
- `ztol` -- (optional, default: `_ztol(N)`) absolute tolerance for comparison
            against zero
- `atol` -- (optional, default: `_atol(N)`) absolute tolerance

### Output

A boolean that is `true` iff `x ≈ y`.

### Algorithm

We first check if `x` and `y` are both approximately zero, using
`isapproxzero(x, y)`.
If that fails, we check if `x ≈ y`, using Julia's `isapprox(x, y)`.
In the latter check we use `atol` absolute tolerance and `rtol` relative
tolerance.

Comparing to zero with default tolerances is a special case in Julia's
`isapprox`, see the last paragraph in `?isapprox`. This function tries to
combine `isapprox` with its default values and a branch for `x ≈ y ≈ 0` which
includes `x == y == 0` but also admits a tolerance `ztol`.

Note that if `x = ztol` and `y = -ztol`, then `|x-y| = 2*ztol` and still
`_isapprox` returns `true`.
"""
function _isapprox(x::N, y::N;
                   rtol::Real=_rtol(N),
                   ztol::Real=_ztol(N),
                   atol::Real=_atol(N)) where {N<:Real}
    if isapproxzero(x; ztol=ztol) && isapproxzero(y; ztol=ztol)
        return true
    else
        return isapprox(x, y; rtol=rtol, atol=atol)
    end
end

# different numeric types with promotion
function _isapprox(x::N, y::M; kwargs...) where {N<:Real,M<:Real}
    return _isapprox(promote(x, y)...; kwargs...)
end

# numeric arrays
function _isapprox(A::AbstractArray{N}, B::AbstractArray{N};
                   rtol::Real=_rtol(N),
                   ztol::Real=_ztol(N),
                   atol::Real=_atol(N)) where {N<:Real}
    if size(A) != size(B)
        return false
    end
    @inbounds for i in eachindex(A)
        if !_isapprox(A[i], B[i]; rtol=rtol, ztol=ztol, atol=atol)
            return false
        end
    end
    return true
end

# sparse numeric vectors
function _isapprox(x::SparseVector{N}, y::SparseVector{N};
                   rtol::Real=_rtol(N),
                   ztol::Real=_ztol(N),
                   atol::Real=_atol(N)) where {N<:Real}
    if length(x) != length(y)
        return false
    elseif x.nzind != y.nzind
        return false
    end
    return _isapprox(x.nzval, y.nzval; rtol=rtol, ztol=ztol, atol=atol)
end

# numeric arrays with different numeric types with promotion
function _isapprox(A::AbstractArray{N}, B::AbstractArray{M};
                   kwargs...) where {N<:Real,M<:Real}
    return _isapprox(promote(A, B)...; kwargs...)
end

# fallback definition
function _isapprox(x, y; kwargs...)
    return x ≈ y
end
