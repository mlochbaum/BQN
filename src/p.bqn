# Plot

width ← 384
pad   ← 2⥊10

ps ← At "class=red|style=fill:none|stroke-width=1"
rc ← At "class=code|stroke-width=1|rx=5"
gr ← "g" At "font-family=BQN,monospace|font-size=18px"

Plot ← {
  "•Plot: 𝕨 and 𝕩 must be lists of numbers" ! 𝕨 ⊢⊘∧○((1==)◶⟨0,∧´@⊸>⟩) 𝕩
  "•Plot: 𝕨 and 𝕩 must have the same length" ! 𝕨 1⊘≡○≠ 𝕩
  xy ← 1e300 (⊣-⊸⌈⌊) ⟨𝕨↕∘≠⊘⊣𝕩, 𝕩⟩     # default x and clip
  bounds ← (-˜`⌊´≍⌈´)¨ xy             # min and range
  ar ← 1⍟((÷4)⊸>∨1.5⊸<) ÷˜´ 1⊑¨bounds # height÷width
  dim ← width (⊣≍×) ar
  scale ← {𝕩÷˜𝕨-˜⊢}´¨ bounds
  p ← dim × ≍⟜¬´ scale {𝕎𝕩}¨ xy
  path ← 'M'⌾⊑ ∾⥊⍉ "L " ∾¨ FmtNum p
  ((-pad)∾dim+2×pad) SVG gr Enc ⟨
    "rect" Elt rc∾(Pos-pad÷2)∾"width"‿"height"≍˘FmtNum dim+pad
    ("path" Elt ps∾"d"≍○<⊢) path
  ⟩
}
