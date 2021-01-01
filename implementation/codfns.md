*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/codfns.html).*

# Co-dfns versus BQN's implementation

The BQN self-hosted compiler is directly inspired by the [Co-dfns](https://github.com/Co-dfns/Co-dfns) project, a compiler for a subset of [Dyalog APL](../doc/fromDyalog.md). I'm very grateful to Aaron for showing that array-oriented compilation is even possible! In addition to the obvious difference of target language, BQN differs from Co-dfns both in goals and methods.

The shared goals of BQN and Co-dfns are to implement a compiler for an array language with whole-array operations. This provides the theoretical benefit of a short *critical path*, which in practice means that both compilers can make good use of a GPU or a CPU's vector instructions simply by providing an appropriate runtime (however, only Co-dfns has such a runtime—an ArrayFire program on the GPU and Dyalog APL on the CPU). The two implementations also share a preference for working "close to the metal" by passing around arrays of numbers rather than creating abstract types to work with data. Objects are right out. These choices lead to a compact source code implementation, and may have some benefits in terms of how easy it is to write and understand the compiler.

## Compilation strategy

Co-dfns development has primarily been focused on the core compiler, and not parsing, code generation, or the runtime. The associated Ph.D. thesis and famous 17 lines figure refer to this section, which transforms the abstract syntax tree (AST) of a program to a lower-level form, and resolves lexical scoping by linking variables to their definitions. While all of Co-dfns is written in APL, other sections aren't necessarily designed to be data-parallel and don't have the same performance guarantees. For example, the parser appears to be written with some sort of parser combinators. In contrast, BQN is entirely written in a data-parallel style. It does not maintain the same clean separation between compiler sections: [token formation](../spec/token.md) and literal evaluation is separated into its own function, but parsing, AST manipulation, and code generation overlap.

The core Co-dfns compiler is based on manipulating the syntax tree, which is mostly stored as parent and sibling vectors—that is, lists of indices of other nodes in the tree. BQN is less methodical, but generally treats the source tokens as a simple list. This list is reordered in various ways, allowing operations that behave like tree traversals to be performed with scans under the right ordering. This strategy allows BQN to be much stricter in the kinds of operations it uses. Co-dfns regularly uses `⍣≡` (repeat until convergence) for iteration and creates nested arrays with `⌸` (Key, like [Group](../doc/group.md)), but BQN has only a single instance of iteration to resolve quotes and comments, plus one complex but parallelizable scan for numeric literal processing, and only uses Group to extract identifiers and strings. This means that most primitives, if we count simple reductions and scans as single primitives, are executed a fixed number of times during execution, making complexity analysis even easier than in Co-dfns.

A goal for BQN was to not only write the compiler in BQN but to use BQN for the runtime as much as possible, while Co-dfns uses a conventional runtime written in C with ArrayFire. This goal has largely been achieved, so that the current BQN runtime uses a very small number of basic array operations currently provided by Javascript. However, basic operations may be added in the future for performance reasons.

## Code style

Initially, the BQN compiler was written with a similar style to Co-dfns, primarily because I wanted to quickly have a working BQN implementation and reach parity with the Co-dfns compiler (not the runtime!). This style is now shifting to support several goals that Co-dfns doesn't have:
- Error reporting
- Teaching
- Multiple backends (bytecode, Wasm, machine code)
- Optimization
- Testing and debugging the compiler

So far the most notable difference is the addition of per-line comments. Aaron advocates the almost complete separation of code from comments (thesis) in addition to his very terse style as a general programming methodology. I find that this practice makes it hard to connect the documentation to the code and is very slow in providing a summary or reminder of functionality that a comment might. However, I do plan to write long-form material providing the necessary context and explanations required to understand the compiler.

Co-dfns doesn't check for compilation errors, while BQN has complete error checking and good error messages, and includes source positions in compiler errors as well as in the compiled code for use in runtime errors. I have found that such checking imposes a low cost on compilation speed (perhaps 25%), but a greater cost on the compiler codebase size and legibility. Maintaining source locations is also a small expense relative to other compilation. Aside from that maintenance, more user-friendly error reporting has almost no performance cost for working programs, because error reporting code only needs to be run when compilation fails. This leaves room for potentially very sophisticated error analysis to attempt to track down the root cause of a compilation error, but I haven't yet done any work along these lines.
