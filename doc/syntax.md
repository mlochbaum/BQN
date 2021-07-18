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
`()`            | Expression grouping
`←`             | [Define](#assignment)
`⇐`             | [Export](#exports)
`↩`             | [Change](#assignment)
`→`             | [Return](block.md#returns)
`⋄,` or newline | Statement or element [separator](#separators)
`⟨⟩`            | [List](#list-notation) (rank-1 array)
`‿`             | [Strand](#list-notation) (lightweight list syntax)
`{}`            | [Block](#blocks) such as a function definition
`:`             | [Block header](block.md#block-headers)
`;`             | [Block body separator](block.md#multiple-bodies)
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

*[More discussion](context.md)*

Like APL, BQN uses four *syntactic roles* for values in expressions:
* **Subjects**, like APL arrays or J nouns
* **Functions**, or verbs in J
* **1-Modifiers**, like APL monadic operators or J adverbs
* **2-Modifiers**, like APL dyadic operators or J conjunctions.

These roles work exactly like they do in APL, with functions applying to one or two subject arguments, 1-modifiers taking a single function or subject on the left, and 2-modifiers taking a function or subject on each side.

Unlike APL, in BQN the syntactic role of an identifier is determined purely by the way it's spelled: a lowercase first letter (`name`) makes it a subject, an uppercase first letter (`Name`) makes it a function, and underscores are used for 1-modifiers (`_name`) and 2-modifiers (`_name_`). Below, the function `{𝕎𝕩}` treats its left argument `𝕎` as a function and its right argument `𝕩` as a subject. With a list of functions, we can make a table of the square and square root of a few numbers:

        ⟨×˜,√⟩ {𝕎𝕩}⌜ 1‿4‿9

BQN's built-in operations also have patterns to indicate the syntactic role: 1-modifiers (`` ˜¨˘⁼⌜´` ``) are all superscript characters, and 2-modifiers (`∘○⊸⟜⌾⊘◶⚇⎉⍟`) all have an unbroken circle (two functions `⌽⍉` have broken circles with lines through them). Every other built-in constant is a function, although the special symbols `¯`, `∞`, and `π` are used as part of numeric literal notation.

### Assignment

Another element that can be included in expressions is assignment, which is written with `←` to *define* (also called "declare" in many other languages) a variable and `↩` to *change* its definition. A variable can only be defined once within a scope, and can only be changed if it has already been defined. However, it can be shadowed, meaning that it is defined again in an inner scope even though it has a definition in an outer scope already.

        x←1 ⋄ {x←2 ⋄ x↩3 ⋄ x}
        x

Assignment can be used inline in an expression, and its result is always the value being assigned. The role of the identifier used must match the value being assigned.

        2×a←(Neg←-)3
        a

### Exports

The double arrow `⇐` is used to export variables from a block or program, causing the result to be a [namespace](namespace.md). There are two ways to export variables. First, `←` in the variable definition can be replaced with `⇐` to export the variable as it's defined. Second, an export statement consisting of an assignment target followed by `⇐` with nothing to the right exports the variables in the assignment target and does nothing else. Export statements can be placed anywhere in the relevant program or body, including before declaration or on the last line, and a given variable can be exported any number of times.

    ⟨alias⇐a, b, c0‿c1⇐c, b2⇐b⟩←{
      b‿c⇐   # Non-definition exports can go anywhere
      a⇐2    # Define and export
      b←1+a
      c←b‿"str"
    }

Fields of the resulting namespace can be accessed either directly using `namespace.field` syntax, or with a destructuring assignment as shown above. This assignment's target is a list where each element specifies one of the names exported by the block and what it should be assigned to. The element can be either a single name (such as `b` above), which gives both, or a combination of the assignment target, then `⇐`, then a name. If `⇐` is never used, the names can be given as a strand with `‿`. To use `⇐` for aliases, bracket syntax `⟨⟩` is needed. Imported names can be repeated and can be spelled with any role (the role is ignored).

## Lists and blocks

### Separators

The characters `⋄` and `,` and newline are completely interchangeable and are used to separate expressions. An expression might be an element in a list or a line in a function. Empty sections—those that consist only of whitespace—are ignored. This means that any number of separators can be used between expressions, and that leading and trailing separators are also allowed. The expressions are evaluated in text order: left to right and top to bottom.

### List notation

Lists (1-dimensional arrays) are enclosed in angle brackets `⟨⟩`, with the results of the expressions in between being the list's elements. Lists of two elements or more can also be written with the ligature character `‿`. This character has higher binding strength than any part of an expression. If one of the elements is a compound expression, then it will need to be enclosed in parentheses.

### Blocks

*[Full documentation](block.md)*

Blocks are written with curly braces `{}` and can be used to group expressions or define functions and modifiers. The contents are simply a sequence of expressions, where each is evaluated and the result of the last is returned in order to evaluate the block. This result can have any value, and its syntactic role in the calling context is determined by the normal rules: functions return subjects and modifiers return functions. Blocks have [lexical scope](lexical.md).

The special names `𝕨` and `𝕩`, which stand for arguments, and `𝕗` and `𝕘`, which stand for operands, are available inside curly braces. Like ordinary names, the lowercase forms indicate subjects and the uppercase forms `𝕎𝕏𝔽𝔾` indicate functions. The type and syntactic role of the block is determined by its contents: a 2-modifier contains `𝕘`, a 1-modifier contains `𝕗` but not `𝕘`, and a function contains neither but does have one of `𝕨𝕩𝕤𝕎𝕏𝕊`. If no special names are present the block is an *immediate block* and is evaluated as soon as it appears, with the result having a subject role.

A modifier can be evaluated twice: once when passed operands and again when the resulting function is passed arguments. If it contains `𝕨` or `𝕩`, the first evaluation simply remembers the operands, and the contents will be executed only on the second evaluation, when the arguments are available. If it doesn't contain these, then the contents are executed on the first evaluation and the result is treated as a function.
