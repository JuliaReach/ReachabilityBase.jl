using ReachabilityBase.Distribution

# reseeding with random seed
rng = GLOBAL_RNG
seed = rand(1:10000)
reseed(rng, seed)
n1 = rand(Int)
reseed(rng, seed)
n2 = rand(Int)
@test n1 == n2
