*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/export.html).*

# Leftward Double Arrow (`⇐`)

## `n ⇐ v`: Export Definition

Define a variable with name `n` and export it from the current namespace or program's scope.

        ns ← { exported ⇐ 5, unexported ← 0}
        ns.exported
        ns.unexported

## `𝕨 ⇐`: Export names

Export the names given in `𝕩` from the current namespace or program's scope. Names must be defined.

        ns1 ← { ⟨alsoexported⟩⇐, exported ⇐ 5, alsoexported ← 0}
        ns1.exported
        ns1.alsoexported
