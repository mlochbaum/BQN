# BQN runtime hosted in BQN

⟨src,need⟩ ← •Import "src/pr.bqn"
compile ← need •Import "src/c.bqn"
glyphs ← ∾ •Import "src/glyphs.bqn"
vm ← •Import "vm.bqn"

FillFn ← (⊑1↑0↑⥊)⊘{𝕩˙⌾⊢ <𝕨}
_fillBy_ ← {
  r←𝕨𝔽x←𝕩 ⋄ G←𝔾
  𝕨({
    _f ← {(3⌊•Type)◶⟨𝔽,0,' ',⊢⟩}
    (FillFn⎊(!˙)_f 𝕨) G FillFn _f x
  }FillFn⊢)⎊⊢⍟(0=•Type∘⊢) r
}
GroupLen ← {(𝕨⌈≠)⊸↑0 FillFn≠¨⊔𝕩}
extra ← ⟨ •Type, FillFn, ⋆⁼, GroupLen, ∾⊔∘⊢, _fillBy_ ⟩
provide ← { g←𝕩∊glyphs ⋄ (⍋⍋g)⊏extra∾•BQN∘⥊¨g/𝕩 } ∾need

rt‿SetPrims‿SetInv ← VM ⟨provide,!∘0¨⟩ Compile src
PrimInd ← rt⊸⊐⌾<
Decompose ← ((≠glyphs)>PrimInd)◶⟨•Decompose,0⊸≍⟩
SetPrims ⟨ Decompose, PrimInd ⟩

rt
