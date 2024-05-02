"""
    CurrentPath

This module provides the macro `@current_path` to conveniently update a path.
This is useful for loading files in combination with the `Literate` package.
"""
module CurrentPath

export @current_path

"""
   @current_path([prefix], filename)

Return the absolute path to file `filename` relative to the executing script.

### Input

- `prefix`   -- path prefix (optional; ignored by default)
- `filename` -- filename

### Output

The string corresponding to the absolute path of the file.

### Notes

This macro is equivalent to `joinpath(@__DIR__, filename)`. It is useful in
scripts to load data files relative to the location of the script without having
to change the directory of the Julia session. For instance, suppose that the
folder `/home/models/my_model` contains the script `my_model.jl`, and suppose
that the data file `my_data.dat` located in the same directory is required to be
loaded by `my_model.jl`. Suppose further that the working directory is
`/home/julia/` and we ran the script as
`julia -e "include("../models/my_model/my_model.jl")"`. In the model file
`/home/models/my_model/my_model.jl` we write:

```julia
d = open(@current_path("my_model", "my_data.dat"))
# do something with d
```

In this example, the macro `@current_path("my_model", "my_data.dat")` evaluates
to the string `/home/models/my_model/my_data.dat`. If the script `my_model.jl`
only had `d = open("my_data.dat")`, without `@current_path`, this command would
fail, as Julia would have looked for `my_data.dat` in the *working* directory,
resulting in an error that the file `/home/julia/my_data.dat` is not found.

The real convenience enters when including the script `my_model` in combination
with the `Literate` package. In this case, we need to prepend the folder
`my_model` for `prefix`; hence we redefine the definition to:

```julia
macro current_path(prefix::String, filename::String)
    return joinpath("home", "models", prefix, filename)
end
```
"""
macro current_path end

macro current_path(filename::String)
    __source__.file === nothing && return nothing
    _dirname = dirname(String(__source__.file))
    dir = isempty(_dirname) ? pwd() : abspath(_dirname)
    return joinpath(dir, filename)
end

macro current_path(prefix::String, filename::String)
    __source__.file === nothing && return nothing
    _dirname = dirname(String(__source__.file))
    dir = isempty(_dirname) ? pwd() : abspath(_dirname)
    return joinpath(dir, filename)
end

end  # module
