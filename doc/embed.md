*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/embed.html).*

# Using embedded BQN

The Javascript implementation of BQN can be [used](https://mlochbaum.github.io/BQN/try.html) as a standalone interpreter, but it can also be called from JS, which in combination with BQN's first-class functions allows the two language to interoperate well. Similar functionality will most likely be brought to other host languages in the future. Languages that (like JS) allow functions and arrays to be tagged with extra properties can host a full BQN implementation with good interoperability. Other languages would either require functions and arrays to be stored in specialized data structures, making interoperability a little harder, or would miss out on some inferred properties like function inverses and array fills.

There is only one mechanism to interface between the host language and BQN: you can evaluate a BQN program from the host and get the result back. Doesn't sound like much, especially considering these programs can't share any state such as global variables (BQN doesn't have those). But taking first-class functions and closures into account, it's all you could ever need!

## JS encodings

It's often useful to pass BQN values directly from JS instead of creating them in BQN. BQN operations don't verify that their inputs are valid BQN values (this would have a large performance cost), so it's up to the JS programmer to make sure that values passed in are valid. To do this, you need to know how BQN values are encoded in JS. Each of the six [types](types.md) has its own encoding.

The two atomic data values are simple: numbers are just JS numbers, and characters are strings containing a single code point. Arrays *are* JS arrays, but with some extra information. Since JS arrays are 1-dimensional, a BQN array `a` is stored as the element list `⥊a`. Its shape `≢a`, a list of numbers, is `a.sh` in JS (the shape isn't necessarily a BQN array so it doesn't have to have a `sh` property). Optionally, its fill element is `a.fill`.

Operations are all stored as JS functions, with one or two arguments for the inputs. The type is determined by the `.m` property, which is `1` for a 1-modifier and `2` for a 2-modifier, and undefined or falsy for a function. Functions might be called with one or two arguments. In either case, `𝕩` is the first argument; `𝕨`, if present, is the second. Note that `F(x,w)` in Javascript corresponds to `w F x` in BQN, reversing the visual ordering of the arguments! For modifiers there's no such reversal, as `𝕗` is always the first argument, and for 2-modifiers `𝕘` is the second argument. As in BQN, a modifier may or may not return a function.
