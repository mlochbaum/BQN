*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/inferred.html).*

# Specification: BQN inferred properties

BQN includes some simple deductive capabilities: detecting the type of empty array elements, and the Undo (`⁼`) and Under (`⌾`) modifiers. These tasks are a kind of proof-based or constraint programming, and can never be solved completely (some instances will be undecidable) but can be solved in more instances by ever-more sophisticated algorithms. To allow implementers to develop more advanced implementations while offering some stability and portability to programmers, two kinds of specification are given here. First, constraints are given on the behavior of inferred properties. These are not exact and require some judgment on the part of the implementer. Second, behavior for common or useful cases is specified more precisely. Non-normative suggestions are also given as a reference for implementers.

For the specified cases, the given functions and modifiers refer to those particular representations. It is not necessary to detect equivalent representations, for example to reduce `(+-×)⁼` to `∨⁼`. However, it is necessary to identify computed functions and modifiers: for example `F⁼` when the value of `F` in the expression is `∨`, or `(1⊑∧‿∨)⁼`.

## Undo

The Undo 1-modifier `⁼`, given an operand `𝔽` and argument `𝕩`, and possibly a left argument `𝕨`, finds a value `y` such that `𝕩≡𝕨𝔽y`, that is, an element of the pre-image of `𝕩` under `𝔽` or `𝕨𝔽⊢`. Thus it satisfies the constraint `𝕩 ≡ 𝕨𝔽𝕨𝔽⁼𝕩` (`𝕨𝔽⁼⊢` is a *right inverse* of `𝕨𝔽⊢`) provided `𝔽⁼` and `𝔽` both complete without error. `𝔽⁼` should of course give an error if no inverse element exists, and can also fail if no inverse can be found. It is also preferred for `𝔽⁼` to give an error if there are many choices of inverse with no clear way to choose one of them: for example, `0‿0⍉m` returns the diagonal of matrix `m`; `0‿0⍉⁼2‿3` requires values to be chosen for the off-diagonal elements in its result. It is better to give an error, encouraging the programmer to use a fully-specified approach like `2‿3⌾(0‿0⊸⍉)` applied to a matrix of initial elements, than to return a result that could be very different from other implementations.

When working with limited-precision numbers, it may be difficult or impossible to exactly invert the operand function. Instead, it is generally acceptable to perform a computation that, if done with unlimited precision, would exactly invert `𝔽` computed with unlimited precision. This principle is the basis for the numeric inverses specified below. It is also acceptable to find an inverse by numeric methods, provided that the error in the inverse value found relative to an unlimited-precision inverse can be kept close to the inherent error in the implementation's number format.

### Required functions

Function inverses are given for one or two arguments, with cases where inverse support is not required left blank.

For arithmetic functions the implementations below may in some cases not give the closest inverse (that is, there may be some other `y` so that `F y` is closer to `x` than `F F⁼x`). Even in these cases the exact functions given below must be used.

| Fn  | 1     | 2
|-----|-------|-------
| `+` | `+`   | `-˜`
| `-` | `-`   | `-`
| `×` |       | `÷˜`
| `÷` | `÷`   | `÷`
| `√` | `×˜`  | `⋆˜`
| `∧` |       | `÷˜`
| `¬` | `¬`   | `¬`

Unlike these inverses, the logarithm function—base *e* for `⋆⁼𝕩` and base `𝕨` for `𝕨⋆⁼𝕩`—does not have any strict precision requirements.

| Fn  | 1     | 2
|-----|-------|-------
| `⋆` | `Log` | `÷˜○Log`

The following structural functions have unique inverses, except in a few cases. Dyadic `⍉` with repeated axes is excluded, and monadic `<` can only be inverted on a rank-0 array. Dyadic `⊣` is invertible only if the arguments match, and in this case any return value is valid, but in BQN the shared argument value is returned. For `/⁼` the argument must be a list of non-descending natural numbers, and the result's fill element is 0.

| Fn  | 1                   | 2
|-----|---------------------|-------
| `⊢` | `⊢`                 | `⊢`
| `⊣` | `⊢`                 | `{!𝕨≡𝕩⋄𝕩}`
| `<` | `{!0==𝕩⋄!0<≡𝕩⋄⊑𝕩}`  |
| `⌽` | `⌽`                 | `(-⊸⌽)`
| `⍉` | `(1⌽↕∘=)⊸⍉⍟(0<=)`   | `{!∧´∊𝕨⋄𝕨⍉𝕩⋄(⍋⍷𝕨∾↕=𝕩)⍉𝕩}`
| `/` | `≠¨∘⊔`              |

For a data value `k`, the inverse `𝕨k⁼𝕩` with or without a left argument is `k⊣⁼𝕩`.

| Fn  | Inverse
|-----|-----------
| `k` | `{!k≡𝕩⋄𝕩}`

### Optional functions

Several primitives are easily and uniquely undone, but doing so is not important for BQN programming. These primitives are listed below along with suggested algorithms to undo them. Unlike the implementations above, these functions are not valid in all cases, and the inputs must be validated or the results checked in order to use them.

| Fn  | 1      | 2
|-----|--------|-------
| `×` | `⊢`    |
| `∧` | `⊢`    |
| `∨` | `⊢`    | `-˜÷1-⊣`
| `∾` |        | `{(=○=⟜𝕩◶1‿≠𝕨)↓𝕩}`
| `≍` | `⊏`    | `¯1⊸⊏`
| `↑` | `¯1⊸⊑` |
| `↓` | `⊑`    |
| `↕` | `≢`    |

### Required modifiers

The following cases of Self/Swap must be supported.

| Fn   | 1     | 2
|------|-------|-------
| `+˜` | `÷⟜2` | `+⁼`
| `-˜` |       | `+`
| `×˜` | `√`   | `×⁼`
| `÷˜` |       | `×`
| `⋆˜` |       | `√`
| `√˜` |       | `÷⋆⁼`
| `∧˜` | `√`   | `∧⁼`
| `∨˜` | `√⌾¬` | `∨⁼`
| `¬˜` |       | `+-1˙`

Inverses of other modifiers and derived functions or modifiers obtained from them are given below. Here the "inverse" of a modifier is another modifier that, if applied to the same operands as the original operator, gives its inverse function. A constant is either a data value or `𝔽˙` for an arbitrary value `𝔽`.

| Mod     | Inverse              | Requirements
|---------|----------------------|--------------
| `¨`     | `{!0<≡𝕩⋄𝕨𝔽⁼¨𝕩}`      |
| `⌜`     | `{!0<≡𝕩⋄ 𝔽⁼⌜𝕩;}`     | Monadic case only
| `˘`     | `{!0<=𝕩⋄𝕨𝔽⁼˘𝕩}`      |
| `` ` `` | `(⊏∾2𝔽⁼˝˘∘↕⊢)⍟(1<≠)` |
| `F∘G`   | `{𝕨G⁼F⁼𝕩}`           |
| `F G`   |                      |
| `·F G`  |                      |
| `○`     | `{𝔾⁼(𝔾𝕨)𝔽⁼𝕩}`        |
| `⁼`     | `{𝔽⁼⊸⊢∘𝔽}`           |
| `⌾`     | `{𝔽⁼⌾𝔾}`             | Verify result for computational Under
| `⍟n`    | `⍟(-n)`              | Atomic number n
| `⊘`     | `{(𝔽⁼)⊘(𝔾⁼)}`        |
| `k⊸𝔽`   | `k⊸(𝔽⁼)`             | Constant k
| `k𝔽⊢`   |                      |
| `𝔽⟜k𝕩`  | `k𝔽˜⁼𝕩`              | Constant k
| `⊢𝔽k˙`  |                      | Arbitrary k

## Under

The Under 2-modifier `⌾` conceptually applies its left operand under the action of its right operand. Setting `z←𝕨𝔽⌾𝔾𝕩`, it satisfies `(𝕨𝔽○𝔾𝕩) ≡ 𝔾z`. We might say that `𝔾` transforms values to a new domain, and `⌾𝔾` lifts actions `𝔽` performed in this domain to the original domain of values. For example, addition in the logarithmic domain corresponds to multiplication in the linear domain: `+⌾(⋆⁼)` is `×` (but less precise if computed in floating point).

Let `v←𝕨𝔽○𝔾𝕩`, so that `v≡𝔾z`. `v` is of course well-defined, so the inference step is to find `z` based on `v` and possibly the original inputs. We distinguish three cases for Under:
- *Invertible* Under: If `𝔾` is uniquely invertible on `v`, that is, `v≡𝔾z` has a unique solution for `z`, then the result of Under is that solution.
- *Structural* Under: If `𝔾` is a structural function (to be defined below) and `v` is compatible with `𝔾` on `𝕩`, then the result is obtained by inserting `v` back into `𝕩`.
- *Computational* Under: If `𝔾` is provably not a structural function, then the result is `𝔾⁼v` if it is defined.

When implementing, there is no need to implement invertable Under specially: it can be handled as part of the structural and computation cases.

### Mathematical definition of structural Under

In general, structural Under requires information from the original right argument to be computed. Here we will define the *structural inverse of* structural function `𝔾` *on* `v` *into* `𝕩`, where `𝕩` gives this information. The value `𝕨𝔽⌾𝔾𝕩` is then the structural inverse of `𝔾` on `𝕨𝔽○𝔾𝕩` into `𝕩`.

We define a *structure* to be either the value `·` or an array of structures (substitute `0` or any other specific value for `·` if you'd like structures to be a subset of BQN arrays; the value is irrelevant). A given structure `s` is a *captures* a BQN value or structure `𝕩` if it is `·`, or if `s` and `𝕩` are arrays of the same shape, and each element of `s` captures the corresponding element of `𝕩`. Thus a structure shares some or all of the structural information in arrays it captures, but none of the data.

A *structure transformation* consists of an initial structure `s` and a result structure `t`, as well as a relation between the two: each instance of `·` in `t` is assigned the location of an instance of `·` in `s`. If `s` captures a value `𝕩`, we say that the structural transformation captures `𝕩` as well. Given such a value `𝕩`, the transformation is applied to `𝕩` by replacing each `·` in `t` with the corresponding value from `𝕩`, found by taking the same location in `𝕩` as the one in `s` given by the transformation.

Given a structure transformation `G` and values `𝕩` and `v`, the *structural inverse* `z` of `G` on `v` into `𝕩`, if it exists, is the value such that `v≡G z`, and `𝕩 ≡○F z` for every structure transformation `F` as possible given the previous constraint. If `G` has initial structure `s` and final structure `t`, we know that `s` captures `𝕩` and `z` (it's required in order to apply `G` at all) while `t` captures `v`. For each instance of `·` in `s`, there are three possibilities:
- No result location in `t` is assigned this location. This component of `z` must match `𝕩`, or `z` could be improved without breaking any constraints by replacing it.
- Exactly one result location is assigned this location. The requirement `v≡G z` implies `z`'s value here is exactly `v`'s value at that result location.
- More than one result location is assigned this location. Now `z`'s value there must match `v`'s value at each of these result leaves. If `v` has different values at the different leaves, there is no inverse.
Following this analysis, `z` can be constructed by replacing each instance of `·` in `s` with the component of `𝕩` or `v` indicated, and it follows that `z` is well-defined if it exists—and it exists if and only if `t` captures `v` and values in `v` that correspond to the same position in `s` have the same value.

A *structural function decomposition* is a possibly infinite family of structure transformations such that any possible BQN value is captured by at most one of these transformations. It can be applied to any value: if some transformation captures the value, then apply that transformation, and otherwise give an error. A function is a *structural function* if there is a structural function decomposition that matches it: that is, for any input either both functions give an error or the results match.

For a structural function `𝔾`, the *structural inverse* of `𝔾` on `v` into `𝕩` is the inverse of `G` on `v` into `𝕩`, where `G` is the structure transformation that captures `𝕩` from some structural function decomposition `Gd` matching `𝔾`. If no decomposition has an initial structural matching `𝕩` then the structural inverse does not exist.

#### Well-definedness

In order to show that the structural inverse of a structural function is well-defined, we must show that it does not depend on the choice of structural function decomposition. That is, for a given `𝕩`, if `G` and `H` are structure transformations from different decompositions of `𝔾` both capturing `𝕩`, then the structural inverse of `G` on `v` into `𝕩` matches that of `H` on `v` into `𝕩`. Call these inverses `y` and `z`. Now begin by supposing that `H` captures `y` and `G` captures `z`; we will show this later. From the definition of a structural inverse, `v≡G y`, so that `v≡𝔾 y`, and because `H` captures `y` we have `v≡H y` as well. Let `S w` indicate the set of all functions `F` such that `w ≡○F 𝕩` (this is not a BQN value, both because it is a set and because it's usually infinite): from the definition of `z` we know that `S z` is a strict superset of `S w` for any `w` other than `z` with `v≡H w`. It follows that either `y≡z` or `S y` is a strict subset of `S z`. By symmetry the same relation holds exchanging `y` and `z`, but it's not possible for `S y` to be a strict subset of `S z` and vice-versa. The only remaining possibility is that `y≡z`.

We now need to show that `H` captures `y` (the proof that `G` captures `z` is of course the same as `H` and `G` are symmetric). To do this we must show that any array in the initial structure of `H` corresponds to a matching array in `y`. Choose the position of an array in `H`, and assume by induction that each array containing it already has the desired property; this implies that this position exists in `y` as well although we know nothing about its contents. `G` captures `y`, so `G`'s initial structure is `·` at this position or some parent position. There are now two cases: either `G` makes use of this postion—at least one position in its final structure corresponds to it—or it doesn't. If not, then the contents of `y` at this position are the same as those of `𝕩`. Since `H` captures `𝕩`, its initial structure matches `𝕩` and hence `y` as well at this position. If it does, then instead `y` matches a part of `v`.
