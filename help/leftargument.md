*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/leftargument.html).*

# Mathematical Double-struck W (`𝕨`)

## `𝕨`: Left Argument
[→full documentation](../doc/syntax.md#blocks)

A variable assigned to the left argument of a block. `𝕎` can be used to access the left argument as a function.

        5 {𝕨} 1

        -‿÷ {𝕎𝕩}¨ 4

In a call with no left argument, `𝕨` functions as [Nothing](nothing.md) and `𝕎` can't be used.

        {(-𝕨)⋈𝕩} 6

        2 {(-𝕨)⋈𝕩} 6
