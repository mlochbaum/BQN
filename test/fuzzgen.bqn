GetGen ← { 𝕊 ⟨Range,Subset,Deal⟩: # 𝕩 is a •MakeRand instance
  Int ⇐ { (1⊸<⊸×m÷2) -˜ 𝕩 Range m←2⋆2⋆𝕨 }
  Interval ⇐ ⊑∘⊣ + -˜´⊸(Range˜)
  Unit ⇐ Range⟜0

  Sel ⇐ Range⟜≠⊏⊢
  Shuffle ⇐ Deal∘≠⊸⊏
  Diffs ⇐ -⟜((0⌊1⊸↑)⊸»)∘∧

  # 𝕨 positive (not zero) integers summing to 𝕩
  Part ← ¯1 (⊢-») (Subset∾⊢)○(-⟜1)
  Stretch ⇐ Part˜⟜≠/⊢

  surr ← (2⋆11)×27+↕2
  ToChar ⇐ @ + (1≠surr⊸⍋)⊸×
}
{ 1=≠•args ? GetGen •MakeRand ⊑•args ; GetGen }
