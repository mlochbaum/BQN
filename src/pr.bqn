#!/usr/bin/env dbqn

# Process BQN runtime

# All primitives
chrs←•Import "glyphs.bqn"
glyphs ← ∾chrs

# Provided values, to be passed in through the constants array
alias‿def ← (⊑¨ ≍○< 1⊸↓¨) ⟨"?Type","∩Fill","⍣Log",
                           "$GroupLen","%GroupOrd","⍝_fillBy_"⟩
keep ← "!+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘⎊"

type ← ((+´·∧`'_'=0‿¯1⊸⊏)¨def) ∾ chrs((+`≠¨)∘⊣⍋∾⊸⊐)keep
need ⇐ type ⊔ alias∾keep

GetRepls ← {
  c‿n ← 𝕩
  ki ← (⊑¨c)⊐keep
  ⟨c,c⊣⌾(ki⊸⊏)n⟩∾¨⟨def,⥊¨alias⟩
}

⟨E_proc⟩ ← chrs‿GetRepls •Import "pp.bqn"

gd ← "glyphs←"""∾glyphs∾"%"""
rslt ← "⟨"∾"⟩"«∾","⊸∾¨glyphs  # Output all primitives
rr ← •FLines¨ "r0.bqn"‿"r1.bqn"
raw ← ∾⟨⟨gd⟩,∾rr,⟨"{PrimInd↩⊑𝕩⊐<⋄𝕩‿SetPrims}"∾rslt⟩⟩
src ⇐ ∾∾⟜(@+10)¨ E_proc¨ raw
