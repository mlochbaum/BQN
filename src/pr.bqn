#!/usr/bin/env dbqn

# Process BQN runtime

impl ← •FLines "r.bqn"

chrs←⟨
  "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!"
  "˙˜˘¨⌜⁼´˝`"
  "∘○⊸⟜⌾⊘◶⎉⚇⍟"
⟩
nc ← ≠¨chrs
glyphs ⇐ chr ← ∾chrs
itr ← 0⥊˜≠chr

idChars ← "_¯.π∞"∾∾"0aA"+⟜↕¨10‿26‿26

init ← " "⊸∾¨(/⟜"_"¨nc/0‿1‿1)∾¨(nc/"FMD")∾¨(nc+´⊸↑⥊"ABC"∾⌜•a)
post ← ∾⟜" "¨/⟜"_"¨nc/0‿0‿1
out ← init∾¨'0'∾¨post

Inc ← {
  i←⊑chr⊐𝕩
  n←0 ⋄ itr↩{n↩1+𝕩}⌾(i⊑⊢)itr
  out↩((i⊑init)∾('0'+n)∾i⊑post)⌾(i⊑⊢)out
}

# Required functionality passed in as an argument
def ← ⟨"Type","Decompose","Glyph","Fill","Log","GroupLen","GroupOrd","_fillBy_"⟩
keep ← "!+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘"
len ⇐ def+○≠keep
ki ← chr⊐keep
dt ← ⊔⟜⊒ (+´·∧`'_'=0‿¯1⊸⊏)¨ def
ns ← » ne←+`nc
kt ← ∾ (ns+≠¨dt) + ⊔⟜⊒ne⍋ki

chrt ← ⥊¨chr
in  ← chrt                  ∾ def
out ↩ ((kt⊏chrt)⌾(ki⊸⊏)out) ∾ (∾ns+dt)⊏chrt

E_isdef ← (3≤≠)◶⟨0,∧´⟨chr," ","←↩"⟩∊˜¨3⊸↑⟩
E_proc ← {
  q←≠`𝕩='"' ⋄ q∨↩≠`q<𝕩=''' ⋄ f←¬∨`q<𝕩='#'
  t ← (¯1+`·¬(»f/q)∨·»⊸∧∊⟜idChars)⊸⊔ f/𝕩
  ∾ (in⊸⊐ ⊑⟜out⍟(<⟜(≠in))¨ ⊢) t
}
E_redef ← { # handles [fmd] [←↩]
  tail ← E_proc 3↓𝕩 # must use old def
  Inc ⊑𝕩
  (E_proc 1↑𝕩) ∾ "←" ∾ tail
}

ref ⇐ ∾∾⟜(@+10)¨ E_isdef◶E_proc‿E_redef¨ impl∾<"⟨"∾"⟩"«⥊","⊸∾˘chr
