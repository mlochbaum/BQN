*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/primitive.html).*

# Specification: BQN primitives

Most primitives are specified by the BQN-based implementation in [reference.bqn](reference.bqn). This document specifies the basic functionality required by those definitions. Descriptions of other primitives are for informational purposes only.

## Arithmetic

Functions here are defined for atoms only; the reference implementations extend them to arrays.

BQN uses five arithmetic functions that are standard in mathematics. The precision of these operations should be specified by the number [type](types.md).

- Add `+`
- Negate `-` and Subtract `-` invert addition, with `-𝕩` equivalent to `0-𝕩` and `𝕨-𝕩` equivalent to `𝕨+-𝕩`
- Multiply `×` generalizes repeated addition.
- Divide `÷` inverts multiplication, with `÷𝕩` equivalent to `1÷𝕩` and `𝕨÷𝕩` equivalent to `𝕨×÷𝕩`
- Power `⋆` generalizes repeated multiplication, and Exponential `⋆` is Power with Euler's number *e* as the base.

The three higher functions `×`, `÷`, and `⋆` apply to numbers and no other atomic types. `+` and `-` apply to numbers, and possibly also to characters, according to the rules of the affine character type:

- If one argument to `+` is the character with code point `c` and the other is a number `n` (in either order), then the result is the character with code point `c+n`.
- If the left argument to `-` is the character with code point `c` and the right is a number `n`, the result is the character with code point `c-n`.
- If both arguments to `-` are characters, the result is the difference of their respective code points.

In the first two cases, if the result would not be a valid Unicode code point, then an error results. The remaining cases of `+` and `-` (adding two characters; negating a character or subtracting it from a number) are not allowed.
