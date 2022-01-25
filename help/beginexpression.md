*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/beginexpression.html).*

# Left Parenthesis (`(`)

## `( ...`: Begin Expression

Starts an expression, and only one expression. Must end with a corresponding `)`.

`(` supercedes any precedence order, so that an expression in `()` is evaluated fully before it can be used in the outer context.

        1 + 2 - 3

        (1 + 2) - 3
