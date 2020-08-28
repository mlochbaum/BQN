*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/types.html).*

# Types

BQN supports the following fundamental types:

- [Number](#numbers)
- [Character](#characters) (Unicode code point)
- [Array](#arrays)
- Function
- 1-Modifier
- 2-Modifier

The first three types are called *data types*, and the rest are *operation types*. The array is the only *compound type*; the other types are *atomic types* and values of these types are called *atoms*. The fact that an array is only one type of many is common in modern programming languages but a novelty in the APL family. This decision is discussed in the page on [based array theory](based.md).

All of these types are immutable, meaning that a particular copy of a value will never change (to go further, with immutable types it doesn't really make sense to talk about a "copy" of a value: values just exist and nothing you do will affect them). The only form of mutability BQN has is the ability to change the value of a particular variable, that is, make that variable name refer to a different value. However, it is likely that in the future [namespaces](extensions.md#namespaces-and-symbols), or references to enclosed scopes, will be added as a mutable data type.

## Numbers

The BQN spec allows for different numeric models to be used, but requires there to be only one numeric type from the programmer's perspective: while programs can often be executed faster by using limited-range integer types, there is no need to expose these details to the programmer. Existing BQN implementations are based on [double-precision floats](https://en.wikipedia.org/wiki/IEEE-754), like Javascript or Lua.

## Characters

A character in BQN is always a [Unicode](https://en.wikipedia.org/wiki/Unicode) code point. BQN does not use encodings such as UTF-8 or UTF-16 for characters, although it would be possible to store arrays of integers or characters that correspond to data in these encodings. Because every code point corresponds to a single unit in UTF-32, BQN characters can be thought of as UTF-32 encoded.

## Arrays

A BQN array is a multidimensional arrangement of data.

Currently, the intention is that arrays will not have prototypes, so that all empty arrays of the same shape behave identically. Different elements of an array should not influence each other. While some APLs force numbers placed in the same array to a common representation, which may have different precision properties, BQN will enforce 64-bit floating-point precision, and only use representations or methods compatible with it (for example, integers up to 32 bits).
