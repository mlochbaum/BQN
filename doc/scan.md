*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/scan.html).*

# Scan

<!--GEN
f ← •BQN fn ← "⌈" ⋄ ft ← Highlight fn
xt ← Highlight∘•Repr¨ xv ← 2‿0‿0‿3‿5‿1
zt ← Highlight∘•Repr¨ f` xv
d ← 56‿42

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "fill=currentColor|stroke-linecap=round|text-anchor=middle|font-family=BQN,monospace"
cg ← "font-size=18px|text-anchor=end"
bg ← "class=bluegreen|stroke-width=3|style=fill:none|opacity=0.6"
lg ← "class=lilac|stroke-width=2"

Text ← ("text" Attr "dy"‿"0.32em"∾ ·Pos d⊸×)⊸Enc
Path ← "path" Elt "d"⋈⊢
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d×⊢

Brak ← {
  l ← 6‿15
  P ← ∾"M l l "∾¨ ·FmtNum∘⥊ ∾
  Path ∾ (((-⊸≍0.4)+0‿¯1⊏𝕨)((0‿¯1×l)+d×≍)⌜𝕩) P¨ ⋈⟜⌽ -⌾⊑⊸≍l
}
VL ← ≍˜⊸≍⟜((≍⟜-0.3)⊸+)

tx ← ↕≠xt ⋄ ty ← 0.75+4.7×↕2
sy ← (2÷˜+´ty)+3×0.5-˜(↕÷-⟜1) ≠sx←1↓tx
dim ← ⟨2.5+≠tx,0.75+1⊑ty⟩ ⋄ sh ← ¯2.3‿0

((∾˜d)×((-∾+˜)1‿0.3)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ (Pos d×sh)∾"width"‿"height"≍˘FmtNum d×dim
  lg Ge Line¨ ∾⟨
    ⟨tx ⊑⊸VL ty⟩
    ∾ sx {𝕨⊸VL¨⌽⌾(1⊸⊑)<˘ty≍˘𝕩}¨ sy
    sx ((¯1‿¯0.14≍¯0.3‿¯0.07)+≍)¨ sy
  ⟩
  cg Ge (¯1.1≍¨ty) Text¨ ⋈⟜(ft∾(Highlight"`")∾⊢) "𝕩"
  "font-size=21px" Ge (⍉tx≍⌜ty) Text¨ xt≍zt
  "font-size=19px" Ge sx (≍ Text ft˙)¨ sy
  bg Ge tx⊸Brak¨ ty
⟩
-->

The 1-modifier Scan (`` ` ``) moves along the first axis of the array `𝕩`, building up an array of results by applying `𝔽` repeatedly beginning with `𝕨` or `⊏𝕩`. It's related to the fold modifiers, and most closely resembles the [APL2-style reduction](fold.md#apl2-reduction) `¨˝`, but it traverses the array in forward rather than reverse index order, and includes all intermediate results of `𝔽` in its output instead of just the final one.

BQN's Scan is ordered differently from Scan in APL. Both include one result for each non-empty prefix of `𝕩`. In BQN this is a left-to-right fold, so that each new result requires one application of `𝔽`. APL uses right-to-left folds, which matches with reduction, but requires starting over at the end for each new prefix, except in special cases. If needed, this definition can be obtained with a fold on each [prefix](prefixes.md) except the first (which is empty). In the particular case of `-⍀`, that nested solution isn't needed: negate odd-indexed elements and then apply `` +` ``.

Scan also differs from Fold or Insert in that it never depends on `𝔽`'s [identity value](fold.md#identity-values), because scanning over an empty array simply returns that array.

## Lists

The best-known use of Scan is the [prefix sum](https://en.wikipedia.org/wiki/Prefix_sum) of a list, in which each element of the result is the sum of that element and all the ones before it. With a [shift](shift.md) this can be modified to sum the previous elements only.

        +` 2‿4‿3‿1

        +`»2‿4‿3‿1  # Exclusive prefix sum

The pattern is generalized to any function `𝔽`. With an operand of `×`, it can find the first *n* factorials. With [Maximum](arithmetic.md#additional-arithmetic) (`⌈`), it returns the largest element so far.

        ×` 1+↕6

        ⌈` ¯1‿¯2‿0‿4‿2‿1‿5‿¯2

If provided, `𝕨` gives a starting element for Scan (actually a starting *cell*, so a single element should be [enclosed](enclose.md)). Below it ensures that all results of `` ⌈` `` are at least `0`. In either valence, the shape of the result is always the same as the shape of `𝕩`.

        0 ⌈` ¯1‿¯2‿0‿4‿2‿1‿5‿¯2

To see the structure of the computation, it can be helpful to use a symbolic operand `𝔽` that returns a string describing its own application.

        {"("∾𝕨∾")𝔽"∾𝕩}` "a"‿"b"‿"c"‿"d"

        (<"w") {"("∾𝕨∾")𝔽"∾𝕩}` "a"‿"b"‿"c"‿"d"

The left argument in each result element is always the previous element, if there is one. Result elements are produced in index order and this element will be reused, rather than computing it again. This can be confirmed by adding a counter to `𝔽`, which shows here that scanning a 10-element list makes 9 calls (supplying an initial value would make it 10).

        c←0
        {c+↩1⋄𝕨+𝕩}` ↕10
        c

Some other useful scans apply to boolean lists. The function `` ∨` `` (with [Or](logic.md)) tests whether this or any previous element is 1, so that the result starts at 0 but permanently switches to 1 as soon as the first 1 is found. Similarly, `` ∧` `` turns all instances of 1 after the first 0 to 0.

        ∨` 0‿0‿1‿0‿0‿1‿0‿1

        ∧` 1‿1‿1‿0‿0‿1‿0‿1

A more complicated boolean scan, which depends on the left-to-right ordering, is `` <` ``. It turns off every other 1 in a group of them—can you see why? One use is to resolve questions regarding backslash escaping: the simple example below removes backslashes except those that are escaped by more backslashes.

        <` 0‿0‿1‿1‿1‿0‿0‿1‿1‿1‿1

        {¬<`'\'=𝕩}⊸/ "ab\\\rs\\\\"

## Reverse scan

We've discussed how the scan moves forward along `𝕩`, so that each time `𝔽` takes an old result as `𝕨` and a new value as `𝕩`. This means that results correspond to [prefixes](prefixes.md) and go left to right on each one. Since the most important scans have associative, commutative operands, the left-to-right ordering often doesn't make a difference. But sometimes a suffix rather than prefix scan is wanted. For these cases, Scan Under [Reverse](reverse.md) (`` `⌾⌽ ``) does the trick.

        ∨`   0‿0‿1‿0‿0‿1‿0

        ∨`⌾⌽ 0‿0‿1‿0‿0‿1‿0

This function reverses the input, does the scan, and reverses the output. Perhaps not so easy to visualize, but a symbolic operand will again show what it's doing:

        {"("∾𝕨∾")𝔽"∾𝕩}`⌾⌽ "a"‿"b"‿"c"‿"d"

The new value is still the right argument to `𝔽`, even though with the reversal it's to the left of any values previously seen. If `𝔽` isn't commutative, and this is the wrong order, then `` 𝔽˜` `` will switch it around.

        {"("∾𝕨∾")𝔽"∾𝕩}˜`⌾⌽ "a"‿"b"‿"c"‿"d"


## Higher ranks

Scan moves along the [leading axis](leading.md) of `𝕩`: vertically, for a table. To apply a scan to later axes, use `˘` or `⎉`. Since a scan returns an array with the same shape as its argument, this can't cause an error from differing result cell shapes, unlike Fold or Insert.

        ⊢ a ← ¯2‿0.25‿'a'‿∞ ∾ 3‿4⥊¯1‿0‿1

        +` a

If `𝕨` is given, it must have the same shape as a major cell of `𝕩` (this is why `𝕨` needs to be enclosed when `𝕩` is a list: in general it's an array). Then the first result cell is found by applying `𝔽` to elements of `𝕨` and `⊏𝕩`, and the computation continues as in the one-argument case for remaining cells.

        3‿2‿1‿0 +` a

Results are produced in index order. This means that instead of moving along each column in turn, a scan produces the first result cell one element at a time, then the next, and so on. Something like a breadth-first as opposed to depth-first ordering.

## Definition

Scan admits a simple recursive definition. `𝕩` is an array of rank one or more and `𝕨`, if given, is an atom or array with shape `1↓≢𝕩`. The result ``z←𝕨𝔽`𝕩`` is an array with the same shape as `𝕩`. If it has length at least one, `⊏z` is `⊏𝕩` if `𝕨` isn't given and `𝕨𝔽¨⊏𝕩` if it is. For `0≤i`, `(i+1)⊏z` is `(i⊏z)𝔽¨(i+1)⊏𝕩`.

The ordering of `𝔽` application is the natural one for this definition: cells are computed in turn, and each instance of `𝔽¨` goes in index order.
