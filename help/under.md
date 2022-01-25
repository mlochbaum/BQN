*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/under.html).*

# Circle Jot (`⌾`)

## `𝔽⌾𝔾 𝕩`, `𝕨 𝔽⌾𝔾 𝕩`: Under

- Apply transformation `𝔾` to all arguments
- Apply `𝔽` to the transformed arguments
- Undo transformation `𝔾`

Where `𝔾` must be

- A function invertible by `⁼` (Undo)
- A structural modification

        9⌾(1⊸⊑) 1‿2‿3

        √⁼ (√1) + (√9)

        1 +⌾√ 9
