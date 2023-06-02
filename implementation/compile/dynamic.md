*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/compile/dynamic.html).*

# Dynamic compilation

This page discusses at a high level (without covering any specific source transformations) how compilation and interpretation might be structured in order to execute BQN faster. Effective strategies will compile parts of the program with more specialization or higher optimization as it runs and more information about it becomes known.

To avoid confusion, an **interpreter** evaluates code to perform actions or produce a result; a CPU is a machine code interpreter. A **compiler** transforms code in one language or format to another. To run a program that does anything, it must eventually be interpreted; before this the program or parts of it might be compiled any number of times.

The starting point for algorithms described here is bytecode for the BQN [virtual machine](../vm.md). Producing this bytecode mostly amounts to parsing the program, which any implementation would have to do anyway, and it's fast enough that compiling an entire file before starting isn't a big concern. The bytecode can be interpreted directly, but compiler passes can reduce the overhead for each instruction or implement groups of instructions more effectively. Sophisticated compiler passes cost time, so the improvement must be balanced against time spent even though it might not be known in advance.

## Considerations

### What are we optimizing?

How a program can be optimized depends on why it's taking time to run. Here we'll assume it's the core BQN syntax and primitives that are responsible, as things like system interaction are out of scope, and that the source file is not unreasonably large. The total time taken is the sum of the time taken by each action performed, so there are two main possibilities:

- Primitives take a long time, because of large arrays.
- There are many actions, because blocks are repeated many times.

If many bytecode instructions are evaluated, it must be that blocks are repeated, because each instruction can only be run once by its containing block. A function operand might be run many times by a modifier, which typically involves a large array, but could also be because of Repeat (`⍟`).

This is an array-based viewpoint, because in a low-level language the large array case would just be considered one of several kinds of repetition. Traditionally APL focused exclusively on speeding up the large array case; BQN's compilation makes better block performance a reachable goal.

The two conditions are routinely mixed in various ways: a program might split its time between manipulating small and large arrays, or it might work with large arrays but sometimes apply a block function to each element or small groups of elements. Array size or number of iterations could even differ between program runs. An evaluation strategy needs to adapt to these changes.

### Hardware

It's easiest to get BQN running on a single-threaded scalar CPU, but all of the following improvements are commonly available, and can greatly increase speed for some programs:

- SIMD instructions
- Multiple CPU cores
- GPUs

Each of the three is a good fit for array programming: any size array with SIMD and large arrays for multi-threading and GPU use. Multi-threading can also be useful for blocks that don't have side effects.

SIMD instructions can be used at the primitive level ([primitive implementation notes](../primitive/README.md)), with some improvement by fusing small operations together. Multi-threading is also possible at the primitive level, but no coordination between primitives will lead to cache coherency issues, and wasted time as some cores wait for others. It's probably better to analyze groups of primitives to allocate data and work. GPU execution is the fastest method for suitable programs, but can only handle certain kinds of code well and must use compiled kernels, which need to do a significant amount of work to justify the overhead.

### Cached optimization

Expensive ahead-of-time optimizations can be saved somewhere in the filesystem (presumably the XDG cache directory for Linux). This of course introduces the problem of cache invalidation: cache files need to be versioned so an old cache isn't used by a new BQN, and they need to be thrown out when the file is changed and avoid saving information about user input or external files that could change.

I think the data about a BQN source file that can be saved is generally pretty cheap to compute, and it's also important to make sure completely new code runs quickly. I'm hoping we don't have a reason to resort to caching.

## Strategies

### Hot paths

The basic strategy for JIT compilers like Java and Javascript (hey, they do actually have something in common!) is to track the number of times a block is called and perform more optimization as this number increases. It's also possible to record information about the inputs to do more specialized compilation, usually with a test in the compiled code to abort when the specialization is invalid.

CBQN already includes a count to control native compilation; because this compilation is fast the best value is very low, between 1 and 5. More powerful optimization would generally use higher counts.

Iteration modifiers ``˘⎉¨⌜´˝`⍟`` can compute how many times they will call the operand quickly: it's usually based on the result size or argument length. The slowest case is probably monadic Scan `` ` ``, where it's the size of `𝕩` minus the cell size, both values that already need to be computed. This number can be added to the existing count to find what level of optimization would be used, or even compared without adding, if false negatives are acceptable. This reduces the number of times the program runs blocks at the wrong optimization level, but slightly increases the overhead of mapping modifiers even on calls where the block to be run is already optimized at a high level. It can be restricted to only modifiers with a block operand because the modifier needs to inspect its operand anyway—the cost of running `=⌜` or `+´` without optimization is too high to skip this.

Iteration modifiers on typed arrays often allow the argument types to be known with certainty, so that the operand can be specialized on that type with no testing.

### Metadata

There's a lot of information about values that can be used to optimize, either in the general case if it's known for sure, or a specialization if it's suspected, or known under specific conditions. Type is the most important, then depth, rank, shape and element metadata for arrays and range or even value for numbers and characters. Other bulk properties like sortedness (to enable faster searches) or sum (for example, to find the shape of `/𝕩`) can be useful for arrays.

Proofs that constrain the metadata in all cases are the most valuable, since the properties don't have to be tested or recomputed if they're already known. One way to get this information is to do an initial run of a block that only propagates known information about metadata. For example, if `{+´↕𝕩}` is run on an integer array, `↕` can return a list of natural numbers with the same type as `𝕩` or cause an error, and `+´`, given a list of natural numbers, returns a natural number. This approach can only help if the block will be run multiple times: clearly for a single run computing metadata along with data is the fastest. It runs at interpreted rather than native speed (because it's only run once) and could in fact take many calls to break even. For large array code, where the interpretive overhead is irrelevant, it could also be a step before a compilation pass that fuses and rearranges primitives.

The same procedure can be run on local rather than global constraints, which might produce more specialized code at the cost of running through the block once per specialization.

Saving metadata from the first run is another possibility, with very low overhead. This most naturally provides a guess as to what the metadata usually is, but it may also be possible to keep track of when metadata is "known" with a flag system.

The desire to do metadata computations, or pure data ones once metadata is known suggests a system with a "wrapper" that computes type, shape, and so on, then selects and calls an "kernel" function for the computation. Specialized code could use a particular kernel, or a different wrapper that selects from a subset of the kernels.

### Compound functions

Like blocks, it can be valuable to optimize compound functions if they are run many times. Compound functions are often known at the program start by constant folding, but might also be constructed dynamically, particularly to bind an argument to a function.

Compound arithmetic functions like `+´`, `` ⌈` ``, or `=⌜` are essential to array programming, and have fast SIMD implementations, so they need to be recognized wherever they are found.

In addition to these, there are patterns like ``∨`∘≠`` that can be implemented faster than their components, and bindings like `l⊸⊐` where a computation (here, a hash table) on the left argument can be saved. These can be handled by inspecting the function. However, it's more robust to convert it to a canonical form, so this possibility should also be considered.

Tacit code can be converted to [SSA](https://en.wikipedia.org/wiki/Static_single_assignment_form) form very easily. To translate it into stack-based bytecode it would need a way to reuse values from the stack in multiple places; instructions to duplicate or extract a value from higher in the stack are an obvious candidate. Either of these forms is a natural step on the way to native compilation, and a bytecode representation would make it easier to optimize mixed tacit and explicit code—but it's easier to do the optimizations on SSA-form rather than stack-based code, so perhaps the right path is to convert both bytecode and compound functions to SSA.

### Compile in another thread

A simple and widely-used strategy to reduce slowdown due to dynamic compilation is to compile blocks in a separate thread from the one that runs them. The new code needs to be added in a thread-safe manner, which is not hard as the set of optimized implementations is a small lookup table of some sort with only one writer.

If the implementation is able to make use of all available threads (possible when working with large arrays), then it's still important to minimize compilation time as that thread could be put to better use. If there are idle threads then the only costs of compilation overhead are minor: the optimized code can't be put to use as quickly, and there is more power draw and possible downclocking.

### Anticipation

The [hot path](#hot-paths) strategy depends on targeting code for optimization based on history. Anticipation would identify in advance what code will take longer to run, and allocate a fraction of the time taken for optimizing that code. This is most useful for code that runs a small number of times on large arrays. An example where anticipation would be very important is for a programmer trying experimental one-off queries on a large dataset.

The end result seems similar to that obtained by thunks as discussed at Dyalog '18 ([video](https://dyalog.tv/Dyalog18/?v=-6no6N3i9Tg), [slides](https://www.dyalog.com/uploads/conference/dyalog18/presentations/D15_The_Interpretive_Advantage.zip)). A thunk runs as part of a primitive, detecting that computing the result will be slow and outputting a deferred computation instead. Anticipation is more powerful because it can scan ahead in the bytecode instead of deciding as primitives are called whether or not to expand the thunk.

Anticipation attempts to improve program speed while bounding the added overhead. For example, it might be constrained to add no more than 5% to the time to first program output, relative to base-level interpretation. The idea is to exit normal interpretation as soon as a large enough lower bound is established on this time, for example if an operation would create a large array. At this point it begins analysis, which will involve at least some shape propagation and probably increase the lower bound and optimization budget.

Optimization level can be gated based on the ratio of expected time to code length (which presumably controls cost of optimization). But optimization doesn't need to be performed all at once: upcoming code should be run as soon as it can be optimized at an appropriate level, in order to have more information available for later operations. Optimization might include primitive combinations or intermediate data formats, so it's important to check how the results will be used before running expensive code.
