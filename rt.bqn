# BQN runtime hosted in BQN

⟨src,need⟩ ← •Import "src/pr.bqn"
compile ← need •Import "src/c.bqn"
glyphs ← ∾ •Import "src/glyphs.bqn"
vm ← •Import "vm.bqn"

FillFn ← (⊑1↑0↑⥊)⊘{𝕩˙⌾⊢ <𝕨}
_fillBy_ ← {𝕘⋄𝔽}
GroupLen ← {(𝕨⌈≠)⊸↑0 FillFn≠¨⊔𝕩}
extra ← ⟨ •Type, FillFn, ⋆⁼, GroupLen, ∾⊔∘⊢, _fillBy_ ⟩
provide ← { g←𝕩∊glyphs ⋄ (⍋⍋g)⊏extra∾•BQN∘⥊¨g/𝕩 } ∾need

rt‿SetPrims ← VM ⟨provide,!∘0¨⟩ Compile src
PrimInd ← rt⊸⊐⌾<
Decompose ← ((≠glyphs)>PrimInd)◶⟨•Decompose,0⊸≍⟩
SetPrims ⟨ Decompose, PrimInd ⟩

rt
