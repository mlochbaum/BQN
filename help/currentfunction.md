*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/currentfunction.html).*

# Mathematical Double-struck S (`𝕊`)

## `𝕊`: Current Function
[→full documentation](../doc/syntax.md#blocks)

A variable assigned to the current function block. `𝕤` accesses the same value but has a subject role.

`𝕊` can be used for recursion.

        F ← {𝕊 0: 1; 𝕩 × 𝕊 𝕩-1} # Factorial
        F 5

        {𝕤‿𝕤}4
