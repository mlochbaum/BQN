*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/types.html).*

# Which data types are best for primitives?

BQN specifies one numeric type (in practice, 64-bit float), and one character type. However, subsets of these types can be supported to improve performance if it doesn't change the semantics. CBQN uses arrays of 1-bit booleans, 8-, 16-, and 32-bit signed integers, and 64-bit floats, as well as 8-, 16-, and 32-bit characters for the highest performance in each primitive, at the cost of extra code needed to implement all these operations. However, in another implementation, or in future fused compilation, it might make sense to choose fewer types.

Note that for float and integer arithmetic to be consistent, the IEEE float value -0 must be [eliminated](arithmetic.md#negative-zero) by making any zero value behave as positive zero. Otherwise, for example, `÷0×¯2` gives `¯∞` if the multiplication is evaluated as a float operation returning `¯0`, and `∞` if evaluated as an integer operation returning `0`. Thus CBQN's numeric type is a modification of IEEE 754.

The major advantage of using a smaller type is the decreased amount of memory used and greater SIMD bandwidth—equivalent vector instructions might process 4 32-bit elements but 8 16-bit elements, for example. The difference between integer and float types is not very significant on modern hardware (and 64-bit floats are better supported than 64-bit integers in some ways). Various primitives might improve more or less with a smaller type. As a general rule, when the element width decreases by a factor of 2:
- Arithmetic and other obviously SIMD operations get very nearly 2x faster.
- Selection including replicate and transpose gets between 1x and 2x faster.
- Searching and sorting on average get more than 2x faster but individual cases can vary.
Selection benefits less because in the general case it's forced to go through memory, which accesses one location at a time. Searching may benefit more because of various consequences of the decreased range: 16-bit and smaller values fit in direct lookup tables, 8-bit boolean tables fit in vector registers, radix sort takes half as many passes, and so on. But it's also not too expensive to do a check before searching or sorting to see if a small-range integer optimization might apply, even if the relevant type isn't used generally.

## Limited type selections

In my opinion the most powerful improvements relative to implementation effort are byte booleans and 16-bit integers. Properly supported bit booleans are a lot faster than byte booleans most of the time, but it takes a lot of work to get to that point, and the difference isn't relevant unless other types are also fast and the program uses a lot of booleans. A 16-bit type allows for a lot of easy table-based optimizations while capturing common indices and other numbers with its maximum of 32767. In contrast, 32-bit numbers aren't that much faster than 64-bit floats, and 8-bit numbers have all sorts of optimization possibilities, but they tend to be higher-effort and the maximum of 127 means the type isn't as reliable.

Here's a list of some type subsets that seem reasonable to me, using fXX and iXX for floating-point and signed integer types and bXX for boolean encoded as unsigned integer (b1 is packed 8 to a byte).
- f64 only (could flag integer-valued and boolean-valued?)
- f64, i32, b32
- f64, i32 and/or i16, b8
- f64, i32, i16, i8, b8 or b1
Notably I think bit booleans are the hardest type to benefit from and it's often easier to implement a SIMD operation on bytes than the bit-based equivalent that beats it. If SIMD is unavailable for some reason (limited hardware, strong portability requirements) then b1 could be moved up a bit; for example APL\360 used f64, i32, b1.

Unsigned integers could maybe be added to the pile. The added range is pretty marginal. Maybe more important is that they record that there are no negative values, but this could also be tracked with a flag on signed integers. Handling the various mixes of signed and unsigned types adds so much complication that I'm not sure if unsigned support is worth adding at all.

## 32-bit integers

Relative to 64-bit floats, 32-bit integers are smaller, and they're marked as integers. The second condition is important because it means now addition is truly associative! The sequential implementation of `+´` required for 64-bit floats is over 10 times slower than the SIMD i32 implementation in CBQN. It's bad enough to become a bottleneck in some programs, which is why we have `•math.Sum`, but that doesn't cover high-rank cases, and there are some other instances like `+˝˘` on short rows where an internal scan and subtraction is useful as an implementation trick. And of course when i32 values are used as indices they only need to be checked for range and not integer-ness.

When adding a limited-range type you also need arithmetic overflow checking. But it doesn't cost as much as you might think, at least with unfused arithmetic. A typical case in CBQN is around 10% overhead relative to an unchecked operation, although it can be higher particularly for multiplication. A major reason for this is that the arithmetic instruction is only a fraction of the cost for vector arithmetic: the arguments also have to be loaded, and the result stored. With a compiler fusing arithmetic, this wouldn't be the case, and some system to reduce the number of checks needed becomes important.

Small-range optimizations such as counting sort can be used after an explicit range check on 32-bit ints. J, which uses 64 bits for its integers, relies on this a lot.

## 16-bit integers

[Lookup tables](search.md#lookup-tables) for searching, and [radix sort](sort.md#radix-sort) gets very fast for all but the shortest arrays while [counting sort](sort.md#distribution-sorts) works even better for long ones. Since these methods are all based on scalar loads and stores, going down from 2 bytes to 1 doesn't improve the per-element speed much further if at all, although it can decrease constant costs and make the methods viable on shorter arguments. On short arguments you need to do [sparse initialization](search.md#sparse-and-reverse-lookups) to get good performance with 16-bit.

16-bit could even be the only integer type, although given the fairly small range and the big jump up to f64 I'd probably feel more comfortable choosing 32-bit in that role. The main benefit would be that it's pretty easy to support 16-bit with good performance across the board, where 32-bit requires hash tables which are fairly fiddly.

## 8-bit integers

Where 16-bit tables are manageable, 8-bit tables are tiny. For scalar code the only real difference is that you can simplify by skipping sparse initialization, but with a vector shuffle you can fit a [bit table](select.md#small-range-selection) in vector registers, which is good not just for member-of but also for anything that only depends on the first occurrence of each value: these first occurrences can be found with a bit table lookup, and there are at most 256 of them so the cost of actually handling them once found is bounded. It's even possible to split 256 bytes across a few registers for lookups, but shuffling together so many values is expensive and might not end up any better than scalar code, depending on hardware.

## Booleans

The two major choices for a dedicated boolean type are 1 per byte, which is easy to implement, and packed 8 per byte, which is mostly faster. But there are significant improvements merely by recording that an array is boolean. [For Replicate](replicate.md#booleans) in particular, boolean replication counts allow a branchless implementation rather than looping for each count. Multiplication and exponentiation by a boolean can be performed with bit manipulation, as can lookups with a boolean index, including indexing and boolean-scalar arithmetic. Scans like `` ∧` `` can shortcut, sorting is just a sum if it comes up, and so on.

In fused arithmetic, it's often better not to pack booleans: for example, `a+a>5` is just a vector compare and a subtract in say AVX2 (ignoring overflow). It would take several boolean operations for the inefficiency of doing them in a wide type to outweigh the cost of packing and unpacking.

### Byte booleans

Are [1-byte integers](#8-bit-integers) plus the knowledge that they're boolean-valued, not much to add. If there's a case where you want them packed, maybe to use as a lookup table index, converting is fairly fast with vector instructions.

### Bit booleans

Selecting from a packed boolean array is generally slower because picking the correct bit out of each byte and re-packing those bits takes longer. However, for large enough arrays packed bits may fit in a lower cache level and end up faster, and for small ones a 256-bit table [fits in vector registers](select.md#small-range-selection) (although byte booleans can easily be packed to use this method).

Multi-dimensional arrays of booleans present all sorts of problems, stemming from the fact that the start and end of each cell might not be byte-aligned. Of course, you could try padding to align them, but it's inconvenient for things like reshaping and index arithmetic; I'm not aware of any attempts to help sort out whether such things are a problem in practice. CBQN does temporarily pad for some heaver operations like sorting, but mostly our strategy has been to research bitwise techniques and fight through it. It's worked out all right.

## Explicit array types?

Many languages let the programmer decide on the type to use, resulting in more predictable performance. These include statically-typed languages as well as array frameworks like Julia and NumPy where arrays have an explicit type but it's tracked dynamically. I argued [here](../compile/intro.md#and-which-is-better) that this doesn't necessarily lead to ideal performance even when the programmer chooses types well, as the program may call for a dynamic approach where a smaller type is used most of the time, but occasionally a larger type is needed for correctness. In practice, low-level programmers rarely choose a 2-byte type outside of specific domains, but CBQN uses this type very frequently. A factor that frees CBQN to optimize in this way is its emphasis on bulk operations on immutable arrays. Changing a single element can force an array into a larger type, which other languages might not want for overall performance, latency, or memory management reasons.

Could an array language combine static types with dynamic optimization? Possibly, but each combination of semantic type and representation type (for example, 32-bit unsigned ints represented as 8-bit unsigned) behaves differently, which makes dispatch very complicated. Addition of numeric arrays has to first examine the semantic types to decide the result's semantic type, then compare to the representation types to see whether overflow is possible and what sort of wrapping, if any, should apply, then dispatch to an appropriate implementation. I think this is a lot of work for very marginal gains; if it's necessary to provide explicit types for uses that want wrapping arithmetic, they could just be stored at the specified type. It may also be better, both for implementer and programmer sanity, to require any type conversions to be explicit.
