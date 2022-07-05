*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/find.html).*

# Find

Find (`⍷`) searches for occurrences of an array `𝕨` within `𝕩`. The result contains a boolean for each possible location, which is 1 if `𝕨` was found there and 0 if not.

        "xx" ⍷ "xxbdxxxcx"

More precisely, `𝕨` needs to [match](match.md) a contiguous selection from `𝕩`, which for strings means a substring. These subarrays of `𝕩` are also exactly the cells in the result of [Windows](windows.md). So we can use Windows to see all the arrays `𝕨` will be compared against.

        2 ↕ "xxbdxxxcx"

        "xx"⊸≡˘ 2 ↕ "xxbdxxxcx"

Like Windows, the result usually doesn't have the same dimensions as `𝕩`. This is easier to see when `𝕨` is longer. It differs from APL's version, which includes trailing 0s in order to maintain the same length. Bringing the size up to that of `𝕩` is easy enough with [Take](take.md) (`↑`), while shortening a padded result would be harder.

        "string" ⍷ "substring"

        "string" (≢∘⊢↑⍷) "substring"  # APL style

If `𝕨` is larger than `𝕩`, the result is empty, and there's no error even in cases where Windows would fail. One place this tends to come up is when applying [First](pick.md#first) (`⊑`) to the result: `⊑⍷` tests whether `𝕨` appears in `𝕩` at the first position, that is, whether it's a prefix of `𝕩`. If `𝕨` is longer than `𝕩` it shouldn't be a prefix. First will fail but using a [fold](fold.md) `0⊣´⍷` instead gives a 0 in this case.

        "loooooong" ⍷ "short"

        9 ↕ "short"

        0 ⊣´ "loooooong" ⍷ "short"

Adding a [Deshape](reshape.md#deshape) gives `0⊣´⥊∘⍷`, which works with the high-rank case discussed below. It tests whether `𝕨` is a multi-dimensional prefix starting at the lowest-index corner of `𝕩`.

### Higher ranks

If `𝕨` and `𝕩` are two-dimensional then Find does a two-dimensional search. The cells used are also found in `𝕨≢⊸↕𝕩`. For example, the bottom-right corner of `𝕩` below matches `𝕨`, so there's a 1 in the bottom-right corner of the result.

        ⊢ a ← 7 (4|⋆˜)⌜○↕ 9   # Array with patterns

        (0‿3‿0≍0‿1‿0) ⍷ a

It's also allowed for `𝕨` to have a smaller rank than `𝕩`; the axes of `𝕨` then correspond to trailing axes of `𝕩`, so that leading axes of `𝕩` are mapped over. This is a minor violation of the [leading axis](leading.md) principle, which would match axes of `𝕨` to leading axes of `𝕩` in order to make a function that's useful with the Rank operator, but such a function would be quite strange and hardly ever useful.

        0‿1‿0‿1 ⍷ a
