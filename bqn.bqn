# BQN hosted in dzaima/BQN
# Result is a function that executes BQN code.

⟨ref,prims⟩ ← •Import "src/pr.bqn"
⟨DRun⟩     ←       •Import "dc.bqn"
⟨DCompile⟩ ← prims •Import "dc.bqn"
glyphs ← ∾ •Import "src/glyphs.bqn"

provide ← ⟨
  •Type           # Type
  •FillFn         # Fill
  ⋆⁼              # Log
  {(𝕨⌈≠)⊸↑≠¨⊔𝕩}   # GroupLen
  ∾⊔∘⊢            # GroupOrd
  !,+,-,×,÷,⋆,⌊,=,≤,≢,⥊,⊑,↕,⌜,`,•_fillBy_,⊘,⎊
⟩
rt‿SetPrims ← •COMP ⟨provide,(•BQN"•"⊸∾)¨⟩ DCompile ref
PrimInd ← rt⊸⊐⌾<
Decompose ← ((≠glyphs)>PrimInd)◶⟨•Decompose,0⊸≍⟩
SetPrims ⟨ Decompose, PrimInd ⟩

sys ← {𝕩⊏˜𝕨⊸⊐}˝⍉>⟨
  "bqn"‿{BQN𝕩}
  "type"‿•Type
  "glyph"‿(glyphs⊑˜PrimInd)
  "decompose"‿Decompose
⟩
BQN ← ⟨rt,Sys⟩⊸DRun
