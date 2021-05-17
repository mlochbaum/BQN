*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/primitive.html).*

# BQN primitives

*Primitives* are functions and modifiers that are built into the language and written with individual glyphs. The role of a primitive when written always matches its type (but you can use its value in other roles by assigning it or various other methods).

Primitives have no side effects other than errors, and can't perform infinite computations, except in the case that the operand to a primitive modifier is a function that has side effects or never returns (primitive modifiers never perform computation when passed operands—they always bind the operands and act when called on arguments). Side effects here include both writing state such as variables or printed output, and reading any outside state, so that a function with no side effects always returns the same result if passed the same arguments. Trains and list notation have the same properties, so that tacit code written entirely with primitives, trains, and lists always describes finite, self-contained computations.

Recursion is the primary way to perform potentially infinite computations in BQN, and it can be packaged into [control structures](control.md) like `While` for ease of use. A given BQN implementation might also provide [system values](../spec/system.md) for "impure" tasks like file access or other I/O.

## Functions

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
| `∧`   | [Sort Up](order.md#sort)                            | [And](logic.md)*
| `∨`   | [Sort Down](order.md#sort)                          | [Or](logic.md)*
| `¬`   | [Not](logic.md)*                                    | [Span](logic.md)*
| `\|`  | [Absolute Value](https://aplwiki.com/wiki/Magnitude)| [Modulus](https://aplwiki.com/wiki/Residue)
| `≤`   |                                                     | [Less Than or Equal to](https://aplwiki.com/wiki/Less_than_or_Equal_to)
| `<`   | [Enclose](https://aplwiki.com/wiki/Enclose)         | [Less Than](https://aplwiki.com/wiki/Less_than)
| `>`   | [Merge](couple.md)*                                 | [Greater Than](https://aplwiki.com/wiki/Greater_than)
| `≥`   |                                                     | [Greater Than or Equal to](https://aplwiki.com/wiki/Greater_than_or_Equal_to)
| `=`   | Rank                                                | [Equals](https://aplwiki.com/wiki/Equal_to)
| `≠`   | [Length](https://aplwiki.com/wiki/Tally)            | [Not Equals](https://aplwiki.com/wiki/Not_Equal_to)
| `≡`   | [Depth](depth.md)*                                  | [Match](match.md)
| `≢`   | [Shape](https://aplwiki.com/wiki/Shape)             | [Not Match](match.md)
| `⊣`   | [Identity](https://aplwiki.com/wiki/Identity)       | [Left](https://aplwiki.com/wiki/Identity)
| `⊢`   | [Identity](https://aplwiki.com/wiki/Identity)       | [Right](https://aplwiki.com/wiki/Identity)
| `⥊`   | [Deshape](reshape.md)                               | [Reshape](reshape.md)*
| `∾`   | [Join](join.md)*                                    | [Join to](join.md)
| `≍`   | [Solo](couple.md)*                                  | [Couple](couple.md)*
| `↑`   | [Prefixes](prefixes.md)*                            | [Take](https://aplwiki.com/wiki/Take)
| `↓`   | [Suffixes](prefixes.md)*                            | [Drop](https://aplwiki.com/wiki/Drop)
| `↕`   | [Range](https://aplwiki.com/wiki/Index_Generator)   | [Windows](windows.md)*
| `»`   | [Nudge](shift.md)*                                  | [Shift Before](shift.md)*
| `«`   | [Nudge Back](shift.md)*                             | [Shift After](shift.md)*
| `⌽`   | [Reverse](reverse.md)                               | [Rotate](reverse.md#rotate)
| `⍉`   | [Transpose](transpose.md)*                          | [Reorder axes](transpose.md)*
| `/`   | [Indices](https://aplwiki.com/wiki/Indices)         | [Replicate](https://aplwiki.com/wiki/Replicate)
| `⍋`   | [Grade Up](order.md#grade)                          | [Bins Up](order.md#bins)
| `⍒`   | [Grade Down](order.md#grade)                        | [Bins Down](order.md#bins)
| `⊏`   | First Cell*                                         | Select*
| `⊑`   | [First](https://aplwiki.com/wiki/First)             | Pick*
| `⊐`   | [Classify](selfcmp.md#classify)* (`⍷⊸⊐`)            | [Index of](https://aplwiki.com/wiki/Index_Of)
| `⊒`   | [Occurrence Count](selfcmp.md#occurrence-count)*    | Progressive Index of*
| `∊`   | [Mark Firsts](selfcmp.md#mark-firsts)               | [Member of](https://aplwiki.com/wiki/Membership)
| `⍷`   | [Deduplicate](selfcmp.md#deduplicate)               | [Find](https://aplwiki.com/wiki/Find)
| `⊔`   | [Group Indices](group.md)*                          | [Group](group.md)*
| `!`   | [Assert](assert.md)*                                | [Assert with Message](assert.md)*

## Modifiers

<!--GEN combinator.bqn-->

*Combinators* only control the application of functions. Because a non-function operand applies as a constant function, some combinators have extra meanings when passed a constant. For example, `0˜` is identical to `0˙`—a constant function that always returns 0—and `0⊸<` is the function that tests whether its right argument is greater than 0.

Glyph | Name(s)     | Definition                     | Description
------|-------------|--------------------------------|---------------------------------------
`˙`   | Constant    | `{𝕩⋄𝕗}`                        | Return a function that returns the operand
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

1-Modifier | Name                                  | 2-Modifier | Name
-----------|---------------------------------------|------------|--------
`˘`        | Cells                                 | `⎉`        | [Rank](https://aplwiki.com/wiki/Rank_(operator))
`¨`        | [Each](https://aplwiki.com/wiki/Each) | `⚇`        | Depth
`⌜`        | Table                                 |
`⁼`        | Undo                                  | `⍟`        | Repeat
`´`        | [Fold](fold.md)                       |
`˝`        | [Insert](fold.md)                     |
`` ` ``    | Scan                                  |
