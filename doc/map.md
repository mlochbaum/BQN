*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/map.html).*

# Mapping modifiers

Mapping a function over an array means to call it on each element of that array, creating an array of results. It's also possible to map over two arrays, applying the function to various choices of one element from each, but there's no longer a single correct way to iterate over these elements.

BQN has two 1-modifiers to map over arrays: Each (`¨`) and Table (`⌜`). On two arguments, Table applies its operand to all combinations of elements while Each creates a one-to-one or one-to-many matching. Since they apply to elements, these modifiers are different from Cells (`˘`) or its generalization Rank (`⎉`), which apply the function to array cells. The modifier [Depth](depth.md#the-depth-modifier) (`⚇`) is a generalization of Each, so that `¨` is `⚇¯1`; however, it can't be used to implement Table without some additional array operations.

## One-argument mapping

<!--GEN
xt ← ("x"∾'0'⊸+)¨ ↕5
d ← 80‿72
Pos ↩ Pos d⊸×

lcol ← "#521f5e"‿"#7f651c"

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "fill=currentColor|font-family=BQN,monospace"
dg ← "font-size=24px|fill=currentColor|opacity=0.9"
tg ← "font-size=18px|text-anchor=middle"
cg ← "font-size=22px|text-anchor=end|dy=0.2"
bg ← "class=bluegreen|stroke-width=3|stroke-linecap=round|style=fill:none|opacity=0.7"

lg ← At"stroke-width=8|opacity=0.1"
Gl ← {("g"Attr"stroke"‿𝕨∾lg)Enc𝕩}

bo ← -⌾⊑⊸≍÷12‿5
Gb ← {
  bb ← ⟨(÷2)-˜⊑𝕨,≠𝕨⟩+0.1×⟨1,¯2⟩
  𝕩 {∾"M l l "∾¨FmtNum⥊d⊸×˘⟨+⟜(𝕩⊸×)´bb,𝕨-0.28⟩∾𝕩⌽bo}⌜ ↕2
}

Text ← ("text" Attr Pos)⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d×⊢
Path ← "path" Elt "d"⋈⊢
{
  dim ← 7.5‿2.2 ⋄ sh ← ¯2.3‿¯0.1
  tx ← ↕≠xt ⋄ ty ← 0.7+↕2

  ((∾˜d)×((-∾+˜)0.5‿0.2)+sh∾dim) SVG g Ge ⟨
    "rect" Elt rc ∾ (Pos 1‿0×sh)∾"width"‿"height"≍˘FmtNum d×dim
    dg Ge ¯2.1‿0.1 Text "Each/Table"
    (1⊑lcol) Gl (Line ≍˜≍(0.2(⊣≍-˜)⊢´dim)˙)¨ tx
    tg Ge (⍉tx≍⌜ty) Text¨ (⊢≍(Highlight"𝔽")⊸∾¨) xt
    cg Ge (¯1.1≍¨ty) Text⟜Highlight¨ "𝕩"‿"𝔽¨𝕩"
    bg Ge Path¨ tx Gb ty
  ⟩
}
-->

On one argument, Each and Table are identical. They apply the function `𝔽` to every element of `𝕩`, and return an array with the same shape that contains each result.

        ↕⌜ 3‿4‿2

        ↕¨ 2‿2⥊3‿4‿2

A nice way to examine what's being applied here is to make an argument where each element is a string describing itself, and an operand that describes its own application: `"𝔽"⊸∾` will place an `𝔽` in front of the argument, which is how functions are applied.

        "𝔽"⊸∾¨ "0⊑𝕩"‿"1⊑𝕩"‿"2⊑𝕩"

        {('0'+𝕩)∾"⊑𝕩"}⌜ ↕3  # Making 𝕩 with mapping instead

The applications are performed in index order: index `…0‿0`, then `…0‿1`, `…0‿2` and so on, until `…1‿0`. This can affect a program where the operand has side effects, such as the following one that appends its argument to `o`.

        o←⟨⟩ ⋄ {o∾⟜<↩𝕩}¨ "index"≍"order" ⋄ o

When an array is displayed, index order is the same as the top-to-bottom, left-to-right reading order of English. It's also the same as the ordering of [Deshape](reshape.md#deshape)'s result, so that here `o` ends up being `⥊𝕩`. The dyadic cases described in the following sections will also have a defined evaluation order, but it's not as easy to describe it in terms of the arguments: instead, the *result* elements are produced in index order.

## Table

<!--GEN
{
  wt ← ("w"∾'0'⊸+)¨ ↕3
  dim ← 6.7‿4.4 ⋄ sh ← ¯1.58‿¯0.1
  tx‿ty ← (p0←¯0.9‿0.8) + (↕1+≠)¨xt‿wt
  cg ← "font-size=19px|text-anchor=middle"
  rb ← {
    o←(1.5⋆¬𝕩)×(18÷d)×𝕩⌽¯1‿1
    ∾"M hv"∾¨FmtNum⥊d⊸×˘o(-˜⌾⊑≍⊣)(0≍𝕩⊑÷15‿¯6)+0.5+(-𝕩)⊑¨⟨0.15+tx,ty⟩
  }⌜ ↕2
  tx +↩0.15×0<tx
  wb ← (1↓ty) {
    bb ← ⟨(÷2)-˜⊑𝕨,≠𝕨⟩+0.2×⟨1,¯2⟩
    𝕩 {∾"M l l "∾¨FmtNum⥊d⊸×˘⌽˘⟨¯0.08++⟜(𝕩⊸×)´bb,𝕨-0.2⟩∾𝕩⌽bo}⌜ ↕2
  } ⊏tx

  ((∾˜d)×((-∾+˜)1‿0.2)+sh∾dim) SVG g Ge ⟨
    "rect" Elt rc ∾ (Pos 1‿0×sh)∾"width"‿"height"≍˘FmtNum d×dim
    dg Ge ¯1.4‿0.1 Text "Table"
    lcol Gl¨ Line¨¨ ⟨
      (((⊑sh)+0.26(⊣≍-˜)⊑dim)˙≍≍˜)¨ ¯0.06+1↓ty
      (≍˜≍(0.3(⊣≍-˜)⊢´dim)˙)¨ 1↓tx
    ⟩
    tg Ge (⍉tx≍⌜ty) Text¨ wt ((<"")⊸∾∾⊣∾˘∾⟜(Highlight"𝔽")⊸∾⌜) xt
    cg Ge (p0⊸+¨⟨¯0.4‿0.6,0.6‿¯0.4⟩) Text¨ "𝕨"‿"𝕩"
    ("Text" Attr (Pos p0+÷¯6‿16)∾"font-size"‿"26px") Enc Highlight "𝔽⌜"
    bg Ge Path¨ (⥊(1↓tx) Gb ⊏ty) ∾ (⥊wb) ∾ rb
  ⟩
}
-->

The Table modifier applies its operand function to every possible combination of one element from `𝕨` and one from `𝕩`, sort of like a structure-preserving and function-applying [Cartesian product](https://en.wikipedia.org/wiki/Cartesian_product). Below, it combines a length-3 list and a length-5 list into a shape `3‿5` table.

        "ABC" ≍⌜ "01234"

Its name comes from the "multiplication table" or "times table" often used to teach arithmetic, and with it you can easily make such a table, by repeating the same argument with Self (`˜`):

        ×⌜˜ 1+↕6

The arguments don't have to be lists (that is, rank 1). There's no restriction on their shapes at all! Much like the result shape is `m‿n` if `𝕨` is a list of length `m` and `𝕩` is a list of length `n`, the result shape for an array `𝕨` of shape `r` and `𝕩` of shape `s` is `r∾s`.

        "A "‿"B " ∾⌜ "the"‿"first"‿"row"≍"and"‿"the"‿"second"

        ≢ "A "‿"B " ∾⌜ "the"‿"first"‿"row"≍"and"‿"the"‿"second"

Except for the more sophisticated shape, this result is exactly what you'd get if you deshaped each argument to a list. In each case, every element of `𝕨` is visited in turn, and each time the element is paired with every element of `𝕩`.

## Each

<!--GEN
{
  wt ← ("w"∾'0'⊸+)¨ ↕5
  dim ← 7.5‿3.2 ⋄ sh ← ¯2.3‿¯0.1
  tx ← ↕≠xt ⋄ ty ← 0.7+↕3

  da ← "id=gr|gradientUnits=userSpaceOnUse|x1=0|x2=0|y1=14.4|y2=216"
  Stop ← "stop" Elt "offset"‿"stop-color"≍˘⋈
  defs ← "defs" Enc ("linearGradient"At da) Enc "0%"‿"70%" Stop¨ lcol

  ((∾˜d)×((-∾+˜)0.5‿0.2)+sh∾dim) SVG defs ∾ g Ge ⟨
    "rect" Elt rc ∾ (Pos 1‿0×sh)∾"width"‿"height"≍˘FmtNum d×dim
    dg Ge ¯2‿0.1 Text "Each"
    "url(#gr)" Gl (Line ≍˜≍(0.2(⊣≍-˜)⊢´dim)˙)¨ tx
    tg Ge (⍉tx≍⌜ty) Text¨ wt (≍∾∾⟜(Highlight"𝔽")⊸∾¨) xt
    cg Ge (¯1.1≍¨ty) Text⟜Highlight¨ "𝕨   "‿"𝕩"‿"𝕨𝔽¨𝕩"
    bg Ge Path¨ tx Gb ty
  ⟩
}
-->

Given two arguments of matching shapes, Each performs what's sometimes called a "zip", matching each element of `𝕨` to the corresponding element of `𝕩`.

        "ABCD" ≍¨ "0123"

This makes for a lot fewer applications than Table. Only the diagonal elements from Table's result are seen, as we can check with [Transpose](transpose.md).

        0‿0 ⍉ "ABCD" ≍⌜ "0123"

If the argument lengths don't match then Each gives an error. This contrasts with zip in many languages, which drops elements from the longer argument (this is natural for linked lists). This flexibility is rarely wanted in BQN, and having an error right away saves debugging time.

        "ABC" ≍¨ "01234"

Arguments can have any shape as long as the axis lengths match up. As with Table, the result elements don't depend on these shapes but the result shape does.

        (>⟨20‿30‿10,50‿40‿60⟩) +⟜↕¨ 2‿1‿0≍3‿2‿1

But arguments don't have to have exactly the same shape: just the same length along corresponding axes. These axes are matched up according to the [leading axis convention](leading.md), so that one argument's shape has to be a prefix of the other's. With equal ranks, the shapes do have to match as we've seen above.

        ≢ (0‿2‿6⥊@) ≍¨ 0‿1⥊0  # Too small
        ≢ (0‿2‿6⥊@) ≍¨ 0‿2⥊0  # Just right
        ≢ (0‿2‿6⥊@) ≍¨ 0‿3⥊0  # Too large

Leading axis agreement is described further [here](leading.md#leading-axis-agreement).
