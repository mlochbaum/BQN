*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/shift.html).*

# Shift functions

The shift functions `«` and `»` add [major cells](array.md#cells) to one side an array, displacing cells on the opposite side and moving those in between. Shifts resemble but are more general than the bit-based shift operations used in low-level languages. They replace the APL pattern of a 2-wise reduction after appending or prepending an element (APL's `2≠/0,v` translates to `»⊸≠v`); a nice version of this common pattern is one reason BQN is free to replace windowed reduction with the sometimes less convenient [Windows](windows.md).

The result of a shift function always has the same shape as `𝕩`. The function adds major cells to the beginning (`»`) or end (`«`) of `𝕩`, moving the cells already in `𝕩` to accomodate them. Some cells on the opposite side from those added will "fall off" and not be included in the result.

        0‿0 » 3‿2‿1             # Shift Before

        "end" « "add to the "   # Shift After

The cells to add come from `𝕨` if it's present, as shown above. Otherwise, a single cell of [fill elements](fill.md) for `𝕩` is used. This kind of shift, which moves cells in `𝕩` over by just one, is called a "nudge".

        » "abcd"   # Nudge

        « 1‿2‿3    # Nudge Back

If `𝕨` is longer than `𝕩`, some cells from `𝕨` will be discarded, plus all of `𝕩`. In this case `𝕨»𝕩` is `(≠𝕩)↑𝕨` and `𝕨«𝕩` is `(-≠𝕩)↑𝕨`. For similar reasons, nudging an array of length 0 returns it unchanged.

## Sequence processing with shifts

When working with a sequence of data such as text, daily measurements, or audio data, shift functions are generally the best way to handle the concept of "next" or "previous". In the following example `s` is shown alongside the shifted-right data `»s`, and each element is compared to the previous with `-⟜»`, which we see is the [inverse](undo.md) of Plus [Scan](scan.md) `` +` ``.

        s ← 1‿2‿2‿4‿3‿5‿6
        s ≍ »s
        -⟜» s

        +` -⟜» s   # Same as s

In this way `»` refers to a sequence containing the previous element at each position. By default the array's fill is used for the element before the first, and a left argument can be given to provide a different one.

        ∞ » s

        ⊏⊸» s

It may appear backwards that `»`, which typically means "go to the next item", is used to represent the previous item. In fact there is no conflict: the symbol `»` describes what position each cell of `𝕩` will have in the result, but in this context we are interested in knowing what argument value occurs in a particular result position. By moving all numbers into the future we ensure that a number in the present comes from the past. To keep your intuition functioning in these situations, it may help to think of the arrow point as fixed at some position in the result while the tail stretches back to land on the argument position where it comes from.

Switching the direction of the arrow, we get an operation that pulls the next value into each position:

        s ≍ «s
        «⊸- s

The differences here are the same as `-⟜» s`, except that they are shifted over by one, and it is the *last* value in the sequence that is compared with a fill value, not the first. These techniques adapt easily to more complicated operations. A symmetric difference is found by subtracting the previous element from the next, and dividing by two:

        2÷˜ (»-«) s

        2÷˜ (⊣˝⊸» - ⊢˝⊸«) s  # Repeat at the ends instead of using fills

A feature these examples all share is that they maintain the length of `s`. This is a common condition in sequence processing, particularly when the processed sequence needs to be combined or compared with the original in some way. However, it's not always the case. In some instances, for example when searching `s` to see if there is any value less than the previous, the list should get shorter during processing. In these cases, [Windows](windows.md) (`↕`) is usually a better choice.

## Arithmetic and logical shifts

The glyphs `«` and `»`, suggesting movement, were chosen for the same reasons as the digraphs `<<` and `>>` in C-like languages, and can be used to implement the same bit-shift operations on boolean lists.

        ⊢ i ← "10011011"-'0'

        «⍟3 i        # Quick and dirty left shift

        3 ⥊⟜0⊸« i    # Alternate left shift

With a number in big-endian format, a right shift might be logical, shifting in zeros, or arithmetic, shifting in copies of the highest-order bit (for little-endian numbers, this applies to left shifts rather than right ones). The two kinds of shift can be performed with similar code, using `0` or `⊏𝕩` for the inserted cell.

        3 ⥊⟜0⊸» i    # Logical right shift

        3 (⥊⟜⊏»⊢) i  # Arithmetic right shift

## Other examples

In [Take](take.md) (`↑`), there's no way to specify the fill element when the result is longer than the argument. To take along the first axis with a specified, constant fill value, you can use Shift Before instead, where the right argument is an array of fills with the desired final shape (a more general approach is [Under](under.md)).

        "abc" » 5⥊'F'

When using [Scan](scan.md) (`` ` ``), the result at a particular index is obtained from values up to and including the one at that index. But it's common to want to use the values up to but not including that one instead. This can be done either by [joining](join.md#join-to) or shifting in that value before scanning. The difference is that with Join the result is longer than the argument. Either form might be wanted depending on how it will be used.

        2 +` 1‿0‿1‿0    # Initial value not retained

        2 +`∘∾ 1‿0‿1‿0  # All values

        2 +`∘» 1‿0‿1‿0  # Final value not created

The *strides* of an array are the distances between one element and the next along any given axis. It's the product of all axis lengths below that axis, since these are all the axes that have to be "skipped" to jump along the axis. The strides of an array `𝕩` are `` (×`1»⊢)⌾⌽ ≢𝕩 ``.

        (×`1»⊢)⌾⌽ 5‿2‿4‿3

## Higher rank

Shifting always works on the [first axis](leading.md) of `𝕩` (which must have rank 1 or more), and shifts in major cells. A left argument can have rank equal to `𝕩`, or one less than it, in which case it becomes a single cell of the result. With no left argument, a cell of fills `1↑0↑𝕩` is nudged in.

        ⊢ a ← ⥊⟜(↕×´) 4‿3

        » a                # Nudge adds a cell of fills

        "one" « a          # Shift in a cell

        ("two"≍"cel") « a  # Shift in multiple cells

## Definition

In any instance of `»` or `«`, `𝕩` must have rank at least 1.

For a dyadic shift function, `𝕨` must be [Join](join.md#join-to)-compatible with `𝕩` (that is, `𝕨∾𝕩` completes without error) and can't have greater rank than `𝕩`. Then Shift Before (`»`) is `{(≠𝕩)↑𝕨∾𝕩}` and Shift After (`«`) is `{(-≠𝕩)↑𝕩∾𝕨}`

When called monadically, the default argument is a cell of fills `1↑0↑𝕩`. That is, Nudge (`»`) is `(1↑0↑⊢)⊸»` and Nudge Back (`«`) is `(1↑0↑⊢)⊸«`. This default argument always satisfies the compatibility requirement above and so the only conditions for nudge are that `𝕩` has rank at least 1 and has a fill element.
