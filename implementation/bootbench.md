*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/bootbench.html).*

# Bootstrapping compiler benchmarks

BQN's [bootstrapping](../src/bootstrap) system offered an ideal test to compare BQN and C performance on a task that's not quite array-hostile, but also not that array friendly. The task is to compile the small subset of BQN syntax used in [boot2.bqn](../src/bootstrap/boot2.bqn). In short, BQN won! [boot3.bqn](../src/bootstrap/boot3.bqn) in CBQN compiles this file 35% more quickly than [comp.c](https://github.com/dzaima/CBQN/blob/master/src/opt/comp.c) in clang. BQN has a large fixed cost so that it's slower on inputs smaller than 1KB (boot2.bqn is 8.8KB), and I believe having a larger subset to compile would be less favorable to BQN, but with simpler and more regular target files benefitting C more than complex ones.

## Compiler details

I created BQN's bootstrapping compiler chain in early 2023 to solve a classic self-hosting problem: in order to run, CBQN depends on bytecode for the compiler and runtime, but building them requires a fairly featureful BQN implementation. From scratch, only dzaima/BQN could do it and that drags in a Java dependency. The BQN bootstrapping compilers boot1 and boot2 were created by iteratively paring down the full compiler, reducing features supported and features used at each step. boot2 uses only a few bits of syntax like functions, 2-modifiers, trains, and bracketed lists, so it's not too hard to support. And in fact dzaima had a C [compiler](https://github.com/dzaima/CBQN/blob/master/src/opt/comp.c) that did the job approximately 20 hours after I first mentioned the bootstrapping chain. He made various changes afterward to improve performance as we compared to other compilers. The compiler uses some BQN infrastructure, including its allocator and hash map.

I also made a BQN compiler able to build boot2. Despite the name, [boot3.bqn](../src/bootstrap/boot3.bqn) is not part of the bootstrapping chain, as it has no syntax restrictions and thus is harder to compile than boot2. Because the path to get there is so circuitous, it's hard to say how long it would take to make from scratch. The expression-reversing line alone [took](https://chat.stackexchange.com/transcript/52405?m=54907766#54907766) nearly 10 hours for a working (three-line) version, although it's quite an outlier. More importantly, it's done. Before I'd written an array compiler, I think an effort of this size would have taken weeks. Now, having experience and being able to refer to compilers I've written, two or three days seems realistic.

The compilers have equivalent (I wrote a script to confirm this) but not identical output. The differences:
- C interleaves objects—literals and primitives—so the entire object list corresponds to source order; BQN splits into primitives then numbers then strings. I think either compiler would get a little slower if forced to use the other's ordering.
- C doesn't deduplicate objects. There aren't many literals in boot2 so only the primitives could matter much. BQN gets primitive deduplication for free as part of character lookups, and it's possible having to output primitives individually slows C down, but deduplicating explicitly would be slower.
- BQN outputs function/train opcodes without Nothing checks and C uses the ones with them. It's not completely free to change BQN to match C, as `TR2O` not existing breaks the arithmetic, but definitely insignificant.
- C doesn't output the per-function variable names and export mask (they're just `↕n` and `n⥊0`). Cutting them from BQN shows no significant difference.

The choice of syntax available in boot2 was influenced by both BQN and C concerns, with 2-modifiers and a quote escape removed to make C compilation easier.

## Measurement

Timings are in microseconds (μs), a millionth of a second.

The C compiler can be built as part of BQN by passing `f='-DNATIVE_COMPILER'`, in which case it's exposed as `•internal.Temp` (obviously this might change). To give the closest possible comparison I removed system value support, bringing the time from 432.9μs to 430.0μs, and then error handling for the final time of 415.5μs. Only a 4% difference—conditions that are never triggered cost very little.

The task is to compile boot2 after it's loaded into BQN, as a string of 32-bit characters since it contains `𝕊𝕩𝕨`. The Java compiler is from dzaima/BQN and only loosely comparable with BQN's. It's not exposed as a function, so I timed `•BQN` on the string wrapped in `{}`, which should be very close. Since JIT warmup matters in Java, the time given is for the third set of 10,000 compilations (I ran four sets and got timings of 634, 588, 567, and 568μs).

Times below are the average of 10,000 runs on my dinky [Skylake i5-6200U](https://www.intel.com/content/www/us/en/products/sku/88193/intel-core-i56200u-processor-3m-cache-up-to-2-80-ghz/specifications.html). Versions are clang 15.0, OpenJDK 19.0, CBQN commit 92763fa compiled native+Singeli.

| C mini  | BQN mini | BQN full | Java full
|---------|----------|----------|----------
| 415.5μs | 270.6μs  | 737.8μs  | 567μs

        270.6‿737.8 ÷ 415.5

The comparable BQN compiler is 35% faster than C, and the full compiler is only 75% slower!

I tested the mini-compilers on smaller sources by snipping parts from boot2. Both compilers take 50μs on a 1KB source, with the C compiler faster on smaller sources and the BQN compiler faster on larger ones.

## Extrapolations

The BQN mini-compiler being faster than C came as a bit of a surprise given the significant gap between the full BQN and Java compilers. While there are differences in the full compilers, I think they're too small to explain the gap, so there are two possibilities:

- The full Java compiler is faster than a C compiler would be, and/or
- Increasing the supported subset (that is, requiring more features) has a smaller effect on C than on BQN.

I think it's a bit of both, and that a full C compiler would fall between the Java timing of 567μs and the 1133μs I calculated by scaling proportionately to BQN. Probably more like 700-800μs? That's a wild guess.

Java faster than C, can that happen? If you give HotSpot a few seconds to examine and optimize the program, sure. Note that Java gets not only runtime information from compiling but from compiling on this specific source: it sees that there aren't any namespaces or 2-modifiers or strands and can try to make the checks for these as fast as possible. Java compiled ahead of time with GraalVM [Native Image](https://www.graalvm.org/native-image/) is a good bit slower than the OpenJDK run. General compilation is also fairly allocation-heavy and Java's allocator and GC are very advanced. The C compiler uses BQN's allocator, which is a lot faster than malloc, and boot2 doesn't need that many allocations, but it still spends at least 20% of time in memory management, freeing memory particularly. Generational GC makes freeing very cheap most of the time.

On the other side, why would an array compiler scale worse than a scalar one? By default, an array compiler pays for syntax even in regions where it isn't used. This can sometimes be mitigated by working on an extracted portion of the source, such as pulling out the contents of headers for header processing. The extraction is still there, so this reduces but doesn't eliminate the cost on non-header parts of the code. And the constant cost for small files is still there. In contrast, a scalar compiler that uses switch statements to decide what to do at a given point won't pay that much for added syntax. The cost of a switch statement is sub-linear in the number of cases: logarithmic for a decision tree and constant for a jump table.

Array-based compiling does have its advantages still. Once all that syntax is supported the cost depends very little on the contents of the input file. This is particularly true for blocks, which need to have some metadata output for each one. A scalar compiler creates this metadata one block at a time, which leads to a lot of branching, while the BQN compiler creates it all at once then splits into blocks with Group (`⊔`), a faster method overall. An informal test with [singeli.bqn](https://github.com/mlochbaum/Singeli/blob/master/singeli.bqn), which has many blocks, showed Java's advantage at about 15%, lower than the 30% seen above.
