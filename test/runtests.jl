using JuliaReachBase, Test

@time @testset "Comparison" begin include("Comparison/comparison.jl") end
@time @testset "Iteration" begin include("Iteration/StrictlyIncreasingIndices.jl") end
