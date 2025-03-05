using ReachabilityBase.Arrays

for N in [Float64, Float32, Rational{Int}]
    x = SingleEntryVector(1, 100, N(10))
    y = SingleEntryVector(1, 100, N(3))
    z = SingleEntryVector(2, 100, N(-6))

    # getindex
    e = x[1]
    @test e isa N && e == N(10)
    e = x[2]
    @test e isa N && e == zero(N)
    @test_throws BoundsError x[0]
    @test_throws BoundsError x[101]

    # addition
    res = x + y
    @test res == SingleEntryVector(1, 100, N(13)) && typeof(res) == SingleEntryVector{N}
    res = x + z
    w = zeros(N, 100)
    w[1] = N(10)
    w[2] = N(-6)
    @test res == w

    # subtraction
    res = x - y
    @test res == SingleEntryVector(1, 100, N(7)) && typeof(res) == SingleEntryVector{N}
    res = x - z
    w = zeros(N, 100)
    w[1] = N(10)
    w[2] = N(6)
    @test res == w

    x = SingleEntryVector(1, 100, N(-1))
    y = SingleEntryVector(1, 100, N(-3))
    z = SingleEntryVector(2, 100, N(-6))

    # distance
    @test distance(x, y) == distance(x, y; p=N(2)) == distance(x, y; p=N(Inf)) == N(2)
    @test distance(x, z) == distance(x, z; p=N(2)) ≈ sqrt(N(37))
    @test distance(x, z; p=N(Inf)) == N(6)
end
