# Plot

dim← 2⥊384
pad← 2⥊10

ps ← At "class=red|style=fill:none|stroke-width=1"
rc ← At "class=code|stroke-width=1|rx=5"
gr ← "g" At "font-family=BQN,monospace|font-size=18px"

Plot ← {
  "•Plot: 𝕨 and 𝕩 must be lists of numbers" ! 𝕨 ⊢⊘∧○((1==)◶⟨0,∧´@⊸>⟩) 𝕩
  "•Plot: 𝕨 and 𝕩 must have the same length" ! 𝕨 1⊘≡○≠ 𝕩
  Norm ← ÷⟜(⌈´)·-⟜(⌊´)1e300(⊣-⊸⌈⌊)⊢
  path ← 'M'⌾⊑ ∾⥊⍉ "L " ∾¨ FmtNum dim × (𝕨 ↕∘≠⊘⊣ 𝕩) ≍⟜¬○Norm 𝕩
  ((-pad)∾dim+2×pad) SVG gr Enc ⟨
    "rect" Elt rc∾(Pos-pad÷2)∾"width"‿"height"≍˘FmtNum dim+pad
    ("path" Elt ps∾"d"≍○<⊢) path
  ⟩
}
