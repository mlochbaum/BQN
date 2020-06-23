# BQN specification

This directory gives a (currently incomplete) specification for BQN. The specification differs from the documentation in `doc/` in that its purpose is only to describe the exact details of BQN's operation in the most quickly accessible way, rather than to explain the core ideas of BQN functionality and how it might be used. Since it is easier to specify than to document, the specification is currently more complete than the documentation; for example, it includes nearly all primitives.

The following aspects define BQN and are or will be specified:
- [Token formation](token.md)
- Numeric and character literals
- [Grammar](grammar.md)
- Array model and notation
- Evaluation semantics
- Built-in operations ([reference implementations](reference.bqn))
