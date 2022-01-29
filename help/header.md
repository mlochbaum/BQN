*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/header.html).*

# Colon (`:`)

## `:`: Header
[→full documentation](../doc/block.md#block-headers)

Placed at the end of a block header. A header has syntax that matches the way the block is called. It indicates the block type, and number and structure of inputs.

        "xy" {a‿b _op c: b} ∞

Multiple bodies are searched in order to find one with a matching header.

        F ← {m Fn n: m+Fn n;  𝕊n: 2×n;  𝕊⁼𝕩: 𝕩÷2}

        F 3      # 𝕊n

        F⁼ 6     # 𝕊⁼𝕩

        10 F 3   # m Fn n
