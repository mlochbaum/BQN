*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/expression.html).*

# Expression syntax

BQN expressions are the part of [syntax](syntax.md) that describes computations to perform. Programs are mainly made up of expressions with a little organizing material like [blocks](block.md) and [namespaces](namespace.md) around them. This page explains how functions, modifiers, and assignment combine with their inputs. It doesn't describe [constant](syntax.md#constants) and [array](arrayrepr.md#list-literals) literals, which each form a single subject for grammatical purposes.

The [first tutorial](../tutorial/expression.md) also covers how to build and read BQN expressions.

## Overview

BQN expressions consist of subjects, functions, and modifiers arranged in sequence, with parentheses to group parts into subexpressions. Assignment arrows `←` and `↩` can also be present and mostly behave similar to functions. Functions can be applied to subjects or grouped into trains, while modifiers can be applied to subjects or functions. The most important kinds of application are:

| left  | main  | right | output     | name       | binding
|-------|-------|-------|------------|------------|---------
|  `w?` |  `F`  |  `x`  | Subject    | Function   | RtL, looser
|  `F?` |  `G`  |  `H`  | Function   | Train      |
|  `F`  | `_m`  |       | Function   | 1-Modifier | LtR, tighter
|  `F`  | `_c_` |  `G`  | Function   | 2-Modifier |

The four roles (subject, function, two kinds of modifier) describe expressions, not values. When an expression is evaluated, the value's [type](types.md) doesn't have to correspond to its role, and can even change from one evaluation to another. An expression's role is determined entirely by its source code, so it's fixed.

In the table, `?` marks an optional left argument. If there isn't a value in that position, or it's [Nothing](#nothing) (`·`), the middle function will be called with only one argument.

If you're comfortable reading [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) and want to understand things in more detail than described below, you might check the [grammar specification](../spec/grammar.md) as well.

## Syntactic role

*This issue is approached from a different angle in [Context free grammar](context.md).*

In APL, the way one part of an expression interacts with others is determined by its value. That means that to parse an expression, in general you would have to evaluate that part, get a value, check its type, and then figure out how it fits in with the rest of the expression. This is a lot of work. BQN changes things so that you can determine how to parse an expression just by looking at its source code. But because it still needs to support expressions that can evaluate to more than one possible [type](types.md), BQN has to introduce a new and independent concept, called **syntactic role**, in order to support APL-like expressions.

Syntactic role is a property of an expression, not its value. To describe it in terms of English grammar, you might say "I like BQN", using "BQN" as an object, or "BQN scares me", using it as a subject. BQN itself isn't a subject or object, it's a programming language. Similarly you might write `F g`, placing `f` in a function role to apply it to `g`, or `G f` to use `f` as an argument. Maybe even in the same program, although it's unlikely.

### Role spellings

The four roles are **subject**, **function**, **1-modifier**, and **2-modifier**, as shown in the table below. Each type has an associated role (with non-operation types all corresponding to subjects), and the value of an expression will often have a matching type, but it doesn't have to.

| BQN         | Names       | Primitives
|-------------|-------------|-----------------
| Subject     | `lowerCase` | Literals
| Function    | `UpperCase` | `+-×÷⋆√⌊⌈\|¬∧∨`…
| 1-modifier  | `_leading`  | `` ˙˜˘¨⌜⁼´˝` ``
| 2-modifier  | `_both_`    | `∘○⊸⟜⌾⊘◶⎉⚇⍟⎊`

Primitive tokens, since they have a fixed value, always have a role that matches their type. They are functions, unless they fall into one of the two modifier patterns. 1-modifiers have superscript glyphs, and 2-modifiers have glyphs with an unbroken circle—that is, one without a line through it, excluding functions `⌽` and `⍉`.

Variable names can be written in any case and with underscores added, and these changes don't affect what [identifier](lexical.md) the name refers to. `ab`, `aB`, `AB`, and `_a_B_` are all the same variable. However, the spelling—specifically the first and last characters—determine the variable's role. A lowercase first letter indicates a subject, and an uppercase first letter makes it a function. A leading underscore (regardless of the following character) indicates a 1-modifier, and both leading and trailing underscores makes a 2-modifier.

Besides these, character, string, and [list literals](arrayrepr.md#list-literals) always have a subject role, and the role of a [block](block.md) is determined by its type, which depends either on the header it has or which special variables it uses.

The role of a compound expression, formed by applying an operation to some inputs, depends on the operation applied. This system is discussed in the remaining sections below.

## Nothing

The character `·` is called Nothing. While it can be easier to think of it as a value, it can't be passed around in variables, and so can also be interpreted as an element of syntax. The special name `𝕨` also functions as Nothing if the block that contains it is called with one argument (the uppercase spelling `𝕎` doesn't, but instead immediately causes an error). Both `·` and `𝕨` have a subject role.

The following rules apply to Nothing:
- If it's the left argument in a function call, the function is called with no left argument.
- If it's the right argument, the function isn't called, and "returns" Nothing.

For example, the expression `(F 2 G ·) H I j` is equivalent to `H I j`. But functions and arguments that would be discarded by the second rule are still evaluated, so that for example `(a+↩1) F ·` increments `a` when run.

Nothing can only be used as an argument to a function, or the left argument in a train (it can't be the right argument in a train because a train ends with a function by definition). In another position where a subject could appear, like as an operand or in a list, it causes an error: either at compile time, for `·`, or when the function is called with no left argument, for `𝕨`.

## Kinds of application

Here is a table of the modifier and function application rules:

| left  | main  | right | output     | name
|-------|-------|-------|------------|------
|       |  `F`  |  `x`  | Subject    | Monadic function
|  `w`  |  `F`  |  `x`  | Subject    | Dyadic function
|       |  `F`  |  `G`  | Function   | 2-train
|  `F*` |  `G`  |  `H`  | Function   | 3-train
|  `F*` | `_m`  |       | Function   | 1-Modifier
|  `F*` | `_c_` |  `G*` | Function   | 2-Modifier
|       | `_c_` |  `G*` | 1-Modifier | Partial application
|  `F*` | `_c_` |       | 1-Modifier | Partial application

A function with an asterisk indicates that a subject can also be used. Since the role doesn't exist after parsing, function and subject spellings are indistinguishable in these positions. Modifier applications bind more tightly than functions, and associate left-to-right while functions associate right-to-left.
