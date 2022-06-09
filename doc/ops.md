*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/ops.html).*

# Functions and modifiers

BQN's three operation [types](types.md) are the function, 1-modifier, and 2-modifier.

In general, an operation is *called* by passing in *inputs*, and returns a *result* value. The inputs and result can have any type. Since BQN isn't a pure [functional](functional.md) language, the operation might also have side effects: it can modify the values of variables, perform program input or output, or call other operations with their own side effects.

This page deals with types, not syntax. Expressions with a function or modifier [role](expression.md#syntactic-role) don't have to yield a value of that type when run. However, primitives and blocks do have roles that match their types.

## Functions

A function has one or two inputs called *arguments*. The general layout is `𝕨 Fn 𝕩`, with an optional left argument `𝕨` and a non-optional right argument `𝕩`. The number of arguments is called its *valence*, and functions are naturally *ambivalent*, allowing one or two arguments. When called with one argument—`𝕩` only—it's *monadic*, and when called with two it's *dyadic*. More arguments, or a variable number, should be handled by using a list argument; [destructuring headers](block.md#destructuring) can be useful in this case.

Functions can be [primitives](primitive.md) or [blocks](block.md) (or system functions), but there are also two kinds of *compound* functions: *derived* functions that consist of a modifier and its operands, and [trains](train.md). [Tacit](tacit.md) programming refers to code written without blocks, so of course it uses compound functions heavily.

        3 + 4     # Primitive function
        {𝕩+𝕩} 4   # Block function
        +˜ 4      # Derived function
        (⊢+÷) 4   # Train

Compound functions have some differences with blocks, most importantly that blocks can express [mutation](lexical.md#mutation) while a compound function can't have side effects unless one of its constituent functions or modifiers does. More subtly, compound functions [match](match.md#atomic-equality) when they have the same composition (much like lists) while blocks must be the same instance to match. A function's composition can also be inspected directly with `•Decompose` ([spec](../spec/system.md#operation-properties)).

While normally functions are just called, some primitives might try to infer properties of functions, which necessarily involves inspecting their definitions. The [identity value](fold.md#identity-values) used by reductions and the results of [Undo](undo.md) and [Under](under.md) rely on inference.

## Modifiers

There are two modifier types, separated for syntax reasons: 1-modifiers follow the layout `𝔽 _mod` and 2-modifiers follow `𝔽 _mod_ 𝔾`. The values `𝔽` and `𝔾` are called *operands*. There aren't any compound modifiers, so modifiers are always [primitives](primitive.md) or system-provided, or [blocks](block.md). A primitive is a 1-modifier when it's written as a superscript like `˘` or `˝`, and a 2-modifier when it has an unbroken circle like `∘` or `⍟` (not `⌽` or `⍉`).

        +⎉3    # Primitive 2-modifier (deferred)
        2{-𝕗}  # Block 1-modifier

In general, a modifier call works just like a function: inputs out, result in. Syntactically, a modifier call expression has a function role, but that doesn't affect execution. However, one kind of modifier is more strict: a *deferred* modifier doesn't evaluate anything when called, but returns a derived function. When the derived function is finally called, the modifier's definition determines what happens. Primitive modifiers are always deferred, and a block modifier is deferred if it includes arguments, either in the header or with `𝕨`, `𝕩`, or `𝕤` in the body.
