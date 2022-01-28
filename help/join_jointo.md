*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/join_jointo.html).*

# Lazy S (`∾`)

## `∾ 𝕩`: Join
[→full documentation](../doc/join.md)

Join all elements of `𝕩` together.

Element ranks must be compatible.

        ∾ ⟨1‿2, 3, 4‿5⟩

        m ← (3‿1≍⌜4‿2‿5) ⥊¨ 2‿3⥊↕6

        ∾ m



## `𝕨 ∾ 𝕩`: Join To
[→full documentation](../doc/join.md)

Join `𝕨` to `𝕩` along the first axis.

        "abcd" ∾ "EFG"

        a ← 3‿3 ⥊ ↕9

        c ← 4‿3 ⥊ ↕12

        a∾c
