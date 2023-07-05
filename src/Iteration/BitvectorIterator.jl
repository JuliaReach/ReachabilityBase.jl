# iterator over the set of bitvectors of length n
#
# One can define a bitvector `skip` and a bitvector `fix` such that if
# `skip[i] == true`, then bitvectors `b` where `b[i] != fix[i]` will be skipped.
#
# NOTE: The iterator can be instructed to not create copies of the vectors,
# which are however modified during iteration.
struct BitvectorIterator{VS,VF}
    skip::VS
    fix::VF
    copy::Bool
end

# iterator over all 2^n bitvectors
BitvectorIterator(n::Int) = BitvectorIterator(falses(n), nothing, true)

function Base.length(it::BitvectorIterator)
    return 2^sum(iszero.(it.skip))
end

Base.eltype(::Type{<:BitvectorIterator{VS,VF}}) where {VS,VF} = VF

function Base.iterate(it::BitvectorIterator)
    state = zeros(Bool, length(it.skip))
    for i in eachindex(it.skip)
        if it.skip[i]
            state[i] = it.fix[i]
        end
    end
    return (state, state)
end

function Base.iterate(it::BitvectorIterator, state)
    if it.copy
        state = copy(state)
    end
    np1 = length(it.skip) + 1
    i = 0
    @inbounds while true
        i += 1
        if i == np1
            return nothing
        end
        if it.skip[i]
            continue
        end
        if !state[i]
            state[i] = true
            break
        end
        state[i] = false
    end
    return (state, state)
end
