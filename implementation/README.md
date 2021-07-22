*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/index.html).*

# BQN implementation notes

Notes about how BQN is or could be implemented.

This repository's BQN implementation is written mainly in BQN: the bytecode [compiler](../src/c.bqn) is completely self-hosted, and the majority of the runtime ([r0](../src/r0.bqn), [r1](../src/r1.bqn)) is written in BQN except that it is allowed to define primitives; some preprocessing ([pr](../src/pr.bqn)) turns the primitives into identifiers.

The remaining part, a Virtual Machine (VM), can be implemented in any language to obtain a version of BQN running in that language. The VM used for the online REPL is the [Javascript implementation](../docs/bqn.js), while [CBQN](https://github.com/dzaima/CBQN) is a more advanced VM in C. There are platform-specific and generic tests in the [test](../test/) directory.

- [The BQN virtual machine and runtime](vm.md): the non-self-hosted parts of the BQN implementation, or those needed to port it to a new platform.
- [Notes on implementing primitives](primitive/README.md)
- [Notes on compilation](compile/README.md)
- [Comparison to Co-dfns](codfns.md), the only other array-based compiler.

I held a few early forum discussions on the workings of the self-hosted compiler, but aborted these because the interactive format wasn't doing too much. I haven't yet started on non-interactive replacements.

- [Parenthesis nesting level](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s1-parenthesis-nesting-level)
- [Infix to RPN](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s2-infix-to-rpn)
- [Parsing expressions with parentheses](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s3-parsing-expressions-with-parentheses)
