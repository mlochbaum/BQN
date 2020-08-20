*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/index.html).*

# BQN: finally, an APL for your flying saucer

*Try it [here](https://mlochbaum.github.io/BQN/try.html)! The online version is mainly good for small programs currently; see [running.md](running.md) for more options.*

**BQN** is a new programming language in the APL lineage, which aims to remove inconsistent and burdensome aspects of the APL tradition and put the great ideas on a firmer footing. BQN is aimed at existing and aspiring APL-family programmers, and using it requires a solid understanding of functions and multidimensional arrays. However, because of its focus on providing simple, consistent, and powerful array operations, BQN should also be a good language for learning array programming and building stronger array intuition.

BQN maintains many of the ideas that made APL\360 revolutionary in 1966:
* Human-friendly **infix notation** with no precedence rules to remember.
* **Built-in array operations** handle any number of dimensions easily.
* **Higher-order functions** allow basic functions to be applied in more powerful ways.

It incorporates concepts developed over years of APL practice:
* The [**leading axis model**](doc/leading.md), which allows for simpler built-in functions.
* Trains and combinators for **tacit programming**.
* Lightweight **anonymous functions** (like [dfns](https://aplwiki.com/wiki/Dfn)).

But BQN is redesigned from the ground up, with brand new ideas to make these paradigms easier to use and less likely to fail.
* The **based array model** makes non-arrays a fundamental part of the language, and removes the surprise of floating arrays and the hassle of explicit boxes. New **array notation** eliminates the gotchas of [stranding](https://aplwiki.com/wiki/Strand_notation).
* A [**context-free grammar**](doc/context.md) where a value's syntactic role is determined by its spelling makes it easier for machines and humans to understand code.
* Oh, and it naturally leads to [**first-class functions**](doc/functional.md), a feature often missed in APL.
* The **new symbols** for built-in functionality allow the syntactic role of a primitive to be distinguished at a glance, and aim to be more consistent and intuitive.

## What kind of name is "BQN"?

It's three letters, that happen to match the capitals in "Big Questions Notation". You can pronounce it "bacon", but are advised to avoid this unless there's puns.

## What does BQN look like?

Rather strange, most likely:

        ⊑+`∘⌽⍟12↕2  # The 12th Fibonacci number

For longer samples, you can [gaze into the abyss](src/c.bqn) that is the self-hosted compiler, or the [shallower but wider abyss](src/r.bqn) of the runtime, or take a look at the friendlier [markdown processor](md.bqn) used to format and highlight documentation files. There are also [some translations](examples/fifty.bqn) from ["A History of APL in 50 Functions"](https://www.jsoftware.com/papers/50/) here.

## Array model

Most of BQN's functionality deals with the manipulation of multidimensional arrays. However, it discards many of the complications of traditional APL [array models](https://aplwiki.com/wiki/Array_model). Unlike in APL, non-array data is possible, and common: numbers, characters, and functions are not arrays (see the full list of [types](#types) below). This avoids some difficulties that show up when trying to treat scalar arrays as the fundamental unit; in particular, there is no "floating" so a value is always different from a scalar array that contains it. This system has been [proposed](https://dl.acm.org/doi/abs/10.1145/586656.586663) in APL's past under the name **based array theory**.

Currently, the intention is that arrays will not have prototypes, so that all empty arrays of the same shape behave identically. Different elements of an array should not influence each other. While some APLs force numbers placed in the same array to a common representation, which may have different precision properties, BQN will enforce 64-bit floating-point precision, and only use representations or methods compatible with it (for example, integers up to 32 bits).

## Built-in operations

### Functions

Functions that have significant differences from APL functions are marked with an asterisk. Links for these entries go to dedicated BQN documentation while other links go to the APL Wiki.

| Glyph | Monadic                                             | Dyadic
|-------|-----------------------------------------------------|---------
| `+`   | [Conjugate](https://aplwiki.com/wiki/Conjugate)     | [Add](https://aplwiki.com/wiki/Add)
| `-`   | [Negate](https://aplwiki.com/wiki/Negate)           | [Subtract](https://aplwiki.com/wiki/Subtract)
| `×`   | [Sign](https://aplwiki.com/wiki/Signum)             | [Multiply](https://aplwiki.com/wiki/Times)
| `÷`   | [Reciprocal](https://aplwiki.com/wiki/Reciprocal)   | [Divide](https://aplwiki.com/wiki/Divide)
| `⋆`   | [Exponential](https://aplwiki.com/wiki/Exponential) | [Power](https://aplwiki.com/wiki/Power_(function))
| `√`   | [Square Root](https://aplwiki.com/wiki/Square_Root) | [Root](https://aplwiki.com/wiki/Root)
| `⌊`   | [Floor](https://aplwiki.com/wiki/Floor)             | [Minimum](https://aplwiki.com/wiki/Minimum)
| `⌈`   | [Ceiling](https://aplwiki.com/wiki/Ceiling)         | [Maximum](https://aplwiki.com/wiki/Maximum)
| `∧`   | Sort Up                                             | [And](doc/logic.md)*
| `∨`   | Sort Down                                           | [Or](doc/logic.md)*
| `¬`   | [Not](doc/logic.md)*                                | [Span](doc/logic.md)*
| `\|`  | [Absolute Value](https://aplwiki.com/wiki/Magnitude)| [Modulus](https://aplwiki.com/wiki/Residue)
| `≤`   |                                                     | [Less Than or Equal to](https://aplwiki.com/wiki/Less_than_or_Equal_to)
| `<`   | [Enclose](https://aplwiki.com/wiki/Enclose)         | [Less Than](https://aplwiki.com/wiki/Less_than)
| `>`   | [Merge](doc/couple.md)*                             | [Greater Than](https://aplwiki.com/wiki/Greater_than)
| `≥`   |                                                     | [Greater Than or Equal to](https://aplwiki.com/wiki/Greater_than_or_Equal_to)
| `=`   | Rank                                                | [Equals](https://aplwiki.com/wiki/Equal_to)
| `≠`   | [Length](https://aplwiki.com/wiki/Tally)            | [Not Equals](https://aplwiki.com/wiki/Not_Equal_to)
| `≡`   | [Depth](doc/depth.md)*                              | [Match](https://aplwiki.com/wiki/Match)
| `≢`   | [Shape](https://aplwiki.com/wiki/Shape)             | [Not Match](https://aplwiki.com/wiki/Not_Match)
| `⊣`   | [Identity](https://aplwiki.com/wiki/Identity)       | [Left](https://aplwiki.com/wiki/Identity)
| `⊢`   | [Identity](https://aplwiki.com/wiki/Identity)       | [Right](https://aplwiki.com/wiki/Identity)
| `⥊`   | [Deshape](https://aplwiki.com/wiki/Ravel)           | [Reshape](https://aplwiki.com/wiki/Reshape)
| `∾`   | [Join](doc/join.md)*                                | [Join to](https://aplwiki.com/wiki/Catenate)
| `≍`   | [Solo](doc/couple.md)*                              | [Couple](doc/couple.md)*
| `↑`   | [Prefixes](doc/prefixes.md)*                        | [Take](https://aplwiki.com/wiki/Take)
| `↓`   | [Suffixes](doc/prefixes.md)*                        | [Drop](https://aplwiki.com/wiki/Drop)
| `↕`   | [Range](https://aplwiki.com/wiki/Index_Generator)   | [Windows](doc/windows.md)*
| `⌽`   | [Reverse](https://aplwiki.com/wiki/Reverse)         | [Rotate](https://aplwiki.com/wiki/Rotate)
| `⍉`   | [Transpose](doc/transpose.md)*                      | [Reorder axes](doc/transpose.md)*
| `/`   | [Indices](https://aplwiki.com/wiki/Indices)         | [Replicate](https://aplwiki.com/wiki/Replicate)
| `⍋`   | [Grade Up](https://aplwiki.com/wiki/Grade)          | [Bins Up](https://aplwiki.com/wiki/Interval_Index)
| `⍒`   | [Grade Down](https://aplwiki.com/wiki/Grade)        | [Bins Down](https://aplwiki.com/wiki/Interval_Index)
| `⊏`   | First Cell*                                         | Select*
| `⊑`   | [First](https://aplwiki.com/wiki/First)             | Pick*
| `⊐`   |                                                     | [Index of](https://aplwiki.com/wiki/Index_Of)
| `⊒`   | Occurrence Count*                                   | Progressive Index of*
| `∊`   | [Unique Mask](https://aplwiki.com/wiki/Nub_Sieve)   | [Member of](https://aplwiki.com/wiki/Membership)
| `⍷`   | [Deduplicate](https://aplwiki.com/wiki/Unique)      | [Find](https://aplwiki.com/wiki/Find)
| `⊔`   | [Group Indices](doc/group.md)*                      | [Group](doc/group.md)*

### Modifiers

*Combinators* only control the application of functions. Because a non-function operand applies as a constant function, some combinators have extra meanings when passed a constant. For example, `0˜` is the constant function that always returns 0 and `0⊸<` is the function that tests whether its right argument is greater than 0.

Glyph | Name(s)     | Definition                     | Description
------|-------------|--------------------------------|---------------------------------------
`˜`   | Self/Swap   | `{𝕩𝔽𝕨⊣𝕩}`                      | Duplicate one argument or exchange two
`∘`   | Atop        | `{𝔽𝕨𝔾𝕩}`                       | Apply `𝔾` to both arguments and `𝔽` to the result
`○`   | Over        | `{(𝔾𝕨)𝔽𝔾𝕩}`                    | Apply `𝔾` to each argument and `𝔽` to the results
`⊸`   | Before/Bind | `{(𝔽𝕨⊣𝕩)𝔾𝕩}`                   | `𝔾`'s left argument comes from `𝔽`
`⟜`   | After/Bind  | `{(𝕨⊣𝕩)𝔽𝔾𝕩}`                   | `𝔽`'s right argument comes from `𝔾`
`⌾`   | Under       | `{𝔾⁼∘𝔽○𝔾}` OR `{(𝔾𝕩)↩𝕨𝔽○𝔾𝕩⋄𝕩}` | Apply `𝔽` over `𝔾`, then undo `𝔾`
`⊘`   | Valences    | `{𝔽𝕩;𝕨𝔾𝕩}`                     | Apply `𝔽` if there's one argument but `𝔾` if there are two
`◶`   | Choose      | `{f←(𝕨𝔽𝕩)⊑𝕘 ⋄ 𝕨F𝕩}`            | Select one of the functions in list `𝕘` based on `𝔽`

Choose isn't really a combinator since it calls the function `⊑`, and Under is not a true combinator since it has an "undo" step at the end. This step might be implemented using the left operand's inverse (*computational* Under) or its structural properties (*structural* Under).

Other modifiers control array traversal and iteration. In three cases a simpler 1-modifier is paired with a generalized 2-modifier: in each case the 1-modifier happens to be the same as the 2-modifier with a right operand of `¯1`.

1-Modifier | Name    | 2-Modifier | Name
-----------|---------|------------|--------
`˘`        | Cells   | `⎉`        | Rank
`¨`        | Each    | `⚇`        | Depth
`⌜`        | Table   |
`⁼`        | Undo    | `⍟`        | Repeat
`´`        | Fold    |
`˝`        | Insert  |
`` ` ``    | Scan    |

## Types

BQN will initially support the following fundamental types:

- Number (complex with 64-bit float precision)
- Character (Unicode code point)
- Array
- Function
- 1-Modifier
- 2-Modifier

All of these types are immutable, and immutable types should be the default for BQN. The only mutable type likely to be added is the namespace or scope.
