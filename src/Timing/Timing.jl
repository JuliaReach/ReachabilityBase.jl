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
    Base.time_print(stats.time * 1e9, stats.bytes, stats.gctime * 1e9,
                    Base.gc_alloc_count(stats.gcstats), 0, true)
end

end  # module
