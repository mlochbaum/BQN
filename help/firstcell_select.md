*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/firstcell_select.html).*

# Square Image Of (`⊏`)

## `⊏ 𝕩`: First Cell
[→full documentation](../doc/select.md#first-cell)

First major cell of `𝕩`.

        ⊏ ⟨1, 2, 3⟩

        a ← 3‿3 ⥊ ↕9

        ⊏ a



## `𝕨 ⊏ 𝕩`: Select
[→full documentation](../doc/select.md)

Select the major cells of `𝕩` at the indices in `𝕨`.

        2‿0 ⊏ ⟨1, 2, 3⟩

        b ← 3‿3 ⥊ ↕9

        2‿0 ⊏ b
