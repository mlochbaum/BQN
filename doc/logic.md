# Logic functions: And, Or, Not (also Span)

BQN retains the APL symbols `∧` and `∨` for logical *and* and *or*, and changed APL's `~` to `¬` for *not*, since `~` looks too much like `˜` and `¬` is more common in mathematics today. Like J, BQN extends Not to the linear function `1⊸-`. However, it discards [GCD](https://aplwiki.com/wiki/GCD) and [LCM](https://aplwiki.com/wiki/LCM) as extensions of And and Or, and instead uses bilinear extensions: And is identical to Times (`×`), while Or is `×⌾¬`, following De Morgan's laws (other ways of obtaining a function for Or give an equivalent result—there is only one bilinear extension).

If the arguments are probabilities of independent events, then an extended function gives the probability of the boolean function on their outcomes (for example, if *A* occurs with probability `a` and *B* with probability `b` independent of *A*, then *A* or *B* occurs with probability `a∨b`). These extensions have also been used in complexity theory, because they allow mathematicians to transfer a logical circuit from the discrete to the continuous domain in order to use calculus on it.

Both valences of `¬` are equivalent to the fork `1+-`. The dyadic valence, called "Span", computes the number of integers in the range from `𝕩` to `𝕨`, inclusive, when both arguments are integers and `𝕩≤𝕨` (note the reversed order, which is used for consistency with subtraction). This function has many uses, and in particular is relevant to the [Windows](windows.md) function.

## Definitions

We define:

    Not ← 1+-  # also Span
    And ← ×
    Or  ← ×⌾¬

Note that `¬⁼ ←→ ¬`, since when applying `¬` twice the first added 1 will be negated but the second won't; the two 1s cancel leaving two subtractions, and `-⁼ ←→ -`. An alternate definition of Or that matches the typical formula from probability theory is

    Or  ← +-×

## Examples

We can form truth tables including the non-integer value one-half:

        ¬ 0‿0.5‿1
    [ 1 0.5 0 ]

        ∧⌜˜ 0‿0.5‿1
    ┌
      0    0   0
      0 0.25 0.5
      0  0.5   1
                 ┘

        ∨⌜˜ 0‿0.5‿1
    ┌
        0  0.5 1
      0.5 0.75 1
        1    1 1
                 ┘

As with logical And and Or, any value and 0 is 0, while any value or 1 is 1. The other boolean values give the identity elements for the two functions: 1 and any value gives that value, as does 0 or the value.

## Why not GCD and LCM?

The main reason for omitting these functions is that they are complicated and, when applied to real or complex numbers, require a significant number of design decisions where there is no obvious choice (for example, whether to use comparison tolerance). On the other hand, these functions are fairly easy to implement, which allows the programmer to control the details, and also add functionality such as the extended GCD.

A secondary reason is that the GCD falls short as an extension of Or, because its identity element 0 is not total. `0∨x`, for a real number `x`, is actually equal to `|x` and not `x`: for example, `0∨¯2` is `2` in APL. This means the identity `0∨x ←→ x` isn't reliable in APL.

## Identity elements

It's common to apply `∧´` or `∨´` to a list (checking whether all elements are true and whether any are true, respectively), and so it's important for extensions to And and Or to share their identity element. Minimum and Maximum do match And and Or when restricted to booleans, but they have different identity elements. It would be dangerous to use Maximum to check whether any element of a list is true because `>⌈´⟨⟩` yields `¯∞` instead of `0`—a bug waiting to happen. Always using `0` as a left argument to `⌈´` fixes this problem but requires more work from the programmer, making errors more likely.

It is easy to prove that the bilinear extensions have the identity elements we want. Of course `1∧x` is `1×x`, or `x`, and `0∨x` is `0×⌾¬x`, or `¬1×¬x`, giving `¬¬x` or `x` again. Both functions are commutative, so these identities are double-sided.

Other logical identities do not necessarily hold. For example, in boolean logic And distributes over Or and vice-versa: `a∧b∨c ←→ (a∧b)∨(a∧c)`. But substituting `×` for `∧` and `+-×` for `∨` we find that the left hand side is `(a×b)+(a×c)+(a×b×c)` while the right gives `(a×b)+(a×c)+(a×b×a×c)`. These are equivalent for arbitrary `b` and `c` only if `a=a×a`, that is, `a` is 0 or 1. In terms of probabilities the difference when `a` is not boolean is caused by failure of independence. On the left hand side, the two arguments of every logical function are independent. On the right hand side, each pair of arguments to `∧` are independent, but the two arguments to `∨`, `a∧b` and `a∧c`, are not. The relationship between these arguments means that logical equivalences no longer apply.
