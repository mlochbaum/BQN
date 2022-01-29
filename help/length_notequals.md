*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/length_notequals.html).*

# Not Equal (`≠`)

## `≠ 𝕩`: Length
[→full documentation](../doc/shape.md)

Length of the first dimension of `𝕩`.


        ≠ 3

        ≠ ⟨1, 2, 3⟩

        ≠ 3‿4‿5⥊0

        ≠ 1‿4‿5⥊0

        ≠ 4‿4‿5⥊0



## `𝕨 ≠ 𝕩`: Not Equal To
[→full documentation](../doc/arithmetic.md#comparisons)

Do argument atoms not match?

[Pervasive.](../doc/arithmetic.md#pervasion)

        1 ≠ 3

        2‿3‿0 ≠ 3‿1‿0

        'a' ≠ 'a'
