using ReachabilityBase.Iteration

ci = ColumnIterator([1 2; 3 4])
@test length(ci) == 2
@test eltype(ci) == Vector{Int}
@test collect(ci) == [[1, 3], [2, 4]]

ci = ColumnIterator(sparse([1 0 0; 0 0 4]))
@test length(ci) == 3
@test eltype(ci) == SparseVector{Int}
@test collect(ci) == [sparsevec([1, 0]), sparsevec([0, 0]), sparsevec([0, 4])]

ci = ColumnIterator(Diagonal(1:4))
@test length(ci) == 4
@test eltype(ci) == AbstractVector{Int}
@test collect(ci) == [[1, 0, 0, 0], [0, 2, 0, 0], [0, 0, 3, 0], [0, 0, 0, 4]]
