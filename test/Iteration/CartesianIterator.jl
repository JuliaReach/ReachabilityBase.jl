using ReachabilityBase.Iteration

@test_throws AssertionError CartesianIterator(Int[])
@test_throws AssertionError CartesianIterator([-1])

ci = CartesianIterator([2, 3], false)
ci2 = CartesianIterator([2, 3], true)
@test length(ci) == length(ci2) == 6
@test [copy(v) for v in ci] == collect(ci2) == [[1, 1], [1, 2], [1, 3], [2, 1], [2, 2], [2, 3]]

ci = CartesianIterator([1, 1, 1], true)
@test length(ci) == 1
@test collect(ci) == [[1, 1, 1]]
