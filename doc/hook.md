*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/hook.html).*

# Before and After

([This joke](https://aplwiki.com/wiki/File:Before_and_after.jpg) has already been claimed by APL, unfortunately)

*Also see [this tutorial section](../tutorial/combinator.md#before-and-after) for an introduction that doesn't require so much context to understand.*

<!--GEN combinator.bqn
DrawComp ≍"⊸⟜"
-->

The "hook" combinators Before and After serve a few purposes in BQN. The important thing to remember: the pointy side goes towards the first function to be executed, and the next function that returns the final result is at the ring side. If the pointy-side function is actually a constant like a number, then the ring-side function just gets applied to that constant and one of the arguments. This is the thing Haskell programmers are constantly telling each other isn't called currying, or "Bind" in BQN.

| Name   | `Cmp` | `Cmp 𝕩`    | `𝕨 Cmp 𝕩`  | Unified      | Train
|--------|-------|------------|------------|--------------|--------
| Before | `F⊸G` | `(F𝕩) G 𝕩` | `(F𝕨) G 𝕩` | `{(𝔽𝕨⊣𝕩)𝔾𝕩}` | `F∘⊣ G ⊢`
| After  | `F⟜G` | `𝕩 F (G𝕩)` | `𝕨 F (G𝕩)` | `{(𝕨⊣𝕩)𝔽𝔾𝕩}` | `⊣ F G∘⊢`

## Description

In the general case, I think of Before as using `𝔽` as a preprocessing function applied to `𝕨` (when there are two arguments), and After as using `𝔾` as preprocessing for `𝕩`. Then the other operand is called on the result and remaining argument. Here are some simple calls with [Pair](pair.md) (`⋈`): the result is a pair that corresponds to `𝕨‿𝕩`, but one or the other result has been modified by the pointy-side function.

        9 √⊸⋈ 2

        9 ⋈⟜↕ 2

When only one argument is given, it's used in both positions, so that the arguments to the final function are `𝕩` and a function applied to `𝕩`.

        ⋈⟜↕ 5

This can be used to make a "filter" pattern using [Replicate](replicate.md) (`/`). The difference is that Replicate takes a list `𝕩` and boolean list `𝕨` indicating which elements to keep, but filter should take a list and a function that says whether to keep each element. The pattern is `F¨⊸/ x`, expanding to `(F¨x) / x`. Here's a list filtered with the function `{𝕩<0}`.

        {𝕩<0}¨⊸/ 4‿¯2‿1‿¯3‿¯3

As `<` is a [pervasive](arithmetic.md#pervasion) function, there's no need for the Each (`¨`) in this case, and the clunky block function `{𝕩<0}` can also be written smaller with a combinator, as `<⟜0`. More on that in the next section…

        <⟜0⊸/ 4‿¯2‿1‿¯3‿¯3

## Bind

"Bind" isn't a special case of Before and After, but instead a description of one way to use them. Let's take a look at the example from the previous section:

        <⟜0  4‿¯2‿1‿¯3‿¯3

If we expand `<⟜0 x`, we get `x < (0 x)`, which doesn't quite make sense. That's because `0` has a subject [role](expression.md#syntactic-role), but `⟜` always applies its operands as functions. It's more accurate to use `x < (0{𝔽} x)`, or just skip ahead to `x < 0`.

Similar reasoning gives the following expansions:

|   `Cmp`   | `0⊸<`   | `<⟜0`
|-----------|---------|---------
| `  Cmp x` | `0 < x` | `x < 0`
| `w Cmp x` | `0 < x` | `w < 0`

Note that when there are two arguments, the constant "swallows" the one on the same side, so that the function is applied to the constant and the argument on the *opposite* side.

As in a train, if you want to use a function as a constant then you need to be explicit about it, with the [Constant](constant.md) (`˙`) modifier.

        3 ⋈⟜(⌊˙)⊸⥊ 'a'+↕12

In the more extreme case of wanting a *modifier* operand, you might try `⋈⟜({∘}˙)⊸⥊`, or `(⊣⋈{∘}˙)⊸⥊`, or just cheat with `∾⟜⟨∘⟩⊸⥊`.

## Combinations

If you like to go [tacit](tacit.md), you'll likely end up stringing together a few `⊸`s and `⟜`s at times. Of course the effects are entirely determined by the left-to-right precedence rule for modifiers, but it's interesting to examine what happens in more detail.

In the pattern `F⊸G⟜H`, the ordering doesn't matter at all! That is, it means `(F⊸G)⟜H`, but this is the same function as `F⊸(G⟜H)`. In both cases, `F` is applied to `𝕨`, `H` is applied to `𝕩`, and `G` acts on both the results (the parentheses do change whether `F` or `H` is called first, which only matters if they have side effects).

        4 -⊸⋈⟜⋆ 2

I once named this pattern "split compose", but now I think it makes more sense to think of it as two pre-functions added separately to one central function (`⋈` above). The whole is exactly the sum of its parts. When applied to just one argument, `𝕩` is reused on both sides, making the composition equivalent to a 3-[train](train.md).

        -⊸⋈⟜⋆ 2

        (-⋈⋆) 2  # Same thing

More `⟜`s can be added on the right, making `𝕩` flow through all the added functions. So for example `F⟜G⟜H x` is `x F G H x`, and could also be written `F⟜(G H) x`.

A sequence of `⊸`s is more interesting. It doesn't just compose the functions (for that you need `G∘F⊸H`, but note the weird ordering—`F` applies before `G`!), but instead passes the current value *and* the initial function each time. Consider `F⊸G⊸H⊸I`, or `((F⊸G)⊸H)⊸I`: every function but `F` is on the ring side, meaning it's dyadic!

Here's a long example, that might show up if you want to [sort](order.md#sort) an array but have an intolerance for the character `∧`. In quicksort, you select a partition element from the array, then divide it into elements less than, and greater than or equal to, the pivot. You'd probably pick a [random](../spec/system.md#random-generation) element for the pivot, but here I'll go with the middle element to avoid having a webpage that generates differently every time!

        (⌊≠÷2˙)       "quicksort"  # Index of the pivot

        (⌊≠÷2˙)⊸⊑     "quicksort"  # Select pivot from 𝕩

        (⌊≠÷2˙)⊸⊑⊸≤   "quicksort"  # Compare with 𝕩

        (⌊≠÷2˙)⊸⊑⊸≤⊸⊔ "quicksort"  # Use to partition 𝕩

Three is rare, but I use two `⊸`s all the time, as well as `⟜` followed by `⊸`, for example the `<⟜'a'⊸/` filter on the [front page](../README.md). I think a combination like `lots∘of○stuff⊸/ x` reads very nicely when moving from right to left. When I see `⊸/` I know that I'm filtering `x` and can read the rest with that context. The reason `⊸` has all this power, but not `⟜`, has nothing to do with the modifiers themselves, as they're completely symmetrical. It's all in the way BQN defines modifier grammar, left to right.
