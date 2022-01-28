*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/fold.html).*

# Acute Accent (`´`)

## `𝔽´ 𝕩`: Fold
[→full documentation](../doc/fold.md)

Fold over `𝕩` with `𝔽` from right to left i.e. Insert `𝔽` between the elements of `𝕩`.

`𝕩` must be a simple list (`1 = =𝕩`).

        +´ 1‿2‿3

        1+2+3

        -´ 1‿2‿3

        1-2-3


## `𝕨 𝔽´ 𝕩`: Fold With Initial
[→full documentation](../doc/fold.md#initial-element)

Monadic fold, but use `𝕨` as initial right argument.

        5 +´ 1‿2‿3

        1+2+3+5

        5 -´ 1‿2‿3

        1-2-3-5
