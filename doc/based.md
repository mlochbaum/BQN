*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/based.html).*

# Based array theory

<!--GEN
"style" Enc "code span.Comment { color: inherit; }"
-->

*"Like a normal programming language"*

This page explains how BQN's array model (christened "based" [in 1981](https://dl.acm.org/doi/abs/10.1145/586656.586663)) differs from the models used by existing APL dialects, and why the choice was made to discard APL's "everything is an array" dictum. If you're not wondering what the difference is, and don't think everything should be an array, then you can probably just read about BQN's [type system](types.md) instead.

If you're an array programmer then I have bad news for you. My thesis here is that APL took a wrong turn around 1981 when it extrapolated the excellent, but limited, flat array model of APL\360 to the ill-founded nested array model and the rigorous but clumsy boxed array model. Make that two wrong turns, I guess. Simultaneously. Anyway, if you've been brought up in either of these array models, then the best thing to do when starting BQN is to throw out your existing ideas about array depth and nesting (but don't worry too much: the fundamental concept of an array as a rectangular collection of data still holds!). If you'd like to ponder the relationship of BQN to APL later, that's great, but trying to initially understand BQN in terms of APL or J will just cause confusion.

## Starting from atoms

APL tends to define its data by starting with the array and then looking downwards in depth at what it contains. The based array model, as the name suggests, starts at the foundations, which in BQN are called "atoms". There are six [types](types.md) of atom, which together with the array type give the seven types a value can have in BQN. Based means being yourself, and an atom's *not* an array.

An atom has [depth](depth.md) 0, and doesn't inherently have a shape. However, primitives that expect an array will promote an atom by [enclosing](enclose.md) to get a rank-0, or *unit*, array that contains it (any value can be enclosed in this way, giving a unit array with higher depth, but it only happens automatically for atoms). [Rank and shape](shape.md) both do this, so an atom can be considered to have the same dimensions as a unit array: rank 0 and shape `⟨⟩`. An atom is also considered a kind of unit, but it's not a unit array.

Atoms are displayed as plain values, while enclosed atoms, that is, depth-1 unit arrays, are shown with an array display.

        3    # Atom
        <3   # Array
        '3'  # Atom

In addition to numbers and characters, functions, 1-modifiers, and 2-modifiers are atoms. We can see this by converting one to a subject [role](context.md) and checking its depth.

        Plus ← +
        ≡ plus

The primitives that return a single number, like Rank (`=`), Length (`≠`), and [Match](match.md) (`≡`), give it as an atom, not an array.

        ≡ "abc"
        ≡ ≡ "abc"  # The result was an atom

[Transposing](transpose.md) no axes of an array wouldn't do anything. But because Transpose expects its right argument to be an array, it converts an atom to an array.

        ⟨⟩ ⍉ 3

## Building arrays

Arrays in BQN, like nearly all data structures in modern programming languages, are an [inductive type](https://en.wikipedia.org/wiki/Inductive_type). That means that an array can be constructed from existing values, but can't contain itself (including recursively: an array always has finite depth). To construct the type of all BQN values inductively, we would say that atoms form the base case, and arrays are an inductive case: an array is a shaped collection of existing BQN values. For an array programmer, this is of course the easy part.

## Versus the nested array model

The [nested array model](https://aplwiki.com/wiki/Array_model#Nested_array_theory) of NARS, APL2, Dyalog, and GNU APL can be constructed from the based model by adding a rule: a unit (or "scalar" in APL) array containing an atom is equivalent to that atom. The equivalents of atoms in nested array theory are thus called "simple scalars", and they are considered arrays but share the characteristics of BQN atoms. Nested arrays don't form an inductive type, because simple scalars contain themselves.

Nested array theory can seem simpler to use, because the programmer never has to worry about simple scalars being enclosed the wrong number of times: all these encloses have been identified with each other. For example, `'abcd'[2]` returns a character while BQN's `2⊏"abcd"` returns an array containing a character. However, these issues usually still appear with more complex arrays: `'ab' 1 'ef'[2]` (here spaces are used for stranding) is not a string but an enclosed string!

A property that might warn about dangerous issues like this is that nested array theory tends to create *inversions* where the depth of a particular array depends on its rank (reversing the normal hierarchy of depth→rank→shape). A 1-character string has depth 1, but when its rank is reduced to 0, its depth is reduced as well.

In some cases nested array theory can remove a depth issue entirely, and not just partially. Most notable is the [search function result depth](../commentary/problems.md#search-function-depth) issue, in which it's impossible for a search function in BQN to return an atomic number because it always returns an array. Nested array theory doesn't have this issue since a scalar number is "just a number", and more complicated arrays can't cause problems because a search function's result is always a numeric array. The other half of the problem, about the non-principal argument depth, is only partly hidden, and causes problems for example when searching for a single string out of a list of strings.

## Versus the boxed array model

The [boxed array model](https://aplwiki.com/wiki/Array_model#Boxes) of SHARP APL, A+, and J is an inductive system like BQN's. But this model uses arrays as the base case: numeric and character arrays are the simplest kind of data allowed, and "a number" means a rank-0 numeric array. The inductive step is the array of boxes; as with numbers "a box" is simply a rank-0 array of boxes.

Numeric and character arrays in this system have depth 0. In general these correspond to arrays of depth 1 in BQN, but because there's no lower depth they are also used where BQN atoms would appear. For example, both Shape (`$`) and Length (`#`) return depth-0 results in J. For an array `a` with rank at least 1, the length `#a` is exactly `[/ $ a`, while the identical BQN code `⊣˝ ≢ a` returns not `≠ a` but `< ≠ a`. Like the nested model, the boxed model can hide depth issues that occur at lower depths but generally reveals them at higher depths.

The boundary at depth 0 will tend to cause inconsistencies and confusion in any array language, and boxed array languages push this boundary up a level. This leads to the programmer spending more effort managing boxes: for example, to reverse each list in a list of lists, the programmer can use reverse under open, `|. &. >`. But to find the lengths of each of these lists, `# &. >` would yield a boxed list, which is usually not wanted, so `# @ >` is needed instead. BQN shows that a system that doesn't require these distinctions is possible, as a BQN programmer would use `⌽¨` and `≠¨`.
