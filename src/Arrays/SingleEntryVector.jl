"""
    SingleEntryVector{N} <: AbstractVector{N}

A sparse unit vector with arbitrary one-element.

### Fields

- `i` -- index of non-zero entry
- `n` -- vector length
- `v` -- (potentially) non-zero value (defaults to `one(N)` if not passed)
"""
struct SingleEntryVector{N} <: AbstractVector{N}
    i::Int
    n::Int
    v::N

    function SingleEntryVector{N}(i::Int, n::Int, v::N=one(N)) where {N}
        @assert 1 <= i <= n || throw(ArgumentError("invalid index $i for vector of length $n"))

        return new{N}(i, n, v)
    end
end

# constructor without type parameter
function SingleEntryVector(i::Int, n::Int, v::N) where {N}
    return SingleEntryVector{N}(i, n, v)
end

function getindex(x::SingleEntryVector{N}, i::Int) where {N}
    @boundscheck 1 <= i <= x.n || throw(BoundsError(x, i))
    return i == x.i ? x.v : zero(N)
end

function size(x::SingleEntryVector)
    return (x.n,)
end

# negation
function -(x::SingleEntryVector)
    return SingleEntryVector(x.i, x.n, -x.v)
end

# arithmetic
for (opS, opF) in ((:(+), +), (:(-), -))
    @eval begin
        function $opS(x1::SingleEntryVector, x2::SingleEntryVector)
            @assert x1.n == x2.n ||
                    throw(DimensionMismatch("dimensions must match, but they are " *
                                            "$(length(x1)) and $(length(x2)) respectively"))

            if x1.i == x2.i
                return SingleEntryVector(x1.i, x1.n, $opF(x1.v, x2.v))
            end

            N = promote_type(eltype(x1), eltype(x2))
            y = spzeros(N, x1.n)
            @inbounds begin
                y[x1.i] = x1.v
                y[x2.i] = $opF(x2.v)
            end
            return y
        end
    end
end

# matrix-vector multiplication
for MT in (Matrix, AbstractSparseMatrix)
    # `Base.:(*)` needed to avoid error
    function Base.:(*)(M::MT, x::SingleEntryVector)
        @assert size(M, 2) == length(x) ||
                throw(DimensionMismatch("dimensions must match, but they are " *
                                        "$(size(M)) and $(length(x)) respectively"))

        return @view(M[:, x.i]) * x.v
    end
end

# multiplication with Diagonal
function *(D::Diagonal, x::SingleEntryVector)
    @assert size(D, 2) == length(x) ||
            throw(DimensionMismatch("dimensions must match, but they are " *
                                    "$(size(D)) and $(length(x)) respectively"))

    return SingleEntryVector(x.i, x.n, D.diag[x.i] * x.v)
end

# transposed matrix-vector multiplication
function At_mul_B(A, b::SingleEntryVector)
    @assert size(A, 1) == length(b) ||
            throw(DimensionMismatch("dimensions must match, but they are " *
                                    "$(size(A)) and $(length(b)) respectively"))

    return @view(A[b.i, :]) * b.v
end

# transposed vector-matrix multiplication
function At_mul_B(a::SingleEntryVector, B)
    return At_mul_B(B, a)
end

# transposed vector-vector multiplication
function At_mul_B(a::SingleEntryVector, b::SingleEntryVector)
    @assert length(a) == length(b) ||
            throw(DimensionMismatch("dimensions must match, but they are " *
                                    "$(length(a)) and $(length(b)) respectively"))

    if a.i == b.i
        return [a.v * b.v]
    else
        N = promote_type(eltype(a), eltype(b))
        return [zero(N)]
    end
end

# x1 * M * x2
function inner(x1::SingleEntryVector, M::AbstractMatrix, x2::SingleEntryVector)
    @assert size(M) == (length(x1), length(x2)) ||
            throw(DimensionMismatch("dimensions must match, but they are " *
                                    "$(length(x1)), $(size(M)), and $(length(x2)) respectively"))

    return x1.v * M[x1.i, x2.i] * x2.v
end

function append_zeros(x::SingleEntryVector, n::Int)
    return SingleEntryVector(x.i, x.n + n, x.v)
end

function prepend_zeros(x::SingleEntryVector, n::Int)
    return SingleEntryVector(x.i + n, x.n + n, x.v)
end

function norm(x::SingleEntryVector, p::Real=2)
    @assert p >= one(p) || throw(ArgumentError("invalid p-norm p=$p"))

    return abs(x.v)
end

# distance = norm of the difference ‖x - y‖_p
function distance(x1::SingleEntryVector, x2::SingleEntryVector; p::Real=2)
    @assert x1.n == x2.n || throw(DimensionMismatch("dimensions must match, but they are " *
                                                    "$(length(x1)) and $(length(x2)) respectively"))
    @assert p >= one(p) || throw(ArgumentError("invalid p-norm p=$p"))

    if x1.i == x2.i
        # simple case for vector with only one entry
        return abs(x1.v - x2.v)
    else
        # vector has only two entries; use LinearAlgebra's implementation
        return norm((x1.v, x2.v), p)
    end
end

# ‖xᵀ M‖₁
function abs_sum(x::SingleEntryVector, M::AbstractMatrix)
    @assert length(x) == size(M, 1) ||
            throw(DimensionMismatch("dimensions must match, but they are " *
                                    "$(length(x)) and $(size(M)) respectively"))

    return sum(abs, @view(M[x.i, :])) * abs(x.v)
end
