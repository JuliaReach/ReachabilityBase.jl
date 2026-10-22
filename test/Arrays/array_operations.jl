using ReachabilityBase.Arrays
using ReachabilityBase.Comparison

for N in [Float64, Float32, Rational{Int}]
    v1 = N[0, 4, 0]
    v2 = sparsevec(N[2], N[4], 3)
    v3 = SingleEntryVector(2, 3, N(4))
    @test v1 == v2 == v3
    v1a = append_zeros(v1, 2)
    v1p = prepend_zeros(v1, 2)
    @test v1a == append_zeros(v2, 2) == append_zeros(v3, 2) == N[0, 4, 0, 0, 0]
    @test v1p == prepend_zeros(v2, 2) == prepend_zeros(v3, 2) == N[0, 0, 0, 4, 0]

    # argmaxabs
    @test_throws AssertionError argmaxabs(N[])
    @test argmaxabs(N[-4, -2, 3]) == 1
    @test argmaxabs(N[-4, 5, 3]) == 2
    @test argmaxabs(N[1, -2, 3]) == 3

    # same_sign
    for a in ([], [0, 0], [0, 1], [0, -1], [1, 0, 2, 0, 3], [0, -1, 0, -2, 0])
        @test same_sign(a)
    end
    for a in ([1, 0, -2, 0, 3], [0, 1, 0, -2, 0, 3])
        @test !same_sign(a)
    end
end

for N in [Float32, Float64]
    # rationalize
    x = [N(1), N(2), N(3)]
    out = [1 // 1, 2 // 1, 3 // 1]
    @test rationalize(x) == out
    v = rationalize(BigInt, x)
    @test v[1] isa Rational{BigInt}
    @test rationalize(x; tol=2 * eps(N)) == out

    # rand_pos_neg_zerosum_vector
    x = rand_pos_neg_zerosum_vector(10; N=N)
    @test isapproxzero(sum(x))
    @test length(unique(x)) == length(x)
    # test that the order is "first all positive, then all negative entries"
    posneg = true
    neg = false
    for xi in x
        if xi > zero(N)
            if neg
                posneg = false
                break
            end
        elseif !neg
            neg = true
        end
    end
    @test posneg
end
