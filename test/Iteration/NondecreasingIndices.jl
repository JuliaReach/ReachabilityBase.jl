using ReachabilityBase.Iteration

vectors = Vector{AbstractVector{Int}}()
for v in NondecreasingIndices(2, 3)
    push!(vectors, copy(v))
end
@test vectors == [[1, 1, 1], [1, 1, 2], [1, 2, 2], [2, 2, 2]]
