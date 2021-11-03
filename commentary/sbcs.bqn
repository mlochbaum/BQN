# Single-Byte Character System (SBCS) for BQN
# This file implements an alternative character encoding for BQN, in
# which each character uses one byte.
# It must exist in order to count BQN characters as bytes for code golf,
# but never needs to be used.
#
# To use:
# $ bqn sbcs.bqn -ef infile.bqn outfile.bqn  # Encode with SBCS
# $ bqn sbcs.bqn outfile.bqn                 # Run with SBCS

cs←"×÷⋆√⌊⌈¬∧∨≠≤≥≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉⍋⍒⊏⊑⊐⊒∊⍷⊔˙˜˘¨⌜⁼´˝∘○⊸⟜⌾⊘◶⎉⚇⍟⎊⋄⇐←↩⟨⟩‿·𝕊𝕏𝕎𝔽𝔾𝕤𝕩𝕨𝕗𝕘π∞¯•"
base←@+128
off←0∾˜cs-base+↕≠cs

Decode ← (off(⊣⊏˜¯1⌈≠⊸⌊)-⟜base)⊸+
Encode ← -⟜(cs⊸⊐⊏off˙)

WriteFile ← •FBytes⟜Encode
RunFile ← •BQN Decode∘•FBytes

(⊑"-e"‿"-ef"‿"--"⊐⊏)◶⟨
  •Out∘Encode 1⊸⊑
  WriteFile⟜•FChars˜´ 1⊸↓
  RunFile 1⊸⊑
  RunFile ⊑
⟩ •args
