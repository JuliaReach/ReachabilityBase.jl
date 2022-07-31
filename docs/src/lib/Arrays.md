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
allequal
cross_product(::AbstractMatrix{N}) where {N<:Real}
distance(::AbstractVector, ::AbstractVector; ::Real=2.0)
dot_zero
extend
hasfullrowrank
inner
is_cyclic_permutation
is_right_turn
isabove
isinvertible
ismultiple
ispermutation
issquare
matrix_type
nonzero_columns
nonzero_indices
projection_matrix
rationalize
rectify
remove_duplicates_sorted!
remove_zero_columns
right_turn
same_sign
samedir
similar_direction
SingleEntryVector
substitute
substitute!
to_matrix
to_negative_vector
vector_type
```
