*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/compile/intro.html).*

# Array language compilation in context

Chances are that if you're reading this, you know the difference between an interpreter and a compiler, and what separates C from interpreted Python. Good! You have a lot more to learn to understand what compilation means for the array language paradigm. The most important is that, for an array language, compiling isn't automatically better in the way that Python compilers tend to run a lot faster than interpreters. The two strategies have different advantages, and a hybrid approach could be much better than either alone. Here we'll discuss what makes BQN fast, what keeps it from always being fast, and how compiling might help.

## Array interpreters

Learn to run the code before you can tree-walk the source.

### Fast and slow evaluation

Let's start by looking closer at the example of C versus Python. Suppose you write a simple program, with a for loop, to sum the elements of a floating-point list in order. To evaluate this code, C compiles it to some machine code that quickly adds the elements. Python *does* compile the code as well, but only a little, leaving some object code that has any syntax complications stripped out but keeps the source code semantics entirely intact. Executing this code is relatively slow.

BQN executes like Python! If you write out a summation loop `{s←0⋄{s+↩𝕩}¨𝕩⋄s}`, it's also slow. But you wouldn't do this in BQN: you'd write `+´` to sum the list, and this runs at about the same speed as C for a long enough list. Well, the reason for that is just that CBQN has some pre-written C code to sum a list of floats, and it recognizes `+´` and calls that.

You wouldn't write the loop in Python either—you'd write `sum(arr)`. There are two differences, however. First, BQN's carefully chosen primitive set and cultural emphasis on array programming mean you're more likely to write a program where most computation is done with fast primitives. Second, uh, Python is slower. I measure about 2ms to sum `1e6 •rand.Range 0` in BQN and 8ms to sum the equivalent in Python.

Python developers aren't stupid, just uninformed! Specifically, they are lacking information about types (and, as an aside, I like Python and am often found defending it against more hostile array programmers). Both C and BQN are faster because they're able to take advantage of knowing that all elements to be added are double-precision floats.

### Ways of knowing types

C and CBQN ultimately sum an array of floats with the same machine code, but they arrive at it in a different way.

C requires the programmer to specify the types used, and more generally a statically typed language is one where the type of a particular value is fixed based on the source code (or each copy of the value, with generics or other code generation mechanisms).

BQN uses dynamic types, but in each array it tries to determine a common element type: for example it might notice that every element can be represented as a signed two-byte integer. The type is stored only once in the array header, and all elements are packed into memory using the appropriate type. So the two-byte integer array would be stored using a fixed-size header (which mostly consists of the shape and other non-type things), then two bytes for each element.

I sometimes think of C's approach to types as **temporally homogeneous**, because once you write a function, a call one minute has the same types as a call the next, and BQN's as **spatially homogeneous**, because in an array each element has the same type as another one address over.

The temporal/spatial distinction isn't the same as static versus dynamic typing. Array elements in a statically-typed language are *both* temporally and spatially homogeneous, although in my opinion C compilers today only properly take advantage of the temporal part. And a dynamically-typed language can take advantage of temporal homogeneity with a combination of type checking and type inference, like a Javascript JIT compiler does.

### And which is better

Because static typing lets the programmer say exactly what type the data should have, it ought to be faster, right? Well that's a bold hypothesis, C Programming Language, given that you spent the entire 90s working to convince programmers that it's better to let the compiler choose which assembly instructions are run and in what order.

Array type detection can be both fast and accurate. First off, scanning a BQN array to get the appropriate type is very quick to do with vector instructions, particularly if it's an integer array. But also, this isn't usually necessary, because most primitives have an obvious result type. Structural manipulation leaves the type unchanged, and arithmetic can be done with built-in overflow checking, adding about 10% overhead to the operation in a typical case.

And on the other side, it's hard to pick a static type that always works. Most times your forum software is run, each user will have under `2⋆15` posts. But not always, and using a short integer for the post count wouldn't be safe. With dynamically typed arrays, your program has the performance of a fast type when possible but scales to a larger one when necessary. So it can be both faster and more reliable.

However, with current array implementation technology, these advantages only apply to array-style code, when you're calling primitives that each do a lot of work. In order to get many small primitive calls working quickly, you need a compiler.
