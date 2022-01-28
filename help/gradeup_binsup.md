*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/gradeup_binsup.html).*

# Delta Stile (`⍋`)

## `⍋ 𝕩`: Grade Up
[→full documentation](../doc/order.md#grade)

Indices of `𝕩` that would sort its major cells in ascending order.

        a ← 3‿2‿1

        ⍋ a

        (⍋a) ⊏ a




## `𝕨 ⍋ 𝕩`: Bins Up
[→full documentation](../doc/order.md#bins)

Binary search for each cell of `𝕩` in `𝕨`, returning the number of major cells in `𝕨` less than or equal to that cell.

`𝕨` must be sorted in ascending order.

        3‿4‿5‿7 ⍋ 2

        3‿4‿5‿7 ⍋ 2‿6
