*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/nothing.html).*

# Middle Dot (`·`)

## `·`: Nothing

### In Trains

Nothing can serve as a left argument in a train to string together multiple monadic functions.

        (-+-) 5

        (-·+-) 5

### In Block Headers

For Block header pattern matching syntax, Nothing can be used to indicate an unused value.

        F ← {𝕊 a‿·‿b: a∾b}

        F 1‿2‿3
