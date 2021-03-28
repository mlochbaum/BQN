# BQN hosted in dzaima/BQN
# Result is a function that executes BQN code.

⟨DRun,DCompile⟩ ← •Import "dc.bqn"
⟨ref,glyphs⟩ ← •Import "src/pr.bqn"

provide ← ⟨
  •Type           # Type
  •FillFn         # Fill
  ⋆⁼              # Log
  {(𝕨⌈≠)⊸↑≠¨⊔𝕩}   # GroupLen
  ∾⊔∘⊢            # GroupOrd
  !,+,-,×,÷,⋆,⌊,=,≤,≢,⥊,⊑,↕,⌜,`,•_fillBy_,⊘
⟩
rt‿SetPrims ← •COMP provide⊸(⊣»«)⌾(1⊸⊑) DCompile ref
PrimInd ← rt⊸⊐⌾<
Decompose ← ((≠glyphs)>PrimInd)◶⟨•Decompose,0⊸≍⟩
SetPrims ⟨ Decompose, PrimInd ⟩
rt⊸DRun
