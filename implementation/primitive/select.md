*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/select.html).*

# Implementation of Select

[Select](../../doc/select.md) is just a CPU load, right? Well, there is a bounds check first, but besides that, memory operations are slow. Yes, even if you use SIMD gathers—these get rid of some minor instruction dispatching overhead but they're still executed as a bunch of separate memory requests. This means that, while there's no replacement for select in the general case, there are many sub-cases that can be handled faster in other ways.

The two important kinds of instructions for selection are the aforementioned _gather_ instructions, which select multiple values from memory given a vector of indices, and _shuffle_ instructions, which implement selection on a vector of indices and a vector of values. Shuffles don't touch memory and are many times faster.

## Bounds checking

Before doing any indexing you need to be sure that the indices are valid. And in a language like BQN that supports negative indices, they need to be wrapped around or otherwise accounted for. The obvious way to do this is to check before each load instruction, which is fairly expensive with scalar loads but much better with SIMD checking/wrapping and gathers.

An alternative approach is to do vectorized checking in blocks on `𝕨` before selecting with that block. In this case, instead of simply testing whether all the indices fit, it's best to compute the minimum and maximum of each block. At one min and one max instruction per vector of indices this is probably faster than comparison in most cases, and it allows for additional optimizations:
- If the minimum is at least 0, there are no negative indices, so wrapping isn't needed. And if the maximum is less than 0, there are no _non_-negative indices, and a global offset can be used instead of wrapping.
- If the minimum and maximum are equal, all indices are the same, so that cell of `𝕩` can be copied without checking `𝕨` again.
- More generally, if the minimum and maximum are close, an appropriate small-range method can be used.

After the range is found, another pass can wrap indices if needed by computing `𝕨+n×𝕨<0` with `n←≠𝕩`, which vectorizes easily. Unfortunately, the range after wrapping is unknown: 0 and -1 map to 0 and n-1 which spans the entire range, and aren't ruled out by any range that requires wrapping. Mixed-sign indices should be fairly rare, so it's probably fine to ignore small-range optimization in this case, but there could be another range check built into the wrapping code. When the range is small but crosses 0, it's also possible to copy the end of `𝕩` and then the beginning, and select from this with an offset but no wrapping.

Extracting the max and min from an accumulator vector and dispatching to a special case has a non-negligible constant cost, so range checking does need to have a block size of many vector registers. This means the instructions mostly won't slip into time spent waiting on memory as they would with interleaved checks. The loss is less bad for smaller index types as SIMD range checking is faster, and I found that with generic code relying on auto-vectorization, separating the range check was better for 1-byte indices, about the same for 2-byte, and slower for larger indices. With any form of SIMD selection, incorporating a range check and wrap with selection will be faster because it makes better use of available throughput, so choosing to range-test first sacrifices raw speed for better special-case handling.

## Small-range selection

When `𝕩` is small, or when values from `𝕨` fit into a small range and thus select from a small slice of `𝕩`, selection with vector shuffles can be much faster than memory-based selection. The relevant instructions in x86 are the SSSE3 shuffle and its AVX2 extension, which work on 1-byte values, and AVX2 vpermd (intrinsic permutevar8x32) on 4-byte values. NEON is cleaner and has vtbl instructions of various widths, but always works on 1-byte indices and values.

Vector shuffles are often effective even when the selection doesn't fit into a single register (or lane). Multiple shuffles can be combined with a blend or some bit-bashing emulation. Another trick applies to data wider than indices such as selecting 2-byte values with 1-byte indices: the indices could be expanded by zipping `2×i` with `1+2×i`, but a better method might be to _unzip_ the values `𝕩` before starting, and do the selection by shuffling both halves and them zipping those together.

The 1-byte shuffle can be used to do a 1-_bit_ lookup from a table of up to 256 bits packed into vector registers. To look up a bit, select the appropriate byte from the table with the top 5 bits—if only 4 are used, a single shuffle instruction is enough, and for all 5 a blend of two shuffles is needed. Then use the bottom 3 bits to get a mask from another table where entry `i` is `1<<i`. And the mask with the byte to select the right bit, and pack into bits with a greater-than-0 comparison and movemask.

SIMD selection can be relevant to [lookup tables](search.md#lookup-tables) for search functions, particularly bit selection for Member of.

## Large-range selection

When the selected elements don't fit in registers (and some other special case like sortedness doesn't apply…), you'll need a memory access per element. With AVX2 or ARM SVE there's a modest improvement for using gather instructions, except with Intel CPUs prior to Skylake (2015) where that's actually slower. If the supported types are wider than the ones you want to use, you can widen the indices, or select a larger element type and then narrow the elements.

For larger `𝕩` arrays, random accesses can run out of cache space and become very expensive. As with most cache-incoherent operations, [radix partitioning](search.md#partitioning) can be used to improve cache utilization. Partially sort the indices, perform selection, undo the sorting. However, the decision of whether to use it is much more difficult than for hash-based searches or shuffling, where accesses are random by design. Selection indices are quite likely to have some sort of locality that allows cache lines to be reused naturally. If this is the case, ordinary selection will be pretty fast, and partitioning is a lot of overhead to add to it. The only way I can think of to really test whether partitioning is needed is to sample some indices and find the number of unique cache lines represented. Figuring out how to choose the sample and interpret the statistics is tricky, and varying cache sizes and other effects will mean that you'll always get some edge cases wrong. But the downside of running a cache-incoherent selection naively is quite bad, so it's worth a try?

Booleans are messy. Probably gather, some vector shifts (or emulation with shuffle), and movemask to pack bits is the way to go if the instruction set supports it. If the selected array isn't too big relative to the number of selections, it can be expanded to 1-byte values as an easy way to avoid lots of bit manipulation.

## Sorted indices

When the indices `𝕨` in `𝕨⊏𝕩` are [sorted](flagsort.md), slices from `𝕨` often fit into a small range. A particular possibility of interest is ``(+`bool)⊏𝕩``, where any slice of `𝕨` selects from an equal or smaller (fewer elements) slice of `𝕩`. Another useful pattern is ``(⌈`↕∘≠⊸×bool)⊏𝕩``, characterized by each result cell matching either the corresponding argument cell or previous result cell.

Taking any vector register out of `𝕨`, several cases might apply:
- The indices are sparse, so the first one is far from the others. Scalar selection is needed.
- Only the first few indices fall within a vector of `𝕩`. An option is to use a shuffle for these indices, then start over with a vector beginning at the one after.
- All indices fit into a vector of `𝕩`. They can be handled with a shuffle, and possibly the `𝕩` values could be retained for the next iteration.
- All indices are the same. Copying the selected element of `𝕩` is still a shuffle, but maybe the same vector works for more indices too? Hitting the speed of memset if there are many equal indices would be nice.
- Indices are consecutive, always increasing by exactly 1. The corresponding elements of `𝕩` can be copied as a unit.

In the second case (partial shuffle), the number of handled indices can be found by comparing the index vector to the maximum allowed index (for example, first index plus 15), then using count-trailing-zeros on the resulting mask.

Choosing between these cases at every step would have high branching costs if the indices aren't very predictable. One way to keep branching costs down is to force each method to do some minimum amount of work if chosen. A hybrid of sparse and dense selection might search for places where dense selection applies by comparing a vector of indices, plus 15, to the vector shifted by 4. It can do sparse selection up to this point; when it hits the dense selection, getting to handle 4 indices quickly would outweigh the cost of a branch (if the number used is tuned properly and not something I made up).

A method with less branching is to take statistics in blocks. These might be used either as a hint, choosing between strategies that are fully general but adapted to different cases, or a proof, enabling a strategy that has some requirement. Some strategies that might be chosen this way are:

- Scalar selection.
- Take a vector of indices, do as many as possible (it's at least 1), repeat until finished.
- A hybrid dense/sparse method like the one just discussed.
- Full vector selection, requiring indices 16 apart to differ by ≤16 in the 1-byte case.
- memset, requiring indices to all be the same.
- memcpy, requiring indices to be consecutive.

So an example of a complex statistic is to test, for each index, whether the difference from the one before is at most 1 (so, the selection is equivalent to ``(+`bool)⊏𝕩`` for some `bool`). If this holds, the full vector selection method—pick one vector from `𝕨` and one from `𝕩` beginning at the first index, apply a shuffle, write, move to the next vector—can be used. If additionally the range is equal to the length, the differences all have to be 1, so that memcpy can be used.

The index range is a very easy statistic to compute, as it's just first minus last. In fact it's possible to pick the chunk size from a target range, using a binary search (which can stop at vector alignment or coarser since there's no need to find an exact element boundary, although if the range is 1 it's better to find it so the leftovers don't cause the range of the _next_ section to be greater than 1). Since 1-byte indices are usually faster to work with, one approach might be to test if the next 64 indices (untested number for concreteness only) fit into a range of 256, handling them sparsely if not. If they are small-range then split into a few cases: range of 1, range 16, and range 256. In each case, keep increasing the chunk size by 64 as long as it stays in this range, or up to some maximum length chosen to avoid cache issues. Then in the range-1 case, copy that one element, in the range-16 case pick a single vector from `𝕩` and shuffle it, and in the range-256 case copy the indices to a 1-byte buffer while taking statistics and choose what to do based on those. It's some sort of telescoping fractal around the sparse/dense boundary. The possibilities just keep going.

## Odd cell sizes

When `𝕩` has rank greater than 1, `𝕨⊏𝕩` may select cells of any size, so one load instruction no longer does it. For long cells a general method like memcpy (or a bit-granularity version for booleans) is fine, so the concern is for short cells.

Overlapping in some way is fastest. One way is to round the cell size up, so that reading from `𝕩` gets some additional elements and they'll be written to the result but overwritten by later iterations. Of course this requires writing result cells in order, and will also need some mechanism to make sure the last cell doesn't break anything. A possibly slower but tidier way is to have copy functions that carry over a specific number of bytes (regardless of underlying element type). For an odd size, let's say 11 bytes, it can copy the first 8 bytes and the last 8 bytes, overlapping internally. Since the same scheme works for any length from 9 to 16 bytes, there can be a single copy function that works on this range and takes an offset, keeping the total number of functions reasonable.

### Odd boolean cells

For booleans it's no longer possible to simply copy from one pointer to another. A bit offset needs to be specified, and, more importantly, writing needs to handle partial bytes, blending the written bits with some that are already there. Again there's the possibility of going in order so that only the beginning and not the end of the result cell needs to be handled; partial results could be kept in a buffer in order to write full words to the result. Currently in CBQN we have a slow generic method, but avoid using it if `𝕩` is short enough by widening cells of `𝕩` to a power of two or multiple of 64, selecting, and narrowing back to the original width (see [bit interleaving and uninterleaving](take.md#bit-interleaving-and-uninterleaving)). This can't be used if `𝕨` is very short relative to `𝕩`, because it would do work on all of `𝕩` just to select a few elements.

An alternative method for small boolean cells is to select directly from `𝕩` but with a widened result, that is, over-read from each cell of `𝕩`. Then at the end the result can be narrowed exactly as in the widen-select-narrow pattern. This goes into a temporary array, which can be over-allocated so there's no concern about the length of the last cell written. However, note that there are alignment concerns in reading from `𝕩`: if the selection is done with 64-bit reads, it only works if every cell fits entirely in some word, which means that the cell width must be at most 60, and not equal to 59. Otherwise there will be some cells that span 9 bytes, and the selection will lose bits.

## Select-cells

Applying the same selection to each cell of an array, that is, `inds⊸⊏˘ arr`, can be optimized similarly to small-range selection and is relevant to other array manipulation such as multidimensional Take, Drop, Replicate, and Rotate. For example `r⊸/˘ 𝕩` may be best implemented as `(/r)⊸⊏˘ 𝕩`. It can also be applied to operations like `⍉⎉2` on multiple trailing axes, by treating them as a single axis and constructing indices appropriately.

Before getting to SIMD, one general way to reduce overhead if `inds` is small is to convert to a single selection, `(inds+⌜˜↕⊸×´≢arr)⊏⥊arr` for rank-2 `arr` with adjustments possible for other ranks. This is effectively a specialization of the axis merging mentioned under [multi-axis-selection](#multi-axis-selection).

For vector selection, the basic idea is to optimize if each argument and result "row" fits in a vector, and apply shuffles to each row, over-reading argument and overlapping result rows as necessary. If multiple rows fit in a vector, the indices can be extended accordingly, adding another copy plus the cell size of `𝕩`, another plus twice the cell size, and so on. The number of rows that can be handled at once might be constrained by either the argument row size or result row size (number of indices) as these two lengths can be independent. There's no obvious way to extend the selection size to a full vector, as (assuming argument and result cell sizes are the same for simplicity) a given aligned vector in the result may take values not just from the corresponding argument vector, but from adjacent ones as well. Also note that if the number of result values written at a time is less than half a vector, then an implementation that does partial writes at the end will need to be able to do more than one of them.

Multi-vector selection can also be used of course, increasing the argument row size that can be handled. Because `𝕨` will be reused, it can be preprocessed to make this more effective. If the selection instruction returns 0 for some indices (x86 shuffles do this if the top bit is set), `𝕨` can be split so that the selection step looks like the bitwise or of multiple selections, `sel(a,x)|sel(b,x)|…`. There's an index vector for each index range `(k×16) ≤ i < (k+1)×16` which is set to `i-k×16` for indices `i` that fall in the range and 128 for other indices. If zeroing selection isn't available, other possibilities with blend or xor aren't too much worse. Increasing the result row size is much simpler, just do multiple selections on the same set of argument vectors. For `x` input vectors and `y` results you need `x×y` index vectors, so vector selection quickly becomes impractical as sizes increase.

However, arbitrarily large result rows can be handled by constructing the result in columns, where each corresponds to a manageable slice of `𝕨`. Working column-wise is effectively a way to avoid re-loading and initializing parts of `𝕨`. It could also be applied to more complicated cases found by analyzing parts of `𝕨`, such as the methods for [sorted indices](#sorted-indices). It's even possible it could be a slight improvement when used for scalar lookups, because only one load from `𝕨` is needed per column.

The same pre-processing idea that works for multi-vector selection also speeds up selecting booleans. The masks from the bottom 3 bits, and shifted-down copy of the other bits, can be precomputed so that the selection step is to shuffle, bitwise-and with the masks, compare to 0, and pack to bit-boolean output.

## Multi-axis selection

To perform a selection where multiple axes are manipulated, trailing axes need to be handled with low per-cell overhead. Likely the best generic approach is to combine indices for lower axes arithmetically, by multiplying each by its stride in `𝕩` and adding with `+⌜` (or some minor variation). This can be done starting from the bottom until the total size of the combined axes is large enough that time is spent mostly in selection itself instead of overhead around the selection loop (although I'm not sure how to handle the case where the last set of indices incorporated this way is huge—should it be handled in sections somehow?). Then selection consists of some sort of multi-dimensional loop over leading axes, which doesn't need to be fast, with an inner selection using the list of indices and an offset pointer into `𝕩`. This low/high axis division is similar to that suggested for [multi-axis Transpose](transpose.md#arbitrary-reordering).

If higher axes are expanded by the selection, so that there are more cells of some rank in the result than in `𝕩`, it can be better to first apply the selection on the lower axes to give an intermediate array, and then do the selection on the upper axes, which will copy cells into the final result. Similarly, if higher axes have repeated indices, so that the unique cells of `𝕩` used are smaller than the final result, a possible optimization is to split each repetitive leading index list `i` into unique indices `⍷i` and where they appear in the result `⊐i`, with `⍷i` being used in the first step and `⊐i` in the second.

The base case with a list of indices might be replaced by any number of special cases after analyzing the lower indices:
- memcpy, for consecutive indices
- offset+difference representation for arithmetic progressions
- Take, for an unchanged axis above consecutive indices
- any [select-cells](#select-cells) method, for an unchanged axis above anything
- Compress, for sorted unique indices
An implementation like this could encompass Replicate, Select, Take, Drop, Rotate, and maybe Transpose! When faced with arguments specifying a complicated multi-dimensional operation, these primitives could be reduced to different entry points to a big selection engine. This engine could take an array and a list of transformations to apply to each axis. It could then put each transformation in a preferred form (analyzing indices and replicate arguments in particular), apply optimizations like merging unchanged axes, choose and initialize a bottom-level kernel, and apply it while looping over upper levels. Optimizations can be gated on the number of times an axis will be used, that is, the combined size of the result axes above it. For example, checking an index array to see if it's an arithmetic progression is unlikely to succeed, but if it's used a million times it's worth trying.
