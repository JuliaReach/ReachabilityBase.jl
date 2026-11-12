"""
    isidentical(x::TX, y::TY) where {TX,TY}

Comparison of objects that always fails if the objects have different types

### Input

- `x` -- first argument
- `y` -- second argument

### Output

`true` iff `x == y` and `x` and `y` have the same type.
"""
function isidentical(x::TX, y::TY) where {TX,TY}
    return TX == TY && x == y
end
