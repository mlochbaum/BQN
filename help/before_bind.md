*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/before_bind.html).*

# Multimap (`⊸`)

## `𝕗⊸𝔾 𝕩`: Bind Left

Supply `𝕗` as a left argument to `𝔾` (`𝕗 𝔾 𝕩`).

`𝕗` is a constant, `𝔾` must be dyadic.

        3⊸- 9

        3 - 9



## `𝔽⊸𝔾 𝕩`: Before

Apply `𝔽` to `𝕩`, and supply it as a left argument to `𝔾` (`(𝔽 𝕩) 𝔾 𝕩`).

`𝔽` must be monadic, `𝔾` must be dyadic.

        -⊸+ 9

        - + 9

        (- 9) + 9



## `𝕨 𝔽⊸𝔾 𝕩`: Dyadic Before

Apply `𝔽` to `𝕨`, and supply it as a left argument to `𝔾` (`(𝔽 𝕨) 𝔾 𝕩`).

`𝔽` must be monadic, `𝔾` must be dyadic.

        2 -⊸+ 1

        2 - + 1

        (- 2) + 1
