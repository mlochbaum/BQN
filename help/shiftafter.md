*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/shiftafter.html).*

# Right Pointing Double Angle Quotation (`»`)

## `» 𝕩`: Shift After
[→full documentation](../doc/shift.md)

Remove the last element of `𝕩`, add a cell of fill values to the start of the first axis of `𝕩`.

        » 1‿2‿3

        » 3‿3 ⥊ 9



## `𝕨 » 𝕩`: Shift After
[→full documentation](../doc/shift.md)

Remove the last `≠𝕨` (length) major cells from `𝕩`, join `𝕨` to the start of `𝕩`. Ranks must match.

        78 » 1‿2‿3

        1‿2 » 1‿2‿3

        a ← 3‿3 ⥊ 9

        1‿2‿3 » a
