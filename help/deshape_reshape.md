*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/deshape_reshape.html).*

# Barb (`⥊`)

## `⥊ 𝕩`: Deshape
[→full documentation](../doc/reshape.md)

Put all elements of `𝕩` in a rank 1 array, promoting to an array if necessary.

        ⥊ 1

        ⥊ 1‿2 ≍ 3‿4



## `𝕨 ⥊ 𝕩`: Reshape
[→full documentation](../doc/reshape.md)

Put all elements of `𝕩` in an array of shape `𝕨`, removing elements or repeating them cyclically if necessary.

A single element in `𝕩` can be a function, which will be replaced with an appropriate length:
- `∘` Exact fit
- `⌊` Round length down, discarding elements
- `⌽` Round length up
- `↑` Round length up, and use element fill to add extra elements.

        3‿3 ⥊ 3

        2‿⌽‿2 ⥊ 1‿2‿3

        2‿↑‿2 ⥊ 1‿2‿3
