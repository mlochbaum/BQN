*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/reshape.html).*

# Deshape and Reshape

<!--GEN
xt ← Highlight∘•Repr¨ 100‿0‿200+⌜0‿50+⌜↕7
d ← 64‿36

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "fill=currentColor|stroke-linecap=round|font-family=BQN,monospace"
dg ← "font-size=22px|fill=currentColor|opacity=0.9"
tg ← "font-size=18px|text-anchor=end"
bg ← "class=bluegreen|stroke-width=3|style=fill:none|opacity=0.7"
lg ← "stroke=#3b285c|fill=none|stroke-width=4|stroke-linejoin=round|opacity=0.5"

Text ← ("text" Attr "dy"‿"0.33em"∾Pos)⊸Enc
Pd ← ·∾∾¨⟜FmtNum
Path ← ("path"At⊣) Elt "d"⋈⊢

pad ← 48‿51 ⋄ sh ← 0‿0
dim ← (pad-0‿7) + ¯1⊑¨ tx‿ty ← pad+d× ¯1(⊑{⟨↕𝕨,⥊+⌜´(↕¨×·×`⌾⌽1+«)𝕩⟩}↓)≢xt
tb ← >0‿¯1⊸⊏¨tx‿ty
cg ← "font-size=19px|text-anchor=middle"
bp ← ⥊⌽(20×1.5‿¯1) (+⌾⊑ ≍ -⊸≍∘⊣)˘ 29‿21-⊸≍⊸+⍉tb

(((-∾+˜)64‿15)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ (Pos sh)∾"width"‿"height"≍˘FmtNum dim
  dg Ge 23‿¯2 Text "Index order"
  lg Path ∾⟨
    ('M'⌾⊑"L "⥊˜≠)⊸Pd ∾⥊ty≍˜⌜(-⊸≍20)+⊏tb
    (≠⥊"M l l "˙)⊸Pd ⥊ 24‿12⊸(-˜∾⊣∾-⌾⊑∘⊣)˘ ⍉>44‿0+0‿2‿5⊸⊏¨tx‿ty
  ⟩
  bg Path ("M hv" ∾˜⊸Pd bp) ∾ "m v" Pd 0‿16‿12
  tg Ge (⍉(tx+16)≍⌜ty) Text¨ ∾˝xt
⟩
-->

The glyph `⥊` indicates BQN's facilities to reflow the data in an array, giving it a different shape. Its monadic form, Deshape, simply removes all shape information, returning a list of all the elements from the array in reading order. With a left argument, `⥊` is called Reshape and is a more versatile tool for rearranging the data in an array into the desired shape.

Because of its dependence on the reading order of an array, Reshape is less fundamental than other array operations. Using Reshape in the central computations of a program can be a sign of imperfect usage of arrays. For example, it may be useful to use Reshape to create a constant array or repeat a sequence of values several times, but the same task might also be accomplished more simply with [Table](map.md#table) `⌜`, or by taking advantage of [leading axis agreement](leading.md#leading-axis-agreement) in arithmetic primitives.

## Deshape

The result of Deshape is a list containing the same elements as the argument.

        ⊢ a ← +⌜´ ⟨100‿200, 30‿40, 5‿6‿7⟩

        ⥊ a

The elements are ordered in reading order—left to right, then top to bottom. This means that leading axes "matter more" for ordering: if one element comes earlier in the first axis but later in the second than some other element, it will come first in the result. In another view, elements are ordered according to their [indices](indices.md). In other words, deshaping the array of indices for an array will always give a [sorted](order.md) array.

        ↕≢a

        ⍋ ⥊ ↕≢a

This ordering is also known as *row-major* order.

Deshape turns a unit argument into a single-element list, automatically [enclosing](enclose.md) it if it's an atom. However, if you know `𝕩` is a unit, a more principled way to turn it into a list is to apply [Solo](couple.md) (`≍`), which adds a length-1 axis before any other axes. If you ever add axes to the data format, Solo is more likely to continue working after this transition, unless there's a reason the result should always be a list.

        ⥊ 2
        ≍ 2

## Reshape

While Deshape removes all shape information from its argument array, Reshape adds shape information back based on the left argument. Reshape ignores the shape of its original argument, treating it like a list of elements as though it were deshaped initially.

The left argument of Reshape gives the shape of the result, except that one entry can be left unspecified for BQN to fill in. We'll look at the cases where a full shape is given first.

### Matching lengths

If the number of elements implied by the given shape—that is, `×´𝕨`—is equal to the number of elements in `𝕩`, then `𝕩` is simply rearranged to match that shape. The element list is kept the same, so that the deshaped result matches the deshaped right argument.

        a

        6‿2 ⥊ a

        (⥊a) ≡ ⥊ 6‿2⥊a

One common use is to generate an array with a specified shape that counts up from 0 in reading order, a reshaped [Range](range.md). The idiomatic phrase to do this is `⥊⟜(↕×´)`, since it doesn't require writing the shape and its product separately.

        2‿7 ⥊ ↕14
        ⥊⟜(↕×´) 2‿7

### Non-matching lengths

If `𝕨` implies a smaller number of elements than are present initially, then only the initial elements of `𝕩` are used. Here the result stops at `237`, three-quarters of the way through `a`, because at that point the result is filled up.

        3‿3 ⥊ a

If `𝕨` implies a larger number of elements, then elements of `𝕩` are reused cyclically. Below, we reach the last element `247` and start over at `135`. If `𝕩` doesn't have any elements to start with, you'll get an error as there aren't any elements available.

        15 ⥊ a

        4 ⥊ ↕0

Reshape is the idiomatic way to make an array filled with a constant value (that is, where all elements are the same) when you know what shape it should have. For an atom element, reshape it directly; for an arbitrary element, first [enclose](enclose.md) it to create a unit, and then reshape it.

        3‿4 ⥊ 0

        5 ⥊ < "string"

### Computed lengths

What if you want to reshape an array into, say, rows of length 2, but don't want to write out the number of rows?

        ∘‿2 ⥊ "aAeEiIoOuU"

Above, the length given is `∘`, a special value that indicates that a length that fits the argument should be computed. In fact, Reshape has four different special values that can be used. Every one works the same for a case like the one above, where the rest of the shape divides the argument length evenly. They differ in how they handle uneven cases, where the required length would fall between two whole numbers.

- `∘` says the length must be an exact fit, and gives an error in such a case.
- `⌊` rounds the length down, so that some elements are discarded.
- `⌽` rounds the length up, repeating elements to make up the difference.
- `↑` rounds the length up, but uses the argument's fill for the needed extra elements.

These values are just BQN primitives of course. They're not called by Reshape or anything like that; the primitives are just chosen to suggest the corresponding functionality.

Here's an example of the four cases. If we try to turn five elements into two rows, `∘` gives an error, `⌊` drops the last element, `⌽` uses the first element again, and `↑` uses a fill element (like `6↑"abcde"` would).

        2‿∘ ⥊ "abcde"

        2‿⌊ ⥊ "abcde"

        2‿⌽ ⥊ "abcde"

        2‿↑ ⥊ "abcde"

A computed length can be useful to input an array without using nested notation: for example, if you have a table with rows of three elements, you might write it as one long list, using `∘‿3⥊⟨…⟩` to get it back to the appropriate shape. `∘` is definitely the value to use here, as it will check that you haven't missed an element or something like that.

Computed Reshape might also be used in actual data processing: for example, to sum a list in groups of four, you might first reshape it using `↑‿4` for the shape, then average the rows. Here the code `↑` is useful because added fill elements of `0` won't change the sum, so that if the last group doesn't have four elements (`9‿7` below), it will still be summed correctly.

        +´˘ ↑‿4 ⥊ ⟨0,2,1,1, 5,9,6,4, 3,3,3,3, 9,7⟩

Computed Reshape can even be used with structural Under. Only the `∘` case really makes sense, although `⌊`, which leaves trailing elements unchanged, could conceivably be useful. Below, we split one argument into three groups and [reverse](reverse.md) their order, and reverse groups of three in another.

        ⌽⌾(3‿∘⊸⥊) ↕15

        ⌽⌾(∘‿3⊸⥊) "nolyricshere"
