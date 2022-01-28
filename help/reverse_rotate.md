*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/reverse_rotate.html).*

# Circle Stile (`⌽`)

## `⌽ 𝕩`: Reverse
[→full documentation](../doc/reverse.md)

Reverse `𝕩` along the first axis.

        ⌽ 1‿2‿3

        a ← 3‿3 ⥊ ↕9

        ⌽ a



## `𝕨 ⌽ 𝕩`: Rotate
[→full documentation](../doc/reverse.md#rotate)

Move the first `𝕨` elements of `𝕩` to its end. Negative `𝕨` reverses the direction of rotation.

        2 ⌽ 1‿2‿3

        b ← 3‿3 ⥊ ↕9

        2 ⌽ b
