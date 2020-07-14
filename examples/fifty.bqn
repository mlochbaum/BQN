# A history of APL in 50 functions
# But they're BQN functions
# Still about APL history though
# Also not all the functions are here yet
# https://www.jsoftware.com/papers/50/

# Utilities
Words ← (⊢-˜¬×+`)∘=⟜' '⊸⊔  # Split string on spaces

# 0
ArrayLogic ← (>-<)⟜0
! 1‿¯1‿0‿1 ≡ ArrayLogic 5‿¯2.7‿0‿6

# 1
Average ← +´÷≠
! 3 ≡ Average 2‿1‿6

# 2
# x⌹x=x is an alternate way to get the average of vector x.
# There's no reason to do it this way in BQN (or APL, really).

# 3
IndexOfSelfie ← ⊐˜
! 0‿1‿2‿3‿4‿1 ≡ IndexOfSelfie "Selfie"

# 4
BarChart ← ".⎕"⊏˜>⌜⟜(↕⌈´)
! {
  bc ← BarChart 3‿1‿4‿1‿5‿9
  bc ≡ 6‿9⥊"⎕⎕⎕......⎕........⎕⎕⎕⎕.....⎕........⎕⎕⎕⎕⎕....⎕⎕⎕⎕⎕⎕⎕⎕⎕"
}

# 5
ParenthesesNesting ← +`1‿¯1‿0⊏˜"()"⊐⊢
! {
  pn ← ParenthesesNesting "⍵((∇<S),=S,(∇>S))⍵⌷⍨?≢⍵"
  pn ≡ 0‿1‿2‿2‿2‿2‿1‿1‿1‿1‿1‿2‿2‿2‿2‿1‿0‿0‿0‿0‿0‿0‿0
}

# 6
PerfectShuffle ← ⊢⊏˜·⍋∘⍒≠⥊0‿1˜
! "IAJBKCLDMENFOGPHQ" ≡ PerfectShuffle "ABCDEFGHIJKLMNOPQ"

# 7
_quicksort ← {Cmp←𝔽 ⋄ S←{p←𝕩Cmp˜𝕩⊏˜•Rand≠𝕩 ⋄ ∾1‿0‿1𝕩{S⍟𝕨𝕗/˜0𝕏p}¨<‿=‿>}⍟(1<≠)}
! 1‿2‿2‿3‿5‿7‿9‿10‿10‿10‿11‿14‿16 ≡ -_quicksort 2‿2‿7‿10‿10‿11‿3‿10‿14‿5‿9‿1‿16
! {
  Cmp ← ≢◶0‿(-´∘⍋∾○<)¨
  srt ← Words "Anna Fi JD Jay Jd John Morten Roger Scott Zeus"
  srt ≡ Cmp _quicksort Words "Fi Jay John Morten Roger JD Jd Anna Scott Zeus"
}

# 8
PascalsTriangle ← {>𝕩↑¨0(∾+∾˜)⍟(↕𝕩)⥊1}
! (>⟨1‿0‿0‿0⋄1‿1‿0‿0⋄1‿2‿1‿0⋄1‿3‿3‿1⟩) ≡ PascalsTriangle 4
! 1‿1‿2‿3‿5‿8‿13‿21‿34‿55 ≡ { 𝕩 ↑ +´¨ (+⌜˜↕𝕩) ⊔○⥊ PascalsTriangle 𝕩 } 10

# 9
GoldenRatio ← +⟜÷´¨∘(1↓↑) ⥊⟜1
! 1e¯5 > | (GoldenRatio 16) - 1‿2‿1.5‿1.66667‿1.6‿1.625‿1.61538‿1.61905‿1.61765‿1.61818‿1.61798‿1.61806‿1.61803‿1.61804‿1.61803‿1.61803

# 10
NewtonsMethod ← (2 ÷˜ ⊢ + ÷)´¨∘(1↓↑) ⥊
! 1e¯5 > | (7 NewtonsMethod 2) - 2‿1.5‿1.41667‿1.41422‿1.41421‿1.41421‿1.41421

# 11
InnerProduct ← (+´<˘)∘(×¨)⎉1‿2
! (>⟨2‿3⋄4‿1⟩) ≡ (>⟨1‿0⋄¯1‿1⟩) InnerProduct >⟨2‿3⋄6‿4⟩

# 12
CayleysTheorem ← {R←∾⊐⊢ ⋄ (R𝕩) ≡ R ⊏˜⌜˜ <˘R𝕩}
! {
  t ← 2‿2⊸⥊¨ (⌽2|⌊∘÷⟜2⍟(↕4))¨ 9‿6‿7‿11‿13‿14
  g ← (≠´<˘)∘(∧¨)⎉1‿2⌜˜t
  CayleysTheorem g
}

# 14
IntervalIndex ← 1-˜≠∘⊣(⊣↓⊢⍋⊸⊏+`∘>)⍋∘∾  # Or ⍋, of course
! 0‿2‿3‿2‿4‿1‿0‿2‿¯1 ≡ ¯1‿2‿3‿7‿8.5 IntervalIndex 0‿4‿7‿6‿11‿2‿1‿3‿¯5
! 0‿1‿0‿¯1‿4‿4 ≡ "Fi Jay John Morten Roger" IntervalIndex○Words "JD Jd Geoff Anna Scott Zeus"

# 15
CentralLimit ← { 41 ↑ /⁼ (5×↕40) ⍋ +´<˘ •Rand 𝕩⥊21 }
# 5‿8 ⥊ CentralLimit 10 1e3

# 17
SeventeenTwentyNine ← {F:
  c ← 3⋆˜1+↕200
  t ← (<⌜˜↕200) × +⌜˜c
  d ← ⍷⊸⊐⊸⊔ ⥊t
  ⌊´ ⊑¨ (2=≠¨)⊸/ d
}
# ! 1729 ≡ SeventeenTwentyNine⟨⟩  # slow

# 24
SymmetricArray ← ⍉⊸≡ ∧ 1⊸⍉⊸≡
! SymmetricArray +⌜´ 3⥊<2‿3‿7‿11

# 34
_pow ← {𝔽´𝔽˜⍟(/2|⌊∘÷⟜2⍟(↕·⌈2⋆⁼⊢)𝕩)𝕨}
! 847288609443 ≡ 3 ×_pow 25

# 38
Hanoi ← {¯1↓(⥊⊢≍⎉0˜≠⥊⊑⊑⟨1‿5‿2⋄0‿3‿4⟩˜)⍟𝕩⥊1}
! 0‿1‿3‿0‿4‿5‿0 ≡ Hanoi 3
