*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/depth.html).*

# Circle With Two Dots (`⚇`)

## `𝔽⚇𝕘 𝕩`, `𝕨 𝔽⚇𝕘 𝕩`: Depth
[→full documentation](../doc/depth.md#the-depth-modifier)

Apply `𝔽` to the cells of the arguments at depth given in `𝕘`. Negative numbers count down from the top level and non-negative ones from the bottom up.


        1⊸↓⚇1 ⟨⟨1,2,3⟩, ⟨4,5,6⟩⟩

        1 ↓⚇1 ⟨⟨1,2,3⟩, ⟨4,5,6⟩⟩

        (+´↕)⚇0 ⟨2,4‿7,3⟩  # Implements pervasion
