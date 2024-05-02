# iterator over the set of vectors `v` of length n containing positive integers
# such that `v[i] ≤ ref[i]` for all `i`
#
# NOTE: The iterator can be instructed to not create copies of the vectors,
# which are however modified during iteration.
struct CartesianIterator{V<:AbstractVector{Int}}
    ref::V
    copy::Bool

    function CartesianIterator(ref::V, copy::Bool=true) where {V}
        @assert length(ref) > 0 "need at least one entry"
        @assert all(>(0), ref) "all entries must be positive"
        return new{V}(ref, copy)
    end
end

function Base.length(it::CartesianIterator)
    return prod(it.ref)
end

Base.eltype(::Type{<:CartesianIterator{V}}) where {V} = V

function Base.iterate(it::CartesianIterator)
    state = ones(Int, length(it.ref))
    return (state, state)
end

function Base.iterate(it::CartesianIterator, state)
    if it.copy
        state = copy(state)
    end
    i = length(it.ref) + 1
    @inbounds while true
        i -= 1
        if i == 0
            return nothing
        end
        if state[i] < it.ref[i]
            state[i] += 1
            break
        end
        state[i] = 1
    end
    return (state, state)
end
