*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/embed.html).*

# Using embedded BQN

The Javascript implementation of BQN, [docs/bqn.js](../docs/bqn.js), can be [used](https://mlochbaum.github.io/BQN/try.html) as a standalone interpreter, but it can also be called from JS, which in combination with BQN's first-class functions allows the two languages to interoperate well. Similar functionality will most likely be brought to other host languages in the future (and there's a [Rust binding](https://detegr.github.io/cbqn-rs/cbqn/) to CBQN that works a lot like an embedding). Languages that (like JS) allow functions and arrays to be tagged with extra properties can host a full BQN implementation with good interoperability. Other languages would either require functions and arrays to be stored in specialized data structures, making interoperability a little harder, or would miss out on some inferred properties like function [inverses](undo.md) and array [fills](fill.md).

There is only one mechanism to interface between the host language and BQN: the function `bqn` evaluates a string containing a BQN program and returns the result. Doesn't sound like much, especially considering these programs can't share any state such as global variables (BQN doesn't have those). But taking first-class functions and closures into account, it's all you could ever need!

## Passing closures

Probably you can figure out the easy things like calling `bqn("×´1+↕6")` to compute six factorial. But how do you get JS and BQN to *talk* to each other, for example to compute the factorial of a number `n`? Constructing a source string with `bqn("×´1+↕"+n)` isn't the best way—in fact I would recommend you never use this strategy.

Instead, return a function from BQN and call it: `bqn("{×´1+↕𝕩}")(n)`. This strategy also has the advantage that you can store the function, so that it will only be compiled once. Define `let fact = bqn("{×´1+↕𝕩}");` at the top of your program and use it as a function elsewhere.

BQN can also call JS functions, to use functionality that isn't native to BQN or interact with a program written in JS. For example, `bqn("{𝕏'a'+↕26}")(alert)` calls the argument `alert` from within BQN. The displayed output isn't quite right here, because a BQN string is stored as a JS array, not a string. See the next section for more information.

Cool, but none of these examples really use closures, just self-contained functions. [Closures](lexical.md#closures) are functions that use outside state, which is maintained over the course of the program. Here's an example program that defines `i`, and then returns a function that manipulates `i` and returns its new value.

    let push = bqn(`
        i←4⥊0
        {i+↩𝕩»i}
    `);
    push(3);    // [3,0,0,0]
    push(-2);   // [1,3,0,0]
    push(4);    // [5,4,3,0]

Note that this program doesn't have any outer braces. It's only run once, and it initializes `i` and returns a function. Just putting braces around it wouldn't have any effect—it just changes it from a program that does something to a program that runs a block that does the same thing—but adding braces and using `𝕨` or `𝕩` inside would turn it into a function that could be run multiple times to create different closures. For example, `pushGen = bqn("{i←4⥊𝕩⋄{i+↩𝕩»i}}")` causes `pushGen(n)` to create a new closure with `i` initialized to `4⥊n`.

The program also returns only one function, which can be limiting. But it's possible to get multiple closures out of the same program by returning a list of functions. For example, the following program defines three functions that manipulate a shared array in different ways.

    let [rotx, roty, flip] = bqn(`
        a ← 3‿2⥊↕6
        RotX ← {a↩𝕩⌽˘a}
        RotY ← {a↩𝕩⌽a}
        Flip ← {𝕊:a↩⍉a}
        RotX‿RotY‿Flip
    `);

When defining closures for their side effects like this, make sure they are actually functions! For example, since `flip` ignores its argument (you can call it with `flip()`, because a right argument of `undefined` isn't valid but will just be ignored), it needs an `𝕊:` in the definition to be a function instead of an immediate block.

You can also use an array to pass multiple functions or other values from JS into BQN all at once. However, a JS array can't be used directly in BQN because its shape isn't known. The function `list()` converts a JS array into a BQN list by using its length for the shape; the next section has a few more details.

## JS encodings

In the programs above we've used numbers and functions of one argument, which mean the same thing in BQN and JS. This isn't the case for all types: although every BQN value is stored as some JS value, the way it's represented may not be obvious and there are many JS values that don't represent any BQN value and could cause errors. BQN operations don't verify that their inputs are valid BQN values (this would have a large performance cost), so it's up to the JS programmer to make sure that values passed in are valid. To do this, you need to know the encodings for each of the seven BQN [types](types.md) you're going to use.

The two atomic data values are simple: numbers are just JS numbers, and characters are strings containing a single code point. Arrays *are* JS arrays, but with some extra information. Since JS arrays are 1-dimensional, a BQN array `a` is stored as the element list `⥊a`. Its shape `≢a`, a list of numbers, is `a.sh` in JS (the shape isn't necessarily a BQN array so it doesn't have to have a `sh` property). Optionally, its [fill element](fill.md) is `a.fill`. Note that a BQN string is not a JS string, but instead an array of BQN characters, or JS strings. To convert it to a JS string you can use `str.join("")`.

There are two utilities for converting from JS to BQN data: `list([…])` converts a JS array to a BQN list, and `str("JS string")` converts a string.

Operations are all stored as JS functions, with one or two arguments for the inputs. The type is determined by the `.m` property, which is `1` for a 1-modifier and `2` for a 2-modifier, and undefined or falsy for a function. Functions might be called with one or two arguments. In either case, `𝕩` is the first argument; `𝕨`, if present, is the second. Note that `F(x,w)` in JS corresponds to `w F x` in BQN, reversing the visual ordering of the arguments! For modifiers there's no such reversal, as `𝕗` is always the first argument, and for 2-modifiers `𝕘` is the second argument. As in BQN, a modifier may or may not return a function.

Operations may have some extra properties set that aren't terribly important for the JS programmer: for each primitive `p`, `p.glyph` gives its glyph, and for a compound operation `o` such as a train, or a modifier with bound operands, `o.repr()` decomposes it into its parts. It wouldn't make sense to define either of these properties for a function created in JS.

## Other functionality

The BQN script also contains the function `fmt`, which takes a BQN value for its argument and returns a string displaying it.

The expression diagram builder used for the REPL's "Explain" button isn't included in the main BQN script: it's kept in [docs/repl.js](../docs/repl.js) instead. It's a little tricky to use as it takes both the source string and the bytecode obtained from compiling the source: see the surrounding Javascript code for an example. The result is the source code for an svg, as a BQN string.
