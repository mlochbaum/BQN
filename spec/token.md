*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/token.html).*

# Specification: BQN token formation

This page describes BQN's token formation rules (token formation is also called scanning). Most tokens in BQN are a single character long, but quoted characters and strings, identifiers, and numbers can consist of multiple characters, and comments, spaces, and tabs are discarded during token formation.

BQN source code should be considered as a series of unicode code points, which we refer to as "characters". The separator between lines in a file is considered to be a single character, newline, even though some operating systems such as Windows typically represent it with a two-character CRLF sequence. Implementers should note that not all languages treat unicode code points as atomic, as exposing the UTF-8 or UTF-16 representation instead is common. For a language such as JavaScript that uses UTF-16, the double-struck characters `𝕨𝕎𝕩𝕏𝕗𝔽𝕘𝔾` are represented as two 16-bit surrogate characters, but BQN treats them as a single unit.

A BQN *character literal* consists of a single character between single quotes, such as `'a'`, and a *string literal* consists of any number of characters between double quotes, such as `""` or `"abc"`. Character and string literals take precedence with comments over other tokenization rules, so that `#` between quotes does not start a comment and whitespace between quotes is not removed, but a quote within a comment does not start a character literal. Almost any character can be included directly in a character or string literal without escaping. The only exception is the double quote character `"`, which must be written twice to include it in a string, as otherwise it would end the string instead. Character literals require no escaping at all, as the length is fixed. In particular, literals for the double and single quote characters are written `'''` and `'"'`, while length-1 strings containing these characters are `"'"` and `""""`.

A comment consists of the hash character `#` and any following text until (not including) the next newline character. The initial `#` must not be part of a string literal started earlier. Comments are ignored entirely and do not form tokens.

Identifiers and numeric literals share the same token formation rule. These tokens are formed from the *numeric characters* `¯∞π0123456789` and *alphabetic characters* `_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ` and the oddball `𝕣`. Additionally, `.` is considered a numeric character if it is followed immediately by a digit (`0123456789`); otherwise it forms its own token. Any sequence of these characters adjacent to each other forms a single token, which is a *numeric literal* if it begins with a numeric character and an *identifier* if it begins with an alphabetic character. If a token begins with an underscore then its first non-underscore character must be alphabetic: for example, `_99` is not a valid token. Numeric literals are also subject to [numeric literal rules](literal.md), which specify which numeric literals are valid and which numbers they represent. If the token contains `𝕣` it must be either `𝕣`, `_𝕣`, or `_𝕣_` and is considered a special name (see below). As the value taken by this identifier can only be a modifier, the uppercase character `ℝ` is not allowed.

The *system dot* `•` always attaches to the token containing the next character, which must not be a whitespace character, `#`, or `•`. This combined token is valid only if its name matches a defined [system value](system.md), ignoring underscores and letter case as with identifiers (but in the unlikely case that system values with numeric names are defined, they need not follow the numeric literal rules). Its role is the same as the role the remainder of the token would have if not preceded by `•`, and it is considered a literal for grammar purposes.

Following these steps, the whitespace characters space and tab are ignored, and do not form tokens. Only these whitespace characters, and the newline character, which does form a token, are allowed.

Otherwise, a single character forms a token. Only the specified set of characters can be used; others result in an error. The classes of characters are given below.

| Class                 | Characters
|-----------------------|------------
| Null literal          | `@`
| Primitive Function    | `+-×÷⋆√⌊⌈\|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!`
| Primitive 1-Modifier  | `` ˙˜˘¨⌜⁼´˝` ``
| Primitive 2-Modifier  | `∘○⊸⟜⌾⊘◶⎉⚇⍟⎊`
| Special name          | `𝕨𝕩𝕗𝕘𝕤𝕎𝕏𝔽𝔾𝕊`
| Punctuation           | `←⇐↩→(){}⟨⟩‿⋄,.` and newline

In the BQN [grammar specification](grammar.md), the three primitive classes are grouped into terminals `Fl`, `_ml`, and `_cl`, while the punctuation characters are identified separately as keywords such as `"←"`. The special names are handled specially. The uppercase versions `𝕎𝕏𝔽𝔾𝕊` and lowercase versions `𝕨𝕩𝕗𝕘𝕤` are two spellings of the five underlying inputs and function.
