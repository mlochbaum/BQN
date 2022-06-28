*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/transpose.html).*

# Implementation of array transpose

The [Transpose](../../doc/transpose.md) primitive `⍉` reorders axes of an array. It's a fairly deep primitive: even swapping two axes has some complexity, while rearranging many axes presents lots of different scenarios, making it hard to figure out which strategy will be best.

## Exchanging axes

Monadic transpose in BQN always exchanges one axis with the rest. As mentioned [below](#axis-simplification), that's equivalent to swapping exactly two axes. This case is easier to implement, but ideas that are useful for this simple transpose always apply to more complex ones as well.

The scalar approach is simply to set `res[i][j] = arg[j][i]` in a loop. Doing the writes in order and the reads out of order (so, `i` is the outer loop here) seems to be slightly faster. This is fine most of the time, but suffers slightly when the inner loop is very short, and can be improved with SIMD.

My talk "Moving Bits Faster in Dyalog 16.0" ([video](https://dyalog.tv/Dyalog17/?v=2KnrDmZov4U), [slides](https://www.dyalog.com/user-meetings/uploads/conference/dyalog18/presentations/D15_The_Interpretive_Advantage.zip)) discusses optimizations for the boolean case, where a scalar loop is particularly bad because reading or writing a single bit is so slow. Booleans can be a little easier to work with than larger units, although there are also some unique issues to be addressed because they can only be accessed in aligned groups, while SIMD vectors don't have to be aligned.

### Blocking

The boolean talk shows blocks (that is, subarrays) of 8×8 bits being transposed. SIMD can handle similar-sized or smaller blocks, depending on element size. This requires using multiple registers; I think the best approach is to use quite a few—that is, sticking to one register for booleans was probably not optimal.

Blocking is useful because it combines multiple reads that would be scattered in the ordinary scalar iteration (if writes are in-order). It costs about the same to read one element as one 32-byte register, so the larger read clearly gets a lot more done with the same memory load. But transposing huge numbers of elements in registers gets complicated, so at some point the CPU load will be big enough that increasing the block size is no longer worth it.

### Interleaving

When one axis is smaller than the wanted block length, the ordinary blocking method clearly isn't going to work so well. Handling these cases well calls for a different strategy that I've called interleaving/uninterleaving in the past. Interleaving is used to transpose a few long rows into a long matrix with short rows, while uninterleaving goes the other way. Generally, an approach that works for one can be run backwards to do the other. The differences between interleaving and the general block strategy are that writes (or reads for uninterleaving) are entirely contiguous, and that the two block dimensions aren't the same. One dimension is forced by the matrix shape, and the other should be chosen as large as possible while fitting in a register. Or multiple registers, if you're brave enough. Alignment is a significant annoyance here, unless the smaller axis length is a power of two.

I never explained how to implement the boolean case in a Dyalog publication, but it's mentioned in the boolean talk, and brought up in [Expanding Bits in Shrinking Time](https://www.dyalog.com/blog/2018/06/expanding-bits-in-shrinking-time/) (section "Small expansion factors"). The two methods used in Dyalog are pdep/pext instructions with a precomputed mask if available (this is straightforward), and shifting power-of-two-sized sections if not (harder, similar to various things shown in Hacker's Delight). It's possible that a SIMD implementation of the shifting logic could beat pdep/pext, but I haven't attempted this.

The case with non-booleans and SIMD should be a lot simpler, as it can be done with byte shuffles. The complication is reading from or writing to the side with long rows. I think the right approach is to read or write most of a register at once, and split it up as part of the shuffling. It's probably enough to have one precomputed index vector and add an offset to it as necessary.

### Cache associativity

A problem to be aware of is that when an array is accessed with a stride that's a power of 2 or very close to it, different accesses compete for the same small set of cache lines in a [set-associative](https://en.wikipedia.org/wiki/Cache_associativity#Set-associative_cache) cache. This can slow down something like a 512×512 transpose to the point that it's faster to pad the matrix, transpose, and remove the padding. But I don't have a good general model for when this requires action or what exactly to do about it. I'm not aware of any array language that tries to mitigate it.

## Arbitrary reordering

Moving lots of axes around quickly gets hard to think about. Here's what I've found so far. Most of these methods work in some way for repeated axis indices (that is, taking diagonals) too.

### Axis simplification

Sometimes the transpose isn't as complicated as it appears. The following are useful simplifications to apply:

- Any length-1 axis can be ignored; it doesn't affect ordering.
- Two axes that begin and end next to each other can be treated as one larger axis.
- Axes at the end that don't change can be absorbed into a total "element size".

Particularly after dropping length-1 axes, some transposes might get down to 1 or 0 axes, which means they're no-ops.

### The bottom line

When there's a large enough fixed axis at the bottom, most of the work of transpose is just moving large chunks of data. If these moves are done with memcpy or similar, it doesn't matter what the structure around them is, as the limiting factor is memory bandwidth.

A similar principle applies if, for example, the last *two* axes switch places, but stay at the end, provided their product is large enough. Then the transpose is a bunch of 2D transposes. If each of these is done efficiently, then the outer structure can be anything.

### Decomposition

Before spending a tremendous amount of effort on optimizing strange transpose arrangements it's probably worth looking into transposing multiple times instead. I don't know whether this can beat a single-pass method in any case, but it's certainly simpler a lot of the time. But finding an algorithm which will make good decompositions can be pretty hard still.

Dyalog splits a general boolean transposes into an axis rotation, which swaps two groups of axes and thus works like a matrix transpose, and a second transpose that fixes the last axis. Since length-1 axes have been eliminated, that last transpose works with at least 2 bits at a time, so the worst case is *slightly* better than moving single bits around but still not great.

### Recursion

Unlike a 2D transpose, the basic implementation of an arbitrary reordering is not so obvious. It "should" be a loop with a variable amount of nesting. Of course, you could get rid of this nesting by working with index vectors, but that's very slow. The way Dyalog handles it is with a recursive function that does a layer of looping. Inside the loop it either calls itself or a base case, which is passed by a function pointer for flexibility. There are actually two loops, one that does one axis and one that does two at once. The single-axis version is only called at the top level in case there's an axis left over, so most of the work is done in this double-loop case.

Of course larger loops are possible as well. But most of the time it's really the base case that's important. The base case also handles two axes most of the time, but can incorporate all the 2D optimizations like blocking.

### Indices

One thing I noticed when working with BQN is that CBQN's dyadic `⍉` sometimes beat Dyalog's, despite using the BQN runtime instead of a native implementation. The runtime just constructs all the (ravel) indices for the output with a big addition table `+⌜´`, then selects. I think this is actually a good strategy for handling trailing axes if there are a lot of small ones. Construct the index table for the bottom few axes of the result—which don't have to correspond to the bottom axes of the argument, even though for cache reasons it'd be nice if they did. Then the base case for tranpose is simply selecting using these axes.
