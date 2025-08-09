using ReachabilityBase.Arrays
using ReachabilityBase.Comparison: isapproxzero

for N in [Float64, Float32, Rational{Int}]
    v1 = N[2, 1]
    v2 = N[1, 2]
    @test isabove(N[2, 0], v1, v2)
    @test !isabove(N[1, 3], v1, v2)
    @test !isabove(N[2, 2], v1, v2) && !isabove(N[0, 0], v1, v2)  # perpendicular

    # append_zeros / prepend_zeros
    v1 = N[0, 4, 0]
    v2 = sparsevec(N[2], N[4], 3)
    @test v1 == v2
    v1a = append_zeros(v1, 2)
    v1p = prepend_zeros(v1, 2)
    @test v1a == append_zeros(v2, 2) == N[0, 4, 0, 0, 0]
    @test v1p == prepend_zeros(v2, 2) == N[0, 0, 0, 4, 0]
end

for N in [Float64, Float32]
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
