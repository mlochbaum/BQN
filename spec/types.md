*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/types.html).*

# Specification: BQN types

BQN programs manipulate data of seven types:
- Character
- Number
- Array
- Function
- 1-Modifier
- 2-Modifier
- Namespace

Beyond these, an implementation may define [system values](system.md) that create values of other types. The behavior of such values is not specified and is left up to the implementation.

Of the types specified, the first three are considered *data types* and the next three *operation types*. We first describe the operation types and the namespace; the remainder of this page will be dedicated to the data types. A member of any operation type accepts some number of *inputs* and either returns a *result* or causes an error; inputs and the result are values of any type. When a function is given inputs (*called*), it may produce side effects before returning, such as manipulating variables and calling other functions within its scope, or performing I/O.
- A *function* takes one (monadic call) or two (dyadic call) *arguments*.
- A *1-modifier* takes one *operand*.
- A *2-modifier* takes two *operands*.

A namespace holds the variables used to evaluate a block or program, as defined in the [scoping rules](scope.md). The observable aspects of a namespace are that it can be compared for equality with other namespaces and that it exposes variables associated with certain names, whose values can be queried or set.

To begin the data types, a *character* is a [Unicode](https://en.wikipedia.org/wiki/Unicode) code point, that is, its value is a non-negative integer within the ranges defined by Unicode (however, it is distinct from this number as a BQN value). Characters are ordered by this numeric value. BQN deals with code points as abstract entities and does not expose encodings such as UTF-8 or UTF-16.

The precise type of a *number* may vary across BQN implementations or instances. The type must be a subset of the [extended real numbers](https://en.wikipedia.org/wiki/Extended_real_number_line), that is, the real numbers and positive or negative infinity. Some system must be defined for rounding an arbitrary real number to a member of this subset, and the basic arithmetic operations add, subtract, multiply, divide, and natural exponent (base *e*) are defined by performing these operations on exact real values and rounding the result. The Power function (dyadic `⋆`) is also used but need not be exactly rounded. The [complex number](complex.md) extension describes an optional extension to use complex numbers instead of reals only.

An *array* is a rectangular collection of data. It is defined by a *shape*, which is a list of non-negative integer lengths, and a *ravel*, which is a list of *elements* whose length (the array's *bound*) is the product of all lengths in the shape. Arrays are defined inductively: any value (of a value or function type) can be used as an element of an array, but it is not possible for an array to contain itself as an element, or an array that contains itself, and so on. Types other than array are called *atomic types*, and their members are called *atoms*.
