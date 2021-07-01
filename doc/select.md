*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/select.html).*

# Select

<!--GEN
d ← 48‿58

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-family=BQN,monospace|font-size=22px|text-anchor=middle"
cg ← "font-size=18px|text-anchor=end"
lg ← "class=lilac|stroke-width=2|stroke-linecap=round"
ig ← "fill=currentColor|font-size=12|opacity=0.75"

xt ← '''(Highlight∾∾⊣)¨"select"
wt ← Highlight∘•Repr¨ wv ← 2‿1‿1‿5

Text ← ("text" Attr "dy"‿"0.32em"∾(Pos d⊸×))⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d⊸×
Rp ← Pos⊸∾⟜("width"‿"height"≍˘FmtNum)○(d⊸×)

tx‿tw ← ↕∘≠¨ xt‿wt ⋄ y ← 0.6+↕3
dim ← ⟨1.8+≠xt, ≠y⟩ ⋄ sh ← ¯2‿0
tp ← (1‿2/tx‿tw) ≍¨¨ y

((∾˜d)×((-∾+˜)1.1‿0.3)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ sh Rp dim
  lg Ge Line¨ (≍˘⟜-0.2≍˜0.08×·÷´-˝˘)⊸+¨ ∾(⟨wv⊏tx,tw⟩≍¨¨<tw)≍¨⟜<¨<˘2↕y
  (∾tp) Text¨ ∾⟨xt,wt,wv⊏xt⟩
  ig Ge (-⟜0‿0.33¨⊑tp) Text¨ •Repr¨ ↕≠xt
  cg Ge (¯0.8≍¨y) Text⟜Highlight¨ "𝕩"‿"𝕨  "‿"𝕨⊏𝕩"
⟩
-->

The function Select (`⊏`) reorganizes the array `𝕩` along one or more axes based on [indices](indices.md) given by `𝕨`. The result has the same [depth](depth.md) as `𝕩`, since its elements are always elements of `𝕩`. This means it differs from Pick (`⊑`), which takes elements from `𝕩` but can arrange them in any nested structure, including returning an element directly.

The monadic form First Cell (`⊏`) gets the major cell with index 0, so that `⊏𝕩` is identical to `0⊏𝕩`.

## Single selection

Each axis of a BQN array is numbered starting at zero. Major cells are arranged along the first axis; in accordance with the [leading axis](leading.md) principle, Select returns a major cell of `𝕩` when `𝕨` is an atom.

        2 ⊏ "abcdef"  # An enclosed element

        2 ⊑ "abcdef"  # Pick gets a non-enclosed element

        2 ⊏ >"nul"‿"one"‿"two"‿"tre"‿"for"

        0 ⊏ <5  # No first axis to select from

As a major cell of `𝕩`, the result has rank one less than it and its shape is `1↓≢𝕩`. `𝕩` must have rank one or more.

The index `𝕨` has to be an integer less than `≠𝕩`. It can be negative, in which case it must be greater than or equal to `-≠𝕩`. Negative indices select from the end of `𝕩`, in that `¯1` indicates the last major cell and `-≠𝕩` indicates the first. If `≠𝕩` is 0, then no index is valid.

        ¯2 ⊏ "abcdef"

        0 ⊏ ""

The monadic case First Cell (`⊏𝕩`) is identical to `0⊏𝕩`. It has the same restrictions: `𝕩` must have rank 1 or more, and length 1 or more (this differs from First (`⊑`), which removes the length requirement to return a fill element).

        ⊏ "abc"

        ⊏ "abc"≍"def"

        ⊏ ≍ "abc"

        ⊏ 'a'

## First-axis selection

If `𝕨` is an array of numbers (including any empty array), then each number indicates a major cell of `𝕩`. In the simplest case, a list of numbers gives a result with the same rank as `𝕩` but maybe not the same length.

        2‿3‿3‿0‿4‿1 ⊏ "OlZEt"

        ⟨⟩ ⊏ "OlZEt"

To find the first and last cells of `𝕩`, use `0‿¯1` for the left argument.

        ⊢ m ← 3‿5‿7‿11 |⌜ ×˜↕7

        0‿¯1 ⊏ m

More generally, `𝕨` can be an array of any rank. Each of its 0-cells—containing a single number—is replaced with a cell of `𝕩` in the result. The result's shape is then made up of the shape of `𝕨` and the major cell shape of `𝕩`: it's `(≢𝕨)∾1↓≢𝕩`. When `𝕩` is a list, the result has the same shape as `𝕨`. Elements of `𝕨` are replaced one-for-one with elements of `𝕩`.

        2|m

        (2|m) ⊏ " *"

Another special case is when `𝕨` is a unit. Now the result shape will be the major cell shape of `𝕩`. In fact it's the same as the atom case above, that is, for a number `n`, `(<n)⊏𝕩` is the same as `n⊏𝕩`.

The general case can result in a complicated array. Remember that the initial axes come from `𝕨` while later ones come from `𝕩`.

        "awA0" +⌜ ↕4

        2 ↕ ↕4

        (2 ↕ ↕4) ⊏ "awA0" +⌜ ↕4

## Multi-axis selection
