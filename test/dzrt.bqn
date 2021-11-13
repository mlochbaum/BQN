# Runtime hosted in dzaima/BQN

⟨src,need⟩ ← •Import "../src/pr.bqn"
⟨DRun⟩ ← need •Import "dc.bqn"
glyphs ← ∾ •Import "../src/glyphs.bqn"

GroupLen ← {(𝕨⌈≠)⊸↑0•FillFn≠¨⊔𝕩}
extra ← ⟨ •Type, •FillFn, ⋆⁼, GroupLen, ∾⊔∘⊢, •_fillBy_ ⟩
provide ← { g←𝕩∊glyphs ⋄ (⍋⍋g)⊏extra∾•BQN∘⥊¨g/𝕩 } ∾need

rt‿SetPrims ← ⟨provide,!∘0¨⟩ DRun src
PrimInd ← rt⊸⊐⌾<
Decompose ← ((≠glyphs)>PrimInd)◶⟨•Decompose,0⊸⋈⟩
SetPrims ⟨ Decompose, PrimInd ⟩

rt
