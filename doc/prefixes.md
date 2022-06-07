*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/prefixes.html).*

# Prefixes and Suffixes

The Prefixes (`↑`) function gives a list of all prefixes of its argument array along the [first axis](leading.md), and Suffixes (`↓`) gives a similar list for suffixes. Because the result can be much larger than the argument, these functions may not be used often in high-performance code, but they are a good conceptual tool and can make sense for algorithms that are inherently quadratic.

        ↑ "abcde"

        ↓ "abcde"

The functions are closely related to [Take and Drop](take.md), as we might expect from their glyphs. Element `i⊑↑𝕩` is `i↑𝕩`, and `i⊑↓𝕩` is `i↓𝕩`.

In both cases, an empty array and the entire argument are included in the result, meaning its length is one more than that of the argument. Using [Span](logic.md), we can say that the result has elements whose [lengths](shape.md) go from `0` to `≠𝕩`, inclusive, so there are `(≠𝕩)¬0` or `1+≠𝕩` elements. The total number of cells in the result (for example, `≠∾↑𝕩` or `+´≠¨↑𝕩`) scales with the square of the argument length—it's quadratic in `≠𝕩`. We can find the exact total by looking at Prefixes and Suffixes together:

        (↑ ≍˘ ↓) "abcde"

        (↑ ∾¨ ↓) "abcde"

Joining corresponding elements of `↑𝕩` and `↓𝕩` gives `𝕩` again. This is because `i⊑(↑∾¨↓)𝕩` is `(i⊑↑𝕩)∾(i⊑↓𝕩)`, or, using the Take and Drop correspondences, `(i↑𝕩)∾(i↓𝕩)`, which is `𝕩`. Element-wise, we are combining the first `i` cells of `𝕩` with all but the first `i`.

Looking at the entire result, we now know that `(↑∾¨↓)𝕩` is `(1+≠𝕩)⥊<𝕩`. The total number of cells in this combined array is therefore `(1+n)×n`, setting `n←≠𝕩`. Each of Prefixes and Suffixes must have the same total number of cells (in code, `↑𝕩` is `⌽¨∘↓⌾⌽𝕩`, and Reverse doesn't change an array's shape). So the total number in either one is `2÷˜n×1+n`.

## Definition

Knowing the length and the elements, it's easy to define functions for Prefixes and Suffixes: `↑` is equivalent to `(↕1+≠)↑¨<` while `↓` is `(↕1+≠)↓¨<`. Each primitive is defined only on arrays with at least one axis.

## Working with pairs

Sometimes it's useful to apply an operation to every unordered pair of elements from a list. For example, consider all possible products of numbers between 1 and 6:

        ×⌜˜ 1+↕6

It's easy enough to use the [Table](map.md#table) modifier here, but it also computes most products twice. If we only care about the unique products, we could multiply each number by all the ones after it. "After" sounds like suffixes, so let's look at those:

        1+↕6

        ↓ 1+↕6

We want to include the diagonal, so we'll pair each element with the corresponding element of the suffixes, reducing the suffixes to the original array's length by dropping the last element, which is empty. In other cases, we might not want to include it and we should instead drop the first element.

        (⊢ × ≠ ↑ ↓) 1+↕6

        (⊢ × 1 ↓ ↓) 1+↕6

By using [Pair](pair.md) (`⋈`) instead of `×`, we can see the argument ordering, demonstrating that we are looking at the upper right half of the matrix produced by Table. While in this case we could use `⋈⚇0` to mimic the pervasion of `×`, we'd like this to work even on nested arguments so we should figure out how the mapping structure works to apply Each appropriately.

        ⋈⌜˜ "abc"

        (<˘ ⋈¨¨ ≠ ↑ ↓) "abc"

As before, we can exclude the diagonal, and using Prefixes instead of Suffixes gives us the lower left half instead of the upper right—in terms of the arguments given to `⋈` it reverses the argument pairs and iterates in a different order.

        (<˘ ⋈¨¨ 1 ↓ ↓) "abc"

        (<˘ ⋈¨¨ 1 ↓ ↑) "abc"

        (<˘ ⋈¨¨ ≠ ↑ ↑) "abc"

## Slices

Prefixes and Suffixes give certain restricted slices of the argument array, where a slice is a contiguous selection of major cells. If we want all slices along the first axis, we can take the suffixes of each prefix, or vice-versa:

        ↓¨↑ "abc"

        ↑¨↓ "abc"

Effectively, this parametrizes the slices either by ending then starting index, or by starting index then length. Four empty slices are included because in a list of length 3 there are 4 places an empty slice can start: all the spaces between or outside elements (these also correspond to all the possible positions for the result of [Bins](order.md#bins)). The slices can also be parametrized by length and then starting index using [Windows](windows.md).

        ((↕1+≠)↕¨<) "abc"

        ((↕1+≠)<˘∘↕¨<) "abc"  # Split them to match Prefixes/Suffixes

We might view a slice as a selection for not two but *three* parameters: the number of cells before, in, and after the slice. The conditions are that each parameter, being a length, is at least 0, and the total of the three parameters is equal to the array length. With three parameters and one equality constraint, the space of slices is two-dimensional; the above ways to enumerate it each pick two parameters and allow the third to be dependent on these two. If you're familiar with [barycentric coordinates](https://en.wikipedia.org/wiki/Barycentric_coordinate_system) on a triangle, this should sound very familiar because that's exactly what the three parameters are!

We might also consider the question of slices along multiple axes. Because axes are orthogonal, we can choose such a slice by independently slicing along each axis. To use the homogeneous shape of arrays as much as possible, the result should still only have two added layers of nesting for the two coordinates we choose, with all possible choices for the first axis along the axes of the outer array and those for the second along the axes of each inner array. Our Windows-based solution adapts to multidimensional arrays easily:

        ((↕1+≢)<⎉2∘↕¨<) 3‿2⥊"abcdef"

This array can be [joined](join.md), indicating that the length of each inner axis depends only on the position in the corresponding outer axis (let's also drop those empty slices to take up less space).

        ∾ 1‿1 ↓ ((↕1+≢)<⎉2∘↕¨<) 3‿2⥊"abcdef"

But Prefixes and Suffixes [don't have](../commentary/problems.md#cant-take-prefixes-or-suffixes-on-multiple-axes) any way to specify that they should work on multiple axes, and always work on exactly one. So to extend this pattern we will have to define multi-dimensional versions. This turns out to be very easy: just replace Length with [Shape](shape.md) in the [definitions](#definition) above.

        Prefs ← (↕1+≢)↑¨<
        Suffs ← (↕1+≢)↓¨<
        Prefs¨Suffs 3‿2⥊"abcdef"
