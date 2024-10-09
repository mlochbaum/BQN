*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/index.html).*

# BQN implementation notes

<center>

[primitives](primitive/README.md) • [compiling](compile/README.md) • [state of CBQN](perf.md) • [VM documentation](vm.md)

</center>

Notes about how BQN is or could be implemented.

This repository's BQN implementation is written mainly in BQN: the bytecode [compiler](../src/c.bqn) is completely self-hosted, and the majority of the runtime ([r0](../src/r0.bqn), [r1](../src/r1.bqn)) is written in BQN except that it is allowed to define primitives; some preprocessing ([pr](../src/pr.bqn)) turns the primitives into identifiers.

The remaining part, a Virtual Machine (VM), can be implemented in any language to obtain a version of BQN running in that language. Its required behavior is documented [here](vm.md). There is a pure-BQN implementation for [bqn.bqn](../bqn.bqn), but its only practical purpose is to quickly test modifications to the runtime and compiler. The VM used for the online REPL is the [Javascript implementation](../docs/bqn.js), while [CBQN](https://github.com/dzaima/CBQN) is a more advanced VM in C. [This page](https://github.com/dzaima/CBQN/blob/master/src/README.md) gives an introduction to the CBQN source code. There are platform-specific and generic tests in the [test](../test/) directory.
