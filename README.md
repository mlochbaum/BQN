*View this file with a real REPL [here](https://mlochbaum.github.io/BQN/index.html).*

# BQN: finally, an APL for your flying saucer

*Try it online below or [here](https://mlochbaum.github.io/BQN/try.html), and see [running.md](running.md) for more options.*
<!--REPL-->

**BQN** is a new programming language in the APL lineage, which aims to remove inconsistent and burdensome aspects of the APL tradition and put the great ideas on a firmer footing. BQN is aimed at existing and aspiring APL-family programmers, and using it requires a solid understanding of functions and multidimensional arrays. However, because of its focus on providing simple, consistent, and powerful array operations, BQN should also be a good language for learning array programming and building stronger array intuition.

BQN maintains many of the ideas that made APL\360 revolutionary in 1966:
* Human-friendly **infix notation** with no precedence rules to remember.
* **Built-in array operations** handle any number of dimensions easily.
* **Higher-order functions** allow basic functions to be applied in more powerful ways.

It incorporates concepts developed over years of APL practice:
* The [**leading axis model**](doc/leading.md), which allows for simpler built-in functions.
* Trains and combinators for **tacit programming**.
* Lightweight **anonymous functions** (like [dfns](https://aplwiki.com/wiki/Dfn)).

But BQN is redesigned from the ground up, with brand new ideas to make these paradigms easier to use and less likely to fail.
* The **based array model** makes non-arrays a fundamental part of the language, and removes the surprise of floating arrays and the hassle of explicit boxes. New **array notation** eliminates the gotchas of [stranding](https://aplwiki.com/wiki/Strand_notation).
* A [**context-free grammar**](doc/context.md) where a value's syntactic role is determined by its spelling makes it easier for machines and humans to understand code.
* Oh, and it naturally leads to [**first-class functions**](doc/functional.md), a feature often missed in APL.
* The **new symbols** for built-in functionality allow the syntactic role of a primitive to be distinguished at a glance, and aim to be more consistent and intuitive.

## What kind of name is "BQN"?

It's three letters, that happen to match the capitals in "Big Questions Notation". You can pronounce it "bacon", but are advised to avoid this unless there's puns.

## What does BQN look like?

Rather strange, most likely:

        ⊑+`∘⌽⍟12↕2  # The 12th Fibonacci number

For longer samples, you can [gaze into the abyss](src/c.bqn) that is the self-hosted compiler, or the [shallower but wider abyss](src/r.bqn) of the runtime, or take a look at the friendlier [markdown processor](md.bqn) used to format and highlight documentation files. There are also [some translations](examples/fifty.bqn) from ["A History of APL in 50 Functions"](https://www.jsoftware.com/papers/50/) here.

## How do I get started?

Read the [documentation](doc/README.md)!

BQN documentation is currently written primarily for array programmers and is not comprehensive, with aspects of the language that are shared with APL poorly documented. If you're not an array programmer, it would probably be better to start with another language, or wait a few weeks. But if you're a serious language enthusiast, the [specification](spec/README.md) is fairly complete and might be enough to fill the gaps in the documentation.

If you're an array programmer, then you're in much better shape. However, you should be aware of two key differences between BQN and existing array languages beyond just the changes of [primitives](doc/primitive.md)—if these differences don't seem important to you then you don't understand them! BQN's based array model is different from both a flat array model like J and a nested one like APL2, Dyalog, or GNU APL in that it has true non-array values (plain numbers and characters) that are different from depth-0 scalars. BQN also uses [syntactic roles](context.md) rather than dynamic type to determine how values interact, that is, what's an argument or operand and so on. This system, along with lexical closures, means BQN fully supports Lisp-style [functional programming](functional.md).
