*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/´fold.html).*

# Acute Accent (`´`)

`𝔽´ 𝕩`: Fold

Fold over `𝕩` with `𝔽` from right to left i.e. Insert `𝔽` between the elements of `𝕩`.

       +´ 1‿2‿3
    6
       1+2+3
    6
       -´ 1‿2‿3
    2
       1-2-3
    2

`𝕨 𝔽´ 𝕩`: Fold With initial

Monadic fold, but use `𝕨` as initial right argument.

       5 +´ 1‿2‿3
    11
       1+2+3+5
    11
       5 -´ 1‿2‿3
    ¯3
       1-2-3-5
    ¯3

