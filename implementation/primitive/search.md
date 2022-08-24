*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/search.html).*

# Implementation of search functions

This page covers the [search functions](../../doc/search.md), dyadic `⊐⊒∊`, and [self-search functions](../../doc/selfcmp.md), monadic `⊐⊒∊⍷`. Generally speaking, hash tables or plain lookup tables are the fastest way to implement these functions, because they transform the problem of searching into random access, which is something computers specialize in. In some edge cases, and when the search becomes large enough that caches can't speed up random access, other methods can be relevant.

## Lookup table

For the purposes of these notes, a lookup table is storage, indexed by some key, that contains at most one entry per key. This means reading the value for a given key is a simple load—differing from a hash table, which might have collisions where multiple keys indicate the same entry. Lookup table operations are very fast, but the entire table needs to be initialized and stay in cache. So they're useful when the number of possible values (that is, size of the table) is small: a 1-byte or 2-byte type, or small-range integers.

For example, a lookup table algorithm for dyadic `⊐` might traverse `𝕨`, writing each value's index to the table. Doing this step in reverse index order makes sure the lowest index "wins". Similarly, empty entries must be initialized to `≠𝕨` beforehand. Then the result is `𝕩⊏t` where `t` is the table constructed this way. A nonzero minimum value can be handled for free by subtracting it from the table pointer.

Set operations can be handled with a packed bit table, but reading a bit is slower so this should be done only if the space savings are really needed.

## Reverse lookups

The classic pattern for searching is to build an index of the data to be searched, then use it for each searched-for value. This is an optimization though: the obvious way is to search for one value at a time. What I call a reverse lookup returns to this method in a sense, and is useful if the searched-in array is larger than searched-for by a factor of 2 or so.

The method is to build an index of all searched-for values, then iterate over searched-in values one at a time. For each one, check if it matches any searched-for values, update results for those accordingly, and remove that value from the index. Since each value only has one first match, the total number of removals is at most the number of searched-for values. The traversal can stop early if all these values are found, and it could also switch to a faster index if most of them are found, although I haven't tried this.

When the searched-in array is much larger, performance tends to the speed of a *set* lookup on that array, which can be several times faster than an index lookup for smaller types. The overhead for the searched-in values is usually higher than normal hash table insertion.

## Partitioning

[Robin Hood sort](https://github.com/mlochbaum/rhsort) sorts small uniform arrays quickly by considering hash tables as a way of sorting hashes. This cuts both ways: RH sort [slows down](https://github.com/mlochbaum/rhsort/blob/master/images/rand.svg) far more than other sorting methods on large arrays because of its random access patterns, and so do hash table operations. For large enough hash tables, it ought to make sense to bring in sorting-based methods in order to reduce the search size.

Of course, it's possible to implement searches using only sorting and no hashing: `∧⊸⍋⊏⍋∘⊣` with some adjustments to the binary search. A hash takes advantage of the fact that what ordering is used doesn't matter to rearrange things and get expected equal distribution of unique keys. It's usually going to be best to use a hash table as the base case, so that it's the hashes being sorted. With small element sizes and a bijective hash, only the hashes need to be compared, so the arguments can be hashed at the start and the original values discarded.

One option is [partitioning](sort.md#partitioning) as in quicksort, but the unstable version doesn't work for many functions, and comparing with a pivot is wasted effort as top bits can be used directly. Stable [radix](sort.md#radix-sort) passes are ideal here. However, they do use a lot of extra memory: twice the size of the hashed array (or equal to it if it can be reused). To undo a radix sort in a cache-friendly way, the original hash bits need to be kept around to retrace the steps. Even in cases where the original indices are known, traversing the radix-ed values and writing back to these indices makes many loops around the original array, moving too quickly for the cache to keep up.

Partitioning doesn't really have to interact with hash insertions or lookups: after the data is partitioned at a suitable size, it will just hash faster because it only accesses part of the hash table at a time. It's also possible to save space by using a smaller hash table and doing one partition with it, then the next, and so on.

There are a few tricks to avoid having to re-initialize the table on each pass. This is a big deal because it means a very low load factor can be used, which allows for faster hash or even a lookup table! First, and more generally, the table can be cleaned up *after* a pass by walking through the elements again (possibly in reverse for some hash designs). Second, if enough data is stored in the hash table to distinguish one pass from the next, then values from previous passes can be interpreted as empty so that no re-initialization is necessary.
