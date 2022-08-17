*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/syntax.html).*

# Syntax overview

BQN syntax consists of expressions where computation is done, with a little organizing structure around them like assignment, functions, and list notation. Expressions are where the programmer is in control, so the design tries to do as much as possible with them before introducing special syntax.

A *program* is a unit of source code that's evaluated, such as a source file, or one line of REPL input (one run of the `bqn` executable often involves multiple programs). Like a [block](#blocks), it's a sequence of expressions to be evaluated in order. It has a result, which is used if the program was evaluated from BQN with `•BQN`, `•Import` or similar. An error might occur when a program is running; this ends execution unless it's [caught](assert.md#catch).

## Precedence

Here's a full table of precedence for BQN's glyphs (broader than "operator precedence", as an "operator" usually just corresponds to a function). Entries at the bottom make the biggest divisions in the program, while the ones further up are subdivisions.

| Level | Role                                  | Associativity | Characters       | Plus
|-------|---------------------------------------|---------------|------------------|-------
| High  | Brackets                              |               | `()⟨⟩{}[]`
|       | [Field access](namespace.md#imports)  | Left-to-right | `.`
|       | [Stranding](arrayrepr.md#strands)     | n-ary         | `‿`
|       | Modifier                              | Left-to-right | `∘⎉¨´`…          | `↩` in `Fn↩`
|       | Function                              | Right-to-left | `+↕⊔⍉`…          | `←↩⇐`
|       | [Separator](token.md#separators)      |               | `⋄,` and newline | `?`
|       | [Header](block.md#block-headers)      |               | `:`
| Low   | [Body](block.md#multiple-bodies)      |               | `;`

While all of BQN's grammar fits into this table somehow, it's not really the whole story because subexpressions including parentheses and blocks might behave like functions or modifiers. See [expressions](#expressions) and [blocks](#blocks).

## Special glyphs

The following glyphs are used for BQN syntax. [Primitives](primitive.md) (built-in functions and modifiers) are not listed in this table, and have their own page. Digits, characters, and the underscore `_` are used for numbers and variable names.

Glyph(s)        | Meaning
----------------|-----------
`#`             | [Comment](token.md#comments)
`'"`            | [Character or string literal](token.md#characters-and-strings)
`@`             | [Null character](token.md#characters-and-strings)
`¯∞π`           | [Used in numeric literals](token.md#numbers)
`·`             | [Nothing](expression.md#nothing)
`()`            | [Expression grouping](expression.md#parentheses)
`←`             | [Define](expression.md#assignment)
`⇐`             | [Export](namespace.md#exports)
`↩`             | [Change](expression.md#assignment)
`.`             | Namespace [field access](namespace.md#imports)
`⋄,` or newline | Statement or element [separator](token.md#separators)
`⟨⟩`            | [List](arrayrepr.md#brackets)
`[]`            | [Array](arrayrepr.md#high-rank-arrays)
`‿`             | [Strand](arrayrepr.md#strands) (lightweight list syntax)
`{}`            | [Block](#blocks) such as a function definition
`:`             | [Block header](block.md#block-headers)
`;`             | [Block body separator](block.md#multiple-bodies)
`?`             | [Predicate](block.md#predicates)
`𝕨𝕎`            | [Left argument](block.md#arguments)
`𝕩𝕏`            | [Right argument](block.md#arguments)
`𝕤𝕊`            | [Function self-reference](block.md#self-reference)
`𝕗𝔽`            | [Left operand of a modifier](block.md#operands)
`𝕘𝔾`            | [Right operand of a 2-modifier](block.md#operands)
`𝕣`             | [Modifier self-reference](block.md#self-reference)

## Tokens

*[Full documentation](token.md)*

BQN syntax is made up of tokens, which are mostly single characters. But there are a few exceptions:
- [Comments](token.md#comments) start with `#` and end at the end of the line.
- [Character literals](token.md#characters-and-strings) start and end with `'`, and have exactly one character in between.
- [String literals](token.md#characters-and-strings) start and end with `"`. Pairs of quotes `""` in between represent one quote character, and other characters (including `'`) represent themselves.
- [Numbers](token.md#numbers) support decimal (`.`) and scientific (`e`) notation, plus `π` and `∞`, and use `¯` for a minus sign.
- [Variable names](token.md#names) allow letters, underscores, and numeric characters. They're matched case-insensitively, with a [spelling system](expression.md#role-spellings) that determines role.

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

Arrays and code blocks can both be represented as sequences of expressions in source code. There are paired bracket representations, using `⟨⟩` for lists, `[]` for arrays, and `{}` for blocks, as well as a shortcut "stranding" notation using `‿` for lists. Elements within brackets are divided by [separators](token.md#separators): `,` or `⋄` or a line break.

### List and array notation

*[Full documentation](arrayrepr.md#array-literals)*

Lists (1-dimensional arrays) are enclosed in angle brackets `⟨⟩`, with the results of the expressions in between being the list's elements. Lists of two elements or more can also be written with the ligature character `‿`. This character has higher binding strength than any part of an expression except `.` for namespace field access. If one of the elements is a compound expression, then it will need to be enclosed in parentheses.

Arrays, or at least non-empty ones with rank 1 or more, can be written with square brackets `[]`. These work just like angle brackets but [merge](couple.md) the elements so that they form cells of the result.

### Blocks

*[Full documentation](block.md)*

Blocks are written with curly braces `{}` and can have a subject, function, or modifier role. The contents are any number of bodies separated by `;`. Each body is a sequence of expressions to be evaluated in order, possibly with a header, followed by `:`, that sets the type and describes expected inputs. A body runs in its own environment according to the rules of [lexical scoping](lexical.md). The result is either a [namespace](namespace.md), if the body used `⇐`, or the result of the last expression.

The special names `𝕨` and `𝕩`, which stand for arguments, and `𝕗` and `𝕘`, which stand for operands, are available inside curly braces. Like ordinary names, the lowercase forms indicate subjects and the uppercase forms `𝕎𝕏𝔽𝔾` indicate functions. If it has no header, the type and syntactic role of the block is determined by its contents: a 2-modifier contains `𝕘`, a 1-modifier contains `𝕗` but not `𝕘`, and a function contains neither but does have one of `𝕨𝕩𝕤𝕎𝕏𝕊`. The last option is an immediate block, which has a subject role and runs as soon as it's encountered.
