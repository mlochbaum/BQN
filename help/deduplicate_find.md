*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/deduplicate_find.html).*

# Epsilon Underbar (`⍷`)

## `⍷ 𝕩`: Deduplicate
[→full documentation](../doc/selfcmp.md#deduplicate)

Unique major cells of `𝕩`.

        ⍷ 4‿5‿6‿6‿4‿7‿5

        a ← 3‿3 ⥊ ↕6

        ⍷ a



## `𝕨 ⍷ 𝕩`: Find
[→full documentation](../doc/find.md)

Mark the top left location of the occurrences of `𝕨` in `𝕩` with a 1, and other locations with 0.

Result is the same shape as `(≢𝕨)↕x`.

        "string" ⍷ "substring"

        "loooooong" ⍷ "short"

        b ← 7 (4|⋆˜)⌜○↕ 9

        c ← (0‿3‿0≍0‿1‿0)

        c ⍷ b
