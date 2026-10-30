# computes ‖a^T G‖₁
@inline function abs_sum(a::AbstractVector, G::AbstractMatrix)
    @assert length(a) == size(G, 1) "invalid dimensions $(length(a)) and $(size(G))"

    n, p = size(G)
    N = promote_type(eltype(a), eltype(G))
    res = zero(N)
    @inbounds for j in 1:p
        aux = zero(N)
        @simd for i in 1:n
            aux += a[i] * G[i, j]
        end
        res += abs(aux)
    end
    return res
end

# computes ‖a^T G‖₁ for `a` being a sparse vector
@inline function abs_sum(a::AbstractSparseVector, G::AbstractMatrix)
    return sum(abs, transpose(a) * G)
end

# computes ‖a^T G‖₁ for `a` having only one nonzero element
@inline function abs_sum(a::SingleEntryVector, G::AbstractMatrix)
    @assert length(a) == size(G, 1) "invalid dimensions $(length(a)) and $(size(G))"

    p = size(G, 2)
    i = a.i
    N = promote_type(eltype(a), eltype(G))
    res = zero(N)
    @inbounds for j in 1:p
        res += abs(G[i, j])
    end
    res *= abs(a.v)
    return res
end

"""
    inner(x::AbstractVector{N}, A::AbstractMatrix{N}, y::AbstractVector{N}
         ) where {N}

Compute the inner product ``xᵀ A y``.

### Input

- `x` -- vector on the left
- `A` -- matrix
- `y` -- vector on the right

### Output

The (scalar) result of the multiplication.
"""
function inner(x::AbstractVector{N}, A::AbstractMatrix{N}, y::AbstractVector{N}) where {N}
    return dot(x, A * y)
end

"""
    vector_type(T)

Return a corresponding vector type with respect to type `T`.

### Input

- `T` -- vector or matrix type

### Output

A vector type that corresponds in some sense (see Notes below) to `T`.

### Notes

- If `T` is a sparse vector or a sparse matrix, the corresponding type is also
  a sparse vector.
- If `T` is a regular vector (i.e. `Vector`) or a regular matrix (i.e. `Matrix`),
  the corresponding type is also a regular vector.
- Otherwise, the corresponding type is a regular vector.
"""
function vector_type end

"""
    matrix_type(T)

Return a corresponding matrix type with respect to type `T`.

### Input

- `T` -- vector or matrix type

### Output

A matrix type that corresponds in some sense (see Notes below) to `T`.

### Notes

- If `T` is a sparse vector or a sparse matrix, the corresponding type is also
  a sparse matrix.
- If `T` is a regular vector (i.e. `Vector`) or a regular matrix (i.e. `Matrix`),
  the corresponding type is also a regular matrix.
- Otherwise, the corresponding type is a regular matrix.
"""
function matrix_type end

vector_type(::Type{<:AbstractSparseArray{T}}) where {T} = SparseVector{T,Int}
vector_type(VT::Type{<:AbstractVector{T}}) where {T} = VT
vector_type(::Type{<:AbstractMatrix{T}}) where {T} = Vector{T}

matrix_type(::Type{<:AbstractVector{T}}) where {T} = Matrix{T}
matrix_type(MT::Type{<:AbstractMatrix{T}}) where {T} = MT
matrix_type(::Type{<:AbstractSparseVector{T}}) where {T} = SparseMatrixCSC{T,Int}

# matrix constructors
_matrix(m, n, ::Type{<:AbstractMatrix{T}}) where {T} = Matrix{T}(undef, m, n)
_matrix(m, n, ::Type{<:SparseMatrixCSC{T}}) where {T} = spzeros(T, m, n)

"""
    to_matrix(vectors::AbstractVector{VN},
              [m]=length(vectors[1]),
              [MT]=matrix_type(VN)) where {VN}

### Input

- `vectors` -- list of vectors
- `m`       -- (optional; default: `length(vectors[1])`) number of rows
- `MT`      -- (optional; default: `matrix_type(VN)`) type of target matrix

### Output

A matrix with the column vectors from `vectors` in the same order.
"""
function to_matrix(vectors::AbstractVector{VN},
                   m=length(vectors[1]),
                   mat_type=matrix_type(VN)) where {VN}
    n = length(vectors)
    M = _matrix(m, n, mat_type)
    @inbounds for (j, vj) in enumerate(vectors)
        M[:, j] = vj
    end
    return M
end

# no-op
similar_type(x::AbstractVector) = typeof(x)
