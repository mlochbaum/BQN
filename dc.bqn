#! /usr/bin/env dbqn

# dzaima/BQN block headers have a different format to account for
# multiple bodies, and use variable names instead of counts.
# Rearrange and make up some names so the bytecode can be run.

glyphs ← •Import "src/glyphs.bqn"
compile ← glyphs •Import "src/c.bqn"
prims ← •BQN∘⥊¨ ∾glyphs

special←<˘∘‿2⥊"𝕤𝕩𝕨𝕣𝕗𝕘"
DCompile⇐{
  ⟨bc,o,fblk,ind⟩ ← 4 ↑ (𝕨⊣prims) Compile 𝕩
  blk‿bdy ← <˘⍉>(↕≠fblk){
    ⟨t,i,l,n⟩←𝕩
    s←(3×i)↓(t⊑3‿5‿6)↑special
    ⟨⟨t,i,𝕨,𝕨⟩ ⋄ ⟨l, s∾⥊¨'a'+↕n-≠s⟩⟩
  }¨fblk
  ⟨bc,o,blk,⊑blk,bdy,⊑ind,1⊑ind,𝕩⟩
}
DRun⇐•COMP∘DCompile
