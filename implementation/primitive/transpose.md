*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/transpose.html).*

# Implementation of array transpose

The [Transpose](../../doc/transpose.md) primitive `⍉` reorders axes of an array. It's a fairly deep primitive: even swapping two axes has some complexity, while rearranging many axes presents lots of different scenarios, making it hard to figure out which strategy will be best.

## Exchanging axes

Monadic transpose in BQN always exchanges one axis with the rest. As mentioned [below](#axis-simplification), that's equivalent to swapping exactly two axes. This case is easier to implement, but ideas that are useful for this simple transpose always apply to more complex ones as well.

The scalar approach is simply to set `res[i][j] = arg[j][i]` in a loop. The loops over `i` and `j` can be nested in either order, but if the inner loop is too short it'll add overhead. So it's best to write both and choose based on which argument axis is longer. For larger arrays, `i` as the outer loop, so that the writes go in order, is less affected by cache issues (but not as good as a [cache-efficient ordering](#cache-efficient-orderings)). SIMD can of course be faster, especially for 2-byte and smaller elements.

My talk "Moving Bits Faster in Dyalog 16.0" ([video](https://dyalog.tv/Dyalog17/?v=2KnrDmZov4U), [slides](https://www.dyalog.com/uploads/conference/dyalog17/presentations/D08_Moving_Bits_Faster_in_Dyalog_16.zip)) discusses optimizations for the boolean case, where a scalar loop is particularly bad because reading or writing a single bit is so slow. Booleans can be a little easier to work with than larger units, although there are also some unique issues to be addressed because they can only be accessed in aligned groups, while SIMD vectors don't have to be aligned.

### Kernels

A transpose kernel is a unit that's transposed with a single loopless section of code. Typically kernels are square, with a power-of-two length on the sides. For example, the boolean talk shows subarrays of 8×8 bits being transposed, since each fits in one 64-bit register. But now I think that's a pretty small kernel and 4 or more would be better, even sticking to general-purpose registers. Vector instructions both increase the size that can be held and speed up the transposing itself, so SIMD kernels are a big step up.

The major benefit of transposing with kernels is to combine multiple reads that would be scattered in ordinary scalar iteration (if writes are in-order). It costs about the same to read one element as one 32-byte register, so the larger read clearly gets a lot more done with the same memory load. But transposing huge numbers of elements in registers gets expensive, so at some point the CPU load will be big enough that increasing the kernel size is no longer worth it.

A matrix in SIMD registers can be transposed with unpack instructions in a [butterfly](https://en.wikipedia.org/wiki/Butterfly_diagram) pattern. This takes `k` layers for a `2⋆k` by `2⋆k` matrix, where each layer pairs up all registers. So the asymptotic cost for `n` elements is linear times an extra factor of `4⋆⁼n`.

Sizes that aren't an even multiple of the kernel side length can be handled either by performing a strided scalar transpose on the leftover bit, or by overlapping kernels. I've found that the scalar transpose is slow enough that it only makes sense with a single leftover row or column.

### Short kernels

A single fixed-size kernel breaks down when one axis is smaller than the kernel length. However, it's possible to handle these cases quickly using packing and unpacking for powers of two, and the [modular permutation](fold.md#the-modular-bit-permutation) for odd factors. For an argument or result width of w where w is small, the kernel will work on w vectors, divided by any power of 2. Short rows will be packed into these, and for performance they should be loaded as aligned vectors.

<!--GEN
d ← 17
pad ← 0.2‿0.2

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-family=BQN,monospace|font-size=11px|text-anchor=middle"
pg ← "class=lilac|stroke-width=2|stroke-linecap=round"
hg ← "stroke=currentColor|fill=none|opacity=0.4|stroke-linecap=round"
tg ← "fill=currentColor"
bg ← "class=yellow"

Text ← ("text" Attr "dy"‿"0.32em"∾(Pos d⊸×))⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d⊸×
Rp ← Pos⊸∾⟜("width"‿"height"≍˘FmtNum)○(d⊸×)
Path ← "path" Elt "d"⋈(∾∾¨⟜(FmtNum d×⊢))
CmpL ← <(⊣˝˘⊣´)≍˘(⊢˝˘⊢´)
Tr_icon ← {"stroke-width=14" Ge ⟨
  Line 𝕩+⌜0⋈2×𝕨
  "circle" Elt "cx"‿"cy"‿"r" ≍˘ FmtNum d×(𝕩+𝕨)∾0.9×𝕨
⟩}
Arrow ← {
  a ← 3.6‿1.8
  p ← {(𝕨⊸+∾-∾(-⊸∾-⌾⊑)∾𝕩∾-∾⊢∾-⌾⊑)a}˝ ⍉(⋈⟜-1.5)⊸+⌾⊏𝕩
  "stroke-width=10" Ge "M l l m L m l l " Path p
}

MP ← {𝕨|𝕩×↕𝕨}
RotC ← {(-𝕨)⊸⌽⌾((𝕨≤(2×𝕨)||⟜↕´≢𝕩)⊸/˘)𝕩}

sh ← k‿l ← 7‿16
dat ← ⋈⌜´ "A0"+↕¨⌽sh
steps ← >⟨
  rs_dat ← ⥊⟜(↕×´) sh
  pc_dat ← (⍋MP´sh) ⊏ rs_dat
  rc_dat ← (-↕l) ⌽˘⌾⍉ pc_dat
  rr_dat ← ( ↕k) ⌽˘ rc_dat
  pr_dat ← (MP˜´sh)⊸⊏˘ rr_dat
⟩
dsh ← 3 + sh ⋄ px0 ← ⟨k+4,3⟩
spos ← > {⋈˜⌜´(dsh×𝕩)+↕¨sh}¨ ⟨0‿0,0‿1,0‿2,1‿2,2‿2⟩
stepx‿sposx ← ⟨rs_dat, sh⥊⋈˜⌜´px0+↕¨⌽sh⟩ ∾¨ steps‿spos

rowm ← 4=k⌊∘÷˜stepx
colm ← 1=k|stepx
hlp ← (1-˜rowm+2×colm) ⊔○⥊ sposx
hlc ← "red"‿"bluegreen"‿"purple"

shf ← ¯1.5‿¯2
dim ← (4+2×shf)-˜3×⌽dsh

(d×((-∾+˜)pad)+shf∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ shf Rp dim
  hlc {("class="∾𝕨) Ge ("rect" Elt -⟜0.4 Rp 0.8¨)¨ 𝕩}¨ hlp
  bg Ge Line¨ CmpL⊸∾˝ +⟜(0.5×[1‿1,¯1‿1])¨ (¯1↓·⊢˝˘∘‿k⥊⊢)˘2↑sposx
  pg Ge ⟨
    Line¨ ∾⟨
      ([⟨l-0.4,¯0.6⟩,0‿0]+≍˘´)¨ steps ⊐⊸⊔○{⥊⊣˝⎉1  2↑𝕩} spos
      ([0‿0,⟨k-0.4,¯0.6⟩]+≍˘´)¨ steps ⊐⊸⊔○{⥊⊣˝⎉2 ¯2↑𝕩} spos
      (<⊣´⥊2⊏spos) +⟜{ [⋈˜¯2.5+0.3×𝕩, 0.6⋈1.4+  𝕩]}¨ ↕5
      (<⊢´⥊2⊏spos) -⟜{⌽[⋈˜¯1.3-0.3×𝕩, 0.6⋈2.4+3×𝕩]}¨ ↕5
    ⟩
    "M l vl " Path (⟨2÷˜k-1,¯1⟩+⊑sposx)(-∾⊢∾¯3∾⊢)0.6‿0.9
  ⟩
  tg Ge sposx Text¨ stepx⊏⥊dat
  hg Ge (4 Tr_icon ⌽dsh+2‿0)∾<Arrow ⟨¯0.5,2÷˜k+1⟩+(0‿k-˜sh+⌽px0)≍˘⊑⊢˝spos
⟩
-->

For an odd width `w`, elements are stored in `w` vectors of length `v`. The modular permutation kernel works by moving through an ordering with elements are stored along a wrapping diagonal: element `i` gets position `w‿v|i` (vector index, index within vector). All `w×v` positions are unique by the Chinese remainder theorem. Essentially, we move the single-step direction from horizontal (second axis) to diagonal (both axes) to vertical (first axis). So the steps are symmetric around this ordering, with a permutation and a shearing step on each side. Here's what to do when starting with a short width:
- Load contiguous rows into packed vectors
- Permute each column by virtually reordering the registers (free)
- Rotate each column forward by its index
- Rotate each row backwards by its index
- Permute each row with a shuffle (can be combined with previous)
- Store each vector as part of a result row
The shearing step that rotates columns is where most of the work happens because it's the only step that transfers elements between registers. It can be performed with `⌈2⋆⁼w` steps, each one handling a fixed power of two smaller than `w`. The step for `2⋆i` rotates each column whose index has that bit set, by blending a given register with another whose index differs by `2⋆i`.

To explain why this works, and nail down the exact permutation operations used, we'll initially number the elements in index order. So the index of element `i` in the initial kernel is `⟨⌊i÷w, w|i⟩`, it should end up at `⟨w|i, ⌊i÷w⟩` (note that computing an element's position from its value is the opposite of the normal array selection). The initial reshaping into vector registers puts element `i` at `⟨⌊i÷v, v|i⟩`. Our register permutation will move row `j` to `w|v×j`, thus sending element `i` from row `⌊i÷v` to `w|v×⌊i÷v`, but by the definition of `|`, this is equal to `w|i-v|i`! Now we rotate, we add the horizontal index to the vertical, modulo `w`, moving from `⟨w|i-v|i, v|i⟩` to `⟨w|i, v|i⟩`. The remaining steps are entirely symmetrical: performed in the same order, they would move from `⟨w|i, ⌊i÷w⟩` to `⟨w|i, v|i⟩`, affecting the second index instead of the first. Doing them backwards connects to the previous result. In sum, element `i` moves through the following positions:

    ⟨⌊i÷w,    w|i⟩
    ⟨⌊i÷v,    v|i⟩      # w‿v⥊
    ⟨w|i-v|i, v|i⟩      # (⍋w|v×↕w)⊏
    ⟨w|i,     v|i⟩      # (-↕v)⌽˘⌾⍉
    ⟨w|i,     v|i-w|i⟩  # (↕w)⌽˘
    ⟨w|i,     ⌊i÷w⟩     # (v|w×↕v)⊸⊏˘

The BQN code for each step is in the comments. Below, it's all run on the indices `i`:

        w‿v←7‿16
        (v|w×↕v)⊸⊏˘ (↕w)⌽˘ (-↕v)⌽˘⌾⍉ (⍋w|v×↕w)⊏ w‿v⥊ ↕w×v

### Cache-efficient orderings

There's some amount of literature on addressing cache issues in transpose. The theory is that by writing in index order, for instance, writes are perfectly cached but reads are very poorly cached. However, in CBQN testing with SIMD kernels, the orderings discussed here were not useful: it was best to simply loop in source order. I think the main reason for this is that an AVX2 register is an entire half the size of a cache line, so revisiting the same line is not that useful, and it confuses whatever predictor is trying to make sure the right lines are available.

The basic cache-friendliness tool is blocking: for example, split the array into blocks of a few kilobytes, transposing each before moving to the next. Multi-layer caches could in theory (but not in practice, it seems) demand multiple layers of blocking, but a cache-oblivious layout—named for its ability to perform well regardless of what layers of cache exist—skips over this mess and adds layers fractally at all scales. Here's [one presentation](https://en.algorithmica.org/hpc/external-memory/oblivious/#matrix-transposition) of this idea. A simpler recursive implementation is to just halve the longer side of the matrix at each step. At the other complexity extreme, Hilbert curves offer better locality and can be traced without recursion. A recent [paper](https://dl.acm.org/doi/10.1145/3555353) with [source code](https://github.com/JoaoAlves95/HPC-Cache-Oblivious-Transposition) offers a SIMD scheme to generate the curve that even the authors say is pointless for transpose because the overhead was low enough already. But it also explains the non-SIMD aspects well, if you have the time.

### Cache associativity

A more severe problem than just limited cache capacity is that when an array's stride is a power of 2 or very close to it, different accesses compete for the same small set of cache lines in a [set-associative](https://en.wikipedia.org/wiki/Cache_associativity#Set-associative_cache) cache. This can slow down something like a naive 512×512 transpose to the point that it's faster to pad the matrix, transpose, and remove the padding.

A set-associative cache can only store a fixed number of lines that have the same trailing bits in their address. So an 8-way associative cache might have space for 8 lines with address ending in 0x5f0. In the 512×512 case with 4-byte elements, every store in a column has the same last 9+2 bits as the previous one, and `2⋆9` elements are read before getting to the next column. The cache would need space for `(2⋆9+2+9)÷8`, or `2⋆17`, lines to store those elements, which it doesn't have, so cache lines from the beginning of the column start getting kicked out before reaching the next column, and those are exactly the ones you needed to keep around.

This is rather hard to fix, and ad-hoc approaches (including supposedly cache-efficient blocking!) have a nasty tendency of working at some sizes but not others. What I eventually found was that because the worst sizes are exact multiples of the cache line size, appropriately positioned transpose kernels are aligned with cache lines, so that by doing multiple transposes it's possible to write an entire cache line at a time. This still leaves an effect at near-powers of two that I don't know how to address, but it's fairly small.

## Arbitrary reordering

Moving lots of axes around quickly gets hard to think about. Here's what I've found so far. Most of these methods work in some way for repeated axis indices (that is, merging axes by taking diagonals) too.

### The outer loop

Unlike a 2D transpose, the basic implementation of an arbitrary reordering is not so obvious. It "should" be a loop with a variable amount of nesting. However it's written, actually looping is not a competitive strategy. But it's still needed, because the fast strategies don't handle the entire transpose: they're base cases, that take up the bottom few result axes.

The easy and non-recursive way to reorder axes is with a result index vector: increment it at each step and adjust the argument position accordingly. A base case that takes up multiple axes just means the loop should only go over the first few result axes instead of all of them. Because incrementing such an index is slow, it might also make sense to break off a level of looping at the bottom and implement it with a direct for loop.

### Axis simplification

Sometimes the transpose isn't as complicated as it appears. The following are useful simplifications to apply:

- Any length-1 axis can be ignored; it doesn't affect ordering.
- Two axes that begin and end next to each other can be treated as one larger axis.
- Axes at the end that don't change can be absorbed into a total "element size".

An efficient way to apply these rules is to compute for each result axis the length and corresponding argument stride—these two lists fully describe the transpose. To get a simplified length and stride, traverse these backwards. Skip any length-1 axes, and combine an axis with the one below if its stride is equal to the length-times-stride of that axis. This stride makes it so moving one step on the higher axis is equivalent to moving the full length along the lower one. This method works fine with merged axes, which are just unusual strides.

Particularly after dropping length-1 axes, some transposes might get down to 1 or 0 axes, which means they're no-ops.

### The bottom line

When there's a large enough fixed axis at the bottom, most of the work of transpose is just moving large chunks of data. If these moves are done with memcpy or similar, it doesn't matter what the structure around them is, as the limiting factor is memory bandwidth.

A similar principle applies if, for example, the last *two* axes switch places, but stay at the end, provided their product is large enough. Then the transpose is a bunch of 2D transposes. If each of these is done efficiently, then the outer structure can be anything. Less obviously, a strided 2D transpose (that is, one that has side lengths and argument/result strides specified independently) can be used any time the last axis changes. Set the argument stride to the stride of whichever axis turns into the last result axis, and the result stride to the stride of whichever axis comes from the last argument axis. This does require the last argument axis not to be merged with any other axis, or equivalently for there to be some result axis with stride 1.

As a result, any axis reordering (without merged axes) where the last argument and last result axis are both long can be performed quickly. If these axes are the same, use memcpy, and if not, use strided 2D transposes. It's short axes that are an issue.

### Indices

One thing I noticed when working with BQN is that CBQN's dyadic `⍉` sometimes beat Dyalog's, despite using the BQN runtime instead of a native implementation. The runtime just constructs all the (ravel) indices for the output with a big addition table `+⌜´`, then selects. I think this is actually a good catch-all strategy for handling trailing axes in case they're small. Construct the index table for the bottom few axes of the result—which don't have to correspond to the bottom axes of the argument, even though for cache reasons it'd be nice if they did. Then the base case for transpose is simply selecting using these axes.

### Decomposition

Another possibility that may be worth looking into is splitting one reordering into two or more. I don't know whether this can beat a single-pass method in any case, but it's certainly simpler a lot of the time. But finding an algorithm which will make good decompositions can be pretty hard still.

Dyalog splits a general boolean transposes into an axis rotation, which swaps two groups of axes and thus works like a matrix transpose, and a second transpose that fixes the last axis. Since length-1 axes have been eliminated, that last transpose works with at least 2 bits at a time, so the worst case is *slightly* better than moving single bits around but still not great.

## Strided representation?

A solution sometimes offered to eliminate the cost of transposing is to store all arrays with a [strided](https://en.wikipedia.org/wiki/Stride_of_an_array) representation. Then a transpose only rearranges axis lengths and strides while leaving the data the same, and the stride will cause later operations to access it as though transposed. Bluntly, this is not a good idea on modern hardware, unless maybe you're building an advanced [array compiler](../compile/intro.md). Transpose isn't used that much even in programs that depend on it, and kernel-based Transpose is fast, taking as long as one to two arithmetic primitives. Building stride support into other primitives, on the other hand, makes every primitive harder to write and slower in the general case.

Nothing wrong with strides, they're very useful—as in [axis simplification](#axis-simplification) above. The problem with virtual transpose is that caching and SIMD loads are all set up to handle data in order. To add one array to another that's virtually transposed, you have to access at least one array out of order. And reading one element at a time is very slow relative to SIMD. The fast way is to take a fast transpose implementation and fuse it with the addition operation. So maybe for kernel transpose you load in one kernel, transpose it, and add it to rows from the other array. Same for other kinds of transpose, and, hey, you're going to support [arithmetic with rank](arithmetic.md#ranked-arithmetic), right? Just take the hit and separate out the transpose. There are much better targets for fusion.

NumPy is probably the highest-profile user of this strategy (and allows manipulation of the stride; see [stride\_tricks](https://numpy.org/doc/stable/reference/generated/numpy.lib.stride_tricks.as_strided.html)). I'm not aware of any current APLs that use it. [ngn/apl](https://aplwiki.com/wiki/Ngn/apl) did briefly, but [abandoned it](https://chat.stackexchange.com/transcript/52405?m=56102817#56102817). JIT-compiled [APL\3000](https://aplwiki.com/wiki/APL%5C3000) used it as part of its subscript calculus system, but this was the 70s—I'm pretty sure the HP 3000 didn't have a data cache and it certainly didn't have SIMD.
