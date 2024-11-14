*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/perf.html).*

# How does BQN perform?

How fast is the performance-oriented BQN implementation, [CBQN](https://github.com/dzaima/CBQN)? I must ask, why do you care? People are out there looking for the fastest array language before they've tried any one to see if it works for them. Fact is, most programs have a point where they are just fast enough, and CPUs have gotten pretty good at reaching that point. If not, there's often a single cause, a concentrated slow part that's easily handed off to a specialized tool like LAPACK. No matter what, a laser focus on performance from the beginning will cause you to miss the fast solutions you'd find if you really understood the problem. So, start with clean code in the most expressive language to work out strategy, and move to tactics once you know when and how the performance falls short. Without this understanding, benchmarks are just a dick measuring contest. It's not even your own dick. It's public, you're just using it.

Anyway, BQN's dick is pretty fast. Compiles its own compiler in a millisecond. Builds this whole site—a megabyte or so of markdown—in well under a second. Lists the primes under a billion in one second. That sort of thing. For CBQN right now, performance splits into three major cases:
- Scalar code, mostly using atoms. CBQN is faster than other array languages and on par with lightweight interpreters (not JIT compilers).
- Flat lists. CBQN is often much better than other array languages and hardly ever worse, and can beat idiomatic C.
- Multidimensional arrays. CBQN's optimization is spotty, so that it may fall back to operating on rows individually. This is of course fine if the rows are long (hundreds of bytes), and I'm not sure there _are_ any languages that consistently handle a short last axis well? Futhark maybe.

Currently we aim for high performance on a single CPU core, and are focusing on 64-bit x86 and ARM. These both have vector extensions that are always present (SSE2 and NEON respectively); these are used by default, and for x86 other extensions like AVX2 and BMI2 are used if the architecture specified at compile time includes them. CBQN doesn't use additional cores or a GPU for acceleration.

## Performance resources

It's more accurate to say CBQN can be fast, not that it will be fast: it's all about how you use it. Definitely ask on the forum if you're struggling with performance so you can improve your technique.

There are two measurement tools in the [time](../spec/system.md#time) system values. `•MonoTime` is a high-precision timer for performance measurements; you can take a time before and after some operation or section of a program and subtract them to get a time in seconds (a profiling tool to do this automatically would be nice, but we don't have one). More convenient for small snippets, `•_timed` returns the time to evaluate `𝔽𝕩`, averaging over `𝕨` runs if given. For two-argument functions you can write `w⊸F•_timed x` or `F´•_timed w‿x`.

    100 +´•_timed ↕1e6  # Time +´ only
    )time:100 +´↕1e6    # Time entire expression

CBQN also has a `)time` command that prints the time taken by an entire expression, not counting compilation time. And a `)profile` command that samples where time was spent by the line—execution naturally has to be spread over several lines for this to be useful, and should take at least a few milliseconds too.

The [bencharray](https://mlochbaum.github.io/bencharray/pages/summary.html) tool has a page showing primitive benchmarks with some explanations.

If BQN isn't meeting your needs, there's always the option to hook up with C by [FFI](../doc/ffi.md). FFI calls have low overhead (tens of nanoseconds), but may require copying as data goes in or out.

## Versus other array languages

Things get hard when you try to put array languages up next to each other. You can get completely different results depending on what sort of problems you want to solve and how you write code, and all those different results are valid. Because people ask for it, I'll try to give some description for the implementations I'm familiar with. I'm of course biased towards the languages I've worked on, Dyalog and BQN; if nothing else, these tend to prioritize just the features I find important! Note also that the situation can change over time; these comments are from 2024.

The implementations I use for comparison are Dyalog APL, ngn/k, and J. I don't benchmark against proprietary K implementations because the anti-benchmarking clauses in their licenses would prevent me from sharing the results (discussed [here](kclaims.md)).

Array operations are the way to get the most value out of an array language ([background reading](https://aplwiki.com/wiki/Performance)), so these languages tend to focus on them. But BQN tries to be usable in less array-oriented situations as well, and is faster for scalar code in the simple cases I've measured—things like naive Fibonacci or folding with a function that does some arithmetic. Dyalog is uniformly slow on such things, 5–10x worse than BQN. J is a bit better with tacit code and worse with explicit, 3–15x worse than BQN. And I measure ngn/k around 2x worse than BQN. For context, BQN is just slower than LuaJIT with the JIT off (which is still a fast interpreter), and I usually expect it to be about 10x slower than C in cases where C operations are compiling to single instructions (e.g. excluding auto-vectorization).

I publish BQN benchmarks of array operations in [bencharray](https://mlochbaum.github.io/bencharray/pages/summary.html), and also use it to compare against J and Dyalog. BQN has a pretty big lead on these, beating the other languages in all but a few cases and often by margins of two or more. Now, I do tend to benchmark things that dzaima or I are actively working on speeding up, but at this point I've gotten to all the list operations that are important for performance. However, it's worth noting that these benchmarks cover straightforward cases where both arguments are numeric of the same width. Other cases may not need new core algorithms but do have to be handled explicitly, so BQN might miss them. Dyalog and J aren't immune to these sorts of problems but generally the older language has the edge in edge coverage.

We're working through the multi-dimensional operations, which is a domain no array language really nails yet (but at least they're not as abysmal at them as C). What we've finished can be many times faster than Dyalog, but Dyalog's coverage is still broader so there's no clear winner if a lot of arrays of rank 2 or more are used—I expect BQN will tend to have a higher performance ceiling, but require more knowledge and fiddling around to hit that ceiling. I think J is well behind these two in terms of generic array manipulation but it does have substantially better floating-point matrix operations, something BQN doesn't specialize in at all. K stores all arrays as nested lists, so it can't be as fast on high-rank arrays unless the last axis is long.

## Faster than C?

It's inappropriate to say a language is faster than C. Public indecency kind of stuff. On the other hand, suppose a programmer who can handle both C and BQN solves the same problem in each, and runs the C program with clang or gcc and the BQN one with CBQN. BQN might just finish first.

I don't mean that it's common! Just, it's not that weird, and could happen to anyone.

CBQN is in fact written in C, and, uh, BQN and Singeli that compiles to C. But it's not the kind of C you'd generally write unless the performance stakes are very high. Here are the major factors that make it fast:
- Dynamically-chosen number and character types, and packed bit-booleans
- Multiple algorithms with selection by inspecting arguments
- Code using SIMD and other special instruction sets
Each of these can have a huge impact, and demands more thinking, writing, and debugging (if you think auto-vectorization can save you from writing SIMD code, you're sadly mistaken. I am exactly the one to know). The reason CBQN can take on this level of optimization is that it's actually a pretty small program. An average primitive *could* be implemented in 20 or so lines of C. By convincing the BQN programmer to concentrate their code into a fairly small number of primitives, we can expend a lot of effort writing hundreds of lines, and speed up BQN programs.

You expected more discussion? Well, now I'm kinda tired… just kidding, there's a [whole page on this](versusc.md).
