"""
    logarithmic_norm(A::AbstractMatrix, p::Real=Inf)

Compute the logarithmic norm (also known as matrix measure) for commonly used p-norms.

### Input

- `A` -- matrix
- `p` -- (optional, default: `Inf`) p-norm

### Output

A number representing the logarithmic norm.

### Notes

The implementation currently supports the following values for `p`: `1`, `2`, `Inf`.

See [DesoerV09](@citet) for a reference.
"""
function logarithmic_norm(A::AbstractMatrix, p::Real=Inf)
    if p == Inf
        return _logarithmic_norm_inf(A)
    elseif p == 1
        return _logarithmic_norm_1(A)
    elseif p == 2
        return _logarithmic_norm_2(A)
    else
        throw(ArgumentError("`logarithmic_norm` is only implemented for p = 1, 2, or Inf, " *
                            "but got p = $p"))
    end
end

# max_j a_jj + ∑_{i ≠ j} |a_ij|
function _logarithmic_norm_1(A::AbstractMatrix)
    out = -Inf
    @inbounds for j in axes(A, 2)
        α = A[j, j]
        for i in axes(A, 1)
            if i ≠ j
                α += abs(A[i, j])
            end
        end
        if α > out
            out = α
        end
    end
    return out
end

# max_i a_ii + ∑_{j ≠ i} |a_ij|
function _logarithmic_norm_inf(A::AbstractMatrix)
    out = -Inf
    @inbounds for i in axes(A, 1)
        α = A[i, i]
        for j in axes(A, 2)
            if i ≠ j
                α += abs(A[i, j])
            end
        end
        if α > out
            out = α
        end
    end
    return out
end

# max_j  1/2 * λⱼ(A + Aᵀ)
function _logarithmic_norm_2(A::AbstractMatrix{N}) where {N}
    B = Hermitian(A + A')  # type information that all eigenvalues are real
    λ = eigmax(B)
    return λ / 2
end
