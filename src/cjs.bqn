#! /usr/bin/env dbqn

compile ← •Import "c.bqn"
useInd ← "-i"≡⊑args←•args ⋄ args↓˜↩useInd
Comp ← (3+useInd) ↑ ((<"runtime["∾⍕∾"]"˙)¨↕62)⊸Compile
FP ← ∞⊸=◶⟨⍕,"Infinity"⟩
Esc ← (⟨"\t","\n","\r","\'","\"""⟩∾<∘⥊)⊑˜("'"""∾˜@+9‿10‿13)⊑∘⊐⊢
Str ← "str("""∾(∾Esc¨)∾""")"˜
Char ← "'"(∾∾⊣)Esc
Fconst ← ≡◶⟨(⊑⍋)∘(∾⟜∞)◶⟨0⊸≤◶⟨"-"∾FP∘|,FP⟩,Char⟩⋄Str⋄⊑⟩
L ← "["∾"]"∾˜1↓·∾","⊸∾⟜⍕¨
J ← ∾∾⟜(@+10)¨
Fout ← (≠↑⟨⊢,Fconst,L,⊢⟩˙) {L𝕎¨𝕩}¨ ⊢
Frun ← ("provide.concat("∾∾⟜")")⌾(1⊸⊑) Fout
Long ← ∾ (≠↑1‿3/⟨"  new Uint8Array("∾∾⟜")"⋄((@+10)∾" ,")⊸∾⟩˙) {𝕎𝕩}¨ ⊢
• ← (⊑"r"‿"c"‿"fmt"‿"e"⊐⊏)◶⟨
  {𝕩⋄ref‿len←•Import"pr.bqn"⋄Long Frun len⊸↓⌾(1⊸⊑)Comp ref}
  {𝕩⋄Long Fout Comp J •LNS "c.bqn"}
  {𝕩⋄Long Fout Comp J •LNS "fmt.bqn"}
  {𝕩⋄Long Fout Comp J ∾ •LNS∘∾⟜".bqn"¨ "ea"‿"../svg"‿"e"}
  ¯1 ↓ · J L∘Fout∘Comp¨
⟩ args
