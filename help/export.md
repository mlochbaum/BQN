*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/export.html).*

# Leftward Double Arrow (`⇐`)

## `n ⇐ v`: Export Definition
[→full documentation](../doc/namespace.md#exports)

Define a variable with name `n` and export it from the current namespace.

        ns ← { exported ⇐ 5, unexported ← 0}
        ns.exported
        ns.unexported

## `n ⇐`: Export names
[→full documentation](../doc/namespace.md#exports)

Export the names given in `n` from the current namespace. Names must be defined somewhere in the scope.

        ns1 ← { ⟨alsoexported⟩⇐, exported ⇐ 5, alsoexported ← 0}
        ns1.exported
        ns1.alsoexported
