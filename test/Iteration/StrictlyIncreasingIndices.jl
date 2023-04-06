using ReachabilityBase.Iteration

vectors = Vector{AbstractVector{Int}}()
sii = StrictlyIncreasingIndices(5, 4)
@test length(sii) == 5
for v in sii
    push!(vectors, copy(v))
end
@test vectors == [[1, 2, 3, 4], [1, 2, 3, 5], [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]]

vectors = Vector{AbstractVector{Int}}()
sii = StrictlyIncreasingIndices(2, 2)
@test length(sii) == 1
for v in sii
    push!(vectors, copy(v))
end
@test vectors == [[1, 2]]
