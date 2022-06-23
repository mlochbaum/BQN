*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/beginarray.html).*

# Left Square Bracket (`[`)

## `[ ...`: Begin array
[→full documentation](../doc/arrayrepr.md#high-rank-arrays)

Starts a high-rank array. Entries must be separated by `,` or `⋄`. These must have the same shape. They become major cells of the result.

Must end with a corresponding `]`.

        ["abc", "def"]

        [↕4, ↕5]
