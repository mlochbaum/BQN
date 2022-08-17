# Expression explainer: generates a Unicode box-drawing character diagram to
# show how a BQN program is evaluated

wh ← 1‿1

Explain ← {
  b‿const‿blk‿bdy‿(i‿e)‿tok ← 𝕨
  ba‿bc‿bo‿bp ← (⊏/¨1⊸↓)'0'-˜⟨ # For each instruction, number of:
    "11411311121111111315114131131111=111"  # Codes until next opcode
    "111000111100000000002221100000000111"  # Arguments
    "000111////23232303230000011022232111"  # Stack values consumed
    "111000111111111101111111101101111111"  # Stack values output
    "000000000011111101010000000000010000"  # Position determiner
  ⟩
  m ← { # Mask of instruction starts
    n ← (↕≠b)+1+ba(⊣⊏˜≠⊸>×⊢)b
    Se←≠(>/⊢)∾⟜≠{(⊏˜𝕨)𝕊⍟(≠○(¯1⊸⊑))𝕩∾𝕩⊏𝕨}⟨0⟩˙
    (≠↑·/⁼Se) n
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

  src‿toks‿ti‿ii ← tok {
    ·‿·‿·‿s‿e ← 𝕨
    ilf ← /𝕩=@+10
    𝕩 ↩ ((ilf∊s)⊏" ⋄")⌾(ilf⊸⊏)𝕩
    ti ← s⊐k/mi
    ⟨𝕩, 𝕩⊔˜1-˜s(⊣×>)○(+`(≠𝕩)↑/⁼)1+e, ti, ti⊏(s+e)÷2⟩
  } 𝕩

  j←¯1↓((1-˜+`k)⊏ii)⊏˜⊏˜⍟≠{s←𝕩⊏˜g←⍋𝕩⋄(g/˜(⊒s)=s⊏mb⊏bp)⌾((⍷s)⊸⊏)↕≠mb}p
  je←j∾¯1
  q←(/k≤j≠p⊏je-la) (⊏≍⊣) p

  pd←⌊¨1+⌽∘∾○<˜˘˜˝ q ⊏ ⍉wh×je≍d
  dim←wh×⟨≠𝕩,1+⌈´d⟩+1‿0

  Path ← {𝕊 (sx‿sy)‿(ex‿ey):
    R←{(𝕨⌊𝕩)+↕1+|𝕨-𝕩}
    xs←sx R ex ⋄ ys←sy R ey
    p←¯1×sx>ex
    (xs∾⌜(¯1⊑ys))∾(p⊑xs)∾⌜ys
  }
  Draw←{𝕊g: {g∧𝕏g}¨⟨«,«˘,»,»˘⟩}
  T←{t‿x 𝕊 s: p←x-⌊(2÷˜≠t) ⋄ ∾(p↑s)‿t‿(s↓˜p+≠t) }
  repr←" ╷╶┌╵│└├╴┐─┬┘┤┴┼"
  tp←⌽⚇1 ⌈ii (1‿0+wh×≍)¨ (k/p)⊏d
  paths←⌽⚇1 Path¨<˘pd
  graphs←{1¨⌾(𝕩⊸⊑) 0⥊˜1+⌽dim}¨paths
  out←1↓repr⊏˜ +⟜(2⊸×)´ ∨´Draw¨graphs
  {y‿x𝕊ti: out (ti⊑toks)‿x⊸T⌾(y⊸⊏)↩}´˘⍉tp≍ti # place tokens
  out =⟜'╷'◶⊢‿'│'¨⌾⊏↩ # fix first row to look better
  <˘∾(∾" "‿src‿" ")‿out
}
