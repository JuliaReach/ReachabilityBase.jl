"""
    Commutative

This module provides the convenience macro `@commutative` to automatically
duplicate a method with the first and second arguments swapped.
"""
module Commutative

using ExprTools: splitdef, combinedef

export @commutative

"""
    @commutative(f)

Macro to declare that a given method is commutative, thus generating the
original method and a new method where the first and second arguments are
swapped.

### Input

- `f` -- method definition

### Output

A quoted expression containing the method definitions.
"""
macro commutative(f)
    # split the expression of the method definition
    def = splitdef(f)
    defswap = deepcopy(def)

    # swap arguments 1 and 2
    aux = defswap[:args][1]
    defswap[:args][1] = defswap[:args][2]
    defswap[:args][2] = aux

    _f = combinedef(defswap)
    return quote
        Core.@__doc__ $(esc(f))
        $(esc(_f))
    end
end

end  # module
