using ReachabilityBase.Arrays, Test, LinearAlgebra, SparseArrays
using ReachabilityBase.Comparison: isidentical

for N in [Float64, Float32, Rational{Int}]
    x = SingleEntryVector(1, 3, N(-10))

    # constructors
    @test_throws ArgumentError SingleEntryVector(0, 2, N(1))
    @test_throws ArgumentError SingleEntryVector(3, 2, N(1))
    @test_throws ArgumentError SingleEntryVector(1, 0, N(1))
    y = SingleEntryVector(1, 2, N(0))  # zero is a valid entry
    @test iszero(y)
    # type parameter
    y = SingleEntryVector{N}(1, 3, N(-10))
    @test isidentical(y, x)
    # one-element default value
    y = SingleEntryVector{N}(2, 3)
    @test isidentical(y, SingleEntryVector(2, 3, N(1)))

    # getindex
    @test_throws BoundsError x[0]
    @test_throws BoundsError x[6]
    v = x[1]
    @test v isa N && v == x.v
    for i in 2:3
        v = x[i]
        @test v isa N && v == zero(N)
    end

    # size
    @test size(x) == (3,)
    @test_throws BoundsError size(x, 0)
    @test size(x, 1) == 3
    @test size(x, 2) == 1  # Base.size behavior for other indices

    # negation
    y = -x
    @test isidentical(y, SingleEntryVector(1, 3, N(10)))

    # addition
    @test_throws DimensionMismatch x + SingleEntryVector(1, 1, N(1))
    # same index
    y = SingleEntryVector(1, 3, N(-3))
    z = x + y
    @test isidentical(z, SingleEntryVector(1, 3, N(-13)))
    # different index
    y = SingleEntryVector(2, 3, N(-3))
    z = x + y
    @test z isa SparseVector{N} && z == sparsevec([1, 2], N[-10, -3], 3)

    # subtraction
    @test_throws DimensionMismatch x - SingleEntryVector(1, 1, N(1))
    # same index
    y = SingleEntryVector(1, 3, N(-3))
    z = x - y
    @test isidentical(z, SingleEntryVector(1, 3, N(-7)))
    # different index
    y = SingleEntryVector(2, 3, N(-3))
    z = x - y
    @test z isa SparseVector{N} && z == sparsevec([1, 2], N[-10, 3], 3)

    # matrix-vector multiplication
    M = zeros(N, 1, 1)
    @test_throws DimensionMismatch M * x
    # Matrix
    M = N[2 3 4; -9 -8 -7]
    y = M * x
    @test y isa Vector{N} && y == N[-20, 90]
    # SparseMatrixCSC
    M = sparse(M)
    y = M * x
    @test y isa SparseVector{N} && y == N[-20, 90]
    # Diagonal
    M = Diagonal(N[2])
    @test_throws DimensionMismatch M * x
    M = Diagonal(N[2, 3, 4])
    y = M * x
    @test isidentical(y, SingleEntryVector(1, 3, N(-20)))

    # At_mul_B
    # matrix/vector and vector/matrix
    M = N[1 2; 3 4]
    @test_throws DimensionMismatch At_mul_B(M, x)
    @test_throws DimensionMismatch At_mul_B(x, M)
    M = N[1 2; 3 4; 5 6]
    for x in (At_mul_B(M, x), At_mul_B(x, M))
        @test x isa Vector{N} && x == N[-10, -20]
    end
    # SingleEntryVector/SingleEntryVector
    y = SingleEntryVector(1, 2, N(1))
    @test_throws DimensionMismatch At_mul_B(x, y)
    # same index
    y = SingleEntryVector(1, 3, N(3))
    z = At_mul_B(x, y)
    @test z isa Vector{N} && z == N[-30]
    # different index
    y = SingleEntryVector(2, 3, N(3))
    z = At_mul_B(x, y)
    @test z isa Vector{N} && z == N[0]

    # inner
    y = SingleEntryVector(1, 2, N(3))
    @test_throws DimensionMismatch inner(x, M, x)
    @test_throws DimensionMismatch inner(y, M, y)
    v = inner(x, M, y)
    @test v isa N && v == dot(x, M * y) == N(-30)

    # append_zeros
    y = SingleEntryVector(2, 3, N(2))
    z = append_zeros(y, 2)
    @test isidentical(z, SingleEntryVector(2, 5, N(2)))

    # prepend_zeros
    z = prepend_zeros(y, 2)
    @test isidentical(z, SingleEntryVector(4, 5, N(2)))

    # norm
    @test_throws ArgumentError norm(x, N(1 // 2))
    v = norm(x)
    @test v isa N && v == N(10)
    for p in (1, 2, Inf)
        v = norm(x, p)
        @test v isa N && v == N(10)
    end

    # distance
    y = SingleEntryVector(1, 2, N(2))
    @test_throws DimensionMismatch distance(x, y)
    y = SingleEntryVector(1, 3, N(-3))
    @test_throws ArgumentError distance(x, y; p=N(1 // 2))
    # same index
    for (x1, x2) in ((x, y), (y, x))
        @test distance(x1, x2) == distance(x1, x2; p=N(2)) == distance(x1, x2; p=N(Inf)) == N(7)
    end
    # different index
    y = SingleEntryVector(2, 3, N(-6))
    for (x1, x2) in ((x, y), (y, x))
        @test distance(x, y) == distance(x, y; p=N(2)) == norm(N[-10, -6], N(2))
        @test distance(x, y; p=N(Inf)) == N(10)
    end

    # abs_sum
    M = N[-1 -2; 3 4; 5 6]
    v = abs_sum(x, M)
    @test v isa N && v == N(30)
end
