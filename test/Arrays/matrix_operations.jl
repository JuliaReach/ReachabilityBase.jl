using StaticArrays: SVector, SMatrix

P = projection_matrix([1, 2], 5, SVector{3, Int})
@test P == [1 0 0 0 0; 0 1 0 0 0] && P isa SMatrix{2, 5, Int, 10}
