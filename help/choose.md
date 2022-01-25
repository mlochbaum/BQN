*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/choose.html).*

# Circle with Lower Right Quadrant (`◶`)

## `𝔽◶𝕘 𝕩`, `𝕨 𝔽◶𝕘 𝕩`: Choose

Apply `𝔽` to the arguments and use the result to [pick](first_pick.md#𝕨--𝕩-pick) (`⊑`) a function from list `𝕘`. Apply the picked function to the arguments.

        F ← ⊢◶+‿-‿÷‿×

        F 0

        F 1

        F 2

        F 3
