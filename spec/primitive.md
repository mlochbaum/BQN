*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/primitive.html).*

# Specification: BQN primitives

Most primitives are specified by the BQN-based implementation in [reference.bqn](reference.bqn). This document specifies the basic functionality required by those definitions. Descriptions of other primitives are for informational purposes only.

## Pervasive primitives

Functions in this section are defined for atoms only; the reference implementations extend them to arrays.

### Arithmetic

BQN uses five arithmetic functions that are standard in mathematics. The precision of these operations should be specified by the number [type](types.md).

- **Add** `+`
- **Negate** and **Subtract** `-` invert addition, with `-𝕩` equivalent to `0-𝕩`.
- **Multiply** `×` generalizes repeated addition.
- **Divide** and **Reciprocal** `÷` invert multiplication, with `÷𝕩` equivalent to `1÷𝕩`.
- **Power** `⋆` generalizes repeated multiplication, and **Exponential** `⋆` is Power with Euler's number *e* as the base.

The three higher functions `×`, `÷`, and `⋆` apply to numbers and no other atomic types. `+` and `-` apply to numbers, and possibly also to characters, according to the rules of the affine character type:

- If one argument to `+` is the character with code point `c` and the other is a number `n` (in either order), then the result is the character with code point `c+n`.
- If the left argument to `-` is the character with code point `c` and the right is a number `n`, the result is the character with code point `c-n`.
- If both arguments to `-` are characters, the result is the difference of their respective code points.

In the first two cases, if the result would not be a valid Unicode code point, then an error results. The remaining cases of `+` and `-` (adding two characters; negating a character or subtracting it from a number) are not allowed.

Additionally, the **Floor** function `⌊` returns the largest integer smaller than or equal to the argument, or the argument itself if it is `¯∞` or `∞`. It's needed because the arithmetic operations give no fixed-time way to determine if a value is an integer. Floor gives an error if the argument is an atom other than a number.

### Comparison

Two kinds of comparison are needed to define BQN's primitives: *equality* comparison and *ordered* comparison.

Ordered comparison is simpler and is provided by the dyadic Less than or Equal to (`≤`) function. This function gives an error if either argument is an operation, so it needs to be defined only for numbers and characters. For numbers it is defined by the number system, and for characters it returns `1` if the left argument's code point is less than that of the right argument. Characters are considered greater than numbers, so that `n≤c` is `1` and `c≤n` is `0` if `c` is a character and `n` is a number.

The dyadic function `=`, representing equality comparison, can be applied to any two atoms without an error. Roughly speaking, it returns `1` if they are indistinguishable within the language and `0` otherwise. If the two arguments have different types, the result is `0`; if they have the same type, the comparison depends on type:
- Equality of numbers is specified by the number type.
- Characters are equal if they have the same code point.

Operations are split into subtypes depending on how they were created.
- Primitives are equal if they have the same token spelling.
- Derived operations are equal if they are derived by the same rule and each corresponding component is the same.
- Block instances are equal if they are the same instance.

This means that block instance equality indicates identity in the context of mutability: two block instances are equal if any change of state in one would be reflected in the other as well. The concept of identity holds even if the blocks in question have no way of changing or accessing state. For example, `=○{𝕩⋄{𝕩}}˜@` is `0` while `=˜○{𝕩⋄{𝕩}}@` is `1`.

## Array functionality

Several subsets of primitives, or dedicated operations, are used to manipulate arrays in the reference implementation.

- `IsArray` returns `1` if the argument is an array and `0` if it's an atom.

The following functions translate between arrays and the two lists that define them: the shape and ravel.

- **Shape** (`≢`) returns the shape of array `𝕩`, as a list of natural numbers.
- **Deshape** (monadic `⥊`) returns the ravel of array `𝕩`, that is, the list of its elements.
- **Reshape** (dyadic `⥊`) returns an array with the same ravel as `𝕩` with shape `𝕨`. It can be assumed that `≢𝕩` and `𝕨` have the same product.

The following functions manipulate lists. In these functions, a valid index for list `l` is a natural number less than the length of `l`.

- **Range** gives the list of length `𝕩` (a natural number) with value `i` at any index `i`.
- **Pick** (`⊑`) selects the element at index `𝕨` from list `𝕩`.
- `_amend` returns an array identical to list `𝕩` except that the element at index `𝕗` is changed to `𝕨`.

## Inferred functionality

Inferred properties are specified in [their own document](inferred.md), not in the reference implementation.

- `Identity` gives the identity value for reduction by function `𝕏`.
- **Undo** (`⁼`) gives a partial right inverse for function `𝔽`.
- `Fill` gives the enclose of the fill value for array `𝕩`.

## Other provided functionality

- **Assert** (`!`) causes an error if `𝕩` is not `1`. The message associated with the error (which is not used by core BQN but might be shown to the user or used by system functions) is `𝕨` if given and `𝕩` otherwise. It can be any value, not just a string.

- **Catch** (`⎊`) evaluates `𝔽` on the arguments `𝕨` (if present) and `𝕩`. If `𝔽` completes without error it returns the result, but if evaluation of `𝔽` results in an error then the error is suppressed, and Catch evaluates `𝔾` on the arguments and returns the result. Errors in `𝔾` are not caught. Catch only prevents evaluation errors, and not syntax errors: these are considered errors in the program as a whole rather than any particular part of it.

## Commentary on other primitives

As noted above, see [reference.bqn](reference.bqn) for the authoritative definitions. Commentary here gives an overall description and highlights implementation subtleties and edge cases.

### Combinators

There's little to say about BQN's true combinators, since each is simply a pattern of function application. All primitive combinators use their operands as functions, and thus treat a data operand as a constant function.

- **Choose** (`◶`) is later redefined to use the complete `⊑` rather than the simple version assumed (using this primitive means it's not a true combinator).
- **Constant** (`˙`)
- **Valences** (`⊘`) uses a trick with ambivalent `-` to find out whether there's a left argument, described below.
- **Right** (`⊢`)
- **Left** (`⊣`)
- **Self**/**Swap** (`˜`)
- **Atop** (`∘`)
- **Over** (`○`)
- **Before**/**Bind** (`⊸`)
- **After**/**Bind** (`⟜`)

The somewhat complicated definition of Valences could be replaced with `{𝔽𝕩;𝕨𝔾𝕩}` using headers. However, reference.bqn uses a simple subset of BQN's syntax that doesn't include headers. Instead, the definition relies on the fact that `𝕨` works like `·` if no left argument is given: `(1˙𝕨)-0` is `1-0` or `1` if `𝕨` is present and `(1˙·)-0` otherwise: this reduces to `·-0` or `0`.

### Array properties

The reference implementations extend Shape (`≢`) to atoms as well as arrays, in addition to implementing other properties. In all cases, an atom behaves as if it has shape `⟨⟩`. The functions in this section never cause an error.

- **Shape** (`≢`) gives the shape of an array or atom.
- **Rank** (`=`) gives the length of the shape.
- **Length** (`≠`) gives the number of major cells, or `1` for an argument of rank `0`.
- **Depth** (`≡`) gives the nesting depth. It ignores the shapes of arrays, and considering only the depths of their elements.

### Arithmetic

Arithmetic functions not already provided are defined in layer 1. These definitions, like the provided functions, apply to atoms only; they should be extended to arrays using the `_perv` modifier from layer 2.

- **Sign** (`×`) 
- **Square Root** and **Root** (`√`) are defined in terms of Power. If a dedicated implementation is used for square roots, then Power should check for a right argument of `0.5` and use this implementation in order to maintain consistency.
- **Ceiling** (`⌈`) is like Floor, but rounds up instead of down.
- **Not** (`¬`) is a linear extension of logical negation, and **Span** (`¬`) adds the left argument.
- **And** (`∧`) and **Or** (`∨`) are bilinear extensions of the boolean functions.
- **Minimum** (`⌊`) and **Maximum** (`⌈`) return the smaller or larger of the arguments, respectively. They are *not required* to be implemented for character arguments, and may give an error if either argument is a character.
- **Absolute Value** (`|`)
- **Modulus** (`|`) is an extension of modular division to real numbers. As it uses floor instead of truncation, it's not the same as the `%` operator from C or other languages when `𝕨<0`.
- Comparisons **Less Than** (`<`), **Greater Than** (`>`), **Greater Than or Equal to** (`≥`), and **Not Equals** (`≠`) are defined in terms of the two provided comparisons.

### Iteration modifiers

Modifiers for iteration are defined in layers 1, 2, and 4. Two 2-modifiers, `⚇` and `⎉`, use a list of numbers obtained by applying the right operand to the arguments in order to control application. This list has one to three elements: if all three are given then they correspond to the monadic, left, and right arguments; if one is given then it controls all three; and if two are given then they control the left argument, and the right and monadic arguments.

The iteration modifiers `⌜¨⚇˘⎉` process elements or cells in index order, that is, according to lexicographic ordering of indices or according to simple numeric ordering of the indices in the Deshaped (`⥊`) arguments. When both arguments are mapped over independently, the left argument is mapped over "first", or as an outer loop: one part of the left argument is paired with each part of the right in turn, then the next part of the left argument, and so on.

**Table** (`⌜`) and **Each** (`¨`) map over the elements of arrays to produce result elements. They convert atom arguments to unit arrays. With one argument, the two modifiers are the same; with two, they differ in how they pair elements. Table pairs every element of the left argument with every element of the right, giving a result shape `𝕨∾○≢𝕩`. Each uses leading axis agreement: it requires one argument's shape to be a prefix of the other's (if the arguments have the same rank, then the shapes must match and therefore be mutual prefixes). This causes each element of the lower-rank argument to correspond to a cell of the higher-rank one; it's repeated to pair it with each element of that cell. The result shape is the shape of the higher-rank argument.

**Depth** (`⚇`) is nearly a generalization of Each: `¨` is equivalent to `⚇¯1`, except that `⚇¯1` doesn't enclose its result if all arguments are atoms. The list given by the right operand specifies how deeply to recurse into the arguments. A negative number `-n` means to recurse `n` times *or* until the argument is an atom, while a positive number `n` means to recurse until the argument has depth `n` or less. Recursion continues until all arguments have met the criterion for stopping. This recursion is guaranteed to stop because arrays are immutable, and form an inductive type.

**Rank** (`⎉`) applies the left operand to cells of the arguments of the specified ranks, forming a result whose cells are the results. **Cells** (`˘`) is identical to `⎉¯1`, and applies to major cells of the arguments, where a value of rank less than 1 is considered its own major cell. All results must have the same shape, as with elements of the argument to Merge (`>`). The combined result is always an array, but results of the left operand can be atoms: an atom result will be enclosed to give a 0-cell. If a specified rank is a natural number `n`, Rank applies the operand to `n`-cells of the corresponding argument, or the entire argument if it has rank less than or equal to `n`. If instead it's a negative integer `-n`, then an effective rank of `0⌈k-n` is used, so that the entire argument is used exactly when `k=0`. Thus an atom will always be passed unchanged to the operand; in particular, Rank does not enclose it. Like Each, Rank matches cells of its arguments according to leading axis agreement, so that a cell of one argument might be paired with multiple cells of the other.

**Fold** (`´`), **Insert** (`˝`), and **Scan** (`` ` ``) repeatedly apply a function between parts of an array. Fold requires the argument to have rank 1 and applies the operand between its elements, while Insert requires it to have rank 1 or more and applies it between the cells. For each of these two functions, the operand is applied beginning at the end of the array, and an [identity](inferred.md#identities) value is returned if the array is empty. While these functions reduce multiple values to a single result, Scan returns many results and preserves the shape of its argument. It requires the argument to have rank at least 1, and applies the function between elements along columns—that is, from one element in a major cell to the one in the same position of the next major cell. This application begins at the first major cell of the array. Scan never uses the identity element of its operand because if the argument is empty then the result, which has the same shape, will be empty as well.

A left argument for any of the three reduction-based modifiers indicates an initial value to be used, so that the first application of the operand function applies not to two values from `𝕩` but instead to a value from `𝕨` and a value from `𝕩`. In Fold and Insert, the entire value `𝕨` is the initial value, while in Scan, `𝕨` is an array of initial values, which must have shape `1↓≢𝕩`.

**Repeat** (`⍟`) applies the operand function, or its [inverse](inferred.md#undo), several times in sequence. The right operand must consist only of integer atoms (arranged in arrays of any depth), and each number there is replaced with the application of the left operand that many times to the arguments. If a left argument is present, then it's reused each time, as if it were bound to the operand function. For a negative number `-n`, the function is "applied" `-n` times by undoing it `n` times. In both directions, the total number of times the function is applied is the maximum of all numbers present: results must be saved if intermediate values are needed.

### Restructuring

**Enclose** (`<`) forms a unit array that contains its argument. **Enlist** and **Pair** (`⋈`) form a 1- or 2-element list of all arguments, that is, `⟨𝕩⟩` or `⟨𝕨,𝕩⟩`.

**Merge** (`>`) combines the outer axes of an array of arrays with inner axes: it requires that all elements of its argument have the same shape, and creates an array such that `(i∾j)⊑>𝕩` is `i⊑j⊑𝕩`. It also accepts atom elements of `𝕩`, converting them to unit arrays, or an atom argument, which is returned unchanged. **Solo** and **Couple** (`≍`) turn one or two arguments into major cells of the result and can be defined easily in terms of Merge.

**Join To** (`∾`) combines its two arguments along an existing initial axis, unless both arguments are units, in which case it creates an axis and is identical to Couple (`≍`). The arguments must differ in rank by at most 1, and the result rank is equal to the maximum of 1 and the higher argument rank. Each argument with rank less than the result, and each major cell of an argument with rank equal to it, becomes a major cell of the result, with cells from the left argument placed before those from the right. **Join** (`∾`) generalizes this behavior to an array of values instead of just two. The argument must be an array (unlike Merge), and atom elements are treated as unit arrays. "Outer" argument axes are matched up with leading "inner" element axes, and elements are joined along these axes. In order to allow this, the length of an element along a particular axis must depend only on the position along the corresponding axis in the argument. However, the axis may also be omitted, resulting in an uneven rank among arguments of `𝕩`. At least one position must have the axis, so that whether a given element has it can be found by comparing it to others along that axis. Along an axis, ranks can differ by at most one because each element either has or omits that axis. If the argument to Join is empty, the result is an empty array with shape computed based on an array of fill elements: the fill rank must be greater than the rank of `𝕩`, and the result shape is computed by multiplying leading lengths of the fill shape by `≢𝕩`, with the trailing shape unchanged.

**Deshape** (`⥊`) differs from the provided function (which returns the element list of an array) only in that it accepts an atom, returning a one-element list containing it. **Reshape** (`⥊`) is extended in numerous ways. It accepts any list of natural numbers (including as a unit array or atom) for the left argument and any right argument; `𝕩` is deshaped first so that it is treated as a list of elements. These elements are repeated cyclically to fill the result array in ravel order. If `𝕩` is empty then a non-empty requested result shape causes an error. Furthermore, at most one element of `𝕨` can be a "length code": one of the primitives `∘⌊⌽↑`. In this case, a target length is computed from the number of elements in `𝕩` divided by the product of the other elements of `𝕨` (which must not be zero). If the target length is an integer then it is used directly for the length code. Otherwise, an error is given if the length code is `∘`, and the target length is rounded down if the code is `⌊` and up if it's `⌽` or `↑`. With code `⌽`, elements are repeated cyclically as usual, but with code `↑`, the extra elements after each argument element is used are fill values for `𝕩`.

**Transpose** (`⍉`) reorders axes of its argument to place the first axis last; if the argument has one or fewer axes then it's enclosed if it's an atom and otherwise returned unchanged. **Reorder Axes** (`⍉`) requires the left argument to be a list or unit of natural numbers, with length at most the rank of the right argument. This list is extended to match the right argument rank exactly by repeatedly appending the least unused natural number (for example, given `1‿3‿0‿0`, `2` is appended). After extension, it specifies a result axis for each axis of the right argument. There must be no gaps in the list: that is, with the result rank equal to one plus the greatest value present, every result axis must appear at least once. Now each argument axis is "sent to" the specified result axis: in terms of indices, `i⊑𝕨⍉𝕩` is `(𝕨⊏i)⊑𝕩` if `𝕨` is complete. If multiple argument axes correspond to the same result axis, then a diagonal is taken, and it's as long as the shortest of those argument axes. Like Transpose, Reorder Axes encloses `𝕩` if it's an atom, so that its result is always an array.

### Indices and selection

Each element in an array `s⥊e` is associated with an *index*, which is a list of natural numbers `i` such that `∧´i<s`. The list of all indices, which corresponds to the element list `e`, contains all such lists `i` in lexicographic order. That is, index `i` comes before `j` exactly when the two indices are not the same, and `i` has the smaller value at the first position where they are unequal. The index of an element along a particular axis `a` is the value `a⊑i`.

**Range** (`↕`) is extended to apply to a list of natural numbers, in addition to the provided case of a single natural number (an enclosed natural number `𝕩` should still result in an error). For a list `𝕩`, the result is an array of shape `𝕩` in which the value at a given index is that index, as a list of natural numbers. That is, `i≡i⊑↕𝕩` for any list of natural numbers `i` with `∧´i<𝕩`.

**Pick** (`⊑`) is extended to array left arguments. In this case, it requires every depth-1 array in the nested structure of `𝕨` to be a valid index list for `𝕩`, and every atom to be contained in one of these lists. The result is `𝕨` with each index list replaced by the element of `𝕩` at that index. In the simple case where `𝕨` itself is an index list, the result is the element of `𝕩` at index `𝕨`.

**First** (`⊑`) simply takes the first element of its argument in index order, with an error if `𝕩` is empty.

For **Select** (`⊏`), `𝕨` is an array of natural numbers, or a list of such arrays; if it's an empty list, it's interpreted as the former. The given arrays are matched with leading axes of `𝕩` and used to select from those axes. Their shape is retained, so that the final shape is the combined shapes of each array of natural numbers in `𝕨` in order, followed by the trailing (unmatched) shape of `𝕩`. This means that a single axis in `𝕩` can correspond to any number of axes in `𝕨⊏𝕩`, depending on the rank of that portion of `𝕨`. More precisely, the value of the result at an index `j` is obtained by splitting `j` into one index into each array of `𝕨` followed by a partial index into `𝕩`. An index `i` for `𝕩` comes from selecting from each array of `𝕨` and appending the results to the partial index from `j`, and the value `i⊑𝕩` is `j⊑𝕨⊏𝕩`.

**First Cell** (`⊏`) selects the initial major cell of `𝕩`, giving an error if `𝕩` has rank 0 or length 0.

**Group** (`⊔`) performs an opposite operation to Select, so that `𝕨` specifies not the argument index that result values come from, but the result index that argument values go to. The general case is that `𝕨` is a list of arrays of numbers; if it has depth less than 2 it's converted to this form by first enclosing it if it's an atom, then placing it in a length-1 list. After this transformation, the result rank is `≠𝕨`, and each result element has rank `(≠𝕨)+(=𝕩)-+´=¨𝕨`, with the initial `≠𝕨` axes corresponding to elements of `𝕨` and the remainder to trailing axes of `𝕩`. Each atom in `𝕨` can be either a natural number or `¯1` (which indicates the corresponding position in `𝕩` will be omitted). If `¯1` doesn't appear, the result has the property that each cell of `𝕩` appears in the corresponding element of `𝕨⊏𝕨⊔𝕩`. More concretely, the length of the result along axis `a` is the maximum value in `a⊑𝕨` plus one, or zero if `a⊑𝕨` is empty. Axis `a` corresponds to `=a⊑𝕨` axes in `𝕩`, and an element of the result at position `i` along this axis contains all positions in `𝕩` where `i=a⊑𝕨`. There may be multiple such positions, and they're arranged along axis `a` of that result element according to their index order in `𝕩`. The shapes of components of `𝕨` must match the corresponding axes of `𝕩`, except for rank-1 components of `𝕨`, which can match or have an extra element. This element, which like the others is either a natural number or `¯1`, gives the minimum length of the result axis corresponding to the component of `𝕨` in question, but otherwise does not affect the result. **Group Indices** treats its argument `𝕩` as a left argument for Group and uses a right argument made up of indices, which is `↕≠𝕩` if `𝕩` has depth 1 and `↕∾≢¨𝕩` if it has depth 2. Because the depth-1 case uses atomic indices, `𝕩` is required to be a list (and it can't be an atom). Much like Range, the result has depth one higher than the argument.

**Indices** (`/`) applies to a list of natural numbers, and returns a list of natural numbers. The result contains `i⊑𝕩` copies of each natural number index `i` for `𝕩`, in increasing order.

### Structural manipulation

Monadic structural functions work on the first axis of the argument, so they require it to have rank at least 1. **Reverse** (`⌽`) reverses the ordering of the major cells of `𝕩`. **Nudge** (`»`) shifts them forward, removing the last and placing a major cell made up of fill elements at the beginning, while **Nudge Back** (`«`) does the same in the reverse direction, so it removes the first cell and places fills at the end. **Prefixes** (`↑`) and **Suffixes** (`↓`) each return lists with length one higher than `𝕩`, whose elements are arrays with the same rank as `𝕩`. For Prefixes, the element of the result at index `i` contains the first `i` major cells of `𝕩` in order, and for Suffixes, it contains all but these major cells.

The remainder of the functions discussed in this section are dyadic. For all of these, an atom value for `𝕩` is treated as an array by enclosing it before acting, so that the result is never an atom. There are four functions for which `𝕨` is a list of whole numbers—but an atomic number or enclosed number is also permitted, and treated as a 1-element list—and its elements are matched with leading axes of `𝕩`. These functions independently manipulate each axis: one way to define such a process is to consider lists running along the axis, where every element of the index is fixed except one. A change to this axis retains the fixed indices, but can move elements from one location to another along the variable index, add fill elements, or split the axis into two axes. A change to a different axis can rearrange these lists along the original axis, but can't affect the placement of elements within them. In the reference implementations, working on leading axes is accomplished using the Cells (`˘`) modifier recursively, so that action on the first axes doesn't use Cells, on the next is affected by Cells once, then twice, and so on.

**Rotate** (`⌽`) is the simplest of these four functions: each element of `𝕨` gives an amount to rotate the corresponding axis, where a rotation of `r` moves the element at index `i+r` to `i` when all indices are taken modulo the length of the axis. **Windows** (`↕`) splits each axis of `𝕩` that corresponds to an element of `𝕨` in two, so that the result has one set of axes corresponding to elements of `𝕨`, then another, then the unchanged trailing axes. The second set of axes has lengths given by `𝕨` (which must consist of natural numbers), while the first has lengths `s¬𝕨`, where `s` contains the lengths of leading axes of `𝕩`. Position `i` in the first set of axes and `j` in the second corresponds to `i+j` in the argument, so that fixing one of these positions and varying the other gives a slice of the argument. In both Rotate and Windows, the length of `𝕨` is at most the rank of `𝕩`.

**Take** (`↑`) offers several possibilities. The absolute value of `𝕨` gives the final lengths of the axes in the result. It may be positive to indicate that the axis aligns with `𝕩` at the beginning, or negative to indicate it aligns at the end. A zero value gives no result elements, so there is no need to consider alignment. If the absolute value of an element of `𝕨` is smaller than or equal to the corresponding length in `𝕩`, then the first or last few elements are taken along that axis. If it is larger, then instead fill elements are added to the end (if positive) or beginning (if negative) to make up the difference in length. **Drop** (`↓`) gives `𝕨` a similar meaning, but excludes all elements that Take includes (maintaining the order of the retained ones). The result of Drop never uses fill elements. In a case where Take would use fill elements, it would include all positions from `𝕩`, so Drop should include none of them, and the result will have length `0` for that axis. Take and Drop are extended to allow an argument with length greater than the rank of `𝕩`. In this case leading length-1 axes are added to `𝕩` so that its rank matches `𝕨` before taking or dropping.

**Replicate** (`/`) is similar to the four dyadic structural functions above, but `𝕨` gives a list of containing *lists* of natural numbers, or plain or enclosed natural numbers, instead of a simple list. If `𝕨` has depth less than `2`, it's considered to be a single value corresponding to one axis of `𝕩`, while if it has depth `2` then it's a list of values. If `𝕨` is the empty list `⟨⟩` then it is defined to be in the second case despite having a depth of `1`. On a single axis of `𝕩` the corresponding value `r` from `𝕨` is either a list or a unit: if it's a unit then it is repeated to match the length of that axis of `𝕩`, and if it's a list it must already have the same length as that axis. Each number in `r` now specifies the number of times to repeat the corresponding position in `𝕩`. This is equivalent to calling Indices on `r` and using the result for selection.

**Shift Before** (`»`) and **Shift After** (`«`) are derived from Join To and share most of its behavior. The difference is that only a portion of the result of Join To is returned, matching the length of `𝕩`. This portion comes from the beginning for Shift Before and the end for Shift After. The only difference in conditions between the shift functions and Join To is that Join To allows the result to have higher rank than `𝕩`. Shifts do not, so the rank of `𝕩` be at least 1 and at least as high as `𝕨`.

### Searching

**Match** (`≡`) indicates whether two values are considered equivalent. It always returns 0 or 1, and never causes an error. If both arguments are atoms then it is identical to `=`, and if one is an atom and the other an array then it returns 0. If both arguments are arrays then it returns 1 only if they have the same shape and all pairs of corresponding elements match. Fill elements aren't taken into account, so that arrays that match might still differ in behavior. **Not Match** simply returns the complement of Match, `¬≡`.

Monadic search functions compare the major cells of `𝕩` to each other. `𝕩` must have rank at least 1. Except for Deduplicate (`⍷`), the result is a list of numbers with the same length as `𝕩`.

- **Mark Firsts** (`∊`) returns 1 for a cell if it doesn't match any earlier cell and 0 if it does.
- **Deduplicate** (`⍷`) filters major cells to remove duplicates, retaining the ordering given by the first appearance of each unique cell.
- **Classify** (`⊐`) returns, for each cell, the smallest index of a cell that matches it (it's necessarily less than or equal to `↕≠𝕩` element-wise, since each cell matches itself).
- **Occurrence Count** (`⊒`) returns the number of earlier cells matching each cell.

Dyadic search functions check whether major cells of the *principal argument* (which must have rank at least 1) match cells of the *non-principal argument* of the same rank. The rank of the non-principal argument can't be less than the major cell rank (rank minus one) of the principal argument. However, the non-principal argument can be an atom, in which case it will be automatically enclosed. The principal argument is `𝕨` for `⊐` and `⊒` and `𝕩` for `∊`. The result is an array containing one number for each cell of the non-principal argument. The value of this number depends on the function:
- **Member of** (`∊`) indicates whether any cell of the principal argument matches the cell in question.
- **Index of** (`⊐`) gives the smallest index of a principal argument cell that matches the cell, or `≠𝕨` if there is no such cell.
- **Progressive Index of** (`⊒`) processes non-principal cells in ravel order, and gives the smallest index of a principal argument cell that matches the cell that hasn't already been included in the result. Again `≠𝕨` is returned for a given cell if there is no valid cell.

**Find** (`⍷`) indicates positions where `𝕨` appears as a contiguous subarray of a `=𝕨`-cell of `𝕩`. It has one result element for each such subarray of `𝕩`, whose value is 1 if that subarray matches `𝕩` and 0 otherwise. Find cannot result in an error unless the rank of `𝕨` is higher than that of `𝕩`. If `𝕨` is longer along one axis than the corresponding trailing axis of `𝕩`, then the result has length 0 along that axis. Any atom argument to Find is automatically enclosed.

### Sorting

Sorting functions are those that depend on BQN's array ordering. There are three kinds of sorting function, with two functions of each kind: one with an upward-pointing glyph that uses an ascending ordering (these function names are suffixed with "Up"), and one with a downward-pointing glyph and the reverse, descending, ordering ("Down"). Below, these three kinds of function are described, then the ordering rules. Except for the right argument of Bins, all arguments must have rank at least 1.

**Sort** (`∧∨`) reorders the major cells of its argument so that a major cell with a lower index comes earlier in the ordering than a major cell with a higher index, or matches it. If it's possible for matching arrays to differ in behavior because of different (including undefined versus defined) fill elements, then these arrays must maintain their ordering (a stable sort is required).

**Grade** (`⍋⍒`) returns a permutation describing the way the argument array would be sorted. For this reason the reference implementations simply define Sort to be selection by the grade. One way to define Grade is as a sorted version of the index list `↕≠𝕩`. An index `i` is ordered according to the corresponding major cell `i⊏𝕩`. However, ties in the ordering are broken by ordering the index values themselves, so that no two indices are ever considered equal, and the result of sorting is well-defined (for Sort this is not an issue—matching cells are truly interchangeable). This property means that a stable sorting algorithm must be used to implement Grade functions. While cells might be ordered ascending or descending, indices are always ordered ascending, so that for example index `i` is placed before index `j` if either `i⊏𝕩` comes earlier in the ordering than `j⊏𝕩`, or if they match and `i<j`.

**Bins** (`⍋⍒`) requires the `𝕨` to be ordered in the sense of Sort (with the same direction). Like a dyadic search function, it then works on cells of `𝕩` with the same rank as major cells of `𝕨`: the rank of `𝕩` cannot be less than `(=𝕨)-1`. For each of these, it identifies where in the ordering given by `𝕨` the cell belongs, that is, the index of the first cell in `𝕨` that is ordered later than it, or `≠𝕨` if no such cell exists. An equivalent formulation is that the result value for a cell of `𝕩` is the number of major cells in `𝕨` that match or precede it.

BQN's *array ordering* is an extension of the number and character ordering given by `≤` to arrays. In this system, any two arrays consisting of only numbers and characters for atoms can be compared with each other. Furthermore, some arrays that contain incomparable atoms (operations) might be comparable, if the result of the comparison can be decided before reaching these atoms. Array ordering does not depend on the fill elements for the two arguments.

Here we define the array ordering using the terms "smaller" and "larger". For functions `∧⍋`, "earlier" means "smaller" and "later" means "larger", while `∨⍒` use the opposite definition, reversing the ordering.

To compare two arrays, BQN first attempts to compare elements at corresponding indices, where two indices are considered to correspond if one is a suffix of the other. Elements are accessed in ravel order, that is, beginning at the all-zero index and first increasing the final number in the index, then the second-to-last, and so on. They are compared, using array comparison if necessary, until a non-matching pair of elements is found—in this case the ordering of this pair determines the ordering of the arrays—or one array has an index with no corresponding index in the other array. For example, comparing `4‿3‿2⥊1` with `2‿5⥊1` stops when index `0‿2` in `2‿5⥊1` is reached, because the corresponding index `0‿0‿2` is out of range. The index `0‿2‿0` in the other array also has no corresponding index, but comes later in the index ordering. In this case, the array that lacks the index in question is considered smaller.

If two arrays have the same shape (ignoring leading `1`s) and all matching elements, or if they are both empty, then the element-by-element comparison will not find any differences. In this case, the arrays are compared first by rank, with the higher-rank array considered larger, and then by shape, beginning with the leading axes.

To compare two atoms, array ordering uses `≤`: if `𝕨≤𝕩` then `𝕨` matches `𝕩` if `𝕩≤𝕨` and otherwise is smaller than `𝕩` (and `𝕩` is larger than `𝕨`). To compare an atom to an array, the atom is promoted to an array by enclosing it; however, if the enclosed atom matches the array then the atom is considered smaller.
