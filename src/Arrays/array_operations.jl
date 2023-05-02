"""
    same_sign(A::AbstractArray{N}; [optimistic]::Bool=false) where {N}

Check whether all elements of the given array have the same sign.

### Input

- `A`          -- array
- `optimistic` -- (optional; default: `false`) flag for expressing that the
                  expected result is `true`

### Output

`true` if and only if all elements in `M` have the same sign.

### Algorithm

If `optimistic` is `false`, we check the sign of the first element and compare
to the sign of all elements.

If `optimistic` is `true`, we compare the absolute element sum with the sum of
the absolute of the elements; this is faster if the result is `true` because
there is no branching.

```math
    |\\sum_i A_i| = \\sum_i |A_i|
```
"""
function same_sign(A::AbstractArray{N}; optimistic::Bool=false) where {N}
    if optimistic
        return sum(abs, A) == abs(sum(A))
    else
        if isempty(A)
            return true
        end
        @inbounds if first(A) >= zero(N)
            return all(e -> e >= zero(N), A)
        else
            return all(e -> e <= zero(N), A)
        end
    end
end

"""
    rationalize(::Type{T}, x::AbstractArray{N}, tol::Real) where {T<:Integer, N<:AbstractFloat}

Approximate an array of floating point numbers as a rational vector with entries
of the given integer type.

### Input

- `T`   -- (optional, default: `Int`) integer type to represent the rationals
- `x`   -- vector of floating point numbers
- `tol` -- (optional, default: `eps(N)`) tolerance the result at entry `i`
           will differ from `x[i]` by no more than `tol`

### Output

An array of type `Rational{T}` where the `i`-th entry is the rationalization
of the `i`-th component of `x`.

### Notes

See also `Base.rationalize`.
"""
function rationalize(::Type{T}, x::AbstractArray{N}, tol::Real) where {T<:Integer,N<:AbstractFloat}
    return rationalize.(Ref(T), x, Ref(tol))
end

# method extensions
function rationalize(::Type{T}, x::AbstractArray{N};
                     tol::Real=eps(N)) where {T<:Integer,N<:AbstractFloat}
    return rationalize(T, x, tol)
end
function rationalize(x::AbstractArray{N}; kwargs...) where {N<:AbstractFloat}
    return rationalize(Int, x; kwargs...)
end

# nested vectors
function rationalize(::Type{T}, x::AbstractArray{<:AbstractArray{N}},
                     tol::Real) where {T<:Integer,N<:AbstractFloat}
    return rationalize.(Ref(T), x, Ref(tol))
end

"""
    rectify(x::AbstractArray{N}) where {N<:Real}

Rectify an array, i.e., take the element-wise maximum with zero.

### Input

- `x` -- array

### Output

A copy of the array where each negative entry is replaced by zero.
"""
function rectify(x::AbstractArray{N}) where {N<:Real}
    return map(xi -> max(xi, zero(N)), x)
end

"""
    argmaxabs(x::AbstractArray)

Return the index with the absolute-wise maximum entry.

### Input

- `x` -- array

### Output

The index `i` such that `|x[i]| >= |x[j]|` for all `j`.
"""
function argmaxabs(x::AbstractArray)
    @assert length(x) > 0 "cannot find the absolute argmax in an empty array"
    res = zero(eltype(x))
    idx = 1
    @inbounds for i in eachindex(x)
        v = abs(x[i])
        if v > res
            res = v
            idx = i
        end
    end
    return idx
end
