"""
    dot_zero(x::AbstractVector{N}, y::AbstractVector{N}) where{N<:Real}

Dot product with preference for zero value in the presence of infinity values.

### Input

- `x` -- first vector
- `y` -- second vector

### Output

The dot product of `x` and `y`, but with the rule that `0 * Inf == 0`.
"""
function dot_zero(x::AbstractVector{N}, y::AbstractVector{N}) where {N<:Real}
    res = zero(N)
    for i in eachindex(x)
        if !iszero(x[i]) && !iszero(y[i])
            res += x[i] * y[i]
        end
    end
    return res
end

"""
    remove_duplicates_sorted!(v::AbstractVector)

Remove duplicate entries in a sorted vector.

### Input

- `v` -- sorted vector

### Output

The input vector without duplicates.
"""
function remove_duplicates_sorted!(v::AbstractVector)
    for i in (length(v) - 1):-1:1
        if v[i] == v[i + 1]
            splice!(v, i + 1)
        end
    end
    return v
end

"""
    samedir(u::AbstractVector{<:Real}, v::AbstractVector{<:Real})

Check whether two vectors point in the same direction.

### Input

- `u` -- first vector
- `v` -- second vector

### Output

`(true, k)` iff the vectors are identical up to a positive scaling factor `k`
such that `u = k * v`, and `(false, 0)` otherwise.


### Examples

```jldoctest; setup = :(using ReachabilityBase.Arrays)
julia> samedir([1, 2, 3], [2, 4, 6])
(true, 0.5)

julia> samedir([1, 2, 3], [3, 2, 1])
(false, 0)

julia> samedir([1, 2, 3], [-1, -2, -3])
(false, 0)

```
"""
function samedir(u::AbstractVector{<:Real}, v::AbstractVector{<:Real})
    return _ismultiple(u, v; allow_negative=false)
end

"""
    ismultiple(u::AbstractVector{<:Real}, v::AbstractVector{<:Real})

Check whether two vectors are linearly dependent.

### Input

- `u` -- first vector
- `v` -- second vector

### Output

`(true, k)` iff the vectors are identical up to a scaling factor `k ≠ 0` such
that `u = k * v`, and `(false, 0)` otherwise.


### Examples

```jldoctest; setup = :(using ReachabilityBase.Arrays)
julia> ismultiple([1, 2, 3], [2, 4, 6])
(true, 0.5)

julia> ismultiple([1, 2, 3], [3, 2, 1])
(false, 0)

julia> ismultiple([1, 2, 3], [-1, -2, -3])
(true, -1.0)

```
"""
function ismultiple(u::AbstractVector{<:Real}, v::AbstractVector{<:Real})
    return _ismultiple(u, v; allow_negative=true)
end

function _ismultiple(u::AbstractVector, v::AbstractVector; allow_negative::Bool)
    @assert length(u) == length(v) "wrong dimension"
    no_factor = true
    factor = 0
    @inbounds for i in eachindex(u)
        if isapproxzero(u[i])
            if !isapproxzero(v[i])
                return (false, 0)
            end
            continue
        elseif isapproxzero(v[i])
            return (false, 0)
        end
        if no_factor
            no_factor = false
            factor = u[i] / v[i]
            if !allow_negative && factor < 0
                return (false, 0)
            end
        elseif !_isapprox(factor, u[i] / v[i])
            return (false, 0)
        end
    end
    if no_factor
        # both vectors are zero
        return (true, 0)
    end
    return (true, factor)
end

"""
    is_cyclic_permutation(candidate::AbstractVector, paragon::AbstractVector)

Checks if the elements in `candidate` are a cyclic permutation of the elements
in `paragon`.

### Input

- `candidate` -- candidate vector
- `paragon`   -- paragon vector

### Output

A boolean indicating if the elements of `candidate` are in the same order as in
`paragon` or any of its cyclic permutations.
"""
function is_cyclic_permutation(candidate::AbstractVector,
                               paragon::AbstractVector)
    m = length(candidate)
    if length(paragon) != m
        return false
    end
    return any(candidate == circshift(paragon, i) for i in 0:(m - 1))
end

"""
    isabove(u::AbstractVector, v1::AbstractVector, v2::AbstractVector)

Checks whether the difference `v1 - v2` points toward the given direction `u`.

### Input

- `u`  -- direction
- `v1` -- first vector
- `v2` -- second vector

### Output

A Boolean indicating whether the difference of the given vectors points toward
the given direction.

### Algorithm

The result is equivalent to `dot(u, v1 - v2) > 0`, but the implementation avoids
the allocation of the difference vector.
"""
function isabove(u::AbstractVector, v1::AbstractVector, v2::AbstractVector)
    v = zero(u[1])
    @inbounds for k in eachindex(u)
        v += u[k] * (v1[k] - v2[k])
    end
    return v > 0
end

"""
    to_negative_vector(v::AbstractVector{N}) where {N}

Negate a vector and convert to type `Vector`.

### Input

- `v` -- vector

### Output

A `Vector` equivalent to ``-v``.
"""
@inline function to_negative_vector(v::AbstractVector{N}) where {N}
    u = zeros(N, length(v))
    @inbounds for (i, vi) in enumerate(v)
        u[i] = -vi
    end
    return u
end

@inline function to_negative_vector(v::Vector)
    return -v
end

@inline function to_negative_vector(v::SparseVector{N}) where {N}
    u = zeros(N, length(v))
    @inbounds for (ni, i) in enumerate(v.nzind)
        u[i] = -v.nzval[ni]
    end
    return u
end

"""
    right_turn([O::AbstractVector{<:Real}=[0, 0]], u::AbstractVector{<:Real},
               v::AbstractVector{<:Real})

Compute a scalar that determines whether the acute angle defined by three 2D
points `O`, `u`, `v` in the plane is a right turn (< 180° counter-clockwise)
with respect to the center `O`.

### Input

- `O` -- (optional; default: `[0, 0]`) 2D center point
- `u` -- first 2D point
- `v` -- second 2D point

### Output

A scalar representing the rotation.
If the result is 0, the points are collinear; if it is positive, the points
constitute a positive angle of rotation around `O` from `u` to `v`; otherwise
they constitute a negative angle.

### Algorithm

The [cross product](https://en.wikipedia.org/wiki/Cross_product) is used to
determine the sense of rotation.
"""
@inline function right_turn(O::AbstractVector{<:Real},
                            u::AbstractVector{<:Real},
                            v::AbstractVector{<:Real})
    return (u[1] - O[1]) * (v[2] - O[2]) - (u[2] - O[2]) * (v[1] - O[1])
end

# version for O = origin
@inline function right_turn(u::AbstractVector{<:Real},
                            v::AbstractVector{<:Real})
    return u[1] * v[2] - u[2] * v[1]
end

"""
    is_right_turn([O::AbstractVector{<:Real}=[0, 0]], u::AbstractVector{<:Real},
                  v::AbstractVector{<:Real})

Determine whether the acute angle defined by three 2D points `O`, `u`, `v`
in the plane is a right turn (< 180° counter-clockwise) with
respect to the center `O`.
Determine if the acute angle defined by two 2D vectors is a right turn (< 180°
counter-clockwise) with respect to the center `O`.

### Input

- `O` -- (optional; default: `[0, 0]`) 2D center point
- `u` -- first 2D direction
- `v` -- second 2D direction

### Output

`true` iff the vectors constitute a right turn.
"""
@inline function is_right_turn(O::AbstractVector{<:Real},
                               u::AbstractVector{<:Real},
                               v::AbstractVector{<:Real})
    return _geq(right_turn(O, u, v), 0)
end

# version for O = origin
@inline function is_right_turn(u::AbstractVector{<:Real},
                               v::AbstractVector{<:Real})
    return _geq(right_turn(u, v), 0)
end

"""
    distance(x::AbstractVector{N}, y::AbstractVector{N}; [p]::Real=N(2)) where {N}

Compute the distance between two vectors with respect to the given `p`-norm,
computed as

```math
    \\|x - y\\|_p = \\left( \\sum_{i=1}^n | x_i - y_i |^p \\right)^{1/p}
```

### Input

- `x` -- vector
- `y` -- vector
- `p` -- (optional, default: `2.0`) the `p`-norm used; `p = 2.0` corresponds to
         the usual Euclidean norm

### Output

A scalar representing ``‖ x - y ‖_p``.
"""
function distance(x::AbstractVector{N}, y::AbstractVector{N}; p::Real=N(2)) where {N}
    return norm(x - y, p)
end

function append_zeros(v::AbstractVector{N}, n::Int) where {N}
    return vcat(v, zeros(N, n))
end

function append_zeros(v::SparseVector{N}, n::Int) where {N}
    return sparsevec(v.nzind, v.nzval, v.n + n)
end

function prepend_zeros(v::AbstractVector{N}, n::Int) where {N}
    return vcat(zeros(N, n), v)
end

function prepend_zeros(v::SparseVector{N}, n::Int) where {N}
    return sparsevec(v.nzind .+ n, v.nzval, v.n + n)
end

"""
    ispermutation(u::AbstractVector{T}, v::AbstractVector) where {T}

Check that two vectors contain the same elements up to reordering.

### Input

- `u` -- first vector
- `v` -- second vector

### Output

`true` iff the vectors are identical up to reordering.

### Examples

```jldoctest; setup = :(using ReachabilityBase.Arrays)
julia> ispermutation([1, 2, 2], [2, 2, 1])
true

julia> ispermutation([1, 2, 2], [1, 1, 2])
false
```

### Notes

Containment check is performed using `Comparison._in(e, v)`, so in the case of
floating point numbers, the precision to which the check is made is determined
by the type of elements in `v`. See `_in` and `_isapprox` for more information.

Note that approximate equality is not an equivalence relation.
Hence the result may depend on the order of the elements.
"""
function ispermutation(u::AbstractVector{T}, v::AbstractVector) where {T}
    if length(u) != length(v)
        return false
    end
    occurrence_map = Dict{T,Int}()
    has_duplicates = false
    for e in u
        if !_in(e, v)
            return false
        end
        found = false
        for k in keys(occurrence_map)
            if _isapprox(k, e)
                occurrence_map[k] += 1
                has_duplicates = true
                found = true
                break
            end
        end
        if !found
            occurrence_map[e] = 1
        end
    end
    if has_duplicates
        for e in v
            found = false
            for k in keys(occurrence_map)
                if _isapprox(k, e)
                    found = true
                    occurrence_map[k] -= 1
                    if occurrence_map[k] < 0
                        return false
                    end
                    break
                end
            end
            if !found
                return false
            end
        end
    end
    return true
end

function isupwards(vec)
    return vec[2] > 0 || (vec[2] == 0 && vec[1] > 0)
end

"""
    rand_pos_neg_zerosum_vector(n::Int; [N]::Type{<:Real}=Float64,
                                        [rng]::AbstractRNG=GLOBAL_RNG)

Create a vector of random numbers such that the total sum is (approximately)
zero, no duplicates exist, all positive entries come first, and all negative
entries come last.

### Input

- `n`   -- length of the vector
- `N`   -- (optional; default: `Float64`) numeric type
- `rng` -- (optional; default: `GLOBAL_RNG`) random number generator

### Output

A vector as described above.

### Algorithm

This is the first phase of the algorithm described
[here](https://stackoverflow.com/a/47358689).
"""
function rand_pos_neg_zerosum_vector(n::Int; N::Type{<:Real}=Float64,
                                     rng::AbstractRNG=GLOBAL_RNG)
    # generate a sorted list of random x and y coordinates
    list = sort!(randn(rng, N, n))
    while (length(remove_duplicates_sorted!(list)) < n)
        # make sure that no duplicates exist
        list = sort!(append!(list, randn(rng, N, length(list) - n)))
    end
    # lists of consecutive points
    l1 = Vector{N}() # normal
    l2 = Vector{N}() # inverted
    res = Vector{N}()
    @inbounds begin
        push!(l1, list[1])
        push!(l2, list[1])
        for i in 2:(n - 1)
            push!(rand(rng, Bool) ? l1 : l2, list[i])
        end
        push!(l1, list[end])
        push!(l2, list[end])
        # convert to vectors representing the distance (order does not matter)
        sizehint!(res, n)
        for i in 1:(length(l1) - 1)
            push!(res, l1[i + 1] - l1[i])
        end
        for i in 1:(length(l2) - 1)
            push!(res, l2[i] - l2[i + 1])
        end
    end
    return res
end

"""
     uniform_partition(n::Int, block_size::Int)

Compute a uniform block partition of the given size.

### Input

- `n`          -- number of dimensions of the partition
- `block_size` -- size of each block

### Output

A vector of ranges, `Vector{UnitRange{Int}}`, such that the size of each block
is the same, if possible.

### Examples

If the number of dimensions `n` is 2, we have two options: either two blocks
of size `1` or one block of size `2`:

```jldoctest partition; setup = :(using ReachabilityBase.Arrays)
julia> uniform_partition(2, 1)
2-element Vector{UnitRange{Int64}}:
 1:1
 2:2

julia> uniform_partition(2, 2)
1-element Vector{UnitRange{Int64}}:
 1:2
```

If the `block_size` argument is not compatible with (i.e., does not divide) `n`,
the output is filled with one block of the size needed to reach `n`:

```jldoctest partition
julia> uniform_partition(3, 1)
3-element Vector{UnitRange{Int64}}:
 1:1
 2:2
 3:3

julia> uniform_partition(3, 2)
2-element Vector{UnitRange{Int64}}:
 1:2
 3:3

julia> uniform_partition(10, 6)
2-element Vector{UnitRange{Int64}}:
 1:6
 7:10
```
"""
function uniform_partition(n::Int, block_size::Int)
    m = div(n, block_size)
    r = n % block_size
    res = Vector{UnitRange{Int}}(undef, r > 0 ? m + 1 : m)
    k = 1
    @inbounds for i in 1:m
        l = k + block_size - 1
        res[i] = k:l
        k = l + 1
    end
    @inbounds if r > 0
        res[m + 1] = k:n
    end
    return res
end

"""
    extend_with_zeros(x::AbstractVector, indices::AbstractVector{<:Int})

Extend a vector with zeros in the given dimensions.

### Input

- `x`       -- vector
- `indices` -- indices to extend, from the interval
               `1:(length(x) + length(indices))`

### Output

A new vector.

### Notes

The indices in the extension list are interpreted on the output vector. This is
best understood with an example. Let `x = [1, 2, 3]` and `indices = [3, 5]`.
Then the output vector is `y = [1, 2, 0, 3, 0]`. Indeed, `y[3] == y[5] == 0`.
"""
function extend_with_zeros(x::AbstractVector, indices::AbstractVector{<:Int})
    N = eltype(x)
    n = length(x) + length(indices)
    y = zeros(N, n)
    j_x = 1
    j_indices = 1
    done = false
    for i in 1:n
        if !done && i == indices[j_indices]
            j_indices += 1
            if j_indices > length(indices)
                done = true
            end
        else
            y[i] = x[j_x]
            j_x += 1
        end
    end
    return y
end
