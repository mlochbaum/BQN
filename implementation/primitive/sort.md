*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/sort.html).*

# Implementation of ordering functions

The [ordering functions](../../doc/order.md) are Sort (`∧∨`), Grade (`⍋⍒`), and Bins (`⍋⍒`). Although these are well-studied—particularly sorting, and then binary search or "predecessor search"—there are many recent developments, as well as techniques that I have not found in the literature. The three functions are closely related but have important differences in what algorithms are viable. Sorting is a remarkably deep problem with different algorithms able to do a wide range of amazing things, and sophisticated ways to combine those. It is by no means solved. In comparison, Bins is pretty tame.

There's a large divide between ordering compound data and simple data. For compound data comparisons are expensive, and the best algorithm will generally be the one that uses the fewest comparisons. For simple data they fall somewhere between cheap and extremely cheap, and fancy branchless and vectorized algorithms are the best.

## On quicksort versus merge sort

Merge sort is better. It is deterministic, stable, and has optimal worst-case performance. Its pattern handling is better: while merge sort handles "horizontal" patterns and quicksort does "vertical" ones, merge sort gets useful work out of *any* sequence of runs but in-place quicksort will quickly mangle its analogue until it may as well be random.

But that doesn't mean merge sort is always faster. Quicksort seems to work a little better branchlessly. For sorting, quicksort's partitioning can reduce the range of the data enough to use an extremely quick counting sort. Partitioning is also a natural fit for binary search, where it's mandatory for sensible cache behavior with large enough arguments. So it can be useful. But it doesn't merge, and can't easily be made to merge, and that's a shame.

The same applies to the general categories of partitioning sorts (quicksort, radix sort, samplesort) and merging sorts (mergesort, timsort, multimerges). Radix sort is a weird one: very fast on lots of inputs, but not adaptive at all, and in fact actively un-adaptive on common patterns from cache associativity. Very hard to know when it's a good choice.

## On binary search

Binary searches are very easy to get wrong. Do not write `(hi+lo)/2`: it's not safe from overflows. I always follow the pattern given in the first code block [here](https://pvk.ca/Blog/2015/11/29/retrospective-on-binary-search-and-on-compression-slash-compilation/). This code will never access the value `*base`, so it should be considered a search on the `n-1` values beginning at `base+1` (the perfect case is when the number of values is one less than a power of two, which is in fact how it has to go). It's branchless and always takes the same number of iterations. To get a version that stops when the answer is known, subtract `n%2` from `n` in the case that `*mid < x`.

## Compound data

Array comparisons are expensive. The goal here is almost entirely to minimize the number of comparisons. Which is a much less complex goal than to get the most out of modern hardware, so the algorithms here are simpler.

For **Sort** and **Grade**, use Timsort. It's time-tested and shows no signs of weakness (but do be sure to pick up a fix for the bug discovered in 2015 in formal verification). Hardly different from optimal comparison numbers on random data, and outstanding pattern handling. Grade can be done either by selecting from the original array to order indices or by moving the data around in the same order as the indices. I think the second of these ends up being substantially better for small-ish elements.

For **Bins**, use a branching binary search: see [On binary search](#on-binary-search) above. But there are also interesting (although, I expect, rare) cases where only one argument is compound. Elements of this argument should be reduced to fit the type of the other argument, then compared to multiple elements. For the right argument, this just means reducing before doing whatever binary search is appropriate to the left argument. If the left argument is compound, its elements should be used as partitions. Then switch back to binary search only when the partitions get very small—probably one element.

## Simple data

The name of the game here is "branchless".

For **Sort**:
- Insertion sort is best for small data (*maybe* [quadsort](https://github.com/scandum/quadsort), but I worry about the cache footprint if you just sort a small array somewhere in a long loop).
- Then [counting sort](#distribution-sorts) for 1-byte types (and obviously for 1-bit regardless of length).
- Branchless [quicksorts](#quicksort) are the solid choice for larger types, particularly since they can track ranges and call counting and other distribution sorts when appropriate.
- But for 2- and 4-byte data, [radix sort](#radix-sort) can be a lot faster? For 2-byte sort, I think it's a better bridge than fluxsort between insertion and counting sort (but scan for sortedness first); for 4-byte, hard to say.

**Grade** is basically the same (now that fluxsort gives us a good stable quicksort), except moves get more expensive relative to comparisons. Counting sort needs to be switch to the much slower bucket sort.

A branchless binary search is adequate for **Bins** but in many cases—very small or large `𝕨`, and small range—there are better methods.

### Distribution sorts

Both counting and bucket sort are small-range algorithms that begin by counting the number of each possible value. Bucket sort, as used here, means that the counts are then used to place values in the appropriate position in the result in another pass. Counting sort does not read from the initial values again and instead reconstructs them from the counts. It might be written `(//⁼)⌾(-⟜min)` in BQN, relying on the extension of `/⁼` to unsorted arguments.

Bucket sort can be used for Grade or sort-by (`⍋⊸⊏`), but counting sort only works for sorting itself. It's not-even-unstable: there's no connection between result values and the input values except that they are constructed to be equal. But with [fast Indices](replicate.md#non-booleans-to-indices), counting sort is vastly more powerful, and is effective with a range four to eight times the argument length. This is large enough that it might pose a memory usage problem, but the memory use can be made arbitrarily low by partitioning.

I developed [Robin Hood Sort](https://github.com/mlochbaum/rhsort) as an algorithm with similar properties to bucket sort that relies on uniformly-distributed data rather than a small range. It uses a buffer a few times larger than the input array, and inserts values in a manner similar to a hash table with linear probing, shifting large clumps out if they appear—they're merge-sorted back in at the end. Like counting sort, the substantial memory use can be cut down by partitioning. And a random selection of `√n` samples is enough to make a good decision about whether to use it (see [candidate selection](#candidate-selection)), which is a good fit for quicksorts. Of course this can only be probabilistic, so it's still important that RHsort has decent worst-case performance. When quadsort is used for merging, the worst case appears to be about half as fast as fluxsort, very solid.

#### Radix sort

LSD radix sort is really fast, like three times faster than fluxsort on random 4-byte data. The idea is: bucket sort according to the last byte, then the second-to-last, on up to the first byte. Array is now sorted, after most likely having been scrambled substantially (but stably!). It's tricky to implement right though. The `sort_inline` functions from `ska_sort_copy` [here](https://github.com/skarupke/ska_sort) are good. They count buckets for every step in one pass, and move back and forth from the array to a buffer instead of adding more memory. Radix sort uses memory proportional to the input array length, plus a constant. But that constant is a liability on short arrays, so it's only really useful for sizes above a hundred or so (to get down to this limit, use 1-byte counts and sum with SIMD or at least SWAR).

LSD radix sort suffers from problems of cache associativity. Now, usually (for, say, non-blocked transpose) such problems strike only at power of 2 lengths. But by picking out input bytes, radix sort tends to create its own powers of 2. Consider an input consisting of ascending natural numbers `↕n`. Lowest byte is fine: the lengths are around `n÷256`. Next byte up, problems: this byte only changes once every 256 inputs, so every bucket but one has a multiple of 256 length! And writes will cycle around these buckets, so they stay roughly in sync. This is enough to overwhelm any [set-associative](https://en.wikipedia.org/wiki/Cache_associativity#Set-associative_cache) cache. I measured a degradation of about 5 times on that pass and 3 times overall. The case with bucket lengths near multiples of 256—they need to be separated by an entire cache line not to conflict—is detectable after the cheap counting pass, but it's not the only way this pattern can arise. For example, put a bunch of zeros at the beginning of the array. The first bucket now has some arbitrary length, but once the zeros are processed the gap between it and the next is back to being a multiple of 256. The good news is that it still requires a lot of space to start kicking out a bunch of cache lines: below 10,000 4-byte elements I could never measure significant degradation. So if the lack of adaptivity (and O(n) memory of course) doesn't bother you, radix sort is kind of the best thing going for 4-byte values in the 500 to 20,000 range.

### Quicksort

[Fluxsort](https://github.com/scandum/fluxsort) attains high performance with a branchless stable partition that places one half on top of existing data and the other half somewhere else. One half ends up in the appropriate place in the sorted array. The other is in swap memory, and will be shifted back by subsequent partitions and base-case sorting. Aside from the partitioning strategy, fluxsort makes a number of other decisions differently from pdqsort, including a fairly complicated merge sort ([Quadsort](https://github.com/scandum/quadsort)) as the base case.

[Crumsort](https://github.com/scandum/crumsort) is an in-place adaptation of fluxsort, which uses a (constant) small amount of external memory to take an approach to partitioning that's slightly more ordered than Hoare partitioning. It's more complicated than fluxsort but performs similarly at small sizes and faster at large ones.

[This paper](https://arxiv.org/abs/2106.05123) gives a good description of [pdqsort](https://github.com/orlp/pdqsort). I'd start with the [Rust version](https://github.com/rust-lang/rust/blob/master/library/core/src/slice/sort.rs), which has some advantages but can still be improved further. The subsections below describe improved [partitioning](#partitioning) and an [initial pass](#initial-pass) with several benefits. I also found that the pivot randomization methods currently used are less effective because they swap elements that won't become pivots soon; the pivot candidates and randomization targets need to be chosen to overlap. The optimistic insertion sort can also be improved: when a pair of elements is swapped the smaller one should be inserted as usual but the larger one can also be pushed forward at little cost, potentially saving many swaps and handling too-large elements as gracefully as too-small ones.

Most likely fluxsort/crumsort partitioning make pdqsort's partitioning obselete for sorting. Because it's easily invertible if comparison results are saved (it's a self-inverse) it's still useful for the partitioning approach to binary search mentioned later.

#### Partitioning

In-place quicksort relies on a partitioning algorithm that exchanges elements in order to split them into two contiguous groups. The [Hoare partition scheme](https://en.wikipedia.org/wiki/Quicksort#Hoare_partition_scheme) does this, and [BlockQuicksort](https://github.com/weissan/BlockQuicksort) showed that it can be performed quickly with branchless index generation; this method was then adopted by pdqsort. But the [bit booleans to indices](replicate.md#booleans-to-indices) method is faster and fits well with vectorized comparisons.

It's simplest to define an operation `P` that partitions a list `𝕩` according to a boolean list `𝕨`. Partitioning permutes `𝕩` so that all elements corresponding to 0 in `𝕨` come before those corresponding to 1. The quicksort partition step, with pivot `t`, is `(t≤𝕩)P𝕩`, and the comparison can be vectorized. Interleaving comparison and partitioning in chunks would save memory (a fraction of the size of `𝕩`, which should have 32- or 64-bit elements because plain counting sort is best for smaller ones) but hardly speeds things up: only a few percent, and only for huge lists with hundreds of millions of elements. The single-step `P` is also good for Bins, where the boolean `𝕨` will have to be saved.

For binary search `𝕨⍋𝕩`, partitioning allows one pivot element `t` from `𝕨` to be compared to all of `𝕩` at once, instead of the normal strategy of working with one element from `𝕩` at a time. `𝕩` is partitioned according to `t≤𝕩`, then result values are found by searching the first half of `𝕨` for the smaller elements and the second half for the larger ones, and then they are put back in the correct positions by reversing the partitioning. Because Hoare partitioning works by swapping independent pairs of elements, `P` is a self inverse, identical to `P⁼`. So the last step is simple, provided the partitioning information `t≤𝕩` is saved.

### Scans and heuristics

Because quicksort does its work before recursing, it's well suited to statistical techniques that allow the algorithm to be changed.

#### Initial pass

An initial pass for pdqsort (or another in-place quicksort) provides a few advantages:
- Recognize sorted and reverse-sorted arrays as fast as possible
- Always use unguarded insertion sort
- Find and maintain range information to switch to counting sort

The main purpose of the pass is to find the range of the array. For an insignificant additional cost, the smallest and largest elements can be swapped to the edges of the array and sorted arrays can be detected.

To find the smallest and largest elements, compute the range in blocks, on the order of 1KB each. Record the maximum and minimum, as well as the index of the block that contained these. After each block, update the range as well as the indices. Then, after traversing all blocks, search the appropriate blocks for these values to find exact indices. It may also be possible to skip the search and jump straight to counting sort.

Finding an initial run is fast as well. Compare the first two elements to determine direction, then search for the first pair that have the opposite direction (this can be vectorized because overreading is fine). This run can be used as the first range block, because the maximum and minimum are the two elements at the ends of the run.

At the start of sorting, swap the smallest element to the beginning and the largest to the end, and shrink the size of the array by one in each direction. Now the element before the array is a lower bound and the one after is an upper bound. This property can also be maintained as the array is partitioned, by placing a pivot element between the two halves (swap it to one side of the array before partitioning and to the middle afterwards). As a result, it's always safe to use unguarded insertion sort, and an upper bound for the range of the array can always be found using the difference between the elements before and after it. Now finding the range is fast enough to check for counting sort at every recursion.

This is a very simple initial pass; a more sophisticated one might be beneficial. If the array starts with a large run then there could be more of them.

#### Candidate selection

Traditionally, performance-oriented quicksort algorithms have chosen pivots using a small number of candidates, such as a median of 3 or pseudomedian of 9. Scandum's work with fluxsort showed that this is leaving performance on the table, because it results in less even partitions. My own [analysis](https://github.com/scandum/fluxsort/issues/1#issuecomment-890540150) found an optimal pivot number approximately equal to `√n÷1+4⋆⁼n`, which also seems to do well empirically. Both costs and benefits here are proportional to `√n` before an O(n) partition, so there's significant room for variation in this number. The cost of increasing the number of pivots further can also be decreased by maintaining candidates as the array is partitioned.

Candidates should be chosen in a pseudo-random or at least not significantly patterned distribution to avoid getting a useless biased median. Randomness is also important for heuristics that select between different algorithms. These will be faster for sorting some patterns or distributions and slower for others. In order to avoid slow cases, the requirement should be that any particular slow case has a low probability of passing the heuristic. This approach doesn't require a guess at what properties the input is likely to have, while an attempt to minimize expected time or some other average metric would.

Robin Hood sorting has a sharp threshold at about `√n` where it's feasible to distinguish good and bad cases, that is, reject arrays with many collisions and accept uniformly random ones. This requires the candidate sampling method to be able to pick candidates close to each other, or it'll fail to notice things like an input that consists of many short blocks of similar values.

Inspecting the pivot candidates before or while sorting could also be used to choose a merge-based recursive step over a partition-based one. That is, rather than partitioning then recursing on each half, the algorithm would recurse on each half and then merge them together. If the halves don't overlap by much, the merge can skip a lot of elements with some binary searches and potentially be much than partitioning, which at a minimum needs to compare every element to the pivot. This allows the overall algorithm to exploit large-scale structure for merging even if there's a lot of noise at the small scale that would make merge sorting a bad choice overall. Unlike partitioning, it doesn't reduce the range of the halves.

### Other sorting algorithms

[IPS⁴o](https://github.com/ips4o/ips4o) is a horrifyingly complicated samplesort thing. Unstable, but there's also a stable not-in-place version PS⁴o. For very large arrays it probably has the best memory access patterns, so a few samplesort passes could be useful.

[Vergesort](https://github.com/Morwenn/vergesort) has another useful first-pass strategy, which spends an asymptotically small amount of time searching for runs before sorting. Since it only detects perfect runs it won't give the full adaptivity of a good merge sort.

Sorting networks compare and swap elements in a fixed pattern, and so can be implemented with branchless or even vectorized code. They're great for sorting many small arrays of the same size, but the limit before insertion sort beats it will be pretty small without hardware specialization.

#### SIMD sorting

A few people have done some work on merge sorting with AVX2 or AVX-512: [two](https://github.com/sid1607/avx2-merge-sort) [examples](https://github.com/PatwinchIR/ultra-sort). Pretty complicated, and still mostly in the proof of concept stage, but the benchmarks on uniform random arrays are good. Can these be made adaptive?

[ChipSort](https://github.com/nlw0/ChipSort.jl) seems further along than those. It uses sorting networks, comb sort, and merging, which all fit nicely with SIMD and should work well together.

Or AVX can [speed up](https://github.com/WojciechMula/simd-sort) quicksort. I suspect this is more of a marginal improvement (over branchless quicksorts) relative to merge sort.

### Binary search

Reminder that we're talking about simple, not [compound](#compound-data) data. The most important thing is just to have a good branchless binary search (see [above](#on-binary-search)), but there are other possible optimizations.

If `𝕨` is extremely small, use a vector binary search as described in "Sub-nanosecond Searches" ([video](https://dyalog.tv/Dyalog18/?v=paxIkKBzqBU), [slides](https://www.dyalog.com/uploads/conference/dyalog18/presentations/D08_Searches_Using_Vector_Instructions.zip)). For 1-byte elements there's also a vectorized method that works whenever `𝕨` has no duplicates: create two lookup tables that go from multiples of 8 (5-bit values, after shifting) to bytes. One is a bitmask of `𝕨`, so that a lookup gives 8 bits indicating which possible choices of the remaining 3 bits are in `𝕨`. The other gives the number of values in `𝕨` less than the multiple of 8. To find the result of Bins, look up these two bytes. Mask off the bitmask to include only bits for values less than the target, and sum it (each of these steps can be done with another lookup, or other methods depending on instruction set). The result is the sum of these two counts.

It's cheap and sometimes worthwhile to trim `𝕨` down to the range of `𝕩`. After finding the range of `𝕩`, binary cut `𝕨` to a smaller list that contains the range. Stop when the middle element fits inside the range, and search each half of `𝕨` for the appropriate endpoint of the range.

If `𝕩` is small-range, then a lookup table method is possible. Check the length of `𝕨` because if it's too large then this method is slower—binary search doesn't have to hit every element! The approach is simply to create a table of the number of elements in `𝕨` with each value, then take a prefix sum. In BQN, ``𝕩⊏+`(1+⌈´𝕩)↑/⁼𝕨``, assuming a minimum of 0.

[Partitioning](#partitioning) allows one pivot `t` from `𝕨` to be compared with all of `𝕩` at once. Although the comparison `t≤𝕩` can be vectorized, the overhead of partitioning still makes this method a little slower per-comparison than sequential binary search *when* `𝕨` *fits in L1 cache*. For larger `𝕨` (and randomly positioned `𝕩`) cache churn is a huge cost and partitioning can be many times faster. It should be performed recursively, switching to sequential binary search when `𝕨` is small enough. Unlike quicksort there is no difficulty in pivot selection: always take it from the middle of `𝕨` as in a normal binary search. However, there is a potential issue with memory. If `𝕩` is unbalanced with respect to `𝕨`, then the larger part can be nearly the whole length of `𝕩` (if it's all of `𝕩` partitioning isn't actually needed and it doesn't need to be saved). This can require close to `2⋆⁼≠𝕨` saved partitions of length `≠𝕩`, while the expected use would be a total length `≠𝕩`.

#### Interpolation search?

Binary search is the optimal approach for truly unknown data. However, if the searched array has an approximately uniform distribution, giving an approximately linear relationship between index and value, [interpolation search](https://en.wikipedia.org/wiki/Interpolation_search) uses asymptotically fewer comparisons. Because of the high overhead of index computation (a division!!), it could only ever be useful for large `𝕨`, and `𝕩` small enough that partitioning isn't viable.

Interpolation is generally held to be counterproductive because of how badly it fails for non-uniform data. But the continuous-domain equivalent, bracketed root-finding, is better studied, with hybrid approaches developed to fix this. The recently published [ITP method](https://en.wikipedia.org/wiki/ITP_Method) (2020) gets the advantages of interpolation with the same maximum number of comparisons as binary search, plus a configurable constant (even if set to 0, it can take advantage of the gap between the length and the next power of 2, but 1 is a better setting). And once the search range is small enough that memory access stops being very expensive, it should switch to binary search and avoid the division.
