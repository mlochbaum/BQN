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
