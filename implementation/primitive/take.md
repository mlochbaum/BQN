*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/take.html).*

# Implementation of Take and Drop

The function [Take](../../doc/take.md) on multidimensional arrays can be an important utility for working with arrays that have an odd cell shape. For example, a sorting algorithm on 25-bit cells would be very hard to write, but it's fast to expand each cell to 32 bits, sort, and trim back to 25 bits.

## Bit interleaving and uninterleaving

When the argument and result cells fit in a machine word, Take performs an operation I call bit interleaving if the width increases, or bit uninterleaving if it decreases. That's because it inserts some number of zero bits between every few bits of `⥊𝕩`, or undoes this process. Bit interleaving with nonzero bits might be used for `⍉𝕩` when `≠𝕩` is small, or `𝕩∾˘𝕨` when both arguments have small cells.

**Careful!** A cell under 64 bits wide might not fit into any single machine word. For example, 57 bits starting at a 6-bit offset span 9 bytes. The first bit is bit 6 of byte 0, and the last is bit 0 of byte 8. Assuming the entire array is byte aligned, each cell always fits in a word for sizes ≤58, and 60. Cell sizes ≥61, and 59, might not. **Beware 59!**

Interleaving can be implemented with pdep, and uninterleaving with pext, in the BMI2 instructions. And these operations can be performed generically with a series of shifts and masks. Consider `7 ↑ 𝕩` where a cell of `𝕩` is 5 bits. Here are the input and expected result, labelling zeros with `.` and argument bits with letters:

    ...................ABCDEabcdeABCDEabcdeABCDEabcdeABCDEabcdeABCDE
    ...ABCDE..abcde..ABCDE..abcde..ABCDE..abcde..ABCDE..abcde..ABCDE

The number of cells that can be widened at a time is `⌊64÷7`, or `9`. In some cases I suppose it'd be possible to pack in one more by letting the leading zeros run past the top bit; that sounds complicated.

With the pdep instruction all we need to do is construct the appropriate mask indicating where the output cells should go. Let `K m` be `(2⋆m)-1`, that is, a number consisting of `m` ones in binary. Then the appropriate mask is `(K 5) × (K 7×9) ÷ (K 7)`. The mask `K 7×9` has 9 groups of 7 1s, and division by `K 7` converts each group to its bottom bit. Then multiplying by `K 5` converts each bit to 5 of them.

Because interleaving and uninterleaving are useful even on short arrays, it's best to precompute the division `(K 7×9) ÷ (K 7)`. Since `9` was computed as `⌊64÷7`, this value depends only on the width 7 so a table of 64 words is enough. And `7|64`, which might be useful for alignment, can be computed from the word as `l¬7`, where `l` is the number of leading 0 bits. Other similar schemes are possible.

On generic hardware these operations take more work. If we have `n` cells in a word (9 here), then it can be done with `⌈2⋆⁼n` steps. Numbering the cells starting at 0 on the right (little-endian) and the steps _ending_ at 0 for interleaving, step `j` moves cells that have a 1 in bit position `j`.

    ...................ABCDEabcdeABCDEabcdeABCDEabcdeABCDEabcdeABCDE
    ...ABCDE................abcdeABCDEabcdeABCDEabcdeABCDEabcdeABCDE
    ...ABCDE........abcdeABCDEabcdeABCDE........abcdeABCDEabcdeABCDE
    ...ABCDE....abcdeABCDE....abcdeABCDE....abcdeABCDE....abcdeABCDE
    ...ABCDE..abcde..ABCDE..abcde..ABCDE..abcde..ABCDE..abcde..ABCDE

The amount to move is `2⋆j` times the difference between the argument and result widths. To move the appropriate cells but not others, we need to blend with a mask, as in `(w<<sh &~ mask) | (w & mask)`. To go backwards, shift first, like `(w &~ mask)>>sh | (w & mask)`. Interleaving leaves some junk that needs to be cleared out with a final mask (same as the one used for pdep), and likewise uninterleaving requires the initial word to be cleaned with that mask. Here are the masks interleaved (heh) with results:

    ...................ABCDEabcdeABCDEabcdeABCDEabcdeABCDEabcdeABCDE
    0000000011111111111111111111111111111111111111111111111111111111
    ...ABCDE................abcdeABCDEabcdeABCDEabcdeABCDEabcdeABCDE
    1111111100000000000000000000000000001111111111111111111111111111
    ...ABCDE........abcdeABCDEabcdeABCDE........abcdeABCDEabcdeABCDE
    1111111100000000000000111111111111110000000000000011111111111111
    ...ABCDE....abcdeABCDE....abcdeABCDE....abcdeABCDE....abcdeABCDE
    0111111100000001111111000000011111110000000111111100000001111111
    ...ABCDE..abcde..ABCDE..abcde..ABCDE..abcde..ABCDE..abcde..ABCDE
    0001111100111110011111001111100111110011111001111100111110011111

The masks aren't very quick to generate, so it's best to do it once for all cells and save them. One way is to start with a mask `m` of all ones, then repeatedly take `m ^ (m<<sh)` with a series of shifts `sh` that decrease by factors of 2.
