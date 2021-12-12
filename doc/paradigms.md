*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/paradigms.html).*

# BQN in programming paradigms

It hangs onto weakly positive connotations somehow, but the term "multi-paradigm" shouldn't impress you. Let's dig into exactly which paradigms BQN supports and how.

This information doesn't tell you what tasks BQN is good for: after all, it turns out you can write an efficient compiler entirely using array programming, something many people assumed was impossible. Instead, it tells you what approaches you can take to writing programs, and how comfortable you'll find it to start using BQN—or how much you can use it to stretch your brain in new directions.

When programming in BQN, I almost always use array, tacit, and (slightly impure) functional styles, and encapsulate code in medium or large projects using namespaces. I sometimes use object-oriented or imperative programming in addition to these.

## Typing

BQN is a **dynamically typed** language with a coarse [type system](types.md) that only distinguishes types when the difference is blindingly obvious. There is a single numeric type and a single unicode character type. A fast implementation such as CBQN will check to see when it can represent the data with a smaller type than the one offered by the language. BQN usually avoids implicit type conversion, with the exception that many primitives automatically convert atoms to unit arrays. The fact that a data value can be applied as a function to return itself could also be considered an implicit conversion.

BQN has no "pointer" or "reference" type, and uses **automatic memory management**. Its data types are **immutable** while operations and namespaces are [mutable](lexical.md#mutation); mutable data can create reference loops, which the implementation must account for in garbage collection but the programmer doesn't have to worry about.

Dynamic types and garbage collection introduce overhead relative to a statically-typed or manually managed language. The impact of this overhead can be greatly reduced with array programming, because an array of numbers or characters can be stored as a single unit of memory and processed with functions specialized to its element type.

## Styles

BQN is designed for **array** programming. The array is its only built-in collection type and it has many primitives designed to work with arrays.

BQN is okay for **imperative** programming. Blocks are lists of statements. Variables can be modified with `↩`, and while there are no truly global variables, [lexical scoping](lexical.md) allows variables at the top level of a file, which are similar (`•Import` with no left argument saves and reuses results, so that data can be shared between files by loading the same namespace-defining file in each). BQN doesn't directly support **structured** programming (which refers to a particular way to structure programs; it also doesn't have a Goto statement, the "unstructured" alternative when the term was coined). However, its first-class functions allow a reasonably similar [imitation](control.md) of control structures.

**Functional** programming is a term with many meanings. Using the terms defined in the [functional programming document](functional.md), BQN supports first-class functions and function-level programming, allows but doesn't encourage pure functional programming, and does not support typed functional programming. BQN uses **lexical scope** and has full support for **closures**. In this way BQN is very similar to Lisp, although it lacks Lisp's macro system.

BQN has excellent [support](tacit.md) for **tacit** or **point-free** programming, with [trains](train.md) and intuitive symbols for combinators making it much easier to work with (in my opinion) than other languages that support this style. It's near-universally considered a poor choice to implement entire programs in a tacit style, so this paradigm is best used as a small-scale tool within a style like functional or object-oriented programming.

BQN uses [namespaces](namespace.md) as **modules** to organize code; the only possible interaction with a module is by its exported variables. There doesn't seem to be a name for this paradigm, but there should be.

BQN supports **object-oriented** programming [only incidentally](oop.md). This is not as bad as it sounds, and programming with objects in BQN can often feel pretty similar to other object-based languages. The main differences are that objects don't have a `this` property to pass themselves into functions, and there's no built-in way to find the class of an object. There is also no support for inheritance, which is not unheard of in the object-oriented world.

BQN does not support **metaprogramming** such as macros or reflection, except with very crude techniques like `•Eval`. Functions describe computations and can easily be written, passed around, and applied: they can fill in for any use of macros or generics in a C-like language. If desired, it's easy to use lists as S-expressions to form structures that can be easily manipulated and also evaluated—roughly, embedding Lisp in BQN.

BQN does not yet have support for **concurrent** programming. It's likely that its strict approach to lexical scoping and encapsulation make it a good fit for concurrent execution, but designing such a system is not a priority. In contrast, array operations are ideal for **parallel** computing, including SIMD or GPU computation. To enable highly-parallel algorithms, the implementation must evaluate primitives (or combinations) using these algorithms, and the programmer must use primitives that have been implemented in this way. It would be possible to define a subset of BQN that restricts the programmer to code with an efficient parallel implementation, but BQN itself does not have any such restrictions.

BQN doesn't support **logic** programming or **computer algebra**, although its [inferred properties](../spec/inferred.md) might be considered a very rudimentary form of either of these. It doesn't support **dataflow** programming.
