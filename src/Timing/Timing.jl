"""
    Timing

This module provides timing-related functionality.
"""
module Timing

export print_timed

"""
    print_timed(stats::NamedTuple)

Print the result of a `@timed` call.

### Input

- `stats` -- the result of a `@timed` call
"""
function print_timed(stats::NamedTuple)
    @static if VERSION >= v"1.8"
        Base.time_print(stats.time * 1e9, stats.bytes, stats.gctime * 1e9,
                        Base.gc_alloc_count(stats.gcstats), 0, 0, true)
    else
        # did not have argument `recompile_time` yet
        Base.time_print(stats.time * 1e9, stats.bytes, stats.gctime * 1e9,
                        Base.gc_alloc_count(stats.gcstats), 0, true)
    end
end

end  # module
