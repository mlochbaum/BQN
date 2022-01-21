*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/namespacefield.html).*

# Full Stop (`.`)

## `ns . name`: Namespace Field

Access a field with name `name` in namespace `ns`. Field must have been exported with `⇐`.

        {a⇐1} . a

        {F⇐-}.F 5
