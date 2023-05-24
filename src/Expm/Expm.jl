"""
    Expm

This module provides functionality for computing the matrix exponential.
"""
module Expm

using Requires
using LinearAlgebra: checksquare
using SparseArrays: AbstractSparseMatrixCSC

export expm

# matrix dimension from which on the FastExpm algorithm is used
const FASTEXPM_THRESHOLD = 17

"""
    expm(M::AbstractMatrix)

Compute the matrix exponential. Conditionally (see below) use the
[`FastExpm`](https://github.com/fmentink/FastExpm.jl) implementation.

### Input

- `M` -- matrix

### Output

A matrix corresponding to ``\\exp(M)``.

### Algorithm

The [`FastExpm`](https://github.com/fmentink/FastExpm.jl) implementation is
used under the following conditions:

- The `FastExpm` package is loaded.
- The matrix `M` is sparse.
- The dimension of `M` is higher than $FASTEXPM_THRESHOLD.

### Notes

If not all of the above conditions are satisfied, this method uses the
`LinearAlgebra` implementation, for which it converts to a dense matrix.

If the `FastExpm` implementation is used, the result is a complex matrix. If
`M` is a real matrix, the result is a real matrix too (i.e., the imaginary
part is discarded).
"""
function expm(M::AbstractMatrix)
    return exp(Matrix(M))  # convert to dense matrix
end

# skip conversion to dense matrix if already dense
function expm(M::Matrix)
    return exp(M)
end

function load_FastExpm()
    return quote
        using .FastExpm: fastExpm
        function expm(M::AbstractSparseMatrixCSC)
            if checksquare(M) >= FASTEXPM_THRESHOLD
                return fastExpm(M)
            else
                return exp(Matrix(M))  # convert to dense matrix
            end
        end
        function expm(M::AbstractSparseMatrixCSC{<:Real})
            if checksquare(M) >= FASTEXPM_THRESHOLD
                return real.(fastExpm(M))  # drop imaginary part
            else
                return exp(Matrix(M))  # convert to dense matrix
            end
        end
    end
end

function __init__()
    @require FastExpm = "7868e603-8603-432e-a1a1-694bd70b01f2" eval(load_FastExpm())
end

end  # module
