*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/arithmetic.html).*

# Implementation of arithmetic

The dyadic arithmetic functions are `+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥`. There are also monadic arithmetic functions, but they're mostly easy to optimize.

## Negative zero

IEEE defines the float value -0. But to make sure integer-valued floats can be consistently optimized as integers, it's best to treat it identically to 0 (this is much easier than trying to not produce -0s, as a negative number times 0 is -0). To convert a number to 0 if it's -0, just add 0. This needs to be done in `÷` for `𝕩`, in `⋆` for `𝕨`, and in `√` for both arguments if it's defined separately. Also in `•math.Atan2` for both arguments if defined.

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

| Constant   | Constant     |  Identity
|------------|--------------|-----------
|            |              | `a+0`
| `a-a`      |              | `a-0`
| `a¬a`      |              | `a¬1`
|            | `a×0`\*      | `a×1`
|            | `a∨1`        | `a∨0`
| `a÷a`\*    | `0÷a`\*      | `a÷1`
|            | `a⋆0`, `1⋆a` | `a⋆1`
|            |              | `¯∞⌊a`, `∞⌈n`
| `a>a` etc. |              | `a⌊a`, `a⌈a`

None of the constant column entries work for NaNs, except `a⋆0` and `1⋆a` which really are always 1. Starred entries have some values of `a` that result in NaN instead of the expected constant: `0` for division and `∞` for multiplication. This means that constant-result `÷` always requires checking for NaN while the other entries work for integers without a check.

### Division and modulus

Division, integer division, and Modulus by an atom (`a÷n`, `a⌊∘÷n`, `n|a`) are subject to many optimizations.

- Floating-point with FMA: [this page](http://marc-b-reynolds.github.io/math/2019/03/12/FpDiv.html) gives a slightly slower method that works for all divisors and a faster one that can be proven to work on over half of divisors.
- Integer division: see [libdivide](https://github.com/ridiculousfish/libdivide). Most important is a mask for power-of-two `n`. For smaller integer types, using SIMD code with 32-bit floats is also fast: see below.

#### Integer division with floats

If `p` and `q` are integers and `p` is small enough, then the floor division `⌊p÷q` gives an exact result. This isn't always the case for floats: for example `1 ⌊∘÷ (÷9)+1e¯17` rounds up to 9 when an exact floor-divide would round down to 8. It means that `q|p` is exactly `p-q×⌊p÷q`, a faster computation.

In particular, if `p` is a 16-bit or smaller integer and `q` is any integer, then the floor division `⌊p÷q` and modulus `q|p` can be computed exactly in single (32-bit float) precision. If `p` is a 32-bit integer these can be computed exactly in double precision.

We will prove the case with 32-bit `p` in double precision. If `q` is large, say it has absolute value greater than `2⋆32`, then `(|p÷q)<1`, meaning the correct result is `¯1` if it's negative and `0` otherwise. If `p` is nonzero, then `(|p÷q) > |÷q`, which is greater than the smallest subnormal for any `q`, and so the division won't round up to 0. So suppose `q` is small. If `p` is a multiple of `q`, say `p=k×q`, then `k≤○|p` so `k` is exactly representable as a double and the division is exact. If `p` is not an exact multiple, say `p=(k×q)-o` with nonzero `o<q`, then write it as `k×(q-o÷k)` and the quotient is `k×1-o÷k×q`, or `k×1-o÷p+o`. For this number to round up to `k` it would have to be larger than `k×1-÷2⋆52`, but `p+o` is less than `p+q` which is much less than `2⋆52`, so the rounded division result is less than `k`, giving a floor of `k-1`.
