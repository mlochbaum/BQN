*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/conjugate_add.html).*

# Plus (`+`)

## `+ 𝕩`: Conjugate
[→full documentation](../doc/arithmetic.md#basic-arithmetic)

Complex conjugate of `𝕩`. BQN doesn't support complex numbers yet, so it has no effect.

        + 1

        + ¯1


## `𝕨 + 𝕩`: Add
[→full documentation](../doc/arithmetic.md#basic-arithmetic)

`𝕨` added to `𝕩`. Either `𝕨` or `𝕩` can be a character, and if so, the other has to be an integer.

[Pervasive.](../doc/arithmetic.md#pervasion)

        1 + 2

        1 + 2‿3‿4

        'a' + 4
