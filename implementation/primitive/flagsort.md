*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/flagsort.html).*

# Sortedness flags in primitive implementation

CBQN has flags for arrays to indicate that the cells are ordered (as if sorted): one for ascending ordering and one for descending. Both flags together mean all cells are the same. These flags can be set in many cases, and allow for faster operation in many primitives, including asymptotic improvements. They're particularly important for Bins (`⍋⍒`) to avoid checking that a large `𝕨` is sorted in order to search a much smaller `𝕩`.

## Setting flags

[Trivial cases](arithmetic.md#trivial-cases) of arithmetic imply flags: for the identity, flags of `a` are maintained, and constant results can have both flags set.

Many primitives are monotonic in each argument. For example, if `a≤b`, then `(a<k)≥(b<k)`, that is, `<` is monotonically descending in `𝕨`. In the table below, + indicates an ascending argument, which corresponds to maintained order, while - indicates a descending argument and swapped order. The result inherits any flags shared by `𝕨` and `𝕩` (so, a bitwise and) after swapping flags for any descending arguments. Since it's reused, a scalar argument is effectively constant and should count as having both flags set. Table `⌜` counts as having a constant right argument.

| Prim   | Bool  | `𝕨` | `𝕩`
|--------|-------|-----|----
| `+⌊⌈`  | `∨∧×` | +   | +
| `>≥-¬` |       | +   | -
| `<≤`   |       | -   | +

Multiplication by a constant factor with `×∧÷`, such as `k×v` or `v÷k`, maintains the ordering of `v` if `k` is positive, reverses it if negative, and gives a constant result if zero and `v` is finite.

The following scans `` F` `` have ordered results. Since ``F`⌾⌽`` applies `⌽` to the result of `` F` ``, it gives the opposite ordering.
| Prim | Bool | Order
|------|------|------
| `⌊`  | `×∧` | Descending
| `⌈`  | `+∨` | Ascending

Other primitives have the effects listed below.

| Prim | Monadic            | Dyadic
|------|--------------------|-------
| `↕`  | Sorted up          | Same as `𝕩`
| `/`  | Sorted up          | Same as `𝕩`
| `↑`  | Sorted up          | Same as `𝕩` if no fills
| `↓`  | Same as `𝕩`        | Same as `𝕩`
| `⌽`  | Swaps flags        |
| `⥊`  |                    | `s⥊atom` is constant
| `⊏`  |                    | Same as `𝕨` if `𝕩` up, swapped if `𝕩` down
| `⊐`  | Up if `𝕩` sorted   |
| `⍷`  | Same as `𝕩`        |
| `⊔`  | Elements sorted up | Elements same as `𝕩`
| `∾«»`|                    | Checkable if `𝕨` and `𝕩` both ordered

As `∾«»` are fast operations and require a check that can be relatively expensive on short arguments, it's not clear whether they should try to maintain sortedness flags.

## Using flags

Ordering functions `∧∨⍋⍒` can use flags in obvious ways: pre-sorted arguments make Sort and Grade trivial, and Bins should check for a sortedness flag before attempting to verify that `𝕨` is sorted.

Both Bins `⍋⍒` and Searches `⊐⊒∊⍷` can apply adaptive galloping methods if both arguments are sorted. There's extensive research on these techniques but I don't have much experience with them.

The minimum and maximum of an ordered list are its first and last cells (reversed if sorted down). This is useful for primitives that perform range checking, as well as folds and scans with `⌊` or `⌈`. In particular, the scan either returns `𝕩` or acts as `` ⊣` ``.

Sorted arguments can be split into runs with binary searches. If the range is much smaller than the length then the runs must be long on average. Then operations such as `/⁼` or `+´` where a run can be processed in constant time can process runs quickly. For example, `+´` on a sorted-descending boolean list is simply the index of the first `0` as found by a binary search. Other cases include `𝕩` for monadic `/`, `𝕨` for `/` and `⊔`, scans with `+` or boolean `≠=`, and Match (`≡≢`) if both arguments are sorted in the same direction.

Small-range selection can be performed with in-register shuffles. For `⊏` with sorted `𝕨`, an adaptive technique is to operate on `𝕨` one vector register at a time, checking the range with the first and last element. Then either a shuffle or gather can be used as appropriate, or even a broadcast if the first and last index are equal. More possibilities are discussed in the section on [sorted selection](select.md#sorted-indices).
