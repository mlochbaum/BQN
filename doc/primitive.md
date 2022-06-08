*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/primitive.html).*

# BQN primitives

*Primitives* are the basic functions and modifiers built into the language, written with individual glyphs (more about the concept [here](../commentary/primitive.md)). The [role](expression.md#syntactic-role) of a primitive when written always matches its type (but you can use its value in other roles by assigning it, or other methods).

Primitives have no side effects other than errors, and can't perform infinite computations, except when a primitive modifier calls an operand function that does one of these things (and this can only happen when arguments are passed, as primitive modifiers are always deferred). Side effects here include both writing state such as variables or printed output, and reading any outside state, so that a function without them always returns the same result if passed the same arguments. Since trains and list notation have the same nice properties, [tacit](tacit.md) code written entirely with primitives, trains, and lists always describes finite, self-contained computations.

Recursion is the primary way to perform potentially infinite computations in BQN, and it can be packaged into [control structures](control.md) like `While` for ease of use. A given BQN implementation might also provide [system values](../spec/system.md) for "impure" tasks like file access or other I/O.

## Functions

A function call with one argument (prefix) is called "monadic" and one with two arguments (infix) is "dyadic".

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
| `∧`   | [Sort Up](order.md#sort)                            | [And](logic.md)
| `∨`   | [Sort Down](order.md#sort)                          | [Or](logic.md)
| `¬`   | [Not](logic.md)                                     | [Span](logic.md)
| `\|`  | [Absolute Value](arithmetic.md#additional-arithmetic)| [Modulus](arithmetic.md#additional-arithmetic)
| `≤`   |                                                     | [Less Than or Equal to](arithmetic.md#comparisons)
| `<`   | [Enclose](enclose.md)                               | [Less Than](arithmetic.md#comparisons)
| `>`   | [Merge](couple.md)                                  | [Greater Than](arithmetic.md#comparisons)
| `≥`   |                                                     | [Greater Than or Equal to](arithmetic.md#comparisons)
| `=`   | [Rank](shape.md)                                    | [Equals](arithmetic.md#comparisons)
| `≠`   | [Length](shape.md)                                  | [Not Equals](arithmetic.md#comparisons)
| `≡`   | [Depth](depth.md)                                   | [Match](match.md)
| `≢`   | [Shape](shape.md)                                   | [Not Match](match.md)
| `⊣`   | [Identity](identity.md)                             | [Left](identity.md)
| `⊢`   | [Identity](identity.md)                             | [Right](identity.md)
| `⥊`   | [Deshape](reshape.md)                               | [Reshape](reshape.md)
| `∾`   | [Join](join.md)                                     | [Join to](join.md)
| `≍`   | [Solo](couple.md)                                   | [Couple](couple.md)
| `⋈`   | [Enlist](pair.md)                                   | [Pair](pair.md)
| `↑`   | [Prefixes](prefixes.md)                             | [Take](take.md)
| `↓`   | [Suffixes](prefixes.md)                             | [Drop](take.md)
| `↕`   | [Range](range.md)                                   | [Windows](windows.md)
| `»`   | [Nudge](shift.md)                                   | [Shift Before](shift.md)
| `«`   | [Nudge Back](shift.md)                              | [Shift After](shift.md)
| `⌽`   | [Reverse](reverse.md)                               | [Rotate](reverse.md#rotate)
| `⍉`   | [Transpose](transpose.md)                           | [Reorder Axes](transpose.md)
| `/`   | [Indices](replicate.md#indices)                     | [Replicate](replicate.md)
| `⍋`   | [Grade Up](order.md#grade)                          | [Bins Up](order.md#bins)
| `⍒`   | [Grade Down](order.md#grade)                        | [Bins Down](order.md#bins)
| `⊏`   | [First Cell](select.md#first-cell)                  | [Select](select.md)
| `⊑`   | [First](pick.md#first)                              | [Pick](pick.md)
| `⊐`   | [Classify](selfcmp.md#classify)                     | [Index of](search.md#index-of)
| `⊒`   | [Occurrence Count](selfcmp.md#occurrence-count)     | [Progressive Index of](search.md#progressive-index-of)
| `∊`   | [Mark Firsts](selfcmp.md#mark-firsts)               | [Member of](search.md#member-of)
| `⍷`   | [Deduplicate](selfcmp.md#deduplicate)               | [Find](find.md)
| `⊔`   | [Group Indices](group.md)                           | [Group](group.md)
| `!`   | [Assert](assert.md)                                 | [Assert with Message](assert.md)

## Modifiers

<!--GEN combinator.bqn-->

*Combinators* only control the application of functions, which are passed as operands. A data value such as a number or array can also be an operand and, as always, applies as a constant function.

Glyph | Name(s)                 | Definition                     | Description
------|-------------------------|--------------------------------|---------------------------------------
`˙`   | [Constant](constant.md) | `{𝕩⋄𝕗}`                        | Return a function that returns the operand
`˜`   | [Self/Swap](swap.md)    | `{𝕩𝔽𝕨⊣𝕩}`                      | Duplicate one argument or exchange two
`∘`   | [Atop](compose.md)      | `{𝔽𝕨𝔾𝕩}`                       | Apply `𝔾` to both arguments and `𝔽` to the result
`○`   | [Over](compose.md)      | `{(𝔾𝕨)𝔽𝔾𝕩}`                    | Apply `𝔾` to each argument and `𝔽` to the results
`⊸`   | [Before/Bind](hook.md)  | `{(𝔽𝕨⊣𝕩)𝔾𝕩}`                   | `𝔾`'s left argument comes from `𝔽`
`⟜`   | [After/Bind](hook.md)   | `{(𝕨⊣𝕩)𝔽𝔾𝕩}`                   | `𝔽`'s right argument comes from `𝔾`
`⊘`   | [Valences](valences.md) | `{𝔽𝕩;𝕨𝔾𝕩}`                     | Apply `𝔽` if there's one argument but `𝔾` if there are two
`◶`   | [Choose](choose.md)     | `{f←(𝕨𝔽𝕩)⊑𝕘 ⋄ 𝕨F𝕩}`            | Select one of the functions in list `𝕘` based on `𝔽`
`⌾`   | [Under](under.md)       | `{𝔾⁼∘𝔽○𝔾}` OR `{(𝔾𝕩)↩𝕨𝔽○𝔾𝕩⋄𝕩}` | Apply `𝔽` over `𝔾`, then undo `𝔾`
`⎊`   | [Catch](assert.md#catch)| `{𝕨𝔽𝕩… 𝕨𝔾𝕩}`                   | Apply `𝔽`, but if it fails catch the error and apply `𝔾`

The last three are combinators in spirit but go beyond the actual strict definition: Choose calls the function `⊑`, Under has an "undo" step at the end, and Catch traps an error. The second definition for Under and the one for Catch are written in pseudo-BQN because they can't be expressed otherwise.

Other modifiers control array traversal and iteration. In three cases a simpler 1-modifier is paired with a generalized 2-modifier: for each of these the 1-modifier happens to be the same as the 2-modifier with a right operand of `¯1`.

| 1-Modifier | Name                                  | 2-Modifier | Name
|------------|---------------------------------------|------------|--------
| `˘`        | [Cells](rank.md)                      | `⎉`        | [Rank](rank.md#rank)
| `¨`        | [Each](map.md)                        | `⚇`        | [Depth](depth.md#the-depth-modifier)
| `⌜`        | [Table](map.md)                       |
| `⁼`        | [Undo](undo.md)                       | `⍟`        | [Repeat](repeat.md)
| `´`        | [Fold](fold.md)                       |
| `˝`        | [Insert](fold.md)                     |
| `` ` ``    | [Scan](scan.md)                       |
