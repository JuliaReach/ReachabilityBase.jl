# Arrays

This section of the manual describes the `Arrays` module.

```@contents
Pages = ["Arrays.md"]
Depth = 3
```

```@meta
CurrentModule = ReachabilityBase.Arrays
```

```@docs
Arrays
argmaxabs
cross_product(::AbstractMatrix{N}) where {N<:Real}
distance(::AbstractVector{N}, ::AbstractVector{N}; ::Real=N(2)) where {N}
dot_zero
extend
extend_with_zeros
hasfullrowrank
inner
is_cyclic_permutation
is_right_turn
isabove
isinvertible
ismultiple
ispermutation
issquare
iswellconditioned
logarithmic_norm
matrix_type
nonzero_columns
nonzero_indices
projection_matrix
rand_pos_neg_zerosum_vector
rationalize
rectify
remove_duplicates_sorted!
remove_zero_columns
right_turn
same_sign
samedir
SingleEntryVector
substitute
substitute!
to_matrix
to_negative_vector
uniform_partition
vector_type
```
