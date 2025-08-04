using ReachabilityBase.Arrays, Test, SparseArrays
using ReachabilityBase.Comparison: isidentical

for N in [Float64, Float32, Rational{Int}]
    # same_sign
    @test same_sign(zeros(N, 0))
    A = reshape(N.(collect(1:8)), 2, 2, 2)
    @test same_sign(A)
    @test same_sign(-A)
    A[1, 1, 1] = -1
    @test !same_sign(A)
    @test !same_sign(-A)
    A[1, 1, 1] = 1
    A[2, 2, 2] = -8
    @test !same_sign(A)
    @test !same_sign(-A)

    # rectify
    A = reshape(N.(collect(1:8)), 2, 2, 2)
    A2 = rectify(A)
    @test isidentical(A2, A)
    A2 = rectify(-A)
    A3 = zeros(N, 2, 2, 2)
    @test isidentical(A2, A3)

    # argmaxabs
    @test_throws ArgumentError argmaxabs(zeros(N, 0, 1, 1))
    @test argmaxabs(N[0, 0]) == 1
    @test argmaxabs(reshape(N[-4, -2, 4, 2], 1, 2, 2)) == 1
    @test argmaxabs(N[-4, 5, 4]) == 2
end

for N in [Float32, Float64]
    to_3d(v) = reshape(v, 1, 2, 2)

    # rationalize
    A = to_3d(N[1, 2, 3, 4])
    # default: Rational{Int}
    A2 = rationalize(A)
    A3 = to_3d(Rational{Int}[1, 2, 3, 4])
    @test isidentical(A2, A3)
    # tolerance
    A2 = rationalize(A; tol=2 * eps(N))
    @test isidentical(A2, A3)
    # nested arrays
    A2 = rationalize(Int, [A, A], 2 * eps(N))
    isidentical(A2, [A3, A3])
    # Rational{BigInt}
    A2 = rationalize(BigInt, A)
    A3 = to_3d(Rational{BigInt}[1, 2, 3, 4])
    @test isidentical(A2, A3)
    # tolerance
    A2 = rationalize(BigInt, A; tol=2 * eps(N))
    @test isidentical(A2, A3)
end
