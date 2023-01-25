glyphs ← •Import "../glyphs.bqn"
gl ← ("⟨"∾"⟩"«∾","⊸∾¨'"'(⊣∾∾˜)¨glyphs)      # Has to replace •args in c.bqn

f ← ⟨"../c.bqn"⟩∾("boot"∾∾⟜".bqn")¨'1'+↕3   # Files to test
c ← (1‿3/⟨glyphs⊸•Import,•Import⟩) {𝕎𝕩}¨ f  # Resulting compilers
c ↩ (∾glyphs){𝕗⊸𝕏}¨ c
t ← (∾∾⟜(@+10)¨)¨ (¯5⊸↓∾gl˙)⌾⊑⌾⊑ •FLines¨ f # Compiler source

# 4⊸↑ to strip source info
# ⋈⁼∘∾⍟=¨⌾(2⊑¨2⊸⊑) to turn only-dyadic functions to ambivalent
! ≡○(4⊸↑)´ (2↑c) {𝕎𝕩}¨ ⊏t
•Out "Boot -1 verified!"
! ≡○(⋈⁼∘∾⍟=¨⌾(2⊑¨2⊸⊑) 4⊸↑)´ (0‿2⊏c) {𝕎𝕩}¨ 1⊏t
•Out "Boot -2 verified!"
! ≡○(⋈⁼∘∾⍟=¨⌾(2⊑¨2⊸⊑) 4⊸↑)´ (0‿3⊏c) {𝕎𝕩}¨ 2⊏t
•Out "Boot -3 verified!"
