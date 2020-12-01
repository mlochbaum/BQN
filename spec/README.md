*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/index.html).*

# BQN specification

This directory gives a (currently incomplete) specification for BQN. The specification differs from the [documentation](../doc/README.md) in that its purpose is only to describe the exact details of BQN's operation in the most quickly accessible way, rather than to explain the core ideas of BQN functionality and how it might be used. Since it is easier to specify than to document, the specification is currently more complete than the documentation; for example, it includes nearly all primitives.

The following aspects define BQN and are or will be specified:
- [Types](types.md)
- [Token formation](token.md)
- [Literals](literal.md)
- [Grammar](grammar.md)
- [Variable scoping](scope.md)
- [Evaluation semantics](evaluate.md)
- Primitives ([reference implementations](reference.bqn))
- [Inferred properties](inferred.md) (type, Undo, and Under)
- [System-provided values](system.md) (`•`)
