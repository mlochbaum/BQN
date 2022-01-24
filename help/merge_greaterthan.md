*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/merge_greaterthan.html).*

# Greater Than (`>`)

## `> 𝕩`: Merge

Add the rank of an element of `𝕩` to the rank of `𝕩`.

All elements must have the same rank.

Returns atomic values as is.


          a ← ⟨⟨1, 2⟩, ⟨3, 4⟩⟩

          >a

          ≢a

          ≢>a




## `𝕨 > 𝕩`: Greater Than

`𝕨` and `𝕩` can both be either numbers or characters.

[Pervasive.](../doc/arithmetic.md#pervasion)

          1 > 3

          2‿3‿0 > 3‿1‿0

          'a' > 'b'
