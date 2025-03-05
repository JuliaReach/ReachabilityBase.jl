"""
    SingleEntryVector{N} <: AbstractVector{N}

A sparse unit vector with arbitrary one-element.

### Fields

- `i` -- index of non-zero entry
- `n` -- vector length
- `v` -- non-zero entry
"""
struct SingleEntryVector{N} <: AbstractVector{N}
    i::Int
    n::Int
    v::N
end

# convenience constructor with one-element of corresponding type
SingleEntryVector{N}(i::Int, n::Int) where {N} = SingleEntryVector{N}(i, n, one(N))

function Base.getindex(e::SingleEntryVector{N}, i::Int) where {N}
    @boundscheck 1 <= i <= e.n || throw(BoundsError(e, i))
    return i == e.i ? e.v : zero(N)
end

Base.size(e::SingleEntryVector) = (e.n,)

# define matrix-vector multiplication with SingleEntryVector
# due to type piracy in other packages, we need to enumerate the matrix types
# explicitly here
for MT in [Matrix, AbstractSparseMatrix]
    function Base.:(*)(A::MT, e::SingleEntryVector)
        return A[:, e.i] * e.v
    end
end

# multiplication with diagonal matrix
function Base.:(*)(D::Diagonal{N,V},
                   e::SingleEntryVector{N}) where {N,V<:AbstractVector{N}}
    return SingleEntryVector(e.i, e.n, D.diag[e.i] * e.v)
end

# negation
function Base.:(-)(e::SingleEntryVector{N}) where {N}
    return SingleEntryVector(e.i, e.n, -e.v)
end

# arithmetic
for (opS, opF) in ((:(+), +), (:(-), -))
    @eval begin
        function Base.$opS(e1::SingleEntryVector{N}, e2::SingleEntryVector{N}) where {N}
            if e1.n != e2.n
                throw(DimensionMismatch("dimensions must match, but they are $(length(e1)) and $(length(e2)) respectively"))
            end

            if e1.i == e2.i
                return SingleEntryVector(e1.i, e1.n, $opF(e1.v, e2.v))
            else
                res = spzeros(N, e1.n)
                @inbounds begin
                    res[e1.i] = e1.v
                    res[e2.i] = $opF(e2.v)
                end
                return res
            end
        end
    end
end

function inner(e1::SingleEntryVector{N}, A::AbstractMatrix{N},
               e2::SingleEntryVector{N}) where {N}
    return A[e1.i, e2.i] * e1.v * e2.v
end

# norm
function LinearAlgebra.norm(e::SingleEntryVector, ::Real=Inf)
    return abs(e.v)
end

function append_zeros(e::SingleEntryVector, n::Int)
    return SingleEntryVector(e.i, e.n + n, e.v)
end

function prepend_zeros(e::SingleEntryVector, n::Int)
    return SingleEntryVector(e.i + n, e.n + n, e.v)
end

# distance = norm of the difference ||x - y||_p
function distance(e1::SingleEntryVector{N}, e2::SingleEntryVector{N}; p::Real=N(2)) where {N}
    if e1.n != e2.n
        throw(DimensionMismatch("dimensions must match, but they are " *
                                "$(length(e1)) and $(length(e2)) respectively"))
    end

    if e1.i == e2.i
        return abs(e1.v - e2.v)
    else
        a = abs(e1.v)
        b = abs(e2.v)
        if isinf(p)
            return max(a, b)
        else
            s = a^p + b^p
            return s^(1 / p)
        end
    end
end
