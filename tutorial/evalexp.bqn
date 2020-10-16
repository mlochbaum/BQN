wh ← 10.75‿24
pad← wh×2‿1
t ← 10

ps ← At "class=Paren|stroke=currentColor|fill=none|stroke-width=1"
rc ← At "class=code|stroke-width=1|rx=10"
gr ← "g" At "font-family=BQN,monospace|font-size=18px"
gt ← "g" At "text-anchor=middle"
gb ← "g" At "class=codeCover|stroke-width=6|stroke-linejoin=round"
gf ← "g" At "font-size=15px|opacity=0.9"
Shadow ← {
  t ← (⟨0,0‿¯2⟩+⌜𝕨) ("text" Attr Pos)⊸Enc¨ (⊢≍Highlight¨) ⥊¨𝕩
  gt Enc ⟨gb,gf⟩ Enc¨<˘ t
}

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
  off← (o ⊏ ∾⟜(wh×¯1.25‿m))⊸- pt
  pd ← pt (<(wh×0.6‿0.1)⊸+)⊸∾⟜⌽˘ off
  dim← (wh×⟨≠𝕩,2+m⟩)+2‿0×pad
  tp ← <˘pt+(1+wh÷2‿3)+⎉1(0‿1×⌜˜f/¬fn)×off
  (512‿0⊸⌈⊸(⊣∾˜(t+pad)-˜-˜÷2˙)dim+2×t) SVG gr Enc ∾⥊¨⟨
    <"rect" Elt rc∾(Pos-pad)∾"width"‿"height"≍˘FmtNum¨dim
    <"text" Enc Highlight 𝕩
    (<"path" Elt ps∾"d"≍○<·∾"Mvh"∾⟜Fmt¨⊢)˘ pd
    <tp Shadow f/ix
  ⟩
}
