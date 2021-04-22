#!/usr/bin/env dbqn

# Process BQN runtime

# All primitives
chrs←•Import "glyphs.bqn"
glyphs ⇐ ∾chrs

# Provided values, to be passed in through the constants array
def ← ⟨"Type","Fill","Log","GroupLen","GroupOrd","_fillBy_"⟩
keep ← "!+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘⎊"
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

gd ← "glyphs←"""∾glyphs∾"%"""
rslt ← "⟨"∾"⟩"«∾","⊸∾¨glyphs  # Output all primitives
src ← ∾⟨⟨gd⟩,•FLines"r.bqn",⟨"{PrimInd↩⊑𝕩⊐<⋄𝕩‿SetPrims}"∾rslt⟩⟩
ref ⇐ ∾∾⟜(@+10)¨ E_proc¨ src
