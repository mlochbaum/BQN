*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/enclose.html).*

# Enclose

The function Enclose creates a unit array whose only element is `𝕩`.

        < "xyz"

If you understand the concept of a unit array, then that definition almost certainly made sense to you. Therefore the remainder of this document will explain what a unit array is, what it isn't, and why you would use it.

If you're familiar with the Enclose or Box function from APL or J (but particularly APL), then it's possible you understand the concept of a unit array wrongly, or at least, not in the same way BQN uses it. A difference from APL is that `<𝕩` is never the same as `𝕩`. I recommend reading about [based array theory](based.md) if you haven't already.

## What's a unit?

A **unit array** is an array with no axes: that is, it has rank 0 and its shape is the empty list. The array itself isn't empty though. The number of elements is the product of the shape, which is 1.

           ≢ <"anything"   # empty shape
        ×´ ≢ <"anything"   # and one element

If there are no axes, what use is an array? Rank 0 certainly qualifies as an edge case, as there's no rank -1 below it. Most often when a unit array is used it's because there *are* relevant axes, but we want an array that doesn't include them (sound cryptic? Just keep reading…).

This contrasts with an atom like `137`, which is considered a unit but not a unit *array*. An atom has no axes just because it doesn't have axes. But because it has no axes, it has the same shape `⟨⟩` as a unit array, by convention.

Some unit arrays are made by removing an axis from an existing array. [First Cell](select.md#first-cell) (`⊏`) or [Insert](fold.md) (`˝`) might do this:

        l ← 2‿7‿1‿8‿2‿8
        ⊏ l
        +˝ l

Usually this is unwanted. You'd prefer to use `⊑` or `+´` in order to get an atom result. But consider the following function to sum the rows of a table:

        +˝˘ 3‿4⥊↕12

In this case each call to `+˝` returns a cell of the result. The result is a list, so its cells are units! Here, [Cells](rank.md) (`˘`) "hides" one axis from its operand, and the operand `+˝` reduces out an axis, leaving zero axes—until Cells assembles the results, putting its axis back. Here, `+´` would also be tolerated. But it's wrong, because each result really should be a zero-axis array. We can reveal this by making an array whose elements aren't atoms.

        +´˘ [⟨↕2,"ab"⟩,⟨↕3,"ABC"⟩]

        +˝˘ [⟨↕2,"ab"⟩,⟨↕3,"ABC"⟩]

The function `+´˘` tries to mix together the result elements into one big array, causing an error because they have different lengths, but `+˝˘` keeps them as elements.

One strained example probably isn't all that compelling. And it doesn't explain why you'd use Enclose, which doesn't remove an axis from an existing array but creates a whole new unit array. So…

## Why create a unit?

Why indeed?

### Table of combinations

Let's take a look at the following program, which uses [Table](map.md#table) (`⌜`) to create an array of combinations—every possibility from three sets of choices. It uses Enclose not once but twice.

        (<⟨⟩) <⊸∾⌜´ ⟨""‿"anti", "red"‿"blue"‿"green", "up"‿"down"⟩

One use is in the function `<⊸∾`, which encloses the left argument [before](hook.md) (`⊸`) [joining](join.md) (`∾`) it to the right argument. This is different from Join on its own because it treats the left argument as a single element.

        "start" ∾ "middle"‿"end"

        "start" <⊸∾ "middle"‿"end"

For this purpose `⋈⊸∾`, which [enlists](pair.md) the left argument giving the list `⟨𝕨⟩`, also works. But maybe it doesn't really capture the intended meaning: it makes `𝕨` into a whole new list to be added when all that's needed is to add one cell. This cell will be placed along the first axis, but it doesn't have an axis of its own. A similar example, showing how units are used as part of a computation, is to join each row of a matrix to the corresponding item of a list.

        (=⌜˜↕4) ∾˘ ↕4

Now [Cells](rank.md) (`˘`) splits both arguments into cells. For the `𝕨`, a rank-2 array, these cells are lists; for the list `𝕩` they have to be units. Treating them as elements would work in this case, because `∾` would automatically enclose them, but would fail if `𝕩` contained non-atom elements such as strings.

The other use of `<` in the original example is `(<⟨⟩)`, which is the left argument to the function `<⊸∾⌜´`. Let's break that function down. We said `<⊸∾` joins `𝕨` as an element to the front of `𝕩`. With [Table](map.md#table) we have `<⊸∾⌜`, which takes two array arguments and does this for every pair of elements from them.

        "red"‿"blue"‿"green" <⊸∾⌜ ⟨"up"⟩‿⟨"down"⟩

[Fold](fold.md) (`´`) changes this from a function of two arrays to a function of any number of arrays. And `<⟨⟩`, the enclosed empty array, is the initial value for the fold. Why do we need an initial value? To start with, consider applying to only one input array. With no initial value Fold just returns it without modification.

        <⊸∾⌜´ ⟨"up"‿"down"⟩

But this is only an array of strings, and not an array of lists of strings: the right result is `⟨⟨"up"⟩,⟨"down"⟩⟩`. And that's not the extent of our troubles: without an initial value we'll get the wrong result on longer arguments too, because the elements of the rightmost array get joined to the result lists as lists, not as elements.

        <⊸∾⌜´ ⟨"red"‿"blue"‿"green", "up"‿"down"⟩

To make things right, we need an array of lists for an initial value. Since it shouldn't add anything to the result, any lists it contains need to be empty. But what should its shape be? The result shape from Table is always the argument shapes joined together (`𝕨∾○≢𝕩`). The initial value shouldn't contribute the result shape, so it needs to have empty shape, or rank 0! We use Enclose to create the array `<⟨⟩` with no axes, because the result *will* have axes but the initial element needs to start without any. All the axes come from the list of choices.

It goes deeper! The following (pretty tough) example uses arrays with various ranks in the argument, and they're handled just fine. The last one isn't really a choice, so it has no axes. If it were a one-element list then the result would have a meaningless length-1 axis. But not enclosing it would cause each character to be treated as an option, with unpleasant results.

        flavor ← ⍉ ∘‿2 ⥊ "up"‿"down"‿"charm"‿"strange"‿"top"‿"bottom"
        (<⟨⟩) <⊸∾⌜´ ⟨"red"‿"blue"‿"green", flavor, <"quark"⟩

### Broadcasting

Table isn't the only mapping function that gets along well with units. Here's an example with [Each](map.md#each) (`¨`).

        =‿≠‿≡‿≢ {𝕎𝕩}¨ < 3‿2⥊"abcdef"

The function `{𝕎𝕩}` applies its left argument as a function to its right; we want to apply the four functions Rank, Length, [Depth](depth.md), and [Shape](shape.md) to a single array. Normally Each matches up elements from its two arguments, but it will also copy the elements of a lower-rank argument to fill in any missing trailing axes and match the higher-rank argument's shape. To copy a single argument for every function call, it should have no axes, so we enclose it into a unit.

This example would work just as well with Table (`⌜`), although maybe the interpretation is a little different. The reason it matters that Each accepts unit arrays is that arithmetic primitives (as well as the Depth modifier `⚇`) use Each to match their arguments up. Want to add a point (two numbers) to each point in an array? Just enclose it first.

        (<10‿¯10) + ⟨2‿3,1‿7⟩≍⟨4‿1,5‿4⟩

## Coda

Perhaps you feel bludgeoned rather than convinced at this point. Unit arrays are useful, sure, but aren't they ugly? Aren't they a hack?

The practical answer is that I think you should use them anyway. You'll probably come to appreciate the use of Enclose and how it can help you produce working, reliable code, making you a more effective BQN programmer.

On the theoretical side, it's important to realize that units are just a consequence of having multidimensional arrays. Array languages come with units by default, so that "adding" them is not really a complication, it's a simplification. It's natural to not feel quite right around these sorts of non-things, because zero is a pretty special number—being among other things the only number of paddles you can have and still not be able to go anywhere in your canoe. In my opinion the right response is to understand why they are special but also why they fit in as part of the system, so you can be in control instead of worrying.
