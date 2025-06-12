*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/rank.html).*

# Cells and Rank

<!--GEN
xn ← 1‿2‿5⌾(⟨1‿1,2‿1,1‿3⟩⊸⊑) 3‿4⥊0
d ← 46‿40

rc ← "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-size=18px|fill=currentColor|font-family=BQN,monospace|text-anchor=middle"
fg ← "font-size=24px"
dg ← fg∾"|fill=currentColor|opacity=0.9|text-anchor=start"
lg ← fg∾"|text-anchor=start"
bg ← "class=bluegreen|stroke-width=2|stroke-linecap=round|style=fill:none|opacity=0.7"
ag ← "class=green|stroke-width=3|stroke-linecap=round|opacity=0.2"
cg ← "stroke-width=0.3|fill=none|stroke=currentColor"

Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d×⊢
Path ← "path"⊸At ⊸ Elt ⟜ ("d"⊸⋈)
Rect ← "rect" Elt {(At𝕨)⊢⊘∾"x"‿"y"‿"width"‿"height"≍˘FmtNum𝕩}
Text ← ("text" Attr "dy"‿"0.33em"∾·Pos d⊸×)⊸Enc
TTab ← (⍉⋈⌜´)⊸(Text⟜Highlight¨)

off ← 1.2‿2.4
fo‿co ← ¯1.1‿¯1
tb ← >0‿¯1⊸⊏¨tx‿ty ← ↕¨sh←⌽≢xn
dim ← 2‿1×off+⌽≢xn
Pd ← ∾∾¨⟜FmtNum

Arr ← "M l m l l " Pd ((⊢∾-∾1‿¯1⊸×) 15‿8)∾˜(-˜∾⊣)
bigarr ← (0.2‿¯0.7+2‿1÷˜sh)∾⌽⊸(¯1‿1‿1‿¯1⊸×⊸∾○∾)(¯1.2‿1.4)‿0.5‿1.9

Tr ← {"transform=translate("∾")"∾˜∾⟜","⊸∾´FmtNum d×off+𝕩‿0}⊸Ge
CR ← { 𝕨 Rect ⥊-˜` 11 -⊸≍⊸+ d⊸×˘𝕩 }
share ← ⟨
  cg Ge (CR (⊏tb)≍˘⊢)¨ ty
  tx‿ty TTab FmtNum xn
  bg Path "M hv" ∾˜⊸Pd ⥊⌽(15×1.5‿¯1) (+⌾⊑ ≍ -⊸≍∘⊣)˘ 19-⊸≍⊸+d⊸×˘⍉tb
⟩

((∾˜d)×((-∾+˜)0.3‿0.3)+0‿0∾dim) SVG g Ge ⟨
  rc Rect 0‿0∾d×dim
  dg Ge 0.2‿0 Text "Cells"
  0 Tr share∾⟨
    cg CR (⊏tb)≍˘¯1.1
    ag Path "z"∾˜"M vhl l hv" (⊣Pd(∊⟜" v"⊏d˙)⊸×) bigarr
    lg Ge ¯1‿fo Text Highlight "+˝"
    tx‿fo TTab FmtNum +˝xn
    fg Ge ((+˝÷≠)⎉1¨tx⋈2↕ty) TTab <"+"
  ⟩
  (1.5+≠tx) Tr share∾⟨
    cg Ge (CR ·≍˜co≍⊢)¨ ty
    (ag∾"|style=fill:none") Ge ("" Path (-≠tx)‿0 Arr○(d⊸×) (co+0.2)⋈⊢)¨ ty
    lg Ge (co-0.2)‿fo Text Highlight "+˝˘"
    co‿ty TTab FmtNum +˝˘xn
    ((+˝÷≠)˘ 2↕tx)‿ty TTab <"+"
  ⟩
⟩
-->

The Cells modifier `˘` applies a function to major cells of its argument, much like [Each](map.md) applies to elements. Each result from `𝔽` becomes a major cell of the result, which means they must all have the same shape.

The Rank modifier `⎉` generalizes this concept by allowing numbers provided by `𝔾` to specify a rank for each argument: non-negative to indicate the rank of each array passed to `𝔽`, or negative for the number of axes that are mapped over. Cells, which maps over one axis of each argument, is identical to `⎉¯1`. Rank is analogous to the [Depth modifier](depth.md#the-depth-modifier), but the homogeneous structure of an array eliminates some tricky edge cases found in Depth.

## Cells

The function Cells (`˘`) is named after *major cells* in an array. A [major cell](array.md#cells) is a component of an array with dimension one smaller, so that the major cells of a list are [units](enclose.md#whats-a-unit), the major cells of a rank-2 table are its rows (which are lists), and the major cells of a rank-3 array are tables.

The function `𝔽˘` applies `𝔽` to the major cells of `𝕩`. So, for example, where [Nudge](shift.md) (`»`) shifts an entire table, Nudge Cells shifts its major cells, or rows.

        a ← 'a' + 3‿∘ ⥊ ↕24  # A character array

        ⟨  a      ,     »a     ,    »˘a ⟩

What's it mean for Nudge to shift the "entire table"? The block above shows that it shifts downward, but what's really happening is that Nudge treats `𝕩` as a collection of major cells—its rows—and shifts these. So it adds an entire row and moves the rest of the rows downwards. Nudge Cells appears similar, but it's acting independently on each row, and the values that it moves around are major cells of the row, that is, rank-0 units.

Here's an example showing how Cells can be used to shift each row independently, even though it's not possible to shift columns like this (in fact the best way to do that would be to [transpose](transpose.md) in order to work on rows). It uses the not-yet-introduced dyadic form of Cells, so you might want to come back to it after reading the next section.

        (↑"∘∘") ⊑⊸»˘ a

You can also see how Cells splits its argument into rows using a less array-oriented primitive: [Enclose](enclose.md) just wraps each row up so that it appears as a separate element in the final result.

        <˘ a

Enclose also comes in handy for the following task: join the rows in an array of lists, resulting in an array where each element is a joined row. The obvious guess would be "join cells", `∾˘`, but it doesn't work, because each `∾` can return a result with a different length. Cells tries to make each result of `∾` into a *cell*, when the problem was to use it as an *element*. But a 0-cell is an enclosed element, so we can close the gap by applying `<` to a joined list: `<∘∾`.

        ⊢ s ← "words"‿"go"‿"here" ≍ "some"‿"other"‿"words"

        ∾˘ s

        <∘∾˘ s

This approach can apply to more complicated functions as well. And because the result of `<` always has the same shape, `⟨⟩`, the function `<∘𝔽˘` can never have a shape agreement error. So if `𝔽˘` fails, it can't hurt to check `<∘𝔽˘` and see what results `𝔽` is returning.

### Two arguments

When given two arguments, Cells tries to pair their cells together. Starting simple, a unit (whether array or atom) on either side will be paired with every cell of the other argument.

        '∘' »˘ a

If you *want* to use this one-to-many behavior with an array, it'll take more work: since you're really only mapping over one argument, [bind](hook.md) the other inside Cells.

        "∘∘" »˘ a

        "∘∘"⊸»˘ a

This is because the general case of Cells does one-to-one matching, pairing the first axis of one argument with the other. For this to work, the two arguments need to have the same length.

        ⟨ "012" »˘ a,  (3‿∘⥊"UVWXYZ") »˘ a ⟩

The arguments might have different ranks: for example, `"012"` has rank 1 and `a` has rank 2 above. That's fine: it just means Cells will pass arguments of rank 0 and 1 to its operand. You can see these arguments using [Pair](pair.md) Cells, `⋈˘`, so that each cell of the result is just a list of the two arguments used for that call.

        "012" ⋈˘ a

## Rank

Rank (`⎉`) is a generalization of Cells (`𝔽˘` is defined to be `𝔽⎉¯1`) that can apply to arbitrary—not just major—[cells](array.md#cells) and combine different levels of mapping for two arguments.

Rank comes in handy when there are high-rank arrays with lots of exciting axes, which is a great use case for BQN but honestly isn't all that common. And to continue this trend of honesty, using Rank just never *feels* good—it's some heavy machinery that I drag out when nothing else works, only to make use of a small part of the functionality. If Cells covers your use cases, that's probably for the best!

### Negative and positive ranks

I've said that `𝔽⎉¯1` is `𝔽˘`. And it's also the case that `𝔽⎉¯2` is `𝔽˘˘`. And `𝔽⎉¯3` is `𝔽˘˘˘`. And so on.

        (↕4) (⋈˘˘˘ ≡ ⋈⎉¯3) ↕4‿2‿2‿5

So `𝔽⎉(-k)`, at least for `k≥1`, is how you map over the first `k` axes of an array or two. We'll get more into why this is in the next section. What about some positivity for a change?

        <⎉0 "abc"≍"def"

        <⎉1 "abc"≍"def"

The function `𝔽⎉k`, for `k≥0`, operates on the `k`-cells of its arguments—that is, it maps over all *but* the last `k` axes. For any given argument `a`, ranks `k` and `k-=a` are the same, as long as `k≥0` and `(k-=a)≤¯1`. So rank 2 is rank ¯3 for a rank-5 array. The reason this option is useful is that the same rank might be applied to multiple arguments, either with multiple function calls or one call on two arguments. Let's revisit an example with Cells from before, shifting the same string into each row of a table. The function `»` should be called on rank-1 strings, but because the argument ranks are different, a negative rank can't get down to rank 1 on both sides. Positive rank 1 does the job, allowing us to unbundle the string `"∘∘"` so that `»⎉1` is a standalone function.

        "∘∘"⊸»˘ a

        "∘∘" »⎉1 a

The rank for a given argument is clamped, so that on a rank 3 argument for example, a rank of ¯5 counts as ¯3 and a rank of 6 counts as 3 (same for any other value less than ¯3 or greater than 3, although it does have to be a whole number). You may have noticed there's [no](../commentary/problems.md#rankdepth-negative-zero) option for ¯0, "don't map over anything", but ∞ serves that purpose, as it indicates the highest possible rank and thus the entire array. More on why that's useful later.

### Frame and Cells

Lets look at things more systematically. Suppose `x` has shape `4‿3‿2‿1‿0`, and we'd like to approach it with `⎉2`, or equivalently `⎉¯3`. This choice splits the axes of `x` into two parts: leading axes (shapes `4‿3‿2`) make up the *frame* of `x`, while trailing axes give the shape `1‿0` of each *cell* of `x`.

        ≢   <⎉2 ↕4‿3‿2‿1‿0

        ≢ ⊑ <⎉2 ↕4‿3‿2‿1‿0

We can build a frame array using `<⎉2`, as shown above. In the general case `F⎉2 x`, the frame remains conceptual: the actual array `<⎉2 x` is never exposed, and the final result might not have exactly shape `4‿3‿2`. But its shape does always start with `4‿3‿2`, because Rank maps over the frame axes, leaving them intact. In terms of our cell-splitting function `<⎉k`, and its inverse [Merge](couple.md) (`>`), we have:

    F⎉k x  ←→  >F¨<⎉k x

That is, `F⎉k` splits its argument into `k`-cells, applies `F` to each of these (in index order, of course), then merges the results into a single array.

        +˝⎉1 4‿2⥊↕8

        +˝¨<⎉1 4‿2⥊↕8  # +˝ of a list is a unit

        >+˝¨<⎉1 4‿2⥊↕8

Each can be implemented by acting on 0-cells with Rank too: `F⌾⊑⎉0 x ←→ F¨x`, meaning that `F¨` applies `F` to the interior of each 0-cell, that is, each element. Some half-way identities are `<∘F⎉k  ←→ F¨<⎉k` and `F∘⊑⎉0 ←→ >F¨`.

### Multiple and computed ranks

The Rank modifier also accepts a list of one to three numbers for `𝕘`, as well as a function `𝔾` returning such a list. Practically speaking, here's what you need to know:

- A single number or one-element list indicates the ranks for all arguments.
- Two numbers indicate the ranks for `𝕨` and `𝕩`.

As an example, we'll define the matrix-vector product. A matrix is a rank-2 array and a vector is a list, and their product is a list. It's made up of the elements `+´ row × vec` for each row `row` of the matrix. To define this using Rank, we'll change `+´` to `+˝` to get a unit out, and we need to map over the rows of the left argument but not of the right one. Following the rules above, there are several ways to do this, including `+˝∘×⎉1`, `+˝∘×⎉¯1‿1`, and `+˝∘×⎉¯1‿∞`. Note that `⎉¯1` wouldn't work, because the ¯1 is interpreted separately for both arguments—it's equivalent to 1 for the matrix but 0 for the vector, or `⎉1‿0` overall. When correctly defined we can see that multiplication by the matrix `m` below negates the first element of a list, and also swaps it with the second.

        ⊢ m ← [0‿1‿0, ¯1‿0‿0, 0‿0‿1]

        +˝ 0‿1‿0 × 1‿2‿3

        m +˝∘×⎉1‿∞ 1‿2‿3

But a rank of `1‿∞` works the best because it also defines a matrix-*matrix* product. Which as shown below does the same transformation to the *cells* of the right-hand-side matrix, instead of the elements of a vector. This works because `×` and `+˝` work on the leading axes of their arguments. When `⎉1‿∞` is applied, these axes are the last axis of `𝕨` and the first axis of `𝕩`. Which… is kind of weird, but it's what a matrix product is.

        +˝ 0‿1‿0 × 1‿2‿3×⌜1‿10

        m +˝∘×⎉1‿∞ 1‿2‿3×⌜1‿10

For completeness, here's the whole, boring description of how `𝔾` is handled. The operand `𝔾` is called on the arguments `𝕨𝔾𝕩` before doing anything else (if it's not a function, this just returns `𝕘`). Then it's converted to a list. It's required to have rank 0 or 1, but numbers and enclosed numbers are fine. This list can have one to three elements; three elements is the general case, as the elements give the ranks for monadic `𝕩`, dyadic `𝕨`, and dyadic `𝕩` in order. If there are less than three elements, the list `r` is expanded backwards-cyclically to `3⊸⥊⌾⌽r`, turning `⟨a⟩` into `a‿a‿a` and `a‿b` into `b‿a‿b`. So `3⊸⥊⌾⌽⥊𝕨𝔾𝕩` is the final formula.

### Leading axis agreement

In the preceding sections we've been somewhat loose with the way two arguments are paired up. The simple answer is [leading axis agreement](leading.md#leading-axis-agreement) on the frames.

This is why the rank of `⎉1‿∞` that leads to a frame `⟨3⟩` on the left and `⟨⟩` on the right is fine: more generally, either argument can have a longer frame as long as the elements in the shorter one agree with it. So frames of `⟨3,2⟩` and `⟨3⟩` would also be fine, but `⟨2,3⟩` and `⟨3⟩` wouldn't: the first axes of these frames need to have the same length.

        ≢ (↕3‿2‿5) ∾⎉1 (↕3‿4)

        ≢ (↕2‿3‿5) ∾⎉1 (↕3‿4)

On the other hand, Rank doesn't care about the argument cell shapes—it leaves that up to the function `𝔽`. If `𝔽` is an arithmetic function, you'll get *two* layers of prefix agreement: one outer matching with `⎉`, and an inner one with `𝔽`.

It's also possible to apply multiple copies of Rank, which in general is powerful enough to match and not-match axes in any combination as long as the axes for each argument stay in order (of course, BQN also provides the tools to [reorder axes](transpose.md#reorder-axes)).

One of the relatively more common instance of this pattern is a variation on the [Table](map.md#table) modifier, to work with cells instead of elements. Here we'll make a table of all combinations of one row (1-cell) from `𝕨` and one from `𝕩`. To do this, we want to first line up each row of `𝕨` with the whole of `𝕩`. As in a matrix product, that's `⎉1‿∞`. But then we'd like to pair that row with the rows of `𝕩` individually, which could be written `⎉∞‿1`. But since we know the left argument has been reduced to lists, `⎉1` also works. We then arrange the two layers of mapping with `⎉1` on the inside, giving `(∾⎉1)⎉1‿∞`.

        ("abc"≍"def") ∾⎉1⎉1‿∞ >"QR"‿"ST"‿"UV"

        ≢ ("abc"≍"def") ∾⎉1⎉1‿∞ >"QR"‿"ST"‿"UV"

        ≢ (↕3‿4‿5) ∾⎉1⎉1‿∞ ↕0‿1‿2‿8

The flexibility of Rank also means we're able to apply this pattern with ranks other than 1. In particular, `𝔽⎉∞‿¯1⎉¯1‿∞` applies `𝔽` to all combinations of one major cell from either argument—an equivalent to `>𝔽⌜○(<˘)`. In this case the left rank of `𝔽⎉∞‿¯1` is unknown, so the only way to apply `𝔽` to the entire cell from `𝕨` is to use rank ∞.
