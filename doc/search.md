*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/search.html).*

# Search functions

<!--GEN
d ← 48‿36

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-family=BQN,monospace|font-size=19px|text-anchor=middle"
hg ← "class=purple|stroke-width=0|opacity=0.5"
cg ← "text-anchor=end"
lg ← "class=lilac|stroke-linecap=round"
lgs← "stroke-width=1|stroke-dasharray=6,7"‿"stroke-width=1.5"‿"stroke-width=3"
ig ← "fill=currentColor|font-size=12|opacity=0.75"

li‿lf ← ≠¨ it‿ft ← '''(Highlight∾∾⊣)¨¨"searches"‿"essays"

Text ← ("text" Attr "dy"‿"0.32em"∾(Pos d⊸×))⊸Enc
Rp ← Pos⊸∾⟜("width"‿"height"≍˘FmtNum)○(d⊸×)

tx ← ↕li ⋄ y ← » yd ← +`2‿1.4‿1‿1‿1.8
dim ← ⟨1.5+li,¯1⊑yd⟩ ⋄ sh ← ¯1.8‿¯1
tp ← y ≍˜¨¨ 1‿4/⟨tx,↕lf⟩
hp ← 0.2‿¯0.45(+⟜(1‿0×sh)≍¯2⊸×⊸+)1‿0×dim
L0 ← ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d × ·⌽˘ (≍˘⟜-0.08×4≍˜×∘-˜´) + ≍⟜(2↑y)
LL ← "line" Elt =⟜li "mask"‿"url(#m)"⊸∾⍟⊣ L0∘≍
Ilg← (1⊸+∾-)∘= <⊸(⊔¨) ∾≍○<∾○(↕∘≠)

lgg ← "linearGradient"At"id=grad|x2=0|y2=1"
Stop ← "stop" Elt "offset"‿"stop-color"≍˘≍○<
defs ← "defs" Enc ("mask"At"id=m") Enc ⟨
  lgg Enc "0.6"‿"0.9" Stop¨ "#000"‿"#fff"
  "rect" Elt "fill"‿"url(#grad)" ∾ ((sh⊑⊸≍⊑) Rp dim⊑⊸≍-˜´) 2↑y
⟩

((∾˜d)×((-∾+˜)0.8‿0.3)+sh∾dim) SVG defs ∾ g Ge ⟨
  "rect" Elt rc ∾ sh Rp dim
  hg Ge ("rect" Elt ·Rp˝ {𝕩⊸+⌾(1⊑⊏)hp})¨ 2‿4⊏y
  lg Ge lgs Ge¨ LL¨¨´ it (⊐Ilg⊒) ft
  ig Ge (-⟜0‿0.48¨⊑tp) Text¨ •Repr¨ tx
  (∾tp) Text¨ it ∾ ft ∾ Highlight∘•Repr¨ ∾ {it 𝕏 ft}¨ ⟨⊐,⊒,∊˜⟩
  cg Ge (¯0.7≍¨y) Text⟜Highlight¨ "in"‿"for"∾⥊¨"⊐⊒∊"
⟩
-->

The three search functions are Index of (`⊐`), Progressive Index of (`⊒`), and Member of (`∊`). These are dyadic functions that search one argument ("searched-in") for major cells [matching](match.md) cells from the other ("searched-for"). For example, Index of returns, for each cell in `𝕩`, the index of the first cell in `𝕨` that matches it.

|      | Name                  | for | in  | Return
|:----:|-----------------------|:---:|:---:|-------
| `⊐`  | Index of              | `𝕩` | `𝕨` | Index of first match
| `⊒`  | Progressive Index of  | `𝕩` | `𝕨` | Index of first unused match
| `∊`  | Member of             | `𝕨` | `𝕩` | `1` if found, `0` if not
| `⍋⍒` | [Bins](order.md#bins) | `𝕩` | `𝕨` | Predecessor index

The searched-for argument is `𝕩` in Index-of functions (`⊐⊒`) and `𝕨` in Member of (`∊`). [Bins](order.md#bins) Up and Down (`⍋⍒`) are ordering functions but follow the same pattern as Index-of. It's split into cells, but not necessarily *major* cells: instead, the cells used match the rank of a major cell of the other (searched-in) argument. In the most common case, when the searched-in argument is a list, 0-cells are used for the search (we might also say elements, as it gives the same result).

The result is always an array containing one number for each searched-for cell. For Index of and Member of, every result is computed independently; for Progressive Index of the result for a cell can depend on earlier cells, in index order.

## Member of

The simplest of the search functions, Member of (`∊`) returns `1` if an entry in `𝕨` matches some entry in `𝕩`, and `0` if it doesn't.

        "green"‿"bricks"‿"cow"‿"blue" ∊ "red"‿"green"‿"blue"

The result is independent of the ordering of `𝕩`: all that matters is which cells it contains.

Member of can be used in a [train](train.md) to compute the set intersection and difference of two arrays. For example, `∊/⊣` uses `𝕨∊𝕩` to [filter](replicate.md) `𝕨` (from `𝕨⊣𝕩`), giving an intersection.

        "initial set" (∊/⊣) "intersect"     # Keep 𝕩

        "initial set" (¬∘∊/⊣) "difference"  # Remove 𝕩

These are the APL functions Intersect (`∩`) and Without (`~`). Really, only `𝕩` is treated like a set, while the ordering and multiplicity of elements of `𝕨` are maintained. I think the explicit implementations show this well, since `𝕩` is only used as the right argument to `∊`, and prefer this clarity to the brevity of a single symbol.

## Index of

Index of (`⊐`) returns the index of the first occurrence of each entry in `𝕨`, or `≠𝕨` if an entry doesn't appear in `𝕨` at all.

        "zero"‿"one"‿"two"‿"three" ⊐ "one"‿"eight"‿"two"

`𝕩∊𝕨` is the same as `(𝕨⊐𝕩)<≠𝕨`. Note the reversal of arguments! In both `∊` and `⊐`, the open side points to the searched-in argument and the closed side points to the searched-for argument. Relatedly, in Select (`⊏`), the open side points to the selected argument, which is more like the searched-in argument in that its cells are generally accessed out of order (the searched-for argument is most like the selection result `𝕨⊏𝕩`).

Index of always returns exactly one number, even if there are multiple matches, or no matches at all. To find the indices of all matches, start with [Match](match.md) [Each](map.md), then [Indices](replicate.md#indices) (I didn't mean for it to sound so repetitive! It just happened!).

        / "letters" ≡¨< 'e'        # Many to one

        "letters" (<∘/˘≡⌜˜) "let"  # Many to many

## Progressive Index of

Progressive Index of (`⊒`), as the name and glyph suggest, is a more sophisticated variant of Index of. Like Index of, it returns either `≠𝕨` or an index of a cell from `𝕨` that matches the given cell of `𝕩`. Unlike Index of, no index except `≠𝕨` can ever be repeated. Progressive Index of returns the index of the first *unused* match, provided there's still one left.

        "aaa" ⊒ "aaaaa"

        "aaabb" ⊒ "ababababab"

Above we said that `𝕩∊𝕨` is `(𝕨⊐𝕩)<≠𝕨`, so that `⊐˜<≠∘⊢` is an implementation of Member of. The corresponding `⊒˜<≠∘⊢` implements *progressive* member of, that is, membership on [multisets](https://en.wikipedia.org/wiki/Multiset). So if `𝕩` contains two copies of `'a'`, only the first to instances of `'a'` in `𝕨` are considered to belong to it. And like membership is useful for set intersection and difference, progressive membership gives multiset versions of these.

        "aabbcc" (⊐˜<≠∘⊢) "baa"

        "aabbcc" (⊒˜<≠∘⊢) "baa"

        "aabbcc" ((⊒˜=≠∘⊢)/⊣) "baa"  # Multiset difference

This primitive gives an interesting way to implement the [ordinals](order.md#ordinals) pattern that might be easier to understand than the APL classic `⍋⍋` (it's probably a little slower though). The idea is to use the sorted array as the left argument to `⊒`. Now the index returned for each cell is just where it ended up in that sorted order. If we used ordinary Index of then equal cells would share the smallest index; Progressive Index of means ties are broken in favor of earlier cells.

        ⍋∘⍋ "adebcedba"

        ∧⊸⊒ "adebcedba"

        ∧⊸⊐ "adebcedba"  # Ties included

Here's a goofy code golf tip: if the two arguments to Progressive Index of are the same, then every cell will be matched to itself, because all the previous indices are taken but the current one does match. So `⊒˜` is the same as `↕∘≠`.

        ⊒˜ "anything at all"
