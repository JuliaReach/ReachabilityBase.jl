using ReachabilityBase.Expm
using SparseArrays

M1 = [1.0 0; 0 3]  # small matrix
M2 = [1.0+1im 0; 0 3]  # complex
M3 = zeros(20, 20)
for i in 1:20  # large matrix
    M3[i, i] = 1 / i
end
M4 = fill(0.0+0im, 20, 20)  # complex
for i in 1:20
    M4[i, i] = 1 / i
end

for M in (M1, M2, M3, M4)
    @test expm(M) == expm(sparse(M)) == exp(M)
end

# switch to FastExpm
import FastExpm

for M in (M1, M2)
    @test expm(M) == expm(sparse(M)) == exp(M)
end
for M in (M3, M4)
    @test expm(M) ≈ expm(sparse(M)) ≈ exp(M)
end
