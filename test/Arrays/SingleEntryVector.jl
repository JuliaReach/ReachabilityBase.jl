using ReachabilityBase.Arrays

for N in [Float64, Float32, Rational{Int}]
    x = SingleEntryVector(1, 100, N(10))
    y = SingleEntryVector(1, 100, N(3))
    z = SingleEntryVector(2, 100, N(-6))

    # addition
    res = x + y
    @test res == SingleEntryVector(1, 100, N(13)) && typeof(res) == SingleEntryVector{N}
    res = x + z
    w = zeros(N, 100); w[1] = N(10); w[2] = N(-6)
    @test res == w

    # subtraction
    res = x - y
    @test res == SingleEntryVector(1, 100, N(7)) && typeof(res) == SingleEntryVector{N}
    res = x - z
    w = zeros(N, 100); w[1] = N(10); w[2] = N(6)
    @test res == w
end
