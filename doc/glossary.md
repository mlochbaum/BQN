*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/glossary.html).*

# BQN glossary

Below are short, and sometimes vague, definitions of terms used to describe BQN code.

## Types

* **Value**: Something that can be stored in variables and manipulated by a BQN programmer.
* [**Type**](types.md): One of seven possible kinds of value.

The possible types are:
* [**Number**](types.md#numbers): Like some caveman was counting but then forty thousand years of math happened to it.
* [**Character**](types.md#characters): A Unicode code point.
* [**Array**](types.md#arrays): A multidimensional collection of values.
* [**Function**](ops.md#functions): An operation that is called on one or two arguments.
* [**1-modifier**](ops.md#modifiers): An operation that is called on one operand.
* [**2-modifier**](ops.md#modifiers): An operation that is called on two operands.
* [**Namespace**](namespace.md): A container for variables, some of which are exposed as fields.

A few terms refer to multiple types collectively:
* [**Atom**](based.md#starting-from-atoms): A value that's not an array.
* [**Modifier**](ops.md#modifiers): A 1-modifier or 2-modifier.
* [**Data type**](types.md#data-types): Number, character, or array.
* [**Operation type**](ops.md): Function, 1-modifier, or 2-modifier.
* [**Mutable type**](lexical.md#mutation): Operation or namespace.

BQN uses standard terminology for particular sets of numbers, with natural numbers starting at 0.
* **Boolean**: 0 or 1.
* **Natural number**: 0, or 1 plus a natural number; alternatively, a non-negative integer.
* **Integer**: A natural number or its negation (use "whole number" instead whenever you can get away with it).
* **Real number** (more accurately, approximate doubly-extended real number): A number with no complex part.
* **Complex number**: A real number plus *i* (one of the square roots of -1) times another real number.

## Arrays

* [**Array**](array.md): A multidimensional collection of values.
* [**Element**](array.md#elements): One of the values contained in an array.
* [**Axis**](array.md#rectangles): One dimension or direction in an array.
* [**Rank**](array.md#dimensions): The number of dimensions an array has.
* [**Shape**](shape.md): The number of positions an array has along each dimension.
* [**Length**](shape.md): The number of positions an array has along the first dimension, or 1 if it has rank 0.
* [**Depth**](depth.md): The greatest number of times an element can be selected from a value before reaching an atom.
* [**Fill**](fill.md): A "prototypical" array element used in certain operations; it's an inferred property of an array.

* [**Empty**](array.md#elements): Having no elements. An array is empty if its shape contains 0.
* [**Cell**](array.md#cells): An array selected from a larger array, containing all elements whose indices share a particular prefix.
* [**k-Cell**](array.md#cells): A cell of rank *k*.
* [**Major cell**](array.md#cells): A cell with rank one less than the original array.
* [**Agreement**](leading.md#leading-axis-agreement): The way elements are paired when mapping over two arrays together (for example by Each).
* [**Frame**](rank.md#frame-and-cells): A prefix of an array's shape, used for agreement with the Rank modifier.

* **Unit**: An array of rank 0, or an atom.
* [**Unit array**](enclose.md#whats-a-unit): An array of rank 0.
* **List**: An array of rank 1.
* **String**: A list of characters.
* **Table**: An array of rank 2.

* [**Index**](indices.md): One of a variety of ways to select an element, cell, axis, or position along an axis of an array.
* [**Index order**](reshape.md): The standard ordering of array elements by increasing index.
* [**Index list**](indices.md#element-indices): A list of numbers indicating a single element of an array.

## Operations

* [**Operation**](ops.md): A value that is called on inputs to perform computation and return a result or cause an error.
* **Call**: Submit inputs to an operation and receive any result.
* **Input**: A value given (*passed*) to an operation when it's called.
* **Result**: A value returned from an operation when called.
* **Argument**: An input to a function.
* **Operand**: An input to a modifier.
* **Valence**: The number of arguments that can be or are passed to a function.
* **Ambivalent**: A function that can be called with one or two arguments without causing an error.
* **Monadic**: Called with one argument, either always (a monadic function) or in a particular instance (a monadic call).
* **Dyadic**: Called with two arguments, always or in a particular instance.

* [**Compound function**](ops.md#functions): A derived function or train.
* [**Derived function**](ops.md#functions): A function produced by binding operands to a deferred modifier; doing so does not cause any computation.
* [**Train**](train.md): A function composed of two or more functions.
* [**Identity value**](fold.md#identity-values): An inferred property of a function: the result of a reduction with this function on an empty array.

* **Error**: A condition that stops compilation or execution (see [assert](assert.md)).
* **Inferred property**: A property of a value that is derived by BQN based on constraints. If it can't be derived then the value won't have the property. Includes identity values, fill elements, and behavior of Undo and Under.

## Tokens

* **Token formation** or tokenization: Splitting source code into a sequence of tokens.
* **Token**: A name, literal, primitive, or other syntactic element.
* **Literal**: A token that indicates a fixed value of a data type.
* [**Primitive**](primitive.md): One of several fixed operations defined by the language, denoted by a single-character token.
* **Word**: A sequence of alphabetic or numeric characters.
* **Name**: A word that starts with an alphabetic character. Names are compared case-insensitively and ignoring underscores `_`.
* [**Numeric literal**](token.md#numbers): A word that starts with a numeric character, indicating a number.
* [**String literal**](arrayrepr.md#strings): A literal written with double quotes `""`, indicating a string.
* [**Character literal**](token.md#characters-and-strings): A literal written with single quotes `''`, indicating a string.
* [**Null literal**](token.md#characters-and-strings): The literal `@`, indicating the null character (code point 0).

## Grammar

* [**Program**](syntax.md): The source code for a single BQN evaluation.
* [**Expression**](syntax.md#expressions): A piece of code that describes the computation of a value.
* [**Nothing**](expression.md#nothing): A special value-like entity that comes from `·`, `𝕨` in a function with no left argument, or a function called on nothing.
* **Statement**: An expression, nothing (`·`), or an export (`var⇐`).
* [**Ligature**](arrayrepr.md#strands): The character `‿`.
* [**List notation**](arrayrepr.md#brackets): The angle brackets `⟨⟩` or ligatures used to indicate a list.
* [**Array notation**](arrayrepr.md#high-rank-arrays): The square brackets `[]` used to form high-rank arrays.

### Roles

* [**Syntactic role**](expression.md#syntactic-role): One of four possible types for an expression, which are determined by the text of the expression, not outside context. The role describes how it interacts with other parts of the syntax.

The possible roles are:
* **Subject**: Can be passed to a function or modifier.
* **Function**: Can be called on subjects or passed to a modifier.
* **1-modifier**: Can be called on one subject or function.
* **2-modifier**: Can be called on two subjects or functions.

## Assignment and scoping

* [**Assignment**](expression.md#assignment): An operation that sets a variable's value. Definition (`←`, `⇐`) or a change of definition (`↩`).
* **Assignment arrow**: `←`, `⇐`, or `↩`, used to denote assignment.
* **Definition**: The first assignment of a variable, which must be performed with `←` or `⇐`.
* [**Destructuring assignment**](expression.md#destructuring): a form of assignment that can extract components of arrays and namespaces.

* [**Scope**](lexical.md): An environment where variables are defined and manipulated, which is created before evaluating a body.
* **Identifier**: An instance of a name in a program, with two identifiers considered the same if they correspond to the same definition.

## Blocks

* [**Block**](block.md): A syntactic element surrounded in curly braces `{}`, which encapsulates code.
* [**Immediate block**](block.md#headerless-blocks): A block that's evaluated giving a result immediately; it has a subject role.
* **Block function**: A block defining a function.
* **Block modifier**: A block defining a 1- or 2-modifier.
* [**Immediate modifier**](block.md#operands): A modifier that's evaluated as soon as it receives its operands.
* [**Deferred modifier**](block.md#operands): The opposite of an immediate modifier, one that's only evaluated when called with operands and arguments.
* [**Body**](block.md#multiple-bodies): One sequence of statements in a block. Bodies, possibly preceded by headers, are separated by semicolons `;`.
* [**Header**](block.md#block-headers): A preface to a body in a block function or modifier indicating possible inputs, which is followed by a colon `:`.
* [**Label**](block.md#short-headers): A header consisting of a single name.
* [**Predicate**](block.md#predicates): An expression followed by `?`, which acts as a condition for the body to continue running.
* [**Tacit**](tacit.md): Code that defines functions without using blocks.

## Namespaces

* [**Namespace**](namespace.md): A container for variables, some of which are exposed as fields.
* **Field**: One of the variables accessible from outside a namespace.
* **Access**: To get the current value of a field from a namespace.
* [**Export**](namespace.md#exports): Declare a variable to be accessible from the outside, that is, make it a field.
* [**Object**](oop.md): Informal term for a namespace that holds mutable state.
* [**Alias**](namespace.md#imports): A different "outside" name chosen for a field in a destructuring assignment.
