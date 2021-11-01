*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/index.html).*

# BQN specification

This document, and the others in this directory (linked in the list below) make up the pre-versioning BQN specification. The specification differs from the [documentation](../doc/README.md) in that its purpose is only to describe the exact details of BQN's operation in the most quickly accessible way, rather than to explain the central ideas of BQN functionality and how it might be used. The core of BQN, which excludes system-provided values, is now almost completely specified. Planned changes to the specification are tracked on [this page](https://topanswers.xyz/apl?q=1888).

Under this specification, a language implementation is a **BQN pre-version implementation** if it behaves as specified for all input programs. It is a **BQN pre-version implementation with extensions** if it behaves as specified in all cases where the specification does not require an error, but behaves differently in at least one case where it requires an error. It is a **partial** version of either of these if it doesn't conform to the description but differs from a conforming implementation only by rejecting with an error some programs that the conforming implementation accepts. As the specification is not yet versioned, other instances of the specification define these terms in different ways. An implementation can use one of these terms if it conforms to any instance of the pre-versioning BQN specifications that defines them. When versioning is begun, there will be only one specification for each version.

The following documents are included in the BQN specification. A BQN program is a sequence of [Unicode](https://en.wikipedia.org/wiki/Unicode) code points: to evaluate it, it is converted into a sequence of tokens using the token formation rules, then these tokens are arranged in a syntax tree according to the grammar, and then this tree is evaluated according to the evaluation semantics. The program may be evaluated in the presence of additional context such as a filesystem or command-line arguments; this context is presented to the program and manipulated through the system-provided values.
- [Types](types.md)
- [Token formation](token.md)
- [Literals](literal.md)
- [Grammar](grammar.md)
- [Variable scoping](scope.md)
- [Evaluation semantics](evaluate.md)
- [Primitives](primitive.md): [reference implementations](reference.bqn)
- [Inferred properties](inferred.md) (identities, fills, Undo, and Under)
- [System-provided values](system.md) (`•`)

In several cases, an implementation can choose between more than one possible behavior.
- An implementation chooses its number system, which must be an approximation of the real or complex numbers but has no specific requirements. Results of basic numeric operations must be deterministic but are not specified.
- Minimum (`⌊`) and Maximum (`⌈`) may give an error if either argument is a character.
- Other than the required cases, attempting to use an inferred property can either fail or give a result consistent with the constraints on that property.
- In some cases there are multiple valid results for Undo. Any of these results, or an error, can be given; if there is no obvious choice of result an error is recommended. The choice must depend only on the inputs to Undo.
- If the specification does not identify the fill element for an array, then any or no fill can be deterministically chosen.
- If an expression in a program cannot be evaluated without error (that is, there is no context that would cause the program, or a caller with access to its result, to evaluate the expression but not eventually fail with an error), then the implementation may reject this program, giving an error before evaluating any code and regardless of context—in this case, it must not accept the program in any context. This "compiler clause" modifies the behavior described above.
- The way the program's output (either a result or an error) is displayed to the user is not specified.
- Evaluation can fail at any time if the implementation runs out of resources such as memory or stack space.
- Any system values can be implemented, and they may act in an arbitrary way including modifying the behavior of the rest of the program. System values can create values with types not included in the specification, whose behavior is left up to the implementation. If system values with names given in this specification are implemented, however, then they must conform with the specified behavior.
