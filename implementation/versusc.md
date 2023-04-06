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

Small real-world problems can still show a major difference. In my first talk at Dyalog ([video](https://dyalog.tv/Dyalog17/?v=2KnrDmZov4U), [zipped slides](https://www.dyalog.com/uploads/conference/dyalog17/presentations/D08_Moving_Bits_Faster_in_Dyalog_16.zip)), as well as a follow-up next year ([video](https://dyalog.tv/Dyalog18/?v=-6no6N3i9Tg), [zipped slides](https://www.dyalog.com/user-meetings/uploads/conference/dyalog18/presentations/D15_The_Interpretive_Advantage.zip)), I considered the problem of replacing every CRLF line ending in a file with just the second character LF. BQN nails this one, breaking even with C at a little under 200 bytes and hitting 4x C's speed on inputs of a few thousand bytes or more in my testing.

Larger problems are more mixed. Our best real-world comparison on a comparable problem is the [compiler benchmark](bootbench.md), which showed a 35% advantage for the BQN implementation. [Here](codfns.md#is-it-a-good-idea) I described compiling as being intermediate in terms of how good it is for array programming. Naturally array-oriented tasks like data crunching can be better, although C can auto-vectorize simpler ones. And as array programming is a limited programming, there's no guarantee a problem will fit. If you have to use sequential code for a significant part of the program, BQN will end up a lot slower.

Another test case is JSON parsing. While I haven't comprehensively benchmarked [json.bqn](https://github.com/mlochbaum/bqn-libs/blob/master/primes.bqn), it runs at 20 to 50 MB/s for typical structures, which is competitive with some C parsers but well short of more optimized efforts like RapidJSON or simdjson.

I spent some time optimizing the prime sieve in [primes.bqn](https://github.com/mlochbaum/bqn-libs/blob/master/primes.bqn) for bqn-libs, and ended up with a `PrimesTo` function that computes the primes under a billion in 2.2 seconds. This is in the ballpark of typical C wheel sieves. It's actually faster than J's `p:`, which is implemented in C and takes 7.1 seconds, but is beaten by [ngn/k's](https://codeberg.org/ngn/k/src/branch/master/4.c) at 1.2 seconds. The serious sieves like one [by Kim Walisch](https://github.com/kimwalisch/primesieve/) with tons of cache-aware code run much faster than any of these.
