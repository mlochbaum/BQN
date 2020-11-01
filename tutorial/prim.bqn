# Show keys and names for primitives
# Input is a list of "glyph%keys%Monad%Dyad" strings

Primitives ← {
  Row ← {
    s ← ¯1⊸↓⌾(¯1⊸⊑) ((+`×¬)⊸-'%'⊸=)⊸⊔ 𝕩∾" "
    t ← ⟨0⊸Highlight, ("kbd"Enc"\"⊸∾)⍟≠⟩⊸({𝕎𝕩}¨)⌾(2⊸↑) s
    "tr" Enc ((3<≠s)◶⟨2⊸/∾∾⟜" colspan='2'"¨,4⊸/⟩ ⟨"td"⟩) Enc¨ t
  }
  "table class='primitives'" Enc Row¨ 𝕩
}
