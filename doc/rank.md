*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/rank.html).*

# Cells and Rank

The Cells modifier `˘` applies a function to major cells of its argument, much like [Each](map.md) applies to elements. Each result from `𝔽` becomes a major cell of the result, which means they must all have the same shape.

The Rank modifier `⎉` generalizes this concept by allowing numbers provided by `𝔾` to specify a rank for each argument: non-negative to indicate the rank of each array passed to `𝔽`, or negative for the number of axes that are mapped over. Cells, which maps over one axis of each argument, is identical to `⎉¯1`. Rank is analogous to the [Depth modifier](depth.md#the-depth-modifier), but the homogeneous structure of an array eliminates some tricky edge cases found in Depth.

## Cells

The function Cells (`˘`) is named after *major cells* in an array. A major cell is a component of an array with dimension one smaller, so that the major cells of a list are [units](enclose.md#whats-a-unit), the major cells of a rank-2 table are its rows (which are lists), and the major cells of a rank-3 array are tables.

The function `𝔽˘` applies `𝔽` to the major cells of `𝕩`. So, for example, where [Nudge](shift.md) (`»`) shifts an entire table, Nudge Cells shifts its major cells, or rows.

        a ← 'a' + 3‿∘ ⥊ ↕24  # A character array

        ⟨  a      ,     »a     ,    »˘a ⟩

What's it mean for Nudge to shift the "entire table"? The block above shows that is shifts downward, but what's really happening is that Nudge treats `𝕩` as a collection of major cells—its rows—and shifts these. So it adds an entire row and moves the rest of the rows downwards. Nudge Cells appears similar, but it's acting independently on each row, and the values that it moves around are major cells of the row, that is, rank-0 units.

Here's an example showing how Cells can be used to shift each row independently, even though it's not possible to shift columns like this (in fact the best way to would be to [transpose](transpose.md) in order to work on rows). It uses the not-yet-introduced dyadic form of Cells, so you might want to come back to it after reading the next section.

        (↑"∘∘") ⊑⊸»˘ a

You can also see how Cells splits its argument into rows using a less array-oriented primitive: [Enclose](enclose.md) just wraps each row up so that it appears as a separate element in the final result.

        <˘ a

Enclose also comes in handy for the following task: join the rows in an array of lists, resulting in an array where each element is a joined row. The obvious guess would be "join cells", `∾˘`, but it doesn't work, because each `∾` can return a result with a different length. Cells tries to make each result of `∾` into a *cell*, when the problem was to use it as an *element*. But a 0-cell is an enclosed element, so we can close the gap by applying `<` to a joined list: `<∘∾`.

        ⊢ s ← "words"‿"go"‿"here" ≍ "some"‿"other"‿"words"

        ∾˘ s

        <∘∾˘ s

This approach can apply to more complicated functions as well. And because the result of `<` always has the same shape, `⟨⟩`, the function `<∘𝔽˘` can never have a shape agreement error. So if `𝔽˘` fails, it can't hurt to check `<∘𝔽˘` and see what results `𝔽` is returning.

### Two arguments

When given two arguments, Cells tries to pair their cells together. Starting simple, a unit array on either side will be paired with every cell of the other argument (and an atom is converted to an array).

        '∘' »˘ a

If you *want* to use this one-to-many behavior with an array, it'll take more work: since you're really only mapping over one argument, [bind](hook.md) the other inside Cells.

        "∘∘" »˘ a

        "∘∘"⊸»˘ a

This is because the general case of Cells does one-to-one matching, pairing the first axis of one argument with the other. For this to work, the two arguments need to have the same length.

        ⟨ "012" »˘ a,  (3‿∘⥊"UVWXYZ") »˘ a ⟩

The arguments might have different ranks: for example, `"012"` has rank 1 and `a` has rank 2 above. That's fine: it just means Cells will pass arguments of rank 0 and 1 to its operand. You can see these arguments using [Pair](pair.md) Cells, `⋈˘`, so that each cell of the result is just a list of the two arguments used for that call.

        "012" ⋈˘ a
