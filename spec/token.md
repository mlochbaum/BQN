*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/token.html).*

# Specification: BQN token formation

This page describes BQN's token formation rules (token formation is also called scanning). Most tokens in BQN are a single character long, but quoted characters and strings, identifiers, and numbers can consist of multiple characters, and comments, spaces, and tabs are discarded during token formation. Additionally, identifier, literal, and primitive tokens are assigned a syntactic role that determines how they are seen by the grammar. The case-insensitive matching of identifiers and special names is described in the [scoping rules](scope.md), not here.

BQN source code should be considered as a series of unicode code points, which we refer to as "characters". Implementers should note that not all languages treat unicode code points as atomic, as exposing the UTF-8 or UTF-16 representation instead is common. For a language such as JavaScript that uses UTF-16, the double-struck characters `𝕨𝕩𝕗𝕘𝕤𝕎𝕏𝔽𝔾𝕊𝕣` are represented as two 16-bit surrogate characters, but BQN treats them as a single unit. The line feed (LF) and carriage return (CR) characters are both considered newline characters.

A BQN *character literal* consists of a single character between single quotes, such as `'a'`, and a *string literal* consists of any number of characters between double quotes, such as `""` or `"abc"`. Character and string literals take precedence with comments over other tokenization rules, so that `#` between quotes does not start a comment and whitespace between quotes is not removed, but a quote within a comment does not start a character literal. Almost any character can be included directly in a character or string literal without escaping. The only exception is the double quote character `"`, which must be written twice to include it in a string, as otherwise it would end the string instead. Character literals require no escaping at all, as the length is fixed. In particular, literals for the double and single quote characters are written `'''` and `'"'`, while length-1 strings containing these characters are `"'"` and `""""`.

A *comment* consists of the hash character `#` and any following text until (not including) the next newline character. The initial `#` must not be part of a string literal started earlier. Comments are ignored entirely and do not form tokens.

Several *word tokens* including identifiers and numbers share a token formation rule. Word tokens are formed from the *numeric characters* `¯∞π0123456789`, *alphabetic characters* `_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`, and the oddball `𝕣`. Additionally, `.` is considered a numeric character if it is followed immediately by a digit (`0123456789`); otherwise it forms its own token. Any sequence of these characters adjacent to each other forms a single token, along with up to one *system dot* `•` immediately before. The combined token is a *system literal* if it begins with a system dot, a *numeric literal* if it begins with a numeric character and an *identifier* if it begins with an alphabetic character.

Some additional rules apply to word tokens:
- If a token begins with an underscore then its first non-underscore character must be alphabetic: for example, `_99` is not a valid token.
- Numeric literals must conform to the grammar given in the [numeric literal rules](literal.md).
- A system literal token is valid only if its name, excluding the leading `•`, matches a defined [system value](system.md), ignoring underscores and letter case as with identifiers.
- If any token contains `𝕣` it can only be `𝕣`, `_𝕣`, or `_𝕣_`, and is considered a special name (as the value taken by this identifier can only be a modifier, the uppercase character `ℝ` is not allowed).

After the steps to form the multi-character tokens described above, the whitespace characters space and tab are ignored, and do not form tokens. These characters and the newline characters, which do form tokens, are the only whitespace characters allowed.

Otherwise, a single character forms a token. Only the specified set of characters can be used; others result in an error. The classes of characters are given below.

| Class                 | Characters
|-----------------------|------------
| Null literal          | `@`
| Primitive Function    | `+-×÷⋆√⌊⌈\|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!`
| Primitive 1-Modifier  | `` ˙˜˘¨⌜⁼´˝` ``
| Primitive 2-Modifier  | `∘○⊸⟜⌾⊘◶⎉⚇⍟⎊`
| Special name          | `𝕨𝕩𝕗𝕘𝕤𝕎𝕏𝔽𝔾𝕊`
| Punctuation           | `←⇐↩(){}⟨⟩[]‿·⋄,.;:?` and newlines

## Syntactic role

Literal, primitive, and identifier tokens are assigned to terminals in the grammar according to their *syntactic role*. The four possible roles are subject, function, 1-modifier, and 2-modifier.

- Numeric literals, character literals including the null literal, and string literals have a subject role.
- Primitives have a function, 1-modifier, or 2-modifier role according to their class.
- A system literal has the same role it would have if it appeared without the `•`.
- An identifier token may have any role depending on its spelling, as defined below.

The role of an identifier token may depend on its first character, and on whether the last character is an underscore, as shown in the table below. If the identifier starts with a lowercase letter, it has a subject role, and if it starts with an uppercase letter, then it has a function role. If it starts with an underscore, the identifier is a modifier, specifically a 2-modifier if it ends with another underscore and a 1-modifier if not.

| First character              | Trailing underscore | Role
|------------------------------|---------------------|-----
| `abcdefghijklmnopqrstuvwxyz` | Any                 | Subject
| `ABCDEFGHIJKLMNOPQRSTUVWXYZ` | Any                 | Function
| `_`                          | No                  | 1-modifier
| `_`                          | Yes                 | 2-modifier

The special names `𝕨𝕩𝕗𝕘𝕤𝕣` my be considered to have a subject role, `𝕎𝕏𝔽𝔾𝕊` to have a function role, and `_𝕣` and `_𝕣_` to have 1-modifier and 2-modifier roles. However, special names are treated individually in the grammar specification rather than being grouped by role.
