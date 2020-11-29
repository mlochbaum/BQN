*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/types.html).*

# Types

BQN supports the following fundamental types:

- [Number](#numbers)
- [Character](#characters) (Unicode code point)
- [Array](#arrays)
- [Function](#functions)
- 1-[Modifier](#modifiers)
- 2-[Modifier](#modifiers)

The first three types are called *data types*, and the rest are *operation types*. The array is the only *compound type*; the other types are *atomic types* and values of these types are called *atoms*. The fact that an array is only one type of many is common in modern programming languages but a novelty in the APL family. This decision is discussed in the page on [based array theory](based.md).

<!--GEN
types ← ⍉"Number"‿"Character"‿"Array"≍"Function"‿"1-modifier"‿"2-modifier"
sh ← ≢ types
p ← 64‿38
dim ← (2×p) + sh × d1 ← 128‿64
rp ← 8÷d1
Pos ↩ Pos d1⊸×
Size ← "width"‿"height" ≍˘ ·FmtNum d1×⊢
cl ← {"class"‿𝕩}¨ "purple"‿"bluegreen"‿"yellow"

TP ← "text" Attr "dy"‿"0.32em"∾˜Pos⊘(∾⟜Pos)
t ← (≍⌜´0.5+↕¨sh) TP⊸Enc¨ types
l ← (cl TP¨ (0.75≍¨1(-≍+)1.2)∾<2.2‿2.3) Enc¨ "Data"‿"Operation"‿"Atom"
RD← (Size ⟨⊑sh,1⟩-2×rp)∾Pos
r ← (2↑cl) {"rect" Elt 𝕩∾"rx"‿"10px"≍𝕨}⟜RD¨ 0(rp+≍)¨↕1⊑sh

Round ← {
  v ← (𝕨⊸×÷+´⌾(×˜))¨ ¯1⊸⌽⊸- 𝕩
  or← 0< v +´∘×⟜(⌽-⌾⊑)¨ 1⌽v
  "Z"∾˜ 'M'⌾⊑ ∾ ⥊ (('L'∾Fmt)¨ v+𝕩) ≍˘ or ('A'∾·Fmt(𝕨‿𝕨∾0‿0)∾∾)¨ (1⌽-v)+𝕩
}
a ← "path" Elt >⟨"d"‿(12 Round d1⊸×¨ ⥊ ((⊢≍˘1⊸⌽) 0‿2‿3) ≍¨ ↕3),¯1⊑cl⟩

FS ← {𝕩 Enc˜ "g"Attr⟨"font-size",(Fmt𝕨)∾"px"⟩}
((0‿2-p)∾dim) SVG ⟨
  "g stroke-width='2'" Enc a‿r
  "g text-anchor='middle' fill='currentColor'" Enc 18‿16 FS¨ t‿l
⟩
-->

All of these types are immutable, meaning that a particular copy of a value will never change (to go further, with immutable types it doesn't really make sense to talk about a "copy" of a value: values just exist and nothing you do will affect them). The only form of mutability BQN has is the ability to change the value of a particular variable, that is, make the variable refer to a different value. Such a change can also change the behavior of a function or modifier that has the variable in its scope, and in this sense operation types are mutable—in fact it is possible to implement typical mutable data structures as functions that act on enclosed state.

It is likely that in the future [namespaces](extensions.md#namespaces-and-symbols), or references to enclosed scopes, will be added as a more directly manipulable mutable data type.

## Data types

Data types—numbers, characters, and arrays—are more like "things" than "actions". If called as a function, a value of one of these types simply returns itself. Data can be uniquely represented, compared for equality, and ordered using BQN's array ordering; in contrast, determining whether two functions always return the same result can be undecidable. For arrays, these properties apply only if there are no operations inside. We might say that "data" in BQN refers to numbers, characters, and arrays of data.

### Numbers

The BQN spec allows for different numeric models to be used, but requires there to be only one numeric type from the programmer's perspective: while programs can often be executed faster by using limited-range integer types, there is no need to expose these details to the programmer. Existing BQN implementations are based on [double-precision floats](https://en.wikipedia.org/wiki/IEEE-754), like Javascript or Lua.

### Characters

A character in BQN is always a [Unicode](https://en.wikipedia.org/wiki/Unicode) code point. BQN does not use encodings such as UTF-8 or UTF-16 for characters, although it would be possible to store arrays of integers or characters that correspond to data in these encodings. Because every code point corresponds to a single unit in UTF-32, BQN characters can be thought of as UTF-32 encoded.

Addition and subtraction treat characters as an [affine space](http://videocortex.io/2018/Affine-Space-Types/) relative to the linear space of numbers. This means that:
* A number can be added to or subtracted from a character.
* Two characters can be subtracted to get the distance between them—a number.
Other linear combinations such as adding two characters or negating a character are not allowed. You can check whether an application of `+` or `-` on numbers and characters is allowed by applying the same function to the "characterness" of each value: `0` for a number and `1` for a character. The result will be a number if this application gives `0` and a character if this gives `1`, and otherwise the operation is not allowed.

### Arrays

A BQN array is a multidimensional arrangement of data. This means it has a certain *shape*, which is a finite list of natural numbers giving the length along each axis, and it contains an *element* for each possible *index*, which is a choice of one natural number that's less than each axis length in the shape. The total number of elements, or *bound*, is then the product of all the lengths in the shape. The shape may have any length including zero, and this shape is known as the array's *rank*. An array of rank 0, which always contains exactly one element, is called a *unit*, while an array of rank 1 is called a *list* and an array of rank 2 is called a *table*.

Each array—empty or nonempty—has an inferred property called a *fill*. The fill either indicates what element should be used to pad an array, or that such an element is not known and an error should result. Fills are used by Take (`↑`) and the two Nudge functions (`»«`).

Arrays are value types (or immutable), so that there is no way to "change" the shape or elements of an array. An array with different properties is a different array. As a consequence, arrays are an inductive type, and it's not possible for an array to contain itself, or contain an array that contains itself, and so on. However, it is possible for an array to contain a function or other operation that has access to the array through a variable, and in this sense an array can "know about" itself.

Different elements of an array should not influence each other. While some APLs force numbers placed in the same array to a common representation, which may have different precision properties, BQN values must not change behavior when placed in an array. However, this doesn't preclude changing the storage type of an array for better performance: for example, in a BQN implementation using 64-bit floats, an array whose elements are all integers that fit in 32-bit int range might be represented as an array of 32-bit ints.

## Operation types

An operation is either a function or modifier, and can be applied to *inputs*—which are called *arguments* for functions and *operands* for modifiers—to obtain a result. During this application an operation might also change variables within its scope and call other operations, or cause an error, in which case it doesn't return a result. There is one type of call for each of the three operation types, and an operation will give an error if it is called in a way that doesn't match its type.

In BQN syntax the result of a function has a subject role and the result of a modifier has a function role. However, the result can be any value at all: roles take place at the syntactic level, which has no bearing on types and values in the semantic level. This distinction is discussed further in [Mixing roles](context.md#mixing-roles).

### Functions

A function is called with one or two arguments. A data value (number, character, or array) can also be called the same way, but only a function takes any action when passed arguments, as data just returns itself. Both the one-argument and two-argument calls are considered function calls, and it's common for a function to allow both. A function that always errors in one case or the other might be called a one-argument or two-argument function, depending on which case is allowed.

### Modifiers

A 1-modifier is called with one operand, while a 2-modifier is called with two. In contrast to functions, these are distinct types, and it is impossible to have a value that can be called with either one or two operands. Also in contrast to functions, data values cannot be called as modifiers: they will cause an error if called this way.
