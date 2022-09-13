*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/perf.html).*

# How does BQN perform?

How fast is the performance-oriented BQN implementation, [CBQN](https://github.com/dzaima/CBQN)? Before answering this question I must ask, why do you care? People are out there looking for the fastest array language before they've even tried *any* of them to see if it works for them. Which is kind of strange: programs usually have a point where they are fast enough, and for the ones that don't, the slow part is often a concentrated piece of the program that's better handled by an existing specialized tool like LAPACK. Even in these cases, a laser focus on performance from the beginning makes your code more difficult to understand and can lead to major missed opportunities. I think it's best to start with the most expressive language in order to work out strategy, and begin thinking about tactics once you know when and how the performance falls short. Without this understanding, benchmarks are just a dick measuring contest. And it's not even your own dick. It's public, you're just using it.

Anyway, BQN's dick is pretty fast. Compiles its own compiler in 3ms. Builds this whole site—a megabyte or so of markdown—in a second and a half. First hundred million primes in a second. That sort of thing. For CBQN right now, performance splits into three major cases:
- Scalar code, mostly using atoms. CBQN is faster than other array languages and on par with lightweight interpreters (not JIT compilers).
- Flat lists, particularly integers and characters. CBQN is rarely too slow for these and often beats other array languages, as well as idiomatic C.
- Multidimensional arrays. These are slow, but not pathologically so. CBQN has few optimizations for them, and often falls back to the runtime which has implementations using a lot of scalar code.

The spotty optimization coverage means that it's more accurate to say CBQN can be fast, not that it will be fast. Have to learn how to use it. I would definitely recommend getting on the forum if you're having trouble with performance so you can find some tricks to use or request improvements. Also see per-primitive benchmarks in [bencharray](https://mlochbaum.github.io/bencharray/pages/summary.html).

Currently we aim for high performance on a single CPU core, and are focusing on 64-bit x86. CBQN won't use additional cores or a GPU for acceleration. It does make substantial use of x86 vector instructions up to AVX2 (2013) in the Singeli build, and will have a few more slow cases if built without Singeli—including on ARM and other architectures.

## Versus other array languages

Things get hard when you try to put array languages up next to each other. You can get completely different results depending on what sort of problems you want to solve and how you write code, and all those different results are valid. Because people ask for it, I'll try to give an account for the implementations I'm familiar with. I'm of course biased towards the languages I've worked on, Dyalog and BQN; if nothing else, these tend to prioritize just the features I find important! Note also that the situation can change over time; these comments are from 2022.

The implementations I use for comparison are Dyalog APL, ngn/k, and J. I don't benchmark against proprietary K implementations because the anti-benchmarking clauses in their licenses would prevent me from sharing the results (discussed [here](kclaims.md)).

Array operations are the way to get the most value out of an array language ([background reading](https://aplwiki.com/wiki/Performance)), so these languages tend to focus on them. But BQN tries to be usable in less array-oriented situations as well, and is faster for scalar code in the simple cases I've measured—things like naive Fibonacci or folding with a function that does some arithmetic. Dyalog is uniformly slow on such things, 5–10x worse than BQN. J is a bit better with tacit code and worse with explicit, 3–15x worse than BQN. And I measure ngn/k around 2x worse than BQN. For context, BQN is just slower than LuaJIT with the JIT off (which is still a fast interpreter), and I usually expect it to be about 10x slower than C in cases where C operations are compiling to single instructions (e.g. excluding auto-vectorization).

I publish BQN benchmarks of array operations in [bencharray](https://mlochbaum.github.io/bencharray/pages/summary.html), which also allows me to compare against J and Dyalog to some extent. I find that in all cases, if BQN is better it's because of fundamental superiority, and if it's worse it's just a case that we're meaning to improve but haven't gotten to yet. Both happen a fair amount. In the best cases BQN can be faster by 2x or more, but these benchmarks have an extreme bias because I tend to benchmark things that dzaima or I are actively working on speeding up. We do sometimes compare translated code in the forum. Dyalog has generally been faster than CBQN when larger array operations are involved, but BQN is also quickly getting new special code, so things may be turning around!

We've been working on list operations instead of getting into multi-dimensional stuff. Dyalog and J are definitely better at operations that make significant use of higher-rank arrays. BQN can also have some slow cases with booleans or floats.

## Faster than C?

It's inappropriate to say a language is faster than C. Public indecency kind of stuff. On the other hand, suppose a programmer who can handle both C and BQN solves the same problem in each, and runs the C program with clang or gcc and the BQN one with CBQN. BQN might just finish first.

I don't mean that it's common! Just, it's not that weird, and could happen to anyone.

CBQN is in fact written in C, and, uh, BQN and Singeli that compiles to C. But it's not the kind of C you'd generally write unless the performance stakes are very high. Here are the major factors that make it fast:
- Dynamically-chosen number and character types, and packed bit-booleans
- Multiple algorithms with selection by inspecting arguments
- Code using SIMD and other instruction sets
Each of these can have a huge impact, and takes more thinking, writing, and debugging (if you think auto-vectorization can save you from writing SIMD code, you're sadly mistaken. I am exactly the one to know). The reason CBQN can take on this level of optimization is that it's actually a pretty small program. An average primitive *could* be implemented in 20 or so lines of C. By convincing the BQN programmer to concentrate their code into a fairly small number of primitives, we can expend a lot of effort writing hundreds of lines, and speed up BQN programs.

This discussion didn't last too long, I know. You might also read [this section](compile/intro.md#array-interpreters) on interpreters in a page supposedly about compilers, or check my talk about Dyalog APL titled "The Interpretive Advantage" ([video](https://dyalog.tv/Dyalog18/?v=-6no6N3i9Tg), [zipped slides](https://www.dyalog.com/user-meetings/uploads/conference/dyalog18/presentations/D15_The_Interpretive_Advantage.zip)).
