*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/prefixes_take.html).*

# Up Arrow (`↑`)

## `↑ 𝕩`: Prefixes
[→full documentation](../doc/prefixes.md)

Prefixes of array `𝕩` along its first axis.

        ↑ 1‿2‿3‿4

        a ← 3‿3 ⥊ ↕9

        ↑ a



## `𝕨 ↑ 𝕩`: Take
[→full documentation](../doc/take.md)

For each integer in `𝕨`, take that many elements from each dimension of `𝕩`.

Negative numbers take from the end.

If any of the elements in `𝕨` are greater than the length of their respective dimension, the dimension is extended with a fill value.

        3 ↑ 1‿3‿5‿67

        b ← 4‿4 ⥊ ↕16

        3‿3 ↑ b

        5‿5 ↑ b

        3‿¯3 ↑ b
