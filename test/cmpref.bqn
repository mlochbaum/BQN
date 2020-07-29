#!/usr/bin/env dbqn

# Compile and run the primitive implementations, and testref.bqn

impl ← •LNS •path∾"../impl.bqn"

drun ← ((<•path∾"../c.bqn")∾<"DRun") •EX •path∾"../dzref"

chrs←⟨
  "!+-×÷⋆√⌊⌈∧∨¬|=≠≤<>≥≡≢⊣⥊∾≍↑↓↕⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔"
  "˜˘¨⌜⁼´˝`"
  "∘⊸⟜○⌾⎉⚇⍟◶⊘"
⟩
nc ← ≠¨chrs
chr ← ∾chrs
itr ← 0⥊˜≠chr

init ← " "⊸∾¨(/⟜"_"¨nc/0‿1‿1)∾¨(nc/"FMD")∾¨(nc+´⊸↑⥊"ABC"∾⌜•a)
post ← ∾⟜" "¨/⟜"_"¨nc/0‿0‿1
names ← init∾¨(•UCS 48)∾¨post

Inc ← {
  i←⊑chr⊐𝕩
  n←0 ⋄ itr↩{n↩1+𝕩}⌾(i⊑⊢)itr
  names↩((i⊑init)∾(•UCS 48+n)∾i⊑post)⌾(i⊑⊢)names
}

# built-in assumptions
Mod ← {((⊑chr⊐𝕨)⊑names) ∾ " ← " ∾ 𝕩}

pre ← ⟨
  "IsArray ← 0≠≡"
  "_amend  ← {𝕨{𝕩⋄𝕗}⌾(𝕗⊑⊢)𝕩}"
  "Type    ← ⟨⟩⥊0⊸⥊"
  '!' Mod "{𝕩 ⋄ ≤1}⍟¬"
⟩∾Mod⟜⥊¨ "+-×÷⋆⌊=≤≢⥊⊑↕⌜⁼"


# checks if line is a builtin redefinition
E_isdef ← (3≤≠)◶⟨0,∧´⟨chr," ","←↩"⟩∊˜¨3⊸↑⟩

# removes comments and replaces built-ins with names
E_proc ← {
  l←≠chr
  q←≠`𝕩∊"""'" ⋄ f←¬∨`q¬⊸∧𝕩='#'
  ∾ (((l×f/q)+chr⊸⊐) (≥⟜l)◶⟨⊑⟜names,⥊∘⊢⟩¨ ⊢) f/𝕩
}

E_redef ← { # handles [fmd] [←↩]
  tail ← E_proc 3↓𝕩 # must use old def
  Inc ⊑𝕩
  (E_proc 1↑𝕩) ∾ "←" ∾ tail
}

pre ∾↩ E_isdef◶E_proc‿E_redef¨ impl
t ← (¬∘⊑'{'∊⊢)¨⊸/ 3⊸↓⌾(3⊸⊑) •LNS •path∾"testref.bqn"
res ← DRun ∾ ∾⟜(•UCS 10)¨ pre ∾ E_proc¨ t
• ← ("All "∾(⍕≠res)∾" passed!")⍟(0=≠) /res
