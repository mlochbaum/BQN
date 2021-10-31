#! /usr/bin/env bqn

# Tests for components of BQN: compiler, runtime, primitive spec

files‿opts ← 2 ↑ ('-'=⊑)¨⊸⊔ •args
files ↩ (0<≠)◶⟨1,∨´"all"⊸≡¨⟩◶⟨∾⟜".bqn"¨, •file.List∘"cases"⟩ files
nc‿rt‿ref‿noerr ← "-nocomp"‿"-rt"‿"-ref"‿"-noerr" ∊ opts
"Can't test runtime without the compiler!" ! ¬nc∧rt∨ref

Native ← •BQN
ReBQN ← {𝕊 rt:
  compile ← (•Import "../src/glyphs.bqn") •Import "../src/c.bqn"
  vm ← •Import "../vm.bqn"
  BQN ← ⟨rt,{𝕊"bqn":BQN}¨⟩⊸(VM Compile)
}
exec ← ((rt⌈2×ref)¬nc)◶⟨
  Native˙                                          # Native
  {𝕤⋄ ReBQN •BQN∘⥊¨ ∾•Import "../src/glyphs.bqn"}  # Compiled; native runtime
  {𝕤⋄ ReBQN •Import "../rt.bqn"}                   # Self-hosted
  {𝕤⋄ ReBQN •Import "ref.bqn"}                     # Reference implementations
⟩ @

c ← ∾ ((0<≠)◶0‿('#'≠⊑)¨⊸/ · •file.Lines "cases/"⊸∾)¨ files
c ↩ ('!'≠⊑)¨⊸/⍟noerr c
•Out 1↓∾' '⊸∾¨∾⟨
  ⟨"Running",•Repr≠c,"tests:"⟩
  noerr/⟨"(error cases excluded)"⟩
  ¯4↓¨files
⟩

Trim ← ((∨`∧∨`⌾⌽)' '⊸≠)⊸/
M ← {e‿b←𝕩
  Msg ← {∾⟨
    """",b,""": expected "
    "to fail"⍟("!"⊸≡)e
    " but "
    0⊸≡◶⟨"received "∾·•Repr⎊"{…}"⊑,"evaluation failed"⟩𝕩
  ⟩}
  ("!"⊸≡◶⟨<Native,0˙⟩ e) ≢◶⟨0,1∘•Out∘Msg⟩ <∘Exec⎊0 b
}
r ← (M '%'⊸= (∨´⊣)◶⟨"1"≍○<⊢, Trim¨(+`-2⊸×)⊸⊔⟩ ⊢)¨ c
•Out 0⊸<◶⟨"All passed!",•Repr∾" failed!"˙⟩ +´r
