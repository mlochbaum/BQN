*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/solo_couple.html).*

# Tape (`≍`)

## `≍ 𝕩`: Solo
[→full documentation](../doc/couple.md)

Add a dimension to `𝕩`.

        ≍ 1


        ≍≍ 1


        ≍≍≍ 1


        ≍≍ 1‿2‿3‿4


        ≍≍≍ 1‿2‿3‿4



## `𝕨 ≍ 𝕩`: Couple
[→full documentation](../doc/couple.md)

Join `𝕨` and `𝕩` along a newly created axis.

        1 ≍ 3

        1‿2 ≍ 2‿3
