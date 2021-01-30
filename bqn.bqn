# BQN hosted in dzaima/BQN
# Result is a function that executes BQN code.

⟨DRun,DCompile⟩ ← •Import "dc.bqn"
⟨ref,glyphs⟩ ← •Import "src/pr.bqn"

PrimInd ← {⊑rt⊐<𝕩}
Decompose ← ((≠glyphs)>PrimInd)◶⟨•Decompose,0⊸≍⟩
provide ← ⟨
  •Type           # Type
  Decompose       # Decompose
  glyphs⊑˜PrimInd # Glyph
  •FillFn         # Fill
  ⋆⁼              # Log
  ≠¨⊔             # GroupLen
  ∾⊔∘⊢            # GroupOrd
  !,+,-,×,÷,⋆,⌊,=,≤,≢,⥊,⊑,↕,⌜,`,•_fillBy_,⊘
⟩
rt ← •COMP provide⊸(⊣»«)⌾(1⊸⊑) DCompile ref
rt⊸DRun
