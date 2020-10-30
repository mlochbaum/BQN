wh ← 10.75‿24
pad← wh×2‿1
to ← 1+wh÷2‿3
t  ← 10

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
  b‿const‿blk‿i ← Compile 𝕩
  ba‿bc‿bo‿bp ← '0'-˜⟨ # For each instruction, number of:
    "11111000000000010000022000"  # Arguments
    "000//232323223102303200121"  # Stack values consumed
    "11111111111111011101111111"  # Stack values output
    "00000110101000001101000100"  # Position determiner
  ⟩
  m ← { # Mask of instruction starts
    a ← ba(⊣⊏˜≠⊸>×⊢)b
    na← ∾⟜≠ (≠-(1+↕∘≠)⊸(»·⌈`×)⌾⌽) <⟜128 b
    n ← 1+{(𝕩=⌜a) +˝∘× >⊏⟜na⍟𝕩↕≠a}↕3
    ! ∧´ ↕∘≠⊸< n
    Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟(0=¯1⊑⊢)
    (≠↑∾⟜≠Se 1∾0¨) n
  }
  mb‿mi ← m⊸/¨ b‿i
  mi↓˜↩¯1

  r←+`(mb⊏bo)-na←mb⊏bc
  ! 1=¯1⊑r
  p←((¯1↓r)⍋⊸⊏○⍋(⊏⟜r+⊒))⊸⊏/na
  j←¯1↓mi⊏˜⊏˜⍟≠{s←𝕩⊏˜g←⍋𝕩⋄(g/˜(⊒s)=s⊏mb⊏bp)⌾((⍷s)⊸⊏)↕≠mb}p
  je←j∾¯1.25
  d←+`⊸×f←0<na
  f↑˜↩≠p
  q←(/f∨j≠p⊏je) (⊏≍⊣) p

  pd ← <⊸∾⟜⌽˘˜˝ q ⊏ ⍉wh×0.6‿0.1+je≍d
  dim← (wh×⟨≠𝕩,2+⌈´d⟩)+2‿0×pad
  (512‿0⊸⌈⊸(⊣∾˜(t+pad)-˜-˜÷2˙)dim+2×t) SVG gr Enc ∾⥊¨⟨
    <"rect" Elt rc∾(Pos-pad)∾"width"‿"height"≍˘FmtNum¨dim
    <"text" Enc Highlight 𝕩
    (<"path" Elt ps∾"d"≍○<·∾"MVH"∾⟜Fmt¨⊢)˘ pd
    mi ((to+wh×≍)¨Shadow⊏⟜𝕩)⟜(⊏⟜d)○((¬f)⊸/) p
  ⟩
}
