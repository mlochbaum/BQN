*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/choose.html).*

# Choose

The 2-modifier Choose (`◶`) applies one function from a list `𝕘`, based on the selecting index returned by a function `𝔽`. It's a combinator form of [Pick](pick.md) (`⊑`), so that `{f←(𝕨𝔽𝕩)⊑𝕘 ⋄ 𝕨F𝕩}` is a complete definition. For example, the function below subtracts 1 from its argument if negative and adds 1 if positive.

        0⊸≤◶⟨-⟜1, +⟜1⟩¨ 3‿¯1‿5

Here the selection function `𝔽` is `0⊸≤`, while `𝕘` is a list of two functions `⟨-⟜1, +⟜1⟩`. On the first argument, `3`, `𝔽3` is `0≤3`, or `1`, so the function `+⟜1` from `𝕘` is chosen. The use of array indices means "false" comes first in `𝕘` and "true" comes second, which is backwards relative to if-else constructs in most programming languages (including BQN's own [predicates](block.md#predicates)). When using a comparison for `𝔽` I strongly prefer to phrase it as `n⊸<` or `n⊸≤` so that smaller values go through the first one and larger functions go through the second. This doesn't apply so much when comparing two arguments since one is smaller but the other's larger, so I don't have an easy answer for that.

        2 >◶⊣‿⊢ 6  # A minimum function (⌊)

The advantage of using an index is that Choose works with any number of options.

        Fn ← (⊑"rtd"⊐⊏)◶⟨⌽, 1⊸↑, 1⊸↓, ⊢⟩  # Reverse, take 1, drop 1

        Fn "r123"

        Fn "d123"

        Fn "123"  # Default

The selection function in `Fn` uses [Index of](search.md#index-of) (`⊐`) to find the index of the first character in the list `"rtd"`. An extra value in `𝕘` serves as a default function if it's none of those, since the result of `𝔽` is `3` in that case. A similar function that's often useful is [Bins](order.md#bins), for grouping inputs into intervals rather than by exact matching.

Choose is necessary for [tacit](tacit.md) programming, but tacit programming is not necessary to be an effective BQN programmer! Consider using block features like [predicates](block.md#predicates) when Choose isn't working with your program's flow.

Because Choose is based on [Pick](pick.md), it retains the features of negative, multidimensional, and multiple selection. Negative indexing might make sense if there's some special `¯1` value, and if the options naturally form an array, multidimensional indexing is pretty neat. Selecting multiple values from `𝕘`, which happens if the result of `𝔽` is an array of arrays, is never useful because the array result from `𝔽` acts as a constant function. It's much clearer to express it as `𝔽⊑𝕘˙`.
