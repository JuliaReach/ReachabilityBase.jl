using JuliaReachBase, Test
using LinearAlgebra, SparseArrays
using Random: GLOBAL_RNG

@time @testset "Comparison" begin include("Comparison/comparison.jl") end
@time @testset "Iteration" begin include("Iteration/StrictlyIncreasingIndices.jl") end
@time @testset "Distribution" begin include("Distribution/reseed.jl") end
@time @testset "Arrays.array_operations" begin include("Arrays/array_operations.jl") end
@time @testset "Arrays.arrays" begin include("Arrays/arrays.jl") end

using Documenter
@time @testset "JuliaReachBase.doctests" begin doctest(JuliaReachBase) end
