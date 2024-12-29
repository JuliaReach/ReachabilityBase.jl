using ReachabilityBase.Arrays

for _dummy_ in 1:1 # avoid global variable warnings
    # square matrix
    @test issquare([2 3; 0 0])
    @test issquare(sparse([1], [1], [1], 3, 3))
    @test !issquare(hcat([2 3]))
    @test !issquare(sparse([1], [1], [1], 3, 4))

    # invertible matrix: (1) invertible, (2) non-invertible, (3) non-square
    # dense matrix
    @test isinvertible([2 3; 1 2])
    @test !isinvertible([2 3; 0 0])
    @test !isinvertible(hcat([2 3]))
    # sparse matrix
    @test isinvertible(sparse([2 3; 1 2]))
    @test !isinvertible(sparse([2 3; 0 0]))
    @test !isinvertible(sparse(hcat([2 3])))
    # diagonal matrix
    @test isinvertible(Diagonal([2 0; 0 2]))
    @test !isinvertible(Diagonal([2 0; 0 0]))

    # matrix rank
    A = sprandn(2, 10, 0.4)
    @test rank(Matrix(A)) == rank(A) == rank(view(A, :, :))

    # extend_with_zeros
    @test extend_with_zeros(Float64[], [1, 2]) == [0.0, 0.0]
    @test extend_with_zeros([1, 2, 3], [3, 5]) == [1, 2, 0, 3, 0]
end

for N in [Float64, Rational{Int}, Float32]
    # removal of zero columns
    A = N[1 2; 3 4]
    @test remove_zero_columns(A) === A
    @test remove_zero_columns(sparse(A)) == A
    B = N[1 0 2; 3 0 4]
    @test remove_zero_columns(B) == remove_zero_columns(sparse(B)) == A
    C = N[1e-16 0; 0 -1e-16]
    @test remove_zero_columns(C) == (N <: AbstractFloat ? zeros(N, 2, 0) : C)

    # substitution
    x = N[1, 2, 3]
    substitution = Dict(1 => N(4), 3 => N(0))
    @test substitute(substitution, x) == N[4, 2, 0]
    substitute!(substitution, x)
    @test x == N[4, 2, 0]

    A = N[1 4; 2 5; 3 6]
    x1 = N[0, 2, 0]
    y1 = N[3, 0]
    x2 = SingleEntryVector(2, 3, N(2))
    y2 = SingleEntryVector(1, 2, N(3))
    @test -x2 == SingleEntryVector(2, 3, N(-2))
    @test inner(x1, A, y1) == dot(x1, A * y1) == inner(x2, A, y2) ==
          dot(x2, A * y2) == N(12)

    x = N[0, 1, -1]
    @test rectify(x) == N[0, 1, 0]

    # approximate permutation check
    v1 = [N[1, 2], N[2, 3], N[3, 4]]
    tol = Base.rtoldefault(N) / 2
    v2 = [N[3 + tol, 4 - tol], N[2 - tol, 3 + tol], N[1 + tol, 2 + tol]]
    v3 = [N[2, 3], N[1, 2], N[4, 4]]
    @test ispermutation(v1, v2) && !ispermutation(v2, v3)
    x = N[1]
    y = [N(1) + Base.rtoldefault(N)]
    @test ispermutation(x, y) && ispermutation(y, x)
    x = N[1, 1]
    y = [N(1), N(1) + Base.rtoldefault(N)]
    @test ispermutation(x, y) && ispermutation(y, x)

    # to_negative_vector
    for v in [N[-1, 0, 1], sparsevec([1, 3], N[-1, 1], 3), N(-1):N(1):N(1)]
        u = to_negative_vector(v)
        @test u isa Vector{N} && u == N[1, 0, -1]
    end

    # vector -> matrix conversion
    M0 = N[0 1; 2 3]
    V = [N[0, 2], N[1, 3]]
    M = to_matrix(V)
    @test M isa Matrix{N} && M == M0
    V = [sparsevec([2], N[2]), sparsevec([1, 2], N[1, 3])]
    M = to_matrix(V)
    @test M isa SparseMatrixCSC{N} && M == M0

    # same sign
    A = (N isa AbstractFloat) ? rand(N, 100, 100) : ones(N, 100, 100)
    @test same_sign(A; optimistic=true) == same_sign(A; optimistic=false) == true
    A[50, 50] = N(-1)
    @test same_sign(A; optimistic=true) == same_sign(A; optimistic=false) == false

    # ============================================
    # Corresponding vector types and matrix types
    # ============================================

    # sparse
    vec = sparsevec([1, 3], N[1, 3], 3)
    mat = sparse([1, 3], [1, 3], N[1, 3], 3, 3)
    @test vector_type(typeof(vec)) == SparseVector{N,Int}
    @test matrix_type(typeof(vec)) == SparseMatrixCSC{N,Int64}
    @test vector_type(typeof(mat)) == SparseVector{N,Int}
    @test matrix_type(typeof(mat)) == SparseMatrixCSC{N,Int64}

    # regular
    vec = N[1, 0, 3]
    mat = N[1 0 0; 0 0 0; 0 0 3]
    @assert vector_type(typeof(vec)) == Vector{N}
    @assert matrix_type(typeof(vec)) == Matrix{N}
    @assert vector_type(typeof(mat)) == Vector{N}
    @assert matrix_type(typeof(mat)) == Matrix{N}

    # other: Diagonal
    mat = Diagonal(N[1, 2])
    @test vector_type(typeof(mat)) == Vector{N}
    @assert matrix_type(typeof(mat)) == Diagonal{N,Vector{N}}
end

for N in [Float64, Float32]
    # modified dot product
    @test isnan(dot(N[1, 0], N[Inf, -Inf]))
    @test dot_zero(N[1, 0], N[Inf, -Inf]) == N(Inf)

    # remove zero columns
    m = 3
    n = 10
    A = ones(N, m, n)
    A[:, 1] = A[:, 5] = A[:, n] = zeros(N, m)
    nzcol = nonzero_columns(A)
    B = A[:, nzcol]
    @test size(B) == (m, n - 3)
    Asp = sparse(A)
    @test nonzero_columns(Asp) == [2, 3, 4, 6, 7, 8, 9]

    # extend by orthogonal complement
    M = N[1 1; 2 2; 3 4.0]
    @assert rank(M) == 2
    Mext, inv_Mext = extend(M)
    @test rank(Mext) == 3
    @test Mext * inv_Mext ≈ Matrix(one(N)I, 3, 3)
    Md = N[1 1; 2 2; 3 3.0]
    @test_throws ArgumentError extend(Md) # test default argument check
    @test_throws ArgumentError extend(Md, check_rank=true)
end