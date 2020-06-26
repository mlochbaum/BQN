BQN programs manipulate data of six types:
- Character
- Number
- Array
- Function
- Modifier
- Composition

Of these, the first three are considered *value types* and the remaining three *function types*. We first describe the much simpler function types; the remainder of this page will be dedicated to the value types. A member of any function type accepts some number of *inputs* and either returns a *result* or causes an error; inputs and the result are data of any type. When a function is given inputs (*called*), it may produce side effects before returning, such as manipulating variables and calling other functions within its scope, or performing I/O.
- A *function* takes one (monadic call) or two (dyadic call) *arguments*.
- A *modifier* takes one *operand*.
- A *composition* takes two *operands*.

To begin the value types, a *character* is a [Unicode](https://en.wikipedia.org/wiki/Unicode) code point, that is, its value is a non-negative integer within the ranges defined by Unicode (however, it is distinct from this number as a BQN value). Characters are ordered by this numeric value. BQN deals with code points as abstract entities and does not use encodings such as UTF-8 or UTF-16.

The precise type of a *number* may vary across BQN implementations or instances. A *real number* is a member of some supported subset of the [extended real numbers](https://en.wikipedia.org/wiki/Extended_real_number_line), that is, the real numbers and positive or negative infinity. Some system must be defined for rounding an arbitrary real number to a member of this subset, and the basic arithmetic operations add, subtract, multiply, divide, and natural exponent (base *e*) are defined by performing these operations on exact real values and rounding the result. The Power function (dyadic `⋆`) is also used but need not be exactly rounded. A *complex number* is a value with two real number *components*, a *real part* and an *imaginary part*. A BQN implementation can either support real numbers only, or complex numbers.

An *array* is a rectangular collection of data. It is defined by a *shape*, which is a list of non-negative integer lengths, and a *ravel*, which is a list of *elements* whose length (the array's *bound*) is the product of all lengths in the shape. Arrays are defined inductively: any value (of a value or function type) can be used as an element of an array, but it is not possible for an array to contain itself as an element, or an array that contains itself, and so on.
