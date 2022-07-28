"""
    Arrays

This module provides machinery for vectors and matrices.
"""
module Arrays

using LinearAlgebra, Requires, SparseArrays
import LinearAlgebra: rank

using JuliaReachBase.Assertions: @assert, activate_assertions
activate_assertions(Arrays)  # activate assertions by default

using JuliaReachBase.Comparison: _geq, isapproxzero, _isapprox, _in

import Base: rationalize

export _above,
       _abs_sum,
       _At_ldiv_B,
       _At_mul_B,
       _dr,
       _isupwards,
       _matrix_type,
       _similar_type,
       _up,
       _vector_type,
       allequal,
       append_zeros,
       cross_product,
       DEFAULT_COND_TOL,
       distance,
       dot_zero,
       extend,
       find_unique_nonzero_entry,
       hasfullrowrank,
       inner,
       is_cyclic_permutation,
       is_right_turn,
       isinvertible,
       ismultiple,
       ispermutation,
       issquare,
       nonzero_columns,
       nonzero_indices,
       prepend_zeros,
       projection_matrix,
       rank,
       rationalize,
       rectify,
       remove_duplicates_sorted!,
       remove_zero_columns,
       right_turn,
       same_sign,
       samedir,
       SingleEntryVector,
       substitute,
       substitute!,
       to_matrix,
       to_negative_vector

include("SingleEntryVector.jl")
include("array_operations.jl")
include("matrix_operations.jl")
include("vector_operations.jl")
include("matrix_vector_operations.jl")
include("init.jl")

end  # module
