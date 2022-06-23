*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/syntax.html).*

# Syntax overview

BQN syntax consists of expressions where computation is done, with a little organizing structure around them like assignment, functions, and list notation. Expressions are where the programmer is in control, so the design tries to do as much as possible with them before introducing special syntax.

## Special glyphs

The following glyphs are used for BQN syntax. [Primitives](primitive.md) (built-in functions and modifiers) are not listed in this table, and have their own page. Digits, characters, and the underscore `_` are used for numbers and variable names.

Glyph(s)        | Meaning
----------------|-----------
`#`             | [Comment](#comments)
`'"`            | [Character or string literal](#constants)
`@`             | [Null character](#constants)
`¯∞π`           | [Used in numeric literals](#constants)
`·`             | [Nothing](expression.md#nothing)
`()`            | [Expression grouping](expression.md#parentheses)
`←`             | [Define](expression.md#assignment)
`⇐`             | [Export](expression.md#exports)
`↩`             | [Change](expression.md#assignment)
`⋄,` or newline | Statement or element [separator](#separators)
`⟨⟩`            | [List](#list-and-array-notation)
`[]`            | [Array](#list-and-array-notation)
`‿`             | [Strand](#list-and-array-notation) (lightweight list syntax)
`{}`            | [Block](#blocks) such as a function definition
`:`             | [Block header](block.md#block-headers)
`;`             | [Block body separator](block.md#multiple-bodies)
`?`             | [Predicate](block.md#predicates)
`𝕨𝕎`            | [Left argument](#blocks)
`𝕩𝕏`            | [Right argument](#blocks)
`𝕤𝕊`            | [Function self-reference](#blocks)
`𝕗𝔽`            | [Left operand of a modifier](#blocks)
`𝕘𝔾`            | [Right operand of a 2-modifier](#blocks)
`𝕣`             | [Modifier self-reference](#blocks)

## Comments

A comment starts with a `#` that isn't part of a character or string literal, and continues to the end of the line.

        '#' - 1  #This is the comment

## Constants

BQN has single-token notation for numbers, strings, and characters.

[Numbers](types.md#numbers) are written as decimals, allowing `¯` for the negative sign (because `-` is a function) and `e` or `E` for scientific notation. They must have digits before and after the decimal point (so, `0.5` instead of `.5`), and any exponent must be an integer. Two special numbers `∞` and `π` are supported, possibly with a minus sign. If complex numbers are supported (no implementation to date has them), then they can be written with the components separated by `i` or `I`.

        ⟨ ¯π ⋄ 0.5 ⋄ 5e¯1 ⋄ 1.5E3 ⋄ ∞ ⟩   # A list of numbers

Strings—lists of characters—are written with double quotes `""`, and [characters](types.md#characters) with single quotes `''` with a single character in between. Only one character ever needs to be escaped: a double quote in a string is written twice. So `""""` is a one-character string of `"`, and if two string literals are next to each other, they have to be separated by a space. Character literals don't have even one escape, as the length is already known. Other than the double quote, character and string literals can contain anything: newlines, null characters, or any other Unicode.

        ≠¨ ⟨ "str" ⋄ "s't""r" ⋄ 'c' ⋄ ''' ⋄ '"' ⟩   # "" is an escape

        ≡¨ ⟨ "a" ⋄ 'a' ⟩   # A string is an array but a character isn't

But including a null character in your source code is probably not a great idea for other reasons. The null character (code point 0) has a dedicated literal representation `@`. Null can be used with [character arithmetic](arithmetic.md#character-arithmetic) to directly convert between characters and numeric code points, which among many other uses allows tricky characters to be entered by code point: for example, a non-breaking space is `@+160`.

## Expressions

*[Full documentation](expression.md)*

BQN expressions are composed of subjects, functions, and modifiers, with parentheses to group parts into subexpressions. [Functions](ops.md#functions) can be applied to subjects or grouped into [trains](train.md), while [modifiers](ops.md#modifiers) can be applied to subjects or functions. The most important kinds of application are:

| example | left  | main  | right | output     | name       | binding
|---------|-------|-------|-------|------------|------------|---------
| `↕ 10`  |  `w?` |  `F`  |  `x`  | Subject    | Function   | RtL, looser
| `+ ⋈ -` |  `F?` |  `G`  |  `H`  | Function   | Train      |
| `×´`    |  `F`  | `_m`  |       | Function   | 1-Modifier | LtR, tighter
| `2⊸\|`  |  `F`  | `_c_` |  `G`  | Function   | 2-Modifier |

The four [roles](expression.md#syntactic-role) (subject, function, two kinds of modifier) describe expressions, not values. When an expression is evaluated, the value's [type](types.md) doesn't have to correspond to its role, and can even change from one evaluation to another. An expression's role is determined entirely by its source code, so it's fixed.

[Assignment](expression.md#assignment) arrows `←`, `↩`, and `⇐` store expression results in variables: `←` and `⇐` create new variables while `↩` modifies existing ones. The general format is `Name ← Value`, where the two sides have the same role. Additionally, `lhs F↩ rhs` is a shortened form of `lhs ↩ lhs F rhs` and `lhs F↩` expands to `lhs ↩ F lhs`.

The double arrow `⇐` is used for functionality relating to [namespaces](namespace.md). It has a few purposes: exporting assignment `name⇐value`, plain export `name⇐`, and aliasing `⟨alias⇐field⟩←namespace`. A block that uses it for export returns a namespace rather than the result of its last statement. The other namespace-related bit of syntax is field access `ns.field`.

## Arrays and blocks

Arrays and code blocks can both be represented as sequences of expressions in source code. There are paired bracket representations, using `⟨⟩` for lists, `[]` for arrays, and `{}` for blocks, as well as a shortcut "stranding" notation using `‿` for lists.

### Separators

The characters `⋄` and `,` and newline are completely interchangeable and are used to separate expressions. An expression might be an element in a list or a line in a block. Empty sections—those that consist only of whitespace—are ignored. This means that any number of separators can be used between expressions, and that leading and trailing separators are also allowed. The expressions are evaluated in text order: left to right and top to bottom.

### List and array notation

*[Full documentation](arrayrepr.md#array-literals)*

Lists (1-dimensional arrays) are enclosed in angle brackets `⟨⟩`, with the results of the expressions in between being the list's elements. Lists of two elements or more can also be written with the ligature character `‿`. This character has higher binding strength than any part of an expression except `.` for namespace field access. If one of the elements is a compound expression, then it will need to be enclosed in parentheses.

Arrays, or at least non-empty ones with rank 1 or more, can be written with square brackets `[]`. These work just like angle brackets but [merge](couple.md#merge-and-array-theory) the elements so that they form cells of the result.

### Blocks

*[Full documentation](block.md)*

Blocks are written with curly braces `{}` and can have a subject, function, or modifier role. The contents are any number of bodies separated by `;`. Each body is a sequence of expressions to be evaluated in order, possibly with a header, followed by `:`, that sets the type and describes expected inputs. A body runs in its own environment according to the rules of [lexical scoping](lexical.md). The result is either a [namespace](namespace.md), if the body used `⇐`, or the result of the last expression.

The special names `𝕨` and `𝕩`, which stand for arguments, and `𝕗` and `𝕘`, which stand for operands, are available inside curly braces. Like ordinary names, the lowercase forms indicate subjects and the uppercase forms `𝕎𝕏𝔽𝔾` indicate functions. If it has no header, the type and syntactic role of the block is determined by its contents: a 2-modifier contains `𝕘`, a 1-modifier contains `𝕗` but not `𝕘`, and a function contains neither but does have one of `𝕨𝕩𝕤𝕎𝕏𝕊`. The last option is an immediate block, which has a subject role and runs as soon as it's encountered.
