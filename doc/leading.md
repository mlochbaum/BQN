*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/leading.html).*

# The leading axis convention

Several primitive functions manipulate the right argument, or sometimes both arguments, along one or more axes. According to the [leading axis model](https://aplwiki.com/wiki/Leading_axis_theory), it's best to make the primitives operate on initial axes, because the Rank modifier then allows it to apply to later axes as well. Here we'll see how this pattern works in BQN.

## Monadic functions

### Manipulating cells

Most non-scalar monadic functions work only on the first axis of the argument—that is, they treat it as a list of its major cells. The function Length (`≠`) counts these major cells, while Prefixes (`↑`), Suffixes (`↓`), Reverse (`⌽`), and First Cell (`⊏`) move them around. The Insert (`˝`) and Scan (`` ` ``) modifiers also yield functions that work along the first axis; in contrast, Reduce (`´`) requires its argument to be a list, as it works on elements.

        ⊢ a ← 3‿2 ⥊ "abcdef"  # An array with three major cells
        ⊏ a                   # Get the first major cell
        ⌽ a                   # Reverse the cells
        ⊣` a                  # Replicate the first cell

To use these functions on another axis, use the Rank (`⎉`) or Cells (`˘`) modifier to find the one you want. For a rank 2 array like `a`, the most you'll ever need is a single `˘`, because a function works on axis 0 by default, and there's only one other axis.

        ⊏˘ a                  # First column
        ⌽˘ a                  # Swap the columns
        ⊣`˘ a                 # Replicate along rows

In these three cases above, the results are the same as you would get from transposing before and after (this has no effect on the result of `⊏˘`, since it has rank 1). But in the following cases, the structure is quite different: `↑a` is a list of matrices while `↑˘a` is a matrix of lists. This is because the functions `⊏`, `⌽`, and `` ⊣` `` leave the trailing axis structure intact (`⊏` removes one axis); taking into account that Rank or Cells always preserves the leading or frame axes, all axes are preserved (except the one removed by `⊏`). In contrast, Prefixes or Suffixes pushes some axes down in depth, and the number of axes that are pushed down in this way changes with the rank of application. More precisely, these functions move axes after the first from the argument itself to result elements, and create two axes from the first axis, with one of them forming the sole result axis and the other joining the rest as an element axis.

        ↑ a                   # Prefixes of a:    ranks 1|2
        ↑˘ a                  # Prefixes of rows: ranks 2|1
        ∾˝ a                  # Join the cells
        ∾˝˘ a                 # Join-insert is a no-op on lists

[Solo](couple.md) (`≍`), something of a maverick, manages to act on *zero* leading axes of its argument by creating the first axis of the *result* instead. Because it doesn't need any axis to work, it can go in front of either axis but also past the last one by working with rank 0, a case where most array functions would give an error.

        ≢ ≍ a                 # Solo adds a length-1 axis
        a ≡ ⊏ ≍ a             # First Cell undoes this
        ≢ ≍˘ a                # Solo can insert the axis deeper…
        ≢ ≍⎉0 a               # …or deeper still.

### Comparing cells

The functions in the last section manipulate cells in the same way regardless of what data they contain. Other functions compare cells to each other, either testing whether they match or how they are ordered relative to one another. The two Grade functions `⍋⍒`, and the self-comparison functions Unique Mask (`∊`) and Occurrence Count (`⊒`), each give a list result, with one number for each cell. We can see below that Occurrence Count returns the same results even as we make the argument cells more complicated, because the changes made preserve the matching of cells.

        s ← "abracadabra"
        ⊒ s
        ⊒ ≍˘ s
        ⊒ s ∾⎉0‿1 "suffix"

The two Sort functions `∧∨` and Deduplicate (`⍷`) move cells around based on their ordering. The length of Deduplicate's result depends on how many unique cells the argument has, so you'd better be careful if you want to apply it to argument cells! However, the result of sorting has the same shape as the argument, so it can always safely be applied at any rank, for example to the rows of an array.

        ⊢ b ← 4‿5 ⥊ ↕4
        ∨˘ b

### Other monadic functions

Not all functions work on the first axis in a straightforward manner. [Transpose](transpose.md) `⍉` moves the first axis to the end, so while it focuses on the first one, it shifts every axis of the argument. [Join](join.md) `∾` also works on every axis of its argument, and applies to the leading axes of the argument's *elements* instead: these leading inner axes are matched up with the outer axes, and trailing inner axes are allowed but the elements must have rank at least as high as the argument array.

The other two monadic functions that work on high-rank arguments are Deshape (`⥊`) and First (`⊑`). These treat the argument as one long list, ordered by its element indices. This ordering privileges leading axes (in fact, it is the reason for the choice of leading axes in the leading axis convention), but these functions can't really be said to work on leading axes: they apply to all axes.

The Each (`¨`) and Table (`⌜`) modifiers return functions which are the same in the monadic case. These functions simply go through all elements of the argument array without regard for its multi-dimensional structure (the operand is applied to elements in index order, matching Deshape; this matters if it has side effects). Similarly, monadic scalar functions do not have any sort of leading axis dependence.

## Dyadic functions

For dyadic functions the pattern of working on only one argument axis is not so common. Only two functions can be said to follow it roughly: Join to (`∾`) combines two arrays along one axis, using the first axis of both arguments if they have the same rank and of the higher-rank argument if they differ by one. [Couple](couple.md) (`≍`), like Solo, does not manipulate the argument axes but adds a result axis. There are also some functions that can't be limited to leading axes: Reshape (`⥊`) treats the argument as one long list, and Pick (`⊑`) requires each index to be as long as the right argument's rank, because it selects elements and not cells from the right argument.

### Multiple axes

Instead of always working on a single axis, many dyadic functions work on one axis by default, but also allow a left argument with multiple elements corresponding to leading axes of the right argument. To decide which of the two possibilities applies, these functions test the left argument depth, a convention that is discussed in the [depth](depth.md#testing-depth-for-multiple-axis-primitives) documentation. A left argument that applies to one axis has a particular depth; the argument can also be a list of such arguments.

| Single-axis depth | Functions
|-------------------|----------
| 0                 | `↑↓↕⌽⍉`
| 1                 | `/⊏⊔`

Functions such as Take and Drop use a single number per axis. When the left argument is a list of numbers, they apply to initial axes. Observing the operation of Rotate on the result of Range is instructive:

        2‿1 ⌽ ↕3‿5

The array is shifted once to the left and twice upward, so that the first index (by ravel order) is now `⊑2‿1⌽↕3‿5 ←→ 2‿1`. To see how values are matched to leading axes, we can look at how Drop changes the shape of its argument:

        ≢ 3‿2 ↓ 7‿7‿7‿7⥊"abc"

Functions with single-axis depth 1 tend to be more complicated; see for example [Group](group.md#multidimensional-grouping).

### Leading axis agreement

Scalar functions, and the Each (`¨`) and Depth (`⚇`) modifiers, use leading axis agreement to match their arguments together. All axes of the lower-rank argument are matched with the leading axes of the higher-rank one, and axes matched together must have the same length. After pairing axes in this way, a single element of the lower-rank argument might correspond to any number of elements of the higher-rank one. It's reused for each of those corresponding elements.

        ⊢ x ← 3‿2‿4 ⥊ ↕60     # A rank-3 array
        100‿0‿200 + x         # 0-cells paired with 2-cells
        ⊢ c ← 100 × 3 =⌜○↕ 2  # A rank-2 array to add
        c + x                 # 0-cells paired with 1-cells
        x + x                 # Pairwise addition

If one argument is a scalar, that is, it has no axes, then leading axis agreement reduces to "scalar extension", where a single scalar is matched with an entire array by repeating it at every application. A scalar always agrees with any other array under leading axis agreement because it has no axes whose lengths would need to be checked.

With leading axis agreement, there are `k+1` shapes for arrays that can be added (or any other function with Each) to a given array `x` without changing its rank. These are precisely the prefixes of `≢x`, with ranks from `0` to `k` inclusive. Arrays with larger rank can also be used as the other argument, but then the result shape will match that argument and not `x`.

### Search functions

The search functions Bins (`⍋⍒`), Index of (`⊐`), Progressive Index of (`⊒`), and Member of (`∊`) look through cells of one argument to find cells of the other. Find (`⍷`) also does a search, but a slightly different one: it tries to find *slices* of cells of its right argument that match the left argument.

| Searching through | Look for | Functions
|-------------------|----------|----------
| `𝕨`               | `𝕩`      | `⍋⍒⊐⊒`
| `𝕩`               | `𝕨`      | `∊⍷`

For all of these functions but Find, the argument to search through is treated as a list of its major cells. It is the rank of these major cells—let's call this rank `c`—that determines how the other argument is treated. That argument must have rank at least `c`, and it is treated as an array of `c`-cells. For example, if the left argument to `⍋` is a matrix, then each 1-cell or row of the right argument is treated independently, and each one yields one number in the result: a 0-cell. The result rank of `⍋` is always `𝕨¬○=𝕩`.
