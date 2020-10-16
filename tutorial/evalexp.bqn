wh ← 10.75‿24
pad← wh×1.5‿1
t ← 10

ps ← >⟨"stroke"‿"#585552","style"‿"fill:none","stroke-width"‿"2"⟩
rc ← >⟨"class"‿"code","stroke-width"‿"1","rx"‿"12"⟩
gr ← "g" Attr >⟨"font-family"‿"BQN,monospace", "font-size"‿"18px"⟩

DrawEval←{
  ix←𝕩⊏˜i←/𝕩≠' '
  f←0=b←-˝p←"()"=⌜ix
  l←<⟜«fn←ix∊"+-×÷⋆√"
  g←⍋+`b
  ei←¯1∾˜b{((𝕨<0)/𝕩)⌾((𝕨>0)⊸/)𝕩}○(g⊸⊏)»+`f
  o←ei⊏˜f/↕∘≠⊸-⌾(g⊸⊏)(1+»l)(⊢+fn×-)1-2×l
  g⊏˜↩⍋g⊏l
  rev←⍋+`¯1↓(¯1∾g)(⊣⍋⊸⊏⊏˜⟜⍋¬⊏˜)⍋+`⊸+1∾g⊏l∨⊏p
  m←1+⌈´d←+`⊸×⌾(rev⊸⊏)fn

  pt ← f/⍉> wh×⟨i,d⟩
  off← (o ⊏ ∾⟜(wh×¯1‿m))⊸- pt
  pd ← pt (<(wh×0.6‿0.1)⊸+)⊸∾⟜⌽˘ off
  dim← (wh×⟨≠𝕩,2+m⟩)+2‿0×pad
  (512‿0⊸⌈⊸(⊣∾˜(t+pad)-˜-˜÷2˙)dim+2×t) SVG gr Enc ∾⥊¨⟨
    <"rect" Elt rc∾(Pos-pad)∾"width"‿"height"≍˘FmtNum¨dim
    <"text" Enc Highlight 𝕩
    (<"path" Elt ps∾"d"≍○<·∾"Mvh"∾⟜Fmt¨⊢)˘ pd
  ⟩
}
