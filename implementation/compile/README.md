*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/compile/index.html).*

# Optimizing compilation notes

Pages here discuss advanced compilation strategies for BQN, that is, steps that might take take place after compiling to bytecode or a similar intermediate representation.

Most content here is currently speculative: C, Java, and Javascript backends are capable of compiling to native (x86, JVM, or Javascript) code in order to lower evaluation overhead but don't perform much if any analysis to improve this code. CBQN is likely to start making such optimizations in the future.

- [Array language compilation in context](intro.md), an introduction to the subject
- [Dynamic compilation](dynamic.md), discussing high-level strategies
