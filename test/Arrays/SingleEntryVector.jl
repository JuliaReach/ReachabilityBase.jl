using ReachabilityBase.Arrays

for N in [Float64, Float32, Rational{Int}]
    x = SingleEntryVector(1, 100, N(-1))
    y = SingleEntryVector(1, 100, N(-3))
    z = SingleEntryVector(2, 100, N(-6))

    @test distance(x, y) == distance(x, y, N(2)) == distance(x, y, N(Inf)) == N(2)
    @test distance(x, z) == distance(x, z, N(2)) ≈ sqrt(N(37))
    @test distance(x, z, N(Inf)) == N(6)
end
