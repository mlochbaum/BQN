*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/range.html).*

# Range

Range (`↕`) is a monadic function that creates arrays of indices, like APL's famous [iota](https://aplwiki.com/wiki/Index_Generator) function `⍳`. Each element in the result is its own [index](indices.md).

        ↕ 6

        ↕ 2‿3

It's really two different functions packed together: if `𝕩` is a natural number—a length—then it returns a list of numeric indices, but if it's a list of numbers, then it returns an array of index lists. This means the result always has [depth](depth.md) one more than the argument.

The two kinds of index correspond to BQN's two selection functions: [Select](select.md) (`⊏`) works with indices along an axis, which are numbers, and [Pick](pick.md) (`⊑`) works with element indices, which are lists. The examples below would fail if we swapped these around. Each result from Range is a length-6 list, but their elements are different.

        ↕6

        (↕6) ⊏ "select"

        ↕⟨6⟩

        (↕⟨6⟩) ⊑ " pick "

They also correspond to [Length](shape.md) (`≠`) [and Shape](shape.md) (`≢`): for an array `a`, `↕≠a` gives the indices of major cells, while `↕≢a` gives the indices of all elements.

        a ← 4‿2⥊@

        ↕ ≠ a

        ↕ ≢ a

## Number range

Calling `↕` on an atom, which must be a natural number, is the more common case. This gives us the list of natural numbers less than `𝕩` (and starting at `0`, the first natural number as BQN defines it). You can also get the first `b` integers starting at `a` with `a+↕b`, or the natural numbers from `a` to `b` with `a↓↕b`.

        ↕4

        5 + ↕4

        2 ↓ ↕4

The result of `↕𝕩` is a list of length `𝕩`, but doesn't include `𝕩` itself. That's just how counting starting at 0 works (but a nice trick if you do want to include `𝕩` is `↕⊸∾𝕩`). It means we can create a length-0 list easily:

        ↕ 0

As with any other number argument, `↕0` has a [fill](fill.md) of 0.

        4 ↑ ↕0

        4 ↑ ↕3

Adding a character to a range produces a character range, with space as the fill.

        'b' + ↕8

        »⍟3 'b'+↕8

One interesting use of Range is to find, at each position in a boolean list, the most recent index that has a 1. To do this, first get the array of indices for `b`, `↕≠b`. Then multiply by `b`, reducing indices where a `0` is found to 0.

        ⊢ b ← 0‿1‿1‿0‿0‿0‿1‿0

        b ≍ ↕≠b

        b × ↕≠b

Now at any given position the index of the last 1, if there is any, is the [maximum](arithmetic.md#additional-arithmetic) of all the adjusted indices so far. That's a [scan](scan.md) `` ⌈` ``.

        ⌈` b × ↕≠b

        (⌈` ⊢ × ↕∘≠) b   # As a tacit function

Where there aren't any previous 1s, this returns an index of 0, which is the same as the result where there is a 1 at index 0. If it's important to distinguish these possibilities, the indices can be increased by one, so that the result is 0 if there are no 1s, and 1 for a 1 at the start. To bring it back into alignment with the argument, either this result can be decreased by 1 or an initial element can be added to the argument.

        ⌈` b × 1 + ↕≠b

## List range

When `𝕩` is a list of numbers, the result is an array of lists.

        ↕ 2‿3‿4

This array, which contains all possible choices of a natural number below each element of `𝕩`, can also be produced using Range on numbers only, along with [Table](map.md#table) (`⌜`).

        (<⟨⟩) ∾⌜´ ↕¨ 2‿3‿4

The initial element for the [fold](fold.md) above is the result of `↕⟨⟩`, which contains the one possible list of no natural numbers.

        ↕ ⟨⟩

The result of Range can also be thought of as representing all possible numbers in a mixed-base system: for example, the argument `2‿3‿4` indicates three-digit numbers where the lowest digit works in base 4, the next in base 3, and the highest in base 2. Of course, fixed bases are used more often than mixed ones. Here are all the 3-digit binary numbers:

        ↕ 3⥊2
