"""
    Arrays

This module provides machinery for vectors and matrices.
"""
module Arrays

using LinearAlgebra, SparseArrays
import LinearAlgebra: rank

using Random: AbstractRNG, GLOBAL_RNG

using ReachabilityBase.Assertions: @assert, activate_assertions
activate_assertions(Arrays)  # activate assertions by default

using ReachabilityBase.Comparison: _geq, isapproxzero, _isapprox, _in

import Base: rationalize

export abs_sum,
       append_zeros,
       argmaxabs,
       At_ldiv_B,
       At_mul_B,
       cross_product,
       DEFAULT_COND_TOL,
       distance,
       dot_zero,
       extend,
       extend_with_zeros,
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
       iswellconditioned,
       logarithmic_norm,
       matrix_type,
       nonzero_columns,
       nonzero_indices,
       prepend_zeros,
       projection_matrix,
       rand_pos_neg_zerosum_vector,
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
       uniform_partition,
       vector_type

@static if VERSION < v"1.8"
    export allequal
end

include("SingleEntryVector.jl")
include("array_operations.jl")
include("matrix_operations.jl")
include("vector_operations.jl")
include("matrix_vector_operations.jl")
include("logarithmic_norm.jl")
include("init.jl")

end  # module
