#! /usr/bin/env dbqn

# dzaima/BQN block headers have a different format to account for
# multiple bodies, and use variable names instead of counts.
# Rearrange and make up some names so the bytecode can be run.

compile ← •Import •path∾"src/c.bqn"
prims ← (•Import •path∾"dzref"){𝔽} "⟨
  +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,↑,↓,↕,«,»,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔,!
  ˙,˜,˘,¨,⌜,⁼,´,˝,`
  ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟
⟩"

special←<˘∘‿2⥊"𝕤𝕩𝕨𝕣𝕗𝕘"
DCompile⇐{
  ⟨bc,o,fblk⟩ ← prims Compile 𝕩
  blk‿bdy ← <˘⍉>(↕≠fblk){
    ⟨t,i,l,n⟩←𝕩
    s←(3×i)↓(t⊑3‿5‿6)↑special
    ⟨⟨t,i,𝕨,𝕨⟩ ⋄ ⟨l, s∾⥊¨'a'+↕n-≠s⟩⟩
  }¨fblk
  ⟨bc,o,blk,bdy⟩
}
DRun⇐•COMP∘DCompile
