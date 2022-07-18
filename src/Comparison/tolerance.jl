"""
    Tolerance{N<:Number}

Type that represents the tolerances for a given numeric type.

### Fields

- `rtol` -- relative tolerance
- `ztol` -- zero tolerance or absolute tolerance for comparison against zero
- `atol` -- absolute tolerance

### Notes

The type `Tolerance`, parametric in the numeric type `N`, is used to store default
values for numeric comparisons. It is mutable and setting the value of a field
affects the getter functions hence it can be used to globally fix the tolerance.

Default values are defined for the most commonly used numeric types, and for those
cases when other numeric types are needed one can extend the default values
as explained next.

The cases `Float64` and `Rational` are special in the sense that they are the most
commonly used types in applications. Getting and setting default tolerances
is achieved with the functions `_rtol` and `set_rtol` (and similarly for the other
tolerances); the implementation creates an instance of `Tolerance{Float64}`
(resp. `Tolerance{Rational}`) and sets some default values. Again since `Tolerance`
is mutable, setting a value is possible e.g. `set_rtol(Type{Float64}, ε)` for some
floating-point `ε`.

For all other cases, a dictionary mapping numeric types to instances of `Tolerance`
for that numeric type is used. For floating-point types, a default value has been
defined through `default_tolerance` as follows:

```julia
default_tolerance(N::Type{<:AbstractFloat}) = Tolerance(Base.rtoldefault(N), N(10) * sqrt(eps(N)), zero(N))
```
Hence to set a single tolerance (either `rtol`, `ztol` or `atol`) for a given
floating-point type, use the corresponding `set_rtol` function, while the values
which have not been set will be pulled from `default_tolerance`. If you would like
to define the three default values at once, or are computing with a non floating-point
numeric type, you can just extend `default_tolerance(N::Type{<:Number})`.
"""
mutable struct Tolerance{N<:Number}
    rtol::N
    ztol::N
    atol::N
end

default_tolerance(N::Type{<:Number}) = error("default tolerance for numeric type $N is not defined")
default_tolerance(N::Type{<:Rational}) = Tolerance(zero(N), zero(N), zero(N))
default_tolerance(N::Type{<:Integer}) = Tolerance(zero(N), zero(N), zero(N))
default_tolerance(N::Type{<:AbstractFloat}) = Tolerance(Base.rtoldefault(N), N(10) * sqrt(eps(N)), zero(N))

function set_tolerance(N, tolerance::Tolerance=default_tolerance(N))
    set_rtol(N, tolerance.rtol)
    set_ztol(N, tolerance.ztol)
    set_atol(N, tolerance.atol)
end

# global Float64 tolerances
const _TOL_F64 = default_tolerance(Float64)

_rtol(N::Type{Float64}) = _TOL_F64.rtol
_ztol(N::Type{Float64}) = _TOL_F64.ztol
_atol(N::Type{Float64}) = _TOL_F64.atol

set_rtol(N::Type{Float64}, ε::Float64) = _TOL_F64.rtol = ε
set_ztol(N::Type{Float64}, ε::Float64) = _TOL_F64.ztol = ε
set_atol(N::Type{Float64}, ε::Float64) = _TOL_F64.atol = ε

# global rational tolerances
const _TOL_RAT = default_tolerance(Rational)

_rtol(N::Type{<:Rational}) = _TOL_RAT.rtol
_ztol(N::Type{<:Rational}) = _TOL_RAT.ztol
_atol(N::Type{<:Rational}) = _TOL_RAT.atol

set_rtol(N::Type{<:Rational}, ε::Rational) = _TOL_RAT.rtol = ε
set_ztol(N::Type{<:Rational}, ε::Rational) = _TOL_RAT.ztol = ε
set_atol(N::Type{<:Rational}, ε::Rational) = _TOL_RAT.atol = ε

# global default tolerances for other numeric types
TOL_N = Dict{Type{<:Number}, Tolerance}()
_rtol(N::Type{<:Number}) = get!(TOL_N, N, default_tolerance(N)).rtol
_ztol(N::Type{<:Number}) = get!(TOL_N, N, default_tolerance(N)).ztol
_atol(N::Type{<:Number}) = get!(TOL_N, N, default_tolerance(N)).atol

set_rtol(N::Type{NT}, ε::NT) where {NT<:Number} = begin
    if N ∉ keys(TOL_N)
        TOL_N[N] = default_tolerance(N)
    end
    TOL_N[N].rtol = ε
end

set_ztol(N::Type{NT}, ε::NT) where {NT<:Number} = begin
    if N ∉ keys(TOL_N)
        TOL_N[N] = default_tolerance(N)
    end
    TOL_N[N].ztol = ε
end

set_atol(N::Type{NT}, ε::NT) where {NT<:Number} = begin
    if N ∉ keys(TOL_N)
        TOL_N[N] = default_tolerance(N)
    end
    TOL_N[N].atol = ε
end
