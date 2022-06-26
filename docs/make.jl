using Documenter, JuliaReachBase

makedocs(
    sitename = "JuliaReachBase.jl",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true",
                             assets = ["assets/aligned.css"]),
    pages = [
        "Home" => "index.md",
        "About" => "about.md"
    ],
    doctest = true,
    strict = true
)

deploydocs(
    repo = "github.com/JuliaReach/JuliaReachBase.jl.git"
)
