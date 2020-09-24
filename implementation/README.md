*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/index.html).*

# BQN implementation notes

Notes about how BQN is implemented. There's not too much here yet.

- [Comparison to Co-dfns](codfns.md) discusses the general compilation strategy and how it compares to the only other array-based compiler.
- [The BQN virtual machine and runtime](vm.md) describes the non-self-hosted parts of the BQN implementation, that is, everything you need to port it to a new platform.

I have also held some forum discussions on the actual workings of the compiler, but aborted these because the interactive format wasn't doing too much. I haven't yet started on non-interactive replacements.

- [Parenthesis nesting level](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s1-parenthesis-nesting-level)
- [Infix to RPN](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s2-infix-to-rpn)
- [Parsing expressions with parentheses](https://chat.stackexchange.com/rooms/52405/conversation/lesson-s3-parsing-expressions-with-parentheses)
