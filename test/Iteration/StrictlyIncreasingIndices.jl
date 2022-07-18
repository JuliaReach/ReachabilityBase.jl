using JuliaReachBase.Iteration

vectors = Vector{AbstractVector{Int}}()
for v in StrictlyIncreasingIndices(5, 4)
    push!(vectors, copy(v))
end
@test vectors == [[1, 2, 3, 4], [1, 2, 3, 5], [1, 2, 4, 5], [1, 3, 4, 5], [2, 3, 4, 5]]
