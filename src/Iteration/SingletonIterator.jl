# iterator over a single element
struct SingletonIterator{T}
    element::T
end

function Base.length(::SingletonIterator)
    return 1
end

function Base.eltype(::Type{SingletonIterator{T}}) where {T}
    return T
end

function Base.iterate(it::SingletonIterator, state=0)
    if state == 0
        element = it.element
        state = nothing
        return (element, state)
    end
    return nothing
end
