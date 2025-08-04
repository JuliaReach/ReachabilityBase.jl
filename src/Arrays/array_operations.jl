"""
    same_sign(A::AbstractArray)

Check whether all elements of the given array have the same sign.

### Input

- `A` -- array

### Output

`true` iff all elements in `A` have the same sign.

### Algorithm

We check the sign of the first element and compare to the sign of all elements.
"""
function same_sign(A::AbstractArray)
    if isempty(A)
        return true
    end
    N = eltype(A)
    @inbounds if first(A) >= zero(N)
        return all(e -> e >= zero(N), A)
    else
        return all(e -> e <= zero(N), A)
    end
end

"""
    rationalize(::Type{T}, A::AbstractArray{N}, tol::Real) where {T<:Integer, N<:AbstractFloat}

Approximate an array of floating-point numbers as an array with rational entries
of the given integer type.

### Input

- `T`   -- (optional, default: `Int`) integer type to represent the rationals
- `A`   -- array of floating-point numbers
- `tol` -- (optional, default: `eps(N)`) tolerance; the result at entry `i`
           will differ from `A[i]` by no more than `tol`

### Output

An array of type `Rational{T}` where the `i`-th entry is the rationalization
of the `i`-th component of `A`.

### Notes

See also `Base.rationalize`.
"""
function rationalize(::Type{T}, A::AbstractArray{N}, tol::Real) where {T<:Integer,N<:AbstractFloat}
    B = similar(A, Rational{T})
    @inbounds for i in eachindex(A)
        B[i] = rationalize(T, A[i], tol)
    end
    return B
end

# `tol` as kwarg with default value
function rationalize(::Type{T}, A::AbstractArray{N};
                     tol::Real=eps(N)) where {T<:Integer,N<:AbstractFloat}
    return rationalize(T, A, tol)
end

# no `T` with default value
function rationalize(A::AbstractArray{N}; kwargs...) where {N<:AbstractFloat}
    return rationalize(Int, A; kwargs...)
end

# nested arrays
function rationalize(::Type{T}, A::AbstractArray{<:AbstractArray{N}},
                     tol::Real) where {T<:Integer,N<:AbstractFloat}
    return rationalize.(Ref(T), A, Ref(tol))
end

"""
    rectify(A::AbstractArray)

Rectify an array, i.e., take the element-wise maximum with zero.

### Input

- `A` -- array

### Output

A copy of the array where each negative entry is replaced by zero.
"""
function rectify(A::AbstractArray)
    B = similar(A)
    z = zero(eltype(A))
    @inbounds for i in eachindex(A)
        B[i] = max(A[i], z)
    end
    return B
end

"""
    argmaxabs(A::AbstractArray)

Return the first index with the absolute-wise maximum entry.

### Input

- `A` -- array

### Output

The first (wrt. `eachindex`) index `i` such that `|A[i]| >= |A[j]|` for all `j`.
"""
function argmaxabs(A::AbstractArray)
    @assert !isempty(A) || throw(ArgumentError("cannot find the absolute argmax in an empty array"))

    res = zero(eltype(A))
    idx = 1
    @inbounds for i in eachindex(A)
        v = abs(A[i])
        if v > res
            res = v
            idx = i
        end
    end
    return idx
end
