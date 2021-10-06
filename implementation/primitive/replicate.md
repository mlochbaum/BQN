*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/replicate.html).*

# Implementation of Indices and Replicate

The replicate family of functions contains not just primitives but powerful tools for implementing other functionality. The most important is converting [bits to indices](#booleans-to-indices): AVX-512 extensions implement this natively for various index sizes, and even with no SIMD support at all there are surprisingly fast table-based algorithms for it.

[General replication](#replicate) is more complex. Branching will slow many useful cases down considerably when using the obvious solution. However, branch-free techniques introduce overhead for larger replication amounts. Hybridizing these seems to be the only way, but it's finicky.

Replicate by a [constant amount](#constant-replicate) (so `𝕨` is a single number) is not too common in itself, but it's notable because it can be the fastest way to implement outer products and arithmetic with prefix agreement.

## Indices

Branchless algorithms are fastest, but with unbounded values in `𝕨` a fully branchless algorithm is impossible because you can't write an arbitrary amount of memory without branching. So the best algorithms depend on bounding `𝕨`. Fortunately the most useful case is that `𝕨` is boolean.

### Booleans to indices

Indices (`/`) on a boolean `𝕩` of 256 or fewer bits can be made very fast on generic 64-bit hardware using a lookup table on 8 bits at a time. This algorithm can write past the end by up to 8 bytes (7 if trailing 0s are excluded), but never writes more than 256 bytes total. This means it's suitable for writing to an overallocated result array or a 256-byte buffer.

To generate indices, use a 256×8-byte lookup table that goes from bytes to 8-byte index lists, and either a popcount instruction or another lookup table to get the sum of each byte. For each byte in `𝕨`, get the corresponding indices, add an increment, and write them to the current index in the output. Then incease the output index by the byte's sum. The next indices will overlap the 8 bytes written, with the actual indices kept and junk values at the end overwritten. The increment added is an 8-byte value where each byte contains the current input index (always a multiple of 8); it can be added or bitwise or-ed with the lookup value.

Some other methods discussed by [Langdale](https://branchfree.org/2018/05/22/bits-to-indexes-in-bmi2-and-avx-512/) and [Lemire](https://lemire.me/blog/2018/03/08/iterating-over-set-bits-quickly-simd-edition/). I think very large lookup tables are not good for an interpreter because they cause too much cache pressure if used occasionally on smaller arrays. This rules out many of these strategies.

### Non-booleans to indices

If the maximum value in `𝕩` is, say, 8, then generating indices is fairly fast: for each element, write 8 indices and then move the output pointer forward by that much. This is much like the lookup table algorithm above, minus the lookup table. If the indices need to be larger than one byte, it's fine to expand them, and possibly add an offset, after generation (probably in chunks).

There are two ways I know to fill in the gaps that this method would leave with elements that are too large. First is to stop after such an element and fill remaining space branchfully (maybe with `memset`). This is maximally efficient if `𝕩` is dominated by large elements—particularly for 2-byte indices when it skips index expansion—but not good if there are a lot of elements near the threshold. Second, initialize the buffer with 0 and perform `` ⌈` `` afterwards, or other variations. This eliminates all but a fixed amount of branching, but it's a lot of overhead and I think unless a more sophisticated strategy arises it's best to stick with the first method.

Indices is half of a counting sort: for sparse values, it's the slower half. Making it fast makes counting sort viable for much larger range-to-length ratios.

## Replicate

For the most part, understanding Indices is the best way to implement Replicate quickly. But this is not the case if `𝕩` is boolean because then its elements are smaller than any useful index, and faster methods are available.

### Compress

Most of the methods listed below can be performed in place.

For booleans, use BMI2's PEXT (parallel bits extract) instruction, or an emulation of it. The result can be built recursively alongside the also-required popcount using masked shifts.

The generally best method for small elements seems to be to generate 1-byte indices into a buffer 256 at a time and select with those. There's a branchless method on one bit at a time which is occasionally better, but I don't think the improvement is enough to justify using it.

For 1- and 2-byte elements, a shuffle-based solution is a substantial improvement, if a vector shuffle is available. AVX-512 has compresses on several sizes built-in.

Odd-sized cells could be handled with an index buffer like small elements, using oversized writes and either overallocating or handling the last element specially.

For medium-sized cells copying involves partial writes and so is somewhat inefficient. It's better to split `𝕨` into groups of 1s in order to copy larger chunks from `𝕩` at once. So the algorithm repeatedly searches `𝕨` for the next 1, then the next 0, then copies the corresponding value from `𝕩` to the result. This might be better for small odd-sized cells as well; I haven't implemented the algorithm with oversized writes to compare.

The grouped algorithm, as well as a simpler sparse algorithm that just finds each 1 in `𝕨`, can also better for small elements. Whether to use these depends on the value of `+´𝕨` (sparse) or `+´»⊸<𝕨` (clumped). The checking is fast and these cases are common, but the general case is also fast enough that this is not a particularly high priority.

### Replicate

Like Compress I think the best algorithm is often to generate small indices in a buffer and then select. But this is inefficient when `𝕨` contains large values, so those need to be detected and handled. Very tricky.

#### Constant replicate

Useful for outer products and leading-axis extension. See [Expanding Bits in Shrinking Time](https://www.dyalog.com/blog/2018/06/expanding-bits-in-shrinking-time/) for the boolean case. C compilers will generate decent code for constant small numbers and variable large ones, but I think specialized code with shuffle would be better for small numbers.

### Higher ranks

When replicating along the first axis only, additional axes only change the element size (these are the main reason why a large element method is given). Replicating along a later axis offers a few opportunities for improvement relative to replicating each cell individually.

Particularly for boolean `𝕨`, Select is usually faster than Replicate (a major exception is for a boolean `𝕩`). Simply replacing `/` with `/¨⊸⊏` (after checking conformability) could be an improvement. It's probably best to compute the result shape first to avoid doing any work if it's empty. Similarly, if early result axes are small then the overhead of separating out Indices might make it worse than just doing the small number of Replicates.

A technique when `𝕨` processed with one or more bytes at a time, and applies to many rows, is to repeat it up to an even number of bytes and combine rows of `𝕩` into longer virtual rows (the last one can be short). I think this only ends up being useful when `𝕩` is boolean.
