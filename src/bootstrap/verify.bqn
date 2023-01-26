glyphs ← •Import "../glyphs.bqn"
gl ← ("⟨"∾"⟩"«∾","⊸∾¨'"'(⊣∾∾˜)¨glyphs)      # Has to replace •args in c.bqn

f ← ⟨"../c.bqn"⟩∾("boot"∾∾⟜".bqn")¨'1'+↕3   # Files to test
c ← (1‿3/⟨glyphs⊸•Import,•Import⟩) {𝕎𝕩}¨ f  # Resulting compilers
c ↩ (∾glyphs){𝕗⊸𝕏}¨ c
t ← (∾∾⟜(@+10)¨)¨ (¯5⊸↓∾gl˙)⌾⊑⌾⊑ •FLines¨ f # Compiler source

# Check that compiler 𝕩 compiles 𝕩-1 same as full compiler
Ver ← {
  norm ← {𝕎𝕏}˜´ 𝕩 ↑ ⟨
    4⊸↑              # Strip source info, always
    ⋈⁼∘∾⍟=¨⌾(2⊑¨2⊸⊑) # Turn only-dyadic functions to ambivalent, only ≥2
    (⊢-2×34⊸=)⌾⊑     # VARU to VARO, could hit non-opcode numbers, oh well
  ⟩
  ! ≡○Norm´ (0‿𝕩⊏c) {𝕎𝕩}¨ (𝕩-1)⊏t
  •Out ∾⟨"Boot -",'0'+𝕩," verified!"⟩
}
Ver¨ 1+↕3

•Out ""
•Out "Compile times, in milliseconds:"
•Show 1e3÷˜⌊1e6× (∨○(3⊸>)∧1≥-)◶∞‿{30(𝕨⊑c)•_timed𝕩⊑t}⌜˜ ↕≠c
