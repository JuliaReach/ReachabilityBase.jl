# iterator with no element
struct EmptyIterator{T}
end

function Base.length(::EmptyIterator)
    return 0
end

function Base.eltype(::Type{EmptyIterator{T}}) where {T}
    return T
end

function Base.iterate(::EmptyIterator, state=nothing)
    return nothing
end
