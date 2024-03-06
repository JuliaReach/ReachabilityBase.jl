using ReachabilityBase.CurrentPath

@testset "@current_path macro" begin
    # no prefix
    file = @current_path "my_data.dat"
    @test file == joinpath(@__DIR__, "my_data.dat")
    # with prefix
    file2 = @current_path "prefix is ignored" "my_data.dat"
    @test file2 == file
end
