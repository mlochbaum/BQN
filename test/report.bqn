Native ← Exec ← •BQN

Trim ← ((∨`∧∨`⌾⌽)' '⊸≠)⊸/

Supports ← {
  l ← (0<≠)◶0‿('#'≠⊑)¨⊸/ ∾ {•FLines "cases/"∾𝕩∾".bqn"}¨𝕩
  c ← ('%'⊸= (∨´⊣)◶⟨"1"⋈⊢, Trim¨(+`-2⊸×)⊸⊔⟩ ⊢)¨ l
  r ← {("!"⊸≡◶⟨<Native,0˙⟩𝕨) ≢ <∘Exec⎊0𝕩}´¨ c
  f‿e ← +` 2↑/⁼ r / ("!"≡⊑)¨c
  W ← ∾⟜(∾⟜" of "⊸∾○•Repr⟜(≠c))
  f 0⊸≠◶⟨"Passing", 0⊸≠◶"Ignores errors: "‿"Failed "⊸W⟩ e
}
Row ← {∾"| "‿𝕨‿" | "‿𝕩}
head ← ⋈⟜(⊢+'|'⊸≠×'-'⊸-) "Feature     " Row "Support"
•Out ¯1↓ ∾ ∾⟜(@+10)¨ head ∾ Row⟜Supports´¨ ⟨
  ⟨"Basics      ", "bytecode"‿"simple"‿"literal"‿"token"‿"syntax"‿"prim"⟩
  ⟨"Inferred    ", "identity"‿"undo"‿"under"⟩
  ⟨"Fills       ", ⋈"fill"⟩
  ⟨"Headers     ", ⋈"header"⟩
  ⟨"Namespaces  ", ⋈"namespace"⟩
  ⟨"Undo headers", ⋈"unhead"⟩
⟩
