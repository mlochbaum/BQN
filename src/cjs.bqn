#! /usr/bin/env dbqn

# Javascript/JSON formatting
L ← "["∾"]"∾˜1↓·∾","⊸∾¨       # Native list/array
Ind ← {∾𝕨‿"["‿𝕩‿"]"}          # Native list/array indexing
Cat ← {∾𝕨‿".concat("‿𝕩‿")"}   # Native list/array concatenation (like ∾)
# Escape the special characters that appear in BQN sources.
Esc←{
  in ← (@+0‿9‿10‿13)∾"'"""    # Null, Tab, LF, CR, and quotes
  out ← "0tnr"                # Whitespace characters changed to letters
  i ← in⊐𝕩
  𝕩 ↩ i ⊏⟜out⌾((i<≠out)⊸/) 𝕩  # Replace
  ∾(i<≠in) /⟜"\"⊸∾¨ 𝕩         # Insert \
}
Str ← "str("""∾Esc∾""")"˜     # A BQN string
Char ← "'"(∾∾⊣)Esc∘⥊          # A BQN character
F ← •Fmt                      # Native format
FP ← ∞⊸=◶⟨F,"Infinity"⟩       # Format positive number
Num ← 0⊸≤◶⟨"-"∾FP∘|,FP⟩       # Format number

glyphs ← •Import "glyphs.bqn"
_getComp ← { (3+useInd) ↑ (𝕗 •Import "c.bqn"){𝔽} }
useInd ← "-i"≡⊑args←•args ⋄ args↓˜↩useInd
Comp ← ((<"runtime" Ind F)¨↕62) glyphs _getComp ⊢
J ← ∾∾⟜(@+10)¨
Fconst ← ≡◶⟨@⊸≤◶Num‿Char, Str, ⊑⟩
Fout ← (≠↑⟨F,Fconst,L F¨,F⟩˙) {L𝕎¨𝕩}¨ ⊢
Long ← ∾ (≠↑1‿3/⟨"  "⊸∾⋄((@+10)∾" ,")⊸∾⟩˙) {𝕎𝕩}¨ ⊢
LFC ← Long∘Fout∘Comp

RT ← {
  src‿need‿inputs←𝕩•Import"pr.bqn"
  pr←"runtime_0"‿"provide"{(∾𝕨<⊸(<∘Ind⟜F¨)⟜(↕≠)¨𝕩)⊏˜(∾𝕩)⊐∾need}○((-1+1=𝕩)⊸↑)inputs
  Long Fout pr need _getComp src
}
CArg ← {J (¯5⊸↓∾𝕩˙)⌾⊑ •FLines "c.bqn"}
SVG ← {∾⟨"Modify←GetHighlights←⊢⋄"⟩∾ •FChars∘∾⟜".bqn"¨ "../svg"‿𝕩}

•Out (⊑"r"‿"r0"‿"r1"‿"c"‿"cc"‿"f"‿"e"‿"p"⊐⊏)◶⟨
  RT∘2, RT∘0, RT∘1
  {𝕩⋄LFC CArg "⟨"∾"⟩"«∾","⊸∾¨'"'(⊣∾∾˜)¨glyphs}
  {𝕩⋄LFC "{"∾"}"∾˜CArg"𝕩"}
  {𝕩⋄LFC •FChars "f.bqn"}
  {𝕩⋄LFC SVG "e"}
  {𝕩⋄LFC SVG "p"}
  ¯1 ↓ · J L∘Fout∘Comp¨
⟩ args
