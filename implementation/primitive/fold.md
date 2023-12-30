*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/fold.html).*

# Implementation of Fold and Scan

Folds and scans with some arithmetic primitives like `+`, `⌈`, and boolean `≠` are staples of array programming. Fortunately these cases are also suitable for SIMD implementation. There is also the minor note that it's worth optimizing folds with `⊣` or `⊢` that give the first and last element (or cell), and the scan `` ⊣` `` broadcasts the first cell to the entire array, which has some uses like ``⊣`⊸≢`` to test if all cells match.

My talk "Implementing Reduction" ([video](https://dyalog.tv/Dyalog19/?v=TqmpSP8Knvg), [slides](https://www.dyalog.com/uploads/conference/dyalog19/presentations/D09_Implementing_Reduction.zip)) quickly covers some ideas about folding, particularly on high-rank arrays. The slides have illustrations of some extra algorithms not discussed in the talk.

## Associative arithmetic

The arithmetic operations `+×` on integers, and `⌈⌊` on all types, are associative and commutative (and for `•math.Sum`, float addition may be considered commutative for optimization). This allows for folds and scans to be reordered in a way that's suitable for SIMD evaluation, where without some insight into the operand function they would be inherently sequential. Also, `-´` can be performed by negating every other value then summing, and monadic `¬´` is `{(¬2|≠𝕩)+-´𝕩}`.

For these operands, a fold can be done simply by combining two vector registers at a time, with a final pairwise reduction at the end. An overflowing operation like `+` needs to be performed at double width (or possibly 32-bit for 8-bit values), and moved to a full-width accumulator once that's exhausted.

The technique for a fast prefix sum is described in Singeli's [min-filter tutorial](https://github.com/mlochbaum/Singeli/blob/master/doc/minfilter.md) beginning at "we have some vector scan code already". There's also a treatment [here](https://en.algorithmica.org/hpc/algorithms/prefix/), but the blocking method seems overcomplicated given that incorporating the carry after summing a register is enough to get rid of dependency chains.

## Booleans

Boolean folds `≠=+-` can be optimized with associative methods. `≠` is the associative xor function, and `=´𝕩` is `(2|≠𝕩)=≠´𝕩`. For `+´` there's a dedicated popcount instruction, but also [Faster Population Counts Using AVX2 Instructions](https://arxiv.org/abs/1611.07612) are possible. This method is well-known enough that clang produces the AVX2 code given a loop that sums popcounts. For `-´`, flip every other bit beforehand and subtract half the length, that is, `(+´𝕩≠2|↕≠𝕩)-⌊2÷˜≠𝕩`. Another case that's been studied is `+˝` on an array with cells of 8, 16, 32, or 64 bits, called [positional popcount](https://github.com/mklarqvist/positional-popcount).

Other folds `∧∨<>≤≥` can be shortcut: they depend only on the first instance of a 0 (for `∧<>`) or 1 (for `∨≤≥`). Specifically we have the following on a boolean list, omitting `⊑` on the right:

| Fold | Equivalent
|:----:|----------:
| `∧´` | `¬0∊𝕩`
| `∨´` | `1∊𝕩`
| `≤´` | `(1-˜≠𝕩)≠𝕩⊐0`
| `<´` | `(1-˜≠𝕩)=𝕩⊐1`
| `>´` | ` 2\|𝕩⊐0`
| `≥´` | `¬2\|𝕩⊐1`

Boolean scans are more varied. For `∨`, the result switches from all `0` to all `1` after the first `1`, and the other way around for `∧`. For `≠`, the associative optimization gives a word-at-a-time algorithm with power-of-two shifts, and other possibilities with architecture support are [discussed below](#xor-scan). The scan `` <` `` turns off every other 1 in groups of 1s. It's used in simdjson for backslash escaping, and they [describe in detail](https://github.com/simdjson/simdjson/blob/ac78c62/src/generic/stage1/json_escape_scanner.h#L96) a method that uses subtraction for carrying. And `` >` `` flips to all 0 at the first bit if it's a 0 or the *second* 1 bit otherwise. `` ≤` `` is ``<`⌾¬``, and `` ≥` `` is ``>`⌾¬``.

### Xor scan

The scan `` ≠` `` has the ordinary implementation using power-of-two shifts, covered in Hacker’s Delight section 5-2, "Parity". Broadcast the carry to the entire word with a signed shift and xor into the next word after scanning it.

If available, carry-less multiply (clmul) can also be used to scan a word, by multiplying by the all-1s word, a trick explained [here](https://branchfree.org/2019/03/06/code-fragment-finding-quote-pairs-with-carry-less-multiply-pclmulqdq). The 128-bit result has an inclusive scan in the low 64 bits and a reverse exclusive scan in the high 64 bits (the top bit is always 0). This is useful because xor-ing high with low gives a word of all carry bits. And the clmul method also works for high-rank `` ≠` `` if the row length `l` is a divisor of 64, by choosing a mask where every `l`-th bit is set. Then the high-low trick is much more important because shifting doesn't gives a valid carry! For strides of 8 or more, this method might not be faster than AVX2 using element-level operations, but hey, it's free.

In AVX-512, there's a clmul instruction on four 64-bit words, albeit in an inconvenient configuration. There's also the GFNI instruction gf2p8affineqb, which can be used for an inclusive or exclusive xor-scan on groups of 8 bits (or 4, or 2). There's [a way](https://twitter.com/InstLatX64/status/1148247870887419904) to combine this with a single 64-bit clmul to do a full 512-bit scan, although it's not all that much faster than doing single clmul instructions.

## High-rank arrays

Insert on large cells can be done simply by combining a cell at a time. However, it's fastest to split things up in columns, so that the accumulators can be kept in vector registers instead of written to memory. For small cells, the virtual rows technique described in my reduction talk means that most of the work can be performed as a larger-cell reduction. However, doing the final combination quickly can be tricky.

For long cells, scan on a high-rank array can be done by initializing the first cell and then calling a single vector-vector arithmetic function. For cell length (or stride) `m`, the function will write to `dst+m` where `dst` is a pointer to the result, and get its arguments from `dst` and `src+m` where `src` points to `𝕩`. If the function works in order on `k≤m` elements at a time, then the `k` elements it reads from `dst` have already been written, so this gives the correct result.

If the cell size is a power of two and fits in a vector register, then the parallel strategy for scans on lists still works (the operation that combines cells is still associative and commutative, it's just wider). For odd widths there's some trouble with alignment.
