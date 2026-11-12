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

"""
    nonzero_indices(A::AbstractArray)

Return the indices in which an array is non-zero.

### Input

- `A` -- array

### Output

The vector of indices `i` such that `A[i] ≠ 0`. The order of the indices follows `eachindex`, i.e.,
typically in ascending order.

For a `SparseVector` input, mutating the result will mutate `A`.
"""
function nonzero_indices(A::AbstractArray)
    res = Vector{Int}()
    @inbounds for i in eachindex(A)
        if !iszero(A[i])
            push!(res, i)
        end
    end
    return res
end

# sparse vector
function nonzero_indices(v::SparseVector)
    return v.nzind
end

# if `A` has exactly one non-zero entry, return its index
# otherwise, return 0
function find_unique_nonzero_entry(A::AbstractArray)
    res = 0
    @inbounds for i in eachindex(A)
        if !iszero(A[i])
            if res != 0
                # at least two non-zero entries
                return 0
            else
                # first non-zero entry so far
                res = i
            end
        end
    end
    return res
end

"""
    substitute(substitution::Dict{Int,T}, A::AbstractArray{T}) where {T}

Apply a substitution to a given mutable array.

### Input

- `substitution` -- mapping from an index to a new value
- `A`            -- mutable array

### Output

A fresh array corresponding to `A` after `substitution` was applied.

The same (but see the Notes below) array `A` but after `substitution` was
applied.
"""
function substitute(substitution::Dict{Int,T}, A::AbstractArray{T}) where {T}
    return substitute!(substitution, copy(A))
end

"""
    substitute!(substitution::Dict{Int,T}, A::AbstractArray{T}) where {T}

Apply a substitution to a given mutable array, in-place.

### Input

- `substitution` -- mapping from an index to a new value
- `A`            -- mutable array (modified in this function)

### Output

The same array `A` but after `substitution` was applied.
"""
function substitute!(substitution::Dict{Int,T}, A::AbstractArray{T}) where {T}
    for (idx, v) in substitution
        A[idx] = v
    end
    return A
end

@static if VERSION < v"1.8"
    """
        allequal(itr)

    Check whether all elements in an iterator are equal (wrt. `isequal`).

    ### Input

    - `itr` -- iterator

    ### Output

    `true` iff all elements in `itr` are equal.

    ### Notes

    The code is taken from [here](https://stackoverflow.com/a/47578613).

    This function is available in Julia `Base` since v1.8. Accordingly, it is
    only defined here if a Julia version below v1.8 is used.
    """
    # COV_EXCL_START
    function allequal(itr)
        length(itr) < 2 && return true
        x1 = @inbounds itr[1]
        @inbounds for xi in itr
            isequal(xi, x1) || return false
        end
        return true
    end
    # COV_EXCL_STOP
end
