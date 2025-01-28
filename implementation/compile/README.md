*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/compile/index.html).*

# Optimizing compilation notes

Pages in this directory discuss advanced compilation strategies for BQN, that is, steps that might take take place after compiling to bytecode or a similar intermediate representation. Most content here is currently speculative: C, Java, and Javascript backends are capable of compiling to native (x86, JVM, or Javascript) code in order to lower evaluation overhead but don't perform much if any analysis to improve this code. CBQN is likely to start making such optimizations in the future.

- [Array language compilation in context](intro.md), an introduction to the subject
- [Dynamic compilation](dynamic.md), discussing high-level strategies
- [Loop fusion in array languages](fusion.md)

The self-hosted bytecode compiler isn't really documented, but there are some related resources elsewhere. I held a few early chat discussions on building an array-based compiler, but aborted these because the interactive format wasn't doing too much.

- [Comparison to Co-dfns](../codfns.md), the other array-based compiler (plus the newer Pareas).
- Chat: [Parenthesis nesting level](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s1-parenthesis-nesting-level)
- Chat: [Infix to RPN](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s2-infix-to-rpn)
- Chat: [Parsing expressions with parentheses](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s3-parsing-expressions-with-parentheses)
