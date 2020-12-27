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
