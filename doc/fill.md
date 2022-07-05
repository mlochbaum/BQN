*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/fill.html).*

# Fill elements

A few array operations need an array element to use when no existing element applies. BQN tries to maintain a "default" element for every array, known as a fill element, for this purpose. If it's known, the fill element is a nested array structure where each atom is either `0` or `' '`. If no fill is known, a function that requests it results in an error.

Fills are used by [Take](take.md) (`↑`) when a value in `𝕨` is larger than the corresponding length in `𝕩` and [Reshape](reshape.md) (`⥊`) when `𝕨` contains `↑`, by the two [Nudge](shift.md) functions (`»«`) when `𝕩` is non-empty, by [Merge](couple.md) (`>`) and [Join](join.md) when `𝕩` is empty, and by [Cells and Rank](rank.md) when the result has an empty frame. These are the only ways that an array's fill value can affect the program. The result of [Match](match.md) (`≡`) doesn't depend on fills, and any attempt to compute a fill can't cause side effects.

## Using fills

For the examples in this section we'll use the fact that an all-number array usually has `0` as a fill while a string has `' '` (it's not too rare to end up with such an array that has no fill, and possible but very unusual for an array to have a fill that conflicts with those rules).

[Take](take.md) (`↑`) and [Nudge](shift.md) (`»«`) in either direction use the fill for padding, to extend the array past its boundary. For example, `𝕨↑𝕩` adds elements to one side if a number in `|𝕨` is larger than the corresponding length in `≢𝕩`.

        ¯7 ↑ 4⥊3     # Fill with 0

        ¯7 ↑ "qrst"  # Fill with space

Nudge Left or Right shifts the array over and places a fill in the vacated space. If `𝕩` is empty then it doesn't need the fill and can't error.

        »¨ ⟨4⥊3,"qrst"⟩

        3↑⟨⟩  # Fill unknown

        »⟨⟩   # Fill not needed

[Reshape](reshape.md#computed-lengths) (`⥊`) uses the fill when `𝕨` contains `↑` and the product of the rest of `𝕨` doesn't evenly divide the number of elements in `𝕩`.

        ↑‿8 ⥊ "completepart"

If for some reason you need to find an array's fill element, the easiest general way is probably `⊑»1↑⥊a`.

        ⊑»1↑⥊"string"

## Edge cases

The above functions use the fill as part of their core definition. A few other functions use fills only when they encounter empty arrays. The goal of this behavior is to make programs working on empty arrays more similar to the non-empty case, so if all goes well you don't need to be thinking about these cases.

If the argument to [Merge](couple.md) is empty then its result will be as well, since the shape `≢𝕩` is a prefix of `≢>𝕩`. However, the remainder of the result shape is determined by the elements of `𝕩`, so if there are none then Merge uses the fill element to decide what the result shape should be. [Join](join.md) is similar, although it multiplies the shape of `𝕩` by the leading shape of the fill instead of concatenating them.

        ≢ > 2‿0⥊<3‿4‿1⥊0

        ≢ ∾ 2‿0⥊<3‿4‿1⥊0

[Cells and Rank](rank.md) rely on fills in a slightly more complicated way. If one of the argument frames is empty, that means the result will be empty, but the shape of a result cell still needs to be known to determine its shape (and similarly for the fill, but that's optional). BQN implementations may try to find it by running `𝔽` using a cell of fills for the argument. As in Each (`¨`) described below, this evaluation is not allowed to produce side effects. If it doesn't work, the result cell shape is assumed to be `⟨⟩`.

        ≢ ⌽˘ ↕0‿4‿3  # Shape is determined by fills

## How fills are computed

For the exact requirements placed on fill, see [the specification](../spec/inferred.md#fill-elements) (particularly "required functions"). This section loosely describes behavior in existing BQN implementations, and includes some parts that aren't required in the specification.

A fill element should encompass something that's necessarily true for all elements of an array. If the way an array is computed implies it's all numbers, the fill should be `0`. If every element is a list of two numbers, then the fill should be `⟨0,0⟩`. If every element is a list but the lengths might vary, `⟨⟩` is probably a reasonable fill element.

For [arithmetic](arithmetic.md) primitives, the fill is found by the rules of pervasion, applying the function to both argument fills. Generally this means it consists of `0`, but [character arithmetic](arithmetic.md#character-arithmetic) can produce space for a fill value.

        » "abc" + 4‿3‿2

[Mapping](map.md) modifiers Each and Table (`¨⌜`) might try to follow a similar strategy, applying `𝔽` to argument fills to obtain the result fill. The absolute rule here is that this computation can't cause side effects or an error, so for a complicated `𝔽` such as a block function this procedure is likely to be aborted to avoid disrupting the rest of the program.

Most other primitives fit in one of three broad categories as shown in the table below. Structural primitives, indicated by `⊢`, don't change the fill of `𝕩`. Combining structural primitives, indicated by `∩`, only depend on the fill of all combined arrays—elements of `𝕩` in the one-argument case, or `𝕨` and `𝕩` in the two-argument case. If these fills are the same value, then that's the fill; otherwise, the result has no fill. Finally, many functions such as [search functions](search.md) return only arrays of numbers and have a fill of `0`.

| Fill   | Monads       | Dyads       | Modifiers
|--------|--------------|-------------|----------
| `⊢`    | `∧∨⥊≍»«⌽⍉⊏⍷` | `⥊↑↓↕⌽⍉/⊏`  | `` 𝔽` ``
| `∩`    | `>∾`         | `∾≍»«`
| `0`    | `≢/⍋⍒∊⊐⊒`    | `⍋⍒⊐⊒∊⍷`

Besides these, there are a few primitives with special fills. [Enclose](enclose.md) (`<`) uses a fill derived directly from `𝕩`, with all numbers replaced by `0` and characters by `' '` (if it contains non-data atoms, the fill doesn't exist). [Enlist](pair.md) works the same way, while [Pair](pair.md) sets the fill this way based on both `𝕨` and `𝕩`, if they agree. [Range](range.md) (`↕`) does the same, although the reason is less obvious: the result elements don't match `𝕩`, but they have the same structure.

[Prefixes and Suffixes](prefixes.md) (`↑↓`) use `0↑𝕩` for the fill, as do [Group](group.md) and Group Indices (`⊔`) in the single-axis case. Fills for multi-axis `⊔` are more complicated, but follow the rule that variable-length axes are changed to length 0. The *elements* of the result of `⊔` also have a fill specified: the same as `𝕩` for Group, or `0` for Group Indices.

        6 ↑ ↑↕3  # Two fills at the end

        »¨ 3‿4‿1 /⊸⊔ "abc0123A"
