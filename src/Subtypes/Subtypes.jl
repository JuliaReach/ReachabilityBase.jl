"""
    Subtypes

This module provides the functionality to obtain the subtypes in a type
hierarchy.
"""
module Subtypes

import InteractiveUtils: subtypes

export subtypes

"""
    subtypes(atype, concrete::Bool)

Return the subtypes of a given abstract type.

### Input

- `atype`    -- an abstract type
- `concrete` -- if `true`, only return the concrete subtypes (leaves of the type
                hierarchy); otherwise return only the direct subtypes

### Output

A list with the subtypes of the abstract type `atype`, sorted alphabetically.

### Examples

Consider the `Integer` type. If we pass `concrete = false`, the implementation
imitates `Base.subtypes` without any arguments.

```jldoctest subtypes
julia> using ReachabilityBase.Subtypes

julia> subtypes(Integer, false)
3-element Vector{Any}:
 Bool
 Signed
 Unsigned
```

If we pass `concrete = true`, we obtain the concrete subtypes instead.

```jldoctest subtypes
julia> subtypes(Integer, true)
12-element Vector{Type}:
 BigInt
 Bool
 Int128
 Int16
 Int32
 Int64
 Int8
 UInt128
 UInt16
 UInt32
 UInt64
 UInt8
```
"""
function subtypes(atype, concrete::Bool)
    if !concrete
        return subtypes(atype)
    end

    subtypes_to_test = subtypes(atype)

    result = Vector{Type}()
    i = 0
    while i < length(subtypes_to_test)
        i += 1
        subtype = subtypes_to_test[i]
        new_subtypes = subtypes(subtype)
        if isempty(new_subtypes)
            # base type found
            push!(result, subtype)
        else
            # yet another atype layer
            append!(subtypes_to_test, new_subtypes)
        end
    end
    return sort(result, by=string)
end

end  # module
