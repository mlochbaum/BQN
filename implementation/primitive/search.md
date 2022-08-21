*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/search.html).*

# Implementation of search functions

This page covers the [search functions](../../doc/search.md), dyadic `⊐⊒∊`, and [self-search functions](../../doc/selfcmp.md), monadic `⊐⊒∊⍷`. Generally speaking, hash tables or plain lookup tables are the fastest way to implement these functions, because they transform the problem of searching into random access, which is something computers specialize in. In some edge cases, and when the search becomes large enough that caches can't speed up random access, other methods can be relevant.

## Reverse lookups

The classic pattern for searching is to build an index of the data to be searched, then use it for each searched-for value. This is an optimization though: the obvious way is to search for one value at a time. What I call a reverse lookup returns to this method in a sense, and is useful if the searched-in array is larger than searched-for by a factor of 2 or so.

The method is to build an index of all searched-for values, then iterate over searched-in values one at a time. For each one, check if it matches any searched-for values, update results for those accordingly, and remove that value from the index. Since each value only has one first match, the total number of removals is at most the number of searched-for values. The traversal can stop early if all these values are found, and it could also switch to a faster index if most of them are found, although I haven't tried this.

When the searched-in array is much larger, performance tends to the speed of a *set* lookup on that array, which can be several times faster than an index lookup for smaller types. The overhead for the searched-in values is usually higher than normal hash table insertion.

## Partitioning

[Robin Hood sort](https://github.com/mlochbaum/rhsort) sorts small uniform arrays quickly by considering hash tables as a way of sorting hashes. This cuts both ways: RH sort [slows down](https://github.com/mlochbaum/rhsort/blob/master/images/rand.svg) far more than other sorting methods on large arrays because of its random access patterns, and so do hash table operations. For large enough hash tables, it ought to make sense to bring in sorting-based methods in order to reduce the search size.

Of course, it's possible to implement searches using only sorting and no hashing: `∧⊸⍋⊏⍋∘⊣` with some adjustments to the binary search. A hash takes advantage of the fact that what ordering is used doesn't matter to rearrange things and get expected equal distribution of unique keys. It's usually going to be best to use a hash table as the base case, so that it's the hashes being sorted. With small element sizes and a bijective hash, only the hashes need to be compared, so the arguments can be hashed at the start and the original values discarded.

The simplest sorting technique to use is probably [partitioning](sort.md#partitioning) as in quicksort. However, I'm guessing that a [radix](sort.md#radix-sort) pass would be faster. The primary reason to avoid MSD radix for sorting is that arguments are often clustered in a small number of bins, making initial passes useless, but this only applies to hashed data if there are many duplicates. Stable partitioning is often more convenient as it ensures that equal elements are still encountered in the right order.

Partitioning doesn't really have to interact with hash insertions or lookups: after the data is partitioned at a suitable size, it will just hash faster because it only accesses part of the hash table at a time. It's also possible to save space by using a smaller hash table and doing one partition with it, then the next, and so on.

The complication is that the result comes out partitioned like the searched-for argument, and this needs to be undone at the end. I think it's best to just keep the partitioning information (first few hash bits) around and run partitioning in reverse.
