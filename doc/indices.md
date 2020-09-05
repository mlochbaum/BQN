*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/indices.html).*

# Indices

One-dimensional arrays such as K lists or Python arrays have only one kind of index, a single number that refers to an element. For multidimensional arrays using the [leading axis theory](leading.md), there are several types of indexing that can be useful. Historically, nested APL designs have equivocated between these, which I believe can lead to subtle errors when programming. BQN focuses on single-number (atomic) indices, which can refer to list elements or array major cells (or more generally indexing along any particular axis). When using atomic indices to select elements, the indexed array has to be a list. In contrast, elements of any array can be indicated by list indices with length equal to that array's rank. Only two BQN primitives use these list indices: Range (`↕`), which returns an array of them if given a list argument, and Pick (`⊑`), where the depth-1 components of an array left argument are list indices.

The following functions take or return indices. Except where marked, the indices are in the result; this is by far the most common type of index use. `⊔` is given two rows as it falls into both cases. Note that in the result case, there is usually no possibility for the programmer to select the format of indices. Instead, the language should be carefully designed to make sure that the kind of index returned is as useful as possible.

| Monad | Dyad | Where   | How
|-------|------|---------|--------------------------
|  `↕`  |      |         | Element scalar or list
|  `/`  |      |         | Element scalar
|  `⊔`  |      |         | Element scalar
|  `⊔`  | `⊔`  | `𝕩`/`𝕨` | Along-axis scalar
|       | `⊑`  | `𝕨`     | Element list
|  `⍋`  | `⍋`  |         | Major cell scalar
|  `⍒`  | `⍒`  |         | Major cell scalar
|       | `⊐`  |         | Major cell scalar
|       | `⊒`  |         | Major cell scalar
|       | `⊏`  | `𝕨`     | Major cell or along-axis scalar
|  `⍉`  |      |         | Axis scalar

Dyadic Transpose (`⍉`) uses indices into the right argument axes in its left argument, but since array shape is 1-dimensional, there is only one sensible choice for this, a single number.

# Element indices

In general, the index of an element of an array is a list whose length matches the array rank. It is also possible to use a number for an index into a list, as the list index is a singleton, but this must be kept consistent with the rest of the language. NARS-family APLs make the Index Generator (`↕` in BQN) return a numeric list when the argument has length 1 but a nested array otherwise. This means that the depth of the result depends on the shape of the argument, inverting the typical hierarchy. BQN shouldn't have such an inconsistency.

Functions `↕`, `/`, `⊔`, and `⊑` naturally deal with element indices. Each of these can be defined to use list indices. However, this usually rules out the possibility of using scalar indices, which makes these functions harder to use both with generic array manipulation and with the major cell indices discussed in the next section. For this reason BQN restricts `⊔` and monadic `/` to use atomic indices, which comes with the requirement that the arguments to monadic `/` and `⊔`, and the result of monadic `⊔`, must be lists. For dyadic `⊔` the depth-1 elements of the left argument are lists of indices along axes of the result; see [the documentation](group.md#multidimensional-grouping). The restriction that comes from using single-number indices is that all axes must be treated independently, so that for example it isn't possible to group elements along diagonals without preprocessing. However, this restriction also keeps Group from having to use an ordering on list indices.

Unlike `/` and `⊔`, `↕` and `⊑` do use list element indices. For `↕` this is because the output format can be controlled by the argument format: if passed a single number, the result uses atomic indices (so it's a numeric list); if passed a list, it uses list indices and the result has depth 2 (the result depth is always one greater than the argument depth). For `⊑`, list indices are chosen because `⊏` handles scalar indices well already. When selecting multiple elements from a list, they would typically have to be placed in an array, which is equivalent to `⊏` with a numeric list left argument. An atomic left argument to `⊑` is converted to a list, so it can be used to select a single element if only one is wanted. To select multiple elements, `⊑` uses each depth-1 array in the left argument as an index and replaces it with that element from the right argument. Because this uses elements as elements (not cells), it is impossible to have conformability errors where elements do not fit together. Ill-formed index errors are of course still possible, and the requirements on indices are quite strict. They must exactly match the structure of the right argument's shape, with no scalars or higher-rank arrays allowed. Atoms also cannot be used in this context, as it would create ambiguity: is a one-element list an index, or does it contain an index?

# Major cell indices

One of the successes of the [leading axis model](https://aplwiki.com/wiki/Leading_axis_theory) is to introduce a kind of index for multidimensional arrays that is easier to work with than list indices. The model introduces [cells](https://aplwiki.com/wiki/Cell), where a cell index is a list of any length up to the containing array's rank. General cell indices are discussed in the next section; first we introduce a special case, indices into major cells or ¯1-cells. These cells naturally form a list, so the index of a major cell is a single number. These indices can also be considered indices along the first axis, since an index along any axis is a single number.

Ordering-based functions `⍋`, `⍒`, `⊐`, and `⊒` only really make sense with major cell indices: while it's possible to order other indices as ravel indices, this probably isn't useful from a programming standpoint. Note that `⊐` only uses the ordering in an incidental way, because it's defined to return the *first* index where a right argument cell is found. A mathematician would be more interested in a "pre-image" function that returns the set of all indices where a particular value appears. However, programming usefulness and consistency with the other search functions makes searching for the first index a reasonable choice.

Only one other function—but an important one!—deals with cells rather than elements: `⊏`, cell selection. Like dyadic `↑↓↕⌽⍉` (depth 0) and `/⊔` (depth 1), Select allows either a simple first-axis case where the left argument has depth 1 or less (a depth-0 argument is automatically enclosed), and a multi-axis case where it is a list of depth-1 elements. In each case the depth-1 arrays index along a single axis.

# General cell indices

BQN does not use general cell indices directly, but it is useful to consider how they might work, and how a programmer might implement functions that use them in BQN if needed. The functions `/`, `⊔`, and `⊏` are the ones that can work with indices for multidimensional arrays but don't already. Here we will examine how multidimensional versions would work.

A cell index into an array of rank `r` is a numeric list of length `l≤r`, which then refers to a cell of rank `r-l`. In BQN, the cell at index `i` of array `a` is `i<¨⊸⊏a`.

Because the shape of a cell index relates to the shape of the indexed array, it makes sense not to enclose cell indices, instead treating them as rows of an index array. A definition for `⊏` for depth-1 left arguments of rank at least 1 follows: replace each row of the left argument with the indexed cell of the right, yielding a result with the same depth as the right argument and shape `𝕨((¯1↓⊣)∾(¯1↑⊣)⊸↓)○≢𝕩`.

To match this format, Range (`↕`) could be changed to return a flat array when given a shape—what is now `>↕`. Following this pattern, Indices (`/`) would also return a flat array, where the indices are rows: using the modified Range, `⥊/↕∘≢`. Here the result cannot retain the argument's array structure; it is always a rank-2 list of rows.

The most interesting feature would be that `⊏` could still allow a nested left argument. In this case each element of the left argument would be an array with row indices as before. However, each row can now index along multiple axes, allowing some adjacent axes to be dependent while others remain independent. This nicely unifies scatter-point and per-axis selection, and allows a mix of the two. However, it doesn't allow total freedom, as non-adjacent axes can't be combined except by also mixing in all axes in between.

Group (`⊔`) could accept the same index format for its index argument. Each depth-1 array in the left argument would correspond to multiple axes in the outer result array, but only a single axis in the argument and inner arrays. Because the ravel ordering of indices must be used to order cells of inner arrays, this modification is not quite as clean as the change to Select. It's also not so clearly useful, as the same results can be obtained by using atomic indices and reshaping the result.

Overall it seems to me that the main use of cell indices of the type discussed here is for the Select primitive, and the other cases are somewhat contrived an awkward. So I've chosen not to support it in BQN at all.
