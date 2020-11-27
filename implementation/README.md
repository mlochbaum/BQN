*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/index.html).*

# BQN implementation notes

Notes about how BQN is implemented. There's not too much here yet.

- [Comparison to Co-dfns](codfns.md) discusses the general compilation strategy and how it compares to the only other array-based compiler.
- [The BQN virtual machine and runtime](vm.md) describes the non-self-hosted parts of the BQN implementation, that is, everything you need to port it to a new platform.

This repository's BQN implementation is written mainly in BQN: the bytecode [compiler](../src/c.bqn) is completely self-hosted, and the [majority of the runtime](../src/r.bqn) is written in BQN except that it is allowed to define primitives; some preprocessing turns the primitives into identifiers. The remaining part, a VM, can be implemented in any language to obtain a version of BQN running in that language.

The VM used for the online REPL is the [Javascript implementation](../docs/bqn.js). The bytecode matches dzaima/BQN's format, and [an extension](../dc.bqn) to the compiler adjusts the slightly different block declarations to target dzaima+reference BQN. [An earlier experiment](../wc.bqn) targetting [WebAssembly](https://en.wikipedia.org/wiki/WebAssembly) works only on a very small subset of BQN. All versions have automated tests in the [test](../test/) directory.

I have also held some forum discussions on the actual workings of the compiler, but aborted these because the interactive format wasn't doing too much. I haven't yet started on non-interactive replacements.

- [Parenthesis nesting level](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s1-parenthesis-nesting-level)
- [Infix to RPN](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s2-infix-to-rpn)
- [Parsing expressions with parentheses](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s3-parsing-expressions-with-parentheses)
