*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/reverse.html).*

# Reverse and Rotate

The symbol `⌽` indicates two different array transformations: with no left argument, it reverses the major cells of the array, but with a left argument, it rotates or cycles them around. These two possibilities, first put together in very early versions of APL, can't be considered restrictions or different views of some unifying function, but there are connections between them. Each returns an array with the same [shape](shape.md) and all the same elements as `𝕩`, possibly in a different arrangement. And elements that start out next to each other in `𝕩` generally stay next to each other—always, if we consider an element on one edge to be next to the one opposite to it. One might think of them as [isometries](https://en.wikipedia.org/wiki/Isometry) preserving a discrete subgroup of the torus, if one were inclined to think such things. On major cells, the two functions decompose the [dihedral group](https://en.wikipedia.org/wiki/Dihedral_group) okay I'll stop.

Many uses of Rotate in APL are better handled by [shift](shift.md) functions in BQN. If there's no reason to treat the data as cyclic or periodic, it's best to avoid Rotate.

## Reverse

There's not too much to say about Reverse. It puts the elements of a list the other way around, or more generally the major cells of an array.

        ⌽ "abcdefg"

        ⌽ >"ab"‿"cd"‿"ef"

        ⌽ 'c'

You can't reverse an atom or rank-0 array because it has no axes to reverse along, or it could be said no ordering to reverse.

To reverse along an axis other than the first, use Cells (`˘`) or Rank (`⎉`).

        ⌽˘ >"ab"‿"cd"‿"ef"

Reverse is useful for [folding](fold.md) left to right instead of right to left (here we use [Pair](pair.md) to show structure).

        ⋈ ´   "abcd"  # Right to left

        ⋈˜´ ⌽ "abcd"  # Left to right

Reverse is its own [inverse](undo.md) `⌽⁼`. As a result, `𝔽⌾⌽` reverses the argument, applies `𝔽`, and reverses again. It's a particularly useful pattern with [Scan](scan.md), as it allows scanning from the end rather than the beginning of the array. For example, `` ∨` `` on a list of booleans changes all bits after the first `1` to `1`, but `` ∨`⌾⌽ `` does this to all bits before the last `1`.

        ∨`   0‿0‿1‿0‿0‿1‿0

        ∨`⌾⌽ 0‿0‿1‿0‿0‿1‿0

## Rotate

Rotate moves elements in a list around cyclically. It can also rotate any number of axes of the argument array by different amounts at once. That's discussed in the next section; for now we'll stick to a single number for `𝕨`. It has to be an integer, and `𝕩` has to be an array with at least one axis.

        2 ⌽ "rotate"

        2 (⊢ ⋈ ⌽) 5‿2⥊"rotateCELL"

        2 ⌽ 'c'  # No axes to rotate

Elements are always rotated to the left, so that entry `i` of the result is entry `𝕨+i` of the argument—or rather, entry `(≠𝕩)|𝕨+i` to enable elements to cycle around. This can be seen directly by using the [range](range.md) `↕n` as an argument: then the value of `𝕩` at index `i` is just `i`.

        2 ⌽ ↕6

The rotation `(≠𝕩)⌽𝕩` moves each element the entire [length](shape.md) of `𝕩`, which just places it back where it started. In fact, adding `≠𝕩` to the rotation amount never changes the behavior or the rotation. In terms of indices, this is because `(≠𝕩)|(≠𝕩)+a` is `a`.

To rotate the other way, use a negative left argument (so `-⊸⌽` is a simple way to write "reverse rotate"). This will always be the same as some leftwards rotation, since `(-r)⌽𝕩` is `((≠𝕩)-r)⌽𝕩`, but could be more convenient.

        ¯2 ⌽ "rotate"

### Multiple axes

The easiest way to rotate a later array axis is usually to use the Cells (`˘`) or Rank (`⎉`) modifier.

        ⊢ tab ← 3‿4⥊"abcdABCD0123"

        1 ⌽˘ tab  # Rotate the second axis

Rotate also allows `𝕨` to be a list (or unit array) of integers, in which case they're matched with [leading axes](leading.md) of `𝕩`. This means the length of `𝕨` can't be larger than the rank of `𝕩`, or there wouldn't be enough axes to match. This rule also explains why `𝕩` has to have rank one or more when `𝕨` is an atom, because `𝕨` is treated as the one-element list `⥊𝕨` in that case.

        3‿4‿2 ⌽ "just a list"

The expression below rotates the first (vertical) axis of `tab` by one element, and second by two. So the line of capital letters goes from being one away from the top, up to the top, and the column with `'2'` goes from horizontal index 2 to index 0.

        1‿2 ⌽ tab

The vertical and horizontal rotations are independent, and could also be done with two `⌽`s and a `˘`. The multi-axis form is more convenient, and can potentially be evaluated faster that multiple separate rotations in the cases where it shows up.

        1 ⌽ 2 ⌽˘ tab
