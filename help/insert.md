*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/insert.html).*

# Double Acute Accent (`˝`)

## `𝔽˝ 𝕩`: Insert
[→full documentation](../doc/fold.md)

Fold over cells of `𝕩` with `𝔽` from end to start, that is, insert `𝔽` between the major cells of `𝕩`.

        a ← 3‿3 ⥊ ↕9

        +˝ a

        0‿1‿2 + 3‿4‿5 + 6‿7‿8


## `𝕨 𝔽˝ 𝕩`: Insert With Initial
[→full documentation](../doc/fold.md#initial-element)

Monadic insert, but use `𝕨` as initial right argument.

If

        b ← 3‿3 ⥊ ↕9

        1‿1‿1 +˝ b

        1 +˝ b

        0‿1‿2 + 3‿4‿5 + 6‿7‿8 + 1‿1‿1
