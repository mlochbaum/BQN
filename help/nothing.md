*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/nothing.html).*

# Middle Dot (`·`)

## `·`: Nothing
[→full documentation](../doc/expression.md#nothing)

Indicates no value. If a left argument is Nothing, the function is called with no left argument, and if the right is Nothing, it's not called and "returns" Nothing.

        · ⌽ "abc"  # Reverse instead of Rotate

### In Trains

Nothing can serve as a left argument in a train to string together multiple monadic functions.

        (-+-) 5

        (-·+-) 5

### Destructuring
[→full documentation](../doc/expression.md#destructuring)

For pattern matching in assignment or a block header, Nothing indicates an unused value.

        F ← {𝕊 a‿·‿b: a∾b}

        F 1‿2‿3
