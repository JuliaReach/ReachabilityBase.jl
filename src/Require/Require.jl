"""
    Require

This module provides convenience functionality to be used in combination with
the [`Requires.jl`](https://github.com/JuliaPackaging/Requires.jl) package.
"""
module Require

export require

"""
    require([mod]=Main, packages; [fun_name]::String="", [explanation]::String="")

Check for one or more optional packages and print an error message if any of
them is not loaded.

### Input

- `mod`         -- (optional; default: `Main`) module where the package should
                   be loaded
- `packages`    -- symbol or list of symbols (the package name(s))
- `fun_name`    -- (optional; default: `""`) name of the function that requires
                   the package
- `explanation` -- (optional; default: `""`) additional explanation in the error
                   message

### Output

If all packages are loaded, this function has no effect.
Otherwise it prints an error message.

### Algorithm

This function uses `@assert` and hence loses its ability to print an error
message if assertions are deactivated (see the `Assertions` module).
"""
function require end

# default: use Main module
function require(package; fun_name::String="", explanation::String="")
    require(Main, package; fun_name=fun_name, explanation=explanation)
end

# version for one package
function require(mod, package::Symbol; fun_name::String="",
                 explanation::String="")
    @assert isdefined(mod, package) "package '$package' not loaded" *
        (fun_name == "" ? "" :
            " (it is required for executing `$fun_name`" *
            (explanation == "" ? "" : " " * explanation) * ")")
end

# version for multiple packages
function require(mod, packages::AbstractVector{Symbol}; fun_name::String="",
                 explanation::String="")
    @assert all(isdefined(mod, package) for package in packages) "no " *
        "package from '$packages' loaded" *
        (fun_name == "" ? "" :
            " (one of them is required for executing `$fun_name`" *
            (explanation == "" ? "" : " " * explanation) * ")")
end

end  # module
