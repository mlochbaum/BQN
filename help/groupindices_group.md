*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/groupindices_group.html).*

# Square Cup (`⊔`)

## `⊔ 𝕩`: Group Indices
[→full documentation](../doc/group.md)

Group the indices of the major cells of `𝕩` by their respective values.

`𝕩` must consist of integers. Groups start from 0.

        ⊔ 4‿5‿6‿6‿4‿7‿5

        (↕8) ≍ ⊔ 4‿5‿6‿6‿4‿7‿5



## `𝕨 ⊔ 𝕩`: Group
[→full documentation](../doc/group.md)

Group the major cells of `𝕩` by their respective indices in `𝕨`.

If an element corresponds to `¯1`, it is excluded from grouping.

An extra element can be added to the end of `𝕨` to specify length of the result.

        1‿0‿1‿2‿2‿3‿3  ⊔ 4‿5‿6‿6‿4‿7‿5

        1‿0‿1‿¯1‿¯1‿3‿3  ⊔ 4‿5‿6‿6‿4‿7‿5

        1‿0‿1‿¯1‿¯1‿3‿3‿10  ⊔ 4‿5‿6‿6‿4‿7‿5
