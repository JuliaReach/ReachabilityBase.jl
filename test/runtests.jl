using ReachabilityBase, Test
using LinearAlgebra, SparseArrays
using Random: GLOBAL_RNG, seed!

seed!(1234)  # fix RNG seed for reproducibility

@testset "Arrays" begin
    @testset "array_operations" begin
        include("Arrays/array_operations.jl")
    end
    @testset "arrays" begin
        include("Arrays/arrays.jl")
    end
    @testset "logarithmic_norm" begin
        include("Arrays/logarithmic_norm.jl")
    end
    @testset "vector_operations" begin
        include("Arrays/vector_operations.jl")
    end
end
@testset "Comparison" begin
    include("Comparison/comparison.jl")
end
@testset "CurrentPath" begin
    include("CurrentPath/CurrentPath.jl")
end
@testset "Distribution" begin
    include("Distribution/reseed.jl")
end
@testset "Iteration" begin
    @testset "NondecreasingIndices" begin
        include("Iteration/NondecreasingIndices.jl")
    end
    @testset "StrictlyIncreasingIndices" begin
        include("Iteration/StrictlyIncreasingIndices.jl")
    end
end
@testset "Timing" begin
    include("Timing/timing.jl")
end

if VERSION > v"1.6"
    using Documenter
    @testset "doctests" begin
        doctest(ReachabilityBase)
    end
end

include("Aqua.jl")
