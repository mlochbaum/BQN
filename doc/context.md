*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/context.html).*

# BQN's context-free grammar

*See [syntactic role](expression.md#syntactic-role) for the plain description of the features discussed here. This page explains why you'd want this system, particularly coming from an APL or J background.*

APL has a problem. To illustrate, let's look at an APL expression:

    a b c d e

It is impossible to say anything about this sentence! Is `c` a dyadic operator being applied to `b` and `d`, or are `b` and `d` two dyadic functions being applied to arrays? In contrast, expressions in C-like or Lisp-like languages show their structure of application:

    b(a, d(c)(e))    # C
    (b a ((d c) e))  # Lisp

In each case, some values are passed to functions while others are the functions being applied (both variables and function results can be used in these two ways). These expressions correspond to the APL one if `a` and `e` are arrays, `b` and `c` are functions, and `d` is a monadic operator. But in APL the types aren't part of the expression—they're a form of context that's required for a reader to know the grammatical structure of the expression. Simple C or Lisp expressions don't need this context because a value's grammatical role is determined by the parentheses: they come after the function in C and before it in Lisp. Of course, a consequence of using parentheses in this way is having a lot of parentheses. BQN has its own way to annotate grammatical role:

    a B C _d e

Here, the lowercase spelling indicates that `a` and `e` are to be treated as subjects ("arrays" in APL) while the uppercase `B` and `C` are used as functions and `_d` as a 1-modifier ("monadic operator"). Like parentheses for function application, the spelling is not inherent to the variable values used, but instead indicates their grammatical role in this particular expression. A variable has no inherent spelling and can be used in any role: the names `a`, `A`, `_a`, and `_a_` refer to the exact same variable. While we still don't know anything about what values `a`, `b`, `c`, and so on have, we know how they interact in the line of code above.

## Is grammatical context really a problem?

Yes, in the sense of [problems with BQN](../commentary/problems.md). A grammar that uses context is harder for humans to read and machines to execute. A particular difficulty is that parts of an expression you don't yet understand can interfere with parts you do, making it difficult to work through an unknown codebase.

One difficulty beginners to APL will encounter is that code in APL at first appears like a string of undifferentiated symbols. For example, a tacit Unique Mask implementation `⍳⍨=⍳∘≢` consists of six largely unfamiliar characters with little to distinguish them (in fact, the one obvious bit of structure, the repeated `⍳`, is misleading as it means different things in each case!). Simply placing parentheses into the expression, like `(⍳⍨)=(⍳∘≢)`, can be a great help to a beginner, and part of learning APL is to naturally see where the parentheses should go. The equivalent BQN expression, `⊐˜=↕∘≠`, will likely appear equally intimidating at first, but the path to learning which things apply to which is much shorter. Rather than learning the entire list of APL primitives, a beginner just needs to know that superscript characters like `˜` are 1-modifiers, and characters like `∘` with unbroken circles are 2-modifiers, to start learning the BQN grammar that tie the various parts together.

This sounds like a distant concern to a master of APL or a computer that has no difficulty memorizing a few dozen glyphs. Quite the opposite: the same concern applies to variables whenever you begin work with an unfamiliar codebase! Many APL programmers even enforce variable name conventions to ensure they know the class of a variable. By having such a system built in, BQN keeps you from having to rely on other programmers following a style guide, and also allows greater flexibility, including [functional programming](functional.md), as we'll see later.

Shouldn't a codebase define all the variables it uses, so we can see their class from the definition? Not always: consider that in a language with libraries, code might be imported from dependencies. Many APLs also have some dynamic features that can allow a variable to have more than one class, such as the `⍺←⊢` pattern in a dfn that makes `⍺` an array in the dyadic case but a function in the monadic case. Regardless, searching for a definition somewhere in the code is certainly a lot more work than knowing the class just from looking! One final difficulty is that even one unknown can delay understanding of an entire expression. Suppose in `A B c`, `B` is a function and `c` is an array, and both values are known to be constant. If `A` is known to be a function (even if its value is not yet known), its right argument `B c` can be evaluated ahead of time. But if `A`'s type isn't known, it's impossible to know if this optimization is worth it, because if it is an array, `B` will instead be called dyadically.

## BQN's spelling system

BQN's [expression grammar](expression.md) is a simplified version of the typical APL, removing some oddities like niladic functions and the two-glyph Outer Product operator. Every value can be used in any of four syntactic roles:

| BQN         | APL              | J
|-------------|------------------|------
| Subject     | Array            | Noun
| Function    | Function         | Verb
| 1-modifier  | Monadic operator | Adverb
| 2-modifier  | Dyadic operator  | Conjunction

BQN uses [a few rules](expression.md#role-spellings) to determine what role various parts of the grammar have. Primitive glyphs follow patterns: 1-modifiers like `˝` are superscripts and 2-modifiers like `○` use circles. A variable can be spelled with different casing or underscores to indicate the role each time it's used.

The syntactic role is a property of an expression, and BQN's grammar determines how roles interact in expressions. But [type](types.md) is a property of a value, and evaluation rules control what types can be used. This means that roles exist statically in the code (context-free grammar!) while values can change between or within runs of the program. This is necessary to have a context-free grammar with unrestricted dynamic types. Are unrestricted dynamic types useful? Read on…

## Mixing roles

BQN's value types align closely with its syntactic roles: functions, 1-modifiers, and 2-modifiers are all types (*operation* types) as well as roles, while the other types (*data* types) are split into numbers, characters, and arrays. This is no accident, and usually values will be used in roles that correspond to their underlying type. However, the ability to use a role that doesn't match the type is also useful.

Any type can be passed as an argument to a function, or as an operand, by treating it as a subject. This means that BQN fully supports Lisp-style [functional programming](functional.md), where functions can be used as first-class entities.

It can also be useful to treat a value of a data type as a function, in which case it applies as a constant function. Most primitive modifiers are used in this way at least some of the time. For example, `F⎉1` has a constant for the rank even though in general a function can be given, and if `a` is an array then `a⌾(b⊸/)` inserts the values in `a` into the positions selected by `b`, ignoring the old values rather than applying a function to them.

Other mixes of roles are generally not useful. For example, just writing a function as a modifier is allowed, but actually applying it to operands will fail. Only a 1-modifier can be applied as a 1-modifier and only a 2-modifier can be applied as a 2-modifier. Only a function or data can be applied as a function.

It's also worth noting that a subject may unexpectedly be a function! For example, the result of `𝕨˜𝕩` may not always be `𝕨`. `𝕨˜𝕩` is exactly identical to `𝕎˜𝕩`, which gives `𝕩𝕎𝕩`. If `𝕎` is a number, character, or array, that's the same as `𝕨`, but if it is a function, then it will be applied. The [Constant](constant.md) (`˙`) modifier keeps a function from being applied when that isn't wanted.

The most general way to change the role of a value in BQN is to give it a name. A convenient trick is to use `{𝔽}` to convert a subject operand into a function. Converting a function to a subject is more difficult. Often an array of functions is wanted, in which case they can be stranded together; otherwise it's probably best to give the function a name. Picking a function out of a list, for example `⊑⟨+⟩`, will give it as a subject.
