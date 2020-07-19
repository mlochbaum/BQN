*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/windows.html).*

# Windows

In BQN, it's strongly preferred to use functions, and not modifiers, for array manipulation. Functions are simpler as they have fewer moving parts. They are more concrete, since the array results can always be viewed right away. They are easier to implement with reasonable performance as well, since there is no need to recognize many possible function operands as special cases.

The Window function replaces APL's Windowed Reduction, J's more general Infix operator, and Dyalog's Stencil, which is adapted from one case of J's Cut operator.

## Definition

We'll start with the one-axis case. Here Window's left argument is a number between `0` and `1+≠𝕩`. The result is composed of slices of `𝕩` (contiguous sections of major cells) with length `𝕨`, starting at each possible index in order.

        5↕"abcdefg"

There are `1+(≠𝕩)-𝕨`, or `(≠𝕩)¬𝕨`, of these sections, because the starting index must be at least `0` and at most `(≠𝕩)-𝕨`. Another way to find this result is to look at the number of cells in or before a given slice: there are always `𝕨` in the slice and there are only `≠𝕩` in total, so the number of slices is the range spanned by these two endpoints.

You can take a slice of an array `𝕩` that has length `l` and starts at index `i` using `l↑i↓𝕩` or `l↑i⌽𝕩`. The [Prefixes](prefixes.md) function returns all the slices that end at the end of the array (`(≠𝕩)=i+l`), and Suffixes gives the slices that start at the beginning (`i=0`). Windows gives yet another collection of slices: the ones that have a fixed length `l=𝕨`. Selecting one cell from its result gives you the slice starting at that cell's index:

        2⊏5↕"abcdefg"
        5↑2↓"abcdefg"

Windows differs from Prefixes and Suffixes in that it doesn't add a layer of nesting (it doesn't enclose each slice). This is possible because the slices have a fixed size.

### Multiple dimensions

The above description applies to a higher-rank right argument. As an example, we'll look at two-row slices of a shape `3‿4` array. For convenience, we will enclose each slice. Note that slices always have the same rank as the argument array.

        <⎉2 2↕"0123"∾"abcd"≍"ABCD"

Passing a list as the left argument to Windows takes slices along any number of leading axes. Here are all the shape `2‿2` slices:

        <⎉2 2‿2↕"0123"∾"abcd"≍"ABCD"

The slices are naturally arranged along multiple dimensions according to their starting index. Once again the equivalence `i⊏l↕x` ←→ `l↑i↓x` holds, provided `i` and `l` have the same length.

If the left argument has length `0`, then the argument is not sliced along any dimensions. The only slice that results—the entire argument—is then arranged along an additional zero dimensions. In the end, the result is the same as the argument.

### More formally

`𝕩` is an array. `𝕨` is a number or numeric list or scalar with `𝕨≤○≠≢𝕩`. The result `z` has shape `𝕨∾¬⟜𝕨⌾((≠𝕨)⊸↑)≢𝕩`, and element `i⊑z` is `𝕩⊑˜(≠𝕨)(↑+⌾((≠𝕨)⊸↑)↓)i`.

Using [Group](group.md) we could also write `i⊑z` ←→ `𝕩⊑˜(𝕨∾○(↕∘≠)≢𝕩) +´¨∘⊔ i`.

## Symmetry

Let's look at an earlier example, along with its transpose.

        {⟨𝕩,⍉𝕩⟩}5↕"abcdefg"

Although the two arrays have different shapes, they are identical where they overlap.

        ≡○(3‿3⊸↑)⟜⍉5↕"abcdefg"

In other words, the i'th element of slice j is the same as the j'th element of slice i: it is the `i+j`'th element of the argument. So transposing still gives a possible result of Windows, but with a different slice length.

        {(5↕𝕩)≡⍉(3↕𝕩)}"abcdefg"

In general, we need a more complicated transpose—swapping the first set of `≠𝕨` axes with the second set. Note again the use of Span, our slice-length to slice-number converter.

        {((5‿6¬2‿2)↕𝕩) ≡ 2‿3⍉(2‿2↕𝕩)} ↕5‿6‿7

## Applications

Windows can be followed up with a reduction on each slice to give a windowed reduction. Here we take running sums of 3 values.

        +´˘3↕ ⟨2,6,0,1,4,3⟩

A common task is to pair elements, with an initial or final element so the total length stays the same. This can also be done with a pairwise reduction, but another good way (and more performant without special support in the interpreter) is to add the element and then use windows matching the original length. Here both methods are used to invert `` +` ``, which requires we take pairwise differences starting at initial value 0.

        -˜´˘2↕0∾ +` 3‿2‿1‿1
        ((-˜´<˘)≠↕0∾⊢) +` 3‿2‿1‿1

This method extends to any number of initial elements. We can modify the running sum above to keep the length constant by starting with two zeros.

        ((+´<˘)≠↕(2⥊0)⊸∾) ⟨2,6,0,1,4,3⟩
