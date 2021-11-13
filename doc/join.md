*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/join.html).*

# Join and Join To

The glyph `∾` combines arrays along an existing axis, a concept that other languages might call "concatenation" or "catenation" but BQN names "Join". The one-argument form Join and two-argument form Join To are parallel to [the functions](couple.md) that combine arrays along a new axis, Merge (`>`) and Couple (`≍`).

## Join To

Join To connects its two arguments together, for example to join two strings:

        "abcd" ∾ "EFG"

If the arguments have the same rank, then they are combined along the first axis: the result is an array whose major cells are the major cells of `𝕨` followed by the major cells of `𝕩`. For arrays with rank two or more, this means they will be joined "vertically" according to BQN's display.

        ⊢ a ← 3 +⌜○↕ 4
        ⊢ b ← 2‿4 ⥊ ↕8
        a ∾ b

For this definition to work, major cells of `𝕨` and `𝕩` have to have the same shape. That means that `𝕨≡○(1↓≢)𝕩`, and the shape of the result is the sum of the lengths of `𝕨` and `𝕩` followed by their shared major cell shape: to use a self-referential definition, the final shape is given by `+○≠ ∾ ⊣⁼○(1↓≢)` for arguments of equal rank.

        a ∾ 2‿5⥊b  # Shapes don't fit

Join To will also allow arguments with ranks that are one apart. In this case, the smaller-rank argument is treated as a major cell in its entirety. If for example `𝕨<○=𝕩`, then we must have `(≢𝕨)≡1↓≢𝕩`, and the result shape is `1⊸+⌾⊑≢𝕩`.

        4‿2‿3‿0 ∾ a

An edge case for Join To is that it can also be applied to two units to make a list:

        3 ∾ 'c'

This case is unusual because the rank of the result is higher than that of either argument. It's also identical to Couple (`≍`); Couple should be preferred because it doesn't require a special case for this situation. See [coupling units](couple.md#coupling-units).

## Join

The monadic form of `∾`, called simply Join, is more complicated than Join To because it really takes not just one argument but an entire array of them. Join is an extension of the monadic function [Raze](https://aplwiki.com/wiki/Raze) from A+ and J to arbitrary argument ranks. It has the same relationship to Join to, the dyadic function sharing the same glyph, as [Merge](couple.md) (`>`) does to Couple (`≍`): `a≍b` is `>a‿b` and `a∾b` is `∾a‿b`. While Merge and Couple combine arrays (the elements of Merge's argument, or the arguments themselves for Couple) along a new leading axis, Join and Join to combine them along the existing leading axis. Both Merge and Join can also be called on a higher-rank array, causing Merge to add multiple leading axes while Join combines elements along multiple existing axes.

Join can be used to combine several strings into a single string, like `array.join()` in Javascript (but it doesn't force the result to be a string).

        ∾"time"‿"to"‿"join"‿"some"‿"words"

To join with a separator in between, we might prepend the separator to each string, then remove the leading separator after joining. Another approach would be to insert the separator array as an element between each pair of array elements before calling Join.

        1↓∾' '∾¨"time"‿"to"‿"join"‿"some"‿"words"

Join also extends the rank of a unit element (including an atom) to allow it to fit into the list. The highest-rank element determines the rank of the result.

        ∾"abc"‿'d'‿"ef"‿(<'g')

        ∾"abcd"  # Result has to be rank 0, impossible

However, Join has higher-dimensional uses as well. Given a rank-`m` array of rank-`n` arrays (requiring `m≤n`), it will merge arrays along their first `m` axes. For example, if the argument is a matrix of matrices representing a [block matrix](https://en.wikipedia.org/wiki/Block_matrix), Join will give the corresponding unblocked matrix as its result.

        ⊢ m ← (3‿1≍⌜4‿2‿5) ⥊¨ 2‿3⥊↕6
        ∾ m  # Join all that together

Axes with length 1 in the argument can also be left out, if it's done consistently for all elements in that position. One use of this is to add borders to an array, as in the multiplication table below.

        ⊢ n ← 2‿4‿6 ×{⟨𝕗,𝕩⟩≍⟨𝕨,𝕨𝔽⌜𝕩⟩} 5‿6‿7‿8

        ≢¨ n  # Different ranks but compatible shapes

        ∾ n

Even with the extension, Join has fairly strict requirements on the shapes of its argument elements—although less strict than those of Merge, which requires they all have identical shape. Suppose the argument to Join has rank `m`. The highest element rank (call it `n`) must be at least `m`. The trailing shapes `(-n-m)↑⟜≢¨𝕩` must all be identical (the trailing shape `(-n-m)↑≢∾𝕩` of the result will match these shapes as well). The other entries in the leading shapes need not be the same, but the shape of an element along a particular axis must depend only on the location of the element along that axis in the full array. For a list argument this imposes no restriction, since the one leading shape element is allowed to depend on position along the only axis. But for higher ranks the structure quickly becomes more rigid.

To state this requirement more formally in BQN, we say that there is some list `s` of lists of lengths, so that `(≢¨s)≡≢𝕩`. We require element `i⊑𝕩` to have shape `i⊑¨s`. Then the first `m` axes of the result are `+´¨s`. To handle omitted axes, we change `s` to contain lists of length 0 or 1 instead of lengths, and require `i⊑𝕩` to have shape `∾i⊑¨s` instead. In the result, an omitted axis behaves exactly like a length-1 axis, so the result can be found using shapes derived from `1⊣´¨¨s`.
