*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/replicate.html).*

# Implementation of Indices and Replicate

The replicate family of functions contains not just primitives but powerful tools for implementing other functionality. Most important is the boolean case, which can be used to ignore unwanted values without branching. Replicate by a constant amount (so `𝕨` is a single number) is not too common in itself, but it's notable because it can be the fastest way to [implement](arithmetic.md#table-and-leading-axis) outer products and arithmetic with prefix agreement. Fast implementations can be much better than the obvious C code, particularly for the boolean case.

| Normal                  | Boolean
|-------------------------|--------
| [Indices](#indices)     | [Where](#booleans-to-indices)
| [Replicate](#replicate) | [Compress](#compress)
| ([by constant](#constant-replicate))

## Indices

Because it's somewhat simpler to discuss, we'll begin with the case `/𝕩` where `𝕩` has an integer type (the boolean case is discussed [below](#compress)). The obvious C loop works fine when the average of `𝕩` is large enough, because it auto-vectorizes to write many values at a time. When the average is smaller, this vectorization becomes less effective, but the main problem is branching, which takes many cycles for each element in `𝕩` if the values aren't predictable.

Indices is half of a [counting sort](sort.md#distribution-sorts): for sparse values, it's the slower half. Making it fast makes counting sort viable for much larger range-to-length ratios.

I know two main ways to tackle the branching problem. The elegant way is a three-pass method computing ``+`/⁼+`𝕩``. First, zero out the result array. Then traverse `𝕩` with a running sum index and increment the result value at that index at each step. Then sum the result. Somehow C compilers still don't know how to vectorize a prefix sum so you'll need to do it manually for best performance. Three passes is bad for caching so this method needs to be done in blocks to work well for large arrays. A slightly faster variation is that instead of incrementing you can write indices and take a max-scan `` ⌈` `` at the end.

The other way is to try to make the lengths less variable by rounding up. Later writes will overwrite earlier ones anyway. This gets messy. If the maximum value in `𝕩` is, say, 8, then generating indices is fairly fast: for each element, write 8 indices and then move the output pointer forward by that much. But if it's not bounded (and why would it be?) you'll end up with gaps. You could just accept some branching and write 8 more indices. You could also use a sparse *where* algorithm to get the indices of large elements in `𝕩`, and do the long writes for those either before or after the short ones. Overall I'm kind of skeptical of these approaches here. However, they are definitely valid for constant Replicate, where `𝕨` is inherently bounded.

## Replicate

Most techniques for Indices can be adapted to Replicate, and the same considerations about branching apply.

An additional approach that becomes available is essentially `/⊸⊏`: apply Indices to portions of `𝕨` with the result in a temporary buffer, and select to produce the result. With small enough sections you can use 8-bit indices which can save time. As far as I can tell this method isn't an improvement for Replicate but is for the boolean case, Compress.

The running sum method needs to be modified slightly: instead of incrementing result values by one always, add the difference between the current value in `𝕩` and the previous one. It's possible to use xor instead of addition and subtraction but it shouldn't ever make much of a difference to performance. In the boolean case xor-ing trailing bits instead of single bits allows part of an xor-scan to be skipped; see [Expanding Bits in Shrinking Time](https://www.dyalog.com/blog/2018/06/expanding-bits-in-shrinking-time/).

### Constant replicate

The case where `𝕨` is constant is useful for outer products and leading-axis extension ([this section](arithmetic.md#table-and-leading-axis)), where elements of one argument need to be repeated a few times. This connection is also discussed in [Expanding Bits](https://www.dyalog.com/blog/2018/06/expanding-bits-in-shrinking-time/).

The same approaches work, but the branches in the branchless ones become a lot more predictable. So the obvious loops are now okay instead of bad even for small values. C compilers will generate decent code for constant small numbers—better for powers of two, but still not optimal it seems?

For top performance, the result should be constructed from one shuffle per output, and some haggling with lanes for odd values in AVX. But this takes `𝕨` shuffle instructions, so handling all constants up to some bound is quadratic in code size (JIT compiling might help, but generating a lot of code is bad for short `𝕩`). CBQN has a complicated mix of AVX2 methods to get high peformance with tolerable code size. From fastest to slowest:

- Sizes 2 to 7 have dedicated shuffle code.
- Small composite sizes `𝕨=l×f`, where `f` has a dedicated shuffle, are split into `l/f/𝕩`.
- Other small sizes use a function that always reads 1 vector and writes 4 per iteration, using shuffle vectors from a table to generate them. This requires tail handling and uses some tricks to pack the tables to a reasonable size.
- Sizes where one element fills multiple vectors write broadcasted vectors, overlapping the last two writes to avoid any tail handling. There are unrolled loops for less than 4 vectors.

## Booleans

The case with a boolean replication amount is called Where or Compress, based on APL names for these functions from before Replicate was extended to natural numbers.

The standard branchless strategy is to write each result value regardless of whether it should actually be included, then increment the result pointer only if it is. Careful as this writes an element past the end in many situations. However, other methods described here are much faster and should be used when there's more implementation time available. All the good methods process multiple bits at once, giving a two-level model: an outer replicate-like pattern that increments by the *sum* of a group of booleans, as well as an inner pattern based on the individual 0s and 1s.

There are x86 instructions for Compress on booleans in BMI2 and other types in AVX-512. If these aren't available then boolean Compress has to be implemented with some shift-based emulation, and otherwise lookup tables seem to be best for Compress and Where (for completeness, boolean-result Where with can have at most two output indices so it hardly matters how fast it is).

### Compress instructions

Some x86 extensions have instructions for Compress: in BMI2, pext is compress on 64 bit booleans, and there are compress instructions for 32- and 64-bit types in AVX-512 F, and 8- and 16-bit in the later AVX-512 VBMI2. The AVX-512 compresses can be used for Where as well by applying to a vector of indices.

For the time being it seems the compress-store variants should never be used, particularly on Zen4 (search vpcompressd [here](https://www.mersenneforum.org/showthread.php?p=614191)). Instead, use in-register compress, then store with a mask. You have to compute the boolean argument's popcount anyway, so the mask for popcount `p` is `(1<<p)-1`, except that the `p==64` case needs to be worked around to avoid shifting by more than a register width.

For pext, you do have to figure out how to write the output given that it comes in partial words. Best I have is to accumulate into a result word and write when it fills up. This creates some branch prediction overhead at density below about 1/8 so I wonder if there's some kind of semi-sparse method that can address that.

Langdale also [describes](https://branchfree.org/2018/05/22/bits-to-indexes-in-bmi2-and-avx-512/) another way to get 1-byte indices using only AVX-512 F and BMI2. I haven't looked into this in detail.

### Table-based Where and Compress

Without hardware support, nothing beats a lookup table as far as I can tell. The two limits on size are the output unit (for example 16 bytes with SSE) and at most 8 bits at a time—with 16 the table's just too big. A single 2KB table mapping each byte to indices (for example 10001100 to 0x070302) can be shared by all the 8-bit cases of Where and Compress. For some compress cases a larger non-shared table might be a touch faster, but this doesn't seem like a good tradeoff for an interpreter. [Lemire explains](https://lemire.me/blog/2018/03/08/iterating-over-set-bits-quickly-simd-edition/) how to do it with an 8KB table and powturbo mentions the 2KB version in a comment.

To sum a byte, popcount is best if you have it and a dedicated table also works. Another way is to store the count minus one in the top byte of the index table, since that byte is only used by 0xff where it has value 7. Can be slower than a separate table but it doesn't take up cache space.

Here's a concrete description for 1-byte Where, the only case that works at full speed without any vector instructions. For each byte, get the corresponding indices, add an increment, and write them to the current index in the output. Then increase the output index by the byte's sum. The next indices will overlap the 8 bytes written, with the actual indices kept and junk values at the end overwritten. The increment added is an 8-byte value where each byte contains the current input index (always a multiple of 8); it can be added or bitwise or-ed with the lookup value.

For 2-byte and 4-byte Where, those bytes need to be expanded with top bits, which is easy enough with vector instructions. The top bits are always constant within one iteration, so they can be updated at between loop iterations.

For Compress you need a shuffle instruction. For 1-byte types an SSSE3 or NEON shuffle applies directly; for 2-byte you'll have to interleave `2×i` with `1+2×i` given indices `i` if you don't want to make a table that precomputes that. But it writes 16 bytes at a time instead of 8 so it'll actually be closer to saturating memory bandwidth. For larger types, when you can only write 4 elements you may as well do the precomputed table as it's only 16 entries. And AVX2's vpermd (permutevar8x32) is essential for 4- and 8-byte values because it goes across lanes. Here's how many elements at a time we handle in CBQN and whether we get them from the large shared table or a small custom one.

| Bytes | SSSE3 or NEON        | AVX2
|-------|----------------------|-----
| 1     | 8, large             | -
| 2     | 8, large+interleave  | -
| 4     | 4, small             | 8, large+convert
| 8     |                      | 4, small

To handle 4 bits we unroll by 2 to process a byte of `𝕨` at a time. Instead of incrementing by the popcount of each half sequentially, increment the result pointer by the count of the entire byte at the end of an iteration. The second half uses the result pointer plus the count of the first half, but discards this pointer.

All of these methods can write past the end of the result (and an AVX2 masked write didn't have good performance when I tried it). So there needs to be some way to prevent this from sowing destruction. Overallocating works, and one particular case is that generating 1-byte indices for temporary use can always be done safely in a 256-byte buffer. Since an overallocation in CBQN is permanently wasted space, what we did is to move the result pointer to a small stack-allocated buffer when there's no longer space in the result for a full write. After finishing in that buffer, we copy the values to the real result with one or two vector writes that are appropriately masked.

Finally, when you don't have a shuffle instruction, the best method I know is just to generate indices in blocks using a table and select with those one at a time.

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

A technique when `𝕨` is processed with one or more bytes at a time, and applies to many rows, is to repeat it up to an even number of bytes and combine rows of `𝕩` into longer virtual rows (the last one can be short). I think this only ends up being useful when `𝕩` is boolean.
