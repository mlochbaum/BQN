*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/classify_indexof.html).*

# Square Original Of (`⊐`)

## `⊐ 𝕩`: Classify
[→full documentation](../doc/selfcmp.md#classify)

Translate major cells of `𝕩` to unique ID numbers based on first occurrence.

        ⊐ 5‿6‿2‿2‿5‿1

        a ← 3‿3 ⥊ 0‿1‿2‿9‿0‿9‿0‿1‿2

        ⊐ a



## `𝕨 ⊐ 𝕩`: Index Of
[→full documentation](../doc/search.md#index-of)

First index of each major cell of `𝕩` in `𝕨`. Rank of `𝕩` must be at least cell rank of `𝕨`.

If a cell is not found in `𝕨`, the length of `𝕨` (`≠𝕨`) is used for that position.

        5‿6‿2‿2‿5‿1 ⊐ 5‿7‿1‿6

        b ← 3‿3 ⥊ 0‿1‿2‿9‿0‿9‿0‿1‿2

        b ⊐ ≍9‿0‿9
