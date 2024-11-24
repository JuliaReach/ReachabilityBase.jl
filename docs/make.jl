using Documenter, ReachabilityBase

DocMeta.setdocmeta!(ReachabilityBase, :DocTestSetup,
                    :(using ReachabilityBase); recursive=true)

makedocs(; sitename="ReachabilityBase.jl",
         format=Documenter.HTML(; prettyurls=get(ENV, "CI", nothing) == "true",
                                assets=["assets/aligned.css"]),
         modules=[ReachabilityBase, ReachabilityBase.Assertions,
                  ReachabilityBase.Require, ReachabilityBase.Comparison,
                  ReachabilityBase.Iteration, ReachabilityBase.Commutative,
                  ReachabilityBase.Distribution, ReachabilityBase.Subtypes,
                  ReachabilityBase.Arrays, ReachabilityBase.Timing],
         pagesonly=true,
         pages=["Home" => "index.md",
                "Library" => Any[
                                 #
                                 "Assertions" => "lib/Assertions.md",
                                 "Require" => "lib/Require.md",
                                 "Comparison" => "lib/Comparison.md",
                                 "Iteration" => "lib/Iteration.md",
                                 "Commutative" => "lib/Commutative.md",
                                 "Distribution" => "lib/Distribution.md",
                                 "Subtypes" => "lib/Subtypes.md",
                                 "Arrays" => "lib/Arrays.md",
                                 "Timing" => "lib/Timing.md",
                                 "CurrentPath" => "lib/CurrentPath.md",
                                 "Basetype" => "lib/Basetype.md"
                                 #
                                 ],
                "About" => "about.md"])

deploydocs(; repo="github.com/JuliaReach/ReachabilityBase.jl.git",
           push_preview=true)
