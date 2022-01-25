*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/after_bind.html).*

# Left Multimap (`⟜`)

## `𝔽⟜𝕘 𝕩`: Bind

Supply `𝕘` as a right argument to `𝔽` (`𝕩 𝔽 𝕘`).

`𝕘` is a constant, `𝔽` must be dyadic.

        -⟜3 9

        - 3 9

        9 - 3



## `𝔽⟜𝔾 𝕩`: After

Apply `𝔾` to `𝕩`, and supply it as a right argument to `𝔽` (`𝕩 𝔽 (𝔾 𝕩)`).

`𝔽` must be dyadic, `𝔾` must be monadic.

        ×⟜- 9

        × - 9

        9 × (- 9)



## `𝕨 𝔽⟜𝔾 𝕩`: Dyadic After

Apply `𝔾` to `𝕩`, and supply it as a right argument to `𝔽` (`𝕨 𝔽 (𝔾 𝕩)`).

`𝔽` must be dyadic, `𝔾` must be monadic.

        2 ×⟜- 1

        2 × (- 1)
