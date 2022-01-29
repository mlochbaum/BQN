*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/rank_equals.html).*

# Equal (`=`)

## `= 𝕩`: Rank
[→full documentation](../doc/shape.md)

Returns the number of dimensions in `𝕩`.


        = 0

        = 3⥊0

        = 3‿3⥊0

        3‿3‿3 ⥊ ⟨⟨0⟩⟩



## `𝕨 = 𝕩`: Equal To
[→full documentation](../doc/arithmetic.md#comparisons)

Do argument atoms match?

[Pervasive.](../doc/arithmetic.md#pervasion)

        1 = 3

        2‿3‿0 = 3‿1‿0

        'a' = 'a'
