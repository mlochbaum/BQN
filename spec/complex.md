*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/complex.html).*

# Specification: Complex numbers

Complex numbers are an optional extension to BQN's numeric system. If they are supported, the following functionality must also be supported. This extension is a draft and is versioned separately from the rest of the BQN specification.

A *complex number* is a value with two *components*, a *real part* and an *imaginary part*. The type of each component is a real number, as described in the [type](types.md) specification. However, this type replaces the number type given there.

The [numeric literal](literal.md) notation is extended with the character `i`, which separates two real-valued components (in effect, it has lower "precedence" than other characters like `e` and `¯`). If a second component is present (using `i` or `I`), that component's value is multiplied by the [imaginary unit](https://en.wikipedia.org/wiki/Imaginary_unit) *i* and added to the first component; otherwise the value is the first component's value without modification. As with real numbers, the exact complex number given is rounded to fit the number system in use.

    complexnumber = number ( ( "i" | "I" ) number )?

Basic arithmetic functions `+-×÷` are extended to complex numbers. A monadic case for the function `+` is added, which returns the conjugate argument: a number with real part equal to the real part of `𝕩` and imaginary part negated relative to `𝕩`.

The primitive function `⍳` is added: the character `⍳` forms a primitive function [token](token.md), and its value is the function `{𝕨⊢⊘+0j1×𝕩}`. This function multiplies `𝕩` by *i*, then adds `𝕨` if given.
