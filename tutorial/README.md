*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/tutorial/index.html).*

# BQN tutorials

BQN tutorials explain how to approach and use the language as a newcomer (or they try; please get in touch if you find that they skip ahead!). Tutorials are meant to explain key ideas and may ignore details that would be included in the [documentation](../doc/README.md); also unlike the documentation they're meant to be read in order, as each tutorial will build on ideas from the previous ones. But feel free to skim or jump around if you find you're reading things that are already obvious. You may also want to check the [quick start](../doc/quick.md) to get a broad idea of what BQN is about.

Tutorials assume (pretty presumptively, really. Disgusting.) that you are already motivated to learn BQN and use simple rather than flashy examples. To see some of the possibilities you might instead check the [community links](../community/README.md), or browse the [APL Wiki](https://aplwiki.com/wiki/Main_Page) as these languages are closely related.

The tutorials available so far:

| Tutorial                     | Concepts | Primitives
|------------------------------|----------|-----------
| [Expressions](expression.md) | Arithmetic, syntax, affine characters  | `+-×÷⋆√˜⁼˙∘`
| [List manipulation](list.md) | Lists, strings, and strands; pervasion | `∾⋈⌽↕¨´`
| [Combinators](combinator.md) | Tacit programming, booleans            | `\|<>≠=≤≥≡≢○⊸⟜`
| [Variables](variable.md)     | Declarations, cross-roles              | `∧∨¬⊣⊢↑↓«»⌾`

Where to from here? I'd suggest the following documentation pages as starting points:

- [Quick start](../doc/quick.md)
- [Blocks](../doc/block.md); maybe [Lexical scoping](../doc/lexical.md) and [Control flow](../doc/control.md)
- [Arrays](../doc/array.md) and [Indices](../doc/indices.md)
- [Namespaces](../doc/namespace.md) and [Object-oriented programming](../doc/oop.md)
- [Primitives](../doc/primitive.md) as needed
