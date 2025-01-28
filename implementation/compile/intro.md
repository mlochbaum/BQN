*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/compile/intro.html).*

# Array language compilation in context

Chances are that if you're reading this, you know the difference between an interpreter and a compiler, and what separates C from interpreted Python. Good! You have a lot more to learn to understand what compilation means for the array language paradigm. The most important is that, for an array language, compiling isn't automatically better in the way that Python compilers tend to run a lot faster than interpreters. The two strategies have different advantages, and a hybrid approach could be much better than either alone. Here we'll discuss what makes BQN fast, what keeps it from always being fast, and how compiling might help.

Scratch that, the *most* important piece of context is that you don't actually care about performance. On array programming forums there are many questions about how to speed up code or what the fastest approach would be. Nine times out of ten, or more, such a post is about a program that takes a fraction of a second—sometimes, under a millisecond, sometimes, under a microsecond. The program was already fast enough! In other cases the answer is almost never to switch languages, but to tweak the code slightly or use a different algorithm. The use cases that call for a general-purpose language and demand full hardware efficiency are rare, and it's much more important to make a language that is easy to write code in than one that runs it quickly.

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

BQN uses dynamic types, but in each array it tries to determine a common [element type](../primitive/types.md): for example it might notice that every element can be represented as a signed two-byte integer. The type is stored only once in the array header, and all elements are packed into memory using the appropriate type. So the two-byte integer array would be stored using a fixed-size header (which mostly consists of the shape and other non-type things), then two bytes for each element.

I sometimes think of C's approach to types as **temporally homogeneous**, because once you write a function, a call one minute has the same types as a call the next, and BQN's as **spatially homogeneous**, because in an array each element has the same type as another one address over.

The temporal/spatial distinction isn't the same as static versus dynamic typing. Array elements in a statically-typed language are *both* temporally and spatially homogeneous, although in my opinion C compilers today only properly take advantage of the temporal part. And a dynamically-typed language can take advantage of temporal homogeneity with a combination of type inference and runtime checks, like a Javascript JIT compiler does.

### And which is better

Because static typing lets the programmer say exactly what type the data should have, it ought to be faster, right? Well that's a bold hypothesis, C Programming Language, given that you spent the entire 90s working to convince programmers that it's better to let the compiler choose which assembly instructions are run and in what order.

Array type detection can be both fast and accurate. First off, scanning a BQN array to get the appropriate type is very quick to do with vector instructions, particularly if it's an integer array. But also, this isn't usually necessary, because most primitives have an obvious result type. Structural manipulation leaves the type unchanged, and arithmetic can be done with built-in overflow checking, adding about 10% overhead to the operation in a typical case.

And on the other side, it's hard to pick a static type that always works. Most times your forum software is run, each user will have under `2⋆15` posts. But not always, and using a short integer for the post count wouldn't be safe. With dynamically typed arrays, your program has the performance of a fast type when possible but scales to a larger one when necessary. So it can be both faster and more reliable.

However, with current array implementation technology, these advantages only apply to array-style code, when you're calling primitives that each do a lot of work. In order to get many small primitive calls working quickly, you need a compiler. Compilers have another significant benefit in the form of [**loop fusion**](https://en.wikipedia.org/wiki/Loop_fusion), allowing multiple primitives to be executed in one round without writing intermediate results. This is most important for arithmetic on arrays, where the cost of doing the actual operation is much less than the cost of reading and writing the results if evaluated using SIMD instructions. I think the benefits of fusion are often overstated because it's rare for such simple operations to make up a large portion of program runtime, but there's no doubt that it can provide some benefit for most array-oriented programs and a large benefit for some of them. [This page](fusion.md) has more about the topic.

## Optimizing array primitives

There is a bit more to say while we're still in interpreter-land (the title says "compilation in context", but I'm sorry to inform you that this page is heavy on "context", but not so hot on "compilation", and frankly lukewarm on "in"). The function `+´` isn't a primitive, it's two!

The way that `+´` is evaluated using specialized code is that `´`, when invoked, checks whether its operand is one of a few known cases (at the time of writing, `+×⌊⌈∧∨`). If so, it checks the type and applies special code accordingly. Arguably, this is a very rudimentary form of just-in-time compilation for the function `+´`, as it takes a program that would apply `+` many times and transforms it to special pre-compiled code that doesn't call the `+` function. However, it's pretty different from what a compiled language would do in that this function is never associated with the object representing `+´`, so that `+´` is re-compiled each time it's run.

Array languages often optimize primitives or arithmetic combinations (folds, scans, table, rank) better than current C compilers handle the code a user would write for them. Partly this is because with C being so low-level it's hard to extract the meaning from this code (pointer aliasing can also get in the way). An array language implementer has an easier job since `-⌜` or `` ∨` `` is easy to detect. I also think C compilers just don't pay as much attention to array operations as they should. I can't imagine any reason why the C code for an integer prefix sum `` +` `` shouldn't generate SIMD code, but I've tried and failed to get gcc or clang to do it.

Forms like `+´` are very simple examples of [tacit](../../doc/tacit.md) code. It's possible to compile more complex tacit forms as well. [I the language](https://github.com/mlochbaum/ILanguage) compiles some tacit programs directly to x86 machine code. For example, if a fold (maybe the equivalent of `(1+×)´`) is called on a list of at least 8 elements, then it attempts to determine the result type and compile code for the entire fold. It doesn't save this machine code, so in one way it's an extension to the treatment of `+´` that re-analyzes the function every time. However, generating code on demand makes it a true JIT compiler.

## Compiling array languages

With this context, what would it mean to compile an array language? I'll try to survey existing and possible approaches here. Note that I don't have first-hand experience with typed array languages as a user or an implementer, so I can't give a very detailed account of what they do and there's a higher-than-usual chance of errors when I talk about them.

I'm now discussing what most people mean when they say "compiled APL", which means running code using machine code that's purpose-built for that particular operation. To make this code, the compiler must know the types of the values it's dealing with, so the two strategies discussed above come into play: have the user specify types, or derive them as the code is running. Various optimizations are possible without knowing types (for example BQN has some rudimentary lifetime analysis, which frees some variables when they're no longer used), but as they're not specific to array languages I've decided they're out of scope for this page.

### Typed array languages

Most array language compilers, and certainly the most successful ones, are based on static typing. Typed array languages have become a major subject of research in the last ten years or so, and the following two groups have arisen:

- ML-family (like Haskell): [Futhark](https://github.com/diku-dk/futhark) has size-dependent types and [Dex](https://github.com/google-research/dex-lang) has fully dependent types
- [MLIR](https://mlir.llvm.org/) and XLA, low-level drivers of deep learning frameworks like TensorFlow

One of the reasons to cover static types first is that all of these languages are promising compilation targets for BQN code when types have been determined. They're mostly designed for large arrays, with a significant focus on GPUs. This would make them a sort of a specialized tool in an array language, where most programs use many small and medium arrays even if the goal is to manipulate large ones.

Three major efforts to apply ahead-of-time compilation to APL are [APEX](https://www.snakeisland.com/apexup.htm), [apltail](https://github.com/melsman/apltail), and [Co-dfns](https://github.com/Co-dfns/Co-dfns). It's worth noting that none has had any apparent uptake in the APL world. I think this is because they have to leave out significant functionality to compile ahead of time, and because performance doesn't actually matter to APL programmers, as mentioned in the introduction. From my reading it appears that APEX is statically typed, since each value in the source code can have only one type, and declarations (written as APL comments) are required to disambiguate if the are multiple possibilities. apltail and Co-dfns are dynamically typed, but apltail compiles to Typed Array Intermediate Language (TAIL), which, as the name insists, is statically typed. As far as I know TAIL is used only as a target for apltail. Some effort has been expended on the [tail2futhark](https://github.com/henrikurms/tail2futhark) project, but it's no longer maintained.

### Compiling with dynamic types

Moving to dynamically-typed languages, the actual compilation isn't going to change that much. What we are interested in is types. When and how are they determined for values that haven't been created yet?

First I think it's worth discussing [Julia](https://julialang.org/), which I would describe as the most successful compiled dynamically-typed array language. Each array has a particular type, and it sticks with it: for example if you multiply two `Int8` arrays then the results will wrap around rather than increasing the type. But functions can accept many different argument types. Julia does this by compiling a function again whenever it's called on types it hasn't seen before. The resulting function is fast, but the time spent compiling causes significant delays. The model of arrays with a fixed type chosen from many options is the same as NumPy, which follows a traditional interpreted model. But it's different from APL and BQN, which have only one number type and optimize using subsets. J and K sit somewhere in between, with a small number of logical types (such as separate integers and floats) and less subset use.

The ahead-of-time compilers apltail and Co-dfns mentioned in the previous section take different approaches. apltail uses a powerful (but not dependent) type system with type inference to detect which types the program uses. Co-dfns compiles to ArrayFire code that is still somewhat dynamic, with switches on rank or types. It's possible the ArrayFire compiler can optimize some of them out. I think that while these impressive projects are definitely doing something worthwhile, ahead-of-time compilation on its own is ultimately not a good basis for an array language implementation (but it's just my opinion, and I may well be wrong! Don't let me stop you!). There's too much to gain by having access to the actual data at compilation time, and being able to fit it into a smaller type.

However, I would be very interested in compiling BQN's stack-based IR using these ahead-of-time methods. The ArrayFire code from Co-dfns would be easiest to generate and can probably be adapted to BQN primitives (Dyalog has indicated in a non-committal way that they're interested in integrating Co-dfns into Dyalog APL as well). Other backends could provide better performance at the cost of type analysis, which brings us to the question of how to approach types in running dynamic code.

A very early example of JIT compilation, [APL\3000](https://aplwiki.com/wiki/APL%5C3000), begins by compiling each function for the exact types it's called with on the first call and recompiles for more general types when its assumptions are broken. This keeps the program from spending all its time compiling, but also can't optimize a function well over multiple types; given how cheap memory is now I think it's better to compile multiple versions more readily.

I wrote in more detail about various strategies in the page on [dynamic compilation](dynamic.md). For one example of an advanced approach, my guess as to the best framework—given unlimited time to implement it—to deal with large arrays on a typical computer is to layer many strategies together:

- At the largest scale, execution is dynamic
- When possible, a few upcoming primitives are statically analyzed together and probably fused
- Execution is split into large chunks which can be split across processors
- A single chunk is evaluated using specialized (but possibly JIT-compiled) SIMD or GPU code.

So, both in the time domain and the space/index domain there's an outer dynamic layer and an inner fixed one. Fusion is important here but the lowest level of optimization should still probably understand array primitives rather than breaking them into scalar loops. The scalar methods don't have deep enough understanding to generate the fancy primitive algorithms that humans can.
