*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/beginexpression.html).*

# Left Parenthesis (`(`)

## `( ...`: Begin Expression

Starts an expression, and only one expression. Must end with a corresponding `)`.

`(` gives higher precedence to the expression in it, and BQN will evaluate expressions in `()` first.

        1 + 2 - 3

        (1 + 2) - 3
