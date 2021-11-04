# Plot

width ← 384
pad   ← 2⥊10

opts_type ← @
InitPlot ← {𝕤⋄ opts_type ↩ "line" }
SetPlot  ← {𝕤⋄ opts_type ↩ 𝕩 }

pa ← At "class=Paren|stroke=currentColor|stroke-width=1"
pg ← At "class=red|style=fill:none|stroke-width=1"
pc ← At "class=red|r=4"
rc ← At "class=code|stroke-width=1|rx=5"
gr ← "g" At "font-family=BQN,monospace|font-size=18px"
Path ← "path" Elt ⊣∾"d"⋈⊢

Pair ← {
  "•Plot: 𝕨 and 𝕩 must consist of rows of numbers" ! 𝕨 ⊢⊘∧○((1≤=)◶⟨0,∧´∘⥊@⊸>⟩) 𝕩
  "•Plot: 𝕨 and 𝕩 must have the same length" ! 𝕨 1⊘(≡○(¯1⊑≢)) 𝕩
  ⥊ 𝕨 (< (↕¯1⊑≢)⊘⊣ ⋈ ⊢)⎉1 𝕩
}
PairRec ← {
  d ← 𝕨≍○≡𝕩
  𝕨 (2≤⌊´d)◶⟨Pair⊣"•Plot: invalid depth mixing"!·∧´1=d˙, ∾∘⥊𝕊¨⟩ 𝕩
}
Plot ← {
  xy ← 1e300 (⊣-⊸⌈⌊) ⍉> 𝕨 PairRec 𝕩   # organize and clip
  pts ← <∘∾˘ xy
  AB ← {e←(÷5e15)(⊣×⌈´)|𝕩⋄(⌊≍⌈)˝⌾(-⟜0‿e)𝕩} # ensure 0 < window size
  win ← -˜`¨ bounds ← (AB ⌊´≍⌈´)¨ pts # min and range; min and max
  ar ← 1⍟((÷4)⊸>∨1.5⊸<) ÷˜´ 1⊑¨win    # height÷width
  dim ← width (⊣≍×) ar
  Scale ← ({¬𝕏}⌾(1⊸⊑) {𝕩÷˜𝕨-˜⊢}´¨ win) {𝕎𝕩}¨ ⊢
  line ← (/≠¨⊏xy) ⊔ FmtNum ⍉> dim×Scale pts
  draw ← ("line"‿"scatter"⊸⊐⌾<opts_type) ⊑ ⟨
    (pg Path {'M'⌾⊑ ∾⥊ "L "∾¨⎉1𝕩})¨
    ("circle"Elt pc∾"cx"‿"cy"≍˘⊢)¨ <˘∘∾
  ⟩
  ((-pad)∾dim+2×pad) SVG gr Enc ∾⥊¨ ⟨
    <"rect" Elt rc∾(Pos-pad÷2)∾"width"‿"height"≍˘FmtNum dim+pad
    pa⊸Path¨ ((0⊸≤∧≤⟜1)/·<∘∾˘("M "⊸∾˘"VH")∾¨·FmtNum dim(×∾˘⌽∘⊣)(=⌜˜↕2)⊸×) Scale 0
    Draw line
  ⟩
}
Plot‿InitPlot‿SetPlot
