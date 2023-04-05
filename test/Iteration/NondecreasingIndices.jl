using ReachabilityBase.Iteration

vectors = Vector{AbstractVector{Int}}()
ndi = NondecreasingIndices(2, 3)
@test length(ndi) == 4
for v in ndi
    push!(vectors, copy(v))
end
@test vectors == [[1, 1, 1], [1, 1, 2], [1, 2, 2], [2, 2, 2]]

vectors = Vector{AbstractVector{Int}}()
ndi = NondecreasingIndices(1, 3)
@test length(ndi) == 1
for v in ndi
    push!(vectors, copy(v))
end
@test vectors == [[1, 1, 1]]
