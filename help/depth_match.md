*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/depth_match.html).*

# Identical To (`≡`)

## `≡ 𝕩`: Depth
[→full documentation](../doc/depth.md)

Highest level of nesting in `𝕩`.

        ≡ 2‿3‿4

        ≡ ⟨2,<3,4,<<<5⟩

        ≡ 9



## `𝕨 ≡ 𝕩`: Match
[→full documentation](../doc/match.md)

Does `𝕨` exactly match `𝕩`?

        1 ≡ ⟨1⟩

        ⟨1⟩ ≡ ⟨1⟩
