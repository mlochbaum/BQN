*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/indices.html).*

# Indices

One-dimensional arrays like you might find in Python, Java, or K have only one kind of index, a single number that refers to an element. For [multidimensional arrays](array.md) using the [leading axis theory](leading.md), there are several types of indexing that can be useful. Historically, nested APL designs have equivocated between these, which I believe can lead to subtle errors when programming. BQN focuses on single-number (atomic) indices, which can refer to list elements or array major cells (or more generally indexing along any particular axis). When using atomic indices to select elements, the indexed array has to be a list. An element of an arbitrary array can be indicated by an index list as long as that array's rank. Only two BQN primitives use these index lists: [Range](range.md) (`↕`), which returns an array of them if given a list argument, and [Pick](pick.md) (`⊑`), where the depth-1 components of an array left argument are index lists.

The following functions take or return indices. Except where marked, the indices are in the result; this is by far the most common type of index use. [Group](group.md) (`⊔`) is given two rows as it falls into both cases. Note that in the result case, there is usually no possibility for the programmer to select the format of indices. Instead, the language should be carefully designed to make sure that the kind of index returned is as useful as possible.

| Monad | Dyad | Where   | How
|-------|------|---------|--------------------------
|  `↕`  |      |         | Element number or list
|  `/`  |      |         | Element number
|  `⊔`  |      |         | Element number
|  `⊔`  | `⊔`  | `𝕩`/`𝕨` | Along-axis number
|       | `⊑`  | `𝕨`     | Element list
|  `⍋`  | `⍋`  |         | Major cell number
|  `⍒`  | `⍒`  |         | Major cell number
|       | `⊐`  |         | Major cell number
|       | `⊒`  |         | Major cell number
|       | `⊏`  | `𝕨`     | Major cell or along-axis number
|       | `⍉`  | `𝕨`     | Axis number

In [Reorder Axes](transpose.md#reorder-axes) (`⍉`), `𝕨` is made up of indices into axes of `𝕩`. Since array shape is 1-dimensional, there is only one sensible choice for these elements, a single number each.

## Element indices

In general, the index of an element of an array is a list whose length matches the array rank. It is also possible to use a number for an index *into* a list, as the index list is a singleton, but this must be kept consistent with the rest of the language. NARS-family APLs make the Index Generator (`↕` in BQN) return a numeric list when the argument has length 1 but a nested array otherwise. This means that the depth of the result depends on the shape of the argument, inverting the typical hierarchy. BQN shouldn't have such an inconsistency.

Functions [Range](range.md) (`↕`), [Indices](replicate.md) (`/`), [Group](group.md) (`⊔`), and [Pick](pick.md) (`⊑`) naturally deal with element indices. Each of these can be defined to use index lists. However, this usually rules out the possibility of using atomic indices, which makes these functions harder to use both with generic array manipulation and with the major cell indices discussed in the next section. For this reason BQN restricts `⊔` and `/` to use atomic indices, which comes with the requirement that the arguments to Group and Indices, and the result of Group Indices, must be lists. [For dyadic Group](group.md#multidimensional-grouping) the depth-1 elements of `𝕨` are arrays of indices along axes of the result. This means each axis of `𝕩` can only be related to one axis of the result.

Unlike `/` and `⊔`, `↕` and `⊑` do use list element indices. For `↕` this is because the output format can be controlled by the argument format: if passed a single number, the result uses atomic indices (so it's a numeric list); if passed a list, it uses index lists and the result has depth 2 (the result depth is always one greater than the argument depth). For `⊑`, index lists are chosen because [Select](select.md) (`⊏`) handles atomic indices well already. When selecting multiple elements from a list, they would typically have to be placed in an array, which is equivalent to `⊏` with a numeric list `𝕨`. Pick can convert `𝕨` from an atom to a list, so it's still convenient to select a single element. To select multiple elements, `⊑` uses each depth-1 array in `𝕨` as an index and replaces it with that element from the right argument. Because this uses elements as elements, not cells, it's impossible to have conformability errors where elements don't fit together. Unfortunately, atoms can't be used in this context, as it would create ambiguity: is a one-element list an index, or does it contain an index?

## Major cell indices

One of the successes of the [leading axis model](https://aplwiki.com/wiki/Leading_axis_theory) is to introduce a kind of index for multidimensional arrays that is easier to work with than index lists. The model introduces [cells](https://aplwiki.com/wiki/Cell), where a cell index is a list of any length up to the containing array's rank. General cell indices are discussed in the next section; first we introduce a special case, indices into major cells or ¯1-cells. These cells are arranged along just the first axis, so the index of a major cell is one number.

[Ordering](order.md) functions `⍋⍒` and [search](search.md)/[self-search](selfcmp.md) functions `⊐⊒` that depend on cell ordering only really make sense with major cell indices: while other indices have an ordering, it's not very natural. Note that Classify/Index-of (`⊐`) only uses the ordering in an incidental way, because it's defined to return the *first* index where a cell in `𝕩` is found. A pure mathematician would be more interested in a "pre-image" function that returns the set of all indices where a particular value appears. However, programming usefulness and consistency with the other search functions make searching for the first index a reasonable choice.

Only one other function—but an important one!—deals with cells rather than elements: [Select](select.md) (`⊏`). Select [allows](leading.md#multiple-axes) either a simple first-axis case where `𝕨` has depth 1 or less (a depth-0 argument is automatically enclosed), and a multi-axis case where it's a list of depth-1 elements. In each case the depth-1 arrays index along a single axis.

## General cell indices

BQN doesn't use general cell indices directly, but it's useful to consider how they might work, and how a programmer might implement functions that use them if needed. The functions `/`, `⊔`, and `⊏` are the ones that can work with indices for multidimensional arrays but don't already, so let's look at how that would be defined.

A cell index into an array of rank `r` is a numeric list of length `l≤r`, which refers to a [cell](https://aplwiki.com/wiki/Cell) of rank `r-l`: the cell at index `i` of array `a` is `i<¨⊸⊏a`.

Because indices for cells of the same rank have the same shape, it makes sense to make multiple k-cell indices the rows of an array instead of enclosing them. Here's a definition for Select (`⊏`) when `𝕨` is an array of numbers with rank 1 or more: replace each row of `𝕨` with the cell of `𝕩` that it indicates, yielding a result with the same depth as `𝕩` and shape `(¯1↓≢𝕨)∾(¯1⊑≢𝕨)↓≢𝕩`.

To match this format, Range (`↕`) could be changed to return a flat array when given a shape `𝕩`—what is now `>↕`. Following this pattern, Indices (`/`) would also return a flat array, where the indices are rows: using the modified Range, `⥊/↕∘≢`. Here the result cannot retain the argument's array structure; it's always a rank-2 list of rows.

The most interesting feature would be that Select could still allow `𝕨` to be nested. In this case each element of `𝕨` would be an array with cell indices for its rows as before. However, each row can now index along multiple axes, allowing some adjacent axes to be dependent while others remain independent. This nicely unifies scatter-point and per-axis selection, and allows a mix of the two. However, it doesn't allow total freedom, as non-adjacent axes can't be combined except by also mixing in all axes in between.

Group (`⊔`) could accept the same index format for its index argument `𝕨`. Each depth-1 array in `𝕨` would correspond to multiple axes in the outer result array, but only a single axis in `𝕩` and inner arrays. Because the index ordering of indices must be used to order cells of inner arrays, this modification is not quite as clean as the change to Select. It's also not so clearly useful, as the same results can be obtained by using atomic indices and reshaping the result.

Overall it seems to me that the main use of cell indices of the type discussed here is for the Select primitive, and the other cases are somewhat contrived and awkward. So I've chosen not to support it in BQN at all.
