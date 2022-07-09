*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/depth.html).*

# Depth

<!--GEN
d ← 48‿38
a ← ⟨⟨@,⟨@,@,@⟩⟩,@,⟨@,@⟩⟩

g ← "g"At"font-family=BQN,monospace|font-size=16px|text-anchor=middle|fill=currentColor|stroke-width=0|stroke=currentColor|stroke-linecap=round"
rc ← At "class=code|stroke-width=1.5|rx=12"
lc ← "line"At"class=lilac|stroke-width=2"
tc ← "text"At"dy=-0.2em|class=Number"
bc ← "path"At"class=bluegreen|stroke-width=2|style=fill:none|opacity=0.4"
dc ← "text"At"font-size=18px|text-anchor=start|opacity=0.9"

Path ← bc Elt "d"⋈⊢
Brak ← {
  P ← ∾"M l l "∾¨ ·FmtNum∘⥊ ∾
  Path (d×⟨0.6×𝕩-0.75,0.4⟩) (-⌾⊑⊸P ∾ P⟜⌽) -⌾⊑⊸≍5‿13
}

TN←tc Enc FmtNum
TL←lc Elt"x2"‿"y2"≍˘·FmtNum 0‿18-˜d×≍⟜1
GTr←{("g"Attr⟨"transform","translate("∾(Fmt d×𝕨)∾")"⟩) Enc 𝕩}
Tree←{
  ds‿ws‿e←<˘⍉>𝕩
  d←1+0⌈´ds
  ww←1⌈+´ws
  p←2÷˜(-ww)+`0⊸»⊸+ws
  ⟨d,ww,⟨TN d,Brak ww⟩∾(TL¨p)∾∾p≍⟜1⊸Gtr¨e⟩
}
n0 ← 0‿1‿⟨TN 0, Path"M h"(∾∾¨)⟜FmtNum (-∾4∾+˜)5.6⟩
dp‿wd‿tr ← {@⊸≢◶⟨n0, Tree𝕊¨⟩𝕩} a

dim ← ⟨1.2+wd,1.3+dp⟩ ⋄ sh ← ⟨-2÷˜⊑dim,¯0.8⟩

((∾˜d)×((-∾+˜)1.7‿0.4)+sh∾dim) SVG g Enc ⟨
  "rect" Elt rc∾(Pos d×sh) ∾ "width"‿"height"≍˘FmtNum d×dim
  (dc Attr Pos d×sh+0.4‿0.1) Enc "List depth"
  tr
⟩
-->

The depth of an array is the greatest level of array nesting it attains, or, put another way, the greatest number of times you can pick an element starting from the original array before reaching an atom. The monadic function Depth (`≡`) returns the depth of its argument, while the 2-modifier Depth (`⚇`) controls the way its left operand is applied based on the depth of its arguments. Several primitive functions also check the depth of the left argument to decide whether it applies to a single axis of the right argument or to several axes.

## The Depth function

To find the depth of an array, use Depth (`≡`). For example, the depth of a list of numbers or characters is 1:

        ≡ 2‿3‿4
        ≡ "a string is a list of characters"

Depth is somewhat analogous to an array's [rank](shape.md) `=𝕩`, and in fact rank can be "converted" to depth by splitting rows with `<⎉1` ([Enclose](enclose.md) [Rank](rank.md) 1), reducing the rank by 1 and increasing the depth. Unlike rank, Depth doesn't care at all about its argument's shape:

        ≡ 3‿4⥊"characters"
        ≡ (1+↕10)⥊"characters"

Also unlike rank, Depth *does* care about the elements of its argument: in fact, to find the depth of an array, every element must be inspected recursively.

        ≡ ⟨2,3,4,5⟩
        ≡ ⟨2,<3,4,5⟩
        ≡ ⟨2,<3,4,<<<5⟩

The depth of an array is the maximum of its elements' depths, plus one. The base case, an atom (including a function or modifier), has depth 0.

        ≡ 'c'
        F←+ ⋄ ≡f
        ≡ ⟨'c',f,2⟩

Using `0=•Type` to test whether `𝕩` is an array, as well as the [Choose](choose.md) modifier, we can write a recursive definition of Depth.

    Depth ← (0=•Type)◶0‿{1+0⌈´Depth¨⥊𝕩}

The minimum element depth of 0 implies that an empty array's depth is 1.

        ≡⟨⟩
        ≡2‿0‿3⥊0

## Testing depth for multiple-axis primitives

Several primitive functions manipulate `𝕩` along one or more axes based on `𝕨`, according to [the leading axis convention](leading.md#multiple-axes).

| Single-axis depth | Functions
|-------------------|----------
| 0                 | `↑↓↕⌽⍉`
| 1                 | `/⊏⊔`

Functions such as [Take and Drop](take.md) accept a single number per axis in `𝕨`. If given a list of numbers, they apply to initial axes. But for convenience, a single number is also accepted, and applied to the first axis only. This is equivalent to [deshaping](reshape.md) the left argument before applying the function.

        ≢2↑7‿7‿7‿7⥊"abc"
        ≢2‿1‿1↑7‿7‿7‿7⥊"abc"

In these cases the flexibility seems trivial because `𝕨` has depth 1 or 0: it is an array or isn't, and it's obvious what a plain number should do. But for the second row in the table, `𝕨` is always an array. The general case ([Select](select.md) below) is that its elements are lists, each corresponding to one axis of `𝕩`:

        ⟨3‿2,1‿4‿1⟩ ⊏ ↕6‿7

This means `𝕨` is homogeneous of depth 2. What should an argument of depth 1, that is, an array of atoms, do? One option is to continue to require the left argument to be a list, and convert any atom argument into an array by enclosing it:

        ⟨3‿2,1⟩ <⍟(0=≡)¨⊸⊏ ↕6‿7

While very consistent, this extension represents a small convenience and makes it difficult to act on a single axis, which (particularly for [Replicate](replicate.md) and [Group](group.md)) is probably the most common way the primitive is used:

        3‿2‿1‿2‿3 / "abcde"

With the extension above, every case like this would have to use `<⊸/` instead of just `/`. BQN avoids this difficulty by testing the left argument's depth. A depth-1 argument applies to the first axis only, giving the behavior above.

For Select, the depth-1 case is still quite useful, but it may also be desirable to choose a single cell using a list of numbers. In this case the left argument depth can be increased from the bottom using `<¨`.

        2‿1‿4 <¨⊸⊏ ↕3‿4‿5‿2

## The Depth modifier

The Depth 2-modifier (`⚇`) is a generalization of [Each](map.md) that allows diving deeper into an array. To illustrate it we'll use a shape `4‿2` array of lists of lists.

        ⊢ n ← <⎉1⍟2 4‿2‿2‿3⥊↕48
        ≡ n

Reversing `n` swaps all the rows:

        ⌽ n

Depth `¯1` is equivalent to Each, and reverses the larger lists, while depth `¯2` applies Each twice to reverse the smaller lists:

        ⌽⚇¯1 n
        ⌽⚇¯2 n

While a negative depth tells how many levels to go down, a non-negative depth gives the maximum depth of the argument before applying the left operand. On a depth-3 array like above, depth `2` is equivalent to `¯1` and depth `1` is equivalent to `¯2`. A depth of `0` means to descend all the way to the level of atoms, that is, apply [pervasively](arithmetic.md#pervasion), like an arithmetic function.

        ⟨'a',"bc"⟩ ≍⚇0 ⟨2‿3,4⟩

With a positive operand, Depth doesn't have to use the same depth everywhere. Here, [Length](shape.md) is applied as soon as the depth for a particular element is 1 or less, including if the argument has depth 0. For example, it maps over `⟨2,⟨3,4⟩⟩`, but not over `⟨11,12⟩`, even though these are elements of the same array.

        ≠⚇1 ⟨1,⟨2,⟨3,4⟩⟩,⟨5,⟨6,7⟩,⟨8,9,10⟩⟩,⟨11,12⟩⟩

[Like the Rank modifier](rank.md#multiple-and-computed-ranks), the right operand `𝔾` is really a function that returns the depth to be used, and that depth can be a single number, or a list of one to three numbers. One number gives the same depth to all arguments, two correspond to `𝕨` and `𝕩`, and three to monadic `𝕩`, and dyadic `𝕨` and `𝕩`.
