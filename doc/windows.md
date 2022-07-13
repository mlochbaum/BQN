*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/windows.html).*

# Windows

<!--GEN
zt ← (w←5) ↕ xt ← Highlight∘•Repr¨ ↕8
d ← 40‿40

Ge ← "g"⊸At⊸Enc
rc ← At "class=code|stroke-width=1.5|rx=12"
g  ← "fill=currentColor|font-family=BQN,monospace|text-anchor=middle|font-size=18px"
bg ← "class=bluegreen|stroke-width=3|stroke-linecap=round|style=fill:none|opacity=0.7"
sg ← "fill=none|stroke-width=1|stroke=currentColor"
col ← {"class"‿𝕩≍"style"‿"fill:none"}¨"purple"‿"red"‿"yellow"‿"green"

Text ← ("text" Attr "dy"‿"0.33em"∾·Pos d⊸×)⊸Enc
Rect ← "rect" Elt Pos⊸∾⟜("width"‿"height"≍˘FmtNum)˝{𝕨⊢⊘∾𝔽𝕩}
Path ← ("path"At⊣) Elt "d"⋈⊢

ay ← ¯2 ⋄ lx ← ¯1.2
Exp ← (-≍+˜)⊸+
dim ← 48‿36 Exp d⊸×˘ lx‿ay ≍ ⟨lx-˜zt-○≠⊏xt,-ay⟩ + ¯1⊑¨ tx‿ty ← ⌽↕¨≢zt
my ← 2÷˜¯1⊑ty

Pd ← ∾∾¨⟜FmtNum
l ← 6‿15
br ← ∾ ((0.6-⊸⋈⊸+0⋈1-˜≠xt)((0‿¯1×l)+d×⋈)¨ay) ("M l l "Pd⥊∘∾)¨ ⋈⟜⌽ -⌾⊑⊸≍l
bp ← ⥊⌽(20×1.5‿¯1) (+⌾⊑ ≍ -⊸≍∘⊣)˘ 28‿24-⊸≍⊸+ d×⍉>0‿¯1⊸⊏¨tx‿ty
sl ← (0⋈¨ty)≍ty⋈¨ay+0.05×ty-my

(⥊48‿16 Exp dim) SVG g Ge ⟨
  rc Rect dim
  "text-anchor=end" Ge ay‿my lx⊸⋈⊸Text⟜Highlight¨ (⊢⋈(FmtNum w)∾"↕"∾⊢)"𝕩"
  sg Ge col Rect⟜{d⊸×˘¯0.1 Exp (¯0.5+𝕩)≍⟨≠tx,1⟩}¨⎉1 sl
  bg Path br ∾ "M hv" ∾˜⊸Pd bp
  ((↕≠xt)⋈⌜ay) Text¨ xt
  (⍉tx⋈⌜ty) Text¨ zt
⟩
-->

The Windows function returns all slices, or contiguous subarrays, with shape (well, shape prefix) `𝕨` from `𝕩`. It might also be seen as sliding a moving window along `𝕩`.

This function replaces APL's Windowed Reduction, J's more general Infix operator, and Dyalog APL's Stencil, which is adapted from one case of J's Cut operator. In BQN, it's strongly preferred to use functions, and not modifiers, for array manipulation. Functions are simpler with fewer moving parts, and more concrete, since the array results can always be viewed right away.

## Basic case

We'll start with the one-axis case. Here `𝕨` is a number between `0` and `1+≠𝕩`. The result is composed of slices of `𝕩` (contiguous sections of [major cells](array.md#cells)) with length `𝕨`, starting at each possible index in order.

        5↕"abcdefg"

There are `1+(≠𝕩)-𝕨`, or `(≠𝕩)¬𝕨`, of these sections, because the starting index must be at least `0` and at most `(≠𝕩)-𝕨`. Another way to find this result is to look at the number of cells in or before a given slice: there are always `𝕨` in the slice and there are only `≠𝕩` in total, so the number of slices is the range [spanned](logic.md) by these two endpoints.

A single slice of an array `𝕩` with length `l` and starting index `i` is `l↑i↓𝕩`, using [Take and Drop](take.md). The [Prefixes](prefixes.md) function returns all the slices that end at the end of the array (`(≠𝕩)=i+l`), and Suffixes gives the slices that start at the beginning (`i=0`). Windows gives yet another collection of slices: the ones that have a fixed length `l=𝕨`. Selecting one cell from its result gives the slice starting at that cell's index:

        2⊏5↕"abcdefg"

        5↑2↓"abcdefg"

Windows differs from Prefixes and Suffixes in that it doesn't add a layer of nesting (it doesn't enclose each slice). This is possible because the slices have a fixed size, so they fit together as cells of an array.

## Windowed reduction

Windows can be followed up with [Insert](fold.md#insert) on each slice to give a windowed reduction or fold. Here we take running sums of 3 values.

        +˝˘3↕ ⟨2,6,0,1,4,3⟩

A common task is to act on windows with an initial or final element so the total length stays the same. When using windows of length 2, the best way to accomplish this is with a [shift](shift.md) `«` or `»`. If the window length is longer or variable, then a trick with Windows works better: add the elements, and then use windows matching the original length. Here we invert Plus [Scan](scan.md) `` +` ``, which requires we take pairwise differences starting at initial value 0.

        -⟜(0»⊢) +` 3‿2‿1‿1

        (-˜˝≠↕0∾⊢) +` 3‿2‿1‿1

With Windows, we can modify the 3-element running sum from before to keep the length constant by starting with two zeros.

        (+˝≠↕(2⥊0)⊸∾) ⟨2,6,0,1,4,3⟩

## Symmetry

Let's look at the first example, paired with its [Transpose](transpose.md) (`⍉`).

        ⋈⟜⍉ 5↕"abcdefg"

Although the two arrays have different shapes, they're identical in the 3×3 region where they overlap.

        ≡○(3‿3⊸↑)⟜⍉ 5↕"abcdefg"

More concretely, the `i`th element of slice `j` is the same as the `j`th element of slice `i`: it's the `i+j`th element of the argument. So transposing still gives a possible result of Windows, but with a different slice length. The two lengths are related by [Span](logic.md), which converts between length and number of slices.

        {(5↕𝕩)≡⍉(3↕𝕩)}"abcdefg"

        (≠"abcdefg") ¬ 3

## Multiple dimensions

The right argument can have rank more than 1, and it's viewed as a list of major cells following [leading axis](leading.md) principles. As an example, Windows can take two-row slices of a shape `3‿4` array.

            2↕["0123","abcd","ABCD"]

        <⎉2 2↕["0123","abcd","ABCD"]

In the second version we've enclosed each slice with `<⎉2` for viewing—a slice has rank 2, the same as `𝕩`. Passing a list as the left argument to Windows takes slices along any number of leading axes. Here are all the shape `2‿2` slices:

        <⎉2 2‿2↕["0123","abcd","ABCD"]

The slices are naturally arranged along multiple dimensions according to their starting index. Once again the equivalence `i⊏l↕x` ←→ `l↑i↓x` holds, provided `i` and `l` have the same length.

If `𝕨` has length `0`, then `𝕩` is not sliced along any dimensions. The only slice that results—the entire argument—is then arranged along an additional zero dimensions. In the end, the result is `𝕩`, unchanged.

Here's a more formal definition: `𝕩` is an array. `𝕨` is a number, or numeric list or unit, with length `l←≠𝕨` so that `l≤=𝕩`. The result `z` has shape `𝕨 ∾ ¬⟜𝕨⌾(l⊸↑)≢𝕩`, and element `i⊑z` is `j⊑𝕩`, with `j←+´¨(l∾○↕=𝕩)⊔i`. That is, the index list `i` starts with two length-`l` sequences that are added together to produce the first `l` values in `j`. We might also say that each of the first `l` values in `j` is split into two values in `i`.
