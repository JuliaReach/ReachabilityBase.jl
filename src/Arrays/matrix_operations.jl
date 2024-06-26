# default tolerance for matrix condition number (see 'isinvertible')
const DEFAULT_COND_TOL = 1e6

# matrix-matrix multiplication
@inline At_mul_B(A, B) = transpose(A) * B

# matrix-matrix division
@inline At_ldiv_B(A, B) = transpose(A) \ B

# rank of sparse submatrix (see #1497)
rank(M::SubArray{N,2,<:SparseMatrixCSC}) where {N} = rank(sparse(M))

"""
    issquare(M::AbstractMatrix)

Check whether a matrix is square.

### Input

- `M` -- matrix

### Output

`true` iff the matrix is square.
"""
function issquare(M::AbstractMatrix)
    m, n = size(M)
    return m == n
end

function issquare(::Diagonal)
    return true
end

"""
    hasfullrowrank(M::AbstractMatrix)

Check whether a matrix has full row rank.

### Input

- `M` -- matrix

### Output

`true` iff the matrix has full row rank.
"""
function hasfullrowrank(M::AbstractMatrix)
    return rank(M) == size(M, 1)
end

"""
    isinvertible(M::Matrix; [cond_tol]::Number=$DEFAULT_COND_TOL)

A sufficient check of a matrix being invertible (or nonsingular).

### Input

- `M`        -- matrix
- `cond_tol` -- (optional, default: `$DEFAULT_COND_TOL`) tolerance of matrix condition

### Output

If the result is `true`, `M` is invertible.
If the result is `false`, the matrix is non-square or not well-conditioned.

### Algorithm

We check whether the matrix is square and well-conditioned (via `iswellconditioned`).
"""
function isinvertible(M::AbstractMatrix; cond_tol::Number=DEFAULT_COND_TOL)
    return issquare(M) && iswellconditioned(M; cond_tol=cond_tol)
end

"""
    iswellconditioned(M::Matrix; [cond_tol]::Number=$DEFAULT_COND_TOL)

A check of a matrix being sufficiently well-conditioned.

### Input

- `M`        -- matrix
- `cond_tol` -- (optional, default: `$DEFAULT_COND_TOL`) tolerance of matrix condition

### Output

`true` iff `M` is well-conditioned subject to the `cond_tol` parameter.

### Algorithm

We check whether the
[matrix condition number](https://en.wikipedia.org/wiki/Condition_number#Matrices) `cond(M)` is
below the prescribed tolerance `cond_tol`.
"""
function iswellconditioned(M::AbstractMatrix; cond_tol::Number=DEFAULT_COND_TOL)
    return cond(M) < cond_tol
end

# cond is not available for sparse matrices; see JuliaLang#6485 and related issues
function iswellconditioned(M::AbstractSparseMatrix; cond_tol::Number=DEFAULT_COND_TOL)
    return iswellconditioned(Matrix(M); cond_tol=cond_tol)
end

function iswellconditioned(M::Diagonal; cond_tol=nothing)
    return !any(iszero, diag(M))
end

"""
    cross_product(M::AbstractMatrix{N}) where {N<:Real}

Compute the high-dimensional cross product of ``n-1`` ``n``-dimensional vectors.

### Input

- `M` -- ``n × n - 1``-dimensional matrix

### Output

A vector.

### Algorithm

The cross product is defined as follows:

```math
\\left[ \\dots, (-1)^{n+1} \\det(M^{[i]}), \\dots \\right]^T
```
where ``M^{[i]}`` is defined as ``M`` with the ``i``-th row removed.
See *Althoff, Stursberg, Buss: Computing Reachable Sets of Hybrid Systems Using
a Combination of Zonotopes and Polytopes. 2009.*
"""
function cross_product(M::AbstractMatrix{N}) where {N<:Real}
    n = size(M, 1)
    @assert 1 < n == size(M, 2) + 1 "the matrix must be n x (n-1) dimensional"

    v = Vector{N}(undef, n)
    minus = false
    for i in 1:n
        Mi = view(M, 1:n .!= i, :)  # remove i-th row
        d = det(Mi)
        if minus
            v[i] = -d
            minus = false
        else
            v[i] = d
            minus = true
        end
    end
    return v
end

# det cannot handle sparse matrices in some cases
cross_product(M::AbstractSparseMatrix) = cross_product(Matrix(M))
cross_product(M::SubArray{N,2,<:AbstractSparseMatrix}) where {N} = cross_product(Matrix(M))

"""
    nonzero_columns(A::AbstractMatrix; [comparison]=isapproxzero)

Return all columns that have at least one non-zero entry.

### Input

- `A`          -- matrix
- `comparison` -- (optional; default: `isapproxzero`) function to check for
                  equality with zero

### Output

A vector of indices.
"""
function nonzero_columns(A::AbstractMatrix; comparison=isapproxzero)
    n = size(A, 2)
    nzcol = Vector{Int}()
    sizehint!(nzcol, n)
    for j in 1:n
        if !all(comparison, view(A, :, j))
            push!(nzcol, j)
        end
    end
    return nzcol
end

function nonzero_columns(A::SparseMatrixCSC)
    dropzeros!(A)
    return collect(j for j in 1:(A.n) if A.colptr[j] < A.colptr[j + 1])
end

"""
    extend(M::AbstractMatrix; check_rank=true)

Return an invertible extension of `M` whose first `n` columns span the column
space of `M`, assuming that `size(M) = (m, n)`, `m > n` and the rank of `M` is `n`.

### Input

- `M`          -- rectangular `m × n` matrix with `m > n` and full rank (i.e. its
                  rank is `n`)
- `check_rank` -- (optional, default: `true`) if `true`, check the rank assumption,
                  otherwise do not perform this check

### Output

The tuple `(Mext, inv_Mext)`, where `Mext` is a square `m × m` invertible matrix
that extends `M`, i.e. in the sense that `Mext = [M | Q2]`, and the rank of `Mext`
is `m`. Here, `inv_Mext` is the inverse of `Mext`.

### Algorithm

First we compute the QR decomposition of `M` to extract a suitable subspace of
column vectors (`Q2`) that are orthogonal to the column span of `M`. Then we observe
that the inverse of the extended matrix `Mext = [M | Q2]` is `[R⁻¹Qᵀ; Q2ᵀ]`.
"""
function extend(M::AbstractMatrix; check_rank=true)
    m, n = size(M)

    m <= n && throw(ArgumentError("this function requires that the number " *
                                  "of rows is greater than the number of columns, but they are of size $m and " *
                                  "$n respectively"))

    if check_rank
        r = rank(M)
        r != n && throw(ArgumentError("the rank of the given matrix is " *
                                      "$r, but this function assumes that it is $n"))
    end

    # compute QR decomposition of M
    Q, R = qr(M)

    # Q2 spans the null space of M
    Q2 = Q[:, (n + 1):end]

    # extend M by appending the columns orthogonal to the column span of M
    Mext = hcat(M, Q2)

    # since the inverse is easy to compute, return it
    inv_Mext = vcat(inv(R) * Q', Q2')

    return Mext, inv_Mext
end

"""
    projection_matrix(block::AbstractVector{Int}, n::Int, [N]::Type{<:Number}=Float64)

Return the projection matrix associated to the given block of variables.

### Input

- `block` -- integer vector with the variables of interest
- `n`     -- integer representing the ambient dimension
- `N`     -- (optional, default: `Float64`) number type

### Output


A sparse matrix that corresponds to the projection onto the variables in `block`.

### Examples

```jldoctest; setup = :(using ReachabilityBase.Arrays)
julia> proj = projection_matrix([1, 3], 4)
2×4 SparseArrays.SparseMatrixCSC{Float64, Int64} with 2 stored entries:
 1.0   ⋅    ⋅    ⋅
  ⋅    ⋅   1.0   ⋅

julia> Matrix(proj)
2×4 Matrix{Float64}:
 1.0  0.0  0.0  0.0
 0.0  0.0  1.0  0.0
```
"""
function projection_matrix(block::AbstractVector{Int}, n::Int, N::Type{<:Number}=Float64)
    m = length(block)
    return sparse(1:m, block, ones(N, m), m, n)
end

# fallback: represent the projection matrix as a sparse array
function projection_matrix(block::AbstractVector{Int}, n::Int,
                           ::Type{<:AbstractVector{N}}) where {N}
    return projection_matrix(block, n, N)
end

function load_projection_matrix_static()
    return quote
        # represent the projection matrix with a static array
        function projection_matrix(block::AbstractVector{Int}, n::Int,
                                   VN::Type{<:SVector{L,N}}) where {L,N}
            mat = projection_matrix(block, n, N)
            m = size(mat, 1)
            return SMatrix{m,n}(mat)
        end
    end # quote
end # end load_projection_matrix_static

"""
    remove_zero_columns(A::AbstractMatrix)

Return a matrix with all columns containing only zero entries removed.

### Input

- `A` -- matrix

### Output

The original matrix `A` if it contains no zero columns or otherwise a new matrix
where those columns have been removed.
"""
function remove_zero_columns(A::AbstractMatrix)
    nzcol = nonzero_columns(A)
    if length(nzcol) == size(A, 2)
        return A
    else
        return A[:, nzcol]
    end
end
