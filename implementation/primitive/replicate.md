*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/replicate.html).*

# Implementation of Indices and Replicate

The replicate family of functions contains not just primitives but powerful tools for implementing other functionality. Most important is the boolean case, which can be used to ignore unwanted values without branching. Replicate by a constant amount (so `𝕨` is a single number) is not too common in itself, but it's notable because it can be the fastest way to [implement](arithmetic.md#table-and-leading-axis) outer products and arithmetic with prefix agreement. Fast implementations can be much better than the obvious C code, particularly for the boolean case.

| Normal                  | Boolean
|-------------------------|--------
| [Indices](#indices)     | [Where](#booleans)
| [Replicate](#replicate) | [Compress](#booleans)
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

For top performance, the result should be constructed from one shuffle per output, and some haggling with lanes for odd values in AVX. But this takes `𝕨` shuffle instructions, so handling all constants up to some bound is quadratic in code size (JIT compiling might help, but generating a lot of code is bad for short `𝕩`). On 1- to 8-byte types, CBQN has a complicated mix of AVX2 methods to get high peformance with tolerable code size. From fastest to slowest:

- Sizes 2 to 7 have dedicated shuffle code.
- Small composite sizes `𝕨=l×f`, where `f` has a dedicated shuffle, are split into `l/f/𝕩`.
- Other small sizes use a function that always reads 1 vector and writes 4 per iteration, using shuffle vectors from a table to generate them. This requires tail handling and uses some tricks to pack the tables to a reasonable size.
- Sizes where one element fills multiple vectors write broadcasted vectors, overlapping the last two writes to avoid any tail handling. There are unrolled loops for less than 4 vectors.

#### Constant replicate boolean

On booleans, we also use a mix of methods, which for small constants is based on factoring into a power of two times an odd number. Divisors of 8 are handled with various ad-hoc shuffling (and sometimes we replicate by 8 and then replicate as 1-byte data). Odd factors less than 64 are always handled with the [modular permutation](fold.md#the-modular-bit-permutation). This alone can only place each bit at its initial index times `𝕨`, so to spread each bit we want to shift up by `𝕨` and subtract. A key trick is to rotate the permuted word, which combines all the bits, instead of shifting after splitting it up. When handling the lowest `𝕨` bits of each word, the top bit will be there but the bottom bit won't, so you have to subtract 1 if any of the bottom `𝕨` bits of the top bit is set—with this, any cross-word carrying is eliminated!

With AVX2 we can also get useful work out of the modular permutation above width 64 and up to 256, by constructing a boundary mask that always has one bit: it is the boundary in each word that has one, or is the same as the previous mask. This is constructed as `1<<(s&63)`, where the shift amount `s` is equal to the distance from the end of a given word to the previous boundary—that is, a negative number in the range [-`𝕨`,0). Then bitwise-and with a permuted 64-bit word picks out the bit value that should go at the end of the word. If `s >= -64`, then this is the entire word, and otherwise the other bit can be incorporated using the rotation trick and some xor-based logic. I haven't found an analogue of the horizontal-vertical mask decomposition for `𝕨<64`; the distance tracking and shifting is substantially slower.

Otherwise, the scalar method for `𝕨>64` is, for each bit in `𝕩`, to write a boundary word and then some number of constant words. This can be done with a fixed number of writes, increasing the speed at smaller `𝕨` by avoiding branch prediction. Every iteration writes `w/64 - 1` or `w/64` constant words. First write the last one, then `w/64 - 1` from the starting point. They'll overlap if necessary to give the right length.

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

### Boolean compress

When you don't have pext you have to emulate it. The two good published methods I know are described in Hacker's Delight. The one given in 7-4 is due to Guy Steele, and sketched in 7-6 is another method I'll call "pairwise"—the book says it isn't practical in software but it works well if finished with sequential shifts. Both take log²(w) instructions for word size w using generic instructions; comparing the two makes it seem like the extra log(w) factor is incidental, but I haven't been able to get rid of it. However, they also vectorize, and are log(w) with the right instruction support: carry-less multiply (x86 PCLMUL, NEON) for Guy Steele and vector-variable shifts (AVX2, SVE) for pairwise.

On Zen, Zen+, and Zen 2 architectures, pext is micro-coded as a loop over set bits and should not be used. The cost ranges from a few cycles to hundreds; measurements such as uops.info apparently use an argument that's 0 or close to it, so they underreport.

Slowest to fastest with 64-bit words on x86:
* Guy Steele generic
* Pairwise generic, sequential shifts after reaching 8 bits
* Guy Steele PCLMUL, 1 word at a time
* Guy Steele PCLMUL, 2 at a time (needs double clmuls so it's not 2x faster)
* Pairwise AVX2, 32- and 64-bit srlv, 4 words at a time
* BMI2 pext

The basic movement strategy is the masked shift `(x & m)>>sh | (x &~ m)`. Combining shifts for `sh` of 1, 2, 4, up to `2⋆k-1`, with variable masks, any variable shift strictly less than `2⋆k` can be obtained. Each bit needs to eventually be shifted down by the number of zeros below it. The challenge is producing these masks, which need to line up with bits of `x` at the time it's shifted.

The pairwise method resolves this by repeatedly combining pairs: at each step only the top group in a pair moves, by the number of zeros in the bottom group. So the top groups can be pulled out and shifted together, and the mask when it's shifted spans both top and bottom groups. Zero counts come from pairwise sums, and the final one can be used to get the total number of 1s needed for Compress's loop. The masked shifting wastes nearly a whole bit: for example merging groups of size 4 may need a shift anywhere from 0 to 4, requiring 3 bits but the top one's only used for 4 exactly! I found some twiddling that mitigates this by not using this bit but instead leaving a group out of the shifted part if it would shift by 0. To avoid the wide shifts in later steps, stop, get total offsets with a multiply (e.g. by 0x010101…), and finish with sequential shifts. That is, pull out each group with a mask, shift by its offset, and or all these shifted words together. But SIMD variable shifts, if present, are much better.

Guy Steele shifts each bit directly by the right amount, that is, the number of zeros below it. So the first shift mask is ``≠`»¬𝕨``, and later shifts are also constructed with xor-scan, but where `𝕨` is filtered to every other bit, then every 4th, and so on. This filtering uses the result of `` ≠` ``, leading to a long dependency chain. Also the bits originating from `𝕨` have to be shifted down along with `𝕩`.

Multiple rounds of xor-scan is a complicated thing to do, considering that all it _does_ do is a prefix sum that could just as easily be (carry-ful) multiplication! It feels like going from 8 bits to 64 in the pairwise method, which I now use sequential shifts for, should have some Guy Steele version that's parallel and reasonably fast. The issue is that the shift amounts, which are 6-bit numbers, have to be moved along with the groups, which are 0 to 8 bits. So if this process brings two of them too close, they'll overlap and get mangled.

### Sparse compress

When `𝕨` is sparse (or `𝕩` for Indices), that is, has a small sum relative to its length, there are methods that lower the per-input cost by doing more work for each output.

The best known sparse method is to work on a full word of bits. At each step, find the first index with count-trailing-zeros, and then remove that bit with a bitwise and, `w &= w-1` in C. However, this method has a loop whose length is the number of 1s in the word, a variable. CPUs are very good at predicting this length in benchmarks, but in practice it's likely to be less predictable! In CBQN it's only used for densities below 1/128, one bit every two words.

For marginal cases, I found a branchless algorithm that can work on blocks of up to `2⋆11` elements. The idea is to split each word into a few segments, and write the bits and relative offset for each segment to the appropriate position in the result of a zeroed buffer. Then traverse the buffer, maintaining bits and a cumulative offset. At each step, the index is obtained from those bits with count-trailing-zeros just as in the branching algorithm. The bits will all be removed exactly when the next segment is reached, so new values from the buffer can be incorporated just by adding them.

<!--GEN
Ge ← "g"⊸At⊸Enc
g  ← "fill=currentColor|font-family=BQN,monospace|font-size=16"
rc ← "class=code|stroke-width=1.5|rx=12"
pe ← "path"At"stroke-width=1|stroke=currentColor|fill=none"

Text ← ("text" Attr "dy"‿"0.33em"∾Pos)⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ FmtNum
Rect ← "rect"{𝕗⊘(𝕗At⊣)} Elt Pos⊸∾⟜("width"‿"height"≍˘FmtNum)˝∘⊢

nw ← 2
input ← (2×64) ↑/⁼ 23‿24‿33‿35‿42‿92‿93‿104‿122
po ← ¯1 ⌽ off ← ⥊nw/≍3‿3‿2
groups← (8×off) /⊸⊔ input
dest ← »+` popc ← +´¨groups
gg ← dest ⊔ groups 24⊸↑⊸⋈¨ po
gs ← (<⟨24⥊0,¯2⟩) (»∨`)⊸∧⌾⊑⊸(+´)` gg

y0 ← 5 + (51⊸× + 5×3⊸≤) ↕≠groups ⋄ yh ← 18+y0
yt ← ⊑ y1 ← 36 × ↕≠gg
x0‿x1‿x2‿x3 ← +`0‿288‿368‿320
dim ← 24‿72 (-∘⊣≍2⊸×⊸+) x3⋈(⊢´y1)-44
x0t ← x0 + 20

Tspan ← {⟨"<tspan class='"∾𝕩∾"'>", "</tspan>"⟩}
tBit‿tAdd‿tSum ← ts ← Tspan¨ "Number"‿"Modifier"‿"String"
CBit‿CAdd‿CSum ← {𝕨∾∾⟜𝕩}´¨ ts

_hl ← { i←𝔽/𝕩 ⋄ ⟨1¨𝕩, ⥊tBit˘i, ⥊i-⌜1‿0⟩ Modify '0'+𝕩 }
FmtBW ← {∾𝕨‿" | "‿𝕩‿"<<24"}⟜CAdd

(⥊ 16‿8 (-≍+˜)⊸+ dim) SVG g Ge ⟨
  rc Rect dim
  "class=bluegreen|opacity=0.3" Rect (-˜`x3+¯26‿10)≍˘(1‿¯2×12)+⊢˝˘dim
  pe Elt "d"⋈∾(∾"M hvh"∾¨⟜FmtNum(x0+4)∾∾⟜(10(-⊸∾∾⊣)7-˜3×51))¨ 13-˜0‿3⊏y0
  "class=bluegreen|stroke-width=3|stroke-linecap=round" Ge Line¨ ∾⟨
    (x1-50‿6)⊸≍¨ y0⋈¨dest⊏y1
    ((x2-50‿6)≍⋈˜)¨ y1
    ((⋈˜14+x2)≍(⋈⟜-12)⊸+)¨ <˘2↕y1
  ⟩
  Text¨´¨ ⟨
    ⟨x0t‿x1‿x2⋈¨48-˜yt, ⟨
      "words split 24+24+16"
      (∾⟨"zeroed buffer  ",CSum"+","  bits"⟩) FmtBW "add"
      ∾⟨"trailing zeros of ",CBit"↓","   +  8×",CAdd"↓"," ="⟩
    ⟩⟩
    ⋈¨⟨x2⋈¯20+yt, (25⥊' ')∾CAdd"(¯2)"⟩
    ⟨x0⋈¨y0, ⊢_hl¨ groups⟩
    ⟨x0⋈¨yh, ∾⟜", "⊸∾¨´ {n‿(b‿e)‿v: (n∾"=")⊸∾¨ (b∾∾⟜e)¨ FmtNum v}¨ ⟨
      "sum"‿tSum‿popc, "dest"‿tSum‿dest, "add"‿tAdd‿po
    ⟩⟩
    ⟨x1⋈¨y1, (0<≠)◶⟨"0", ⊢_hl⊸FmtBW⟜•Repr´+´⟩¨ gg⟩
    ⟨x2⋈¨y1, ⊑_hl⊸{𝕨∾","∾CAdd ¯3↑𝕩}⟜•Repr´¨ gs⟩
    ⟨(x3-42)⋈¨y1, {"→"∾¯4↑•Repr𝕩}¨ {(⊑/𝕨)+8×𝕩}´¨gs⟩
  ⟩
  "font-size=12" Ge ⟨x0t,28-˜yt⟩ Text "(little-endian bit order)"
  "font-size=26" Ge ⟨x0-4, x3-26⟩ ⋈⟜(yt-42)⊸Text⟜Highlight¨ "𝕩"‿"/𝕩"
⟩
-->

### Grouped compress

The sparse method can also be adapted to find groups of 1s instead of individual 1s, by searching for the first 1 and then the first 0 after that. This is useful if `𝕨` changes value rarely, that is, if `+´»⊸<𝕨` is small. Computing this value can be expensive so it's best to compute the threshold first, then update it in blocks and stop if it exceeds the threshold.

For copying medium-sized cells with memcpy, all the branching here is pretty cheap relative to the actual operation, and it may as well be used all the time. This may not be true for smaller cells copied with overwriting, but I haven't implemented overwriting so I'm not sure.

## Higher ranks

When replicating along the first axis only, additional axes only change the element size (these are the main reason why a large-element method is given). Replicating along a later axis offers a few opportunities for improvement relative to replicating each cell individually. See also [multi-axis Select](select.md#multi-axis-selection).

Particularly for boolean `𝕨`, Select is usually faster than Replicate (a major exception is for a boolean `𝕩`). Simply replacing `/` with `/¨⊸⊏` (after checking length agreement) could be an improvement. It's probably best to compute the result shape first to avoid doing any work if it's empty. Similarly, if early result axes are small then the overhead of separating out Indices might make it worse than just doing the small number of Replicates.

Some other tricks are possible for boolean `𝕨`. If there's a large enough unchanged axis above, perhaps with `𝕨/⎉1𝕩`, then `𝕨` can be repeated to act on virtual rows consisting of multiple rows of `𝕩` (the last one can be short). I think this only ends up being useful when `𝕩` is boolean. But we can also combine compress along several axes, as multi-axis `⥊𝕨/𝕩` is `(∧⌜´𝕨)/○⥊𝕩`: the previous method is a bit like a specialization where entries of `𝕨` other than the last are lists of `1`s. This is particularly nice if `𝕩` as a whole is small, but even if `𝕨` will eventually be converted to indices, it's a faster way to combine the bottom few levels if they're fairly dense.
