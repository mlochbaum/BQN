*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/leading.html).*

# The leading axis convention

Several primitive functions manipulate the right argument, or sometimes both arguments, of an [array](array.md) along one or more axes. According to the [leading axis model](https://aplwiki.com/wiki/Leading_axis_theory), it's best to make the primitives operate on initial axes, because the [Rank modifier](rank.md) then allows it to apply to later axes as well. Here we'll see how this pattern works in BQN.

## Monadic functions

### Manipulating cells

Most monadic functions that deal with structure at all (that is, not arithmetic) work only on the first axis of the argument. Usually, they treat it as a list of its [major cells](array.md#cells). The function [Length](shape.md) (`≠`) counts these major cells, while [Prefixes](prefixes.md) (`↑`), Suffixes (`↓`), [Reverse](reverse.md) (`⌽`), and [First Cell](select.md#first-cell) (`⊏`) move them around. The [Insert](fold.md#insert) (`˝`) and [Scan](scan.md) (`` ` ``) modifiers also yield functions that work along the first axis; [Fold](fold.md) (`´`) requires `𝕩` to be a list but does go along the first (only) axis of that list.

        ⊢ a ← 3‿2 ⥊ "abcdef"  # An array with three major cells

        ⊏ a                   # Get the first major cell

        ⌽ a                   # Reverse the cells

        ⊣` a                  # Replicate the first cell

To use these functions on another axis, use the [Rank](rank.md#rank) (`⎉`) or [Cells](rank.md#cells) (`˘`) modifier to find the one you want. For a rank 2 array like `a`, the most you'll ever need is a single `˘`, because after the leading one there's only one other axis.

        ⊏˘ a                  # First column

        ⌽˘ a                  # Swap the columns

        ⊣`˘ a                 # Replicate along rows

In these three cases above, the results are the same as you would get from [transposing](transpose.md) before and after (which does nothing to the rank-1 result of `⊏˘`, but that's what's wanted). But in the following cases, the structure is quite different: `↑a` is a list of matrices while `↑˘a` is a matrix of lists. This is because the functions `⊏`, `⌽`, and `` ⊣` `` leave the trailing axis structure intact (`⊏` removes one axis); taking into account that Rank or Cells always preserves the leading or frame axes, all axes are preserved (except the one removed by `⊏`). But Prefixes or Suffixes move axes after the first from the whole of `𝕩` to elements of the result, pushing them down in depth, and Rank won't undo this sort of structural change.

        ↑ a                   # Prefixes of a:    ranks 1|2

        ↑˘ a                  # Prefixes of rows: ranks 2|1

        ∾˝ a                  # Join the cells

        ∾˝˘ a                 # Join-insert is a no-op on lists

[Solo](couple.md) (`≍`), something of a maverick, manages to act on *zero* leading axes of `𝕩` by creating the first axis of the *result* instead. Because it doesn't need any axis to work, it can go in front of either axis but also past the last one by working with rank 0, a case where most array functions would give an error.

        ≢ ≍ a                 # Solo adds a length-1 axis

        a ≡ ⊏ ≍ a             # First Cell undoes this

        ≢ ≍˘ a                # Solo can insert the axis deeper…

        ≢ ≍⎉0 a               # …or deeper still.

### Comparing cells

The functions in the last section manipulate cells in the same way regardless of what data they contain. Other functions compare cells to each other, either testing whether they match or how they are ordered relative to one another. The two [Grade](order.md#grade) functions `⍋⍒`, and the [self-search](selfcmp.md) functions Classify (`⊐`), Mark Firsts (`∊`), and Occurrence Count (`⊒`), each give a list result, with one number for each cell. We can see below that [Occurrence Count](selfcmp.md#occurrence-count) returns the same results even as we make the argument cells more complicated, because the changes made preserve the matching of cells.

        s ← "abracadabra"

        ⊒ s

        ⊒ ≍˘ s

        ⊒ s ∾⎉0‿1 "suffix"

The two [Sort](order.md#sort) functions `∧∨` and [Deduplicate](selfcmp.md#deduplicate) (`⍷`) move cells around based on their ordering. The length of Deduplicate's result depends on how many unique cells the argument has, so you'd better be careful if you want to apply it to argument cells! However, the result of sorting has the same shape as the argument, so it can always safely be applied at any rank, for example to the rows of an array.

        ⊢ b ← 4‿5 ⥊ ↕4

        ∨˘ b

### Other monadic functions

Not all functions work on the first axis in a straightforward manner. [Transpose](transpose.md) `⍉` moves the first axis of `𝕩` to the end, so while it focuses on the first one, it shifts every other axis too. [Join](join.md) `∾` also works on every axis of its argument, and applies to the leading axes of `𝕩`'s *elements* instead: these leading inner axes are matched up with the outer axes, and trailing inner axes are allowed but the elements must have rank (after extension) at least as high as the argument array.

The other two monadic functions that work on high-rank arguments are [Deshape](reshape.md#deshape) (`⥊`) and [First](pick.md#first) (`⊑`). These treat `𝕩` as one long list, ordered by its element indices. This ordering privileges leading axes (in fact, it's the reason for the choice of leading axes in the leading axis convention), but these functions can't really be said to work on leading axes: they apply to all axes.

The [Each](map.md) (`¨`) and [Table](map.md#table) (`⌜`) modifiers behave the same in the monadic case: they go through all elements of `𝕩` without regard for its multi-dimensional structure (in index order, matching Deshape; this matters if it has side effects). Similarly, monadic arithmetic functions don't have any sort of leading axis dependence.

## Dyadic functions

For dyadic functions the pattern of working on only one argument axis is not so common. Only two functions can be said to follow it roughly: [Join to](join.md) (`∾`) combines two arrays along one axis, using the first axis of both arguments if they have the same rank and of the higher-rank argument if they differ by one. [Couple](couple.md) (`≍`), like Solo, doesn't manipulate the argument axes but adds a result axis. There are also some functions that can't be limited to leading axes: [Pick](pick.md) (`⊑`) requires each index to be as long as `𝕩`'s rank, because it selects elements and not cells from `𝕩`, and [Reshape](reshape.md) (`⥊`) treats `𝕩` as one long list. In fact I think I [got Reshape wrong](../commentary/problems.md#deshape-and-reshape-cant-ignore-trailing-axes) by rejecting J's leading axis form, but it's too late to go back on that, especially given that it wouldn't make much sense for it to share the glyph `⥊` with Deshape.

### Multiple axes

Instead of always working on a single axis, many dyadic functions work on one axis by default, but also allow a left argument with multiple elements corresponding to leading axes of `𝕩`. To decide which of the two possibilities applies, these functions test the depth of `𝕨`, a convention that is discussed [in the depth documentation](depth.md#testing-depth-for-multiple-axis-primitives). A left argument that applies to one axis has a particular depth; `𝕨` can also be a list of such arguments.

| Single-axis depth | Functions
|-------------------|----------
| 0                 | `↑↓↕⌽⍉`
| 1                 | `/⊏⊔`

Functions such as Take and Drop use a single number per axis. When `𝕨` is a list of numbers, they apply to initial axes. The operation of [Rotate](reverse.md#rotate) on the result of [Range](range.md) is instructive:

        2‿1 ⌽ ↕3‿5

The array is shifted once to the left and twice upward, so that the first index (by index order) is now `⊑2‿1⌽↕3‿5 ←→ 2‿1`. To see how values are matched to leading axes, we can look at how [Drop](take.md) changes the shape of its argument:

        ≢ 3‿2 ↓ 7‿7‿7‿7⥊"abc"

Functions with single-axis depth 1 tend to be more complicated; see for example [Group](group.md#multidimensional-grouping).

### Leading axis agreement

[Arithmetic](arithmetic.md) functions, and the [Each](map.md#each) (`¨`) and [Depth](depth.md#the-depth-modifier) (`⚇`) modifiers, use leading axis agreement to match their arguments together. It's a bit like NumPy or Julia broadcasting, but these mostly match trailing, not leading, axes. In BQN, all axes of the lower-rank argument are matched with the leading axes of the higher-rank one, and axes matched together must have the same length. After pairing axes in this way, a single element of the lower-rank argument might correspond to any number of elements of the higher-rank one. It's reused for each of those corresponding elements.

        ⊢ x ← 3‿2‿4 ⥊ ↕60     # A rank-3 array

        100‿0‿200 + x         # 0-cells paired with 2-cells

That's shape `3‿2‿4` matched with shape `⟨3⟩`: the leading `3` agrees. Now to match with `3‿2`:

        ⊢ c ← 100 × 3 =⌜○↕ 2  # A rank-2 array to add

        c + x                 # 0-cells paired with 1-cells

And of course, identical shapes agree:

        x + x                 # Pairwise addition

If one argument is a [unit](enclose.md#whats-a-unit), that is, it has no axes, then leading axis agreement reduces to APL's "scalar extension" (where "scalar" is equivalent to BQN's "unit"), where a single unit is matched with an entire array by repeating it at every application. A unit always agrees with any other array under leading axis agreement, because it has no axes whose lengths would need to be checked.

With leading axis agreement, there are `k+1` shapes for arrays that can be added (or any other function with Each) to a given array `a` without changing its rank. These are precisely the prefixes of `≢a`, with ranks from `0` to `k` inclusive. Arrays with larger rank can also be used as the other argument, but then the result shape will match that argument and not `a`.

### Search functions

The [search functions](search.md) Index of (`⊐`), Progressive Index of (`⊒`), and Member of (`∊`), and also [Bins](order.md#bins) (`⍋⍒`), look through cells of one argument to find cells of the other. [Find](find.md) (`⍷`) also does a search, but a slightly different one: it tries to find *slices* of cells of `𝕩` that match `𝕨`.

| Search in | Search for | Functions
|-----------|------------|----------
| `𝕨`       | `𝕩`        | `⍋⍒⊐⊒`
| `𝕩`       | `𝕨`        | `∊⍷`

For all of these functions but Find, the searched-in argument is treated as a list of its major cells, and the searched-for argument is considered a collection of cells with the same rank. See the [search function documentation](search.md#higher-ranks).
