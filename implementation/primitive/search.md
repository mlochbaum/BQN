*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/search.html).*

# Implementation of search functions

This page covers the [search functions](../../doc/search.md), dyadic `⊐⊒∊`, and [self-search functions](../../doc/selfcmp.md), monadic `⊐⊒∊⍷`. Generally speaking, hash tables or plain lookup tables are the fastest way to implement these functions, because they transform the problem of searching into random access, which is something computers specialize in. In some edge cases, and when the search becomes large enough that caches can't speed up random access, other methods can be relevant.

Searching is closely related to [sorting](sort.md). I've found it helpful to think of a search function as an ordered lookup according to an unspecified order. The advantage over a predefined order is that the order can be shuffled with a hash function to randomize the distribution. The fact that the wanted result is in the original argument order, not sorted, also means that sparse tables are more effective—there is never any need to traverse the table to pack ordered values as in sorting.

## Small arguments

When one argument to a search function is small, it's best to use a linear-time method—that is, linear in both arguments, O(mn). The simplest versions:

- For self-search, branchlessly compare to all previous elements, or use insertion sort.
- With small searched-for, search for each element one at a time.
- With small searched-in, compare each one to all searched-for elements and accumulate.

Each of these easily allows for SIMD comparison. A more effective use of SIMD (unless the size of the small argument is 1, up to maybe 3) is a vector binary search as presented in the first half of my "Sub-nanosecond Searches" talk ([video](https://dyalog.tv/Dyalog18/?v=paxIkKBzqBU), [slides](https://www.dyalog.com/uploads/conference/dyalog18/presentations/D08_Searches_Using_Vector_Instructions.zip)). This search of sorted values is performed by using shuffle instructions to independently select a pivot for each value, and adding a pivot index bit based on the result of comparing. It can be used as a [reverse lookup](#sparse-and-reverse-lookups) as well, performing a non-SIMD update whenever a match is found. Multiple registers can be searched, but each one has to be touched at every step leading to O(mn) asymptotic performance despite the binary search.

## Lookup tables

For the purposes of these notes, a lookup table is storage, indexed by some key, that contains at most one entry per key. This means reading the value for a given key is a simple load—differing from a hash table, which might have collisions where multiple keys indicate the same entry. Lookup table operations are very fast, but only if the table remains in cache. So they're useful when the number of possible values (that is, size of the table) is small: a 1-byte or 2-byte type, or small-range integers. You might expect the entire table has to be initialized, but it doesn't always: see [sparse lookups](#sparse-and-reverse-lookups).

For example, a lookup table algorithm for dyadic `⊐` might traverse `𝕨`, writing each value's index to the table. Doing this step in reverse index order makes sure the lowest index "wins". Similarly, empty entries must be initialized to `≠𝕨` beforehand. Then the result is `𝕩⊏t` where `t` is the table constructed this way. A nonzero minimum value can be handled for free by subtracting it from the table pointer.

Set operations can be handled with a packed bit table, but reading a bit is slower so this should be done only if the space savings are really needed. With sparse lookups this seems to be very rare.

A 1-byte lookup can be packed into vector registers for extra-fast searching. To look up a byte, select the appropriate byte from the table with the top 5 bits, and a mask from another table with the bottom 3. Put these together and pack into bits with compare-movemask.

## Hash tables

A hash table is a more sophisticated design where there are more possible keys than table entries. For good performance it depends on not having too many *actual* keys packed into a small space, which is why this method is named after the hash function. If the data is expected to be random then no hash function is needed (the identity function can be used), but that's no good for search functions. Hash tables generally degrade to the performance of a linear lookup if the hash is defeated, so it's ideal to have a way to escape and use a sorting-based method if too many hashes collide.

Hashing is really the only way to get a performant lookup on arbitrary data. For 2-byte and small-range data, lookups are better, and lookup with [partitioning](#partitioning) is better for 4-byte arguments that outgrow the cache (>1e5 elements to be hashed or so).

While hash tables are well studied, almost all the work is focused on large persistent tables, meaning that they're not too suited for a one-shot search function. Abseil's [flat\_hash\_map](https://github.com/abseil/abseil-cpp/blob/master/absl/container/flat_hash_map.h) is fine, I guess. Roger Hui's [Index-Of, a 30-Year Quest](https://www.jsoftware.com/papers/indexof/indexof.htm) works as an introduction to hashing in APL, although it has begun to suffer from the small number of years in places, and some details have serious issues (with a power-of-two table size, multiplying by a prime causes high bits to be lost and so is hardly better than no hash). The second half of my "Sub-nanosecond Searches" talk ([video](https://dyalog.tv/Dyalog18/?v=paxIkKBzqBU), [slides](https://www.dyalog.com/uploads/conference/dyalog18/presentations/D08_Searches_Using_Vector_Instructions.zip)) covers a difficult 4-byte design that's very good for membership and negative lookups (in particular, it's perfect for the reverse lookup as described in the next section).

I'd take the following choices as a given for an array language hash design:
- Power-of-two size
- Open addressing
- Linear probing

The main cost for larger data is the hashing itself; [wyhash](https://github.com/wangyi-fudan/wyhash) appears to be one of the best choices at the time of writing. 4- and 8-byte lookups are where all the fancy optimizations are wanted. Hashes on these fixed sizes should be reversible and are often called mixing functions in the literature. A CRC instruction makes a good one if available. Reversibility means they can be stored in the table for comparison instead of the original data.

### Resizing hash tables

When performing a one-shot array operation, the maximum hash table size needed is known in advance. However, if the array to be hashed doesn't have many unique elements, allocating a table this large will have extra costs because it needs to be initialized and the hash probes won't cache as well (they're random by design!). Starting with a smaller hash table and resizing mitigates these costs. But! Getting the resizing policy right is difficult, and any way you do it there's going to be some overhead from resizing when the large size is needed. And hash tables are already somewhat adaptive to small numbers of unique values, because these hit fewer memory regions, avoiding cache penalties. With a factor of 2 to 4 upside, this is not a very high-value use of time.

Hash model resizing is usually based on a counter of the number of values in the hash. I like using a collision counter instead, because tracking it has the same cost (possibly a little less) and can protect from a compromised hash function. Whenever a value is inserted, add the difference between the index computed from the hash and the index it was actually inserted at. This is the number of collisions for that value and measures the cost of inserting or looking it up. It can be checked for a resizing condition periodically, since checking at every step would be expensive.

#### Resizing math

Here's a model for when to resize in a self-search function, assuming the average number of collisions increases linearly as values are inserted. Suppose we've reached position `i` of `n` and observed an average of `c÷2` collisions per element. When is resizing now better than resizing later? There will be two changes: cache-related costs which we'll say will change by `d` per element, and collision related costs which will change by `c` per element (times a constant; we can absorb this into `d` and later `s` as well). So it's better to switch now instead of a step later as soon as `c > d`.

But resizing also incurs a one-time cost. We'll call it `s`, which is some coefficient times the table size, and we now need to look at all future hashes to see if the averaged cost `s÷n-i` per element is worth it. We assume the collision-related costs will go down by a constant factor, but the future cost remaining is proportional to an adjustment factor `(i+n)÷i`, because with linearly increasing collisions we'd average `i÷2` before and `(i+n)÷2` after the current position. Setting `r←n-i`, this is `(2n-r)÷(n-r)`, or `2×(1-r÷2n)÷(1-r÷n)`. Now we want to resize at some point if:

    0 > d - (c×(1-r÷2n)÷(1-r÷n)) + s÷r

Solve for `c`, and drop several terms to give an approximation that's exact at `r=0` and larger when `r>0`. This is good because the assumption of linearly increasing `c` is definitely not always going to hold so being more hesitant to resize early is good.

    c > (d + s÷r) × (1 - r÷n)÷(1 - r÷2n)
      > (d + s÷r) × (1 - r÷n)×(1 + r÷2n)
      > (d + s÷r) × (1 - r÷2n)
      = d + (-d×r÷2n) + (s÷r) - s÷2n
      > d + (s÷r) - s÷2n
      = d + s×(2n-r)÷(2n×r)
      = d + s×(n+i)÷(2n×r)

Some rearrangement gives this form, which doesn't divide by any variables. `ct` is the total number of collisions, `i×c`.

    (r × ct-d×i) > i×(n+i)×s÷n

Now you have two parameters to tune, `d` and `s`. And the coefficient for `d` depends on the current size of the table. Try not to go insane.

## Sparse and reverse lookups

The classic pattern for searching is to build an index of the data to be searched, then use it for each searched-for value. This is an optimization though: the obvious way is to search for one value at a time. Two methods flip this around in a sense, beginning with the searched-for array. Of course this requires that there *is* such an array, that is, all lookups are done at one time. So these methods work for one-shot lookups as in array languages but not persistent search structures used in others.

| Biggest      | Method         | Pattern
|--------------|----------------|---------
| Searched-for | Normal lookup  | table - in - for
| Searched-in  | Reverse lookup | table - for - in - maybe for/table
| Table        | Sparse lookup  | for - in - for

A sparse lookup is mostly useful for lookup tables, and is useful when the table size is much larger than the data. The idea is that the main cost would be initializing the table, but it will only be read to look up searched-for values. So initialize according to the searched-for array, *then* write searched-in values and look up searched-for ones (in a self-search function these last two are combined, making this method even more effective). It's not so great for hash tables because probing means it's not enough to initialize more than one value, and anyway the hash table can be sized to avoid a large initialization cost.

A reverse lookup has a similar pattern but does require table initialization. It works for lookup tables, but is more impressive for hashes, and is useful if the searched-in array is larger than searched-for by a factor of 2 or so. The method is to build an index of all searched-for values, then iterate over searched-in values one at a time. For each one, check if it matches any searched-for values, update results for those accordingly, and remove that value from the index. Since each value only has one first match, the total number of removals is at most the number of searched-for values. The traversal can stop early if all these values are found, and it could also switch to a faster index if most of them are found, although I haven't tried this.

As the searched-in array gets larger in a reverse lookup, ideal performance tends to the speed of a *set* lookup on that array, which can be several times faster than an index lookup for smaller types. Since each searched-for value can only be found once, this performance is achieved with a set lookup followed by a slow path that does an index lookup (other methods might be better depending on table specifics, but this one is general). However, the overhead for the searched-for values is usually higher than normal hash table insertion.

## Partitioning

[Robin Hood sort](https://github.com/mlochbaum/rhsort) sorts small uniform arrays quickly by considering hash tables as a way of sorting hashes. This cuts both ways: RH sort [slows down](https://github.com/mlochbaum/rhsort/blob/master/images/rand.svg) far more than other sorting methods on large arrays because of its random access patterns, and so do hash table operations. For large enough hash tables, it ought to make sense to bring in sorting-based methods in order to reduce the search size. As in quicksort, partitioning has two advantages in that it reduces the number of values to be compared and also their range. It does have a lot of memory usage because entries need to be copied rather than swapped for stability, and ordering data has to be kept around.

[Partitioning](sort.md#partitioning) as in quicksort is possible, but I think stable [radix](sort.md#radix-sort) passes are almost always better. The typical problem with radix passes on high bits is that they might distribute values unevenly, but the values will either be searched with constant memory (lookup table) or redistributed (hash table). To undo a radix sort in a cache-friendly way, the original hash bits need to be kept around to retrace the steps. Even in cases where the original indices are known, traversing the radix-ed values and writing back to these indices makes many loops around the original array, moving too quickly for the cache to keep up.

For 4-byte values, two 8-bit passes reduce the range to two bytes, lookup table range. With [sparse](#sparse-and-reverse-lookups) initialization, this is fairly fast, even for sizes under 100 elements. But hash tables are better until cache effects of a large table kick in. At least partitioning is a good backup for cases where the hash function fails. And one advantage it does have over hash tables is that for small-range data it might be possible to skip one or both rounds of radix passes. I haven't found a way to make it work for Classify (`⊐`). Deriving it from `⊐˜` requires a cache-incoherent final pass, so `∊⊸⊐` might be the best option.

Partitioning doesn't really have to interact with hash insertions or lookups: after the data is partitioned at a suitable size, it will just hash faster because it only accesses part of the hash table at a time. But it's better to use a smaller hash table, doing one partition with it, then the next, and so on. There are a few tricks to avoid having to re-initialize the table on each pass. This is a big deal because it means a very low load factor can be used, which speeds things up! First, and more generally, the table can be cleaned up *after* a pass by walking through the elements again (possibly in reverse for some hash designs). Second, if enough data is stored in the hash table to distinguish one pass from the next, then values from previous passes can be interpreted as empty so that no re-initialization is necessary.
