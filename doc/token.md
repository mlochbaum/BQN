*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/token.html).*

# Tokens

A "token" is the smallest part of syntax, much like a word in English. BQN's rules for forming tokens are simpler than most programming languages, because most of them are single characters. There are only a few kinds of multi-character tokens: character and string literals written with `'` and `"`, and words which are numbers, names, or system values.

Strings (and characters) and comments have starting and ending conditions, but can't overlap. The first one that starts first "wins": it needs to end before any other token or comment can start. These also take precedence over other token rules, that is, characters inside a string or comment don't form other tokens.

## Non-tokens

Comments, and the horizontal whitespace characters space and tab, don't form tokens, since they don't do anything as far as the program's concerned. However, whitespace can be used to separate adjacent words or strings. Comments can only end with a newline, which doesn't need separating, so they _really_ don't do anything, other than inform the reader about whatever you have to say. Note that newline characters (either LF or CR) are [separators](#separators), which are tokens.

### Comments

A comment starts with a `#` that isn't part of a character or string literal, and continues to the end of the line.

        '#' - 1  #This is the comment

Every line of commentary needs its own `#`; there's no multi-line comment syntax.

## Characters and strings

Strings—lists of characters—are written with double quotes `""`, and [characters](types.md#characters) with single quotes `''` with a single character in between. Only one character ever needs to be escaped: a double quote in a string is written twice. So `""""` is a one-character string of `"`, and if two string literals are next to each other, they have to be separated by a space. Character literals don't have even one escape, as the length is already known. Other than the double quote, character and string literals can contain any character directly: newlines, null characters, or other Unicode.

        ≠¨ ⟨ "str" ⋄ "s't""r" ⋄ 'c' ⋄ ''' ⋄ '"' ⟩   # "" is an escape

        ≡¨ ⟨ "a" ⋄ 'a' ⟩   # A string is an array but a character isn't

But including a null character in your source code is probably not a great idea for other reasons. The null character (code point 0) has a dedicated literal representation `@`. Null can be used with [character arithmetic](arithmetic.md#character-arithmetic) to directly convert between characters and numeric code points, which among many other uses allows tricky characters to be entered by code point: for example, a non-breaking space is `@+160`.

## Words

Numbers and variable names share a token formation rule, and are collectively called words. A word is a number if it starts with a digit or numeric character `¯∞π`, and a name otherwise.

Words are formed from digits, letters, and the characters `_.¯∞π`. All these characters stick together, so that you need to separate words with whitespace in order to write them next to each other. But `.` only counts if it's followed by a digit: otherwise it forms its own token to support [namespace syntax](namespace.md#imports) `ns.field`. A word may be preceded by `•` to form a system name.

The character `𝕣` also sticks with other word-forming characters, but is only allowed form the special names `𝕣`, `_𝕣`, and `_𝕣_`.

### Numbers

[Numbers](types.md#numbers) are written as decimals, allowing `¯` for the negative sign (because `-` is a function) and `e` or `E` for scientific notation. They must have digits before and after the decimal point (so, `0.5` instead of `.5`), and any exponent must be an integer. Two special numbers `∞` and `π` are supported, possibly with a minus sign. If complex numbers are supported (no implementation to date has them), then they can be written with the components separated by `i` or `I`.

        ⟨ ¯π ⋄ 0.5 ⋄ 5e¯1 ⋄ 1.5E3 ⋄ ∞ ⟩   # A list of numbers

### Names

A variable name starts with a letter but otherwise can contain anything, including characters like `∞` and `¯`. Names represent identifiers according to the rules of [lexical scoping](lexical.md). A somewhat unusual feature of BQN is that identifiers are case- and underscore-insensitive, so that `abc` is treated as the same name as `_a_B_c`. This works with the [role spelling](expression.md#role-spellings) system so that changing the case or adding underscores allows the same variable to be used in different roles.

The system dot `•` can only start a word, and must be followed by a name. This accesses a system value such as the debugging display function `•Show`.

## Separators

The characters `⋄` and `,` and newline are completely interchangeable and are used to separate expressions. An expression might be an element in a list or a line in a block. Empty sections—those that consist only of whitespace—are ignored. This means that any number of separators can be used between expressions, and that leading and trailing separators are also allowed. The expressions are evaluated in text order: left to right and top to bottom.

Both LF and CR are allowed as newline characters, and CRLF functions as a separator too because of the way multiple separators work.
