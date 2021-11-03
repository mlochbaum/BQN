*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/pair.html).*

# Pair

The function `⋈` forms a list of all its arguments. When there's one argument, it's called "Enlist", and with two, it's called "Pair".

        ⋈ "enlist"    # ⟨𝕩⟩

        "pa" ⋈ "ir"   # ⟨𝕨,𝕩⟩

It's usually preferable to use [list notation](arrayrepr.md#brackets) directly for such arrays, because it's easy to add or remove any number of elements. Pair is useful when a standalone function is needed, for example to be used as an operand.

        2‿4‿1 ⋈⌜ "north"‿"south"  # Cartesian product

        ⋈¨ "+-×÷"  # Glyphs to strings

Another common pattern is to use Pair in a [train](train.md), giving the results from applying each of two functions.

        'c' (+⋈-)  1‿2

For longer lists, this pattern can be extended with the function `<⊸∾`, which prepends a single element to a list.

        "e0" <⊸∾ "e1" <⊸∾ "e2" ⋈ "e3"

However, before making a long list of this sort, consider that your goal might be more easily accomplished with a list of functions.

        6 (+ <⊸∾ - <⊸∾ × ⋈ ÷) 3

        {6𝕏3}¨ +‿-‿×‿÷

## Pair versus Couple

Enlist and Pair closely related to [Solo and Couple](couple.md), in that `⋈` is equivalent to `≍○<` and `≍` is equivalent to `>∘⋈`. However, the result of `⋈` is always a list (rank 1) while Solo or Couple return an array of rank at least 1.

        "abc" ≍ "def"

        "abc" ⋈ "def"

And the arguments to Couple must have the same shape, while Enlist takes any two arguments.

        "abc" ≍ "defg"

        "abc" ⋈ "defg"

The difference is that Couple treats the arguments as cells, and adds a dimension, while Pair treats them as elements, adding a layer of depth. Couple is a "flat" version of Pair, much like Cells (`˘`) is a flat version of Each (`¨`). Pair is more versatile, but—precisely because of its restrictions—Couple may allow more powerful array operations on the result.

## Fill element

Enlist and Pair set the result's [fill](fill.md) element, while list notation doesn't have to. So the following result is guaranteed:

        4 ↑ "a"‿5 ⋈ "b"‿7

This means that `⋈` may always behave the same as the obvious implementation `{⟨𝕩⟩;⟨𝕨,𝕩⟩}`. However, `≍○<` and even `>∘{⟨𝕩⟩;⟨𝕨,𝕩⟩}○<` compute the result fill as `⋈` does and are identical implementations.
