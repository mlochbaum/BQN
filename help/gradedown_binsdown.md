*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/gradedown_binsdown.html).*

# Del Stile (`⍒`)

## `⍒ 𝕩`: Grade Down

Indices of `𝕩` that would sort its major cells in descending order.

           a ← 1‿2‿3

           ⍒ a

           (⍒a) ⊏ a



## `𝕨 ⍒ 𝕩`: Bins Down

Binary search for each element of `𝕩` in `𝕨`, and return the index found, if any.

`𝕨` must be sorted in descending order.

[Right Pervasive.](../doc/arithmetic.md#pervasion)

           7‿5‿4‿3 ⍒ 2

           7‿5‿4‿3 ⍒ 2‿6
