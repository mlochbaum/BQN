# Expression explainer: generates an svg diagram to show how a BQN
# program is evaluated

wh ← 10.75‿24
pad← wh×2‿1
to ← 1+wh÷2‿3
t  ← 10

ps ← At "stroke=currentColor|fill=none|stroke-width=1"
rc ← At "class=code|stroke-width=1|rx=10"
gr ← "g" At "font-family=BQN,monospace|font-size=18px|class=Paren|fill=currentColor"
gt ← "g" At "font-size=15px|text-anchor=middle"
gb ← "g" At "class=codeCover|stroke-width=8|stroke-linejoin=round"
gf ← "g" At "opacity=0.9"
Shadow ← {
  p ← ("text" Attr ·Pos -⟜0‿2)¨ 𝕨
  gt Enc ⟨gb,gf⟩ Enc¨ (1⊸⊑¨ ≍○<○(p Enc¨⊢) ∾¨) 𝕩
}

hlcl‿hlch ← <˘ ⍉ ∘‿2⥊⟨
  "Number"      , ('0'+↕10)∾"¯.π∞"
  "Paren"       , "()"
  "Bracket"     , "⟨⟩"
  "Brace"       , "{}"
  "Nothing"     , "·"
  "String"      , "'"∾'"'∾"@"
  "Comment"     , "#"
⟩
hlcl ∾↩ ⟨
  "Gets"      # ¯3
  "Ligature"  # ¯2
  "Separator" # ¯1
  "Value"     #  0
  "Function"  #  1
  "Modifier"  #  2
  "Modifier2" #  3
⟩
GetHlcl←hlch{(+`≠¨𝕗)⍋(∾𝕗)⊸⊐}
hlTag ← {"<tspan class='"∾𝕩∾"'>"}¨ hlcl

Explain ← {
  b‿const‿blk‿i‿tok ← 𝕨
  ba‿bc‿bo‿bp ← '0'-˜⟨ # For each instruction, number of:
    "11111000000000010000022000"  # Arguments
    "000//232323223102303200121"  # Stack values consumed
    "11111111111111011101111110"  # Stack values output
    "00000110111001001101000100"  # Position determiner
  ⟩
  m ← { # Mask of instruction starts
    a ← ba(⊣⊏˜≠⊸>×⊢)b
    na← ∾⟜≠ (≠-(1+↕∘≠)⊸(»·⌈`×)⌾⌽) <⟜128 b
    n ← 1+{(𝕩=⌜a) +˝∘× >⊏⟜na⍟𝕩↕≠a}↕3
    ! ∧´ ↕∘≠⊸< n
    Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟(0=¯1⊑⊢)
    (≠↑∾⟜≠Se 1∾0¨) n
  }
  mb‿mi ← 0‿¯1 ↓¨ m⊸/¨ b‿i
  la←¯1=na←mb⊏bc
  na(b⊏˜1+⊣)⌾(la⊸/)˜↩/m
  no←1⌾(¯1⊸⊑)mb⊏bo
  r←+`no-na
  ! 1=¯1⊑r
  d←(+`no⊸×)⊸×f←0<na
  p←((¯1↓r)⍋⊸⊏○⍋(⊏⟜r+⊒))⊸⊏/na¬no
  f↑˜↩≠p

  src‿toks‿ii ← tok {
    tok‿role‿val‿s‿e ← 𝕨
    n ← ≠hlch
    o ← hlTag ⊏˜ (n+3+role) (⊢+-×n⊸=) GetHlcl s⊏𝕩
    c ← "</tspan>"¨e
    t ← c∾o
    ilf ← /𝕩=@+10
    𝕩 ↩ ((ilf∊s)⊏" ⋄")⌾(ilf⊸⊏)𝕩
    src ← ((↕≠𝕩)∾(≠¨t)/e∾s-1) ⍋⊸⊏ 𝕩∾∾t
    tt← <˘⍉> ⟨o, e(𝕩⊏˜⊢+↕∘¬)¨s, c⟩
    ti← s⊐(¬f)/mi
    ⟨src, ti⊏tt, ti⊏(s+e)÷2⟩
  } 𝕩

  j←¯1↓((1-˜+`¬f)⊏ii)⊏˜⊏˜⍟≠{s←𝕩⊏˜g←⍋𝕩⋄(g/˜(⊒s)=s⊏mb⊏bp)⌾((⍷s)⊸⊏)↕≠mb}p
  je←j∾¯1.25
  q←(/f∨j≠p⊏je-la) (⊏≍⊣) p

  pd ← <⊸∾⟜⌽˘˜˝ q ⊏ ⍉wh×0.6‿0.1+je≍d
  dim← (wh×⟨≠𝕩,2+⌈´d⟩)+2‿0×pad
  (512‿0⊸⌈⊸(⊣∾˜(t+pad)-˜-˜÷2˙)dim+2×t) SVG gr Enc ∾⥊¨⟨
    <"rect" Elt rc∾(Pos-pad)∾"width"‿"height"≍˘FmtNum¨dim
    <"text" Enc src
    (<"path" Elt ps∾"d"≍○<·∾"MVH"∾⟜Fmt¨⊢)˘ pd
    (ii (to+wh×≍)¨⟜(⊏⟜d) (¬f)/p) Shadow toks
  ⟩
}
