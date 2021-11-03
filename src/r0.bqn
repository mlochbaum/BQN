# BQN runtime part 0. Requires:
#   Fill _fillBy_
#   +-×⌊=≤≢⥊⊑↕⌜⊘
# Provides:
#   ⌊⌈|<>≠≥⊢⊣∾⋈↑↓⊏˙˜´∘○⊸⟜◶⍟
#   ^^^^^^^  ^^^^^  ^    ^^ are limited, suitable for r1

⊢ ← {𝕩}
⊣ ← {𝕩}⊘{𝕨}
˙ ← {𝕩⋄𝕗}
˜ ← {𝕩𝔽𝕨⊣𝕩}
∘ ← {𝔽𝕨𝔾𝕩}
○ ← {(𝔾𝕨)𝔽𝔾𝕩}
⊸ ← {(𝔽𝕨⊣𝕩)𝔾𝕩}
⟜ ← {(𝕨⊣𝕩)𝔽𝔾𝕩}
◶ ← {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}     # LIMITED to number left operand result
⍟ ← {𝕨((𝕨𝔾𝕩)⊑⊢‿𝕗){𝔽}𝕩}   # LIMITED to boolean right operand result

Box ← {𝕩Fill⟨⟩⥊⟨𝕩⟩}
# LIMITED to numeric arguments for arithmetic cases
≥ ←            ≤˜
< ← Box      ⊘ (1-≥)
> ←            (1-≤)
⌊ ↩ ⌊        ⊘ (⊣-≥×-)
⌈ ← -∘⌊∘-    ⊘ (⊣-≤×-)
| ← 0⊸≤◶-‿⊢
≠ ← (0<=)◶⟨1⋄0⊑≢⟩  # LIMITED to monadic case

⋈ ← {⟨𝕩⟩} ⊘ {⟨𝕨,𝕩⟩}                # LIMITED by not having a result fill
∾ ← {k←≠𝕨⋄k⊸≤◶⟨⊑⟜𝕨⋄-⟜k⊑𝕩˜⟩⌜↕k+≠𝕩}  # LIMITED to two list arguments
↑ ← {⊑⟜𝕩⌜↕𝕨}                       # LIMITED to number 𝕨 and list 𝕩
↓ ← {(𝕨⊸+⊑𝕩˙)⌜↕(≠𝕩)-𝕨}             # LIMITED to number 𝕨 and list 𝕩

¨ ← { d←⥊𝕩⋄(≢𝕩)⥊(⊑⟜(⥊𝕨)𝔽⊑⟜d)⌜↕≠d } # LIMITED to equal-shape arrays

_fold0←{
  l←≠𝕩 ⋄ F←𝔽
  r←𝕨 {l↩l-1⋄l⊑𝕩}⊘⊣ 𝕩
  ({r↩𝕩 F r}(l-1)⊸-⊑𝕩˙)⌜↕l
  r
}
´ ← _fold0    # LIMITED to nonempty list 𝕩, or 𝕨 and list 𝕩

GetCells←(1==∘⊢)◶{
  c←1×´s←1↓≢𝕩
  (c⊸×⌜𝕨)(+⊑(⥊𝕩)˙)⌜s⥊↕c
}‿{
  ⊑⟜𝕩⌜𝕨
} _fillBy_ ⊢
⊏ ← GetCells  # LIMITED to depth-1 natural number left argument
