*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/beginblock.html).*

# Left Curly Bracket (`{`)

## `{ ...`: Begin Block
[→full documentation](../doc/syntax.md#blocks)

Starts a block, which can be one of:

- Function
- 1-Modifier
- 2-Modifier
- Namespace
- Immediate Block

Must end with a corresponding `}`.

        {𝕨 + 𝕩}   # Function

        {𝕨‿𝔽‿𝕩}   # 1-modifier

        {𝕨‿𝔽‿𝔾‿𝕩} # 2-modifier

        {a ⇐ 5}   # Namespace

        {5+4+6}   # Immediate block
