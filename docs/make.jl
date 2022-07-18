using Documenter, JuliaReachBase

DocMeta.setdocmeta!(JuliaReachBase, :DocTestSetup, :(using JuliaReachBase); recursive=true)

makedocs(
    sitename = "JuliaReachBase.jl",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true",
                             assets = ["assets/aligned.css"]),
    modules = [JuliaReachBase, JuliaReachBase.Assertions,
               JuliaReachBase.Require, JuliaReachBase.Comparison,
               JuliaReachBase.Iteration, JuliaReachBase.Commutative,
               JuliaReachBase.Distribution, JuliaReachBase.Subtypes,
               JuliaReachBase.Arrays],
    pages = [
        "Home" => "index.md",
        "Library" => Any[
            "Assertions" => "lib/Assertions.md",
            "Require" => "lib/Require.md",
            "Comparison" => "lib/Comparison.md",
            "Iteration" => "lib/Iteration.md",
            "Commutative" => "lib/Commutative.md",
            "Distribution" => "lib/Distribution.md",
            "Subtypes" => "lib/Subtypes.md",
            "Arrays" => "lib/Arrays.md",
        ],
        "About" => "about.md"
    ],
    doctest = false,
    strict = true
)

deploydocs(
    repo = "github.com/JuliaReach/JuliaReachBase.jl.git"
)
