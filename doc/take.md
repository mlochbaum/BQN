*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/take.html).*

# Take and Drop

<!--GEN
xt ← '''(Highlight∾∾⊣)¨ "startend"
wv ← 5
d ← 56‿80

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "fill=currentColor|stroke-linecap=round|text-anchor=middle|font-family=BQN,monospace"
cg ← "font-size=25px"
bg ← "class=bluegreen|stroke-width=3|style=fill:none|opacity=0.8"
ag ← "class=green|stroke-width=3|style=fill:none|opacity=0.8"
lg ← "class=red|stroke-width=2.5|stroke-dasharray=9 9|opacity=0.9"

Text ← ("text" Attr "dy"‿"0.32em"∾ ·Pos d⊸×)⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d×⊢

_brak ← {
  P ← ∾"M l l "∾¨ ·FmtNum∘⥊ ∾
  "path" Elt "d"≍○< ∾ (𝕨((0‿¯1×𝕗)+d×≍)⌜𝕩) P¨ ≍○<⟜⌽ -⌾⊑⊸≍𝕗
}
ab ← ¯25‿12

tx ← ↕≠xt ⋄ ay ← 0.54 + ty ← 0
wm ← 0‿1 ⊑ bp ← 2↕(÷2)-˜⟨0,wv,≠xt⟩
tp ← (¯1.2∾2÷˜+˝bp) ≍¨ ty+/1‿2
dim ← ⟨2+≠tx,1.96⟩ ⋄ sh ← ¯1.8‿¯0.5

((∾˜d)×((-∾+˜)1‿0.3)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ (Pos d×sh)∾"width"‿"height"≍˘FmtNum d×dim
  cg Ge tp Text⟜Highlight¨ (<∾"↑"‿"↓"((•Repr wv)∾∾)¨<) "𝕩"
  "font-size=21px" Ge (tx≍¨ty) Text¨ xt
  bg Ge ((-⊸≍0.4)+0‿¯1⊏tx) 6‿15 _brak ty
  ag Ge ⟨
    ((-⊸≍0.9)+wm) ab _brak ay
    Line∘≍⟜(≍˜ay)¨ <˘ bp + -∘⌽⊸≍⟨0.9+ab÷○⊑d,¯0.2⟩
  ⟩
  lg Ge Line wm ≍˜⊸≍ ¯0.3‿1.2+ty
⟩
-->
