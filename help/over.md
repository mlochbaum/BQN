*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/over.html).*

# Circle (`○`)

## `𝔽○𝔾 𝕩`: Atop

Apply `𝔾` to `𝕩`, then apply `𝔽` (`𝔽 𝔾 𝕩`).

`𝔽` and `𝔾` must be monadic.

        -○- 5

        - - 5



## `𝕨 𝔽○𝔾 𝕩`: Over

Apply `𝔾` to `𝕨` and `𝕩`, then apply `𝔽` to them (`(𝔾 𝕨) 𝔽 (𝔾 𝕩)`).

`𝔽` must be dyadic, `𝔾` must be monadic.

        1 +○- 2

        1 + - 2

        (- 1) + (- 2)
