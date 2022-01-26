*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/fromJ.html).*

# BQN–J dictionary

<!--GEN
"style" Enc ".Comment { color: inherit; }"
-->

A guide to help users of J get up to speed with BQN quickly. For a higher-level comparison, check [Why BQN?](../commentary/why.md#versus-apl-and-j).

## Terminology

### Array model

BQN uses the [based array model](based.md), which is fundamentally different from J's flat array model. BQN uses non-array values such as characters and numbers, called "atoms", while in J every noun is an array. A BQN array can contain any values in any mixture, while a J array must be uniformly numbers, characters, or boxes (BQN doesn't use boxes).

The J terms "atom" and "element" are used to mean different things by different authors. In BQN, an atom or rank-0 array is called a "unit", and the values contained in an array—which may or may not be arrays—are called "elements". Each element is contained in a 0-cell, or rank-0 subarray. BQN uses the term "major cell" for what J calls an "item" of an array: a cell with rank one less than that array. BQN shares the terms "list" and "table" for rank-1 and rank-2 arrays with J.

BQN uses "[depth](depth.md)" rather than "boxing level". BQN gives atoms depth 0, so that the depth of a BQN array is one higher than the boxing level of the corresponding J array.

### Roles

In J, the part of speech is an inherent property of a value, while in BQN it is determined by how the value is used in a particular expression, and can be different from the value's type. See [context-free grammar](context.md).

| J part of speech    | BQN role   |
|---------------------|------------|
| Noun                | Subject    |
| Verb                | Function   |
| Adverb              | 1-modifier |
| Conjunction         | 2-modifier |

## Syntax

| J                 | BQN         | Remarks
|-------------------|-------------|---------
| `NB.`             | `#`         |
| `'`               | `"`         | `'` creates characters
| `=.` and `=:`     | `←` and `↩` | `←` to define; `↩` to modify
| `3 :…` or `{{…}}` | `{…}`       |
| `:`               | `;`         | To separate function cases
| `x` `y`           | `𝕨` `𝕩`     | `𝕊` for block function self-reference
| `u` `v`           | `𝔽` `𝔾`     | `𝕣` for block modifier self-reference
| `_`               | `¯` or `∞`  |
| `2 3 4`           | `2‿3‿4`     |
| `[:`              | `·`         | Cap
| `assert.`         | `!`         |

BQN's explicit functions and modifiers are called "blocks", and have a more sophisticated syntax than J; see [the documentation](block.md). BQN uses [lexical scope](lexical.md), and has no global variables. BQN also has a [list notation](arrayrepr.md#brackets) using `⟨⟩`.

## For reading

J analogues of BQN primitive functions are given below. They are not always the same; usually this is because BQN has extra functionality relative to J, although in some cases it has less or different functionality.

Functions `+` `-` `|` `<` `>` are the same in both languages.

| BQN | `×` | `÷` | `⋆` | `√`  | `⌊`  | `⌈`  | `≤`  | `≥`  | `⊣` | `⊢` |
|:---:|:---:|:---:|:---:|:----:|:----:|:----:|:----:|:----:|:---:|:---:|
| J   | `*` | `%` | `^` | `%:` | `<.` | `>.` | `<:` | `>:` | `[` | `]` |

| BQN | `≍`  | `⋈`    | `⌽`   | `⍉`   |
|:---:|:----:|:------:|:-----:|:-----:|
| J   | `,:` | `,&:<` | `\|.` | `\|:` |

| BQN   | `∧`   | `∨`   | `¬`   | `=`   | `≠`  | `≡`  | `≢`     | `⥊` | `∾` |
|:-----:|:-----:|:-----:|:-----:|:-----:|:----:|:----:|:-------:|:---:|:---:|
| Monad | `/:~` | `\:~` | `-.`  | `#@$` | `#`  | `L.` | `$`     | `,` | `;` |
| Dyad  | `*.`  | `+.`  | `+-.` | `=`   | `~:` | `-:` | `-.@-:` | `$` | `,` |

| BQN   | `↑`  | `↓`   | `↕`  | `»`            | `«`             | `/`  |
|:-----:|:----:|:-----:|:----:|:--------------:|:---------------:|:----:|
| Monad | `<\` | `<\.` | `i.` | `#{.(_1-#){.]` | `-@#{.(1+#){.]` | `I.` |
| Dyad  | `{.` | `}.`  | `]\` | `#@]{.,`       | `-@#@]{.,~`     | `#`  |

| BQN   | `⍋`  | `⍒`     | `⊏`  | `⊑`     | `⊐`     | `⊒` | `∊`  | `⍷`  | `⊔`       |
|:-----:|:----:|:-------:|:----:|:-------:|:-------:|:---:|:----:|:----:|:---------:|
| Monad | `/:` | `/:`    | `{.` | `0{::,` | `i.~~.` | `…` | `~:` | `~.` | `</.i.@#` |
| Dyad  | `I.` | `I.&:-` | `{`  | `{::`   | `i.`    | `…` | `e.` | `E.` | `</.`     |

Most of BQN's combinators have J equivalents. The J equivalent `"_` for `˙` assumes a noun operand, but `˙` makes a constant function for any operand. `◶` has arguments reversed relative to `@.`, and uses an actual array of functions rather than gerunds. Besides these, BQN's `⟜` is like a J hook, that is, `F⟜G` is `(F G)`, and `⊸` applies in the opposite direction.

| BQN | `˙`  | `˜` | `∘`  | `○`  | `⌾`   | `⊘` | `◶`  | `⎊`  |
|:---:|:----:|:---:|:----:|:----:|:-----:|:---:|:----:|:----:|
| J   | `"_` | `~` | `@:` | `&:` | `&.:` | `:` | `@.` | `::` |

For other modifiers the correspondence is looser. Here `⌜` shows the dyadic case and `´` `˝` the monadic case only.

| BQN | `¨`   | `⌜`    | `´`    | `˝` | `` ` `` | `˘`   | `⎉` | `⚇`  | `⍟`  | `⁼`    |
|:---:|:-----:|:------:|:------:|:---:|:-------:|:-----:|:---:|:----:|:----:|:------:|
| J   | `&.>` | `&.>/` | `&.>/` | `/` | `/\`    | `"_1` | `"` | `L:` | `^:` | `^:_1` |

## For writing

J's primitive nouns are easily defined in BQN.

| J    | BQN      |
|------|----------|
| `a.` | `@+↕256` |
| `a:` | `<↕0`    |

Functions `+` `-` `|` `<` `>` are the same in both languages.

Some other primitives are essentially the same in J and BQN, but with different spellings (but [transpose](transpose.md) behaves differently; J's dyadic `|:` is more like `⍉⁼`):

| J   | `*` | `%` | `^` | `^.` | `%:` | `<.` | `>.` | `[` | `]` | `\|.` | `\|:` |
|:---:|:---:|:---:|:---:|:----:|:----:|:----:|:----:|:---:|:---:|:-----:|:-----:|
| BQN | `×` | `÷` | `⋆` | `⋆⁼` | `√`  | `⌊`  | `⌈`  | `⊣` | `⊢` | `⌽`   | `⍉`   |

| J   | `~` | `@:` | `&:` | `&.:` | `:` | `"` | `L:` | `^:` | `::` |
|:---:|:---:|:----:|:----:|:-----:|:---:|:---:|:----:|:----:|:----:|
| BQN | `˜` | `∘`  | `○`  | `⌾`   | `⊘` | `⎉` | `⚇`  | `⍟`  | `⎊`  |

The tables below give approximate implementations of J primitives. J has a whole lot of complicated primitives that no one uses (some of which are officially deprecated), so not everything is translated here. Operations that only apply to complex numbers are omitted because no BQN implementation currently supports them.

| J    | Monad                   | Dyad
|------|-------------------------|-----
| `=`  | `⍷⊸(≡⌜)`                | `=`
| `<:` | `-⟜1`                   | `≤`
| `>:` | `1⊸+`                   | `≥`
| `+.` |                         | `∨`
| `+:` | `2⊸×`                   | `¬∨`
| `*.` |                         | `∧`
| `*:` | `×˜`                    | `¬∧`
| `-.` | `¬`                     | `¬∘∊/⊣`
| `-:` | `÷⟜2`                   | `≡`
| `%.` | `Inverse` from [here](https://github.com/mlochbaum/bqn-libs/blob/master/matrix.bqn) | `Solve`
| `$`  | `≢`                     | `⥊`
| `~.` | `⍷`                     |
| `~:` | `∊`                     | `≠`
| `,`  | `⥊`                     | `∾`
| `,.` | `⥊˘`                    | `∾˘`
| `,:` | `≍`                     |
| `;`  | `∾`                     | `∾⟜(<⍟(1≥≡))`
| `#`  | `≠`                     | `/`
| `#.` | `+˜⊸+˜´∘⌽`              |
| `#:` | `⌽2\|⌊∘÷⟜2⍟(↕1+·⌊2⋆⁼⊢)` | ``{𝕨\|1↓⌊∘÷`⌾⌽𝕨∾<𝕩}``
| `!`  | `×´1+↕`                 | `-˜(+÷○(×´)⊢)1+↕∘⊣`
| `/:` | `⍋`                     | `⍋⊸⊏`
| `\:` | `⍒`                     | `⍒⊸⊏`
| `{`  | `(<⟨⟩)<⊸∾⌜´⊢`           | `⊏`
| `{.` | `⊏`                     | `↑`
| `{:` | `⊢˝`                    |
| `{::`|                         | `⊑`
| `}.` | `1⊸↓`                   | `↓`
| `}:` | `¯1⊸↓`                  |
| `".` | `•BQN`                  |
| `":` | `•Fmt`                  |
| `?`  | `•rand.Range⚇0`         | `•rand.Deal`
| `e.` | `><∘∾∊¨⊢`               | `∊`
| `E.` |                         | `⍷`
| `i.` | `↕` (`⥊⟜(↕×´)` for lists) | `⊐`
| `i:` | `{𝕩-˜↕1+2×𝕩}`           | `≠∘⊣-1+⌽⊸⊐`
| `I.` | `/`                     | `⍋`
| `L.` | `≡`                     |
| `o.` | `π⊸×`                   | `•math`

Some J modifier expressions are translated below. BQN doesn't keep track of the rank of functions, so the "close" compositions `@` `&` `&.` have no BQN equivalents: instead, specify a rank after composing.

| J              | BQN
|----------------|-----
| `&.>`          | `¨`
| `F/ y`         | `F˝ y`
| `x F&.>/ y`    | `x F⌜ y`
| `x F/ y`       | `x F⎉r‿∞ y` where `r` is `F`'s left rank
| ``F`G`H@.C``   | `C◶⟨F,G,H⟩`
| `x y} z`       | `x⌾(y⊸⊏) z`
| `x F/ . G y`   | `x F˝∘G⎉1‿∞ y`
| `F :. G`       | `{𝕊: 𝕨F𝕩; 𝕊⁼: 𝕨G𝕩}`
| `<;._1`        | ``((1-˜¬×+`)=⟜⊏⊘⊣)⊔⊢``
| `x {.!.f y`    | `y » x⥊f`
| `x \|.!.f y`   | `x ⥊⟜f⊸« y`, or `(-x) ⥊⟜f⊸» y` if `𝕩<0`

BQN uses functions, not modifiers, for structural manipulation. The following table gives BQN functions corresponding to J's structural modifiers. The result is an array of arrays; use `F¨` to apply a function to each of these, and `>F¨` to apply a function and merge the results into a single array.

| J    | Monad         | Dyad
|------|---------------|------
| `/.` | `(+⌜´↕¨∘≢)⊸⊔` | `⊐⊸⊔`
| `\`  | `1↓↑`         | `<˘↕`
| `\.` | `¯1↓↓`        |
