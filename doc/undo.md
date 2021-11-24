*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/undo.html).*

# Undo

Oh no, you've deleted a function after spending half an hour writing it! Well… hopefully your editor can help with that. But maybe you'll be interested to hear that BQN can reverse the action of some functions—ones that *don't* lose information. This capability is also used by [Repeat](repeat.md) (`⍟`) to repeat a negative number of times.

        2 ⌽ "abcde"

        2 ⌽⁼ 2 ⌽ "abcde"

Above is one example of Undo (`⁼`) in action. [Rotate](reverse.md) shifts the elements of a list left, and undoing shifts them to the right. BQN's ability to undo functions covers a lot of cases and can seem somewhat magical:

        (Fn ← -⟜1⌾(¯1⊸⊑)) "BQN"

        Fn⁼ Fn "BQN"

Here it undoes a function to decrement the last character by incrementing that character. In part this is enabled by the clean design of BQN primitives, because better-behaved functions like those using structural Under are easier to invert.

## The rules

If `𝔽` can be inverted exactly, then Undo just does that. However, there are also some other functions that BQN inverts. For example, the squaring function `×˜` has both a positive and a negative inverse, and yet:

        ×˜ ¯3
        ×˜⁼ ×˜ ¯3  # It's not the same!

Don't worry, this isn't 'nam. Undo doesn't always satisfy `𝕩 ≡ 𝔽⁼ 𝔽 𝕩`, but it *does* obey `𝕩 ≡ 𝔽 𝔽⁼ 𝕩`. That is, it gives one possible argument that could have been passed to `𝔽`, just not necessarily the one that actually was. BQN is conservative in how it uses this freedom, so that it won't for example make up new elements entirely to find an inverse: `1⊸↓` is one function that it could undo but won't. It's usually used when there's an obvious or standard way to pick which of the possible values should be returned.

In a BQN with floating-point numbers, computations are approximate, so the inverse is allowed to be approximate as well (any error should still be very small though).

        6 - √⁼√6

## What's supported?

For the full list, see [the specification](../spec/inferred.md#undo). An individual implementation might support a lot more functionality than is required, so if you're not concerned about portability just try out whatever function you're interested in.

Arithmetic and simple combinators are usually invertible. A compound function that refers to its argument just once, like `6+⌽∘⍉`, can typically be undone, but one that uses the argument in two different ways, such as `⊢+⋆`, probably can't.

A few notable inverses are the [logarithm](arithmetic.md#basic-arithmetic) `⋆⁼`, [un-Transpose](transpose.md) `⍉⁼`, and [Indices inverse](replicate.md#inverse) `/⁼`. [Enclose](enclose.md) inverse, `<⁼`, is an alternative to [First](pick.md#first) that requires its argument to be a unit array.

Structural functions like [Take](take.md) and [shifts](shift.md) that remove elements from `𝕩` can't be inverted, because given the result there's no way to know what the elements should be. However, there are two special cases that have inverses defined despite losing data: these are `⊣⁼` and `k⁼` where `k` is a constant (a data type, or `k˙`). For these, `𝕩` is required to [match](match.md) the always returned value `𝕨` or `k`, and this value is also used for the result—even though any result would be valid, as these functions ignore `𝕩`.

        3 ⊣⁼ 4
        3 ⊣⁼ 3

## Undo headers

Of course BQN will never be able to invert all the functions you could write (if it could you could earn a *lot* of bitcoins, among other feats). But it does recognize some [header](block.md#block-headers) forms that you can use to specify the inverse of a block function. BQN will trust you and won't verify the results your specified inverse gives.

    {
      𝕊𝕩:  𝕩÷1+𝕩 ;
      𝕊⁼𝕩: 𝕩÷1-𝕩
    }

The above function could also be defined with the automatically invertible `1⊸+⌾÷`, but maybe there's a numerical reason to use the definition above. Like a normal header, an undo header reflects the normal use, but it includes `⁼` and possibly `˜` addition to the function and arguments.
