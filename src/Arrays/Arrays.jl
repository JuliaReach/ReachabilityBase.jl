"""
    Arrays

This module provides machinery for vectors and matrices.
"""
module Arrays

using LinearAlgebra, Requires, SparseArrays
import LinearAlgebra: rank

using ReachabilityBase.Assertions: @assert, activate_assertions
activate_assertions(Arrays)  # activate assertions by default

using ReachabilityBase.Comparison: _geq, isapproxzero, _isapprox, _in

import Base: rationalize

export abs_sum,
       allequal,
       append_zeros,
       At_ldiv_B,
       At_mul_B,
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
       isabove,
       isinvertible,
       ismultiple,
       ispermutation,
       issquare,
       isupwards,
       matrix_type,
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
       similar_type,
       substitute,
       substitute!,
       to_matrix,
       to_negative_vector,
       vector_type

include("SingleEntryVector.jl")
include("array_operations.jl")
include("matrix_operations.jl")
include("vector_operations.jl")
include("matrix_vector_operations.jl")
include("init.jl")

end  # module
