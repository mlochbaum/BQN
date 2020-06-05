# BQN: finally, an APL for your flying saucer

*This repository does not yet have a working implementation. You can try a prototype implementation [online here](https://mlochbaum.github.io/BQN2NGN/web/index.html) (from [this repository](https://github.com/mlochbaum/BQN2NGN))*

**BQN** is a new programming language in the APL lineage, which aims to remove inconsistent and burdensome aspects of the APL tradition and put the great ideas on a firmer footing. BQN is aimed at existing and aspiring APL-family programmers, and using it requires a solid understanding of functions and multidimensional arrays.

BQN maintains many of the ideas that made APL\360 revolutionary in 1966:
* Human-friendly **infix notation** with no precedence rules to remember.
* **Built-in array operations** handle any number of dimensions easily.
* **Higher-order functions** allow basic functions to be applied in more powerful ways.
It incorporates concepts developed over years of APL practice:
* The **leading axis model**, which allows for simpler built-in functions.
* Trains and combinators for **tacit programming**.
* Lightweight **anonymous functions** (like [dfns](https://aplwiki.com/wiki/Dfn)).
But BQN is redesigned from the ground up, with brand new ideas to make these paradigms easier to use and less likely to fail.
* The **based array model** makes non-arrays a fundamental part of the language, and removes the surprise of floating arrays and the hassle of explicit boxes. New **array notation** eliminates the gotchas of [stranding](https://aplwiki.com/wiki/Strand_notation).
* A **context-free grammar** where a value's syntactic role is determined by its spelling makes it easier for machines and humans to understand code.
* Oh, and it naturally leads to **first-class functions**, a feature often missed in APL.
* The **new symbols** for built-in functionality allow the syntactic role of a primitive to be distinguished at a glance, and aim to be more consistent and intuitive.

## What does BQN look like?

It looks like qebrus okay:

    ⊑+`∘⌽⍟12↕2  ⍝ The 12th Fibonacci number

[More examples here](https://github.com/mlochbaum/BQN2NGN/tree/master/examples).

## Syntax

Like APL, BQN values have one of four *syntactic classes*:
* **Values**, like APL arrays or J nouns
* **Functions**, or verbs in J
* **Modifiers**, like APL monadic operators or J adverbs
* **Combinators**, like APL dyadic operators or J conjunctions.

These classes work exactly like they do in APL, with functions applying to one or two arguments, modifiers taking a single function or value on the left, and combinators taking a function or value on each side.

Unlike APL, in BQN the syntactic class of a value is determined purely by the way it's spelled: a lowercase first letter (`name`) makes it a value, an uppercase first letter (`Name`) makes it a function, and underscores are used for modifiers (`_name`) and combinators (`_name_`). Below, the function `{𝕎𝕩}` treats its left argument `𝕎` as a function and its right argument `𝕩` as an argument. With a list of functions, we can make a table of the square and square root of a few numbers:

        ⟨×˜,√⟩ {𝕎𝕩}⌜ 1‿4‿9
    ┌
      1 16 81
      1  2  3
              ┘

## Built-in operations

### Functions

| Glyph | Monadic          | Dyadic
|-------|------------------|---------
| `+`   | Conjugate        | Add
| `-`   | Negate           | Subtract
| `×`   | Signum           | Multiply
| `÷`   | Reciprocal       | Divide
| `⋆`   | Exponential      | Power
| `√`   | Square Root      | Root
| `⌊`   | Floor            | Min
| `⌈`   | Ceiling          | Max
| `∧`   | Sort Up          | And
| `∨`   | Sort Down        | Or
| `¬`   | Not              | Span
| `\|`  | Absolute Value   | Modulus
| `=`   |                  | Equals
| `≠`   | Count            | Not Equals
| `≤`   |                  | Less Than or Equal to
| `<`   | Box              | Less Than
| `>`   | Unbox            | Greater Than
| `≥`   |                  | Greater Than or Equal to
| `≡`   | Depth            | Match
| `≢`   | Shape            | Not Match
| `⊣`   | Identity         | Left
| `⊢`   | Identity         | Right
| `⥊`   | Deshape          | Reshape
| `∾`   | Join             | Join to
| `≍`   | Itemize          | Laminate
| `↑`   | Prefixes         | Take
| `↓`   | Suffixes         | Drop
| `↕`   | Range            | Windows
| `⌽`   | Reverse          | Rotate
| `⍉`   | Transpose        | Reorder axes
| `/`   | Indices          | Replicate
| `\`   |                  | Partition
| `⍋`   | Grade Up         | Bins Up
| `⍒`   | Grade Down       | Bins Down
| `⊏`   | First Cell       | Select
| `⊑`   | First            | Pick
| `⊐`   |                  | Index of
| `⊒`   | Occurrence Count | Progressive Index of
| `∊`   | Unique Mask      | Member of
| `⍷`   |                  | Find
| `⊔`   | Group            | Key
