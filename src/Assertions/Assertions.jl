"""
    Assertions

This module provides a quick way to deactivate and reactivate Julia's `@assert`
checks. This can be useful for performance-critical runs.

### Notes

The implementation is based on the idea from
[here](https://discourse.julialang.org/t/defensive-programming-assert/8383/11).
"""
module Assertions

export activate_assertions,
       deactivate_assertions

# override Base.@assert
macro assert(exs...)
    quote
        if $__module__.are_assertions_enabled()
            Base.@assert $(map(esc, exs)...)
        end
    end
end

"""
    activate_assertions(m::Module)

Activate `@assert` checks for the given module.

### Input

- `m` -- module
"""
function activate_assertions(m::Module)
    m.eval(:(are_assertions_enabled() = true))
    return nothing
end

"""
    deactivate_assertions(m::Module)

Deactivate `@assert` checks for the given module.

### Input

- `m` -- module
"""
function deactivate_assertions(m::Module)
    m.eval(:(are_assertions_enabled() = false))
    return nothing
end

end  # module
