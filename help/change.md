*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/change.html).*

# Leftwards Arrow With Hook (`↩`)

## `n ↩ v`: Change
[→full documentation](../doc/expression.md#assignment)

Changes the value of variable with name `n` to value `v`.

Variable `n` must already exist.

        a ↩ 1

        ⊢ b ← 3

        ⊢ b ↩ "Be the change you wish to see in the world."

## `n F↩`: Modify
[→full documentation](../doc/expression.md#assignment)

Apply function `F` to existing variable `n`, and assign the result back to `n`.

        ⊢ b ⌽↩

## `n F↩ v`: Modify
[→full documentation](../doc/expression.md#assignment)

Assign `n F v` to `n`.

        ⊢ b ↓˜↩ 6
