Text ← "text" Attr "dy"‿"0.32em"∾⊢

ops ← ⍎∘⥊¨ spel ← "⊸⟜˜∘○˙"
m2 ← ∾˜1‿1‿0
_symb ← {𝕗<⊸∾≍○<}
lrand ← 5‿1/⟨"𝔽"_symb,"𝕗"⟩
lrsp  ← 5‿1/"𝔽"‿"𝕗"
names ← (¬×+`)⊸-∘=⟜' '⊸⊔ "Before After Self/Swap Atop Over Constant"

w‿h ← 280‿260
Pnt ← 32‿57×⌽

app ← m2 {o←𝕩⊑ops⋄𝕨◶{𝕩_o}‿{𝕩_o_("𝔾"_symb)}𝕩⊑lrand}¨ ↕≠ops
res ← >{⟨𝕏"𝕩","𝕨"𝕏"𝕩"⟩}¨app
map ← ⟨⟩⊸{(1<≡)◶(≍(𝕨∾0)≍○<⊢)‿((𝕨≍○<⊑)∾⟜∾·𝕊¨˜⟜(𝕨⊸∾¨((2×↕)- -⟜1)∘≠)1↓⊢)𝕩}¨res
path‿name ← <˘⍉⁼><˘∘⍉¨map

notBase ← (1<≠)◶⟨1,0≠¯1⊸⊑⟩¨¨ path
path ↓¨¨˜↩ -¬notBase
FromPath ← ≠≍+´
vv ← (1↓⌽↓"𝕨"‿"𝕩")      ∾˜¨⎉1 notBase /¨ name
vl ← (2 ≍⚇0 ⟨0⟩‿⟨¯1,1⟩) ∾˜¨⎉1 notBase FromPath¨∘/¨ path
vp ← Pnt¨¨ vl

ps ← >⟨"class"‿"yellow","style"‿"fill:none","stroke-width"‿"2"⟩
Connect ← {
  e ← FromPath ¯1↓𝕨
  curve ← ⟨1‿1.3, 1‿1.25‿0.9‿1, 0.5‿1.25‿1‿0⟩
  c ← 𝕨 ((1=≠)⊸∧⟜(2=⊑))◶⟨⟩‿(⊑⊸((⊣(⊢×≢∘⊢⥊1∾⊣)curve⊑˜×)○×)⟜(1⊸⊑)) 𝕩
  "path" Elt ps∾⟨"d",∾("M"∾(2÷˜≠c)⊏"LQC")∾⟜(Fmt Pnt˘⌾(∘‿2⊸⥊))¨e‿(c∾𝕩)⟩
}

label ← ⍉ ""‿"𝕨 " ∾⌜ ∾⟜" 𝕩"¨ lrsp∾¨spel∾⟜(/⟜"𝔾")¨m2

_trans ← {(𝕗∾" transform='translate(")∾(⊣∾","∾⊢)○FmtNum∾")'"˙}
g ← (20+h×↕2) "g font-size='20px' text-anchor='middle'"_trans˜⌜ (5+w×0.5+↕3)

rc ← >⟨"class"‿"code","stroke-width"‿"1","rx"‿"12"⟩
rc ∾↩ (Pos⟨¯0.43×w,1⟩)∾"width"‿"height"≍˘FmtNum¨⟨0.86×w,h-55⟩
cc ← >⟨"r"‿"12","class"‿"code","stroke-width"‿"0"⟩
n ← Text∘‿2⥊⟨"y",FmtNum h-37, "fill","currentColor"⟩
case ← (¯1‿1×w÷4.6) "g font-size='21px' font-family='monospace'"_trans¨ 25
lt← Text∘‿2⥊⟨"y",FmtNum h-105, "font-size","19px"⟩

(0‿0∾10+3‿2×w‿h) SVG g Enc¨ ⌽ <⎉1⍉>2‿3⊸⥊¨⟨
  < "rect" Elt rc
  n⊸Enc¨ names
  (< case Enc¨ ⊢)⎉1 ∾¨´ ⟨
    (<lt Enc Highlight)¨ label
    path Connect¨¨⟜(vl⊏¨˜vv(⊐⌈≠∘⊣|⊒)¨⊢)○((0<≠¨¨path)/¨⊢) name
    ("circle" Elt cc∾⟨"cx","cy"⟩≍˘FmtNum¨)¨¨ vp
    vp Text∘Pos⊸Enc⟜Highlight¨¨ vv
  ⟩
⟩
