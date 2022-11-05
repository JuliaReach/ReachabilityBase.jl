# iterator over the columns of a matrix
struct ColumnIterator{T<:AbstractMatrix}
    matrix::T
end

function Base.length(it::ColumnIterator)
    return size(it.matrix, 2)
end

function Base.eltype(::Type{<:ColumnIterator{<:AbstractMatrix{N}}}) where {N}
    return AbstractVector{N}
end

function Base.eltype(::Type{<:ColumnIterator{<:Matrix{N}}}) where {N}
    return Vector{N}
end

function Base.eltype(::Type{<:ColumnIterator{<:SparseMatrixCSC{N}}}) where {N}
    return SparseVector{N}
end

function Base.iterate(it::ColumnIterator, state=0)
    if state == length(it)
        return nothing
    end
    state += 1
    column = it.matrix[:, state]
    return (column, state)
end
