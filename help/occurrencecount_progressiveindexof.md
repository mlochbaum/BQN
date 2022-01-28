*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/occurrencecount_progressiveindexof.html).*

# Square Original Of or Equal To (`⊒`)

## `⊒ 𝕩`: Occurrence Count
[→full documentation](../doc/selfcmp.md#occurrence-count)

Number of times each major cell of `𝕩` has occurred before the current position.

        ⊒   2‿7‿1‿8‿1‿7‿1‿8‿2‿8‿4

        ≍⟜⊒ 2‿7‿1‿8‿1‿7‿1‿8‿2‿8‿4



## `𝕨 ⊒ 𝕩`: Progressive Index Of
[→full documentation](../doc/search.md#progressive-index-of)

Index of the first unused match of each major cell of `𝕩` in `𝕨`. If there are no more matches left, the length of `𝕨` is placed in that position.

        "aaa" ⊒ "aaaaa"

        "aaabb" ⊒ "ababababab"
