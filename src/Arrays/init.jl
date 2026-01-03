@static if !isdefined(Base, :get_extension)
    using Requires
end

@static if !isdefined(Base, :get_extension)
    function __init__()
        @require StaticArrays = "90137ffa-7385-5640-81b9-e52037218182" include("../../ext/StaticArraysExt.jl")
    end
end
