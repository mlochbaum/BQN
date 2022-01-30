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

Below, the function `{𝕎𝕩}` treats its left argument `𝕎` as a function and its right argument `𝕩` as a subject. With a list of functions, we can make a table of the square and square root of a few numbers:

        ⟨×˜,√⟩ {𝕎𝕩}⌜ 1‿4‿9

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

A function with an asterisk indicates that a subject can also be used. Since the role doesn't exist after parsing, function and subject spellings are indistinguishable in these positions. Modifier applications bind more tightly than functions, and associate left-to-right while functions associate right-to-left.

## Assignment

Another element that can be included in expressions is assignment, which is written with `←` to *define* (also called "declare" in many other languages) a variable and `↩` to *change* its definition. A variable can only be defined once within a [scope](lexical.md), and can only be changed if it has already been defined. However, it can be shadowed, meaning that it is defined again in an inner scope even though it has a definition in an outer scope already.

        x←1 ⋄ {x←2 ⋄ x↩3 ⋄ x}
        x

Assignment can be used inline in an expression, and its result is always the value being assigned. The role of the identifier used must match the value being assigned.

        2×a←(Neg←-)3
        a

The modification arrow `↩` can also be used to *update* the value of a variable by applying a function. This meaning applies only when there is no expression to the right of `↩` or that expression has a subject role, and there's a function to the left of `↩` (in terms of precedence this function is like an operand—a train must be parenthesized). The two forms of modified assignment are shown below along with equivalent expansions.

| Syntax   | Meaning
|----------|----------
| `a F↩`   | `a ↩ F a`
| `a F↩ b` | `a ↩ a F b`

### Destructuring

The left hand side of assignment in a subject expression can be *compound*, so that assigned values are extracted from lists or namespaces. This is called a *destructuring* assignment. The most common case is list destructuring: the left hand side's written as a list, and the value on the right has to be a list of the same length. Assignments are made element-wise, and the elements can destructure things further.

        ⟨q‿r,s⟩ ← ⟨"qr",↕4⟩

        r

        s

Namespace destructuring uses an overlapping syntax, fully described in [its own section](namespace.md#imports). The left hand side is a list of names or aliases `to⇐from`.

        q‿r ↩ {q⇐2+r⇐0.5} ⋄ q

With destructuring, you might want to discard some values from the right hand side rather than assign them any name. There's special syntax for this: use Nothing (`·`) for a placeholder non-name in the appropriate position, like `·‿y‿· ← list`.

        · ← 6   # Doesn't do anything

### Exports

The double arrow `⇐` is used to export variables from a block or program, causing the result to be a [namespace](namespace.md). There are two ways to export variables. First, `←` in the variable definition can be replaced with `⇐` to export the variable as it's defined. Second, an export statement consisting of an assignment target followed by `⇐` with nothing to the right exports the variables in the assignment target and does nothing else. Export statements can be placed anywhere in the relevant program or body, including before declaration or on the last line, and a given variable can be exported any number of times.

    ⟨alias⇐a, b, c0‿c1⇐c, b2⇐b⟩←{
      b‿c⇐   # Non-definition exports can go anywhere
      a⇐2    # Define and export
      b←1+a
      c←b‿"str"
    }

Fields of the resulting namespace can be accessed either directly using `namespace.field` syntax, or with a destructuring assignment as shown above. This assignment's target is a list where each element specifies one of the names exported by the block and what it should be assigned to. The element can be either a single name (such as `b` above), which gives both, or a combination of the assignment target, then `⇐`, then a name. If `⇐` is never used, the names can be given as a strand with `‿`. To use `⇐` for aliases, bracket syntax `⟨⟩` is needed. Imported names can be repeated and can be spelled with any role (the role is ignored).
