*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/shape.html).*

# Array dimensions

The function Shape (`≢`) returns an array's shape, and Rank (`=`) and Length (`≠`) return properties that can be derived from the shape. BQN's [arrays](array.md) are multidimensional, so that the shape is a list of natural numbers (the length along each axis), while the rank (length of the shape) and length (of the first axis) are numbers. In these functions, an atom is treated as a unit array, which has rank 0 and empty shape. A unit has no first axis, but its length is defined to be 1.

Rank can be defined as `≠∘≢` while Length can be defined with a [fold](fold.md) to be `1⊣´≢`.

## Examples

The function [Reshape](reshape.md) (`⥊`) always returns an array of shape `𝕨`, so we use it to make an array of shape `1‿3‿2‿6` in the example below ([Take](take.md) (`↑`) shares this property if `(≠𝕨)≥=𝕩`).

        ⊢ arr ← 1‿3‿2‿6 ⥊ '0'+↕10

        ≢ arr  # Shape

        ≠ arr  # Length

        = arr  # Rank

The length is the first element of the shape, and the rank is the length of the shape—the number of axes. For another example, taking the first (and only) cell of `arr` gives an array with shape `3‿2‿6`, length `3`, and rank `3`, as we can see by applying [each](map.md#each) function to `⊏arr`.

        ≢‿=‿≠ {𝕎𝕩}¨< ⊏arr

Applying Shape and the other two functions to an atom shows a shape of `⟨⟩` (the empty list), and a rank of zero and length of 1. The same is true of an enclosed array, which like an atom is a kind of unit.

        ≢ 5

        (= ≍ ≠) 5

        (= ≍ ≠) <↕10

## Units

A [unit](enclose.md#whats-a-unit) is an atom, or an array with no axes—rank 0. Since it doesn't have any axes, its shape should have no elements. It should be the empty list `⟨⟩` (with a [fill](fill.md) of `0`, like all shapes). As there's no first element in the shape, it's not obvious what the length should be, and a stricter language would just give an error. However, there are some good reasons to use a length of `1`. First, the total number of elements is 1, meaning that if the length divides this number evenly (as it does for non-unit arrays) then the only possible natural number it can be is 1. Second, many functions that take a list for a particular argument also accept a unit, and treat it as a length-1 array. For example, `5⥊a` and `⟨5⟩⥊a` are identical. Defining `≠5` to be `1` means that `=s⥊a` is always `≠s`.

Despite this last point, it's important to remember that a unit isn't the same as a 1-element list. For example, the length-1 string `"a"` doesn't match `<'a'` but instead `⟨'a'⟩`. And also bear in mind that having an empty *shape* doesn't make a unit an empty *array*. That would mean it has no elements, not one!

Value          | Shape  | Rank | Length
---------------|--------|------|-------
Unit           | `⟨⟩`   | `0`  | `1`
1-element list | `⟨1⟩`  | `1`  | `1`
Empty list     | `⟨0⟩`  | `1`  | `0`

These three kinds of array are distinguished in the table above. A related fact is that repeating the Shape function three times (`≢⍟3`) always gives `⟨1⟩`: the first time returns a list, the second a 1-element list, and the third that specific list. Another comment is that there's no value with rank 0 *and* length 0. An rank-0 array is a unit by definition, so it has length 1.
