*View this file with no extra features [here](https://mlochbaum.github.io/BQN/implementation/kclaims.html).*

# Wild claims about K performance

Sometimes I see unsourced, unclear, vaguely mystical claims about K being the fastest array language. It happens often enough that I'd like to write a long-form rebuttal to these, and a demand that the people who make these do more to justify them.

This isn't meant to put down the K language! K is in fact the only APL-family language other than BQN that I would recommend without reservations. And there's nothing wrong with the K community as a whole. Go to [the k tree](https://chat.stackexchange.com/rooms/90748/the-k-tree) and meet them! What I want to fight is the *myth* of K, which is carried around as much by those who used K once upon a time, and no longer have any connection to it, as by active users.

One theme I find is equivocating between different kinds of performance. I suspect that for interpreting scalar code K is faster than APL and J but slower than Javascript, and certainly any compiled language. For operations on arrays, maybe it beats Javascript and Java but loses to current Dyalog and tensor frameworks. Simple database queries, Shakti says it's faster than Spark and Postgres but is silent about newer in-memory databases. The most extreme K advocates sweep away all this complexity by comparing K to weaker contenders in each category. Just about any language can be "the best" with this approach.

I've had to expand on things here, inferring details because I haven't been able to get K supporters to articulate their points. If you know something I don't, I'd be interested in discussing it. If you can offer concrete evidence against my arguments below, I promise I'll revise this page to include it, even if I just have to quote verbatim because I don't understand a word of it.

## The fastest array language

When you ask what the fastest array language is, chances are someone is there to answer one of k, kdb, or q. I can't offer benchmarks that contradict this, but I will argue that there's little reason to take these people at their word.

The reason I have no measurements is that every contract for a commercial K includes an anti-benchmark clause. For example, Shakti's [license](https://shakti.com/download/license) says users cannot "distribute or otherwise make available to any third party any report regarding the performance of the Software benchmarks or any information from such a report". As I would be unable to share the results, I have not taken benchmarks of any commercial K. Or downloaded one for that matter. Shakti could publish benchmarks; they choose to publish a handful of comparisons with database software and none with array languages or frameworks. I do run tests with [ngn/k](https://codeberg.org/ngn/k), which is developed with goals similar to Whitney's K; the author says it's slower than Shakti but not by too much.

The primary reason I don't give any credence to claims that K is the best is that they are always devoid of specifics. Most importantly, the same assertion is made across decades even though performance in J, Dyalog, and NumPy has improved by leaps and bounds in the meantime—I participated in advances of [26%](https://www.dyalog.com/dyalog/dyalog-versions/170/performance.htm) and [10%](https://www.dyalog.com/dyalog-versions/180/performance.htm) in overall Dyalog benchmarks in the last two major versions. Has K4 (the engine behind kdb and Q) kept pace? Maybe it's fallen behind since Arthur left but Shakti K is better? Which other array languages has the poster used? Doesn't matter—*they* are all the same but *K* is better.

It's also crucial to know what kind of code is being run. Below I discuss array-based versus scalar code, but here's another case. It's well known that K works on one list at a time, that is, if you have a matrix—in K, a list of lists—then applying an operation (say sum) to each row works on each one independently. If the rows are short then there's function overhead for each one. In APL, J, and BQN, the matrix is stored as one unit with a stride. The sum can use one metadata computation for all rows, and there's usually special code for many row-wise functions. I measured that Dyalog is 30 times faster than ngn/k to sum rows of a ten-million by three float (double) matrix, for one fairly representative example. It's fine to say—as many K-ers do—that these cases don't matter or can be avoided in practice; it's dishonest (or ignorant) to claim they don't exist.

## Scalar versus array code

I have a suspicion that users sometimes think K is faster than APL because they try out a Fibonacci function or other one-number-at-a-time code. Erm, your boat turns faster than a battleship, congratulations? *Python* beats these languages at interpreted performance. By like a factor of five. The only reason for anyone to think this is relevant is if they have a one-dimensional model where J is "better" than Python, so K is "better" than both.

Popular APL and J implementations interpret source code directly, without even building an AST. This is very slow, and Dyalog has several other pathologies that get in the way as well. Like storing the execution stack in the workspace to prevent stack overflows, and the requirement that a user can save a workspace with paused code and resume it *in a later version*. But the overhead is per token executed, and a programmer can avoid the cost by working on large arrays where one token does a whole lot of work. If you want to show a language is faster than APL generally, this is the kind of code to look at.

K is designed to be as fast as possible when interpreting scalar code, for example using a [grammar](https://k.miraheze.org/wiki/Grammar) that's much simpler than [BQN's](../spec/grammar.md) (speed isn't the only benefit of being simpler of course, but it's clearly a consideration). It succeeds at this, and K interpreters are very fast, even without bytecode compilation in advance.

But K isn't good at scalar code either! It's also an interpreter for a dynamically-typed language, and will be slower than compiled languages like C and Go, or JIT-compiled ones like Javascript and Java. A compiler generates code to do what you want, while an interpreter is code that reads data (the program) to do what you want. This is why BQN uses compiler-based strategies to speed up execution, first compiling to bytecode to make syntax overhead irrelevant and then usually post-processing that bytecode.

## Instruction cache

A more specific claim about K is that the key to its speed is that the interpreter, or some part of it, fits in L1 cache. I know Arthur Whitney himself has said this but can't track down the source now. Maybe this was a relevant factor in the early days of K around 2000—I'm doubtful. In the 2020s it's ridiculous to say that instruction caching matters.

Let's clarify terms first. The CPU cache is a set of storage areas that are smaller and faster than RAM; memory is copied there when it's used so it will be faster to access it again later. L1 is the smallest and fastest level. On a typical CPU these days it might consist of 64KB of *data* cache for memory to be read and written, and 64KB of *instruction* cache for memory to be executed by the CPU. When I've seen it the L1 cache claim is specifically about the K interpreter (and not the data it works with) fitting in the cache, so it clearly refers to the instruction cache.

A K interpreter will definitely benefit from the instruction cache. Unfortunately, that's where the truth of this claim runs out. Any other interpreter you use will get just about the same benefit, because the most used code will fit in the cache with plenty of room to spare. And the best case you get from a fast core interpreter loop is fast handling of scalar code—exactly the case that array languages typically ignore. K will beat array languages in this area, but lose to interpreters with JIT compilation like JavaScript or CBQN. It might be faster these languages when big arrays are involved, but if so, it has nothing to do with the instruction cache!

So, 64KB of instruction cache. That would be small even for a K interpreter. Why is it enough? I claim specifically that while running a program might cause a cache miss once in a while, the total cost of these will only ever be a small fraction of execution time. This is because an interpreter is made of loops: a core loop to run the program as a whole and usually smaller loops for some specific instructions. These loops are small, with the core loop being on the larger side. In fact it can be pretty huge if the interpreter has a lot of exotic instructions, but memory is brought to the cache in lines of around 64 bytes, so that unused regions can be ignored. The active portions might take up a kilobyte or two. Furthermore, you've got the L2 and L3 caches as backup, which are many times larger than L1 and not much slower.

So a single loop doesn't overflow the cache. And the meaning of a loop is that it's loaded once but run multiple times—for array operations, it could be a huge number. The body of an interpreter loop isn't likely to be fast either, typically performing some memory accesses or branches or both. An L1 instruction cache miss costs tens of cycles if it's caught by another cache layer and hundreds if it goes to memory. Twenty cycles would be astonishingly fast for a go around the core interpreter loop, and array operation loops are usually five cycles or more, plus a few tens in setup. It doesn't take many loops to overcome a cache miss, and interpreting any program that doesn't finish instantly will take millions of iterations or more, spread across various loops.

### Measuring L1 with perf

Look, you can measure this stuff. Linux has a nice tool called [perf](https://en.wikipedia.org/wiki/Perf_(Linux)) that can track all sorts of hardware events related to your program, including cache misses. You can pass in a list of events with `-e` followed by the program to be run. It can even distinguish instruction from data cache misses! I'll be showing the following events:

    perf stat -e cycles,icache_16b.ifdata_stall,cache-misses,L1-dcache-load-misses,L1-icache-load-misses

`cycles` is the total number of CPU cycles run. `L1-dcache-load-misses` shows L1 data cache misses and `L1-icache-load-misses` shows the instruction cache misses; `cache-misses` shows accesses that miss every layer of caching, which is a subset of those two (more detailed explanation [here](https://stackoverflow.com/questions/55035313/how-does-linux-perf-calculate-the-cache-references-and-cache-misses-events)). `icache_16b.ifdata_stall` is a little fancy. Here's the summary given by `perf list`:

      icache_16b.ifdata_stall
           [Cycles where a code fetch is stalled due to L1 instruction cache miss]

That's just the whole cost (in cycles) of L1 misses, exactly what we want! First I'll run this on a J program I have lying around, building my old [Honors thesis](https://cdr.lib.unc.edu/concern/honors_theses/pg15bk00p) with  [JtoLaTeX](https://github.com/mlochbaum/JtoLaTeX).

     Performance counter stats for 'jlatex document.jtex nopdf':

         1,457,284,402      cycles:u
            56,485,452      icache_16b.ifdata_stall:u
             2,254,192      cache-misses:u
            37,849,426      L1-dcache-load-misses:u
            28,797,332      L1-icache-load-misses:u

           0.557255985 seconds time elapsed

Here's the BQN call that builds [CBQN](https://github.com/dzaima/CBQN)'s bytecode sources:

     Performance counter stats for './genRuntime /home/marshall/BQN/':

           241,224,322      cycles:u
             5,452,372      icache_16b.ifdata_stall:u
               829,146      cache-misses:u
             6,954,143      L1-dcache-load-misses:u
             1,291,804      L1-icache-load-misses:u

           0.098228740 seconds time elapsed

And the Python-based font tool I use to build [font samples](https://mlochbaum.github.io/BQN/fonts.html) for this site:

     Performance counter stats for 'pyftsubset […more stuff]':

           499,025,775      cycles:u
            24,869,974      icache_16b.ifdata_stall:u
             5,850,063      cache-misses:u
            11,175,902      L1-dcache-load-misses:u
            11,784,702      L1-icache-load-misses:u

           0.215698059 seconds time elapsed

Dividing the stall number by total cycles gives us percentage of program time that can be attributed to L1 instruction misses. 

        "J"‿"BQN"‿"Python" ≍˘ 100 × 56‿5.4‿25 ÷ 1_457‿241‿499

So, roughly 4%, 2%, and 5%. The cache miss counts are also broadly in line with these numbers. Note that full cache misses are pretty rare, so that most misses just hit L2 or L3 and don't suffer a large penalty. Also note that instruction cache misses are mostly lower than data misses, as expected.

Don't get me wrong, I'd love to improve performance even by 2%. But it's not exactly world domination, is it? And it doesn't matter how cache-friendly K is, that's the absolute limit.

For comparison, here's [ngn/k](https://codeberg.org/ngn/k) (which does aim for a small executable) running one of its unit tests—test 19 in the a20/ folder, chosen because it's the longest-running of those tests.

     Performance counter stats for '../k 19.k':

         3,341,989,998      cycles:u
            21,136,960      icache_16b.ifdata_stall:u
               336,847      cache-misses:u
            10,748,990      L1-dcache-load-misses:u
            20,204,548      L1-icache-load-misses:u

           1.245378356 seconds time elapsed

The stalls are less than 1% here, so maybe the smaller executable is paying off in some way. I can't be sure, because the programs being run are very different: `19.k` is 10 lines while the others are hundreds of lines long. But I don't have a longer K program handy to test with. Again, it doesn't matter much: the point is that the absolute most the other interpreters could gain from being more L1-friendly is about 5% on those fairly representative programs.
