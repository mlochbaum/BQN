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
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d⊸×
Rp ← Pos⊸∾⟜("width"‿"height"≍˘FmtNum)○(d⊸×)

tx ← ↕li ⋄ y ← » yd ← +`2‿1.4‿1‿1‿1.8
dim ← ⟨1.5+li,¯1⊑yd⟩ ⋄ sh ← ¯1.8‿¯1
tp ← y ≍˜¨¨ 1‿4/⟨tx,↕lf⟩
hp ← 0.2‿¯0.45(+⟜(1‿0×sh)≍¯2⊸×⊸+)1‿0×dim
LL ← Line ·⌽˘ (≍˘⟜-0.08×4≍˜×∘-˜´) + ≍⟜(2↑y)
Ilg← (1⊸+∾-)∘= <⊸(⊔¨) ∾≍○<∾○(↕∘≠)

((∾˜d)×((-∾+˜)0.8‿0.3)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ sh Rp dim
  hg Ge ("rect" Elt ·Rp˝ {𝕩⊸+⌾(1⊑⊏)hp})¨ 2‿4⊏y
  lg Ge lgs Ge¨ LL∘≍¨¨´ it (⊐Ilg⊒) ft
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
