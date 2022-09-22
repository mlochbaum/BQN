*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/replicate.html).*

# Implementation of Indices and Replicate

The replicate family of functions contains not just primitives but powerful tools for implementing other functionality. The most important is converting [bits to indices](#booleans-to-indices): AVX-512 extensions implement this natively for various index sizes, and even with no SIMD support at all there are surprisingly fast table-based algorithms for it.

[General replication](#replicate) is more complex. The main enemy is branching but there are reasonable approaches.

Replicate by a [constant amount](#constant-replicate) (so `𝕨` is a single number) is not too common in itself, but it's notable because it can be the fastest way to implement outer products and arithmetic with prefix agreement.

| Normal                  | Boolean
|-------------------------|--------
| [Indices](#indices)     | [Where](#where)
| [Replicate](#replicate) | [Compress](#compress)
| ([by constant](#constant-replicate))

## Indices

Because it's somewhat simpler to discuss, we'll begin with the case `/𝕩` where `𝕩` has an integer type (the boolean case is discussed [below](#compress)). The obvious C loop works fine when the average of `𝕩` is large enough, because it auto-vectorizes to write many values at a time. When the average is smaller, this vectorization becomes less effective, but the main problem is branching, which takes many cycles for each element in `𝕩` if the values aren't predictable.

Indices is half of a [counting sort](sort.md#distribution-sorts): for sparse values, it's the slower half. Making it fast makes counting sort viable for much larger range-to-length ratios.

I know two main ways to tackle the branching problem. The elegant way is a three-pass method computing ``+`/⁼+`𝕩``. First, zero out the result array. Then traverse `𝕩` with a running sum index and increment the result value at that index at each step. Then sum the result. Somehow C compilers still don't know how to vectorize a prefix sum so you'll need to do it manually for best performance. Three passes is bad for caching so this method needs to be done in blocks to work well for large arrays. A slightly faster variation is that instead of incrementing you can write indices and take a max-scan `` ⌈` `` at the end.

The other way is to try to make the lengths less variable by rounding up. Later writes will overwrite earlier ones anyway. This gets messy. If the maximum value in `𝕩` is, say, 8, then generating indices is fairly fast: for each element, write 8 indices and then move the output pointer forward by that much. But if it's not bounded (and why would it be?) you'll end up with gaps. You could just accept some branching and write 8 more indices. You could also use a sparse *where* algorithm to get the indices of large elements in `𝕩`, and do the long writes for those either before or after the short ones. Overall I'm kind of skeptical of these approaches here. However, they are definitely a valid approach to constant Replicate, where `𝕨` is inherently bounded.

## Replicate

Most techniques for Indices can be adapted to Replicate, and the same considerations about branching apply.

An additional approach that becomes available is essentially `/⊸⊏`: apply Indices to portions of `𝕨` with the result in a temporary buffer, and select to produce the result. With small enough sections you can use 8-bit indices which can save time. As far as I can tell this method isn't an improvement for Replicate but is for the boolean case, Compress.

The running sum method needs to be modified slightly: instead of incrementing result values by one always, add the difference between the current value in `𝕩` and the previous one. It's possible to use xor instead of addition and subtraction but it shouldn't ever make much of a difference to performance. In the boolean case xor-ing trailing bits instead of single bits allows part of an xor-scan to be skipped; see [Expanding Bits in Shrinking Time](https://www.dyalog.com/blog/2018/06/expanding-bits-in-shrinking-time/).

### Constant replicate

The case where `𝕨` is constant is useful for outer products and leading-axis extension, where elements of one argument need to be repeated a few times. This connection is also discussed in [Expanding Bits](https://www.dyalog.com/blog/2018/06/expanding-bits-in-shrinking-time/).

The same approaches apply, but the branches in the branchless ones become a lot more predictable. So the obvious loops are now okay instead of bad even for small values. C compilers will generate decent code for constant small numbers as well, but I think they're still not as good as specialized code with shuffle, and can sometimes be beaten by scan-based methods.

## Booleans

The case where the replication amount is boolean is called Where or Compress based on older APL names for these functions before Replicate was extended to natural numbers.

When the amounts to replicate are natural numbers you're pretty much stuck going one at a time. With booleans there are huge advantages to doing bytes or larger units at once. This tends to lead to an outer replicate-like pattern where the relevant amount is the *sum* of a group of booleans, as well as an inner pattern based on the individual 0s and 1s.

### Booleans to indices

Indices (`/`) on a boolean `𝕩` of 256 or fewer bits can be made very fast on generic 64-bit hardware using a lookup table on 8 bits at a time. This algorithm can write past the end by up to 8 bytes (7 if trailing 0s are excluded), but never writes more than 256 bytes total. This means it's suitable for writing to an overallocated result array or a 256-byte buffer.

To generate indices, use a 256×8-byte lookup table that goes from bytes to 8-byte index lists, and either a popcount instruction or another lookup table to get the sum of each byte. For each byte in `𝕨`, get the corresponding indices, add an increment, and write them to the current index in the output. Then increase the output index by the byte's sum. The next indices will overlap the 8 bytes written, with the actual indices kept and junk values at the end overwritten. The increment added is an 8-byte value where each byte contains the current input index (always a multiple of 8); it can be added or bitwise or-ed with the lookup value.

Some other methods discussed by [Langdale](https://branchfree.org/2018/05/22/bits-to-indexes-in-bmi2-and-avx-512/) and [Lemire](https://lemire.me/blog/2018/03/08/iterating-over-set-bits-quickly-simd-edition/). I think very large lookup tables are not good for an interpreter because they cause too much cache pressure if used occasionally on smaller arrays. This rules out many of these strategies.

### Compress

Most of the methods listed below can be performed in place.

For booleans, use BMI2's PEXT (parallel bits extract) instruction, or an emulation of it. The result can be built recursively alongside the also-required popcount using masked shifts.

A good general method is to generate 1-byte indices into a buffer 256 at a time and select with those. There's a branchless method on one bit at a time which is occasionally better, but I don't think the improvement is enough to justify using it.

For 1- and 2-byte elements, a shuffle-based solution is a substantial improvement, if a vector shuffle is available. AVX-512 has compresses on several sizes built-in.

Odd-sized cells could be handled with an index buffer like small elements, using oversized writes and either overallocating or handling the last element specially.

For medium-sized cells copying involves partial writes and so is somewhat inefficient. It's better to split `𝕨` into groups of 1s in order to copy larger chunks from `𝕩` at once. So the algorithm repeatedly searches `𝕨` for the next 1, then the next 0, then copies the corresponding value from `𝕩` to the result. This might be better for small odd-sized cells as well; I haven't implemented the algorithm with oversized writes to compare.

The grouped algorithm, as well as a simpler sparse algorithm that just finds each 1 in `𝕨`, can also better for small elements. Whether to use these depends on the value of `+´𝕨` (sparse) or `+´»⊸<𝕨` (clumped). The checking is fast and these cases are common, but the general case is also fast enough that this is not a particularly high priority.

## Higher ranks

When replicating along the first axis only, additional axes only change the element size (these are the main reason why a large element method is given). Replicating along a later axis offers a few opportunities for improvement relative to replicating each cell individually.

Particularly for boolean `𝕨`, Select is usually faster than Replicate (a major exception is for a boolean `𝕩`). Simply replacing `/` with `/¨⊸⊏` (after checking conformability) could be an improvement. It's probably best to compute the result shape first to avoid doing any work if it's empty. Similarly, if early result axes are small then the overhead of separating out Indices might make it worse than just doing the small number of Replicates.

A technique when `𝕨` processed with one or more bytes at a time, and applies to many rows, is to repeat it up to an even number of bytes and combine rows of `𝕩` into longer virtual rows (the last one can be short). I think this only ends up being useful when `𝕩` is boolean.
