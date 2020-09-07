# Specification: BQN inferred properties

BQN includes some simple deductive capabilities: detecting the type of empty array elements, and the Undo (`⁼`) and Under (`⌾`) modifiers. These tasks are a kind of proof-based or constraint programming, and can never be solved completely (some instances will be undecidable) but can be solved in more instances by ever-more sophisticated algorithms. To allow implementers to develop more advanced implementations while offering some stability and portability to programmers, two kinds of specification are given here. First, constraints are given on the behavior of inferred properties. These are not exact and require some judgment on the part of the implementer. Second, behavior for common or useful cases is specified more precisely. Non-normative suggestions are also given as a reference for implementers.

For the specified cases, the given functions and modifiers refer to those particular representations. It is not necessary to detect equivalent representations, for example to reduce `(+-×)⁼` to `∨⁼`. However, it is necessary to identify computed functions and modifiers: for example `F⁼` when the value of `F` in the expression is `∨`, or `(1⊑∧‿∨)⁼`.

## Undo

The Undo modifier `⁼`, given an operand `𝔽` and argument `𝕩`, and possibly a left argument `𝕨`, finds a value `y` such that `𝕩≡𝕨𝔽y`, that is, an element of the pre-image of `𝕩` under `𝔽` or `𝕨𝔽⊢`. Thus it satisfies the constraint `𝕩 ≡ 𝕨𝔽𝕨𝔽⁼𝕩` (`𝕨𝔽⁼⊢` is a *right inverse* of `𝕨𝔽⊢`) provided `𝔽⁼` and `𝔽` both complete without error. `𝔽⁼` should of course give an error if no inverse element exists, and can also fail if no inverse can be found. It is also preferred for `𝔽⁼` to give an error if there are many choices of inverse with no clear way to choose one of them: for example, `0‿0⍉m` returns the diagonal of matrix `m`; `0‿0⍉⁼2‿3` requires values to be chosen for the off-diagonal elements in its result. It is better to give an error, encouraging the programmer to use a fully-specified approach like `2‿3⌾(0‿0⊸⍉)` applied to a matrix of initial elements, than to return a result that could be very different from other implementations.

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
| `√` | `⋆⟜2` | `⋆˜`
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

Several primitives are easily undone, but doing so is not important for BQN programming. These primitives are listed below along with suggested algorithms to undo them. Unlike the implementations above, these functions are not valid in all cases, and the inputs must be validated or the results checked in order to use them.

| Fn  | 1      | 2
|-----|--------|-------
| `×` | `⊢`    |
| `∧` | `⊢`    |
| `∨` | `⊢`    | `-˜÷1-⊢`
| `∾` |        | `{(=○=⟜𝕩◶1‿≠𝕨)↓𝕩}`
| `≍` | `⊏`    | `¯1⊸⊏`
| `↑` | `¯1⊸⊑` |
| `↓` | `⊑`    |
| `↕` | `≢`    |

### Required modifiers

The following cases of Self/Swap must be supported. In the table below, a number (n) in parentheses indicates that the function in question is equivalent to the constant function `n˙`, and should be inverted accordingly (check that the argument matches `n`, then return it).

| Fn   | 1     | 2
|------|-------|-------
| `+˜` | `÷⟜2` | `+⁼`
| `-˜` | (0)   | `+`
| `×˜` | `√`   | `×⁼`
| `÷˜` | (1)   | `×`
| `⋆˜` |       | `√`
| `√˜` |       | `÷⋆⁼`
| `∧˜` | `√`   | `∧⁼`
| `∨˜` | `√⌾¬` | `∨⁼`
| `¬˜` | (1)   | `+-1˙`

Inverses of other modifiers and derived functions or modifiers obtained from them are given below. Here the "inverse" of a modifier is another modifier that, if applied to the same operands as the original operator, gives its inverse function. A constant is either a data value or `𝔽˙` for an arbitrary value `𝔽`.

| Mod     | Inverse              | Requirements
|---------|----------------------|--------------
| `˙`     | `{𝕗⊢⁼𝕩}`             |
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
