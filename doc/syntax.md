*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/syntax.html).*

# Syntax overview

BQN syntax consists of expressions where computation is done with a little organizing structure around them like assignment, functions, and list notation. Expressions are where the programmer is in control so the design tries to do as much as possible with them before introducing special syntax.

## Special glyphs

The following glyphs are used for BQN syntax. [Primitives](primitive.md) (built-in functions and modifiers) are not listed in this table, and have their own page. Digits, characters, and the underscore `_` are used for numbers, and identifiers or variable names.

Glyph(s)        | Meaning
----------------|-----------
`#`             | [Comment](#comments)
`'"`            | [Character or string literal](#constants)
`@`             | [Null character](#constants)
`¯∞π`           | [Used in numeric literals](#constants)
`·`             | [Nothing](expression.md#nothing)
`()`            | Expression grouping
`←`             | [Define](expression.md#assignment)
`⇐`             | [Export](expression.md#exports)
`↩`             | [Change](expression.md#assignment)
`⋄,` or newline | Statement or element [separator](#separators)
`⟨⟩`            | [List](#list-notation) (rank-1 array)
`‿`             | [Strand](#list-notation) (lightweight list syntax)
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

A comment starts with `#` that is not part of a string and continues to the end of the line.

## Constants

BQN has single-token notation for numbers, strings, and characters.

Numbers allow the typical decimal notation with `¯` for the negative sign (because `-` is a function) and `e` for scientific notation (or `E`, as numeric notation is case-insensitive). `∞` and `π` may be used as special numeric values. If complex numbers are supported, then they can be written with the components separated by `i`. However, no BQN to date supports complex numbers.

        ⟨ ¯π ⋄ 0.5 ⋄ 5e¯1 ⋄ 1.5E3 ⋄ ∞ ⟩   # A list of numbers

Strings are written with double quotes `""`, and characters with single quotes `''` with a single character in between. A double quote within a string can be escaped by writing it twice; if two string literals are next to each other, they must be separated by a space. In contrast, character literals do not use escapes, as the length is already known.

        ≠¨ ⟨ "str" ⋄ "s't""r" ⋄ 'c' ⋄ ''' ⋄ '"' ⟩   # "" is an escape

        ≡¨ ⟨ "a" ⋄ 'a' ⟩   # A string is an array but a character isn't

The null character (code point 0) has a dedicated literal representation `@`. This character can be used to directly convert between characters and numeric code points, which among many other uses allows tricky characters to be entered by code point: for example, a non-breaking space is `@+160`. The character can also be entered as a character literal, but this will display differently in various editors and some tools may have trouble with a file directly containing a null, so it is best to use `@` instead.

## Expressions

*[Full documentation](expression.md)*

BQN expressions are composed of subjects, functions, and modifiers, with parentheses to group parts into subexpressions. Functions can be applied to subjects or grouped into trains, while modifiers can be applied to subjects or functions. The most important kinds of application are:

| example | left  | main  | right | output     | name       | binding
|---------|-------|-------|-------|------------|------------|---------
| `↕ 10`  |  `w?` |  `F`  |  `x`  | Subject    | Function   | RtL, looser
| `+ ⋈ -` |  `F?` |  `G`  |  `H`  | Function   | Train      |
| `×´`    |  `F`  | `_m`  |       | Function   | 1-Modifier | LtR, tighter
| `2⊸\|`  |  `F`  | `_c_` |  `G`  | Function   | 2-Modifier |

The four roles (subject, function, two kinds of modifier) describe expressions, not values. When an expression is evaluated, the value's [type](types.md) doesn't have to correspond to its role, and can even change from one evaluation to another. An expression's role is determined entirely by its source code, so it's fixed.

Assignment arrows `←`, `↩`, and `⇐` store expression results in variables: `←` and `⇐` create new variables while `↩` modifies existing ones. The general format is `Name ← Value`, where the two sides have the same role. Additionally, `lhs F↩ rhs` is a shortened form of `lhs ↩ lhs F rhs` and `lhs F↩` expands to `lhs ↩ F lhs`.

The double arrow `⇐` is used for functionality relating to [namespaces](namespace.md). It has a few purposes: exporting assignment `name⇐value`, plain export `name⇐`, and aliasing `⟨alias⇐field⟩←namespace`. A block that uses it for export returns a namespace rather than the result of its last statement.

## Lists and blocks

### Separators

The characters `⋄` and `,` and newline are completely interchangeable and are used to separate expressions. An expression might be an element in a list or a line in a function. Empty sections—those that consist only of whitespace—are ignored. This means that any number of separators can be used between expressions, and that leading and trailing separators are also allowed. The expressions are evaluated in text order: left to right and top to bottom.

### List notation

*[Full documentation](arrayrepr.md#list-literals)*

Lists (1-dimensional arrays) are enclosed in angle brackets `⟨⟩`, with the results of the expressions in between being the list's elements. Lists of two elements or more can also be written with the ligature character `‿`. This character has higher binding strength than any part of an expression. If one of the elements is a compound expression, then it will need to be enclosed in parentheses.

### Blocks

*[Full documentation](block.md)*

Blocks are written with curly braces `{}` and can be used to group expressions or define functions and modifiers. The contents are simply a sequence of expressions, where each is evaluated and the result of the last is returned in order to evaluate the block. This result can have any value, and its syntactic role in the calling context is determined by the normal rules: functions return subjects and modifiers return functions. Blocks have [lexical scope](lexical.md).

The special names `𝕨` and `𝕩`, which stand for arguments, and `𝕗` and `𝕘`, which stand for operands, are available inside curly braces. Like ordinary names, the lowercase forms indicate subjects and the uppercase forms `𝕎𝕏𝔽𝔾` indicate functions. The type and syntactic role of the block is determined by its contents: a 2-modifier contains `𝕘`, a 1-modifier contains `𝕗` but not `𝕘`, and a function contains neither but does have one of `𝕨𝕩𝕤𝕎𝕏𝕊`. If no special names are present the block is an *immediate block* and is evaluated as soon as it appears, with the result having a subject role.

A modifier can be evaluated twice: once when passed operands and again when the resulting function is passed arguments. If it contains `𝕨` or `𝕩`, the first evaluation simply remembers the operands, and the contents will be executed only on the second evaluation, when the arguments are available. If it doesn't contain these, then the contents are executed on the first evaluation and the result is treated as a function.
