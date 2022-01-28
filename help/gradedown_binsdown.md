*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/gradedown_binsdown.html).*

# Del Stile (`⍒`)

## `⍒ 𝕩`: Grade Down
[→full documentation](../doc/order.md#grade)

Indices of `𝕩` that would sort its major cells in descending order.

        a ← 1‿2‿3

        ⍒ a

        (⍒a) ⊏ a



## `𝕨 ⍒ 𝕩`: Bins Down
[→full documentation](../doc/order.md#bins)

Binary search for each cell of `𝕩` in `𝕨`, returning the number of major cells in `𝕨` greater than or equal to that cell.

`𝕨` must be sorted in descending order.

[Right Pervasive.](../doc/arithmetic.md#pervasion)

        7‿5‿4‿3 ⍒ 2

        7‿5‿4‿3 ⍒ 2‿6
