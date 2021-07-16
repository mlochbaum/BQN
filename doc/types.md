*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/types.html).*

# Types

BQN supports the following fundamental types:

- [Number](#numbers)
- [Character](#characters) (Unicode code point)
- [Array](#arrays)
- [Function](#functions)
- 1-[Modifier](#modifiers)
- 2-[Modifier](#modifiers)
- [Namespace](#namespaces)

The first three types, called *data types*, are immutable; the others are mutable. Functions and modifiers together are the *operation types*. Types other than the array are *atomic types* and values of these types are called *atoms*. The fact that an array is only one type of many is common in modern programming languages but a novelty in the APL family. This decision is discussed in the page on [based array theory](based.md).

<!--GEN
types ← ⟨"Number"‿"Character"‿"Array","Function"‿"1-modifier"‿"2-modifier"‿"Namespace"⟩
sh ← 4‿2
p ← 64‿38
dim ← (2×p) + sh × d1 ← 128‿68
rp ← 8÷d1
Pos ↩ Pos d1⊸×
Size ← "width"‿"height" ≍˘ ·FmtNum d1×⊢
cl ← {"class"‿𝕩}¨ "purple"‿"green"‿"bluegreen"‿"yellow"

TP ← "text" Attr "dy"‿"0.35em"∾˜Pos⊘(∾⟜Pos)
t ← ∾(0.5+↕2) (TP∘≍˜¨⟜((4÷≠)×0.5+↕∘≠)Enc¨⊢)¨ types
l ← (cl TP¨ ⟨2.75‿¯0.15,3‿2.2,1.5‿2.2,1.1‿¯0.3⟩) Enc¨ "Data"‿"Mutable"‿"Operation"‿"Atom"
rd← (÷⟜2⌾(⊑¯1⊸⊑)2‿1.5‿3×<(¯1≍÷2)×⌜rp) + (4‿4‿3≍¨1) ≍¨ 1‿2/0≍¨↕2
r ← (3↑cl) ("rect" Elt ∾˜)¨ (FmtNum 9‿10‿8) {𝕩∾⟨"rx",𝕨∾"px"⟩}¨ Size⊸∾⟜Pos˝¨ rd

Round ← {
  v ← (𝕨⊸×÷+´⌾(×˜))¨ ¯1⊸⌽⊸- 𝕩
  or← 0< v +´∘×⟜(⌽-⌾⊑)¨ 1⌽v
  "Z"∾˜ 'M'⌾⊑ ∾ ⥊ (('L'∾Fmt)¨ v+𝕩) ≍˘ or ('A'∾·Fmt(𝕨‿𝕨∾0‿0)∾∾)¨ (1⌽-v)+𝕩
}
a ← "path" Elt >⟨"d"‿(12 Round d1⊸×¨ ⥊ ((⊢≍˘1⊸⌽) 0‿2.6‿4) ≍¨ ↕3),¯1⊑cl⟩

FS ← {𝕩 Enc˜ "g"Attr⟨"font-size",(Fmt𝕨)∾"px"⟩}
((0‿2-p)∾dim) SVG ⟨
  "g stroke-width='2'" Enc a‿r
  "g text-anchor='middle' fill='currentColor'" Enc 18‿16 FS¨ t‿l
⟩
-->

The reason operations and namespaces are called "mutable" is that the values obtained from them—by calling an operation on particular arguments or reading a field from a namespace—may change over the course of the program. This property is caused by variable modification `↩`, which can directly change a namespace field, or change the behavior of an operation that uses the modified variable. This means that a program that doesn't include `↩` won't have such changes in behavior. However, there will still be an observable difference between immutable data and the mutable types: code that creates a mutable value (for example, a block function `{𝕩}`) creates a different one each time, so that two different instances don't [match](match.md) (`≡`) each other. Data values created at different times may match, but mutable values never will.

An array is considered immutable because its shape, and what elements it contains, cannot change. An array has no identity outside these properties (and possibly its fill element), so an array with a different shape or different elements would simply be a different array. However, any element of an array could be mutable, in which case the behavior of the array would change with respect to the operation of selecting that element and calling it or accessing a field.

## Data types

Data types—numbers, characters, and arrays—are more like "things" than "actions". If called as a function, a value of one of these types simply returns itself. Data can be uniquely represented, compared for equality, and ordered using BQN's [array ordering](order.md#array-ordering); in contrast, determining whether two functions always return the same result can be undecidable. For arrays, these properties apply only if there are no operations inside. We might say that "data" in BQN refers to numbers, characters, and arrays of data.

### Numbers

The BQN spec allows for different numeric models to be used, but requires there to be only one numeric type from the programmer's perspective: while programs can often be executed faster by using limited-range integer types, there is no need to expose these details to the programmer. Existing BQN implementations are based on [double-precision floats](https://en.wikipedia.org/wiki/IEEE-754), like Javascript or Lua.

### Characters

A character in BQN is always a [Unicode](https://en.wikipedia.org/wiki/Unicode) code point. BQN does not use encodings such as UTF-8 or UTF-16 for characters, although it would be possible to store arrays of integers or characters that correspond to data in these encodings. Because every code point corresponds to a single unit in UTF-32, BQN characters can be thought of as UTF-32 encoded.

Addition and subtraction [treat](arithmetic.md#character-arithmetic) characters as an [affine space](http://videocortex.io/2018/Affine-Space-Types/) relative to the linear space of numbers. This means that:
* A number can be added to or subtracted from a character.
* Two characters can be subtracted to get the distance between them—a number.
Other linear combinations such as adding two characters or negating a character are not allowed. You can check whether an application of `+` or `-` on numbers and characters is allowed by applying the same function to the "characterness" of each value: `0` for a number and `1` for a character. The result will be a number if this application gives `0` and a character if this gives `1`, and otherwise the operation is not allowed.

### Arrays

A BQN array is a multidimensional arrangement of data. This means it has a certain [*shape*](shape.md), which is a finite list of natural numbers giving the length along each axis, and it contains an *element* for each possible [*index*](indices.md), which is a choice of one natural number that's less than each axis length in the shape. The total number of elements, or *bound*, is then the product of all the lengths in the shape. The shape may have any length including zero, and this shape is known as the array's *rank*. An array of rank 0, which always contains exactly one element, is called a *unit*, while an array of rank 1 is called a *list* and an array of rank 2 is called a *table*.

Each array—empty or nonempty—has an inferred property called a *fill*. The fill either indicates what element should be used to pad an array, or that such an element is not known and an error should result. Fills can be used by [Take](take.md) (`↑`), the two [Nudge](shift.md) functions (`»«`), [First](pick.md) (`⊑`), and [Reshape](reshape.md) (`⥊`).

Arrays are value types (or immutable), so that there is no way to "change" the shape or elements of an array. An array with different properties is a different array. As a consequence, arrays are an inductive type, and it's not possible for an array to contain itself, or contain an array that contains itself, and so on. However, it is possible for an array to contain a function or other operation that has access to the array through a variable, and in this sense an array can "know about" itself.

Different elements of an array should not influence each other. While some APLs force numbers placed in the same array to a common representation, which may have different precision properties, BQN values must not change behavior when placed in an array. However, this doesn't preclude changing the storage type of an array for better performance: for example, in a BQN implementation using 64-bit floats, an array whose elements are all integers that fit in 32-bit int range might be represented as an array of 32-bit ints.

## Operation types

An operation is either a function or modifier, and can be applied to *inputs*—which are called *arguments* for functions and *operands* for modifiers—to obtain a result. During this application an operation might also change variables within its scope and call other operations, or cause an error, in which case it doesn't return a result. There is one type of call for each of the three operation types, and an operation will give an error if it is called in a way that doesn't match its type.

In BQN syntax the result of a function has a subject role and the result of a modifier has a function role. However, the result can be any value at all: roles take place at the syntactic level, which has no bearing on types and values in the semantic level. This distinction is discussed further in [Mixing roles](context.md#mixing-roles).

### Functions

A function is called with one or two arguments. A data value (number, character, or array) can also be called the same way, but only a function takes any action when passed arguments, as data just returns itself. Both the one-argument and two-argument calls are considered function calls, and it's common for a function to allow both. A function that always errors in one case or the other might be called a one-argument or two-argument function, depending on which case is allowed.

### Modifiers

A 1-modifier is called with one operand, while a 2-modifier is called with two. In contrast to functions, these are distinct types, and it is impossible to have a value that can be called with either one or two operands. Also in contrast to functions, data values cannot be called as modifiers: they will cause an error if called this way.

## Namespaces

Functions and modifiers have internal scopes which they can manipulate (by defining and modifying variables) to save and update information. Namespaces let the programmer to expose this state more directly: identifiers in a namespace may be exported, allowing code outside the namespace to read their values. They are described in detail [here](namespace.md).
