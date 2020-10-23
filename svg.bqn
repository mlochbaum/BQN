# Utilities for creating SVG diagrams as strings

# Snag the code highlighter from md.bqn
Highlight ← {
  AddT ← (↑∾"t"∾↓)¨˜⟜(1‿2⥊˜≢)⍟(𝕨⊣1)  # span to tspan
  (1¨ <⊸∾ ·AddT⌾⊑GetHighlights)⊸Modify 𝕩
}

IsLines ← 1<≡
DeNest ← {(3⌊≡)◶⟨!∘0,⥊<,⊢,∾𝕊¨⟩ ⥊𝕩}
Indent ← "  "⊸∾¨ DeNest

# Create a node from a tag name and interior text.
Enc ← {
  open ← ∾⟨"<",𝕨,">"⟩
  close← ∾⟨"</", (⊑𝕨⊐" ")↑𝕨, ">"⟩
  l ← IsLines 𝕩
  ∾ open (Indent⍟l 𝕩){𝕨‿𝕗‿𝕩}○(⥊∘<⍟l) close
}
Void ← {∾⟨"<",𝕩,"/>"⟩}

FmtNum ← {
  ! 0=≡𝕩
  ! (¯∞⊸< ∧ <⟜∞) 𝕩
  d ← 3 ⋆˜ b←10            # Base 10, up to 3 decimals
  _base ← {⌽b|⌊∘÷⟜b⍟(↕𝔽)}  # 𝔽 is the number of digits
  fl ← ⌊ abs ← (÷2×d) + |𝕩
  ∾ ⟨
    (𝕩<0) / "-"
    '0' + (1+·⌊b⋆⁼1⌈⊢)_base fl
    0⊸<◶""‿("." ∾ '0' + · ∨`⌾⌽∘×⊸/ 3 _base) ⌊ d × abs-fl
  ⟩
}
Fmt ← (2⌊≡)◶FmtNum‿(1↓·∾(' '∾FmtNum)¨)‿{𝕩⋄!0}

At1 ← " " ∾ {∾⟨𝕨,"='",𝕩,"'"⟩}´
Attr ← ∾⟜(∾ <∘At1⎉1)
At ← {
  _s ← {((+`×¬)⊸-𝕗⊸=)⊸⊔}
  𝕨 >⊘(∾⟜(∾At1¨)) '='_s¨ '|'_s 𝕩
}
Pos ← ⟨"x","y"⟩ ≍˘ FmtNum¨
Elt ← Void∘Attr

SVG ← {
  (∾∾⟜(10+@)¨)⍟IsLines ("svg" Attr ⟨"viewBox",Fmt 𝕨⟩) Enc 𝕩
}
