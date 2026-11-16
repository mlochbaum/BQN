*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/inferred.html).*

# Specification: BQN inferred properties

BQN includes some simple deductive capabilities: detecting the type of empty array elements, the result of an empty reduction, and the Undo (`⁼`) and Under (`⌾`) modifiers. These tasks are a kind of proof-based or constraint programming, and can never be solved completely (some instances will be undecidable) but can be solved in more instances by ever-more sophisticated algorithms. To allow implementers to develop more advanced implementations while offering some stability and portability to programmers, two kinds of specification are given here. First, constraints are given on the behavior of inferred properties. These are not exact and require some judgment on the part of the implementer. Second, behavior for common or useful cases is specified more precisely. Non-normative suggestions are also given as a reference for implementers.

For the specified cases, the given functions and modifiers refer to those particular representations. It is not necessary to detect equivalent representations, for example to reduce `(+-×)⁼` to `∨⁼`. However, it is necessary to identify computed functions and modifiers: for example `F⁼` when the value of `F` in the expression is `∨`, or `(1⊑∧‿∨)⁼`.

Failing to compute an inferred property for a function or array as it's created cannot cause an error. An error can only be caused when the missing inferred property is needed for a computation.

## Identities

When monadic Fold (`´`) or Insert (`˝`) is called on an array of length 0, BQN attempts to infer a right identity value for the function in order to determine the result. A right identity value for a dyadic function `𝔽` is a value `r` such that `e≡e𝔽r` for any element `e` in the domain. For such a value `r`, the fold `r 𝔽´ l` is equivalent to `𝔽´ l` for a non-empty list `l`, because the first application `(¯1⊑l) 𝔽 r` gives `¯1⊑l`, which is the starting point when no initial value is given. It's thus reasonable to define `𝔽´ l` to be `r 𝔽´ l` for an empty list `l` as well, giving a result `r`.

For Fold, the result of `𝔽´` on an empty list is defined to be a right identity value for the *range* of `𝔽`, if exactly one such value exists. If an identity can't be proven to uniquely exist, then an error results.

For Insert, `𝔽˝` on an array of length 0 is defined similarly, but also depends on the cell shape `1↓≢𝕩`. The required domain is the arrays of that shape that also lie in the range of `𝔽` (over arbitrary arguments, not shape-restricted ones). Furthermore, an identity may be unique among all possible arguments as in the case of Fold, or it may be an array with shape `1↓≢𝕩` and be unique among arrays with that shape. For example, with cell shape `3‿2`, all of `0`, `2⥊0`, and `3‿2⥊0` are identities for `+`, but `3‿2⥊0` can be used because it is the only indentity with shape `3‿2`, while the other identities aren't unique and can't be used.

Identity values for the arithmetic primitives below must be recognized. Under Fold, the result is the given identity value, while under Insert, it is the identity value reshaped to the argument's cell shape.

| Id   | Fn  | Fn  | Id   |
|-----:|:---:|:---:|-----:|
|  `0` | `+` | `-` |  `0` |
|  `1` | `×` | `÷` |  `1` |
|  `1` | `⋆` | `¬` |  `1` |
|  `∞` | `⌊` | `⌈` | `¯∞` |
|  `0` | `∨` | `∧` |  `1` |
|  `0` | `≠` | `=` |  `1` |
|  `0` | `>` | `≥` |  `1` |

Additionally, the identity of `∾˝` must be recognized: if `0=≠𝕩` and `1<=𝕩`, then `∾˝𝕩` is `(0∾2↓≢𝕩)⥊𝕩`. If `1==𝕩`, then there is no identity element, as the result of `∾` always has rank at least 1, but the cell rank is 0.

## Fill elements

Any BQN array can have a *fill element*, which is a sort of "default" value for the array. The reference implementations use `Fill` to access this element, and it is used primarily for Take (`↑`) and Nudge (`«`, `»`). One way to extract the fill element of an array `a` in BQN is `⊑»1↑⥊a`.

A fill element can be either `0`, `' '`, or an array of valid fill elements. If the fill element is an array, then it may also have a fill element (since it is an ordinary BQN array). The fill element is meant to describe the shared structure of the elements of an array: for example, the fill element of an array of numbers should be `0`, while the fill element for an array of variable-length lists should probably be `⟨⟩`. However, the fill element, unlike other inferred properties, does not satisfy any particular constraints that relate it to its array. The fill element of a primitive's result, including functions derived from primitive modifiers, must depend only on its inputs.

In addition to the requirements below, the fill element for the value of a string literal is `' '`.

### Required function fills

Combinators `⊣⊢!˙˜´˝∘○⊸⟜⊘◶⍟` do not affect fill element computation: if the combinator calls a function that computes a fill element, then that fill element must be retained if the result is passed to other functions or returned. `⍟` constructs arrays if its right operand is or contains arrays, and the fill elements of these arrays are not specified; converting `𝕩` to a fill element is a reasonable choice in some cases but not others.

Arithmetic primitives—all valences of `+-×÷⋆√⌊⌈|¬` and dyadic `∧∨<>≠=≤≥`—obtain their fill elements by applying to the fill elements of the arguments. If this is an error, there is no fill element; otherwise, the fill element is the result, with all numbers in it changed to `0` and all characters changed to `' '`.

Fill elements for many primitives are given in the table below. The "Fill" column indicates the strategy used to compute the result's fill. Fields `0`, `𝕩`, and `0↑𝕩` indicate the fill directly, except that for dyadic `⋈` the fill is specified only if it's the same as that obtained from `𝕨`. `⊢` and `∩` indicate that the fill is to be computed from the argument fills (if not all arguments have fills, then the fill element is unspecified). For `⊢`, the fill element of the result is the fill element of `𝕩`. For `∩`, the fill is equal to the fill values for multiple arrays, provided that they are all equal (it's unspecified if they are not all equal). In the two argument case, these arrays are `𝕨` and `𝕩`. In the one-argument case, they are the elements of `𝕩`; however, if `𝕩` is empty, then the result's fill is the fill of the fill of `𝕩`.

| Fill   | Monads       | Dyads       | Modifiers
|--------|--------------|-------------|----------
| `⊢`    | `∧∨⥊≍»«⌽⍉⊏⍷` | `⥊↑↓↕⌽⍉/⊏`  | `` 𝔽` ``
| `0`    | `≢/⍋⍒∊⊐⊒`    | `⍋⍒⊐⊒∊⍷`
| `𝕩`    | `<↕⋈`        | `⋈`
| `∩`    | `>∾`         | `∾≍»«`
| `0↑𝕩`  | `↑↓`

For Group and Group Indices (`⊔`), the fill element of the result and its elements are both specified: the fill element of each element of the result is the same as that of `𝕩` for Group, and is `0` for Group Indices. The fill element of the result is `(0⚇1𝕨)↑𝕩` for Group, and `⥊⟜<0⚇1𝕩` for Group Indices.

Fill elements of iteration modifiers such as `¨⌜` are not specified. It is reasonable to define the fill element of `𝔽⌜` or `𝔽¨` to be `𝔽` applied to the fill elements of the arguments. Regardless of definition, computing the fill element cannot cause side effects or an error.

## Undo

The Undo 1-modifier `⁼`, given an operand `𝔽` and argument `𝕩`, and possibly a left argument `𝕨`, finds a value `y` such that `𝕩≡𝕨𝔽y`, that is, an element of the pre-image of `𝕩` under `𝔽` or `𝕨𝔽⊢`. Thus it satisfies the constraint `𝕩 ≡ 𝕨𝔽𝕨𝔽⁼𝕩` (`𝕨𝔽⁼⊢` is a *right inverse* of `𝕨𝔽⊢`) provided `𝔽⁼` and `𝔽` both complete without error. `𝔽⁼` should of course give an error if no inverse element exists, and can also fail if no inverse can be found. It is also preferred for `𝔽⁼` to give an error if there are many choices of inverse with no clear way to choose one of them: for example, `0‿0⍉m` returns the diagonal of matrix `m`; `0‿0⍉⁼2‿3` requires values to be chosen for the off-diagonal elements in its result. It is better to give an error, encouraging the programmer to use a fully-specified approach like `2‿3⌾(0‿0⊸⍉)` applied to a matrix of initial elements, than to return a result that could be very different from other implementations.

If a value `𝕩` isn't in the range of `𝔽`, then no result satisfies the rule for `𝔽⁼𝕩`. As `𝔽⁼𝕩` would then always give an error by the above rules, a BQN implementation with extensions could define it in any way. However, a few such extensions are specified: `√⁼` is defined on all numbers, and `F⁼⁼` and `F⍟(-n)⁼` are extended to the full domain of `F` (with `F⁼˜⁼` extended similarly) and `/⁼` to any list of natural numbers, as noted below.

When working with limited-precision numbers, it may be difficult or impossible to exactly invert the operand function. Instead, it is generally acceptable to perform a computation that, if done with unlimited precision, would exactly invert `𝔽` computed with unlimited precision. This principle is the basis for the numeric inverses specified below. It is also acceptable to find an inverse by numeric methods, provided that the error in the inverse value found relative to an unlimited-precision inverse can be kept close to the inherent error in the implementation's number format.

Regardless of which cases for Undo are supported, the result of a call, and whether it is an error, must depend only on the values of the inputs `𝔽`, `𝕩`, and (if present) `𝕨`.

### Required functions

Function inverses are given for monadic and dyadic calls, with cases where inverse support is not required left blank.

For arithmetic functions the implementations below may in some cases not give the closest inverse (that is, there may be some other `y` so that `F y` is closer to `x` than `F F⁼x`). Even in these cases the exact functions given below must be used.

| Fn  | Monad | Dyad
|-----|-------|-------
| `+` | `+`   | `-˜`
| `-` | `-`   | `-`
| `×` |       | `÷˜`
| `÷` | `÷`   | `÷`
| `√` | `×˜`  | `⋆˜`
| `∧` |       | `÷˜`
| `¬` | `¬`   | `¬`

Unlike these inverses, the logarithm function—base *e* for `⋆⁼𝕩` and base `𝕨` for `𝕨⋆⁼𝕩`—does not have any strict precision requirements.

| Fn  | Monad | Dyad
|-----|-------|-------
| `⋆` | `Log` | `÷˜○Log`

The following structural functions have unique inverses, except in a few cases. Dyadic `⍉` with repeated axes is excluded, and monadic `<` can only be inverted on a rank-0 array. Dyadic `⊣` is invertible only if the arguments match, and in this case any return value is valid, but in BQN the shared argument value is returned. For `/⁼` the argument must be a list of natural numbers (it's extended to handle any such list even though the range consists of non-descending ones), and the result's fill element is 0.

| Fn  | Monad               | Dyad
|-----|---------------------|-------
| `⊢` | `⊢`                 | `⊢`
| `⊣` | `⊢`                 | `{!𝕨≡𝕩⋄𝕩}`
| `<` | `{!0==𝕩⋄!0<≡𝕩⋄⊑𝕩}`  |
| `⌽` | `⌽`                 | `-⊸⌽`
| `⍉` | `(1⌽↕∘=)⊸⍉⍟(0<=)`   | `{!∧´∊𝕨⋄𝕨⍉𝕩⋄(⍋⍷𝕨∾↕=𝕩)⍉𝕩}`
| `/` | `≠¨∘⊔`              |

For a data value `k`, the inverse `𝕨k⁼𝕩` with or without a left argument is `k⊣⁼𝕩`.

| Fn  | Inverse
|-----|-----------
| `k` | `{!k≡𝕩⋄𝕩}`

### Optional functions

Several primitives are easily and uniquely undone, but doing so is not important for BQN programming. These primitives are listed below along with suggested algorithms to undo them. Unlike the implementations above, these functions are not valid in all cases, and the inputs must be validated or the results checked in order to use them.

| Fn  | Monad  | Dyad
|-----|--------|-------
| `×` | `⊢`    |
| `∧` | `⊢`    |
| `∨` | `⊢`    | `-˜÷1-⊣`
| `∾` |        | `{(=○=⟜𝕩◶1‿≠𝕨)↓𝕩}`
| `≍` | `⊏`    | `¯1⊸⊏`
| `⋈` | `⊑`    | `¯1⊸⊑`
| `↑` | `¯1⊸⊑` |
| `↓` | `⊑`    |
| `↕` | `≢`    |

### Required modifiers

The following cases of Self/Swap must be supported.

| Fn   | Monad | Dyad
|------|-------|-------
| `+˜` | `÷⟜2` | `+⁼`
| `-˜` |       | `+`
| `×˜` | `√`   | `×⁼`
| `÷˜` |       | `×`
| `⋆˜` |       | `√`
| `√˜` |       | `⋆⁼˜`
| `∧˜` | `√`   | `∧⁼`
| `∨˜` | `√⌾¬` | `∨⁼`
| `¬˜` |       | `+-1˙`
| `𝔽˜˜`|       | `𝔽⁼`

Inverses of other modifiers and compound functions are given below. Here the "inverse" of a modifier is another modifier that, if applied to the same operands as the original operator, gives its inverse function. A constant is either a data value or `𝔽˙` for an arbitrary value `𝔽`.

| Mod     | Inverse              | Requirements
|---------|----------------------|--------------
| `¨`     | `{!0<≡𝕩⋄𝕨𝔽⁼¨𝕩}`      |
| `⌜`     | `{!0<≡𝕩⋄ 𝔽⁼⌜𝕩}`      | Monadic case only
| `˘`     | `{!0<=𝕩⋄𝕨𝔽⁼˘𝕩}`      |
| `˙`     | `{!𝕗≡𝕩⋄𝕩}`           |
| `F∘G`   | `{𝕨G⁼F⁼𝕩}`           |
| `F G`   |                      |
| `·F G`  |                      |
| `○`     | `{𝔾⁼(𝔾𝕨)𝔽⁼𝕩}`        |
| `⁼`     | `{𝔽}`                | Extended: no result check
| `𝔽⁼˜`   | `𝔽˜⁼˜`               | Extended; dyadic case only
| `⌾`     | `{𝔽⁼⌾𝔾}`             | Verify result for computational Under
| `⍟n`    | `⍟(-n)`              | Atomic number `n`; no check, like `⁼`
| `⊘`     | `{(𝔽⁼)⊘(𝔾⁼)}`        |
| `⊸`     | `{𝔽⊸(𝔾⁼)}`           | Dyadic case or constant `𝔽` only
| `⟜`     | `{𝔾⁼𝔽⁼}`             | Dyadic case
| `𝔽⟜k`   | `k𝔽˜⁼⊢`              | Monadic case, constant `k`
| `k𝔽𝔾`   | `𝔾⁼{𝕨𝔽𝔾𝕩}(k𝔽⁼⊢)`     | Constant `k`
| `𝔽𝔾K`   | `𝔽⁼k𝔾˜⁼⊢`            | Constant `k`

| Mod     | Inverse 
|---------|---------
| `` ` `` | `{!0<=𝕩 ⋄ 𝕨 (»𝔽⁼¨⊢){(⊏∾⊏𝔽1⊸↓)⍟(1<≠)⊘𝔽} 𝕩}`

### Undo headers

An `ARG_HEAD` header containing `"⁼"` specifies how a block function acts when undone. Like ordinary headers, undo headers are searched for a match when a block function `F` is undone, or when `F˜` is undone with two arguments (including the two modifier cases `𝔽⟜k` and `𝔽𝔾k` from the previous section). An `ARG_HEAD` without `"˜"` matches the `F⁼` case while one with `"˜"` matches the `F˜⁼` case. The left and right arguments are matched to `headW` and `headX` as with ordinary headers, and the first matching case is evaluated to give the result of the Undo-derived function.

## Under

The Under 2-modifier `⌾` conceptually applies its left operand under the action of its right operand. Setting `z←𝕨𝔽⌾𝔾𝕩`, it satisfies `(𝕨𝔽○𝔾𝕩) ≡ 𝔾z`. We might say that `𝔾` transforms values to a new domain, and `⌾𝔾` lifts actions `𝔽` performed in this domain to the original domain of values. For example, addition in the logarithmic domain corresponds to multiplication in the linear domain: `+⌾(⋆⁼)` is `×` (but less precise if computed in floating point).

Let `v←𝕨𝔽○𝔾𝕩`, so that `v≡𝔾z`. `v` is of course well-defined, so the inference step is to find `z` based on `v` and possibly the original inputs. We distinguish three cases for Under:
- *Invertible* Under: If `𝔾` is uniquely invertible on `v`, that is, `v≡𝔾z` has a unique solution for `z`, then the result of Under is that solution.
- *Structural* Under: If `𝔾` is a structural function (to be defined below) and `v` is compatible with `𝔾` on `𝕩`, then the result is obtained by inserting `v` back into `𝕩`.
- *Computational* Under: If `𝔾` is provably not a structural function, then the result is `𝔾⁼v` if it is defined.

When implementing, there is no need to implement invertible Under specially: it can be handled as part of the structural and computation cases.

### Mathematical definition of structural Under

In general, structural Under requires information from the original right argument to be computed. Here we will define the *structural inverse of* structural function `𝔾` *on* `v` *into* `𝕩`, where `𝕩` gives this information. The value `𝕨𝔽⌾𝔾𝕩` is then the structural inverse of `𝔾` on `𝕨𝔽○𝔾𝕩` into `𝕩`.

We define a *structure* to be either the value `·` or an array of structures (substitute `0` or any other specific value for `·` if you'd like structures to be a subset of BQN arrays; the value is irrelevant). A given structure `s` *captures* a BQN value or structure `𝕩` if it is `·`, or if `s` and `𝕩` are arrays of the same shape, and each element of `s` captures the corresponding element of `𝕩`. Thus a structure shares some or all of the structural information in arrays it captures, but none of the data.

A *structure transformation* consists of an initial structure `s` and a result structure `t`, as well as a relation between the two: each instance of `·` in `t` is assigned the location of an instance of `·` in `s`. If `s` captures a value `𝕩`, we say that the structural transformation captures `𝕩` as well. Given such a value `𝕩`, the transformation is applied to `𝕩` by replacing each `·` in `t` with the corresponding value from `𝕩`, found by taking the same location in `𝕩` as the one in `s` given by the transformation.

Given values `𝕩` and `v` and a structure transformation `G` capturing `𝕩`, the *structural inverse* `z` of `G` on `v` into `𝕩`, if it exists, is the value such that `v≡G z`, and `𝕩 ≡○F z` for every structure transformation `F` possible given the previous constraint. If `G` has initial structure `s` and final structure `t`, we know that `s` captures `𝕩` and `z` (it's required in order to apply `G` at all) while `t` captures `v`. For each instance of `·` in `s`, there are three possibilities:
- No result location in `t` is assigned this location. This component of `z` must match `𝕩`, or `z` could be improved without breaking any constraints by replacing it.
- Exactly one result location is assigned this location. The requirement `v≡G z` implies `z`'s value here is exactly `v`'s value at that result location.
- More than one result location is assigned this location. Now `z`'s value there must match `v`'s value at each of these result leaves. If `v` has different values at the different leaves, there is no inverse.
Following this analysis, `z` can be constructed by replacing each instance of `·` in `s` with the component of `𝕩` or `v` indicated, and it follows that `z` is well-defined if it exists—and it exists if and only if `t` captures `v` and values in `v` that correspond to the same position in `s` have the same value.

A *structural function decomposition* is a possibly infinite family of structure transformations such that any possible BQN value is captured by at most one of these transformations. It can be applied to any value: if some transformation captures the value, then apply that transformation, and otherwise give an error. A function is a *structural function* if there is a structural function decomposition that matches it: that is, for any input either both functions give an error or the results match.

For a structural function `𝔾`, the *structural inverse* of `𝔾` on `v` into `𝕩` is the inverse of `G` on `v` into `𝕩`, where `G` is the structure transformation that captures `𝕩` from some structural function decomposition `Gd` matching `𝔾`. If no decomposition has an initial structural matching `𝕩` then the structural inverse does not exist.

#### Well-definedness

In order to show that the structural inverse of a structural function is well-defined, we must show that it does not depend on the choice of structural function decomposition. That is, for a given `𝕩`, if `G` and `H` are structure transformations from different decompositions of `𝔾` both capturing `𝕩`, then the structural inverse of `G` on `v` into `𝕩` matches that of `H` on `v` into `𝕩`. Call these inverses `y` and `z`. Now begin by supposing that `H` captures `y` and `G` captures `z`; we will show this later. From the definition of a structural inverse, `v≡G y`, so that `v≡𝔾 y`, and because `H` captures `y` we know that `𝔾 y` is `H y`, so we have `v≡H y` as well. Let `S w` indicate the set of all structure transformations `F` such that `w ≡○F 𝕩` (this is not a BQN value, both because it is a set and because it's usually infinite): from the definition of `z` we know that `S z` is a strict superset of `S w` for any `w` other than `z` with `v≡H w`. It follows that either `y≡z` or `S y` is a strict subset of `S z`. By symmetry the same relation holds exchanging `y` and `z`, but it's not possible for `S y` to be a strict subset of `S z` and vice-versa. The only remaining possibility is that `y≡z`.

We now need to show that `H` captures `y` (the proof that `G` captures `z` is of course the same as `H` and `G` are symmetric). To do this we must show that any array in the initial structure of `H` corresponds to a matching array in `y`. For convenience, we will call the initial structures of the two transformations `iG` and `iH`, and the final structures `fG` and `fH`, and use the notation `p⊑a` to indicate the value of array `a` at position `p`. Choose the position of an array in `H`, and assume by induction that each array containing it already has the desired property; this implies that this position exists in `y` as well although we know nothing about its contents. `G` captures `y`, so `iG` is `·` at this position or some parent position; call this position in `iG` `p`. There are now two cases: either `G` makes use of this `p`—at least one position in `fG` corresponds to it—or it doesn't. If it doesn't, then the contents of `y` at `p` are the same as those of `𝕩`. Since `H` captures `𝕩`, `iH` matches `𝕩` and hence `y` as well at `p`. If it does, then let `s` be a position in `fG` that corresponds to `p` (if there are multiple possibilities, choose one). From `v≡G y`, we know that `s⊑v` matches `p⊑y`. We know that `fH` captures `v`, so that `s⊑fH` captures `s⊑v`, or `p⊑y`. But we can show that the value of `s⊑fH` is the same as `p⊑iH`, which would prove that `H` captures `y` at `p`. To show this, construct an array `xp` by replacing the value of `𝕩` at `p` with `p⊑iH` (to be more careful in our handling of types, we might replace every `·` with some value that never appears in `𝕩`). Both `H` and `G` capture `xp`: clearly they capture it outside `p`, while at `p` itself, `iG` is `·` and `iH` is equal to `p⊑xp`. Now `(H xp)≡(G xp)` because both functions match `𝔾` on their domains. Therefore `s⊑H xp` matches `s⊑G xp`, which by the definition of `s` matches `p⊑xp`, which matches `p⊑iH`. But `s⊑H xp` comes from replacing each atom in `s⊑fH` with an atom in `xp` that's captured by a `·` in `iH`. Because it matches `p⊑iH`, every atom in `s⊑H xp` is `·`, but the only instances of `·` in `xp` come from our inserted copy of `p⊑iH` and each is immediately captured by the corresponding `·` in `iH`. It follows that `s⊑H xp`, and consequently `s⊑fH`, is exactly `p⊑iH`, completing the proof.

### Required structural inverses

The following primitive functions must be fully supported by structural Under. Each manipulates its right argument structurally.

| Type    | Primitives
|---------|-----------
| Monad   | `⊣⊢<>∾⥊≍↑↓⌽⍉⊏⊑`
| Dyad    | `⊢⥊↑↓↕⌽⍉/⊏⊑⊔`

The following combinations must also be supported, where `S` and `T` are structural functions and `k` is a constant function (data type, or function derived from `˙`):

| Expression | Remarks
|------------|--------
| `S∘T`      |
| `S T`      |
| `·S T`     |
| `S○T`      |
| `k⊸T`      |
| `k T ⊢`    |
| `S⍟k`      | `k` a natural number
| `S¨`       |
| `S⚇k`      | `k` contains only negative numbers
| `S⌜`       |
| `S˘`       |
| `S⎉k`      |

### A structural Under algorithm

This section offers the outline for a procedure that computes most structural inverses that a programmer would typically use. The concept is to build a special result array whose elements are not BQN values but instead indicate positions within the initial argument. This structural array is applied to the initial argument by replacing its elements with the values at those positions, and inverted by placing elements back in the original array at these indices, checking for any conflicts. If operations like dyadic `∾` are allowed, then a structural array might have some indices that are prefixes or parents of others, making it slightly different from a structural transformation as defined above (although it could be represented as a structural transformation by expanding some of these). This requires additional checking to ensure that elements of previously inserted elements can't be modified.

Structural functions can be applied to structural arrays directly, after ensuring that they have the necessary depth as given below. An array's depth can be increased by expanding each position in it into an array of child positions, or, if that position contains an atom and the structural function in question would tolerate an atom, enclosing it.

| Level | Monads          | Dyads            | Modifiers
|:-----:|-----------------|------------------|----------
| 0     | `⊢⊣<`           | `⊢⊣`             | `˜∘○⊸⟜⊘◶`
| 1     | `=≠≢⥊≍↑↓»«⌽⍉⊏⊑` | `⥊∾≍↑↓↕»«⌽⍉/⊏⊑⊔` | `˘¨⌜⎉`
| 2     | `>∾`            |                  |
| n     |                 |                  | `⚇`

Not all primitives in the table above are required. Of note are `=≠≢`, which accept a structural array but return an ordinary value; this might be used as a left argument later. If the final result is not structural, then the function in question can't be structural, and the attempt to find a structural inverse can be aborted.

### Non-structural case

The behavior of invertible and computational Under is fully dependent on that of [Undo](#undo), and does not need to be repeated here. However, it is important to discuss when this definition can be applied: specifically, either
- When `𝔾` is exactly invertible, or
- When `𝔾` is provably not a structural function.

A substantial class of functions that is easy to identify and always satisfies one of the above criteria is the functions that *never perform non-invertible structural manipulation*, or more colloquially *don't discard argument elements*. This class consists of functions made up of plain primitives that don't contain the following primitives:

| Valence | Primitives
|---------|-----------
| Monad   | `»«⊏⊑`
| Dyad    | `⥊↑↓»«⍉/⊏⊑⊔`
| Modifer | `` ⁼⍟´˝` ``

If a function of this class is a structural function, then it must be invertible, because the remaining primitives leave no way to retain some elements but discard others (an element's value can be ignored by replacing it by a constant, but a function that does this can't be structural). It can be extended to include some dyadic functions like `⥊↑⍉/` if it can be determined that the left argument never allows information to be discarded; for example if the left argument to `⍉` contains no duplicates or the left argument to `⥊` always has a product larger than its argument's bound. Inverses from `⁼` or `⍟` might be allowed on a case-by-case basis, and `⍟` with a constant right operand that contains no negative numbers can also be allowed.
