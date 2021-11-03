*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/array.html).*

# The array

As BQN is an array language, it's often helpful to understand what an array is when writing BQN programs. Fully describing the concept is sometimes [held to be tricky](https://www.jsoftware.com/papers/array.htm); here we'll see definitions, examples, and metaphors.

In BQN, as in APL, arrays are multidimensional, instead of strictly linear. Languages like Python, Javascript, or Haskell offer only one-dimensional arrays with `[]` syntax, and typically represent multidimensional data with nested arrays. Multidimensional arrays have fundamental differences relative to this model.

BQN's arrays are immutable, meaning that an array is entirely defined by its attributes, and there is no way to modify an existing array, only to produce another array that has changes relative to it. As a result, an array can never contain itself, and arrays form an inductive type. BQN's [mutable](lexical.md#mutation) types are operations and namespaces.

An array might also have a [fill element](fill.md) that captures some structural information about its elements and is used by a few operations. The fill, as an inferred property, isn't considered to truly be part of the array but is instead some information about the array that the interpreter keeps track of. So it's out of scope here.

<!--GEN
xt ← ∾˝ Highlight∘•Repr¨ xv ← 3‿2‿6⥊×˜2+3×↕5
xs ← ≢ xv
d ← 64‿36

Ge ← "g"⊸At⊸Enc
g  ← "fill=currentColor|stroke-linecap=round|text-anchor=middle|font-size=14|font-family=BQN,monospace"
dg ← "font-size=24px|opacity=0.9|text-anchor=start"
tg ← "font-size=18px|text-anchor=end"
bg ← "class=bluegreen|stroke-width=3|style=fill:none|opacity=0.8"
gg ← "stroke=currentColor|stroke-width=1.5|opacity=0.1"
pg ← "class=purple|stroke-width=2|style=fill:none"

Text ← ("text" Attr "dy"‿"0.33em"∾Pos)⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ FmtNum
Path ← "path"⊘("path"At⊣) Elt "d"⋈⊢
Pd ← ·∾∾¨⟜FmtNum
Rd ← Pos∘⊣ ∾ "width"‿"height"≍˘FmtNum∘⊢
Rect ← "rect"⊸At⊸Elt

strd ← (1⊑d) × str ← ×`⌾⌽1+«¯1↓xs
elp ← ⌽ ¯1 (+´∘↓≍⊑) xs (×`⌾⌽1⊸«)⊸×⌾(¯1⊸↓) el ← 2‿0‿3

pad ← 48‿40 ⋄ off ← pad+d+0‿28 ⋄ sh ← ¯4‿0
dim ← pad + ¯1⊑¨ tx‿ty ← off+d× ¯1(⊑{⟨↕𝕨,⥊+⌜´str×↕¨𝕩⟩}↓)xs
bp ← ⥊⌽(21×1.5‿¯1) (+⌾⊑ ≍ -⊸≍∘⊣)˘ 29‿21-⊸≍⊸+ ⍉> 0‿¯1⊸⊏¨tx‿ty

Tr ← {(𝕨⊢⊘(At˜)"g") Attr "transform"‿𝕩}
Tt ← Tr "translate("∾")"∾˜∾⟜","⊸∾´∘FmtNum

axp ← off⊸+¨<˘(⟨tx-⊑off,0⟩-0.35‿1.3×d) ∾ ⍉ (1‿0.3×d) -˜ (0.5‿0×-⊑d)≍strd×↕¨¯1↓xs
axd ← 50∾10(⊢-«)strd

(((-∾+˜)32‿15)+sh∾dim) SVG g Ge ⟨
  "class=code|stroke-width=1.5|rx=12" Rect sh Rd dim
  dg Ge 23‿¯2 Text "Array properties"
  "fill=#7f651c|opacity=0.1"Rect {⟨elp⊑⊸⊑tx,𝕩⟩(- Rd 2×⊢)23≍𝕩-14}2÷˜⊢´dim
  bg Path ("M hv"∾˜⊸∾"m v") Pd bp∾0‿16‿12
  tg Ge (⍉(tx+16)≍⌜ty) Text¨ xt

  ("font-size=18" Tr "rotate(-90)") Enc (-⌾⊑⌽off+d×¯0.9‿5) Text "Axis 0"
  ((off⊣⌾(¯1⊸⊑)elp⊑¨tx‿ty)-d×0‿1.8) Text "Position "∾•Repr ¯1⊑el
  (Tt elp⊑¨tx‿ty) Enc ⟨
    pg Path "M hvh" (Pd∾"z"˙) (÷⟜¯2∾(⊢∾-∘⊏)∘⊢) 0.7‿0.9×d
    (d×0‿¯1.2) Text "Element at "∾1↓∾"‿"⊸∾¨•Repr¨el
    (d×0‿¯0.75) Text "Value "∾•Repr el⊑xv
  ⟩

  "class=yellow" Ge ⟨
    "font-size=22px" Ge (0.7‿0.8‿0.25{(d×0.1‿0.25-(=⊑𝕩)⌽0‿𝕨)+⊑¨𝕩}¨1⌽axp) Text¨ FmtNum xs
    (off-1.1‿1.4×d) Text "Shape"
  ⟩
  "class=bluegreen|font-size=16" Ge (off-0.95‿1.95×d) Text "Rank 3"
  gg Path ∾ axd {o←=⊑𝕩 ⋄ ("M "∾o⊏"VH") Pd 16⊸+⌾(o⊸⊑)(⊑∾𝕨+o¬⊸⊑⊢´) ≍¨´𝕩}¨ axp
  pg Path ∾ axd {(("M "∾3⥊"hv"⌽˜=⊑𝕩)⥊˜≠)⊸Pd ∾∾⟜16‿𝕨‿6¨ ≍¨´𝕩}¨ axp
  ∾{Text⟜("0"⊸+)¨⟜(↕≠) 8+≍¨´𝕩}¨ axp
⟩
-->

## Rectangles

A BQN **array** is a multidimensional arrangement of data. The word "array" descends from words meaning "order", and the data in an array is ordered indeed. Below are examples of arrays with zero, one, and two dimensions.

        <5

        ⟨3,'x',1⟩

        2‿3‿4 ×⌜ 1‿5‿8‿11

Each dimension, or **axis**, has some finite number of positions, with an **element** at every *combination* of positions. For example, if a group of friends shop at several different stores, the amount they spend in a week could be placed in a two-dimensional array, with people along one axis and stores along another. An element of the array would indicate how much one person spent at one store, so that summing across stores gives each person's expenditures and summing across people gives each store's income.

The axes of an array must be independent, that is, the positions present in one axis are fixed for the entire array and don't depend on other axes. This is a difference relative to a nested list model. When storing data in nested lists, the outer axis comes first and later axes are subordinate to it. The length of the second axis depends completely on the position in the first. A programmer might choose the lengths so it doesn't in a particular case, but in a BQN array differing lengths simply aren't representable.

The array also needs to be complete. Every element—every combination of positions—must have a value. This value could be a placeholder like `@`, but it has to be *something* (in the spending example, everyone spends some amount at each store, even if it's zero). And of course, there are no extra elements that don't fit into the positioning system—the [fill](fill.md) isn't really part of the array, but extra information about it.

## Ordering and indices

To finish this definition of an array we also need to nail down the idea of a position. The positions along one dimension can't be labelled in any way, but they have a linear ordering (mathematically speaking, a [total order](https://en.wikipedia.org/wiki/Total_order): out of any two different positions one comes earlier and the other later). BQN keeps track of this order: for example, when we [join](join.md) two arrays it places positions in `𝕨` before those of `𝕩` and otherwise maintains the original ordering.

        "before" ∾ "after"

It's only the ordering that allows positions to be distinguished. BQN labels them with natural numbers called **indices** that can be derived from the order: the earliest position is called `0`, the next `1`, and so on. The axes of an array are also ordered, and they're indexed starting at `0` as well.

These kinds of index are one-dimensional, but there's also a multidimensional kind of array [index](indices.md), that identifies an element. An element index consists of one index along each axis. Because the axis are ordered, it can be represented as a list `l` of numbers, where `i⊑l` is the index along axis `i`. It's important to distinguish an element from its value: for example, there's only one value (`3`) contained in the array `⟨3,3,3⟩`, but it still has three elements, identified by indices `⟨0⟩`, `⟨1⟩`, and `⟨2⟩`.

## Dimensions

The number of axes in an array is called its **rank**. The number of positions along an axis is called its **length**, and the length of an array means its length along the first axis, or `1` if there are no axes. The list of the length along each axis is the array's **shape**, and describes the possible element locations completely. In BQN they're exposed as the [functions](shape.md) Rank (`=`), Length (`≠`), and Shape (`≢`).

The total number of elements in an array is its **bound**, and can be found using [Deshape](reshape.md) with `≠∘⥊`, is then the product of all the lengths in the shape. An array of rank 0, which always contains exactly one element, is called a [**unit**](enclose.md#whats-a-unit), while an array of rank 1 is called a **list** and an array of rank 2 is called a **table**.

## Elements

Any BQN value can be used as an array element, including another array (BQN, as a dynamically-typed language, doesn't restrict the types that can be used in one context without a good reason). However, BQN arrays are restricted relative to another array model. Frameworks like NumPy or Julia have mutable arrays, so that the value of an element can be changed after the array is created. This allows an array to be its own element, by creating an array and then inserting it into itself. This would be unnatural in BQN, where an array can only be formed from elements that already exist. In BQN only operations and namespaces are [mutable](lexical.md#mutation).

## Properties

Summarizing, the values needed to define an array are its rank (the number of axes), its shape (the number of positions along each axis), and the value of each element (that is, at each combination of positions). Two arrays [match](match.md) when all these values match.

If the rank is considered to be part of the shape, as it is when the shape is a BQN list, then the array is defined by its shape and element list—from [deshape](reshape.md).

Here's a somewhat informal mathematical take. Given a set of possible element values `T`, a *list* of `T` of length `l` is a map from natural numbers less than `l` to `T`. An array is a rank `r`, along with a list `s` of natural numbers of length `r`, and a map from lists of natural numbers `i` that satisfy `i(j) < s(j)` for all natural numbers `j<r` to BQN values. Arrays are an inductive type, so that an array can only be defined using elements that already exist. As a result an array's elements are always values of lesser complexity and selecting one element of an array, then an element of that element, and so on, must eventually reach a non-array.

## Why arrays?

The multidimensional array is a fairly simple structure, but there are simpler ones like pairs, lists, sets, and dictionaries. Why does BQN choose the array for its central type? I don't think arrays are always the best data structure (or that BQN is always the best language), but I do think they're one of several good choices and have unique advantages.

Arrays offer a lot of flexibility since they generalize lists. This also means that they can be used to represent pairs or sets. Two lists, or an array with a length-2 axis, can represent a map, although it could be hard to use with good performance.

But arrays are less flexible than *nested* lists (which in turn are less flexible than nested arrays). This is also in some sense a strength. The axes of an array are inherently independent. Lots of things in real life are independent! Regardless of which main you choose in your Cook Out tray you have the same options for sides. A term in a multivariate polynomial can have any power of `x` and any power of `y`. An array language lets you encode this independence in your data, and use operations that take advantage of it.

The rigidity of arrays is also great for performance. Nested lists might have a complicated structure in memory. An array can always be packed flat: the shape and the elements. This strided representation makes branchless and cache-friendly primitive algorithms much easier.
