files‿opts ← 2 ↑ ('-'=⊑)¨⊸⊔ •args
files ↩ (0<≠)◶⟨1,∨´"all"⊸≡¨⟩◶⟨∾⟜".bqn"¨, •file.List∘"cases"⟩ files
⟨noerr⟩ ← ⟨"-noerr"⟩ ∊ opts

Native ← Exec ← •BQN

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
r ← (M '%'⊸= (∨´⊣)◶⟨"1"⋈⊢, Trim¨(+`-2⊸×)⊸⊔⟩ ⊢)¨ c
•Out 0⊸<◶⟨"All passed!",•Repr∾" failed!"˙⟩ +´r
