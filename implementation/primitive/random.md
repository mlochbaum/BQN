*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/random.html).*

# Implementation of random stuff

Not a primitive, but CBQN's `•MakeRand` initializes a random number generator that has some built-in utilities. For clarity we'll call a result of this initialization `rand` in the text below.

## Random number generation

CBQN is currently using wyrand, part of the [wyhash](https://github.com/wangyi-fudan/wyhash) library. It's extremely fast, passes the expected test suites, and no one's raised any concerns about it yet (but it's very new). It uses only 64 bits of state and doesn't have extra features like jump ahead.

Other choices are [xoshiro++](https://prng.di.unimi.it/) and [PCG](https://www.pcg-random.org/). The authors of these algorithms (co-author for xoshiro) hate each other very much and have spent quite some time slinging mud at each other. As far as I can tell they both have the normal small bias in favor of their own algorithms but are wildly unfair towards the other side, choosing misleading examples and inflating minor issues. I think both generators are good but find the case for xoshiro a little more convincing, and I think it's done better in third-party benchmarks.

## Simple random sample

A [simple random sample](https://en.wikipedia.org/wiki/Simple_random_sample) from a set is a subset with a specified size, chosen so that each subset of that size has equal probability. `rand.Deal` gets a sample of size `𝕨` from the set `↕𝕩` with elements in a uniformly random order, and `rand.Subset` does the same but sorts the elements.

`Deal` uses a [Knuth shuffle](https://en.wikipedia.org/wiki/Fisher%E2%80%93Yates_shuffle), stopping after the first `𝕨` elements have been shuffled, as the algorithm won't touch them again. Usually it creates `↕𝕩` explicitly for this purpose, but if `𝕨` is very small then initializing it is too slow. In this case we initialize `↕𝕨`, but use a "hash" table with an identity hash—the numbers are already random—for `𝕨↓↕𝕩`. The default is that every value in the table is equal to its key, so that only entries where a swap has happened need to be stored. The hash table is the same design as for self-search functions, with open addressing and linear probing.

`Subset` uses [Floyd's method](https://math.stackexchange.com/questions/178690/whats-the-proof-of-correctness-for-robert-floyds-algorithm-for-selecting-a-sin), which is sort of a modification of shuffling where only the selected elements need to be stored, not what they were swapped with. This requires a lookup structure that can be updated efficiently and output all elements in sorted order. The choices are a bitset for large `𝕨` and another not-really-hash table for small `𝕨`. The table uses a right shift—that is, division by a power of two—as a hash so that hashing preserves the ordering, and inserts like an insertion sort: any larger entries are pushed forward. Really this is an online sorting algorithm, that works because we know the input distribution is well-behaved (it degrades to quadratic performance only in very unlikely cases). When `𝕨>𝕩÷2`, we always use a bitset, but select `𝕩-𝕨` elements and invert the selection.
