*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/arithmetic.html).*

# Implementation of arithmetic

The dyadic arithmetic functions are `+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥`. There are also monadic arithmetic functions, but they're mostly easy to optimize.

Arithmetic with Table, leading axis extension, and Rank is also covered [below](#table-and-leading-axis).

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

| Constant   | Constant      |  Identity
|------------|---------------|-----------
|            |               | `a+0`
| `a-a`      |               | `a-0`
| `a¬a`      |               | `a¬1`
|            | `a×0`\*       | `a×1`
|            | `a∨1`         | `a∨0`
| `a÷a`\*    | `0÷a`\*       | `a÷1`
|            | `a⋆0`, `1⋆a`  | `a⋆1`
|            | `¯∞⌊a`, `∞⌈a` | `¯∞⌈a`, `∞⌊a`
| `a>a` etc. |               | `a⌊a`, `a⌈a`

None of the constant column entries work for NaNs, except `a⋆0` and `1⋆a` which really are always 1. Starred entries have some values of `a` that result in NaN instead of the expected constant: `0` for division and `∞` for multiplication. This means that constant-result `÷` always requires checking for NaN while the other entries work for integers without a check.

### Division and modulus

Division, integer division, and Modulus by an atom (`a÷n`, `a⌊∘÷n`, `n|a`) are subject to many optimizations.

- Floating-point with FMA: [this page](http://marc-b-reynolds.github.io/math/2019/03/12/FpDiv.html) gives a slightly slower method that works for all divisors and a faster one that can be proven to work on over half of divisors.
- Integer division: see [libdivide](https://github.com/ridiculousfish/libdivide). Most important is a mask for power-of-two `n`. For smaller integer types, using SIMD code with 32-bit floats is also fast: see below.

#### Integer division with floats

If `p` and `q` are integers and `p` is small enough, then the floor division `⌊p÷q` gives an exact result. This isn't always the case for floats: for example `1 ⌊∘÷ (÷9)+1e¯17` rounds up to 9 when an exact floor-divide would round down to 8. It means that `q|p` is exactly `p-q×⌊p÷q`, a faster computation.

In particular, if `p` is a 16-bit or smaller integer and `q` is any integer, then the floor division `⌊p÷q` and modulus `q|p` can be computed exactly in single (32-bit float) precision. If `p` is a 32-bit integer these can be computed exactly in double precision. An additional optimization if `q` is constant is to pre-compute `r←u÷q`, where `u` is slightly larger than 1. Then `⌊p×r` is equal to `⌊p÷q`.

We will prove the case with 32-bit `p` in double precision. If `q` is large, say it has absolute value greater than `2⋆32`, then `(|p÷q)<1`, meaning the correct result is `¯1` if it's negative and `0` otherwise. If `p` is nonzero, then `(|p÷q) > |÷q`, which is greater than the smallest subnormal for any `q`, and so the division won't round up to 0. So suppose `q` is small. If `p` is a multiple of `q`, say `p=k×q`, then `k≤○|p` so `k` is exactly representable as a double and the division is exact. If `p` is not an exact multiple, say `p=(k×q)-o` with nonzero `o<q`, then write it as `k×(q-o÷k)` and the quotient is `k×1-o÷k×q`, or `k×1-o÷p+o`. For this number to round up to `k` it would have to be larger than `k×1-÷2⋆52`, but `p+o` is less than `p+q` which is much less than `2⋆52`, so the rounded division result is less than `k`, giving a floor of `k-1`.

Furthermore, in this case, the division `p÷q` can be performed by a single multiplication—not by `÷q`, which may be too small (49 is the first positive `q` where it fails), but by a value slightly further from 0. Rounding the reciprocal away from 0 works, but in case this isn't possible, using either `u÷q` or `u×÷q` with `u←1+2⋆¯52` is fine. This is true for the large-`q` case because multiplying by `u` won't bring `|÷q` up to `1÷2⋆32`, as can easily be checked with `q←1+2⋆32`. And it's true for the small-`q` case because `p×u×÷q` is at most `(p÷q)×1+2⋆¯51` (being rather generous with the error term to account for any rounding). Now to avoid bad rounding `p÷q` would have to be larger than `k×(1-÷2⋆52)÷1+2⋆¯51`, which is greater than `k×1-÷2⋆50`, and it's still far away from this bound.

## Power and logarithm

The monadic exponential `⋆` and logarithm `⋆⁼` functions are well-known and hopefully have adequate implementations in math libraries. Power and logarithm with an arbitrary base present some additional concerns, as well as optimization opportunities when one argument is fixed.

Researchers associated with Inria [propose](https://hal.science/hal-01227877) a logarithm that takes a 64-bit floating-point argument and returns a fixed-point value, scaled by `2⋆52`. This is a natural choice because the base-2 log of a float fits in [0,1024) by design, and it's much better at maintaining precision at the larger end of that range. The applications in BQN are to compute `b⋆⁼a ←→ (⋆⁼a)÷⋆⁼b` and possibly `b⋆a ←→ ⋆a×⋆⁼b` and `a√b ←→ ⋆(⋆⁼b)÷a` with good precision; these formulas allow precomputing `⋆⁼b` if it's fixed, as is often the case.

### Number of digits

A common problem is to find the number of digits required to represent integer `a` in integer base `b`, `1+⌊b⋆⁼a`. This code is a lot less reliable than repeated division. As we'll see, even a correctly-rounded `⋆⁼` can overestimate the count when `a` is somewhat above `2⋆48`, resulting in a leading 0 if the number is expanded with that many digits. With an imprecise logarithm, such as `a÷○(⋆⁼)b` with correctly-rounded components, we can get a more severe issue: `b⋆⁼b⋆k` for integer `k` can end up below `k` and round down at small values like `⌊10⋆⁼1000`, clipping off the leading digit.

The best fix is to get the error of dyadic log under 1 ULP, which ensures the log of an integer will never round past an integer. However, it's also possible to correct the result of `x÷○(⋆⁼)b` to fix near-integers, when `x` is not large. The idea is this: the case we need to fix is that the true value of `b⋆⁼x` is on one side of an integer `i`, but numeric error puts the computed value `r←e+b⋆⁼x` on the other side (or it should be equal but is computed unequal). In this case the computed value must be within `e` of `i`, `e≥|r-i`. And the true `(b⋆⁼x) - i` must have the same sign as `x - b⋆i`, as `b⋆𝕩` is monotonically increasing; if `r-i` differs then `⌊0.5+r` would be a more accurate result.

    Log ← {b 𝕊 x:
      r ← (⋆⁼x) ÷ ⋆⁼b  # Unadjusted result
      u ← r × 2⋆¯51    # Max error, ≥2 ULP
      D ← {𝕩 - ⌊0.5+𝕩} # Distance from nearest int
      dr ← D r
      r - dr × (u≥|dr) ∧ dr ≠○× D x
    }

The above code corrects `r` if it's within a certain relative error of an integer (with the conservative assumption that `⋆⁼x` has a relative error of at most 0.75 ULP, and `÷` is correctly rounded, we have `(2×0.75)+0.5` or 2 ULP), and the direction (-1, 0, or 1) from that integer is different from the direction to `x` from the nearest integer to it. So it just assumes the nearest integer to `x` is a power of `b`! But testing `dr` ensures this is true for `x` up to a little past `2⋆44`, as we show in the next section. Past this (well, certainly past `2⋆46`) the implementer has to decide between correcting and possibly bringing the error up from 2 ULP to 4 ULP, or not correcting and allowing too-low results from `⌊b⋆⁼a`.

#### Logarithm error analysis

To analyze the distance between adjacent values of `b⋆⁼a` we'll look at ratios like `(b⋆⁼x+1)÷(b⋆⁼x)`, since `b` instantly drops out giving `(⋆⁼x+1)÷(⋆⁼x)`. We can get some bounds on the logarithm `⋆⁼x` using the fact that it's a concave function, meaning it curves downwards from its linear approximation at any point `x`. So the value at `x+k` is at most `⋆⁼x` plus `k` times the derivative `÷x` at `x` (alternatively, start with `(1+y) ≤ ⋆y` and substitute `y ← (⋆⁼x+k)-⋆⁼x ←→ ⋆⁼1+k÷x`). Then we divide each through by `⋆⁼x`:

    (÷x) ≤ (⋆⁼x) - ⋆⁼x-1
    (÷x×⋆⁼x) ≤ 1 - ((⋆⁼x-1) ÷ ⋆⁼x)

    (÷x+1) ≤ (⋆⁼x+1) - ⋆⁼x
    (÷(x+1)×⋆⁼x) ≤ ((⋆⁼x+1) ÷ ⋆⁼x) - 1

So when might `b⋆⁼x` come within `m` ULP of an integer `i`? Setting `u←2⋆¯52` and `xi ← b⋆i`, a ULP is at most `i×u`, and the distance from the true result is at least `i÷(x⌈xi)×⋆⁼x`, giving the following inequality:

    (m×i×u) ≥ i÷(x⌈xi)×⋆⁼x
    m ≥ ÷u×(x⌈xi)×⋆⁼x

First we consider the case `m=0.5` meaning that `i` is the correctly-rounded result. The inequality is very close to exact, and for `x = 1+b⋆i` it correctly predicts the smallest `b⋆i` that causes a problem, `271029746912941⋆1` (so, the long number is `b` such that `b⋆⁼b+1` rounds to exactly 1 instead of larger). When adding one, power-of-two `i` has the smallest error tolerance, but for `x = 1-˜b⋆i`, it's largest instead, and one plus a power of two is smallest; a larger power further decreases the tolerance but makes possible `x` values sparser. With `i≥3` the relevant range is not too hard to search exhaustively, and `41⋆9` is the smallest `b⋆i` such that `b⋆⁼1-˜b⋆i` rounds to `i`. These two values of `x` are about `0.96×2⋆48` and `1.16×2⋆48`, which unfortunately is not all that large.

Next we look at when the 2 ULP threshold for our corrected logarithm can fail. The problem is when `x` differs from `b⋆i` by 0.5 or more, and the computed `b⋆⁼x` comes within 2 ULP of `i`—so, the true `b⋆⁼x` is within 4ULP of `i`. It turns out we're looking for the equivalent of `m=8`, which is guaranteed by `x≤1.04×2⋆44`. We can improve this a bit by replacing the constant bound `dr` in `u≥|dr` with the piecewise linear `dr + (D x) ÷ x⌈⌊0.5+x`, which works to `m=4`, `x≤1.02×2⋆45` (while this linear approximation is also a more accurate correction for `r` below that `x` threshold, it must not be used above it, as this will incorrectly cross integer boundaries). Past `m=2` at `x≤1.00×2⋆46` we are definitely done for, as the log of an integer non-power might result in an integer: we can't distinguish this case from a power of `b` without actually knowing some powers of `b`!

## Table and leading-axis

While they can be viewed as special cases of the nested rank discussed in the next section, Table and leading-axis extension are easier to analyze, and are the most common forms. To avoid some tedium with shapes, we'll consider a result shape `m‿n`, by assuming `𝕨` is a list with length `m`, and `𝕩` is either a list with length `n`, for Table, or a shape `m‿n` array, for leading-axis.

With these definitions, `⥊𝕨𝔽⌜𝕩` is `(n/𝕨) 𝔽 (m×n)⥊𝕩`, which can make use of a fast [constant replicate](replicate.md#constant-replicate). It's better not to compute these expanded arguments in full, and instead choose a unit size `k≤m` so that `k×n` is small but not too small. Then pre-compute `(k×n)⥊𝕩`, and work on `𝕨` in chunks of length `k`. For example, expand each chunk with `k/` into the result, then apply the function in-place with the saved `(k×n)⥊𝕩`. Of course, if the optimal `k` is 1, then a scalar-vector operation into the result works just as well.

Leading-axis extension is similar: `⥊𝕨𝔽𝕩` is `(n/𝕨) 𝔽 ⥊𝕩`, so the same strategy works, with minor modifications. Instead of `(k×n)⥊𝕩`, a new chunk of length `k×n` from `𝕩` is needed at each step. And if `k` is 1, the base case is vector-vector instead of scalar-vector.

Table also admits faster overflow checking for well-behaved functions like `+-¬×`: all combinations of `𝕨` and `𝕩` will be used, so there's an overflow exactly if the extreme values would overflow. The range of `𝕨+⌜𝕩` is `𝕨+○(⌊´)𝕩` to `𝕨+○(⌈´)𝕩`, and similarly for `𝕨-⌜𝕩` but swapping the max and min of `𝕩`. For `𝕨×⌜𝕩` all four combinations of min and max need to be checked.

## Ranked arithmetic

Dyadic arithmetic can be applied to various combinations of axes with leading-axis extension, Table (`⌜`), and the Cells (`˘`) and Rank (`⎉`) modifiers. Cells is of course `⎉¯1`, and Table is `⎉0‿∞`, so the general case is arithmetic applied with the Rank operator any number of times.

An application of Rank is best described in terms of its frame ranks, not cell ranks. If `a` and `b` are these ranks, then there are `a⌊b` shared frame axes and `a(⌈-⌊)b` non-shared axes from the argument with the higher-rank frame. Repeating on rank applications from the outside in, with a final rank 0 inherent in the arithmetic itself, the two sets of argument axes are partitioned into sets of shared and non-shared axes. For example consider `+⌜˘⎉4‿3` on arguments of ranks 6 and 8.

- The `⎉4‿3` implies frame ranks of 6-4=2 and 8-3=5. This gives 2 shared axes (label 0 below), then 3 non-shared axes from `𝕩` (label 1).
- The `˘` takes a shared axis (label 2).
- The `⌜` takes all axes from `𝕨` non-shared (3), then all from `𝕩` (label 4).

      0 1 2 3 4 5 6 7
    𝕨 0 0 2 3 3 3 
    𝕩 0 0 1 1 1 2 4 4

An axis set behaves like a single axis, and any adjacent axis sets of the same type (for example, non-shared from `𝕨`) can be combined. Length-1 axes can be ignored as well, so a simplification pass [like transpose](transpose.md#axis-simplification) might make sense.

Then the implementation needs to expand this mapping quickly. As usual, long axes are easy and short axes are harder. It's best to take enough result axes so that a cell is not too small, then use a slow outer loop (for example, based on index lists) to call that inner loop. One result axis can be split in blocks if the cell size would be too small without it, but too big with it.

Because a result cell should be much larger than a cache line, there's no need for the outer loop to traverse these cells in order—that is, the axes can be moved around to iterate in a transposed order. An easy way to do this is to represent each result axis with a length, stride in the result, and stride in both arguments; axes represented this way can be freely rearranged. It's best to iterate over shared axes first (outermost), then non-shared axes, because a non-shared axis means cells in the other argument are repeated, and if it's placed last then no other cells will be used between those repeated accesses. If both arguments have non-shared axes then a blocked order that keeps the repeated cells in cache might be best, but it's complicated to implement.

### Base cases

The scalar-vector, vector-vector cases work as base cases on one axis, and Table and leading-axis are two two-axis cases. There's also a flipped Table `˜⌜˜` and a trailing-axis case like `⎉1`. Representing each result axis with "w" if it comes from `𝕨` only, "x" for `𝕩` only, and "wx" for shared, we can organize these cases.

- w, x (scalar-vector)
- wx (vector-vector)
- w-x (Table)
- x-w (flipped Table)
- wx-x, wx-w (leading)
- w-wx, x-wx (trailing)

That's six two-axis combinations; the remaining three possibilities w-w, x-x, and wx-wx are simplifiable. Trailing-axis agreement takes half of Table like leading-axis agreement, but it's the reshaping half instead of replicate.

The general case is to expand the arguments with Replicate along various axes so that they have the same shape as the result, and then use vector-vector arithmetic. More concretely, insert a length-1 axis into the argument for each non-shared axis in the other argument. Then replicate these axes to to required length. This can be done one axis at a time from the bottom up, or by constructing an array of indices and applying them at once, and probably other ways as well. See also [high-rank Replicate](replicate.md#higher-ranks).
