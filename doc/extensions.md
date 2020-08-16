*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/extensions.html).*

# BQN extensions

This page describes features that are not part of the core BQN specification, but may be specified in the future. If specified, these features would be optional, so that an implementation could choose to support them or not.

## Complex numbers

These are fairly common in APL dialects and could be useful in BQN as well.

## Sets and dictionaries

Sets are unordered collections of distinct values. Dictionaries have a set of keys and associate each key with a corresponding value. These types are a natural fit for the data in some cases; while they can be represented using arrays of keys and values, using the right type can lead to cleaner and faster algorithms.

The following glyphs are added for the dictionary and set literal notation.

Glyph(s)        | Meaning
----------------|-----------
`:`             | Key/value separator for dictionaries
`⦃⦄`            | Set

Set notation matches the bracketed list notation with the angle brackets changed to double-struck curly brackets `⦃⦄`, but there is no ligature notation for sets.

Dictionaries use angle brackets `⟨⟩` like lists, but instead of expressions there are pairs of expressions separated by `:`. The first expression evaluates to the key and the second to the corresponding value. The empty dictionary is written `⟨:⟩`.

Dictionaries and sets should be supported their own set of primitive operations like arrays are. The glyphs `∪⊂⊃⊆⊇` from mathematics are unused for this reason: they could be wanted for set operations.

## Namespaces and symbols

Sometimes it is useful to have a mutable type, particularly if a part of the program should maintain its own state over the course of execution. The [closures](https://en.wikipedia.org/wiki/Closure_(computer_programming)) required as part of a complete lexical scoping implementation actually allow something like this. If a function defines and returns an explicit function, then that function can read and change variables in its environment. As the environment includes the scope created to execute the outer function, calling the outer function creates a mutable environment that can be indirectly accessed through the returned function.

A namespace would allow such an environment to be directly accessed and manipulated. While it's possible there would be facilities to create a namespace, a simpler mechanism is simply to add a primitive that returns the current scope as a variable. This scope would then behave the same way as a returned function's environment, and would allow member access by a dot-like syntax.

A symbol is a variable representing a name in the program. Symbols would make it easier to interact with namespaces dynamically.
