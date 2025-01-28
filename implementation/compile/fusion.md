*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/compile/fusion.html).*

# Loop fusion in array languages

Interpreted array languages have a major problem. Let's say you evaluate some arithmetic on a few arrays. Perhaps the first operation adds two arrays. It will loop over them, ideally adding numbers a vector register at a time, and write the results to an array. Maybe next it will check if the result is more than 10. So it'll read vectors from the result, compare to 10, pack to bit booleans, and write to another array. Each primitive has been implemented well but the combination is already far from optimal! The first result array isn't needed: it would be much better to compare each added vector to 10 right when it's produced. The extra store and load (and index arithmetic) are instructions that we don't need, but by using extra memory we can also create cache pressure that slows down the program even more.

Scalar languages don't have this problem. The programmer just writes the addition and comparison in a loop, the compiler compiles it, and every comparison naturally follows the corresponding addition. More modern languages might prefer approaches like iterators that abstract away the looping but still have the semantics of a fused loop. But an iterator call, let's say `zipwith(+, a.iter(), b.iter()).map(>10)` to make up some syntax, has a pretty obvious array equivalent, and if the functions are pure the different semantics don't matter! This has led to several compiled array languages like [APEX](https://www.snakeisland.com/apexup.htm) that work on the principle of re-interpreting the scalar parts of array operations in a way that fuses naturally.

Scalar compilation gives up many advantages inherent to array programming, a topic I discussed more broadly [here](intro.md). The obvious complaint is that you lose the vector instructions, but that's easy enough to dismiss. Any decent C compiler can auto-vectorize a loop, and so could an array compiler. But arithmetic is rarely the bottleneck, so let's say that the comparison's result will be used to filter a third array, that is, the expression is now `(10<a+b)/c`. Filtering doesn't auto-vectorize! At least the C compilers I've dealt with will fall back to producing completely scalar code. Depending on type, this can actually be slower than CBQN's un-fused, but SIMD, primitives.

In this case the problem is more that compilers don't _know_ how to vectorize [filtering](../primitive/replicate.md#booleans), since in AVX-512 at least there's an instruction to do it an write a partial result. Fusing the result into more arithmetic later would be a more fundamental difficulty, because round of Replicate produces an unknown number of values so it can't be directly paired with an input vector. What we need is a way to cut the fusion at this point, writing to memory as an escape. I believe array languages are best served by two levels of fusion, a looser level that ensures this memory use isn't excessive, and tighter fusion at the level of registers.

## Blocking and cache levels

The loosest form of loop fusion goes by various names such as blocking, chunking, or tiling. Instead of running each primitive on the entire array, we run it on a block of a few kilobytes. Looping within a block stays separate, but the outer layer of looping over blocks can be fused. So in `(10<a+b)/c` we'd add blocks from `a` and `b`, compare each one to 10, and use the result to filter a block of `c`, before moving on to the next set of blocks. This has the advantage that it doesn't actually require compilation, as blocks can still be processed with pre-compiled functions. It has the disadvantage that each block operation still reads and writes to memory—hang on, what problem are we actually trying to solve here?

For basic arithmetic, working from memory is a big relative cost, because even at the fastest cache level a load or store costs about as much the arithmetic itself. Heavier primitives like scans, filtering, transpose, or searching in a short list, do a lot more work in between, so if load and store _only_ cost about as much as arithmetic that's actually pretty good. But large arrays don't fit in the fastest cache level. If a primitive writes a large result, then by the time it's done only a little piece at the end is still saved in L1. The next primitive will start at the beginning and miss L1 entirely! If the interpreter instead works in blocks that are significantly smaller than the L1 cache, accesses between primitives should stay within L1 and only the boundary of fusion, meaning the initial reads and final write, can be slow.

Blocking is still compatible with finer-grained fusion. Primitives should simply be fused as block operations and not whole-array operations.

Sounds simple, but blocking has its difficulties even once the primitives to be blocked have been identified. As is becoming a pattern, one-to-one arithmetic suffers from none of these and is trivial.
- Do we want to block at all? For very small arrays, setting up the block system may be expensive. Otherwise it's fine to "block" the computation even if a block is a whole array (and it may be a good idea to allow a single oversize block at the end instead of making one that's very small)
- Shifting and rotation have unaligned input and output: one output should be formed from two inputs
- Replicate changes the block size: if it shrinks it, multiple output blocks should be gathered together; if it expands it, how will we even know the right input size?
- Functions like scans have state that needs to be carried across blocks
- Two stateful functions might end up with different iteration orders, preventing fusion (e.g. combining forward and reverse scan with ``∧`∨∧`⌾⌽``, or float `` +´+` `` as BQN's fold is unfortunately backwards)

Multidimensional operations are a whole new world of trouble. With a 2D transpose, for example, you probably want to work on square-ish blocks. The short side should be at least a cache line long to avoid re-reading or re-writing cache lines. Tiling like this is also okay for shifts, scans, and folds in either direction, but in some cases maybe it would be better for a block to be a section of a row, or even a column.

A computation that can be blocked but can't be freely reordered because of side effects, `•Show¨` for example, can be fused with primitives if the elements are passed to it in the right order. But two such functions can't be fused because the first needs to run on every block before the second gets any. Fusion needs to be cut at some point between them, perhaps in a place where memory use is lowest. And a function that can't be blocked at all obviously can't be fused, but there may still be some value in reordering relative to primitives: for example `(F c) × a+b` is defined to compute `+` before `F` but doing them in the other order has the same result and allows `+` and `×` to be fused. This should only be done if any reordered primitives (`+` here) are known not to have errors, to avoid calling `F` and then throwing an error that should have happened first.

Blocking has a natural benefit for adaptive algorithms, which is that pattern checks will apply at the block level rather than the whole array level. For example, for filtering `a/b`, if the number of result elements is small enough, then a sparse algorithm can skip past 0s in `a` and get the result faster. If this number is tested per-block, the implementation can take advantage of sparse regions of `a` even if it's not sparse overall.

## Low-level fusion

With a JIT compiler we can begin fusing smaller loops, to eliminate loads and stores entirely. Of course we'd rather fuse vector loops and not scalar ones. There are a few domains where this is easy, for example arithmetic on floats. But for the most part we quickly run into issues with types:
- Most arithmetic can overflow. How often do you need to check for overflow and what do you do when it fails? How do you combine the results when one iteration overflows and another doesn't?
- Mixed types mean a different number of elements will fit into each register. So, if the calculation initially works on 2-byte ints but then a division switches it to floats, do we do a full 2-byte vector and then 4 copies of the float method, which might spill? Or only fill part of a 2-byte vector?
- When comparisons give you booleans, do you pack results together to handle more with one instruction, or leave them at the width of the compared elements?

The answers depend on which types are used and how much. A wrong answer for one step is not a big deal, but a badly wrong answer, like failing to pack booleans when they make up 10 out of 15 steps, might mean the fused loop would be better off being cut in half.

Folds and scans should be fusable when they have nice SIMD implementations (but overflow for scans becomes quite a gnarly problem). Folds are particularly valuable because of the small output, meaning an expression ending in a fold might need essentially no writes. Simpler non-arithmetic functions can be compiled profitably, for example consider `⌽»↕n` which has no loops but would benefit from a fused implementation (albeit, even more from being converted into arithmetic `0⌈(n-2)-↕n`). There are a pretty limited number of these and they look pretty easy to handle, even though shifts and reverse will require crossing vector and lane boundaries.

Selection and search primitives can be partly fused. The indexed-into argument (values for selection; searched-in values) needs to be known in advance. In some cases the primitive actually vectorizes in the other argument, with shuffle-based methods like in-register lookup tables and binary search. Otherwise it probably has to be evaluated with scalar code, or gather instructions which run on vectors but run as a sequence of loads. But at worst you unpack the input vector into scalars and pack the result back into vectors. You'll still get the normal benefits of fusion and maybe the surrounding actually-SIMD code will run while waiting on memory. For searches that build a table, this step could similarly be fused into the computation of the searched-in argument. Furthermore there are some possible ideas with sorted arguments: both sides can be fused in a selection where the indices are known to be sorted, or a search where both arguments are sorted.