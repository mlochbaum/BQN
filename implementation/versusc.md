*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/versusc.html).*

# Performance in BQN versus C

The title alone! You know BQN has some fast [performance](perf.md) to wave around!

If you think it's paradoxical that programs written for CBQN, a C-based interpreter, might outperform programs written directly in C, it's because you think performance comes from the language implementation. Not so: performance comes from the programmer, taking advantage of the features offered by their language implementation. The difficulty of doing so has two consequences:

- BQN programs can and do outperform equivalent C programs.
- Your BQN programs are unlikely to outperform equivalent C programs.

Because once you have a working program, you are probably going to come to the realization that you'd rather do something else with your time than study and optimize until it can beat the C program that you never even wrote in the first place. You wouldn't have made the C program as fast as possible either: that only makes sense for programs that are used over and over in a performance-sensitive context and simple enough to optimize well. Like… the CBQN interpreter.

Here's a highly authoritative graph on how the effort to speed tradeoff could work, in one case, maybe.

<!--GEN
dim ← 256‿128
pad ← 40‿40
pad1← 80‿10+pad

Ge ← "g"⊸At⊸Enc
pa ← "class=Paren|stroke-width=1.2|stroke=currentColor|fill=none"
gr ← "stroke-width=1.8|font-size=13px|text-anchor=middle|fill=currentColor"
Path ← "path" Elt "d"⊸⋈⊘(⊣∾"d"⋈⊢)
Text ← "text"⊸Attr⊸Enc
Rect ← {"rect" Elt 𝕨⊢⊘∾"x"‿"y"‿"width"‿"height"≍˘FmtNum𝕩}

Cub ← ∾"MCC"(∾»⟜(' '¨)∾¨⊢)¨·FmtNum¨∾⟜(¯2⊸↑)⌾(¯1⊸⊑)
col ← "class"⊸⋈¨"bluegreen"‿"green"
((-pad1÷2)∾dim+pad1) SVG gr Ge ∾⥊¨ ⟨
  <(At "class=code|stroke-width=1|rx=6") Rect (-pad÷2)∾dim+pad
  "class=purple|stroke-width=1|opacity=0.4" Ge ⟨
    Rect ⥊¯10‿20+dim⊸×˘¬⊸≍0.1‿1
    "Non-portable" Text˜ (At"transform=rotate(-90)|dy=0.2em")∾Pos ⌽dim×1‿¯0.5
  ⟩
  (col∾⟜(Pos dim⊸×)¨⟨93‿6,73‿20⟩÷100) Text¨ "C"‿"BQN"
  "opacity=0.8" Ge Text˜´¨ ⟨
    ⟨"Effort", "dy"‿"1em"∾Pos dim×0.5‿1⟩
    ⟨"Speed", "transform"‿"rotate(-90)"∾"dy"‿"-0.35em"∾Pos ⌽dim×0‿¯0.5⟩
  ⟩
  <pa At⊸Path ∾("M VH")∾¨FmtNum 0‿0∾⌽dim
  col ≍⟜"style"‿"fill:none"⊸Path⟜Cub¨ (dim×·≍⟜¬˝÷⟜100)⌾(⍉∘‿2⥊∾∘∾) ⟨
    ⟨40‿30, 45‿80‿83‿55‿93‿85, 97‿97‿100‿100⟩
    ⟨ 0‿ 0, 20‿35‿50‿30‿60‿60, 65‿75‿ 80‿ 75⟩
  ⟩
⟩
-->

I'm considering something basically straightforward (no big algorithmic improvements) and that can be implemented with whole arrays, but not trivially. BQN lets you quickly write a working program, but the easy way usually involves lots of small arrays and slow iteration. C on the other hand is notorious for being hard to write, but once you do it you'll get good performance if you didn't cut corners. Going beyond to get the most out of a CPU takes a lot more work, and often manual use of SIMD or other intrinsics, which isn't portable. CBQN gives you access to some of those methods without as much effort, which is how it can end up beating a basic C program. But evaluating one primitive at a time has overhead, so it's never as good as specialized C.

A major factor that separates low- and high-performance programs in both C and BQN is not actually time spent but experience with the required programming techniques. In portable C this means branchless tricks, bit manipulation, and writing things an auto-vectorizer can handle. In BQN it's a totally different set of skills needed to write in an array-oriented style. Surprisingly, non-portable C often benefits from those array-oriented skills as well: I often find better ways to implement BQN primitives by thinking in terms of other primitives!

## Case studies

All right, how can I so confidently claim that CBQN can—sometimes—be faster than C in practice? First off, there's a certain class of problems where it's routine: BQN primitives. Every one that does anything, really. Scan, Transpose, Indices, Sort, Modulus, Reshape. And so on. We write the ordinary C implementation, and it's just not good enough, so we have to use lookup tables, SIMD, blocked multi-pass techniques, and more. A 10x improvement over ordinary C code is completely normal. But this is the best possible case for BQN; combinations of primitives never do so well.

Small real-world problems can still show a major difference. In my first talk at Dyalog ([video](https://dyalog.tv/Dyalog17/?v=2KnrDmZov4U), [zipped slides](https://www.dyalog.com/uploads/conference/dyalog17/presentations/D08_Moving_Bits_Faster_in_Dyalog_16.zip)), as well as a follow-up next year ([video](https://dyalog.tv/Dyalog18/?v=-6no6N3i9Tg), [zipped slides](https://www.dyalog.com/uploads/conference/dyalog18/presentations/D15_The_Interpretive_Advantage.zip)), I considered the problem of replacing every CRLF line ending in a file with just the second character LF. BQN nails this one, breaking even with C at a little under 200 bytes and hitting 5x C's speed on inputs of a few thousand bytes or more in my testing. That's with AVX-512 disabled; with it BQN is over 10x faster until cache becomes a bottleneck.

<details><summary>(Benchmark details)</summary>

The benchmark is run with a CRLF every 100 characters on average, placed with a simple LCG for reproducibility. This is just the number I picked in the Dyalog presentation and isn't particularly favorable to BQN, as it only gets an advantage from sparse Replicate at lower densities like 1/1000 and branching C code would be penalized at higher ones like 1/4. C code is also taken from the Dyalog talk. gcc 12.2.1 generates short branching code with the `if`-based function, while clang 15.0.7 converts both functions to branchless and unrolls by a factor of 4. The two are very close in speed with density 1/100, and gcc is slightly faster at lower densities and much slower at high ones.

lineending.bqn:

    cr‿lf ← @+13‿10
    CRLF_to_LF ← (cr⊸≠ ∨ ·«lf⊸≠)⊸/

    n ← 1e6 ⋄ m ← n÷100
    r ← 29 ⋄ LCG ← {(1-˜2⋆31)|16807×𝕩}
    str ← {i←(n-1)|r ⋄ r LCG↩ ⋄ cr⌾(i⊸⊑)lf⌾((i+1)⊸⊑)𝕩}⍟m @+100|↕n

    ls ← ≤⟜n⊸/ ⥊(10⋆2+↕5)×⌜1‿3
    Disp ← { •Out "ns/elt" ∾˜ ∾ ∾⟜" "¨ ¯7‿8 ↑⟜•Repr¨ 𝕩 }
    {𝕊l: Disp l ⋈ 1e9×l÷˜ (⌊5e8÷l) CRLF_to_LF•_timed l↑str}¨ ls

lineending.c:

    #include "stdlib.h"
    #include "stdio.h"
    #include "time.h"

    #if 0
    // Branchless
    __attribute((noinline)) void crlf_to_lf(char* dst, char* src, size_t n) {
      int was_cr = 0;
      for (size_t i=0; i<n; i++) {
        char c = src[i];
        dst -= (was_cr && c=='\n');
        dst[i] = c;
        was_cr = (c=='\r');
      }
    }
    #else
    __attribute((noinline)) void crlf_to_lf(char* dst, char* src, size_t n) {
      int was_cr = 0;
      for (size_t i=0; i<n; i++) {
        char c = src[i];
        if (was_cr && c=='\n') dst--;
        dst[i] = c;
        was_cr = (c=='\r');
      }
    }
    #endif

    static size_t monoclock(void) {
      struct timespec ts;
      clock_gettime(CLOCK_MONOTONIC, &ts);
      return 1000000000*ts.tv_sec + ts.tv_nsec;
    }

    int main(int argc, char **argv) {
      int n = 1000000, m = n/100;
      char *str = malloc(n*sizeof(char)),
           *dst = malloc(n*sizeof(char));
      for (size_t i=0; i<n; i++) str[i] = (char)(i%100);
      for (size_t i=0, r=29; i<m; i++) {
        size_t j = r%(n-1); str[j] = '\r'; str[j+1] = '\n';
        r = (16807*r) % ((1ull<<31)-1);
      }
      for (size_t l=100, l0=l; l<=n; l=l==l0?3*l:(l0*=10)) {
        size_t k = 500000000/l;
        size_t t = monoclock();
        for (size_t i=0; i<k; i++) crlf_to_lf(dst, str, l);
        t = monoclock()-t;
        printf("%7ld %f ns/elt\n", l, (double)t / (l*k));
      }
    }

And the benchmark run, on [Tiger Lake i5-1135G7](https://www.intel.com/content/www/us/en/products/sku/208658/intel-core-i51135g7-processor-8m-cache-up-to-4-20-ghz/specifications.html):

    $ clang --version
    clang version 15.0.7
    Target: x86_64-unknown-linux-gnu
    Thread model: posix
    InstalledDir: /usr/bin

    $ clang -O3 -march=native lineending.c && ./a.out
        100 0.613074 ns/elt
        300 0.574972 ns/elt
       1000 0.560992 ns/elt
       3000 0.556508 ns/elt
      10000 0.555551 ns/elt
      30000 0.554987 ns/elt
     100000 0.554504 ns/elt
     300000 0.554786 ns/elt
    1000000 0.555487 ns/elt

    $ bqn --version
    CBQN on commit 0d2631a2278fab44164f4619a1a8c295fe674fa0
    built with FFI, singeli x86-64 avx2 bmi2 pclmul, replxx

    $ bqn lineending.bqn 
        100 0.893145 ns/elt
        300 0.396408 ns/elt
       1000 0.187448 ns/elt
       3000 0.127288 ns/elt
      10000 0.106085 ns/elt
      30000 0.094272 ns/elt
     100000 0.096406 ns/elt
     300000 0.095310 ns/elt
    1000000 0.107455 ns/elt

    $ bqn --version
    CBQN on commit 0d2631a2278fab44164f4619a1a8c295fe674fa0
    built with FFI, singeli native x86-64, replxx

    $ bqn lineending.bqn 
        100 0.838992 ns/elt
        300 0.319644 ns/elt
       1000 0.129420 ns/elt
       3000 0.072258 ns/elt
      10000 0.052556 ns/elt
      30000 0.050635 ns/elt
     100000 0.053703 ns/elt
     300000 0.052985 ns/elt
    1000000 0.078744 ns/elt

</details>

Larger problems are more mixed. Our best real-world comparison on a comparable problem is the [compiler benchmark](bootbench.md), which showed a 35% advantage for the BQN implementation. [Here](codfns.md#is-it-a-good-idea) I described compiling as being intermediate in terms of how good it is for array programming. Naturally array-oriented tasks like data crunching can be better, although C can auto-vectorize simpler ones. And as flat array programming is a limited paradigm, there's no guarantee a problem will fit. If you have to use sequential code for a significant part of the program, BQN will end up a lot slower.

Another test case is JSON parsing. While I haven't comprehensively benchmarked [json.bqn](https://github.com/mlochbaum/bqn-libs/blob/master/json.bqn), it runs at 40 to 100 MB/s for typical structures, which is competitive with some C parsers but well short of more optimized efforts like RapidJSON or simdjson.

I spent some time optimizing the prime sieve in [primes.bqn](https://github.com/mlochbaum/bqn-libs/blob/master/primes.bqn) for bqn-libs, and ended up with a `PrimesTo` function that computes the primes under a billion in 1.1 seconds. This is in the ballpark of typical C wheel sieves. It's actually faster than J's `p:`, which is implemented in C and takes 3.1 seconds, but is beaten by [ngn/k's](https://codeberg.org/ngn/k/src/branch/master/4.c) at 0.7 seconds. The serious sieves like one [by Kim Walisch](https://github.com/kimwalisch/primesieve/) with piles of cache-aware code run much faster than any of these.

## When to use BQN?

Those examples were somewhat favorable to BQN. This page is kinda pro-BQN, yeah? Because if you haven't heard the pro-C arguments a million times already, wow.

Still, it's possible to give more guidance than "BQN good" or "BQN bad": BQN is relatively better at certain problems and programming models. If you don't care about performance, that's out of scope for this page; maybe you like BQN and maybe you don't. If performance is so important that development time is no object, you will have to go to C eventually, if not CUDA or other specialized tools. However, I find BQN quite useful for testing out high-performance strategies to work out the details or see how they will perform. Since array primitives are so closely related to SIMD instructions, a BQN solution will often match the overall shape of high-performance code better than an initial C one!

The tough decisions are in the intermediate case where there's a high threshold for acceptable performance but only so much developer time to achieve it. I think this mainly happens for large programs. Here I should stress that object-oriented C++ is not the same as C: if your code spends most of its time dispatching methods on small objects then it's in a different and slower performance category that I don't know much about. But a program that deals with plain data like strings and arrays of numbers is a candidate for writing in BQN. Relative to C, BQN will do best if the data structures are homogeneous arrays that are large (at least hundreds and preferably thousands of elements), and have a small element type (particularly 1 or 2 bytes) so more elements can be packed in a SIMD vector. BQN aims to be fast even on multidimensional arrays with a short last axis, where the default in C is to use a slow nested loop, but it's better to keep the last axis long if possible.

Some programs are just not suitable for array programming, making C or similar the best tool for the job. One tell-tale feature for these is a lot of loops where the number of iterations isn't known in advance (assuming a single iteration is too short to get useful array work done). SIMD speedups are all about processing multiple steps at a time, so they can't be done without knowing there are multiple steps left! And some domains need types that CBQN doesn't support for good performance. Crypography uses a lot of wrapping operations on integers of various widths, which can sort of be approached with `•bit`, but besides being ugly this generally runs into some missing operation eventually. Some financial applications, particularly those that convert currencies, must round in decimal, making binary floats unsuitable.

On the other end, some programs naturally work in terms of long arrays, and these might end up with C-ish performance without any particular effort to write fast BQN. Between these two extremes anything could happen, as there's no limit on the work that may be needed to distinguish the hard and the impossible. If you're enjoying array programming I think it's a good idea to learn about ways of working with partitioned lists and trees as flattened arrays to extend your reach. However, after using these techniques extensively to make the BQN compiler, [I wrote](codfns.md#is-it-a-good-idea) that performance alone isn't a good reason to tackle such a hard problem with array programming.

## BQN's advantages

BQN has definite disadvantages relative to C, because it doesn't have static type information and doesn't do a significant amount of optimization when it compiles—every primitive is a function call, except the operands to some modifiers like `+´`. To make up for this, there are a number of advantages that are perhaps less obvious. Broadly speaking, a C program contains more optimization information than a BQN one, but this information (even if it's well chosen!) can tie the compiler down and prevent optimization as much as it can enable it.

Now, I can't really say it's impossible for some future C compiler to sift out what information is important and what isn't, and build a program that's perfectly suited to what you want to do. It would be fighting its own source language to get there, and may have to do crazy things like guess constraints on program input that you expect but haven't checked for. And if you're hoping for radical implementation improvements, you might bet on the language that's a few years old, not the one that's been around for 50?

### High-level versus low-level

Array programming is a high-level framework for describing algorithms, in that the programmer is saying more "what" than "how". C does this too, because when you write `a+b` you don't specify the instruction to use, and indeed `a*4` is almost certainly going to use a shift instruction instead of multiplication. But in terms of how many "how"s you can leave out, BQN leaves out a lot more. The downside of the implementation filling in the "how" for you is that it might do worse, and the upside is that it might do better.

Unlike BQN, C doesn't just fill in the details of what you told it to do. Auto-vectorization is an attempt to build some high-level understanding and use it to change over to a different low-level implementation. This is much harder than just implementing primitives and I think that's the main reason you won't see a C compiler do something like transposing a matrix with a SIMD kernel. C also has limitations on how it can rearrange memory accesses. A common one is that it can't read extra memory because this might segfault, so if you write a scalar search to find the first 0 in an array it's actually not legal to rewrite this to a vector search that might read past that 0.

On the topic of memory, it's a very simple structure—the whole world, just a sequence of bytes!—but it's also mutinous I mean mutable. If you call an unknown function in C, it could write anywhere, so the compiler no longer knows the value of any part of memory. If you write to an unknown pointer, and pointers are hard to know mind you, it could change any part of memory too. This leads to a whole category of optimization problems known as [pointer aliasing](https://en.wikipedia.org/wiki/Pointer_aliasing#Conflicts_with_optimization), where something as simple as adding one to a bunch of values with a source and destination pointer can't be vectorized unless the pointers are known to not overlap.

#### Fusion versus fission

I view getting the balance between [loop fusion and fission](https://en.wikipedia.org/wiki/Loop_fission_and_fusion) right as a sort of holy grail of array programming. I so wish I could say "we've already got one!". Nope, as it stands, C chooses fusion and BQN chooses fission. That is, a C programmer usually writes one loop with lots of stuff in it, but each BQN primitive is like a loop, making a BQN program a series of loops. But the best approaches usually have more complicated shapes. Some loops can be fused at the level of a vector instruction, and this is where C auto-vectorization works great and BQN is worst with lots of extra loads and stores. Loops involving filtering or other data movement might not be tightly fusable; auto-vectorization gives up and CBQN looks great in comparison. But it's still missing out on any instruction-level fusion that *can* be done (`a/b+c×d` won't fuse `b+c×d`), and if the arrays are large it's missing out on looser-grained fusion that would make better use of caches. I've written more about the problem and approaches to it that BQN might take on [another page](compile/fusion.md).

### Dynamic versus static

A C compiler decides what it's going to do at compile time, before it's even caught a whiff of the data that'll be processed (all right, profile-guided optimization is a decent sniff in that direction, but no touching). CBQN decides what to do again every time a primitive is called. This has some overhead, but it also means these calls can adapt to conditions as they change.

An example is selection, `⊏`. If you select from any old array of 1-byte values, it'll pick one element at a time (okay, call a gather instruction that then loads one at a time) which I measure at 0.2ns per selection. If you select from a *small* array, say 32 values or less, CBQN will load them into vector registers and do the selection with shuffle instructions, 0.04ns per selection. That includes a range check, that C is supposedly speeding your code up by ignoring! By having the high-level information of a known right argument range, and checking it dynamically, BQN goes much faster in certain cases.

As a SIMD programmer in C you might write code that uses vector shuffles as well, but probably only for an array whose length is known statically. BQN's dynamic checking allows it to take advantage of this case exactly when it comes up. And sure, you could do this sort of check in C, but at that point, you're kind of writing a BQN VM.

We do a lot of dynamic checking in CBQN. Checking array rank and shape is pretty cheap, and we also track [element type](primitive/types.md) and [sortedness](primitive/flagsort.md) of arrays. A boolean array is packed 8 bits to the byte, which is way faster for most things but not often done in C.

There's also data-based checking, or [adaptive algorithms](https://en.wikipedia.org/wiki/Adaptive_algorithm)—adaptive sorting being the best-known case. There are simpler examples too. [Replicate](primitive/replicate.md) (`/`) compares the input and output lengths to use either a sparse or dense algorithm, and can also check a boolean argument to see how many times it switches between 0 and 1, so that if it's clumpy it can copy values in chunks. Group (`⊔`) checks for clumpiness as well, copying in sections if `𝕨` changes value infrequently. Sticking to just a single implementation can lead to very poor cases that are dominated by branch misprediction penalties—which is exactly what happens in C when you write a string partitioning function that branches at the boundaries and then get a string where the sections are short.

### Primitives versus C libraries

BQN can call C code through its [FFI](../doc/ffi.md), but it has a little call overhead and often requires copying data so it's not the fastest interface. C can also call into CBQN as a library, with similar issues. But isn't it possible to make C library functions for BQN primitives—in fact, don't many such library functions like sorting and binary searching already exist?

In principle this is a fine strategy; it's something we do a fair amount internally within BQN. Practically speaking, well first I have to admit that I know very little about these libraries. It seems clear enough that stdlib implementations are a joke as far as performance goes, so we are talking about C++ stuff like Abseil, Folly, or Boost. I'm still kind of skeptical, but what little knowledge I have about these is from looking at documentation and not finding functions that seemed useful (for implementing APL) and looking at source code and benchmarks and not seeing anything that seemed impressive. If anyone would, say, use these to implement some BQN primitives faster than CBQN's Singeli versions I'd change my mind real fast.

The advantage of a library is mainly moving from low level to high level. C libraries work within the static type system so they're still mainly static rather than dynamic, but can be dynamic in other ways like adaptive sorting. Beyond this I do have some examples few ways that the expectations for a C/C++ library tend to harm performance.
- Libraries shy away from too much memory use; for some things like `k/l` for a small constant `k` CBQN uses precomputed tables of shuffle indices. Since we know exactly how big the BQN language is, it's easier to decide on how much memory use is reasonable, where a library might be mixed with any amount of other code, preventing this.
- There's a lot of pressure for [sorting](primitive/sort.md) to match the standard library interface which means taking a comparison function. Numeric sorting can sometimes be recognized as a special case, but sort function authors seem to feel that the same algorithm should be used for all types, ruling out much faster distribution sorts for 1- and 2-byte integers.
- [Lookups](primitive/search.md) are performed with persistent hash tables. These have type problems too (a lookup table on 1 byte is a lot faster than a hash table), and additionally inserting and searching one at a time means the table is running blind, without information about what future operations are needed. Often, all the values are known at a one point in the program, making a combined call like BQN's `⊐` a better interface. It can lower resizing overhead using the known argument lengths, store equal-size hashes instead of values since it knows it won't have to iterate over keys, and sometimes use a reverse lookup that stops early in the searched values instead of inserting them all.

These problems are noticeably easier to address than BQN's issues with fusing primitives (although the library functions run into those same fusion problems too). I hope I'll see it happen!

### Why can't I do these in C?

There are a few things the C compilers of today (2023) don't seem able to generate from portable code. If you know how to do them, please tell me!

- SIMD scans—prefix sums and so on. `for (i=1; i<n; i++) x[i] += x[i-1]` should vectorize for integers. Or some other variant; I've tried many. The way to do this is well known and I don't think the code size and latency tradeoffs are any worse than for typical auto-vectorizations. This is so baffling to me.

- Multiple comparisons with the result in a bitmask. x86 has the very useful `movmsk` family of instructions to move a bit from each element of a vector register into a general-purpose register. As far as I know, portable C can't get at the full result of this—clang can use it to test if any comparison is true, but nothing else. Since C doesn't really treat packed-bit formats as native, recognizing the conditions where `movmsk` could be used is pretty tough. Still, it closes off optimization opportunities in many places.

- Conditional-move instructions. Various things like binary search and branchless merges turn into a guessing game because compilers have all sorts of [weird](https://kristerw.github.io/2022/05/24/branchless/) and sometimes [buggy](https://github.com/llvm/llvm-project/issues/39374) (can it really be… it's finally fixed!) heuristics for determining whether `if (cond) a=b` should use a consistently fast branchless instruction or a branch that could be slightly faster or many times slower. Really fixing this would require compiler extension though. I would definitely support an intrinsic that you can apply to a condition that says "don't you dare branch on this" (with an error if it's not possible). A `__branchless_choice(cond, a, b)` intrinsic also makes a lot of sense to me.
