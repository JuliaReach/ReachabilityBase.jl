# computes ‖xᵀ M‖₁
@inline function abs_sum(x::AbstractVector, M::AbstractMatrix)
    @assert length(x) == size(M, 1) "invalid dimensions $(length(x)) and $(size(M))"

    n, p = size(M)
    N = promote_type(eltype(x), eltype(M))
    res = zero(N)
    @inbounds for j in 1:p
        aux = zero(N)
        @simd for i in 1:n
            aux += x[i] * M[i, j]
        end
        res += abs(aux)
    end
    return res
end

@inline function abs_sum(x::AbstractSparseVector, M::AbstractMatrix)
    return sum(abs, transpose(x) * M)
end

"""
    inner(x::AbstractVector{N}, A::AbstractMatrix{N}, y::AbstractVector{N}) where {N}

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

function load_copy_finalize_static()
    return quote
        similar_type(x::StaticArrays.StaticArray) = StaticArrays.similar_type(x)
    end # quote
end # end load_copy_finalize_static
