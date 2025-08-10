using ReachabilityBase.Arrays, Test
using ReachabilityBase.Comparison: isidentical

for N in [Float64, Float32, Rational{Int}]
    A = N[1 2; 3 -4]
    @test_throws ArgumentError logarithmic_norm(A, 3)
    @test isidentical(logarithmic_norm(A), N(3))  # default norm is `Inf`
    @test isidentical(logarithmic_norm(A, Inf), N(3))
    @test isidentical(logarithmic_norm(A, 1), N(4))
    # see Example 2 in:
    # "Marcelo Forets and Amaury Pouly: Explicit Error Bounds for Carleman Linearization (2018)"
    A = N[0 1; -1 -2]
    Aop2 = kron(A, A)
    @test isidentical(logarithmic_norm(A, Inf), N(1))
    @test isidentical(logarithmic_norm(Aop2, Inf), N(9))
    @test isidentical(logarithmic_norm(A, 1), N(1))
    @test isidentical(logarithmic_norm(Aop2, 1), N(9))
end

for N in [Float64, Float32]
    A = N[0 1; -1 -2]  # see above
    Aop2 = kron(A, A)
    @test isidentical(logarithmic_norm(A, 2), N(0))
    res = logarithmic_norm(Aop2, 2)
    @test res isa N && res ≈ 4.23606797749979
end
