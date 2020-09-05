*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/join.html).*

# Join

Join (`∾`) is an extension of the monadic function [Raze](https://aplwiki.com/wiki/Raze) from A+ and J to arbitrary argument ranks. It has the same relationship to Join to, the dyadic function sharing the same glyph, as [Merge](couple.md) (`>`) does to Couple (`≍`): `a≍b` is `>a‿b` and `a∾b` is `∾a‿b`. While Merge and Couple combine arrays (the elements of Merge's argument, or the arguments themselves for Couple) along a new leading axis, Join and Join to combine them along the existing leading axis. Both Merge and Join can also be called on a higher-rank array, causing Merge to add multiple leading axes while Join combines elements along multiple existing axes.

Join can be used to combine several strings into a single string, like `array.join()` in Javascript (but it doesn't force the result to be a string).

        ∾"time"‿"to"‿"join"‿"some"‿"words"

To join with a separator in between, we might prepend the separator to each string, then remove the leading separator after joining. Another approach would be to insert the separator array as an element between each pair of array elements before calling Join.

        1↓∾' '∾¨"time"‿"to"‿"join"‿"some"‿"words"

Join requires each element of its argument to be an array, and their ranks to match exactly. No rank extension is performed.

        ∾"abc"‿'d'‿"ef"  # Includes an atom
    RANK ERROR
        ∾"abc"‿(<'d')‿"ef"  # Includes a scalar
    RANK ERROR

However, Join has higher-dimensional uses as well. Given a rank-`m` array of rank-`n` arrays (requiring `m≤n`), it will merge arrays along their first `m` axes. For example, if the argument is a matrix of matrices representing a [block matrix](https://en.wikipedia.org/wiki/Block_matrix), Join will give the corresponding unblocked matrix as its result.

        ⊢ m ← (3‿1∾⌜4‿2‿5) ⥊¨ 2‿3⥊↕6
        ∾ m  # Join all that together

Join has fairly strict requirements on the shapes of its argument elements—although less strict than those of Merge, which requires they all have identical shape. Suppose the argument to Join has rank `m`. Each of its elements must have the same rank, `n`, which is at least `m`. The trailing shapes `m↓⟜≢¨𝕩` must all be identical (the trailing shape `m↓≢∾𝕩` of the result will match these shapes as well). The other entries in the leading shapes need not be the same, but the shape of an element along a particular axis must depend only on the location of the element along that axis in the full array. For a list argument this imposes no restriction, since the one leading shape element is allowed to depend on position along the only axis. But for higher ranks the structure quickly becomes more rigid.

To state this requirement more formally in BQN, we say that there is some list `s` of lists of lengths, so that `(≢¨s)≡≢𝕩`. We require element `i⊑𝕩` to have shape `i⊑¨s`. Then the first `m` axes of the result are `+´¨s`.
