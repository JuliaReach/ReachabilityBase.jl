using ReachabilityBase, Test
import Aqua

import Pkg
@static if VERSION >= v"1.6"  # TODO make explicit test requirement
    Pkg.add("ExplicitImports")
    import ExplicitImports

    @testset "ExplicitImports tests" begin
        ignores = (:GLOBAL_RNG,)
        @test isnothing(ExplicitImports.check_all_explicit_imports_are_public(ReachabilityBase;
                                                                              ignore=ignores))
        @test isnothing(ExplicitImports.check_all_explicit_imports_via_owners(ReachabilityBase))
        ignores = (Symbol("@__doc__"), :rtoldefault, :gc_alloc_count, :time_print, :typename)
        @test isnothing(ExplicitImports.check_all_qualified_accesses_are_public(ReachabilityBase;
                                                                                ignore=ignores))
        @test isnothing(ExplicitImports.check_all_qualified_accesses_via_owners(ReachabilityBase))
        @test isnothing(ExplicitImports.check_no_implicit_imports(ReachabilityBase))
        @test isnothing(ExplicitImports.check_no_self_qualified_accesses(ReachabilityBase))
        @test isnothing(ExplicitImports.check_no_stale_explicit_imports(ReachabilityBase))
    end
end

@testset "Aqua tests" begin
    Aqua.test_all(ReachabilityBase)
end
