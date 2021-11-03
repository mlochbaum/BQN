*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/couple.html).*

# Couple and Merge

Solo/Couple (`≍`) and Merge (`>`) are functions that create a higher-rank array from lower-rank components. Each takes some number of inner arrays organized in an outer structure, and creates a single array combining all elements of those inner arrays. For example, let's couple two arrays of shape `2‿3`:

        ⊢ p ← 3‿5×⌜↕3
        ⊢ q ← 2‿3⥊"abcdef"
        p ≍ q   # p coupled to q
        ≢ p ≍ q

The result has two inner axes that are shared by `p` and `q`, preceded by an outer axis: length 2 because there are two arguments. Calling `≍` with no left argument does something simpler: because there is one argument, it just adds a length-1 axis to the front. The argument goes solo, becoming the only major cell of the result.

        ≍ q
        ≢ ≍ q

Merge (`>`) also takes one argument, but a nested one. Its argument is an array of arrays, each with the same shape. The shape of the result is then the outer shape followed by this shared inner shape.

        ⊢ a ← "AB"‿"CD" ∾⌜ "rst"‿"uvw"‿"xyz"
        > a
        ≢ > a

Merge is effectively a generalization of Solo and Couple, since Solo is `{>⟨𝕩⟩}` and Couple is `{>⟨𝕨,𝕩⟩}`. Since `≍` works on the "list" of arguments, it can only add one dimension, but `>` can take any number of dimensions as its input.

## Merge and array theory

In all cases what these functions do is more like reinterpreting existing data than creating new information. In fact, if we ignore the shape and look at the ravels of the arrays involved in a call to Merge, we find that it just [joins](join.md) them together. Essentially, Merge is a request to ensure that the inner arrays (which, being independent elements, could be any sort of "ragged" array) can fit together in an array, and then to consider them to be such an array. For this reason, Merge (or a virtual analogue) is used to combine the result cells when calling a function with Rank into a single array.

        ⥊ > a
        ⥊ ⥊¨ a
        ∾ ⥊ ⥊¨ a

The way this happens, and the constraint that all inner arrays have the same shape, is closely connected to the concept of an array, and like [Table](map.md#table) `⌜`, Merge might be considered a fundamental way to build up multidimensional arrays from lists. In both cases rank-0 or [unit](enclose.md#whats-a-unit) arrays are somewhat special. They are the [identity value](fold.md#identity-values) of a function with Table, and can be produced by Merge [inverse](undo.md), `>⁼` **on a list**, which forces either the outer or inner shape to be empty (BQN chooses `>⁼` to be `<`, but only on an array, as `>` cannot produce non-arrays). Merge has another catch as well: it cannot produce arrays with a `0` in the shape, except at the end, without relying on a [fill](fill.md) element.

        ⊢ e ← ⟨⟩¨ ↕3
        ≢ > e
        ≢ > > e

Above we start with a list of three empty arrays. After merging once we get a shape `3‿0` array, sure, but what happens next? The shape added by another merge is the shared shape of that array's elements—and there aren't any! If the nested list kept some type information around then we might know, but extra type information is essentially how lists pretend to be arrays. True dynamic lists simply can't represent multidimensional arrays with a `0` in the middle of the shape. In this sense, arrays are a richer model than nested lists.

## Coupling units

A note on the topic of Solo and Couple applied to units. As always, one axis will be added, so that the result is a list (strangely, J's [laminate](https://code.jsoftware.com/wiki/Vocabulary/commaco#dyadic) differs from Couple in this one case, as it will add an axis to get a shape `2‿1` result). For Solo, this is interchangeable with [Deshape](reshape.md) (`⥊`), and either primitive might be chosen for stylistic reasons. For Couple, it is equivalent to [Join-to](join.md) (`∾`), but this is an irregular form of Join-to because it is the only case where Join-to adds an axis to both arguments instead of just one. Couple should be preferred in this case.

The function [Pair](pair.md) (`⋈`) can be written `≍○<`, while `≍` in either valence is `>∘⋈`. As an interesting consequence, `≍ ←→ >∘≍○<`, and `⋈ ←→ >∘⋈○<`. These two identities have the same form because adding `○<` commutes with adding `>∘`.

## Definitions

As discussed above, `≍` is equivalent to `>{⟨𝕩⟩;⟨𝕨,𝕩⟩}`. To complete the picture we should describe Merge fully. Merge is defined on an array argument `𝕩` such that there's some shape `s` satisfying `∧´⥊(s≡≢)¨𝕩`. If `𝕩` is empty then any shape satisfies this expression; `s` should be chosen based on known type information for `𝕩` or otherwise assumed to be `⟨⟩`. If `s` is empty then `𝕩` is allowed to contain atoms as well as unit arrays, and these will be implicitly promoted to arrays by the `⊑` indexing used later. We construct the result by combining the outer and inner axes of the argument with Table; since the outer axes come first they must correspond to the left argument and the inner axes must correspond to the right argument. `𝕩` is a natural choice of left argument, and because no concrete array can be used, the right argument will be `↕s`, the array of indices into any element of `𝕩`. To get the appropriate element corresponding to a particular choice of index and element of `𝕩` we should select using that index. The result of Merge is `𝕩⊑˜⌜↕s`.

Given this definition we can also describe Rank (`⎉`) in terms of Each (`¨`) and the simpler monadic function Enclose-Rank `<⎉k`. We assume effective ranks `j` for `𝕨` (if present) and `k` for `𝕩` have been computed. Then the correspondence is `𝕨F⎉k𝕩 ←→ >(<⎉j𝕨)F¨(<⎉k𝕩)`.
