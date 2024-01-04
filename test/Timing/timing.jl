using ReachabilityBase.Timing

res = @timed sleep(0.001)

# write to stdout by default
print_timed(res)

# write to IOBuffer (only available since Julia v1.10)
@static if VERSION >= v"1.10"
    io = IOBuffer()
    print_timed(res; io=io)
    s = String(take!(io))
    pattern = r".* seconds \(.* allocations.*"
    @test occursin(pattern, s)
end
