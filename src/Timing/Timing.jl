"""
    Timing

This module provides timing-related functionality.
"""
module Timing

export print_timed

"""
    print_timed(stats::NamedTuple; [io]::IO=stdout)

Print the result of a `@timed` call.

### Input

- `stats` -- the result of a `@timed` call
- `io`    -- (optional; default: `stdout`) where the output is written (ignored
             prior to Julia v1.10)
"""
@static if VERSION >= v"1.5"
    function print_timed(stats::NamedTuple; io::IO=stdout)
        @static if VERSION >= v"1.10"
            # format:
            # time_print(io::IO, elapsedtime, bytes, gctime, allocs, compile_time, recompile_time, newline)
            return Base.time_print(io, stats.time * 1e9, stats.bytes, stats.gctime * 1e9,
                                   Base.gc_alloc_count(stats.gcstats), 0, 0, true)
        elseif VERSION >= v"1.8"
            # format:
            # time_print(elapsedtime, bytes, gctime, allocs, compile_time, recompile_time, newline)
            return Base.time_print(stats.time * 1e9, stats.bytes, stats.gctime * 1e9,
                                   Base.gc_alloc_count(stats.gcstats), 0, 0, true)
        elseif VERSION >= v"1.6"
            # format:
            # time_print(elapsedtime, bytes, gctime, allocs, compile_time, newline)
            return Base.time_print(stats.time * 1e9, stats.bytes, stats.gctime * 1e9,
                                   Base.gc_alloc_count(stats.gcstats), 0, true)
        else
            # format:
            # time_print(elapsedtime, bytes, gctime, allocs)
            return Base.time_print(stats.time * 1e9, stats.bytes, stats.gctime * 1e9,
                                   Base.gc_alloc_count(stats.gcstats))
        end
    end
else
    # prior to Julia v1.5, @timed returned a Tuple instead of a NamedTuple
    function print_timed(stats::Tuple; io::IO=stdout)
        # format:
        # time_print(elapsedtime, bytes, gctime, allocs)
        return Base.time_print(stats[2] * 1e9, stats[3], stats[4] * 1e9,
                               Base.gc_alloc_count(stats[5]))
    end
end

end  # module
