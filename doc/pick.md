*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/pick.html).*

# Pick

Pick (`⊑`) chooses elements from `𝕩` based on [index](indices.md) lists from `𝕨`. `𝕨` can be a plain list, or even one number if `𝕩` is a list, in order to get one element from `𝕩`. It can also be an array of index lists, or have deeper array structure: each index list will be replaced with the element of `𝕩` at that index, effectively applying to `𝕨` at [depth](depth.md#the-depth-modifier) 1.

The one-argument form is called First, and `⊑𝕩` takes the first element of `𝕩` in index order, with an error if `𝕩` is empty.

While sometimes "scatter-point" indexing is necessary, using Pick to select multiple elements from `𝕩` is less array-oriented than [Select](select.md) (`⊏`), and probably slower. Consider rearranging your data so that you can select along axes instead of picking out elements.

## One element

When the left argument is a number, Pick gets an element from a list:

        2 ⊑ 0‿1‿2‿3‿4
        2 ⊑ "abc"
        2 ⊑ ⟨@, 0‿1‿2‿3, "abc"⟩

A negative number `𝕨` behaves like `𝕨+≠𝕩`, so that `¯1` will select the last element, and `-≠𝕩` the first. A number in `𝕨` must be an integer less than `≠𝕩` but not less than `-≠𝕩`.

        ¯2 ⊑ 0‿1‿2‿3‿4
        ¯2 ⊑ "abc"

Making `𝕩` a list is only a special case. In general `𝕨` can be a list of numbers whose length is `𝕩`'s rank. So when `=𝕩` is 1, `𝕨` can be length-1 list. The case above where `𝕨` is a number is a simplification, but an enclosed number `𝕨` isn't allowed because it could be confused with the nested case described below.

        ⟨2,0⟩ ⊑ ↕4‿5

Above we see that picking from the result of [Range](range.md) gives the index. For something slightly more interesting, here's a character array:

        ⊢ a ← 'a' + ⥊⟜(↕×´) 4‿5
        2‿0 ⊑ a
        1‿¯1 ⊑ a

`𝕩` can even be a [unit](enclose.md#whats-a-unit). By definition it has rank 0, so the only possible value for `𝕨` is the empty list. This extracts an [enclosed](enclose.md) element, and returns an atom unchanged—the atom is promoted to an array by enclosing it, then the action of Pick undoes this. But there's rarely a reason to use this case, because the monadic form First accomplishes the same thing.

        ⟨⟩ ⊑ <'a'
        ⟨⟩ ⊑ 'a'

### First

With no left argument, `⊑` is called First, and is the same as Pick with a default left argument `0¨≢𝕩`. For a non-empty array it returns the first element in index order.

        ⊑ <'a'
        ⊑ "First"
        ⊑ ↕4‿2‿5‿1

And if `𝕩` is empty then First results in an error.

        ⊑ ""

        ⊑ ≢π

In APL it's common to get the last element of a list with an idiom that translates to `⊑⌽`, or First-[Reverse](reverse.md). In BQN the most straightforward way is to select with index `¯1` instead. I also sometimes use [Fold](fold.md) with the Right [identity function](identity.md).

        ⊑⌽ "last"
        ¯1⊑ "last"
        ⊢´ "last"

## Many elements

Pick also accepts a list of indices:

        a  # Defined above

        ⟨2‿0, 1‿¯1, 3‿1, ¯1‿¯1⟩ ⊑ a

These indices have to be lists, since if they're numbers it just looks like `𝕨` is an index list for one element.

        ⟨2,1,0,¯1⟩ ⊑ "abc"  # 𝕩 doesn't have rank 4!

        ⟨2,1,0,¯1⟩ ⥊¨⊸⊑ "abc"

        ⟨2,1,0,¯1⟩ ⊏ "abc"  # Better way

It's much more general than just a list of indices though. As long as your indices are lists, you can arrange them in any array structure with arbitrary nesting.

        ⟨2‿0, ⟨⟨1‿¯1, 3‿1⟩, ¯1‿¯1⟩⟩ ⊑ a

        (⟨2‿0, 1‿¯1⟩≍⟨3‿1, ¯1‿¯1⟩) ⊑ a

        (⟨2‿0, <1‿¯1⟩≍⟨<3‿1, ¯1‿¯1⟩) ⊑ a

This option is easily described using the [Depth modifier](depth.md#the-depth-modifier). Pick applies to depth-1 components of the left argument and the entire right argument, which corresponds to a depth operand of `1‿∞`. The left argument components have to be lists of numbers, or Pick gives an error.

        (⟨2‿0, <1‿¯1⟩≍⟨<3‿1, ¯1‿¯1⟩) ⊑⚇1‿∞ a

        ⟨⟨2,3⟩,1⟩ ⊑ a  # 1 isn't a valid index
