*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/identity.html).*

# Identity functions

Here are the simplest functions in BQN: Right (`⊢`) always returns its right argument, and Left (`⊣`) returns its left argument if called with two arguments, and the right argument otherwise.

        ⊢ "only"

        ⊣ "only"

        "left" ⊢ "right"

        "left" ⊣ "right"

Depending on your past experiences, this could cause some confusion: built-in support for functions that do nothing? Documentation should say why a feature's there and how to use it, not just what it does, so we'll try to address this below. The most important single use is for [tacit](tacit.md) programming, but there are a variety of other uses as well.

Of course, it's easy to write block functions `{𝕩}` and `{𝕨}` that return particular arguments. While I would already make `⊣` and `⊢` primitives just because they are common and important, there are also specific disadvantages to using blocks. They fail to indicate that there are no side effects, as primitives would, and they also need special casing for the interpreter to manipulate them when applying [Undo](undo.md) (`⁼`) or making other inferences.

## Filling arrays

What's the easiest way to create a matrix with 0 on the first row, 1 on the second, and so on? Probably this one, with [table](map.md#table):

        (↕4) ⊣⌜ ↕5

The right argument `↕5` could be any length-5 list, as its values aren't used. With `5⥊0`, we could use `+⌜` instead, but requiring a specific argument seems artificial. A similar pattern applies with [Each](map.md#each):

        (⌽↕4) ⊣¨ ↕4‿5

A more powerful pattern is with dyadic [Under](under.md) (`⌾`): unselected parts of the result will use values from `𝕩`. If `𝔽` is `⊣`, then the selected ones will use values from `𝕨`, merging these arrays together.

        "ABCDE" ⊣⌾(0‿1‿1‿0‿0⊸/) "abcde"

        ⟨"wxy"‿"z",@⟩ ⊣⌾(1⊑⊑∘⊑) ⟨⟨↕3,↕2⟩,4‿5⟩

This method can replace even values nested deeply in arrays, as long as you can write the function to get at them. The parts that aren't accessed don't even need to have matching shapes!

## As a variable

Suppose you want a list of a matrix, its transpose, and its negation. One way to do this is to put together a list of functions for each of these values: the first one is an identity.

        ⊢‿⍉‿- {𝕎𝕩}¨< 0‿¯1≍1‿0

Here `⊢` ends up being used as `𝕎`. A similar case might be a function or program with a caller-specified processing step. For example, a function to write some kind of file, with a parameter function to encrypt data before writing. To use no encryption, you'd pass a parameter `⊢`. Or it might happen that you write a Choose (`◶`) expression where one of the cases should do nothing `⊢`, or return the left argument `⊣`.

## In tacit functions

In a [tacit](tacit.md) context, `⊣` is roughly equivalent to `𝕨` and `⊢` to `𝕩`. In some (not too common) cases, it's even possible to translate a block function to tacit code directly by replacing the variables in this way.

        3 {𝕩-𝕨÷1+𝕩} 5
        3 (⊢-⊣÷1+⊢) 5

A larger class of block functions can be translated just by adding parentheses and `˙` (there's a discussion of this technique in APL [here](https://dfns.dyalog.com/n_tacit.htm)). It's helpful when writing tacit code to know that `Fn∘⊣` applies `Fn` to the left argument only and `Fn∘⊢` applies it to the right argument—these can be read "Fn of left" and "Fn of right".

## One more thing

You've probably seen `⊢` used in documentation to display the value of a variable being assigned. Normally `•Show` is used to display values, but the website is sort of a weird context: it displays by default but disables it if the final thing done is an assignment. `⊢` isn't assignment, so it works arround that rule.

        ⊢ a ← "show this"
