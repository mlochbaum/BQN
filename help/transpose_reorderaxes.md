*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/transpose_reorderaxes.html).*

# Circle Backslash (`⍉`)

## `⍉ 𝕩`: Transpose
[→full documentation](../doc/transpose.md)

Move the first axis of `𝕩` to the end.

        a ← 3‿3 ⥊ ↕9

        ⍉ a

        b ← 1‿2‿3 ⥊ ↕6

        ≢⍉ b



## `𝕨 ⍉ 𝕩`: Reorder Axes
[→full documentation](../doc/transpose.md)

Rearrange the axes of `𝕩` as per the axis indices in `𝕨`.

        ≢ c ← 2‿3‿4‿5‿6 ⥊1

        ≢ 1‿3‿2‿0‿4 ⍉ c
