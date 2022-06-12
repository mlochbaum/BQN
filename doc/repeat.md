*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/repeat.html).*

# Repeat

Repeat (`⍟`) is a 2-modifier that applies its operand function `𝔽` multiple times.

        »»» "ABCDE"

        »⍟3 "ABCDE"

In mathematics (which unsurpisingly tends to use complicated terms to talk about an easy concept), this kind of repetition is called an [iterated function](https://en.wikipedia.org/wiki/Iterated_function) and written with exponential notation. It's related to function [composition](compose.md) `∘` in the same way that exponentiation (`⋆`) relates to multiplication (`×`): function iteration is repeated composition.

    n⋆4  ←→  n×n×n×n
    F⍟4  ←→  F∘F∘F∘F

`F⍟0` repeats `F` zero times, that is, does nothing. Like `n⋆0` gives the multiplicative identity `1`, `F⍟0` is the compositional [identity](identity.md), `⊢`. Since `F⍟1` applies `F` and `F⍟0` doesn't, Repeat might be pronounced "if" or "conditional" when `𝔾` is boolean.

BQN's Repeat modifier has some extra functionality relative to the mathematical version. It allows a left argument, and some extensions to the right operand `𝔾`. As usual for 2-modifiers, `𝔾` is actually a function that applies to the arguments to give a result. The result can be a natural number as shown above, or a negative number to [Undo](undo.md) (`⁼`) `𝔽`, or an array of values.

## Left argument

If `𝕨` is given, it's passed as the left argument to `𝔽` for every invocation.

        3 +⍟2 7
        3 + 3 + 7

This kind of composition can't be represented by `∘` anymore (you'd need a [train](train.md)), but it's not much of a leap. `𝕨 𝔽⍟n 𝕩` is always equivalent to `𝕨⊸𝔽⍟n 𝕩`, provided `n` is a constant—not a function, as discussed in the next section.

## Dynamic repetition count

In the general case, `𝔾` is a function, which is applied to all arguments to get the repetition count. That is, the *actual* count is `𝕨𝔾𝕩`.

        ∾⟜1⍟⊢ 4

        1⊸+⍟≠ ↕4

The most common use is the case where `𝔾` is a condition that returns `0` or `1`. Then Repeat simply applies `𝔽` if the condition holds. For example, the following code halves numbers that are greater than 6.

        ÷⟜2⍟{6<𝕩}¨ 3‿7‿2‿1‿8

If `𝕨` is given, then `𝔾` gets it as a left argument (to avoid this, use `𝕨⊸𝔽⍟𝔾 𝕩`, which applies `𝔾` to `𝕩` only). This form also works well with a boolean condition.

        3 ⊣⍟<¨ 2‿4‿6  # Left if less, i.e. minimum

## Negative repetition

What does it mean to repeat a function a negative number of times? For a negative integer `-n`, BQN defines `F⍟(-n)` to be `F⁼⍟n`. In particular, `F⍟¯1` simply [undoes](undo.md) `F`.

        1 ⌽⍟¯1 "abcde"  # Rotate backwards

Because BQN's Undo is a little looser than a strict mathematical inverse, this is an extension of the function inverse written f⁻¹ in mathematics. As a result, it doesn't have all the same properties. For natural numbers, Repeat follows the rule that `F⍟m F⍟n 𝕩` is `F⍟(m+n) 𝕩`. With a negative, we have `𝕩 ≡ F⍟n F⍟(-n) 𝕩`, but not necessarily `𝕩 ≡ F⍟(-n) F⍟n 𝕩`.

## Array of repetition counts

The value of `𝕨𝔾𝕩` might also be an array, whose elements are any valid repetition values—integers, or other arrays. Each integer in the nested structure is replaced with the result of repeating `𝔽` that many times.

        2⊸×⍟⟨2,⟨4,¯2,1⟩⟩ 1

Regardless of how numbers in `𝕨𝔾𝕩` are arranged, `𝔽` is evaluated the minimum number of times required to find the result, and regular (positive) applications are all performed before reverse (negative) ones. So the pattern of application is entirely defined by the smallest and largest values given by `𝔾`.
