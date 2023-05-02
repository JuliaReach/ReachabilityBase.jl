using ReachabilityBase, Test
using LinearAlgebra, SparseArrays
using Random: GLOBAL_RNG, seed!

seed!(1234)  # fix RNG seed for reproducibility

@time @testset "Comparison" begin
    include("Comparison/comparison.jl")
end
@time @testset "Iteration" begin
    include("Iteration/StrictlyIncreasingIndices.jl")
end
@time @testset "Iteration" begin
    include("Iteration/NondecreasingIndices.jl")
end
@time @testset "Distribution" begin
    include("Distribution/reseed.jl")
end
@time @testset "Arrays.array_operations" begin
    include("Arrays/array_operations.jl")
end
@time @testset "Arrays.arrays" begin
    include("Arrays/arrays.jl")
end

if VERSION > v"1.6"
    using Documenter
    @time @testset "ReachabilityBase.doctests" begin
        doctest(ReachabilityBase)
    end
end
