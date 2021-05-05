#! /usr/bin/env dbqn

# dzaima/BQN block headers have a different format to account for
# multiple bodies, and use variable names instead of counts.
# Rearrange and make up some names so the bytecode can be run.

glyphs ← •Import∘"src/glyphs.bqn"⍟(0=≠) •args
compile ← glyphs •Import "src/c.bqn"

special←<˘∘‿2⥊"𝕤𝕩𝕨𝕣𝕗𝕘"
DCompile⇐{
  ⟨bc,o,fblk,ind,tok⟩ ← 5 ↑ (𝕨 •BQN∘⥊¨∘∾⊘⊣ glyphs) Compile 𝕩
  name ← ⊑2⊑tok
  blk‿bdy ← <˘⍉>(↕≠fblk){
    ⟨t,i,l,n,d,e⟩←𝕩
    s←(3×i)↓(t⊑3‿5‿6)↑special
    ⟨⟨t,i,𝕨,𝕨⟩ ⋄ ⟨l, s∾d⊏name, (0¨s)∾e⟩⟩
  }¨fblk
  ⟨bc,o,blk,⊑blk,bdy,⊑ind,1⊑ind,𝕩⟩
}
DRun⇐•COMP∘DCompile
