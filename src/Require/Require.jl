"""
    Require

This module provides convenience functionality to be used in combination with
the [`Requires.jl`](https://github.com/JuliaPackaging/Requires.jl) package.
"""
module Require

export require, @required

"""
    require(mod, packages; [fun_name]::String="", [explanation]::String="")

Check for one or more optional packages and print an error message if any of
them is not loaded.

### Input

- `mod`         -- module where the package should be loaded; use `@__MODULE__`
- `packages`    -- symbol or list of symbols (the package name(s))
- `fun_name`    -- (optional; default: `""`) name of the function that requires
                   the package
- `explanation` -- (optional; default: `""`) additional explanation in the error
                   message
- `require_all` -- (optional; default: `true`) flag to require all `packages`

### Output

If all packages are loaded, this function has no effect.
Otherwise, it prints an error message.

### Notes

The argument `mod` should typically be `@__MODULE__`, but since this is a macro,
it has to be inserted by the caller.

The argument `require_all` can be set to `false` to require only one of the
given packages. This is useful if multiple packages provide a functionality and
any of them is fine.

This function uses `@assert` and hence loses its ability to print an error
message if assertions are deactivated (see the `Assertions` module).

See also the [`@required`](@ref) macro for a more concise syntax.
"""
function require end

# version for one package
function require(mod, package::Symbol; fun_name::String="",
                 explanation::String="", require_all::Bool=true)
    @assert isdefined(mod, package) "package '$package' not loaded" *
                                    (fun_name == "" ? "" :
                                     " (it is required for executing `$fun_name`" *
                                     (explanation == "" ? "" : " " * explanation) * ")")
end

# version for multiple packages
function require(mod, packages::AbstractVector{Symbol}; fun_name::String="",
                 explanation::String="", require_all::Bool=true)
    if require_all
        @assert all(isdefined(mod, package) for package in packages) "some " *
                                                                     "package from '$packages' not loaded" *
                                                                     (fun_name == "" ? "" :
                                                                      " (they are all required for executing `$fun_name`" *
                                                                      (explanation == "" ? "" :
                                                                       " " * explanation) * ")")
    else
        @assert any(isdefined(mod, package) for package in packages) "no " *
                                                                     "package from '$packages' loaded" *
                                                                     (fun_name == "" ? "" :
                                                                      " (at least one is required for executing `$fun_name`" *
                                                                      (explanation == "" ? "" :
                                                                       " " * explanation) * ")")
    end
end

"""
    @required(package)

Check for an optional package and print an error message if any of them is not loaded.

### Input

- `package` -- package name

### Output

If the package is loaded, this macro has no effect. Otherwise, it prints an error message.

This macro uses `@assert` and hence loses its ability to print an error message if assertions are
deactivated (see the `Assertions` module).

See also the [`require`](@ref) function for a more customizable version.
"""
macro required(package)
    p = Meta.quot(Symbol(package))
    return esc(:(@assert isdefined(@__MODULE__, $p) "package `$($p)` not loaded"))
end

end  # module
