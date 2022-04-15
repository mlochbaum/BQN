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

In the general case, I think of Before as using `𝔽` as a preprocessing function applied to `𝕨` (when there are two arguments) and After as using `𝔾` as preprocessing for `𝕩`. Then the other operand is called on the result and remaining argument. Here are some simple calls with Pair (`⋈`): the result is a pair that corresponds to `𝕨‿𝕩`, but one or the other result has been modified by the pointy-side function.

        9 √⊸⋈ 2

        9 ⋈⟜↕ 2

When only one argument is given, it's used in both positions, so that the arguments to the final function are `𝕩` and a function applied to `𝕩`.

        ⋈⟜↕ 5

This can be used to make a "filter" pattern using [Replicate](replicate.md) (`/`). The difference is that Replicate takes a list `𝕩` and boolean list `𝕨` indicating which elements to keep, but filter should take a list and a function that says whether to keep each element. The pattern is `F¨⊸/ x`, expanding to `(F¨x) / x`. Here's a list filtered with the function `{𝕩<0}`.

        {𝕩<0}¨⊸/ 4‿¯2‿1‿¯3‿¯3

As `<` is a pervasive function, there's no need for the Each (`¨`) in this case, and the clunky block function `{𝕩<0}` can also be written smaller with a combinator, as `<⟜0`. More on that in the next section…

        <⟜0⊸/ 4‿¯2‿1‿¯3‿¯3

## Bind

"Bind" isn't a special case of Before and After, but instead a description of one way to use them. Let's take a look at the example from the previous section:

        <⟜0  4‿¯2‿1‿¯3‿¯3

If we expand `<⟜0 x`, we get `x < (0 x)`, which doesn't quite make sense. That's because `0` has a subject role, but `⟜` always applies its operands as functions. It's more accurate to use `x < (0{𝔽} x)`, or just skip ahead to `x < 0`.

Similar reasoning gives the following expansions:

|   `Cmp`   | `0⊸<`   | `<⟜0`
|-----------|---------|---------
| `  Cmp x` | `0 < x` | `x < 0`
| `w Cmp x` | `0 < x` | `w < 0`

Note that when there are two arguments, the constant "swallows" the one on the same side, so that the function is applied to the constant and the argument on the *opposite* side.

As in a train, if you want to use a function as a constant then you need to be explicity about it, with the [Constant](constant.md) (`˙`) modifier.

        3 ⋈⟜(⌊˙)⊸⥊ 'a'+↕12

In the more extreme case of wanting a *modifier* operand, you might try `⋈⟜({∘}˙)⊸⥊`, or `(⊣⋈{∘}˙)⊸⥊`, or just cheat with `∾⟜⟨∘⟩⊸⥊`.
