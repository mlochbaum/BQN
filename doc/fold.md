*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/fold.html).*

# Fold and Insert

<!--GEN
f ← •BQN fn ← "-" ⋄ ft ← Highlight fn
xt ← Highlight∘•Repr¨ xv ← 2‿0‿5‿3‿4‿2
zt ← Highlight∘•Repr¨ F˜`⌾⌽ xv
d ← 56‿40

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-size=21px|fill=currentColor|stroke-linecap=round|text-anchor=middle|font-family=BQN,monospace"
bg ← "class=bluegreen|stroke-width=3|style=fill:none|opacity=0.7"
lg ← "class=lilac|stroke-width=2"

Text ← ("text" Attr "dy"‿"0.32em"∾ ·Pos d⊸×)⊸Enc
Path ← "path" Elt "d"≍○<⊢
Line ← "line" Elt (⍉"xy"≍⌜"12")≍˘○⥊ ·FmtNum ·d⊸×˘⊢

Brak ← {
  l ← 6‿15
  P ← ∾"M l l "∾¨ ·FmtNum∘⥊ ∾
  Path ∾ (((-⊸≍0.4)+0‿¯1⊏𝕨)((0‿¯1×l)+d×≍)⌜𝕩) P¨ ≍○<⟜⌽ -⌾⊑⊸≍l
}

_pair ← {1(↓𝔽-⊸↓)⊢}
tx ← ↕≠xt ⋄ ty ← 0.8+5×↕2
sy ← (2÷˜+´ty)-3×0.5-˜(↕÷-⟜1) ≠sx←2÷˜+_pair tx
tp ← tx≍¨⊑ty ⋄ sp ← sx≍¨sy
dim ← ⟨2.5+≠tx,0.8+1⊑ty⟩ ⋄ sh ← ¯2.3‿0
lp ← 0.35

((∾˜d)×((-∾+˜)1‿0.3)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ (Pos d×sh)∾"width"‿"height"≍˘FmtNum d×dim
  lg Ge Line¨ ∾⟨
    tp (≍+·≍⟜-·(⊢×lp÷1⊸⊑)-)¨ ¯0.25‿0<⊸(+ ∾ ⊣-˜¯1⊏⊢)sp
    ((lp×¯0.5‿1≍1.2‿¯0.5)+≍)¨_pair sp
    ⟨sx {⍉(≍˜𝕨)≍(≍⟜-lp)+𝕩≍1⊑ty}○⊑ sy⟩
  ⟩
  "text-anchor=end" Ge (¯1.1≍¨ty) Text¨ ≍○<⟜(ft∾(Highlight"´")∾⊢) "𝕩"
  (tp∾<(⊑sx)≍1⊑ty) Text¨ xt∾⊏zt
  sp Text¨ (¯1↓xt) ∾⟜ft⊸∾¨ 1↓zt
  bg Ge tx Brak ⊑ty
⟩
-->

The closely related 1-modifiers Fold (`´`) and Insert (`˝`) apply a dyadic operand function `𝔽` repeatedly between elements or major cells of `𝕩`. Neither is quite like the APL2-style Reduce operator (`/` or `⌿` in APL), although I sometimes use the term "reduction" to mean either Fold or Insert. There are a bunch of other names like "accumulate" and "aggregate" for this class of calculations—I don't know which is best but I know "catamorphism" is worst.

A distinguishing feature of APL-family reductions is that they don't use an initial value, and try to derive an "identity element" from the operand if the argument array is empty. BQN retains this capability but also allows the programmer to supply an initial value as `𝕨`.

## Fold

As its glyph suggests, Fold is slightly simpler than Insert. The argument `𝕩` must always be a list, and Fold applies `𝔽` between elements—always two at a time—of the list to yield a single result value. In this sense, `𝔽´` removes a layer of [depth](depth.md) from `𝕩`, although it's not necessarily true that the depth of `𝔽´𝕩` is less than that of `𝕩` because the function `𝔽` might increase depth.

        +´ 2‿4‿3‿1
        +´ ⟨2‿4, 3‿1⟩

Any function can be used as an operand. With Maximum (`⌈`) you can find the largest number out of an entire list, and likewise for Minimum (`⌊`).

        ⌈´ 2‿4‿3‿1
        ⌊´ 2‿4‿3‿1
        ×´ 2‿4‿3‿1  # Product as well

The [logic](logic.md) function And (`∧`) tests if all elements of a boolean list are 1, while Or (`∨`) tests if any are 1.

        ∧´ 1‿1‿0
        ∨´ 1‿1‿0

### Identity values

Folding over a list of length 1 never calls the operand function: it returns the lone element unchanged.

        !´ ⟨⎊⟩

Folding over a list of two values applies `𝔽` once, since `𝔽` is always called on two arguments. But what about zero values? Should `𝔽` be applied minus one times? Sort of. BQN checks to see if it knows an *identity value* for the operand function, and returns that, never calling the function. This works for the arithmetic functions we showed above, always returning a single number.

        +´ ⟨⟩  # Add nothing up, get zero
        ⌈´ ⟨⟩  # The smallest number
        ∧´ ⟨⟩  # All the elements in the list are true…

The full list of identity values Fold has to use is shown below.

| Id   | Fn  | Fn  | Id   |
|-----:|:---:|:---:|-----:|
|  `0` | `+` | `-` |  `0` |
|  `1` | `×` | `÷` |  `1` |
|  `1` | `⋆` | `¬` |  `1` |
|  `∞` | `⌊` | `⌈` | `¯∞` |
|  `0` | `∨` | `∧` |  `1` |
|  `0` | `≠` | `=` |  `1` |
|  `0` | `>` | `≥` |  `1` |

### Right-to-left

The functions we've shown so far are associative (ignoring floating point imprecision), meaning it's equally valid to combine elements of the argument list in any order. But it can be useful to fold using a non-associative function. In this case you must know that Fold performs a *right fold*, starting from the array and working towards the beginning.

        ≍○<´ "abcd"

        'a' ≍○< 'b' ≍○< 'c' ≍○< 'd'  # Expanded form

Using the pair function `≍○<` as an operand shows the structure nicely. This fold first pairs the final two characters `'c'` and `'d'`, then pairs `'b'` with that and so on. This matches BQN's right-to-left order of evaluation. More declaratively we might say that each character is paired with the result of folding over everything to its right.

BQN doesn't provide a left Fold (`` ` `` is Scan). However, you can fold from the left by reversing (`⌽`) the argument list and also reversing (`˜`) the operand function's argument order.

        ≍○<˜´ ⌽ "abcd"

One consequence of this ordering is that folding with Minus (`-`) gives an alternating sum, where the first value is added, the second subtracted, the third added, and so on. Similarly, `÷` gives an alternating product, with some elements multiplied and some divided.

        -´ 30‿1‿20‿2‿10

The operand `+⟜÷` is a quick way to compute a [continued fraction](https://en.wikipedia.org/wiki/Continued_fraction)'s value from a list of numbers. Here are a few terms from the continued fraction for *e*.

        +⟜÷´ 2‿1‿2‿1‿1‿4‿1‿1

### Initial element

When the operand isn't just an arithmetic primitive, folding with no initial element can be dangerous. Even if you know `𝕩` isn't empty, saving you from an "Identity not found" error, the case with only one element can easily violate expectations. Here's a somewhat silly example of a function meant to merge elements of the argument into a single list (`∾⥊¨` is a much better way to do this):

        ∾○⥊´ ⟨2‿4≍6‿8,"abcd",0⟩

        ∾○⥊´ ⟨2‿4≍6‿8,"abcd"⟩

        ∾○⥊´ ⟨2‿4≍6‿8⟩

The result always has rank 1, until the one-element case, when `∾○⥊` is never applied and can't deshape anything. Using Fold with lots of complex operands and no initial element can make a program fragile.

However, it's easy to specify an initial element for Fold: simply pass it as `𝕨`. Because `𝕨` behaves like an element of `𝕩`, it doesn't need to be enclosed and will usually have one smaller depth. For `∾○⥊` the natural starting element for a fold that returns a list is the empty list.

        ⟨⟩ ∾○⥊´ ⟨2‿4≍6‿8⟩

The initial element is used in the first function application, so it behaves as though it's added to the end of the list (`∾⟜<˜` would accomplish this as well).

        "end" ∾○⥊´ ⟨"start","middle"⟩

Folding with `𝕨` never needs to come up with an identity value, and the number of function applications is exactly the length of `𝕩`. A function `P` can be applied to each element of `𝕩` before operating using `𝕨P⊸F´𝕩`, which is equivalent to `𝕨 F´ P¨𝕩` except for the order in which `F` and `P` are invoked (if they have side effects).

        "STOP" ⌽⊸∾´ "ABCDE"‿"012"‿"abcd"

## Insert

Fold only works on lists. What if you want to, say, sum the columns of a table?

        ⊢ tab ← (2+↕5) |⌜ 9+↕3

        +˝ tab

The Insert (`˝`) modifier will do this for you. Because it works on the [leading axis](leading.md) of the argument, Insert can be applied to axes other than the first with Rank. Sum each row (second axis) with `˘`, for example.

        +˝˘ tab

This case is tricky, because `+´˘ tab` yields the same result but is actually unsound—if `tab` contains arrays then they will be merged together at the end. Remember that if you want to reduce along one axis of an array but get an array of results out, you should use Insert (possibly adding Each to work on elements instead of cells; see [APL2 reduction](#apl2-reduction) below).

A function with Insert `𝔽˝` is nearly equivalent to `𝔽´<˘` (and both fail on unit arguments, because there's no axis to apply along). Besides being more convenient, `𝔽˝` is a little safer because it takes the argument shape into account when returning an identity value:

        +´<˘ 0‿4⥊0
        +˝   0‿4⥊0

Just like Fold, Insert allows an initial element for the left argument, so that you don't need to rely on the interpreter knowing the identity. A more complete translation into Fold is therefore `{𝕨𝔽´<˘𝕩}`. The expression below shows that the operand function is called on the last major cell when the identity, then the next-to-last major cell and so on. In total there are `≠𝕩` calls, while there would be `1-˜≠𝕩` without the left argument.

        "id" ≍○<˝ "row0 "∾"row1 "≍"row2 "

One trick involving Insert is `∾˝`, which merges the first two axes of `𝕩` into one long axis. It even works on empty arrays, because BQN knows that there's only one result shape that makes sense (in contrast to `∾´⟨⟩`, where many results sometimes work but none of them always work).

        ⊢ let ← ("AHW"-'A') +⌜ "aA" +⌜ ↕4

        ∾˝ let

        ≢ ∾˝ ↕3‿2‿4

        ≢ ∾˝ ↕0‿2‿4  # The identity is an empty cell

As a historical note, Insert is named after J's adverb `/`, which comes from SHARP APL's `⌿`, reduce-down. In the original APL, only arithmetic reductions were defined, and nested arrays didn't exist—arrays were either all characters or all numbers. SHARP extended them by splitting the array into cells as we've shown. However, there's another interpretation, which is what you'll find in mainstream APLs today…

## APL2 reduction?

If you try an expression like `⍪⌿` in Dyalog APL, you'll get results very different from BQN's `∾˝`. Instead of combining the cells like we see above, APL applies the function on pairs of *elements* much like Fold. The difference is that, because reduction happens only along one axis but an array might have other axes, there can be multiple values in the result, so that it will always be an array like the argument. BQN can perform this operation as well: `⍪⌿` is written `∾¨˝` in BQN.

        ∾¨˝ tab

This kind of reduction has an interesting property that the other two lack: it always removes exacly one axis, so that the result's shape is the argument's major cell shape. When applied to a later axis using the Rank or Cells modifier, it removes that axis instead.

        ≢ ∾¨˝ ↕4‿2‿3   # Reduce out the first axis
        ≢ ∾¨˝˘ ↕4‿2‿3  # Reduce out the second

When the operand is an arithmetic function, say `⌊`, APL2-style reduction is no different from Insert: `⌊¨˝` is the same as `⌊˝`, because `⌊¨` and `⌊` are the same on arrays. That means that Insert with an arithmetic operand also has this axis-removing property.
