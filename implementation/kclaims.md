*View this file with no extra features [here](https://mlochbaum.github.io/BQN/implementation/kclaims.html).*

# Wild claims about K performance

Sometimes I see unsourced, unclear, vaguely mystical claims about K being the fastest array language. It happens often enough that I'd like to write a long-form rebuttal to these, and a demand that the people who make these do more to justify them.

This isn't meant to put down the K language! K is in fact the only APL-family language other than BQN that I would recommend without reservations. Its C-based implementations certainly aren't slow, and choosing an array language based on performance is usually a bad idea anyway. And there's nothing wrong with the K community as a whole. Go to [the k tree](https://chat.stackexchange.com/rooms/90748/the-k-tree) and meet them! (No, now it's the [same chat](../community/forums.md) as BQN with Matrix room [#aplfarm-k:matrix.org](https://app.element.io/#/room/%23aplfarm-k:matrix.org), as well as [#ngnk:matrix.org](https://app.element.io/#/room/%23ngnk:matrix.org)). What I want to fight is the *myth* of K, which is carried around as much by those who used K once upon a time, and no longer have any connection to it, as by active users.

The points I argue here are narrow. To some extent I'm picking out the craziest things said about K to argue against. Please don't assume whoever you're talking to thinks these crazy things about K just because I wrote them here. Or, if they are wrong about these topics, that they're wrong about everything. Performance is a complicated and often counter-intuitive field and it's easy to be misled.

On that note, it's possible *I've* made mistakes, such as incorrectly designing or interpreting benchmarks. If you present me with concrete evidence against something I wrote below, I promise I'll revise this page to include it, even if I just have to quote verbatim because I don't understand a word of it.

This page has now been discussed on [Hacker News](https://news.ycombinator.com/item?id=28365645) and [Lobsters](https://lobste.rs/s/d3plgr/wild_claims_about_k_performance) (not really the intention… just try not to be *too* harsh to the next person who says L1 okay?), and I have amended and added information based on comments there and elsewhere.

## The fastest array language

When you ask what the fastest array language is, chances are someone is there to answer one of k, kdb, or q (seems less likely now than it was when I wrote this!). While vendors KX and Shakti both advertise performance heavily, they only ever refer to database performance, and it's outside users who present K as the fastest array language. I can't offer benchmarks that contradict this, but I will argue that there's little reason to take these people at their word.

The reason I have no measurements is that every contract for a commercial K includes an anti-benchmark clause. For example, Shakti's [license](https://shakti.com/download/license) says users cannot "distribute or otherwise make available to any third party any report regarding the performance of the Software benchmarks or any information from such a report". This ["DeWitt clause"](https://en.wikipedia.org/wiki/DeWitt_Clause) is common in commercial databases ([history](https://danluu.com/anon-benchmark/); [survey](https://cube.dev/blog/dewitt-clause-or-can-you-benchmark-a-database)). It takes much more work to refute bad benchmarks than to produce them, so perhaps in the high-stakes DBMS world it's not as crazy as it seems—even though it's a terrible outcome. As I would be unable to share the results, I have not taken benchmarks of any commercial K. Or downloaded one for that matter.

So I'm limited to benchmarks published with vendor approval: [STAC-M3](https://stacresearch.com/m3), [NYC Taxi](https://tech.marksblogg.com/billion-nyc-taxi-kdb.html), [Imperial College](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4342004), [vs Python](https://kx.com/blog/a-comparison-of-python-and-q-for-data-problem-solving/) and [my bumbling replication](https://news.ycombinator.com/item?id=28367019). These are all for time-series database workloads and don't cover operations like sorting, selection, filtering and so on needed for effective array programming. I don't have the database knowledge to make any strong conclusions, but it seems quite likely that kdb at least is very fast for time series workloads—a use case no one else seems to really specialize in. I also run tests with [ngn/k](https://codeberg.org/ngn/k), which is developed with goals similar to Whitney's K; the author says it's slower than Shakti but not by too much. In no case have I seen timings that imply unusually fast array operations.


On to the unofficial claims about K as an array language: the primary reason I don't give any credence to these is that they are always devoid of specifics. Most importantly, the same assertion is made across decades even though performance in J, Dyalog, and NumPy has improved by leaps and bounds in the meantime—I participated in overall Dyalog benchmark improvements by [26%](https://www.dyalog.com/dyalog/dyalog-versions/170/performance.htm), then [10%](https://www.dyalog.com/dyalog-versions/180/performance.htm) but [reverted](https://aplwiki.com/wiki/Dyalog_APL_versions#18.1) after this page's initial writing but CBQN which barely existed then is fast now… anyway. Has K4 (the engine behind kdb and Q) kept pace? Maybe it's fallen behind since Arthur left but Shakti K is better? Which other array languages has the poster used? Doesn't matter—*they* are all the same but *K* is better.

A related theme I find is equivocating between different kinds of performance. As I'll discuss below, I suspect that K is faster than APL and J for interpreting scalar code but slower than, say, Javascript, and for operations on arrays, that it beats Javascript but loses to current Dyalog and possibly J. A language that can beat all others? Not really, just well-rounded. Before getting into array-based versus scalar code, here's a simpler example. It's well known that K works on one list at a time, that is, if you have a matrix—in K, a list of lists—then applying an operation (say sum) to each row works on each one independently. If the rows are short then there's function overhead for each one. In APL, J, and BQN, the matrix is stored as one unit with a stride. The sum can use one metadata computation for all rows, and there's usually special code for many row-wise functions. I measured that Dyalog is 30 times faster than ngn/k to sum rows of a ten-million by three float (double) matrix, for one fairly representative example. It's fine to say—as many K-ers do—that these cases don't matter or can be avoided in practice; it's dishonest (or ignorant) to claim they don't exist.

## Scalar versus array code

I have a suspicion that users sometimes think K is faster than APL because they try out a Fibonacci function or other one-number-at-a-time code. Erm, your boat turns faster than a battleship, congratulations? *Python* beats these languages at interpreted performance. By like a factor of five. The only reason for anyone to think this is relevant is if they have a one-dimensional model where J is "better" than Python, so K is "better" than both.

*That's CPython of course. Language names here refer to the commonly-used implementations, such as V8 or SpiderMonkey for Javascript.*

Popular APL and J implementations interpret source code directly, without even building an AST. This is very slow, and Dyalog has several other pathologies that get in the way as well. Like storing the execution stack in the workspace to prevent stack overflows, and the requirement that a user can save a workspace with paused code and resume it *in a later version*. But the overhead is per token executed, and a programmer can avoid the cost by working on large arrays where one token does a whole lot of work. If you want to show a language is faster than APL generally, this is the kind of code to look at.

K's design is well-suited to interpreting scalar code because of its simplicity. It has only one kind of user-defined function and doesn't allow lexical closures. Implementations always compile to bytecode, which for example Q's [value](https://code.kx.com/q/ref/value/) function shows. Having to keep track of integers versus floats is a drag, but ngn/k is able to use [tagged pointers](https://en.wikipedia.org/wiki/Tagged_pointer) to store smaller integers without an allocation, and I doubt Whitney would miss a trick like that. So K interpreters can be fast.

But K still isn't good at scalar code! It's an interpreter (if a good one) for a dynamically-typed language, and will be slower than compiled languages like C and Go, or JIT-compiled ones like Javascript and Java. A compiler generates code to do what you want, while an interpreter (including a bytecode VM) is code that reads data—the program—to do what you want. Once the code is compiled, the interpreter has an extra step and *has* to be slower. Compiling has its difficulties, particularly for JIT compilers. An interpreter can use one set of source code and re-compile for different architectures, but a native compiler (such as the one used to build that interpreter…) either needs new code for each architecture or has to target an intermediate language that can then be handled with an existing compiler. But, well, it runs faster.

This is why BQN uses compiler-based strategies to speed up execution, first compiling to [object code](vm.md#bytecode) (fast enough that it's no problem to compile code every time it's run) and then usually further processing it. Right now, CBQN can compile to x86 to get rid of dispatching overhead, although that's well short of true [array language compilation](compile/intro.md). On the K side, ktye's somewhat obscure implementation now has [an ahead-of-time compiler](https://github.com/ktye/i/tree/master/kom) targeting C, which is great news. Commercial K and Q are always described by developers as interpreters, not compilers, and if they do anything like this then they have kept very quiet about it.

## Parallel execution

As of 2020, Q supports [multithreaded primitives](https://code.kx.com/q/kb/mt-primitives/) that can run on multiple CPU cores. I think Shakti supports multi-threading as well. Oddly enough, J user Monument AI also did some work on a [parallel J engine](https://www.monument.ai/m/parallel), and since then J developers have been taking some steps to get multi-threading into the core language. So array languages are finally moving to multiple cores (the reason this hasn't happened sooner is probably that array language users often have workloads where they can run one instance on each core, which is easier and tends to be faster than splitting one run across multiple cores). It's interesting, and a potential reason to use K or Q, although it's too recent to be part of the "K is fastest" mythos. Not every K claim is a wild one!

## Instruction cache

A more specific claim about K is that the key to its speed is that the interpreter, or some part of it, fits in L1 cache. This is often attributed to Arthur Whitney, and I also seem to remember reading an interview where he mentioned caching, but I haven't found any publication that backs this up. KX has at least published [this article](https://kx.com/blog/what-makes-time-series-database-kdb-so-fast/) that talks about the "L1/2 cache". Maybe instruction caching was a relevant factor in the early days of K around 2000—I'm doubtful. In the 2020s it's ridiculous to say that it matters.

Let's clarify terms first. The CPU cache is a set of storage areas that are smaller and faster than RAM; memory is copied there when it's used so it will be faster to access it again later. L1 is the smallest and fastest level. On a typical CPU core these days it might consist of 32KB of *data* cache for memory to be read and written, and 32KB of *instruction* cache for memory to be executed by the CPU. When I've seen it the L1 cache claim is specifically about the K interpreter (and not the data it works with) fitting in the cache, so it clearly refers to the instruction cache.

(Unlike the instruction cache, the data cache is a major factor that makes array languages faster. It's what terms like "cache-friendly" typically refer to. I think the reason K users prefer to talk about the instruction cache is that it allows them to link this well-known consideration to the size of the kdb binary, which is easily measured and clearly different from other database products. But [this great article](https://matklad.github.io/2021/07/10/its-not-always-icache.html) discusses jumping to blame ICache in Rust, so maybe it's just an explanation that sounds better than it is.)

A K interpreter will definitely benefit from the instruction cache. Unfortunately, that's where the truth of this claim runs out. Any other interpreter you use will get just about the same benefit, because the most used code will fit in the cache with plenty of room to spare. And the best case you get from a fast core interpreter loop is fast handling of scalar code—exactly the case that array languages typically ignore.

So, 32KB of instruction cache. That would be small even for a K interpreter. Why is it enough? I claim specifically that while running a program might cause a cache miss once in a while, the total cost of these will only ever be a small fraction of execution time. This is because an interpreter is made of loops: a core loop to run the program as a whole and usually smaller loops for some specific instructions. These loops are small, with the core loop being on the larger side. In fact it can be pretty huge if the interpreter has a lot of exotic instructions, but memory is brought to the cache in lines of around 64 bytes, so that unused regions can be ignored. The active portions might take up a kilobyte or two. Furthermore, you've got the L2 and L3 caches as backup, which are many times larger than L1 and not much slower.

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

Here are the BQN calls that build [CBQN](https://github.com/dzaima/CBQN)'s object code sources, and this website:

     Performance counter stats for './genRuntime /home/marshall/BQN/':

           232,456,331      cycles:u
             4,482,531      icache_16b.ifdata_stall:u
               707,909      cache-misses:u
             5,058,125      L1-dcache-load-misses:u
             1,315,281      L1-icache-load-misses:u

           0.103811282 seconds time elapsed

     Performance counter stats for './gendocs':

         5,633,327,936      cycles:u
           494,293,472      icache_16b.ifdata_stall:u
             8,755,069      cache-misses:u
            37,565,924      L1-dcache-load-misses:u
           265,985,526      L1-icache-load-misses:u

           2.138414849 seconds time elapsed

And the Python-based font tool I use to build [font samples](https://mlochbaum.github.io/BQN/fonts.html) for this site:

     Performance counter stats for 'pyftsubset […more stuff]':

           499,025,775      cycles:u
            24,869,974      icache_16b.ifdata_stall:u
             5,850,063      cache-misses:u
            11,175,902      L1-dcache-load-misses:u
            11,784,702      L1-icache-load-misses:u

           0.215698059 seconds time elapsed

Dividing the stall number by total cycles gives us percentage of program time that can be attributed to L1 instruction misses.

        l ← "J"‿"BQN"‿"BQN"‿"Python"
        l ≍˘ 100 × 56‿4.5‿494‿25 ÷ 1_457‿232‿5_633‿499

So, roughly 4%, 2 to 9%, and 5%. The cache miss counts are also broadly in line with these numbers. Note that full cache misses are pretty rare, so that most misses just hit L2 or L3 and don't suffer a large penalty. Also note that instruction cache misses are mostly lower than data misses, as expected.

Don't get me wrong, I'd love to improve performance even by 2%. But it's not exactly world domination, is it? The perf results are an upper bound for how much these programs could be sped up with better treatment of the instruction cache. If K is faster by more than that, it's because of other optimizations.

For comparison, here's [ngn/k](https://codeberg.org/ngn/k) (which does aim for a small executable) running one of its unit tests—test 19 in the a20/ folder, chosen because it's the longest-running of those tests.

     Performance counter stats for '../k 19.k':

         3,341,989,998      cycles:u
            21,136,960      icache_16b.ifdata_stall:u
               336,847      cache-misses:u
            10,748,990      L1-dcache-load-misses:u
            20,204,548      L1-icache-load-misses:u

           1.245378356 seconds time elapsed

The stalls are less than 1% here, but it seems this is largely due to the different nature of the program: `19.k` is 10 lines while the others are hundreds of lines long. Now that [Advent of Code](../community/aoc.md) 2021 has run, dzaima points out that his solutions are comparable in intent to ngn's, and I measure very close to 0.5% icache stalls in both (27 of 5,404 million cycles in BQN and 34 of 6,600 in ngn/k, problems 23 and 24 omitted). But I don't have a longer K program handy to test with, and you could always argue the result doesn't apply to Whitney's K. Again, it doesn't matter much: the point is that the absolute most the other interpreters could gain from being more L1-friendly is about 10% on those fairly representative programs.
