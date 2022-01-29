*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/nextbody.html).*

# Semicolon (`;`)

## `;`: Next Body
[→full documentation](../doc/block.md#multiple-bodies)

End the current block body and start a new one. [Headers](header.md) (`:`) and [predicates](predicate.md) (`?`) can control which body is evaluated. A function can have two headers without these, indicating the monadic and dyadic cases.

        3 { 𝕩÷2 ; -𝕨‿𝕩 } 4   # Monadic and dyadic cases

        F ← {𝕊a‿b: a-b; 𝕊a‿b‿c: b+c}

        F 5‿2                # Matches first header

        F 1‿3‿6              # Matches second header
