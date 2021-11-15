*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/context.html).*

# BQN's context-free grammar

APL has a problem. To illustrate, let's look at an APL expression:

    a b c d e

It is impossible to say anything about this sentence! Is `c` a dyadic operator being applied to `b` and `d`, or are `b` and `d` two dyadic functions being applied to arrays? In contrast, expressions in C-like or Lisp-like languages show their structure of application:

    b(a, d(c)(e))
    (b a ((d c) e))

In each case, some values are used as inputs to functions while others are the functions being applied. The result of a function can be used either as an input or as a function again. These expressions correspond to the APL expression where `a` and `e` are arrays, `b` and `c` are functions, and `d` is a monadic operator. However, these syntactic roles have to be known to see what the APL expression is doing—they are a form of context that is required for a reader to know the grammatical structure of the expression. In a context-free grammar like that of simple C or Lisp expressions, a value's grammatical role is part of the expression itself, indicated with parentheses: they come after the function in C and before it in Lisp. Of course, a consequence of using parentheses in this way is having a lot of parentheses. BQN uses a different method to annotate grammatical role:

    a B C _d e

Here, the lowercase spelling indicates that `a` and `e` are to be treated as subjects ("arrays" in APL) while the uppercase spelling of variables `B` and `C` are used as functions and `_d` is a 1-modifier ("monadic operator"). Like parentheses for function application, the spelling is not inherent to the variable values used, but instead indicates their grammatical role in this particular expression. A variable has no inherent spelling and can be used in any role, so the names `a`, `A`, `_a`, and `_a_` all refer to exact same variable, but in different roles; typically we use the lowercase name to refer to the variable in isolation—all values are nouns when speaking about them in English. While we still don't know anything about what values `a`, `b`, `c`, and so on have, we know how they interact in the line of code above.

## Is grammatical context really a problem?

Yes, in the sense of [problems with BQN](../commentary/problems.md). A grammar that uses context is harder for humans to read and machines to execute. A particular difficulty is that parts of an expression you don't yet understand can interfere with parts you do, making it difficult to work through an unknown codebase.

One difficulty beginners to APL will encounter is that code in APL at first appears like a string of undifferentiated symbols. For example, a tacit Unique Mask implementation `⍳⍨=⍳∘≢` consists of six largely unfamiliar characters with little to distinguish them (in fact, the one obvious bit of structure, the repeated `⍳`, is misleading as it means different things in each case!). Simply placing parentheses into the expression, like `(⍳⍨)=(⍳∘≢)`, can be a great help to a beginner, and part of learning APL is to naturally see where the parentheses should go. The equivalent BQN expression, `⊐˜=↕∘≠`, will likely appear equally intimidating at first, but the path to learning which things apply to which is much shorter: rather than learning the entire list of APL primitives, a beginner just needs to know that superscript characters like `˜` are 1-modifiers and characters like `∘` with unbroken circles are 2-modifiers before beginning to learn the BQN grammar that will explain how to tie the various parts together.

This sounds like a distant concern to a master of APL or a computer that has no difficulty memorizing a few dozen glyphs. Quite the opposite: the same concern applies to variables whenever you begin work with an unfamiliar codebase! Many APL programmers even enforce variable name conventions to ensure they know the class of a variable. By having such a system built in, BQN keeps you from having to rely on programmers following a style guide, and also allows greater flexibility, including [functional programming](functional.md), as we'll see later.

Shouldn't a codebase define all the variables it uses, so we can see their class from the definition? Not always: consider that in a language with libraries, code might be imported from dependencies. Many APLs also have some dynamic features that can allow a variable to have more than one class, such as the `⍺←⊢` pattern in a dfn that makes `⍺` an array in the dyadic case but a function in the monadic case. Regardless, searching for a definition somewhere in the code is certainly a lot more work than knowing the class just from looking! One final difficulty is that even one unknown can delay understanding of an entire expression. Suppose in `A B c`, `B` is a function and `c` is an array, and both values are known to be constant. If `A` is known to be a function (even if its value is not yet known), its right argument `B c` can be evaluated ahead of time. But if `A`'s type isn't known, it's impossible to know if this optimization is worth it, because if it is an array, `B` will instead be called dyadically.

## BQN's spelling system

BQN's [expression grammar](expression.md) is a simplified version of the typical APL, removing some oddities like niladic functions and the two-glyph Outer Product operator. Every value can be used in any of four syntactic roles:

| BQN         | APL              | J
|-------------|------------------|------
| Subject     | Array            | Noun
| Function    | Function         | Verb
| 1-modifier  | Monadic operator | Adverb
| 2-modifier  | Dyadic operator  | Conjunction

Unlike variables, BQN primitives have only one spelling, and a fixed role (but their values can be used in a different role by storing them in variables). Superscript glyphs `` ˜¨˘⁼⌜´˝` `` are used for 1-modifiers, and glyphs `∘○⊸⟜⌾⊘◶⚇⎉⍟` with an unbroken circle are 2-modifiers. Other primitives are functions. String and numeric literals are subjects.

BQN's variables use another system, where the spelling indicates how the variable's value is used. A variable spelled with a lowercase first letter, like `var`, is a subject. Spelled with an uppercase first letter, like `Var`, it is a function. Underscores are placed where operands apply to indicate a 1-modifier `_var` or 2-modifier `_var_`. Other than the first letter or underscore, variables are case-insensitive.

The associations between spelling and syntactic role are considered part of BQN's [token formation rules](../spec/token.md).

One rule for typing is also best considered to be a pre-parsing rule like the spelling system: the role of a brace construct `{}` with no header is determined by which special arguments it uses: it's a subject if there are none, but a `𝕨` or `𝕩` makes it at least a function, an `𝔽` makes it a 1- or 2-modifier, and a `𝔾` always makes it a 2-modifier.

The syntactic role is a property of an expression, and BQN's grammar determines how roles interact in expressions. In contrast, type is a property of a value, and evaluation rules control what types can be used. This means that roles exist statically in the code (context-free grammar!) while values can change between or within runs of the program. This is necessary to have a context-free grammar with unrestricted dynamic types. Are unrestricted dynamic types useful? Read on…

## Mixing roles

BQN's value types align closely with its syntactic roles: functions, 1-modifiers, and 2-modifiers are all types (*operation* types) as well as roles, while the other types (*data* types) are split into numbers, characters, and arrays. This is no accident, and usually values will be used in roles that correspond to their underlying type. However, the ability to use a role that doesn't match the type is also useful.

Any type can be passed as an argument to a function, or as an operand, by treating it as a subject. This means that BQN fully supports Lisp-style [functional programming](functional.md), where functions can be used as first-class entities.

It can also be useful to treat a value of a data type as a function, in which case it applies as a constant function. This rule is useful with most built-in modifiers. For example, `F⎉1` uses a constant for the rank even though in general a function can be given, and if `a` is an array then `a⌾(b⊸/)` inserts the values in `a` into the positions selected by `b`, ignoring the old values rather than applying a function to them.

Other mixes of roles are generally not useful. While a combination such as treating a function as a modifier is allowed, attempting to apply it to an operand will fail. Only a 1-modifier can be applied as a 1-modifier and only a 2-modifier can be applied as a 2-modifier. Only a function or data can be applied as a function.

It's also worth noting that a subject may unexpectedly be a function! For example, the result of `𝕨˜𝕩` may not always be `𝕨`. `𝕨˜𝕩` is exactly identical to `𝕎˜𝕩`, which gives `𝕩𝕎𝕩`. If `𝕎` is a number, character, or array, that's the same as `𝕨`, but if it is a function, then it will be applied.

The primary way to change the role of a value in BQN is to use a name, including one of the special names for inputs to a brace function or modifier. In particular, you can use `{𝔽}` to convert a subject operand into a function. Converting a function to a subject is more difficult. Often an array of functions is wanted, in which case they can be stranded together; otherwise it's probably best to give the function a name. Picking a function out of a list, for example `⊑⟨+⟩`, will give it as a subject.
