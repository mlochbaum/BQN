*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/logic.html).*

# Logic functions: And, Or, Not (also Span)

BQN uses the mathematical symbols `∧` for logical *and*, `∨` for *or*, and `¬` for *not*. That is, on booleans the result of `∧` is 1 if both arguments are 1, and `∨` is 1 if any argument is 1. `¬` flips its argument, returning 1 if the argument is 0 and 0 if it's 1. The logic functions are also considered [arithmetic](arithmetic.md) and thus are [pervasive](arithmetic.md#pervasion).

| `𝕨` | `𝕩` | `𝕨∧𝕩` | `𝕨∨𝕩` | `¬𝕩`
|:---:|:---:|:-----:|:-----:|:----:
|  0  |  0  |   0   |   0   |   1
|  0  |  1  |   0   |   1   |   0
|  1  |  0  |   0   |   1   |
|  1  |  1  |   1   |   1   |

The three logic functions are extended linearly to apply to all numbers. This means Not returns `1-𝕩`, and And returns `𝕨×𝕩`. Or does a more complicated computation `𝕨×⌾¬𝕩` or `𝕨(+-×)𝕩`.

Both valences of `¬` can be written as a [fork](train.md) `1+-`. The dyadic one, Span, computes the number of integers in the range from `𝕩` to `𝕨`, inclusive, when both arguments are integers and `𝕩≤𝕨` (the reversed order is used for consistency with subtraction). It often shows up in connection with the [Windows](windows.md) function.

## Examples

And, Or, and Not can often be thought of as connecting logical statements together. So `(n<1) ∨ n>3` tests whether one of the two statements `n<1` or `n>3` holds.

        n ← 4

        (n<1) ⋈ n>3  # One false, one true

        (n<1) ∨ n>3

Of course, what actually happens is that those expressions are evaluated and the primitive acts on the results (both sides are always evaluated: there's nothing like the shortcutting of `&&` in some languages). Functions can be used more flexibly: for example, the [fold](fold.md) `∧´` indicates whether all values in a list are true, while `∨´` indicates if any is true.

        ∧´ 1‿1‿1‿1‿1
        ∧´ 1‿1‿1‿0‿1

And the [scans](scan.md) `` ∧` `` and `` ∨` `` extend this notion to prefixes, switching permanently off at the first 0, or on at the first 1.

        ∧` 1‿1‿0‿0‿1‿0‿1

        ∨` 0‿1‿0‿0‿1‿0‿1

Not (`¬`) isn't complicated: for example `¬a=b` indicates that `a` is *not* equal to `b`. Or `a≠b`, but you can't just put a slash through every symbol. One less obvious use is to convert a boolean to plus or minus 1, using the [hook](hook.md) modifiers. `b-¬b` leaves 1 unchanged but subtracts 1 from 0, while `(¬b)-b` is the negation, converting 0 to 1 and 1 to ¯1.

        -⟜¬ 0‿1

        ¬⊸- 0‿1

### Span

Span isn't a logic function, given that `1¬0` is `2`, not a boolean. It's defined to be `1+𝕨-𝕩` (I like to think of the line hanging off the right side as the 1 to be added). The reason it's called Span is that if the arguments are whole numbers with `𝕩≤𝕨`, this is the length of the sequence `𝕩, 𝕩+1,… 𝕨`.

        4 ¬ 1   # 1, 2, 3, 4

        9 ¬ 7   # 7, 8, 9

The fact that Not and Span share a glyph is no coincidence. `¬𝕩` is `0¬𝕩`, because this is equal to `1-𝕩` and `1-0‿1` is `1‿0`. And because `¬𝕩` is defined to be `1-𝕩` not just for booleans but for all numbers, it's also true that `𝕨¬𝕩` is `𝕨+¬𝕩`.

        5 + ¬ 0‿1‿1

        5 ¬ 0‿1‿1

The identities `¬𝕩 ←→ 0¬𝕩` and `𝕨¬𝕩 ←→ 𝕨+¬𝕩` are also true with `-` in place of `¬`! That's because `¬` is `{1+𝕨-𝕩}`, or `1+-`, in either case. Changing between `-` and `¬` only adds or subtracts 1 from both sides of the identities.

## Definitions

The three logic functions can be defined easily in terms of other arithmetic. They're convenience functions in that sense.

    Not ← 1+-  # also Span
    And ← ×
    Or  ← ×⌾¬

using a [train](train.md) for Not and [Under](under.md) for Or. The latter expands to `Or ← ¬∘×○¬`, since Not is a self-inverse `¬⁼ ←→ ¬`: when applying `¬` twice, the first added 1 will be negated but the second won't; the two 1s cancel leaving two subtractions, and `-⁼ ←→ -`. An alternate definition of Or that matches the typical formula from probability theory is

    Or  ← +-×

Building these definitions from arithmetic components makes it look like they should apply to any numbers, not just booleans. Well, they do.

## Extension

The logic functions are extended to all numbers by making them linear in every argument. In the case of Not, that means the linear function `1⊸-`. The two-argument functions have bilinear extensions: And is identical to Times (`×`), while Or is `×⌾¬`, following De Morgan's laws (other ways of obtaining a function for Or give an equivalent result—there is only one bilinear extension).

Here are truth [tables](map.md#table) of these extensions including the non-integer value one-half:

        ¬ 0‿0.5‿1

        ∧⌜˜ 0‿0.5‿1

        ∨⌜˜ 0‿0.5‿1

As in logic, any value And 0 is 0, while any value Or 1 is 1. The other boolean values give the identity values for the two functions: 1 and any value gives that value, as does 0 or the value.

If the arguments are probabilities of independent events, then an extended function gives the probability of the boolean function on their outcomes. For example, if *A* occurs with probability `a` and *B* with probability `b` independent of *A*, then at least one of *A* or *B* occurs with probability `a∨b`. These extensions have also been used in complexity theory, because they allow mathematicians to transfer a logical circuit from the discrete to the continuous domain in order to use calculus on it.

### Identity values

The [folds](fold.md) `∧´` or `∨´` ought to work on empty lists, so And and Or should have the expected [identity](fold.md#identity-values) values 1 (an empty list *is* all 1s) and 0 (and yet has no 1s). [Minimum and Maximum](arithmetic.md#additional-arithmetic) do match And and Or when restricted to booleans, but they have different identity values. It would be dangerous to use Maximum to check whether any element of a list is true because `⌈´⟨⟩` yields `¯∞` instead of `0`—a bug waiting to happen. To avoid this you'd have to always use an initial value `𝕨` of `0`, which is easy to forget.

It's not hard to prove that the bilinear extensions have these identity values. Of course `1∧x` is `1×x`, or `x`, and `0∨x` is `0×⌾¬x`, or `¬1×¬x`, giving `¬¬x` or `x` again. Both functions are commutative, so these values are identities on the right as well.

Some other logical identities don't always hold. For example, in boolean logic And distributes over Or and vice-versa: `a∧b∨c ←→ (a∧b)∨(a∧c)`. But substituting `×` for `∧` and `+-×` for `∨` we find that the left hand side is `(a×b)+(a×c)+(a×b×c)` while the right gives `(a×b)+(a×c)+(a×b×a×c)`. These are equivalent for arbitrary `b` and `c` only if `a=a×a`, that is, `a` is 0 or 1. In terms of probabilities the difference when `a` is not boolean is caused by failure of independence. On the left hand side, the two arguments of every logical function are independent. On the right hand side, each pair of arguments to `∧` are independent, but the two arguments to `∨`, `a∧b` and `a∧c`, are not. The relationship between these arguments means that logical equivalences no longer apply.

### Why not GCD and LCM?

APL provides [GCD](https://aplwiki.com/wiki/GCD) and [LCM](https://aplwiki.com/wiki/LCM) as extensions of And and Or, while BQN doesn't make these functions primitives. The main reason for omitting them functions is that they are complicated and, when applied to real or complex numbers, require a significant number of design decisions where there's no obvious choice (for example, whether to use comparison tolerance). On the other hand, these functions are fairly easy to implement, which allows the programmer to control the details, and also add functionality such as the extended GCD. Possible implementations for GCD and LCM are shown in [bqncrate](https://mlochbaum.github.io/bqncrate) ([GCD](https://mlochbaum.github.io/bqncrate/?q=gcd), [LCM](https://mlochbaum.github.io/bqncrate/?q=lcm)), and `•math.GCD` and `•math.LCM` are also supported.

A secondary reason is that the GCD falls short as an extension of Or, because its identity value 0 is not total. `0∨x`, for a real number `x`, is actually equal to `|x` and not `x`: for example, `0∨¯2` is `2` in APL. This means the identity `0∨x ←→ x` isn't reliable in APL.

Unrelatedly, the reason BQN discards APL's `~` for negation is that it looks like `˜`, and is less common in mathematics today.
