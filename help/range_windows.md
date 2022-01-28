*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/range_windows.html).*

# Up Down Arrow (`↕`)

## `↕ 𝕩`: Range
[→full documentation](../doc/range.md)

Return all indices that would index into an array of shape `𝕩`.

When given a single number, range from `0` to `𝕩-1`.

        ↕ 4

        ↕ 4‿5



## `𝕨 ↕ 𝕩`: Windows
[→full documentation](../doc/windows.md)

Overlapping slices from `𝕩` of shape `𝕨`.

        5 ↕ "abcdefg"

        a ← 3‿3⥊↕9

        2‿2 ↕ a
