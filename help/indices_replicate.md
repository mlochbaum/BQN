*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/indices_replicate.html).*

# Solidus (`/`)

## `/ 𝕩`: Indices
[→full documentation](../doc/replicate.md#indices)

Repeat the index of each element in `𝕩` by the element's value. `𝕩` must be rank 1.

        / 1‿2‿3

        / 1‿0‿1



## `𝕨 / 𝕩`: Replicate
[→full documentation](../doc/replicate.md)

Repeat each major cell in `𝕩` by the corresponding element in `𝕨`.

Unit `𝕨` applies to all elements.

        3 / "copy"

        1‿0‿1 / 1‿2‿3
