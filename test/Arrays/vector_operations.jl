using ReachabilityBase.Arrays

for N in [Float64, Float32, Rational{Int}]
    v1 = N[2, 1]
    v2 = N[1, 2]
    @test isabove(N[2, 0], v1, v2)
    @test !isabove(N[1, 3], v1, v2)
    @test !isabove(N[2, 2], v1, v2) && !isabove(N[0, 0], v1, v2)  # perpendicular
end
