# dzaima/BQN block headers have a different format to account for
# multiple bodies, and use variable names instead of counts.
# Rearrange and make up some names so the bytecode can be run.

glyphs ← •Import∘"../src/glyphs.bqn"⍟(0=≠) •args
compile ← glyphs •Import "../src/c.bqn"

special←<˘∘‿2⥊"𝕤𝕩𝕨𝕣𝕗𝕘"
DCompile⇐{
  ⟨bc,o,fblk,fbdy,ind,tok⟩ ← 6 ↑ (𝕨 •BQN∘⥊¨∘∾⊘⊣ glyphs) Compile 𝕩
  name ← ⊑2⊑tok
  blk ← 2(↑∾≍˜∘⊑)¨fblk
  bdy ← {⟨l,n,d,e⟩←𝕩 ⋄ ⟨l,((<"")⥊˜n-≠d)∾d⊏name,n-⊸↑e⟩}¨fbdy
  ⟨bc,o,blk,⊑blk,bdy,name,⊑ind,1⊑ind,𝕩⟩
}
DRun⇐•COMP∘DCompile
