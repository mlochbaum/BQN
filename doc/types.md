*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/types.html).*

# Types

BQN supports the following fundamental types:

- Number (complex with 64-bit float precision)
- Character (Unicode code point)
- Array
- Function
- 1-Modifier
- 2-Modifier

All of these types are immutable, and immutable types should be the default for BQN. The only mutable type likely to be added is the namespace or scope.

## Array model

Most of BQN's functionality deals with the manipulation of multidimensional arrays. However, it discards many of the complications of traditional APL [array models](https://aplwiki.com/wiki/Array_model). Unlike in APL, non-array data is possible, and common: numbers, characters, and functions are not arrays. This avoids some difficulties that show up when trying to treat scalar arrays as the fundamental unit; in particular, there is no "floating" so a value is always different from a scalar array that contains it. This system has been [proposed](https://dl.acm.org/doi/abs/10.1145/586656.586663) in APL's past under the name **based array theory**.

Currently, the intention is that arrays will not have prototypes, so that all empty arrays of the same shape behave identically. Different elements of an array should not influence each other. While some APLs force numbers placed in the same array to a common representation, which may have different precision properties, BQN will enforce 64-bit floating-point precision, and only use representations or methods compatible with it (for example, integers up to 32 bits).
