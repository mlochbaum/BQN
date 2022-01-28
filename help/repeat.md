*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/repeat.html).*

# Circle Star (`⍟`)

## `𝔽⍟𝔾 𝕩`, `𝕨 𝔽⍟𝔾 𝕩`: Repeat
[→full documentation](../doc/repeat.md)

Apply `𝔾` to `𝕨` and `𝕩`, then apply `𝔽` to `𝕩` that may times. If `𝕨` is given, use it each time as a constant left argument.

If `𝔾` returns an array, give `𝔽⍟𝕩` for each of its elements.

        1 +⍟⊢ 4

        1 +⍟1‿2‿3 4

        3 ∾⍟{≠𝕩} ⟨4,5,6⟩
