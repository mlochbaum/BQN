*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/fold.html).*

# Implementation of Fold and Scan

Folds and scans with some arithmetic primitives like `+`, `⌈`, and boolean `≠` are staples of array programming. Fortunately these cases are also suitable for SIMD implementation. There is also the minor note that it's worth optimizing folds with `⊣` or `⊢` that give the first and last element (or cell), and the scan `` ⊣` `` broadcasts the first cell to the entire array, which has some uses like ``⊣`⊸≡`` to test if all cells match.

My talk "Implementing Reduction" ([video](https://dyalog.tv/Dyalog19/?v=TqmpSP8Knvg), [slides](https://www.dyalog.com/uploads/conference/dyalog19/presentations/D09_Implementing_Reduction.zip)) quickly covers some ideas about folding, particularly on high-rank arrays. The slides have illustrations of some extra algorithms not discussed in the talk.

## Associative arithmetic

The arithmetic operations `+×` on integers, and `⌈⌊` on all types, are associative and commutative (and for `•math.Sum`, float addition may be considered commutative for optimization). This allows for folds and scans to be reordered in a way that's suitable for SIMD evaluation, where without some insight into the operand function they would be inherently sequential. Also, `-´` can be performed by negating every other value then summing, and monadic `¬´` is `{(¬2|≠𝕩)+-´𝕩}`.

For these operands, a fold can be done simply by combining two vector registers at a time, with a final pairwise reduction at the end. An overflowing operation like `+` needs to be performed at double width (or possibly 32-bit for 8-bit values), and moved to a full-width accumulator once that's exhausted.

The technique for a fast prefix sum is described in Singeli's [min-filter tutorial](https://github.com/mlochbaum/Singeli/blob/master/doc/minfilter.md) beginning at "we have some vector scan code already". There's also a treatment [here](https://en.algorithmica.org/hpc/algorithms/prefix/), but the blocking method seems overcomplicated given that incorporating the carry after summing a register is enough to get rid of dependency chains.

## Booleans

Boolean folds `≠=+-` can be optimized with associative methods. `≠` is the associative xor function, and `=´𝕩` is `(2|≠𝕩)=≠´𝕩`. For `+´` there's a dedicated popcount instruction, but also [Faster Population Counts Using AVX2 Instructions](https://arxiv.org/abs/1611.07612) are possible. This method is well-known enough that clang produces the AVX2 code given a loop that sums popcounts. For `-´`, flip every other bit beforehand and subtract half the length, that is, `(+´𝕩≠2|↕≠𝕩)-⌊2÷˜≠𝕩`. Another case that's been studied is `+˝` on an array with cells of 8, 16, 32, or 64 bits, called [positional popcount](https://github.com/mklarqvist/positional-popcount).

Other folds `∧∨<>≤≥` can be shortcut: they depend only on the first instance of a 0 (for `∧<>`) or 1 (for `∨≤≥`). Specifically we have the following on a boolean list, omitting `⊑` in the right column:

| Fold | Equivalent
|:----:|----------:
| `∧´` | `¬0∊𝕩`
| `∨´` | `1∊𝕩`
| `≤´` | `(1-˜≠𝕩)≠𝕩⊐0`
| `<´` | `(1-˜≠𝕩)=𝕩⊐1`
| `>´` |  `2\|𝕩⊐0`
| `≥´` | `¬2\|𝕩⊐1`

Boolean scans are more varied. For `∨`, the result switches from all `0` to all `1` after the first `1`, and the other way around for `∧`. For `≠`, the associative optimization gives a word-at-a-time algorithm with power-of-two shifts, and other possibilities with architecture support are [discussed below](#xor-scan). The scan `` <` `` turns off every other 1 in groups of 1s. It's used in simdjson for backslash escaping, and they [describe in detail](https://github.com/simdjson/simdjson/blob/ac78c62/src/generic/stage1/json_escape_scanner.h#L96) a method that uses subtraction for carrying. And `` >` `` flips to all 0 at the first bit if it's a 0 or the *second* 1 bit otherwise. `` ≤` `` is ``<`⌾¬``, and `` ≥` `` is ``>`⌾¬``.

### Xor scan

The scan `` ≠` `` has the ordinary implementation using power-of-two shifts, covered in Hacker's Delight section 5-2, "Parity". Broadcast the carry to the entire word with a signed shift and xor into the next word after scanning it.

If available, carry-less multiply (clmul) can also be used to scan a word, by multiplying by the all-1s word, a trick explained [here](https://branchfree.org/2019/03/06/code-fragment-finding-quote-pairs-with-carry-less-multiply-pclmulqdq). The 128-bit result has an inclusive scan in the low 64 bits and a reverse exclusive scan in the high 64 bits (the top bit is always 0). This is useful because xor-ing high with low gives a word of all carry bits. And the clmul method also works for high-rank `` ≠` `` if the row length `l` is a divisor of 64, by choosing a mask where every `l`-th bit is set. Then the high-low trick is much more important because shifting doesn't give a valid carry! For strides of 8 or more, this method might not be faster than AVX2 using element-level operations, but hey, it's free.

In AVX-512, there's a clmul instruction on four 64-bit words, albeit in an inconvenient configuration. There's also the GFNI instruction gf2p8affineqb, which can be used for an inclusive or exclusive xor-scan on groups of 8 bits (or 4, or 2). There's [a way](https://twitter.com/InstLatX64/status/1148247870887419904) to combine this with a single 64-bit clmul to do a full 512-bit scan, although it's not all that much faster than doing single clmul instructions.

## High-rank arrays

Insert on large cells can be done simply by combining a cell at a time. However, it's fastest to split things up in columns, so that the accumulators can be kept in vector registers instead of written to memory. For small cells, the virtual rows technique described in my reduction talk means that most of the work can be performed as a larger-cell reduction. The speed of the final combination matters when there aren't a large number of rows, and doing it quickly can be tricky.

For long cells, scan on a high-rank array can be done by initializing the first cell and then calling a single vector-vector arithmetic function. For cell length (or stride) `m`, the function will write to `dst+m` where `dst` is a pointer to the result, and get its arguments from `dst` and `src+m` where `src` points to `𝕩`. If the function works in order on `k≤m` elements at a time, then the `k` elements it reads from `dst` have already been written, so this gives the correct result.

If the cell size is a power of two and fits in a vector register, then the parallel strategy for scans on lists still works (the operation that combines cells is still associative and commutative, it's just wider). For odd widths there's some trouble with alignment.

### Boolean fold-cells

Boolean folds on short rows can be implemented as a segmented scan, or windowed reduction, followed by extracting the appropriate bit from each row. The extraction is the hard part. While it's a special case of [bit uninterleaving](take.md#bit-interleaving-and-uninterleaving), it's better to implement it with a more specialized method. [Here's a post](https://orlp.net/blog/extracting-depositing-bits/) on how you might do this extraction on a single word. Believe it or not, for multiple words even the pext-based method is beaten soundly by some generic code! Okay, for even widths it requires a little cheating with SSE2 auto-vectorization. For an odd width, say `f`, there's a complicated but powerful method relying on the fact that in the first `f` input words, the row boundaries cover each position within a word exactly once (this follows from the Chinese remainder theorem, since an odd number is relatively prime to each power of two). So the idea is to mask out these bits and combine them into a single word, then un-permute to put them in the right order in the result. There are a lot of complications, so it's described in [its own section](#the-modular-bit-permutation).

## The modular bit permutation

This section describes how to perform and use the permutation sending the bit at position `n|f×i` to position `i` within each group of `n←2⋆k` bits, where `f` is odd. It's done by a series of swaps, conditionally exchanging pairs of bits separated by a power of two, starting at `n÷2` and ending at 2. Each swap is a self-inverse, so doing them in the opposite order results in the opposite permutation taking position `i` to `n|f×i`.

The direction we focus on here can extract one bit from every `f`, so it's useful for boolean fold-cells and select-cells picking out a single column. In the other direction, it can spread bits out in the same way, which can be used for take-cells but is most powerful in [Replicate by constant](replicate.md#constant-replicate) since this also applies to broadcasting as used in Table and leading axis extension.

### Decomposing into swaps

First we'll prove that a modular permutation does actually decompose into swap operations. Here's the intuitive case: consider the permutation where index `i` has value `16|5×i` (meaning, that's the original index of the bit that ends up at `i`). At positions `i` and `8+i`, `i<8`, we have `16|5×i` and `16|5×(8+i)` or `16|8+5×i`. These values are different, but both are congruent to `5×i` (mod 8), so one of them is `8|5×i` and the other is `8+8|5×i`. These are the values at positions `i` and `8+i` in the permutation that applies `8|5×i` within each byte, so to extend that permutation from size 8 to size 16 what we need to do is swap these bits if `16|5×i` isn't equal to `8|5×i`.

To handle it more rigorously, suppose we have performed our permutation of size `h` so the value at `i` is `(i - h|i) + h|f×i` and want to extend this to size `l ← 2×h`. Define `B ← {(l|𝕩) - h|𝕩}`, noting that `h|B𝕩` is always 0. We will show that the value to be moved to `i` appears at `j ← (i - B i) + (B f×i)`. Since `h|j` is `h|i` after dropping `B` terms, we have:

       (j - h|j) + h|f×j
    ←→ (j - h|i) + h|f×i
    ←→ (((i - B i) + (B f×i)) - h|i) + h|f×i
    ←→ (i - ((B i)+h|i)) + ((B f×i)+h|f×i)
    ←→ (i - l|i) + l|f×i

as desired. Now, what does this extending mapping do? In C terminology `B i` is the bit mask `i & h`, so `j` is `i` with this bit replaced with the one from `f×i`. With a lot of algebra it's possible to prove that our transformation is a self-inverse: to give a sketch, `B j` is `B f×i` which means `j - B j` is `i - B i`, and `B f×j` works out to `B i` using the facts that `l|B𝕩` and `l|f×B𝕩` are `B𝕩` and `l|2×B𝕩` is 0 (with `𝕩=f×i` for that last one). Then `(j - B j) + (B f×j)` is `(i - B i) + (B i)`, giving back `i`! We can conclude that it either swaps positions `i` and `i ^ h`, where `^` is bitwise xor, or leaves them alone.

The example below shows the steps for the modular permutation with factor 3 on size 16. The first one is the identity: this is always true because `f` is odd, so `1=2|f` and `2|f×i` is `2|i`.

        f ← 3
        Step ← { h𝕊i:
          l ← 2×h
          B ← {(l|𝕩) - h|𝕩}
          (i - B i) + B f×i
        }

        > s16 ← 1‿2‿4‿8 Step¨ <↕16
        > ⊏˜` s16  # Successively apply steps
        16 | f × ↕16  # It matches!

Applying the steps backwards gives the inverse, where index 1 goes to position 3, 2 to 6, and so on. This is also the original direction with factor 11, which is the inverse of 3 modulo 16.

        ⊏´ s16

        16 | 11 × ↕16

        16 | 3 × 11

### Evaluating swaps

So we know that step that widens permutation units from `h` to `2×h` swaps bit `i` with bit `i ^ h` whenever `i & h` isn't equal to `(f×i) & h`. There are various ways to compute this given a bitmask of which values to swap, which depends on `f`. The data needed is just the bits for `i` in `↕h`, that is, `h≤(2×h)|f×↕h`, as the remaining bits `h↓↕2×h` are the same. I know of two good ways to apply it, and a shortcut:

- Using xor, `d = (x ^ x<<h) & hi`, `x ^ (d | d>>h)` with high-bits mask `hi`.
- With a swap-halves function, `(x &~ m) | (swap(x) & m)` with full mask `m`.
- Also, any permutation on each byte can be done with two shuffle instructions.

A swap-halves function can be a rotate instruction on elements of width `2×h`, or can be done with a shuffle on elements of width `h` or smaller.

The total data to permute width `l` is 2+4+…`l÷2` bits, or `l-2`. It can be precomputed for each odd factor `f<l` (which covers larger factors too, since `f+k×l` permutes as `f`). Then it just needs to be read from a table and unpacked into individual mask vectors. These mask vectors could also be computed directly with multiplication and some bit shuffling; I'm not sure how this would compare in speed.

### Collecting bits

The bits to be passed into the modular permutation need to be collected from the argument (possibly after some processing), one bit out of each `f`. Or, in the other direction, they need to be distributed to the result. This can be done by generating a bitmask of the required position in each register. Then an argument register is and-ed with the bitmask and or-ed into a running total. But generating the bitmask is slow. For example, with row size under 64, updating the mask `m` for the next word is `m>>r | m<<l` for appropriately-chosen shifts `l` and `r`: this is a lot of instructions at each step! For small factors, an unrolled loop with saved masks works; for larger factors, it gets to be a lot of code, and eventually you'll run out of registers.

Since one modular permutation is needed for every `f` expanded registers, a better approach is to structure it as a loop of length `f` and unroll this loop. An unrolled iteration handling 4 adjacent registers works with a mask that combines the selected bits from all those registers, and at the end of the iteration it's advanced by 4 steps—this is the same operation as advancing once, just with different shifts. So that contains iterations 0|1|2|3, then 4|5|6|7, and so on. In addition to this "horizontal" mask we need 4 pre-computed "vertical" masks to distinguish within an iteration: one mask combines register 0 of each iteration 0|4|8|…, another does 1|5|9|…, and so on. So the intersection of one horizontal and one vertical mask correctly handles a particular register. The unrolled iteration applies the vertical mask to each of the 4 registers, and the horizontal one to them as a whole. So:
- When extracting, add `h & ((i0&v0) | ... | (i3&v3))` to the running total.
- When depositing, set `c = h & p`, and use `c&v0`, ... `c&v3`.
where `h` is the horizontal mask and `v0`…`v3` are vertical ones, `i0`…`i3` are input registers, and `p` is a combined output resulting from a permutation.

For the partial iteration at the end, the combined mask stops working! Take `f←15` for example. The last iteration starts at register 12, and the mask will combine iterations 12, 13, and 14, but also 15, which is iteration 0 of the _next_ length-`f` loop. This means `h&v0` contains iterations 0 and 12, so it will incorrectly pick out extra bits. The last iteration also has a variable length, so a dedicated loop with a single-register mask is a fine approach.

### Handling even factors

When the size of a row is a multiple of two, it's no longer relatively prime to the register size. In general, a given size needs to be split into a power of two times an odd number, and some other method is needed to handle powers to two. Fortunately SIMD architectures usually have some useful instructions for this; generic code may not be so fast.

It's possible to apply these methods in completely separate calls. For example, `28/𝕩` is `4/7/𝕩`, and `∧˝˘𝕩` on rows of length 28 can be implemented as reductions of length 4 then 7, that is, `∧˝˘∧˝⎉1 ∘‿7‿4⥊𝕩`. This is great with 4 and larger powers of two if they have a solid SIMD implementation; place the power of two on the larger side.

A multiple of 2 or maybe 4 can be fused in as well. To avoid permuting any extra registers, it should be placed just before the permutation (for a fold; after for expansion). That is, condense every `2×f` bits from `f` registers of the argument, and again from the next `f` registers. Then pack every other bit of these two registers together. This gives a register where each half needs to be permuted, which can be done with the normal permutation code either by skipping the last iteration or zeroing out the mask for it.
