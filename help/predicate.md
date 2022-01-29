*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/predicate.html).*

# Question Mark (`?`)

## `?`: Predicate
[→full documentation](../doc/block.md#predicates)

Follows a statement in a block, which must return 0 or 1. If it's 0, stop the current body and evaluate the next eligible one instead. Variables defined before the `?` stay if execution continues (1) but don't carry over to other bodies (0).

        {0 ? 3 ; 4}

        Min ← {𝕨<𝕩 ? 𝕨 ; 𝕩}

        3 Min 5

        4 Min 2
