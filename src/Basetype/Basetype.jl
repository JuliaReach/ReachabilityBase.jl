"""
    Basetype

This module provides the functionality to obtain the base type of a type or object.
"""
module Basetype

export basetype

"""
    basetype(T::Type)

Return the base type of the given type (i.e., without type parameters).

### Input

- `T` -- type

### Output

The base type of `T`.

```jldoctest
julia> using ReachabilityBase.Basetype

julia> basetype(Float64)
Float64

julia> basetype(Rational{Int})
Rational
```
"""
basetype(T::Type) = Base.typename(T).wrapper

"""
    basetype(x)

Return the base type of the given object (i.e., without type parameters).

### Input

- `x` -- object

### Output

The base type of `x`.

### Examples

```jldoctest
julia> using ReachabilityBase.Basetype

julia> basetype(1.0)
Float64

julia> basetype(1//1)
Rational
```
"""
basetype(x) = basetype(typeof(x))

end  # module
