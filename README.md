# BQN: finally, an APL for your flying saucer

*This repository does not yet have a working implementation. You can try a prototype implementation [online here](https://mlochbaum.github.io/BQN2NGN/web/index.html) (from [this repository](https://github.com/mlochbaum/BQN2NGN))*

**BQN** is a new programming language in the APL lineage, which aims to remove inconsistent and burdensome aspects of the APL tradition and put the great ideas on a firmer footing. BQN is aimed at existing and aspiring APL-family programmers, and using it requires a solid understanding of functions and multidimensional arrays.

BQN maintains many of the ideas that made APL\360 revolutionary in 1966:
* Human-friendly **infix notation** with no precedence rules to remember.
* **Built-in array operations** handle any number of dimensions easily.
* **Higher-order functions** allow basic functions to be applied in more powerful ways.

It incorporates concepts developed over years of APL practice:
* The **leading axis model**, which allows for simpler built-in functions.
* Trains and combinators for **tacit programming**.
* Lightweight **anonymous functions** (like [dfns](https://aplwiki.com/wiki/Dfn)).

But BQN is redesigned from the ground up, with brand new ideas to make these paradigms easier to use and less likely to fail.
* The **based array model** makes non-arrays a fundamental part of the language, and removes the surprise of floating arrays and the hassle of explicit boxes. New **array notation** eliminates the gotchas of [stranding](https://aplwiki.com/wiki/Strand_notation).
* A **context-free grammar** where a value's syntactic role is determined by its spelling makes it easier for machines and humans to understand code.
* Oh, and it naturally leads to **first-class functions**, a feature often missed in APL.
* The **new symbols** for built-in functionality allow the syntactic role of a primitive to be distinguished at a glance, and aim to be more consistent and intuitive.

## What kind of name is "BQN"?

It's three letters, that happen to match the capitals in "Big Questions Notation". You can pronounce it "bacon", but are advised to avoid this unless there's puns.

## What does BQN look like?

It looks like qebrus okay:

    ⊑+`∘⌽⍟12↕2  ⍝ The 12th Fibonacci number

[More examples here](https://github.com/mlochbaum/BQN2NGN/tree/master/examples).

## Array model

Most of BQN's functionality deals with the manipulation of multidimensional arrays. However, it discards many of the complications of traditional APL [array models](https://aplwiki.com/wiki/Array_model). Unlike in APL, non-array data is possible, and common: numbers, characters, and sets are not arrays (see the full list of [types](#data-types) below). This avoids some difficulties that show up when trying to treat scalar arrays as the fundamental unit; in particular, there is no "floating" so a value is always different from a scalar array that contains it. This system has been [proposed](https://dl.acm.org/doi/abs/10.1145/586656.586663) in APL's past under the name **based array theory**.

Currently, the intention is that arrays will not have prototypes, so that all empty arrays of the same shape behave identically. Different elements of an array should not influence each other. While some APLs force numbers placed in the same array to a common representation, which may have different precision properties, BQN will enforce 64-bit floating-point precision, and only use representations or methods compatible with it (for example, integers up to 32 bits).

## Syntax

BQN syntax consists of expressions where computation is done with a little organizing structure around them like assignment, functions, and list notation. Expressions are where the programmer is in control so the design tries to do as much as possible with them before introducing special syntax.

### Expressions

Like APL, BQN values have one of four *syntactic classes*:
* **Values**, like APL arrays or J nouns
* **Functions**, or verbs in J
* **Modifiers**, like APL monadic operators or J adverbs
* **Compositions**, like APL dyadic operators or J conjunctions.

These classes work exactly like they do in APL, with functions applying to one or two arguments, modifiers taking a single function or value on the left, and compositions taking a function or value on each side.

Unlike APL, in BQN the syntactic class of a value is determined purely by the way it's spelled: a lowercase first letter (`name`) makes it a value, an uppercase first letter (`Name`) makes it a function, and underscores are used for modifiers (`_name`) and compositions (`_name_`). Below, the function `{𝕎𝕩}` treats its left argument `𝕎` as a function and its right argument `𝕩` as an argument. With a list of functions, we can make a table of the square and square root of a few numbers:

        ⟨×˜,√⟩ {𝕎𝕩}⌜ 1‿4‿9
    ┌
      1 16 81
      1  2  3
              ┘

BQN's built-in operations also have patterns to indicate the syntactic class: modifiers (`` ˜¨˘⁼⌜´` ``) are all superscript characters, and compositions (`∘○⊸⟜⌾⚇⎉⍟`) all have an unbroken circle (two functions `⌽⍉` have broken circles with lines through them). Every other built-in constant is a function, although the special symbols `¯`, `∞`, and `π` are used as part of numeric literal notation.

### Special syntax

Most of these glyphs are explained further in the section on [literal notation](#literal-notation).

Glyph(s)        | Meaning
----------------|-----------
`←`             | Define
`↩`             | Modify
`→`             | Return
`⋄,` or newline | Statement or element separator
`()`            | Expression grouping
`{}`            | Explicit function, modifier, or composition
`⟨⟩`            | List/vector
`:`             | Key/value separator for dictionaries
`‿`             | Strand (lightweight vector syntax)
`⦃⦄`            | Set
`𝕨𝕎`            | Left argument
`𝕩𝕏`            | Right argument
`𝕗𝔽`            | Left operand (modifier or composition)
`𝕘𝔾`            | Right operand (composition)
`⍝`             | Comment

## Built-in operations

### Functions

| Glyph | Monadic          | Dyadic
|-------|------------------|---------
| `+`   | Conjugate        | Add
| `-`   | Negate           | Subtract
| `×`   | Signum           | Multiply
| `÷`   | Reciprocal       | Divide
| `⋆`   | Exponential      | Power
| `√`   | Square Root      | Root
| `⌊`   | Floor            | Min
| `⌈`   | Ceiling          | Max
| `∧`   | Sort Up          | And
| `∨`   | Sort Down        | Or
| `¬`   | Not              | Span
| `\|`  | Absolute Value   | Modulus
| `=`   |                  | Equals
| `≠`   | Count            | Not Equals
| `≤`   |                  | Less Than or Equal to
| `<`   | Box              | Less Than
| `>`   | Unbox            | Greater Than
| `≥`   |                  | Greater Than or Equal to
| `≡`   | Depth            | Match
| `≢`   | Shape            | Not Match
| `⊣`   | Identity         | Left
| `⊢`   | Identity         | Right
| `⥊`   | Deshape          | Reshape
| `∾`   | [Join](doc/join.md) | Join to
| `≍`   | Solo             | Couple
| `↑`   | Prefixes         | Take
| `↓`   | Suffixes         | Drop
| `↕`   | Range            | Windows
| `⌽`   | Reverse          | Rotate
| `⍉`   | [Transpose](doc/transpose.md) | Reorder axes
| `/`   | Indices          | Replicate
| `⍋`   | Grade Up         | Bins Up
| `⍒`   | Grade Down       | Bins Down
| `⊏`   | First Cell       | Select
| `⊑`   | First            | Pick
| `⊐`   |                  | Index of
| `⊒`   | Occurrence Count | Progressive Index of
| `∊`   | Unique Mask      | Member of
| `⍷`   |                  | Find
| `⊔`   | Group Indices    | [Group](doc/group.md)

### Modifiers and compositions

*Combinators* only control the application of functions. Because a non-function operand applies as a constant function, some combinators have extra meanings when passed a constant. For example, `0˜` is the constant function that always returns 0 and `0⊸<` is the function that tests whether its right argument is greater than 0.

Glyph | Name(s)     | Definition                     | Description
------|-------------|--------------------------------|---------------------------------------
`˜`   | Self/Swap   | `{𝕩𝔽𝕨⊣𝕩}`                      | Duplicate one argument or exchange two
`∘`   | Atop        | `{𝔽𝕨𝔾𝕩}`                       | Apply `𝔾` to both arguments and `𝔽` to the result
`○`   | Over        | `{(𝔾𝕨)𝔽𝔾𝕩}`                    | Apply `𝔾` to each argument and `𝔽` to the results
`⊸`   | Before/Bind | `{(𝔽𝕨)𝔾𝕩}˜˜`                   | `𝔾`'s left argument comes from `𝔽`
`⟜`   | After/Bind  | `{𝕨𝔽𝔾𝕩}˜˜`                     | `𝔽`'s right argument comes from `𝔾`
`⌾`   | Under       | `{𝔾⁼∘𝔽○𝔾}` OR `{(𝔾𝕩)↩𝕨𝔽○𝔾𝕩⋄𝕩}` | Apply `𝔽` over `𝔾`, then undo `𝔾`

Under is not a true combinator since it has an "undo" step at the end. This step might be implemented using the left operand's inverse (*computational* Under) or its structural properties (*structural* Under).

Other modifiers and compositions control array traversal and iteration. In three cases a simpler modifier is paired with a generalized composition: in each case the modifier happens to be the same as the composition with a right operand of `¯1`.

Modifier | Name    | Compositon | Name
---------|---------|------------|--------
`˘`      | Cells   | `⎉`        | Rank
`¨`      | Each    | `⚇`        | Depth
`⌜`      | Table   |
`⁼`      | Inverse | `⍟`        | Iterate
`´`      | Reduce  |
`` ` ``  | Scan    |

## Literal notation

### Constant notation

BQN has single-token notation for numbers, strings, and characters.

Numbers allow the typical decimal notation with `¯` for the negative sign (because `-` is a function) and `e` for scientific notation (or `E`, as numeric notation is case-insensitive). `∞` and `π` may be used as special numeric values. Complex numbers are also allowed, with the components separated by `i`.

Strings are written with double quotes `""`, and characters with single quotes `''` with a single character in between. A double quote within a string can be escaped by writing it twice. If two string or two character literals are next to each other, they must be separated by a space.

### Separators

The characters `⋄` and `,` and newline are completely interchangeable and are used to separate expressions. An expression might be an element in a list or set, or a line in a function. Empty sections—those that consist only of whitespace—are ignored. This means that any number of separators can be used between expressions, and that leading and trailing separators are also allowed. The expressions are evaluated in text order: left to right and top to bottom.

### List, set, and dictionary notation

Lists (1-dimensional arrays) are enclosed in angle brackets `⟨⟩`, with the results of the expressions in between being the list's elements. Lists of two elements or more can also be written with the ligature character `‿`. This character has higher binding strength than any part of an expression. If one of the elements is a compound expression, then it will need to be enclosed in parentheses.

Sets share the same notation with the angle brackets changed to double-struck curly brackets `⦃⦄` and no ligature notation.

Dictionaries use angle brackets `⟨⟩` like lists, but instead of expressions there are pairs of expressions separated by `:`. The first expression evaluates to the key and the second to the corresponding value. The empty dictionary is written `⟨:⟩`.

### Explicit functions

Functions, modifiers, and combinators can be defined using curly braces `{}`. The contents are simply a sequence of expressions, where each is evaluated and the result of the last is returned. This result can have any value, and its syntactic class in the calling context is determined by the normal rules: functions return values and modifiers and compositions return functions. Operations defined in this way have lexical scope.

The special values `𝕨` and `𝕩`, which stand for arguments, and `𝕗` and `𝕘`, which stand for operands, are available inside curly braces. Like ordinary names, the lowercase forms indicate values and the uppercase forms `𝕎𝕏𝔽𝔾` indicate functions. The type (including syntactic class) of the result is determined by its contents: a composition contains `𝕘`, a modifier contains `𝕗` but not `𝕘`, and a function contains neither.

A modifier or composition can be evaluated twice: once when passed operands and again when the resulting function is passed arguments. If it contains `𝕨` or `𝕩`, the first evaluation simply remembers the operands, and the contents will be executed only on the second evaluation, when the arguments are available. If it doesn't contain these, then the contents are executed on the first evaluation and the result is treated as a function.

## Data types

BQN will support the following fundamental types:
- Numbers (complex with 64-bit float precision)
- Characters (Unicode code points)
- Arrays
- Sets
- Dictionaries
- Function
- Modifier
- Composition

All of the above types are immutable. Other types may be added in the future, such as symbols and namespaces.
