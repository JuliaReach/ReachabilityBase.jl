using JuliaReachBase, Test
using Random: GLOBAL_RNG

@time @testset "Comparison" begin include("Comparison/comparison.jl") end
@time @testset "Iteration" begin include("Iteration/StrictlyIncreasingIndices.jl") end
@time @testset "Distribution" begin include("Distribution/reseed.jl") end
