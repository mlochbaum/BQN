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

Additionally, the **Floor** function `⌊` returns the largest integer smaller than the argument, or the argument itself if it is `¯∞` or `∞`. It's needed because the arithmetic operations give no fixed-time way to determine if a value is an integer. Floor gives an error if the argument is an atom other than a number.

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

- **Assert** (`!`) causes an error if the argument is not `1`. If `𝕨` is provided, it gives a message to be associated with this error (which can be any value, not necessarily a string).

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

**Table** (`⌜`) and **Each** (`¨`) map over the elements of arrays to produce result elements. They convert atom arguments to unit arrays. With one argument, the two modifiers are the same; with two, they differ in how they pair elements. Table pairs every element of the left argument with every element of the right, giving a result shape `𝕨∾○≢𝕩`. Each uses leading axis agreement: it requires one argument's shape to be a prefix of the other's (if the arguments have the same rank, then the shapes must match and therefore be mutual prefixes). This causes each element of the lower-rank argument to correspond to a cell of the higher-rank one; it's repeated to pair it with each element of that cell. The result shape is the shape of the higher-rank argument.

**Depth** (`⚇`) is nearly a generalization of Each: `¨` is equivalent to `⚇¯1`, except that `⚇¯1` doesn't enclose its result if all arguments are atoms. The list given by the right operand specifies how deeply to recurse into the arguments. A negative number `-n` means to recurse `n` times *or* until the argument is an atom, while a positive number `n` means to recurse until the argument has depth `n` or less. Recursion continues until all arguments have met the criterion for stopping. This recursion is guaranteed to stop because arrays are immutable, and form an inductive type.

**Rank** (`⎉`) applies the left operand to cells of the arguments of the specified ranks, forming a result whose cells are the results. **Cells** (`˘`) is identical to `⎉¯1`, and applies to major cells of the arguments, where a value of rank less than 1 is considered its own major cell. All results must have the same shape, as with elements of the argument to Merge (`>`). The combined result is always an array, but results of the left operand can be atoms: an atom result will be enclosed to give a 0-cell. If a specified rank is a natural number `n`, Rank applies the operand to `n`-cells of the corresponding argument, or the entire argument if it has rank less than or equal to `n`. If instead it's a negative integer `-n`, then an effective rank of `0⌈k-n` is used, so that the entire argument is used exactly when `k=0`. Thus an atom will always be passed unchanged to the operand; in particular, Rank does not enclose it. Like Each, Rank matches cells of its arguments according to leading axis agreement, so that a cell of one argument might be paired with multiple cells of the other.

**Fold** (`´`), **Insert** (`˝`), and **Scan** (`` ` ``) repeatedly apply a function between parts of an array. Fold requires the argument to have rank 1 and applies the operand between its elements, while Insert requires it to have rank 1 or more and applies it between the cells. For each of these two functions, the operand is applied beginning at the end of the array, and an [identity](inferred.md#identities) value is returned if the array is empty. While these functions reduce multiple values to a single result, Scan returns many results and preserves the shape of its argument. It requires the argument to have rank at least 1, and applies the function between elements along columns—that is, from one element in a major cell to the one in the same position of the next major cell. This application begins at the first major cell of the array. Scan never uses the identity element of its operand because if the argument is empty then the result, which has the same shape, will be empty as well.

**Repeat** (`⍟`) applies the operand function, or its [inverse](inferred.md#undo), several times in sequence. The right operand must consist only of integer atoms (arranged in arrays of any depth), and each number there is replaced with the application of the left operand that many times to the arguments. If a left argument is present, then it's reused each time, as if it were bound to the operand function. For a negative number `-n`, the function is "applied" `-n` times by undoing it `n` times. In both directions, the total number of times the function is applied is the maximum of all numbers present: results must be saved if intermediate values are needed.

### Restructuring

**Enclose** (`<`) forms a unit array that contains its argument.

**Merge** (`>`) combines the outer axes of an array of arrays with inner axes: it requires that all elements of its argument have the same shape, and creates an array such that `(i∾j)⊑>𝕩` is `i⊑j⊑𝕩`. It also accepts atom elements of `𝕩`, converting them to unit arrays, or an atom argument, which is returned unchanged. **Solo** and **Couple** (`≍`) turn one or two arguments into major cells of the result and can be defined easily in terms of Merge.

**Join To** (`∾`) combines its two arguments along an existing initial axis, unless both arguments are units, in which case it creates an axis and is identical to Couple (`≍`). The arguments must differ in rank by at most 1, and the result rank is equal to the maximum of 1 and the higher argument rank. Each argument with rank less than the result, and each major cell of an argument with rank equal to it, becomes a major cell of the result, with cells from the left argument placed before those from the right. **Join** (`∾`) generalizes the equal-rank subset of this behavior to an array of values instead of just two. The argument must be an array (unlike Merge), and its elements must all the same rank, which is at least the argument rank. Atom elements are treated as unit arrays. Then "outer" argument axes are matched up with leading "inner" element axes, and elements are joined along these axes. In order to allow this, the length of an element along a particular axis must depend only on the position along the corresponding axis in the argument. An empty argument to Join is return unchanged, as though the element rank is equal to the argument rank.

**Deshape** (`⥊`) differs from the provided function (which returns the element list of an array) only in that it accepts an atom, returning a one-element list containing it. **Reshape** (`⥊`) is extended in numerous ways. It accepts any list of natural numbers (including as a unit array or atom) for the left argument and any right argument; `𝕩` is deshaped first so that it is treated as a list of elements. These elements are repeated cyclically to fill the result array in ravel order. If `𝕩` is empty but the result is not, then the result consists of fill elements for `𝕩`. Furthermore, at most one element of `𝕨` can be a "length code": one of the primitives `∘⌊⌽↑`. In this case, a target length is computed from the number of elements in `𝕩` divided by the product of the other elements of `𝕨` (which must not be zero). If the target length is an integer then it is used directly for the length code. Otherwise, an error is given if the length code is `∘`, and the target length is rounded down if the code is `⌊` and up if it's `⌽` or `↑`. With code `⌽`, elements are repeated cyclically as usual, but with code `↑`, the extra elements after each argument element is used are fill values for `𝕩`.

**Transpose** (`⍉`) reorders axes of its argument to place the first axis last; if the argument has one or fewer axes then it's returned unchanged. **Reorder Axes** (`⍉`) requires the left argument to be a list or unit of natural numbers, with length at most the rank of the right argument. This list is extended to match the right argument rank exactly by repeatedly appending the least unused natural number (for example, given `1‿3‿0‿0`, `2` is appended). After extension, it specifies a result axis for each axis of the right argument. There must be no gaps in the list: that is, with the result rank equal to one plus the greatest value present, every result axis must appear at least once. Now each argument axis is "sent to" the specified result axis: in terms of indices, `i⊑𝕨⍉𝕩` is `(𝕨⊏i)⊑𝕩` if `𝕨` is complete. If multiple argument axes correspond to the same result axis, then a diagonal is taken, and it's as long as the shortest of those argument axes. While Transpose does not enclose an atom right argument, Reorder Axes does, so that its result is always an array.

### Searching

**Match** (`≡`) indicates whether two values are considered equivalent. It always returns 0 or 1, and never causes an error. If both arguments are atoms then it is identical to `=`, and if one is an atom and the other an array then it returns 0. If both arguments are arrays then it returns 1 only if they have the same shape and all pairs of corresponding elements match. Fill elements aren't taken into account, so that arrays that match might still differ in behavior. **Not Match** simply returns the complement of Match, `¬≡`.

Monadic search functions compare the major cells of `𝕩` to each other. `𝕩` must have rank at least 1. Except for Unique (`⍷`), the result is a list of numbers with the same length as `𝕩`.

- **Unique Mask** (`∊`) returns 1 for a cell if it doesn't match any earlier cell and 0 if it does.
- **Deduplicate** (`⍷`) filters major cells to remove duplicates, retaining the ordering given by the first appearance of each unique cell.
- **Classify** (`⊐`) returns, for each cell, the smallest index of a cell that matches it (it's necessarily less than or equal to `↕≠𝕩` element-wise, since each cell matches itself).
- **Occurrence Count** (`⊒`) returns the number of earlier cells matching each cell.

Dyadic search functions check whether major cells of the *principal argument* (which must have rank at least 1) match cells of the *non-principal argument* of the same rank. The rank of the non-principal argument can't be less than the major cell rank (rank minus one) of the principal argument. However, the non-principal argument can be an atom, in which case it will be automatically enclosed. The principal argument is `𝕨` for `⊐` and `⊒` and `𝕩` for `∊`. The result is an array containing one number for each cell of the non-principal argument. The value of this number depends on the function:
- **Member of** (`∊`) indicates whether any cell of the principal argument matches the cell in question.
- **Index of** (`⊐`) gives the smallest index of a principal argument cell that matches the cell, or `≠𝕨` if there is no such cell.
- **Progressive Index of** (`⊒`) processes non-principal cells in ravel order, and gives the smallest index of a principal argument cell that matches the cell that hasn't already been included in the result. Again `≠𝕨` is returned for a given cell if there is no valid cell.

**Find** (`⍷`) indicates positions where `𝕨` appears as a contiguous subarray of a `=𝕨`-cell of `𝕩`. It has one result element for each such subarray of `𝕩`, whose value is 1 if that subarray matches `𝕩` and 0 otherwise.
