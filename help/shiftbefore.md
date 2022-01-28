*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/shiftbefore.html).*

# Left Pointing Double Angle Quotation (`«`)

## `« 𝕩`: Shift Before
[→full documentation](../doc/shift.md)

Remove the first element of `𝕩`,  add a cell of fill values to the end of the first axis of `𝕩`.

        78 « 1‿2‿3

        « 1‿2‿3

        « 3‿3 ⥊ 9



## `𝕨 « 𝕩`: Shift Before
[→full documentation](../doc/shift.md)

Remove the first `≠𝕨` (length) major cells from `𝕩`, join `𝕨` to the end of `𝕩`. Ranks must match.

        8‿5 « 1‿2‿3

        a ← 3‿3 ⥊ 9

        1‿2‿3 « a
