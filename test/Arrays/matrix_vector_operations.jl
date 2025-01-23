using StaticArrays: SVector

@test similar_type(SVector(1)) == SVector{1, Int}
