#! ./dzref

# dzaima/BQN block headers are a little different from the version used
# in the Javascript implementation:
# - Types are f/m/d instead of 0/1/2
# - dzaima/BQN uses variable names instead of counts (but we make the
#   names up anyway, except for special names).

compile ← ⟨•path∾"src/c.bqn","Compile"⟩ •EX •path∾"dzref"

prims←⟨
  +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,↑,↓,↕,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔,!
  ˙,˜,˘,¨,⌜,⁼,´,˝,`
  ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟
⟩
special←<˘∘‿2⥊"𝕤𝕩𝕨𝕣𝕗𝕘"
DRun←{
  ⟨bc,o,blk⟩ ← prims Compile 𝕩
  blk ↩ {
    ⟨t,i,l,n⟩←𝕩
    s←(3×i)↓(t⊑3‿5‿6)↑special
    ⟨t⊑"fmd",i,l,s∾⥊¨'a'+↕n-≠s⟩
  }¨blk
  •COMP ⟨bc,o,⟨⟩,blk⟩
}
