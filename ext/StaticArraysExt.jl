module StaticArraysExt

using ReachabilityBase.Arrays

@static if isdefined(Base, :get_extension)
    import StaticArrays
else
    import ..StaticArrays
end

# represent the projection matrix with a static array
function Arrays.projection_matrix(block::AbstractVector{Int}, n::Int,
                                  ::Type{<:StaticArrays.SVector{L,N}}) where {L,N}
    mat = projection_matrix(block, n, N)
    m = size(mat, 1)
    return StaticArrays.SMatrix{m,n}(mat)
end

Arrays.similar_type(x::StaticArrays.StaticArray) = StaticArrays.similar_type(x)

end  # module
