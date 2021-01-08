*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/index.html).*

# BQN specification

This directory gives a specification for BQN. The specification differs from the [documentation](../doc/README.md) in that its purpose is only to describe the exact details of BQN's operation in the most quickly accessible way, rather than to explain the core ideas of BQN functionality and how it might be used.

All normative sections of the core BQN specification (that is, excluding system-provided values) are complete except for the behavior of fill elements. The non-normative commentary on primitive definitions is also not yet complete.

The BQN specification consists of the following documents:
- [Types](types.md)
- [Token formation](token.md)
- [Literals](literal.md)
- [Grammar](grammar.md)
- [Variable scoping](scope.md)
- [Evaluation semantics](evaluate.md)
- [Primitives](primitive.md): [reference implementations](reference.bqn)
- [Inferred properties](inferred.md) (identities, fills, Undo, and Under)
- [System-provided values](system.md) (`•`)
