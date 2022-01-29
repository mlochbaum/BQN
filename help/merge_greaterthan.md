*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/merge_greaterthan.html).*

# Greater Than (`>`)

## `> 𝕩`: Merge
[→full documentation](../doc/couple.md)

Combine an array of arrays into one array. All elements of `𝕩` must have the same rank, and the result rank is that plus the rank of `𝕩`.

Returns and boxed atoms unchanged.


        a ← ⟨⟨1, 2⟩, ⟨3, 4⟩⟩

        >a

        ≢a

        ≢>a




## `𝕨 > 𝕩`: Greater Than
[→full documentation](../doc/arithmetic.md#comparisons)

`𝕨` and `𝕩` can both be either numbers or characters.

[Pervasive.](../doc/arithmetic.md#pervasion)

        1 > 3

        2‿3‿0 > 3‿1‿0

        'a' > 'b'
