*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/markfirst_memberof.html).*

# Element Of (`∊`)

## `∊ 𝕩`: Mark Firsts
[→full documentation](../doc/selfcmp.md#mark-firsts)

Mark the first occurrence of each major cell in `𝕩` with a 1, and all other occurrences with a 0.

        ∊ 4‿5‿6‿6‿4‿7‿5

        a ← 3‿3 ⥊ ↕9

        ∊ a



## `𝕨 ∊ 𝕩`: Member Of
[→full documentation](../doc/search.md#member-of)

Is each cell in `𝕨` a major cell of `𝕩`?

        ⟨1⟩ ∊ ↕9

        b ← 3‿3 ⥊ ↕9

        ⟨0‿1‿2⟩ ∊ b

        ⟨1‿3 ⥊ 0‿1‿2⟩ ∊ b
