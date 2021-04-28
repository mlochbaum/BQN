# BQN hosted in dzaima/BQN
# Result is a function that executes BQN code.

⟨src,need⟩ ← •Import "src/pr.bqn"
⟨DRun⟩     ←      •Import "dc.bqn"
⟨DCompile⟩ ← need •Import "dc.bqn"
glyphs ← ∾ gl ← •Import "src/glyphs.bqn"

GroupLen ← {(𝕨⌈≠)⊸↑0•FillFn≠¨⊔𝕩}
extra ← ⟨ •Type, •FillFn, ⋆⁼, GroupLen, ∾⊔∘⊢, •_fillBy_ ⟩
provide ← { g←𝕩∊glyphs ⋄ (⍋⍋g)⊏extra∾•BQN¨g/𝕩 } ∾need

rt‿SetPrims ← •COMP ⟨provide,(•BQN"•"⊸∾)¨⟩ DCompile src
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
