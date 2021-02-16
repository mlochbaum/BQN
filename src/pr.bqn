#!/usr/bin/env dbqn

# Process BQN runtime

# All primitives
chrs←⟨
  "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!"
  "˙˜˘¨⌜⁼´˝`"
  "∘○⊸⟜⌾⊘◶⎉⚇⍟"
⟩
glyphs ⇐ ∾chrs

# Provided values, to be passed in through the constants array
def ← ⟨"Type","Decompose","Glyph","Fill","Log","GroupLen","GroupOrd","_fillBy_"⟩
keep ← "!+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘"
len ⇐ def+○≠keep

GetRepls ← {
  c‿n ← 𝕩
  ki ← (⊑¨c)⊐keep
  dt ← ⊔⟜⊒ (+´·∧`'_'=0‿¯1⊸⊏)¨ def
  ns ← » ne←+`≠¨chrs
  kt ← ∾ (ns+≠¨dt) + ⊔⟜⊒ne⍋ki
  ⟨c,(kt⊏c)⌾(ki⊸⊏)n⟩∾¨⟨def,(∾ns+dt)⊏c⟩
}

⟨E_proc⟩ ← chrs‿GetRepls •Import "pp.bqn"

rslt ← "⟨"∾"⟩"«∾","⊸∾¨glyphs  # Output all primitives
ref ⇐ ∾∾⟜(@+10)¨ E_proc¨ (•FLines "r.bqn")∾<rslt
