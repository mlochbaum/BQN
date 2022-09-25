*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/replicate.html).*

# Implementation of Indices and Replicate

The replicate family of functions contains not just primitives but powerful tools for implementing other functionality. Most important is the boolean case, which can be used to ignore unwanted values without branching. Replicate by a constant amount (so `𝕨` is a single number) is not too common in itself, but it's notable because it can be the fastest way to implement outer products and arithmetic with prefix agreement. Fast implementations can be much better than the obvious C code, particularly for the boolean case.

| Normal                  | Boolean
|-------------------------|--------
| [Indices](#indices)     | [Where](#booleans-to-indices)
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

The case with a boolean replication amount is called Where or Compress, based on APL names for these functions from before Replicate was extended to natural numbers.

When the amounts to replicate are natural numbers you're pretty much stuck going one at a time. With booleans there are huge advantages to doing bytes or larger units at once. This tends to lead to a two-level model: an outer replicate-like pattern where the relevant amount is the *sum* of a group of booleans, as well as an inner pattern based on the individual 0s and 1s.

The standard branchless strategy is to write each result value regardless of whether it should actually be included, then increment the result pointer only if it is. This works best if done in an unrolled loop handling 8 bits at a time. But it's still not competitive with other methods using hardware extensions or lookup tables, so these should be used when there's more implementation time available.

### Booleans to indices

Generally, Compress implementations can be adapted to implement Where, and this tends to be the best way to do it. In the other direction, a Where implementation on 1 or 2 bytes can be used to implement Where or Compress on larger types. To do this, traverse the boolean argument in blocks; for each, get the indices and either add the current offset to them (Where) or use them to select from the argument (Compress). This is close to but not necessarily the fastest method for 4-byte and 8-byte outputs. It's a bargain given the low amount of effort required though.

Indices from 256 or fewer bits is fastest with hardware extensions as discussed in the next section. But it can be done pretty fast on generic 64-bit hardware using a lookup table on 8 bits at a time. This algorithm can write past the end by up to 8 bytes (7 if trailing 0s are excluded), but never writes more than 256 bytes total. This means it's suitable for writing to an overallocated result array or a 256-byte buffer.

To generate indices, use a 256×8-byte lookup table that goes from bytes to 8-byte index lists, and either a popcount instruction or another lookup table to get the sum of each byte. For each byte in `𝕨`, get the corresponding indices, add an increment, and write them to the current index in the output. Then increase the output index by the byte's sum. The next indices will overlap the 8 bytes written, with the actual indices kept and junk values at the end overwritten. The increment added is an 8-byte value where each byte contains the current input index (always a multiple of 8); it can be added or bitwise or-ed with the lookup value.

Some other methods discussed by [Langdale](https://branchfree.org/2018/05/22/bits-to-indexes-in-bmi2-and-avx-512/) and [Lemire](https://lemire.me/blog/2018/03/08/iterating-over-set-bits-quickly-simd-edition/). I think very large lookup tables are not good for an interpreter because they cause too much cache pressure if used occasionally on smaller arrays. This rules out many of these strategies.

### Compress

Branchless writes and blocked indices are possible methods as discussed above. The ones below use extended instruction sets. Note that older AMD processors do BMI2 operations very slowly. Compress can often be performed in-place.

For booleans, use BMI2's PEXT (parallel bits extract) instruction, or an emulation of it. The result can be built recursively alongside the also-required popcount using masked shifts.

AVX-512 has compresses on all sizes up to 8 bytes, split across several sub-extensions.

For 1- and 2-byte elements and no AVX-512 support, there are two methods with similar performance on Intel hardware. Both work with one byte at a time from the boolean argument. One uses BMI2, first using PDEP (1-byte case) or a lookup table (2-byte case) to expand each bit to the result element size, then applies PEXT to that and a word from the compressed argument. The other is to use a 256-entry lookup table where each entry is 8 indices for a vector shuffle instruction, a total of 2KB of data. Shuffling may also be competitive for 4-byte elements but it's no longer automatically the best.

### Sparse compress

When `𝕨` is sparse (or `𝕩` for Indices), that is, has a small sum relative to its length, there are methods that lower the per-input cost by doing more work for each output.

The best known sparse method is to work on a full word of bits. At each step, find the first index with count-trailing-zeros, and then remove that bit with a bitwise and, `w &= w-1` in C. However, this method has a loop whose length is the number of 1s in the word, a variable. CPUs are very good at predicting this length in benchmarks, but in practice it's likely to be less predictable! In CBQN it's only used for densities below 1/128, one bit every two words.

For marginal cases, I found a branchless algorithm that can work on blocks of up to `2⋆11` elements. The idea is to split each word into a few segments, and write the bits and relative offset for each segment to the appropriate position in the result of a zeroed buffer. Then traverse the buffer, maintaining bits and a cumulative offset. At each step, the index is obtained from those bits with count-trailing-zeros just as in the branching algorithm. The bits will all be removed exactly when the next segment is reached, so new values from the buffer can be incorporated just by adding them.

### Grouped compress

The sparse method can also be adapted to find groups of 1s instead of individual 1s, by searching for the first 1 and then the first 0 after that. This is useful if `𝕨` changes value rarely, that is, if `+´»⊸<𝕨` is small. Computing this value can be expensive so it's best to compute the threshold first, then update it in blocks and stop if it exceeds the threshold.

For copying medium-sized cells with memcpy, all the branching here is pretty cheap relative to the actual operation, and it may as well be used all the time. This may not be true for smaller cells copied with overwriting, but I haven't implemented overwriting so I'm not sure.

## Higher ranks

When replicating along the first axis only, additional axes only change the element size (these are the main reason why a large element method is given). Replicating along a later axis offers a few opportunities for improvement relative to replicating each cell individually.

Particularly for boolean `𝕨`, Select is usually faster than Replicate (a major exception is for a boolean `𝕩`). Simply replacing `/` with `/¨⊸⊏` (after checking conformability) could be an improvement. It's probably best to compute the result shape first to avoid doing any work if it's empty. Similarly, if early result axes are small then the overhead of separating out Indices might make it worse than just doing the small number of Replicates.

A technique when `𝕨` processed with one or more bytes at a time, and applies to many rows, is to repeat it up to an even number of bytes and combine rows of `𝕩` into longer virtual rows (the last one can be short). I think this only ends up being useful when `𝕩` is boolean.
