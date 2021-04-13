# Plot

width ← 384
pad   ← 2⥊10

pa ← At "class=Paren|stroke=currentColor|stroke-width=1"
pg ← At "class=red|style=fill:none|stroke-width=1"
rc ← At "class=code|stroke-width=1|rx=5"
gr ← "g" At "font-family=BQN,monospace|font-size=18px"
Path ← "path" Elt ⊣∾"d"≍○<⊢

Plot ← {
  "•Plot: 𝕨 and 𝕩 must be lists of numbers" ! 𝕨 ⊢⊘∧○((1==)◶⟨0,∧´@⊸>⟩) 𝕩
  "•Plot: 𝕨 and 𝕩 must have the same length" ! 𝕨 1⊘≡○≠ 𝕩
  xy ← 1e300 (⊣-⊸⌈⌊) ⟨𝕨↕∘≠⊘⊣𝕩, 𝕩⟩     # default x and clip
  win ← -˜`¨ bounds ← (⌊´≍⌈´)¨ xy     # min and range; min and max
  ar ← 1⍟((÷4)⊸>∨1.5⊸<) ÷˜´ 1⊑¨win    # height÷width
  dim ← width (⊣≍×) ar
  Scale ← ({¬𝕏}⌾(1⊸⊑) {𝕩÷˜𝕨-˜⊢}´¨ win) {𝕎𝕩}¨ ⊢
  line ← < 'M'⌾⊑ ∾⥊⍉ "L " ∾¨ FmtNum > dim × Scale xy
  ((-pad)∾dim+2×pad) SVG gr Enc ∾⥊¨ ⟨
    <"rect" Elt rc∾(Pos-pad÷2)∾"width"‿"height"≍˘FmtNum dim+pad
    pa⊸Path¨ ((0⊸≤∧≤⟜1)/·<∘∾˘("M "⊸∾˘"VH")∾¨·FmtNum dim×·∾⟜1˘(=⌜˜↕2)⊸×) Scale 0
    pg⊸Path¨ line
  ⟩
}
