# Expression explainer: generates an svg diagram to show how a BQN
# program is evaluated

wh ← 10.84‿24
pad← wh×2‿1
to ← 0‿¯1+wh÷2‿3
t  ← 10

ps ← At "stroke=currentColor|fill=none|stroke-width=1"
rc ← At "class=code|stroke-width=1|rx=10"
gr ← "g" At "font-family=BQN,monospace|font-size=18px|class=Paren|fill=currentColor"
gt ← "g" At "font-size=15px|text-anchor=middle"
gb ← "g" At "class=codeCover|stroke-width=8|stroke-linejoin=round"
gf ← "g" At "opacity=0.9"

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

escchars ← """&<>" ⋄ escapes ← ("&"∾∾⟜";")¨"quot"‿"amp"‿"lt"‿"gt"

Explain ← {
  b‿const‿blk‿bdy‿(i‿e)‿tok ← 𝕨
  ba‿bc‿bo‿bp ← (⊏/¨1⊸↓)'0'-˜⟨ # For each instruction, number of:
    "114113141111111311411413141111=111"  # Codes until next opcode
    "1110001100000000000222110000000111"  # Arguments
    "000111//23232303232000001122232111"  # Stack values consumed
    "1110001111111101111111110101111111"  # Stack values output
    "0000000011111101010000000000010000"  # Position determiner
  ⟩
  m ← { # Mask of instruction starts
    n ← (↕≠b)+1+ba(⊣⊏˜≠⊸>×⊢)b
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
  k←p≠⊸↑¬f

  src‿toks‿ii ← tok {
    tok‿role‿val‿s‿e ← 𝕨
    n ← ≠hlch
    o ← hlTag ⊏˜ (n+3+role) (⊢+-×n⊸=) GetHlcl s⊏𝕩
    c ← "</tspan>"¨e
    t ← c∾o
    ilf ← /𝕩=@+10
    𝕩 ↩ ((ilf∊s)⊏" ⋄")⌾(ilf⊸⊏)𝕩
    u←/¬em←escchars≠⊸>ei←escchars⊐𝕩 ⋄ t∾˜↩escapes⊏˜em/ei
    ord← ⍋u∾(≠¨t)/(/em)∾e∾s-1
    src← ord⊏(u⊏𝕩)∾∾t
    el ← ei⊏(≠¨escapes)∾1
    xe ← (ord⊏(+´el)>↕∘≠)⊸/src
    tt ← <˘⍉> ⟨o, xe⊔˜el/1-˜s(⊣×>)○(+`(≠𝕩)↑/⁼)1+e, c⟩
    ti ← s⊐k/mi
    ⟨src, ti⊏tt, ti⊏(s+e)÷2⟩
  } 𝕩

  j←¯1↓((1-˜+`k)⊏ii)⊏˜⊏˜⍟≠{s←𝕩⊏˜g←⍋𝕩⋄(g/˜(⊒s)=s⊏mb⊏bp)⌾((⍷s)⊸⊏)↕≠mb}p
  je←j∾¯1.25
  q←(/k≤j≠p⊏je-la) (⊏≍⊣) p

  pd ← <∘(∾"M VH"∾¨∾⟜⌽)˘˜˝ q ⊏ FmtNum ⍉wh×0.5‿0.1+je≍d
  tp ← ii ("text" Attr Pos)∘(to+wh×≍)¨ (k/p)⊏d
  dim← (wh×⟨≠𝕩,2+⌈´d⟩)+2‿0×pad
  (512‿0⊸⌈⊸(⊣∾˜(t+pad)-˜-˜÷2˙)dim+2×t) SVG gr Enc ∾⥊¨⟨
    <"rect" Elt rc∾(Pos-pad)∾"width"‿"height"≍˘FmtNum dim
    <"text" Enc src
    ("path" Elt ps∾"d"⋈⊢)¨ pd
    gt Enc ⟨gb,gf⟩ Enc¨ (1⊸⊑¨ ⋈○(tp Enc¨⊢) ∾¨) toks
  ⟩
}
