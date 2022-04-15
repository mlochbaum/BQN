*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/valences.html).*

# Valences

<!--GEN combinator.bqn
DrawComp ≍"⊘"
-->

Every BQN function can be called with one or two arguments, possibly doing completely different things in each case. The Valences (`⊘`) 2-modifier grafts together a one-argument function `𝔽` and a two-argument function `𝔾`, with the resulting function calling one or the other as appropriate. It's the [tacit](tacit.md) equivalent of a block function with [two bodies](block.md#multiple-bodies). So the function `{÷𝕩 ; 𝕩-𝕨}` can also be written `÷⊘(-˜)`. A full definition of Valences as a block is `{𝔽𝕩;𝕨𝔾𝕩}`.

          -⊘+ 6  # - side

        3 -⊘+ 2  # + side

Valences provides one way to check whether `𝕨` is present in a block function. The expression `𝕨0⊘1𝕩` always ignores the values of the arguments, resulting in `0` if `𝕨` isn't given and `1` if it is (if you want `1` or `2`, then `≠𝕨⋈𝕩` is shorter, but I'm not sure if I like it).

            {𝕨0⊘1𝕩} 'x'

        'w' {𝕨0⊘1𝕩} 'x'
