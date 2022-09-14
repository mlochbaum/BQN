*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/arithmetic.html).*

# Implementation of arithmetic

The dyadic arithmetic functions are `+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥`. There are also monadic arithmetic functions, but they're mostly easy to optimize.

## Boolean functions

Many arithmetic functions give boolean results when both arguments are boolean. Because there are only 16 possible functions like this, they overlap a lot. Here's a categorization:

        f ← ∧‿∨‿<‿>‿≠‿=‿≤‿≥‿+‿-‿×‿÷‿⋆‿√‿⌊‿⌈‿|‿¬

        bt ← {⥊𝕏⌜˜↕2}¨f
        ∧⌾(⌽¨⌾(⊏˘)) bt (⍷∘⊣≍˘⊐⊸⊔)○((∧´∘∊⟜(↕2)¨bt)⊸/) f

Some functions have fast implementations when one argument is boolean. The only ones that really matter are `×`/`∧`, which can be implemented with a bitmask, and `∨`, which changes the other argument to 1 when the boolean argument is 1 and otherwise leaves it alone. `⋆` is `∨⟜¬` when `𝕩` is boolean.

A function of an atom and a boolean array, or a monadic function on a boolean array, can be implemented by a lookup performed with (preferably SIMD) bitmasking.

## Strength reductions

### Trivial cases

Several cases where either one argument is an atom, or both arguments match, have a trivial result. Either the result value is constant, or it matches the argument.

| Constant   | Constant  |  Identity
|------------|-----------|-----------
|            |           | `a+0`
| `a-a`      |           | `a-0`
| `a¬a`      |           | `a¬1`
|            | `a×0`\*   | `a×1`
|            | `a∨1`     | `a∨0`
| `a÷a`\*    | `0÷a`\*   | `a÷1`
|            | `a⋆0`     | `a⋆1`
|            |           | `¯∞⌊a`, `∞⌈n`
| `a>a` etc. |           | `a⌊a`, `a⌈a`

None of the constant column entries work for NaNs, except `a⋆0` which really is always 1. Starred entries have some values of `a` that result in NaN instead of the expected constant: `0` for division and `∞` for multiplication. This means that constant-result `÷` always requires checking for NaN while the other entries work for integers without a check.

### Division and modulus

Division, integer division, and Modulus by an atom (`a÷n`, `a⌊∘÷n`, `n|a`) are subject to many optimizations.

- Floating-point with FMA: [this page](http://marc-b-reynolds.github.io/math/2019/03/12/FpDiv.html) gives a slightly slower method that works for all divisors and a faster one that can be proven to work on over half of divisors.
- Integer division: see [libdivide](https://github.com/ridiculousfish/libdivide). Most important is a mask for power-of-two `n`. For smaller integer types, using SIMD code with 32-bit floats is also fast.
