*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/replicate.html).*

# Indices and Replicate

<!--GEN
d ← 48‿22

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-family=BQN,monospace|font-size=18px|text-anchor=middle"
hg ← "class=bluegreen|stroke-width=0|opacity=0.2"
cg ← "font-size=24px|text-anchor=end"
lg ← "class=lilac|stroke-linecap=round"

wv ← 0‿1‿1‿0‿3‿2‿0‿0‿0
xl ← ≠ xc ← ⊐ xt ← '''(Highlight∾∾⊣)¨"replicate"

Text ← ("text" Attr "dy"‿"0.29em"∾(Pos d⊸×))⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d×⊢
Rp ← Pos⊸∾⟜("width"‿"height"≍˘FmtNum)○(d⊸×)

tx ← ↕xl ⋄ y ← » yd ← +`0.6+1‿2‿1‿1.8
dim ← ⟨2+xl,¯1⊑yd⟩ ⋄ sh ← ¯2.1‿¯1.3
tp ← y ≍˜¨¨ 2 / ⟨tx,↕+´wv⟩
hp ← 0.2‿¯0.7(+⟜(1‿0×sh)≍¯2⊸×⊸+)1‿0×dim
Ll ← Line∘⍉ ≍ + (0≍0.05×-○⊑)≍˘0.45‿¯0.55˙

((∾˜d)×((-∾+˜)0.7‿0.4)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ sh Rp dim
  hg Ge ("rect" Elt ·Rp˝ {𝕩⊸+⌾(1⊑⊏)hp})¨ 0‿2⊏y
  cg Ge (¯0.7≍¨y) Text⟜Highlight¨ "𝕩"‿"𝕨"‿"𝕨/𝕩"‿"/𝕨"
  tp Text¨○∾ Highlight∘•Repr¨¨⌾(1‿3⊸⊏) xt‿wv‿(wv/xt)‿(/wv)
  lg Ge ⟨
    "stroke-width=0.6" Ge   Ll¨ ´ (0=wv)⊸/¨  2⊸↑ tp
    "stroke-width=1.8" Ge > Ll¨¨˝˘ 2↕ wv⊸/¨⌾(2⊸↑)tp
  ⟩
⟩
-->

The functions Indices and Replicate are used to copy or filter data. They might be described as transforming a [run-length encoding](https://en.wikipedia.org/wiki/Run-length_encoding) into unencoded form. On the other hand, Indices might be described as giving a sparse representation of `𝕩`, which is smaller if `𝕩` mostly consists of zeros.

BQN doesn't have any of the various features used in APL to add fills to the result of Replicate, like negative numbers in `𝕨` or an Expand (`\`) primitive. An alternative to Expand is to use Replicate with structural Under (`⌾`) to insert values into an array of fills.

## Replicate

Given a list of natural numbers `𝕨`, Replicate repeats each major cell in `𝕩` the corresponding number of times. That is, `𝕨` and `𝕩` must have the same length, and the result includes `i⊑𝕨` copies of each cell `i⊏𝕩`, in order.

        2‿1‿0‿2 / "abcd"

        ⊢ a ← >"aa0"‿"bb1"‿"cc2"‿"dd3"

        2‿1‿0‿2 / a

It's also allowed for `𝕨` to be a single number (or enclosed number: it just needs to be a unit and not a list). In this case every cell of `𝕩` is repeated that number of times.

        3 / "copy"

When `𝕨` is a list of booleans, a cell is never repeated more than once, meaning that each cell of `𝕩` is either left out (0), or kept in (1). If `Fn` is a function with a boolean result, `Fn¨⊸/` filters elements of a list according to `Fn`.

        1‿1‿0‿0‿1‿0 / "filter"

        ≤⟜'i' "filter"

        ≤⟜'i'⊸/ "filter"

Here `≤⟜'i'` is a pervasive function, so there's no need to add `¨`. Similarly, to filter major cells of an array, `Fn˘⊸/` could be used, applying `Fn` to one major cell at a time.

A similar pattern applies to Replicate as well. The function below tests which input characters are double quotes, but by adding one it changes the result to 1 for each non-quote character and 2 for quotes (but source code and display also double quotes here, so the input string has only two `"`s and the output has four).

        {1+'"'=𝕩}⊸/ "for ""escaping"" quotes"

### Compound Replicate

If `𝕨` has [depth](depth.md) two, then its elements give the amounts to copy along each [leading axis](leading.md) of `𝕩`.

        ⊢ b ← 2‿5 ⥊ ↕10

        ⟨2‿0, 1‿0‿0‿1‿1⟩ / b

        2‿0 / 1‿0‿0‿1‿1⊸/˘ b

Here the `2‿0` indicates that the first row of `b` is copied twice and the second is ignored, while `1‿0‿0‿1‿1` picks out three entries from that row. As in the single-axis case, `𝕩` can have extra trailing axes that aren't modified by `𝕨`. The rules are that `𝕨` can't have *more* elements than axes of `𝕩` (so `(≠𝕨)≤=𝕩`), and that each element has to have the same length as the corresponding axis—or it can be a unit, as shown below.

        ⟨<2,<3⟩ / b

Above, both elements of `𝕨` are [enclosed](enclose.md) numbers. An individual element doesn't have to be enclosed, but I don't recommend this, since if *none* of them are enclosed, then `𝕨` will have depth 1 and it will be interpreted as replicating along the first axis only.

        ⟨2,3⟩ / b

The example above has a different result from the previous one! The function `<¨⊸/` could be used in place of `/` to replicate each axis by a different number.

If `𝕨` is `⟨⟩`, then it has depth 1, but is handled with the multidimensional case anyway, giving a result of `𝕩`. The one-dimensional case could also only ever return `𝕩`, but it would be required to have length 0, so this convention still only extends the simple case.

        b ≡ ⟨⟩ / b

## Indices

The monadic form of `/` is much simpler than the dyadic one, with no multidimensional case or mismatched argument ranks. `𝕩` must be a list of natural numbers, and `/𝕩` is the list `𝕩/↕≠𝕩`. Its elements are the [indices](indices.md) for `𝕩`, with index `i` repeated `i⊑𝕩` times.

        / 3‿0‿1‿2

A unit argument isn't allowed, and isn't very useful: for example, `/6` might indicate an array of six zeros, but this can be written `/⥊6` or `6⥊0` with hardly any extra effort.

When `𝕨` has rank 1, `𝕨/𝕩` is equivalent to `𝕨/⊸⊏𝕩`. Of course, this isn't the only use of Indices. It also gets along well with [Group](group.md): for example, `/⊸⊔` groups `𝕩` according to a list of lengths `𝕨`.

        2‿5‿0‿1 /⊸⊔ "ABCDEFGH"

This function will fail to include trailing empty arrays; the modification `(/∾⟜1)⊸⊔` fixes this and ensures the result always has as many elements as `𝕨`.

If `𝕩` is boolean then `/𝕩` contains all the indices where a 1 appears in `𝕩`. Applying `-⟜»` to the result gives the distance from each 1 to the [previous](shift.md), or to the start of the list, another potentially useful function.

        / 0‿1‿0‿1‿0‿0‿0‿0‿1‿0

        -⟜» / 0‿1‿0‿1‿0‿0‿0‿0‿1‿0

With more effort we can also use `/` to analyze groups of 1s in the argument (and of course all these methods can be applied to 0s instead, by first flipping the values with `¬`). First we highlight the start and end of each group by comparing the list with a shifted copy of itself. Or rather, we'll first place a 0 at the front and then at the end, in order to detect when a group starts at the beginning of the list or ends at the end (there's also a shift-based version, `≠⟜«0∾𝕩`).

        0 (∾≍∾˜) 0‿1‿1‿1‿0‿0‿1‿0‿1‿1‿0

        0 (∾≠∾˜) 0‿1‿1‿1‿0‿0‿1‿0‿1‿1‿0

        / 0(∾≠∾˜) 0‿1‿1‿1‿0‿0‿1‿0‿1‿1‿0

So now we have the indices of each transition from 0 to 1 or 1 to 0, in an extended list with 0 added at the beginning and end. The first index has to be for a 0 to 1 transition, because we forced the first value to be a 0, and then the next can only be 1 to 0, then 0 to 1, and so on until the last, which must be 1 to 0 because the last value is also 0.

        -˜`˘ ∘‿2⥊/ 0(∾≠∾˜) 0‿1‿1‿1‿0‿0‿1‿0‿1‿1‿0

This means the transitions can be grouped exactly in pairs, the beginning and end of each group. Reshape with a [computed length](reshape.md#computed-lengths) `∘‿2` groups these pairs, and then a scan ``-˜`˘`` can be used to convert the start/end format to start/length if wanted.

### Inverse

The result of Indices `/n` is an ordered list of natural numbers, where the number `i` appears `i⊑n` times. Given an ordered list of natural numbers `k`, the [*inverse*](undo.md) of indices returns a corresponding `n`: one where the value `i⊑n` is the number of times `i` appears in `k`.

        / 3‿2‿1

        /⁼ 0‿0‿0‿1‿1‿2

Finding how many times each index appears in a list of indices is often a useful thing to do, and there are a few ways to do it:

        +˝˘ (↕5) =⌜ 2‿2‿4‿1‿2‿0  # Inefficient

        ≠¨⊔ 2‿2‿4‿1‿2‿0

        /⁼ 2‿2‿4‿1‿2‿0

The last of these is an extension defined in the language specification. As we said, the result of Indices is always sorted, so properly there's no argument that could return `2‿2‿4‿1‿2‿0`. But the index-counting function is very useful, so `/⁼` is defined to implicitly sort its argument (which is still required to be a list of natural numbers). Since `/⁼` is implemented as a single operation, it's the best way to perform this counting task.
