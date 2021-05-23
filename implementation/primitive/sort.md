*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/sort.html).*

# Implementation of ordering functions

The [ordering functions](../../doc/order.md) are Sort (`∧∨`), Grade (`⍋⍒`), and Bins (`⍋⍒`). Although these are well-studied—particularly sorting, and then binary search or "predecessor search"—there are many recent developments, as well as techniques that I have not found in the literature. The three functions are closely related but have important differences in what algorithms are viable. Sorting is a remarkably deep problem with different algorithms able to do a wide range of amazing things, and sophisticated ways to combine those. It is by no means solved. In comparison, Bins is pretty tame.

There's a large divide between ordering compound data and simple data. For compound data comparisons are expensive, and the best algorithm will generally be the one that uses the fewest comparisons. For simple data they fall somewhere between cheap and extremely cheap, and fancy branchless and vectorized algorithms are the best.

## On quicksort versus merge sort

Merge sort is better. It is deterministic, stable, and has optimal worst-case performance. Its pattern handling is better: while merge sort handles "horizontal" patterns and quicksort does "vertical" ones, merge sort gets useful work out of *any* sequence of runs but in-place quicksort will quickly mangle its analogue until it may as well be random.

But that doesn't mean merge sort is always faster. Quicksort seems to work a little better branchlessly. For sorting, quicksort's partitioning can reduce the range of the data enough to use an extremely quick counting sort. Partitioning is also a natural fit for binary search, where it's mandatory for sensible cache behavior with large enough arguments. So it can be useful. But it doesn't merge, and can't easily be made to merge, and that's a shame.

The same applies to the general categories of partitioning sorts (quicksort, radix sort, samplesort) and merging sorts (mergesort, timsort, multimerges). Radix sorts are definitely the best for some types and lengths, although the scattered accesses make their performance unpredictable and I think overall they're not worth it.

## On binary search

Binary searches are very easy to get wrong. Do not write `(hi+lo)/2`: it's not safe from overflows. I always follow the pattern given in the first code block [here](https://pvk.ca/Blog/2015/11/29/retrospective-on-binary-search-and-on-compression-slash-compilation/). This code will never access the value `*base`, so it should be considered a search on the `n-1` values beginning at `base+1` (the perfect case is when the number of values is one less than a power of two, which is in fact how it has to go). It's branchless and always takes the same number of iterations. To get a version that stops when the answer is known, subtract `n%2` from `n` in the case that `*mid < x`.

## Compound data

Array comparisons are expensive. The goal here is almost entirely to minimize the number of comparisons. Which is a much less complex goal than to get the most out of modern hardware, so the algorithms here are simpler.

For **Sort** and **Grade**, use Timsort. It's time-tested and shows no signs of weakness (but do be sure to pick up a fix for the bug discovered in 2015 in formal verification). Hardly different from optimal comparison numbers on random data, and outstanding pattern handling. Grade can either by selecting from the original array to order indices or by moving the data around in the same order as the indices. I think the second of these ends up being substantially better for small-ish elements.

For **Bins**, use a branching binary search: see [On binary search](#on-binary-search) above. But there are also interesting (although, I expect, rare) cases where only one argument is compound. Elements of this argument should be reduced to fit the type of the other argument, then compared to multiple elements. For the right argument, this just means reducing before doing whatever binary search is appropriate to the left argument. If the left argument is compound, its elements should be used as partitions. Then switch back to binary search only when the partitions get very small—probably one element.

## Simple data

The name of the game here is "branchless".

Sorting algorithms of interest are counting/bucket sort, [pdqsort](https://github.com/orlp/pdqsort) (some improvements of my own to be described here later), and [quadsort](https://github.com/scandum/quadsort) (good benchmarks but I haven't properly looked into it).

Vector binary search described in "Sub-nanosecond Searches" ([video](https://dyalog.tv/Dyalog18/?v=paxIkKBzqBU), [slides](https://www.dyalog.com/user-meetings/uploads/conference/dyalog18/presentations/D15_The_Interpretive_Advantage.zip)).
