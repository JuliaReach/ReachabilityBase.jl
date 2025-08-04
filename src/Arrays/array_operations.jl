"""
    same_sign(A::AbstractArray)

Check whether all elements of the given array have the same sign.

### Input

- `A` -- array

### Output

`true` iff all elements in `A` have the same sign.

### Notes

The result is `false` if and only if the array contains two elements ``e₁ > 0``
and ``e₂ < 0``. Zero elements (0) do not influence the result.
"""
function same_sign(A::AbstractArray)
    if isempty(A)
        return true
    end
    N = eltype(A)
    for (i, Ai) in enumerate(A)
        if Ai > zero(N)
            @inbounds for j in (i + 1):length(A)
                if A[j] < zero(N)
                    return false
                end
            end
            return true
        elseif Ai < zero(N)
            @inbounds for j in (i + 1):length(A)
                if A[j] > zero(N)
                    return false
                end
            end
            return true
        end
    end
    return true
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
    @inbounds for (i, Ai) in enumerate(A)
        B[i] = rationalize(T, Ai, tol)
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

# nested vectors
function rationalize(::Type{T}, As::AbstractVector{<:AbstractVector{N}},
                     tol::Real) where {T<:Integer,N<:AbstractFloat}
    Bs = similar(As, Rational{T})
    @inbounds for (i, Ai) in enumerate(As)
        Bs[i] = rationalize(T, Ai, tol)
    end
    return Bs
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
