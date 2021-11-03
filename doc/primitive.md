*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/primitive.html).*

# BQN primitives

*Primitives* are the basic functions and modifiers built into the language, written with individual glyphs (more about the concept [here](../commentary/primitive.md)). The role of a primitive when written always matches its type (but you can use its value in other roles by assigning it, or other methods).

Primitives have no side effects other than errors, and can't perform infinite computations, except when a primitive modifier calls an operand function that does one of these things (this can only happen when arguments are passed, as primitive modifiers are always deferred). Side effects here include both writing state such as variables or printed output, and reading any outside state, so that a function without them always returns the same result if passed the same arguments. Since trains and list notation have the same nice properties, tacit code written entirely with primitives, trains, and lists always describes finite, self-contained computations.

Recursion is the primary way to perform potentially infinite computations in BQN, and it can be packaged into [control structures](control.md) like `While` for ease of use. A given BQN implementation might also provide [system values](../spec/system.md) for "impure" tasks like file access or other I/O.

## Functions

Functions that have significant differences from APL equivalents or don't appear in APL are marked with an asterisk.

| Glyph | Monadic                                             | Dyadic
|-------|-----------------------------------------------------|---------
| `+`   | [Conjugate](arithmetic.md#basic-arithmetic)         | [Add](arithmetic.md#basic-arithmetic)
| `-`   | [Negate](arithmetic.md#basic-arithmetic)            | [Subtract](arithmetic.md#basic-arithmetic)
| `×`   | [Sign](arithmetic.md#basic-arithmetic)              | [Multiply](arithmetic.md#basic-arithmetic)
| `÷`   | [Reciprocal](arithmetic.md#basic-arithmetic)        | [Divide](arithmetic.md#basic-arithmetic)
| `⋆`   | [Exponential](arithmetic.md#basic-arithmetic)       | [Power](arithmetic.md#basic-arithmetic)
| `√`   | [Square Root](arithmetic.md#basic-arithmetic)       | [Root](arithmetic.md#basic-arithmetic)
| `⌊`   | [Floor](arithmetic.md#additional-arithmetic)        | [Minimum](arithmetic.md#additional-arithmetic)
| `⌈`   | [Ceiling](arithmetic.md#additional-arithmetic)      | [Maximum](arithmetic.md#additional-arithmetic)
| `∧`   | [Sort Up](order.md#sort)                            | [And](logic.md)*
| `∨`   | [Sort Down](order.md#sort)                          | [Or](logic.md)*
| `¬`   | [Not](logic.md)*                                    | [Span](logic.md)*
| `\|`  | [Absolute Value](arithmetic.md#additional-arithmetic)| [Modulus](arithmetic.md#additional-arithmetic)
| `≤`   |                                                     | [Less Than or Equal to](arithmetic.md#comparisons)
| `<`   | [Enclose](enclose.md)                               | [Less Than](arithmetic.md#comparisons)
| `>`   | [Merge](couple.md)*                                 | [Greater Than](arithmetic.md#comparisons)
| `≥`   |                                                     | [Greater Than or Equal to](arithmetic.md#comparisons)
| `=`   | [Rank](shape.md)*                                   | [Equals](arithmetic.md#comparisons)
| `≠`   | [Length](shape.md)                                  | [Not Equals](arithmetic.md#comparisons)
| `≡`   | [Depth](depth.md)*                                  | [Match](match.md)
| `≢`   | [Shape](shape.md)                                   | [Not Match](match.md)
| `⊣`   | [Identity](identity.md)                             | [Left](identity.md)
| `⊢`   | [Identity](identity.md)                             | [Right](identity.md)
| `⥊`   | [Deshape](reshape.md)                               | [Reshape](reshape.md)*
| `∾`   | [Join](join.md)*                                    | [Join to](join.md)
| `≍`   | [Solo](couple.md)*                                  | [Couple](couple.md)*
| `⋈`   | [Enlist](pair.md)*                                  | [Pair](pair.md)*
| `↑`   | [Prefixes](prefixes.md)*                            | [Take](take.md)
| `↓`   | [Suffixes](prefixes.md)*                            | [Drop](take.md)
| `↕`   | [Range](range.md)                                   | [Windows](windows.md)*
| `»`   | [Nudge](shift.md)*                                  | [Shift Before](shift.md)*
| `«`   | [Nudge Back](shift.md)*                             | [Shift After](shift.md)*
| `⌽`   | [Reverse](reverse.md)                               | [Rotate](reverse.md#rotate)
| `⍉`   | [Transpose](transpose.md)*                          | [Reorder axes](transpose.md)*
| `/`   | [Indices](replicate.md#indices)                     | [Replicate](replicate.md)
| `⍋`   | [Grade Up](order.md#grade)                          | [Bins Up](order.md#bins)
| `⍒`   | [Grade Down](order.md#grade)                        | [Bins Down](order.md#bins)
| `⊏`   | [First Cell](select.md)*                            | [Select](select.md)*
| `⊑`   | [First](pick.md#first)                              | [Pick](pick.md)*
| `⊐`   | [Classify](selfcmp.md#classify)*                    | [Index of](search.md#index-of)
| `⊒`   | [Occurrence Count](selfcmp.md#occurrence-count)*    | [Progressive Index of](search.md#progressive-index-of)*
| `∊`   | [Mark Firsts](selfcmp.md#mark-firsts)               | [Member of](search.md#member-of)
| `⍷`   | [Deduplicate](selfcmp.md#deduplicate)               | [Find](find.md)
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
`¨`        | [Each](map.md)                        | `⚇`        | [Depth](depth.md#the-depth-modifier)
`⌜`        | [Table](map.md)                       |
`⁼`        | [Undo](undo.md)                       | `⍟`        | [Repeat](repeat.md)
`´`        | [Fold](fold.md)                       |
`˝`        | [Insert](fold.md)                     |
`` ` ``    | [Scan](scan.md)                       |
