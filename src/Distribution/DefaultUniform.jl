"""
    DefaultUniform{N}

Represents a uniform distribution over an interval ``[a, b]``.

### Fields

- `a` -- lower bound
- `b` -- upper bound
"""
struct DefaultUniform{N}
    a::N
    b::N
end

function rand(rng::AbstractRNG, U::DefaultUniform)
    r = rand(rng)
    Δ = U.b - U.a
    return Δ * r + U.a
end

function rand(rng::AbstractRNG, U::DefaultUniform, n::Int)
    return [rand(rng, U) for _ in 1:n]
end

function rand(rng::AbstractRNG, U::AbstractVector{<:DefaultUniform})
    return rand.(Ref(rng), U)
end

function rand!(x, rng::AbstractRNG, U::DefaultUniform)
    @inbounds for i in eachindex(x)
        x[i] = rand(rng, U)
    end
    return x
end
