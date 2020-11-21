#! /usr/bin/env dbqn

# dzaima/BQN block headers have a different format to account for
# multiple bodies, and use variable names instead of counts.
# Rearrange and make up some names so the bytecode can be run.

compile ← •Import "src/c.bqn"
prims ← (•Import "dzref"){𝔽} "⟨
  +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,↑,↓,↕,«,»,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔,!
  ˙,˜,˘,¨,⌜,⁼,´,˝,`
  ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟
⟩"

LEB←{
  b←128
  s←+`»i←1+l←⌊b⋆⁼1⌈𝕩
  o←⍋⍋↕∘≠⊸-i/s
  v←o⊏l{f←×𝕨⋄(𝕨-1)(b⊸(×⟜f+|)∾𝕊⟜(⌊÷⟜b)○(f⊸/))⍟(∨´f)𝕩}𝕩
  v‿s‿i
}

special←<˘∘‿2⥊"𝕤𝕩𝕨𝕣𝕗𝕘"
DCompile⇐{
  ⟨bc,o,fblk,ind⟩ ← 4 ↑ prims Compile 𝕩
  bcl‿el‿ol←LEB bc
  blk‿bdy ← <˘⍉>(↕≠fblk){
    ⟨t,i,l,n⟩←𝕩
    s←(3×i)↓(t⊑3‿5‿6)↑special
    ⟨⟨t,i,𝕨,𝕨⟩ ⋄ ⟨l⊑el, s∾⥊¨'a'+↕n-≠s⟩⟩
  }¨fblk
  ⟨bcl,o,blk,bdy,ol/⊑ind,ol/1⊑ind,𝕩⟩
}
DRun⇐•COMP∘DCompile
