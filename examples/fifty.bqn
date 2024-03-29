# First, a word about the examples folder
# Yes, it only has this file and more will not be added
# This file is from when there weren't many examples and now I don't want to break links
# Look in these places for examples instead:
# https://mlochbaum.github.io/bqncrate/
# https://mlochbaum.github.io/BQN/community/index.html

# A history of APL in 50 functions
# But they're BQN functions
# Still about APL history though
# https://www.jsoftware.com/papers/50/

# Utilities
Words ← (⊢-˜¬×+`)∘=⟜' '⊸⊔  # Split string on spaces
Rand ← •rand.Range
BConv ← {⌽⊑¨(<0‿𝕩){·‿b 𝕊 𝕩:⟨𝕩|b,⌊b÷𝕩⟩}`⌽𝕨}  # Substitute for one case of ⊤
Enc ← {+´𝕩×⌽×`⌽1«𝕨}  # Substitute for one case of ⊥
Binary ← 2{⌽𝕗|⌊∘÷⟜𝕗⍟(↕1+·⌊𝕗⋆⁼1⌈⊢)}  # Substitute for 2⊥⍣¯1
_fix ← {𝔽∘⊢⍟≢⟜𝔽_𝕣∘⊢⍟≢⟜𝔽𝕩}  # Substitute for ⍣≡
# One case of matrix division:
# Solve lower triangular matrix equation by forward substitution
SolveLTri ← { t 𝕊 b:
  Row ← { new←b÷○⊏𝕩 ⋄ b↩b-⟜(×⌜⟜new)○(1⊸↓)𝕩 ⋄ new }
  > (↕∘≠ Row∘↓¨ ⊢) <˘⍉t
}

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
PerfectShuffle ← ⊢⊏˜·⍋∘⍒≠⥊0‿1˙
! "IAJBKCLDMENFOGPHQ" ≡ PerfectShuffle "ABCDEFGHIJKLMNOPQ"

# 7
_quicksort ← {Cmp←𝔽 ⋄ S←{p←𝕩Cmp˜𝕩⊏˜Rand≠𝕩 ⋄ ∾1‿0‿1𝕩{S⍟𝕨𝕗/˜0𝕏p}¨<‿=‿>}⍟(1<≠)}
! 1‿2‿2‿3‿5‿7‿9‿10‿10‿10‿11‿14‿16 ≡ -_quicksort 2‿2‿7‿10‿10‿11‿3‿10‿14‿5‿9‿1‿16
! {
  Cmp ← ≢◶0‿(-´∘⍋∾○<)¨
  srt ← Words "Anna Fi JD Jay Jd John Morten Roger Scott Zeus"
  srt ≡ Cmp _quicksort Words "Fi Jay John Morten Roger JD Jd Anna Scott Zeus"
}

# 8
PascalsTriangle ← {>𝕩↑¨0(∾+∾˜)⍟(↕𝕩)⥊1}
! [1‿0‿0‿0⋄1‿1‿0‿0⋄1‿2‿1‿0⋄1‿3‿3‿1] ≡ PascalsTriangle 4
! 1‿1‿2‿3‿5‿8‿13‿21‿34‿55 ≡ { 𝕩 ↑ +´¨ (+⌜˜↕𝕩) ⊔○⥊ PascalsTriangle 𝕩 } 10

# 9
GoldenRatio ← ÷⊸+`⥊⟜1
! 1e¯5 ∧´∘> | (GoldenRatio 16) - 1‿2‿1.5‿1.66667‿1.6‿1.625‿1.61538‿1.61905‿1.61765‿1.61818‿1.61798‿1.61806‿1.61803‿1.61804‿1.61803‿1.61803

# 10
NewtonsMethod ← (2 ÷˜ ⊣ + ÷˜)` ⥊
! 1e¯5 ∧´∘> | (7 NewtonsMethod 2) - 2‿1.5‿1.41667‿1.41422‿1.41421‿1.41421‿1.41421

# 11
InnerProduct ← +˝∘×⎉1‿2
! [2‿3⋄4‿1] ≡ [1‿0⋄¯1‿1] InnerProduct [2‿3⋄6‿4]

# 12
CayleysTheorem ← {R←⥊⊐⊢ ⋄ (R𝕩) ≡ R ⊏˜⌜˜ <˘R𝕩}
! {
  t ← 2‿2⊸⥊¨ (⌽2|⌊∘÷⟜2⍟(↕4))¨ 9‿6‿7‿11‿13‿14
  g ← ≠˝∘∧⎉1‿2⌜˜t
  CayleysTheorem g
}

# 13
d8 ← [
  ⟨⊢ , ⍒ , ⍒⍒, ⍋⌽, ⌽ , ⍋ , ⍋⍒, ⍒⌽⟩
  ⟨⍒ , ⍒⍒, ⍋⌽, ⊢ , ⍒⌽, ⌽ , ⍋ , ⍋⍒⟩
  ⟨⍒⍒, ⍋⌽, ⊢ , ⍒ , ⍋⍒, ⍒⌽, ⌽ , ⍋ ⟩
  ⟨⍋⌽, ⊢ , ⍒ , ⍒⍒, ⍋ , ⍋⍒, ⍒⌽, ⌽ ⟩
  ⟨⌽ , ⍋ , ⍋⍒, ⍒⌽, ⊢ , ⍒ , ⍒⍒, ⍋⌽⟩
  ⟨⍋ , ⍋⍒, ⍒⌽, ⌽ , ⍋⌽, ⊢ , ⍒ , ⍒⍒⟩
  ⟨⍋⍒, ⍒⌽, ⌽ , ⍋ , ⍒⍒, ⍋⌽, ⊢ , ⍒ ⟩
  ⟨⍒⌽, ⌽ , ⍋ , ⍋⍒, ⍒ , ⍒⍒, ⍋⌽, ⊢ ⟩
]
PM ← ⊢=⌜↕∘≠
MP ← ⊐⟜1˘
p ← 6‿3‿2‿1‿5‿4‿0
! (⊢  PM p) ≡ PM ⊢p
! (⍉  PM p) ≡ PM ⍋p
! (⌽⍉ PM p) ≡ PM ⍒p
! (⌽  PM p) ≡ PM ⌽p
rp ← •rand.Deal 7
! (d8{𝕎𝕩}¨<p) ≡ ({𝕎∘𝕏}⌜˜⊏d8){𝕎𝕩}¨<p
! CayleysTheorem d8

# 14
IntervalIndex ← 1-˜≠∘⊣(⊣↓⊢⍋⊸⊏+`∘>)⍋∘∾  # Or ⍋, of course
! 0‿2‿3‿2‿4‿1‿0‿2‿¯1 ≡ ¯1‿2‿3‿7‿8.5 IntervalIndex 0‿4‿7‿6‿11‿2‿1‿3‿¯5
! 0‿1‿0‿¯1‿4‿4 ≡ "Fi Jay John Morten Roger" IntervalIndex○Words "JD Jd Geoff Anna Scott Zeus"

# 15
CentralLimit ← { 41 ↑ /⁼ (5×↕40) ⍋ +˝ Rand 𝕩⥊21 }
# 5‿8 ⥊ CentralLimit 10 1e3

# 16
PN ← {1≥𝕩 ? 0≤𝕩; -´+˝𝕊¨Rec 𝕩}
Rec ← {𝕩 - (÷⟜2 (×⎉1) ¯1‿1 +⌜ 3⊸×) 1+↕⌈√𝕩×2÷3}
! 1‿1‿2‿3‿5‿7 ≡ PN¨↕6
# APL/J string manipulation approach doesn't work because •BQN can't access outside variables
# Use first class functions instead
Cond ← {1≥𝕩}, Base ← {0≤𝕩}, _gen←{-´+˝𝔽¨Rec 𝕩}
_memo ← { 𝕨 c‿b‿g _𝕣 𝕩:
  t ← (1+𝕨⋈𝕩)⥊¯1
  𝕨{
    𝕨C𝕩 ? 𝕨B𝕩;
    ¯1≢t⊑˜𝕨⋈𝕩 ? ⊑t⊑˜𝕨⋈𝕩;
    v←𝕨 𝕊 _g 𝕩
    t v⌾((𝕨⋈𝕩)⊸⊑)↩
    v
  }𝕩
}
! (PN 10) ≡ cond‿base‿gen _memo 10
# Time comparison on a local machine:
#    )t cond‿base‿gen _memo 30
# 187.1us
#    )t PN 30
# 2.6586s

# 17
SeventeenTwentyNine ← {F:
  c ← 3⋆˜1+↕200
  t ← (<⌜˜↕200) × +⌜˜c
  d ← ⍷⊸⊐⊸⊔ ⥊t
  ⌊´ ⊑¨ (2=≠¨)⊸/ d
}
! 1729 ≡ SeventeenTwentyNine⟨⟩

# 18
WinSimple ← { 𝕊 h:
  m ← ≠h
  s ← (≠⌜˜↕m) +˝∘×⎉¯1‿∞ h  # or s←+´⊸-h
  m|(↕m)-s
}
Win ← {
  # winning strategy based on group table 𝕨 for hat numbering 𝕩
  ! ∧´𝕩∊↕m←≠𝕩
  w←𝕨⊣m|+⌜˜↕m      # default is + modulo m
  ! m‿m≡≢w
  ! ⍉⊸≡w           # must be abelian
  g←⊏⊸⊐w           # standardize group table
  GS←(⋈⊑g˙)¨       # group operation
  GI←{⊑0⊐˜𝕩⊏g}¨    # inverses
  (↕m) GS GI (≠⌜˜↕m) GS´∘×⎉¯1‿∞ 𝕩
}
Mgrp ← {𝕩|×⌜˜/1=𝕩•math.GCD↕𝕩}
! {
  h ← 1‿9‿5‿6‿2‿0‿8‿8‿12‿4‿6‿10‿0
  ! 1 = +´ h = WinSimple h
  h88 ← •rand.Range˜ 88
  ! 1 = +´ h88 = WinSimple h88
  ! 1 = +´ h88 = Win h88
  coprimes ← / 88 = (+´1=•math.GCD⟜↕)¨ ↕1000
  ! ∧´ {1 = +´ h88 = (Mgrp 𝕩) Win h88}¨ coprimes
}

# 19
Permutations ← {𝕊0:1‿0⥊0; ∾˝(0∾˘1+𝕊𝕩-1)⊸⊏˘⍒˘=⌜˜↕𝕩}
! (6‿3⥊0‿1‿2‿0‿2‿1‿1‿0‿2‿1‿2‿0‿2‿0‿1‿2‿1‿0) ≡ Permutations 3

# 20
InversePermutation ← ⍋  # Or ⊐⟜(↕≠) or ∾∘⊔
! (↕10) ≡ InversePermutation⊸⊏ 1‿4‿5‿2‿6‿8‿3‿7‿0‿9

# 21
⟨IndexFromPermutation⇐Ifp,PermutationFromIndex⇐Pfi⟩ ← {
  Rfd ← ⊢+´∘>¨¯1↓↓
  Dfr ← (⍋∘⍋∾)´
  Ifp ⇐ {𝕊⁼:𝕨Pfi𝕩; (⌽×`1+»↕≠𝕩) +´∘× Rfd𝕩}
  Pfi ⇐ {𝕊⁼:𝕨Ifp𝕩; w𝕊𝕩: Dfr (1+↕w) (⌽⊣|¯1↓·⌊∘÷`∾˜) 𝕩}
}
! {
  p ← 1‿3‿0‿7‿6‿5‿4‿9‿8‿2
  ! p ≡ 10 PermutationFromIndex i ← IndexFromPermutation p
  ! p ≡ ⊢⌾(10⊸IndexFromPermutation) p
  ! i ≡ ⊢⌾(10⊸PermutationFromIndex) i
}

# 22
Combinations ← {𝕨(=∨0=⊣)◶⟨(0∾˘𝕊⌾(-⟜1))∾1+𝕊⟜(-⟜1), ≍∘↕⊣⟩𝕩}
! (3 Combinations 5) ≡ 10‿3⥊0‿1‿2‿0‿1‿3‿0‿1‿4‿0‿2‿3‿0‿2‿4‿0‿3‿4‿1‿2‿3‿1‿2‿4‿1‿3‿4‿2‿3‿4

# 23
⟨IndexFromCombination⇐Ic,CombinationFromIndex⇐Ci⟩ ← {
  C ← (-÷○(×´)1⊸+)⟜↕˜⚇0  # or •math.Comb˜ (APL's dyadic !)
  Ic ⇐ {
    𝕊⁼: 𝕨Ci𝕩;
    m‿n𝕊𝕩:
    -´(m-↕m) +˝∘C n-(»1+𝕩)∾˘𝕩
  }
  Ci ⇐ {
    𝕊⁼: 𝕨Ic𝕩;
    0‿n𝕊𝕩: ⟨⟩;
    m‿n𝕊𝕩:
    v←+`(m-1)C(1-m)↓⌽↕n
    k←(v>𝕩)⊐1
    k∾(1+k)+(𝕨-1∾1+k)𝕊(𝕩-k⊏0∾v)
  }
}
! 11 ≡ 4‿6 IndexFromCombination 1‿2‿3‿5
! 1‿2‿3‿5 ≡ 4‿6 CombinationFromIndex 11
! 11 ≡ 4‿6 CombinationFromIndex⁼ 4‿6 CombinationFromIndex 11

# 24
SymmetricArray ← ⍉⊸≡ ∧ 1⊸⍉⊸≡
! SymmetricArray +⌜´ 3⥊<2‿3‿7‿11

# 25
NQueens ← {
  Arr ← {>(⊑⊸⊏⟜𝕩∾1⊸⊑)¨/○⥊⟜(↕≢)¬(↕𝕨)∊⎉1𝕩⥊∘+⎉1‿2(-⟜↕¯1⊑≢𝕩)×⌜¯1‿0‿1}
  𝕩 Arr⍟(𝕩-1) ≍˘↕𝕩
}
QueenCheck ← {
  ! 1=≠≢𝕩
  ! (↕≠𝕩)≡∧𝕩
  ! ∧´⥊(=⌜˜↕≠𝕩)≥(|-⌜˜𝕩)=|-⌜˜↕≠𝕩
}
QueenCheck˘ NQueens 8

# 26
KnightsTour ← {
  Kmoves ← {
    t ← (⥊↕𝕩‿𝕩)+⌜<˘8‿2⥊2‿1‿2‿¯1‿1‿2‿1‿¯2‿¯1‿2‿¯1‿¯2‿¯2‿1‿¯2‿¯1
    (∧˝⎉1(>t)∊↕𝕩) /¨○<˘ 𝕩{+⟜(𝕨⊸×)´⌽𝕩}¨t
  }
  m ← >↑˜¨⟜(⌈´≠¨) Kmoves 𝕩
  b ← (𝕩×𝕩)⥊1
  F ← {b↩0⌾(𝕩⊸⊑)b ⋄ (⊑⍋+˝˘(j⊏m)⊏b)⊑j←⊏⟜b⊸/𝕩⊏m}
  𝕩‿𝕩⥊⍋F⍟(↕𝕩⋆2) 0
}
! (KnightsTour 6) ≡ 6‿6⥊0‿9‿20‿35‿6‿11‿21‿32‿7‿10‿19‿26‿8‿1‿34‿25‿12‿5‿33‿22‿31‿16‿27‿18‿2‿15‿24‿29‿4‿13‿23‿30‿3‿14‿17‿28

# 27
moo ← {
  # The main game is interactive, but we move these functions outside
  # to define Verify for testing
  Univ  ← {(1=(⌈´·≠¨⊔)⎉1 t)/t←𝕩(BConv⟜⊑)⎉1‿0↕×´𝕩}

  Guess ← {𝕩⊏˜•rand.Range≠𝕩}
  Solved← {g‿s 𝕊 ·: s≡'b'⥊˜≠g}
  Bull  ← {g‿s 𝕊 𝕩: (+´'b'=s)=(+´g⊸=)˘𝕩}
  Bc    ← {g‿s 𝕊 𝕩: (≠s)=+´˘𝕩∊g}
  Prune ← {𝕨 Solved 𝕩 ? ≍⊑𝕨; 𝕩/˜𝕨(Bull∧Bc)𝕩}

  Verify⇐{𝕨 𝕊 u‿x: 𝕨≡⊑¨(<(≠⋈⊢)Univ u){l‿w 𝕊 g‿s: (≠⋈⊢)g‿s Prune w}`x}
  Play⇐{
    Cow 𝕩:
    •Out "Computer Guess: "∾•Fmt g←Guess 𝕩
    •Out "Enter Bulls and Cows: "
    s←•GetLine@
    pr←g‿s Prune 𝕩
    {
      0=≠pr ? "";
      1=≠pr ? •Out "One choice left, it must be "∾•Fmt ⊏pr;
      •Out (•Fmt ≠pr)∾" choices left", Cow pr
    }
    pr
  } Univ
}
! 480‿126‿23‿1 moo.Verify ⟨
  4⥊10
  ⟨
    ⟨6‿5‿4‿0, "b" ⟩
    ⟨7‿3‿4‿1, "c" ⟩
    ⟨9‿5‿2‿7, "cc"⟩
    ⟨6‿9‿1‿2, "cc"⟩
  ⟩
⟩
# moo.Play 4⥊10 # Enjoy the game!

# 28
Odometer ← {𝕩(BConv⟜⊑)⎉1‿0↕×´𝕩}
Odometer1 ← {>⥊∾⌜´↕¨𝕩}
Odometer2 ← {⍉>(×´𝕩)⥊¨(⌽×`⌽1↓𝕩∾1)/¨↕¨𝕩}
Odometer3 ← {𝕩|⎉1⌊(↕×´𝕩)÷⌜⌽×`⌽1↓𝕩∾1}
Successor ← {𝕨⊸{(𝕨|𝕩)+1↓(𝕨=𝕩)∾0}_fix 𝕩+(-≠𝕩)↑1}
Odometer4a ← {>𝕩 Successor⍟(↕×´𝕩)0×𝕩} # omitted 4 as we have non scalar repeat (⍟)
Odometer5 ← ⍉∘>×´⥊¨(1«×`⌾⌽)/⟜↕¨⊢ # A BQN-oriented one for good measure
Pco2 ← {⍉>(⊑⋈≠)¨⊐⊸⊔2⊸{𝕩=1 ? ⟨⟩; 0=𝕨|𝕩 ? 𝕨∾𝕨𝕊𝕩÷𝕨; (𝕨+1)𝕊𝕩}𝕩}
Divisors←{p‿e←<˘Pco2 𝕩, p ×´∘⋆⎉1 Odometer 1+e}
! 1 = ≠⍷⟨Odometer, Odometer1, Odometer2, Odometer3, Odometer4a⟩ {𝕎𝕩}¨<4‿2‿3
! 1‿5‿2‿10‿4‿20‿8‿40‿16‿80‿32‿160 ≡ Divisors 160

# 29
Ind←{(⥊𝕨)⊏˜(<≢𝕨)Enc¨∾⌜´𝕩}
Ind1←{(⥊𝕨)⊏˜+⌜´𝕩×⌽×`⌽1«≢𝕨}
# Support missing axes since ⊏ doesn't. Value ∘ indicates a missing axis.
EInd←{b←{∘}≡¨𝕩,𝕨 Ind (↕¨b/≢𝕨)⌾(b⊸/)𝕩}
! {
  x←Rand¨5‿7‿11⥊100
  i←Rand¨2‿3⥊5 ⋄ j←Rand¨6⥊7 ⋄ k←Rand¨4‿1‿1⥊11
  ! (i‿j‿k⊏x) ≡ x Ind i‿j‿k
  ! (i‿j‿k⊏x) ≡ x Ind1 i‿j‿k
  ! (i‿j⊏x) ≡ x EInd i‿j‿∘
  ! ((⋈i)⊏x)≡ x EInd i‿∘‿∘
  ! (⟨i,0⥊0,k⟩⊏x) ≡ x EInd ⟨i,0⥊0,k⟩
}

# 30
Transpose←{(⥊𝕩)⊏˜(>⥊¨↕(≢𝕩)⌊˝∘+⎉1‿∞(⌈´≢𝕩)×¬b)+˝∘×⎉1‿∞(≢𝕩)⊸Enc˘⍉ b←𝕨=⌜↕0⌈1+⌈´𝕨}
# Version with infinity does not work (no infinite ranges):
# Transpose1←{(⥊𝕩)⊏˜(>⥊¨↕(≢𝕩)⌊˝∘+⎉1‿∞ ∞×¬b)+˝∘×⎉1‿∞(≢𝕩)⊸Enc˘⍉b←𝕨=⌜↕0⌈1+⌈´𝕨}
Transpose2←{𝕩⊑˜(<<𝕨)⊏¨⥊¨↕⌊´¨(⊐∧𝕨)⊔(≢𝕩)⊏˜⍋𝕨} # Functional Conf 2017, Roger Hui
! {
  y← Rand¨5‿13‿19‿17‿11 ⥊ 100
  x← 2‿1‿2‿0‿1
  z←x⍉y
  i←Rand 17, j←Rand 11, k←Rand 5
  ! (i‿j‿k⊑z) ≡ k‿j‿k‿i‿j⊑y
  ! (x⍉y) ≡ x Transpose y
  ! (x⍉y) ≡ x Transpose2 y
}

# 31
MF ← {>(⌈´≢¨𝕩)⊸↑¨𝕩} # Merge with fill
Inv  ← {MF¨<˘⍉𝕩}
Vert ← {⍉><˘⍟(2≤=)¨𝕩}
! {
  tx ← [
    ⟨"John"  , 'M', "USA", 26⟩
    ⟨"Mary"  , 'F', "UK" , 24⟩
    ⟨"Monika", 'F', "DE" , 31⟩
    ⟨"Min"   , 'M', "CN" , 17⟩
    ⟨"Max"   , 'M', "IT" , 29⟩
  ]
  ty ← [
    ⟨"Min"   , 'M', "CN" , 17⟩
    ⟨"Mary"  , 'F', "UK" , 24⟩
    ⟨"John"  , 'M', "UK" , 26⟩
    ⟨"Monika", 'F', "DE" , 31⟩
    ⟨"Mesut" , 'M', "DE" , 24⟩
    ⟨"Mesut" , 'M', "DE" , 24⟩
  ]
  ! 3‿1‿5‿2‿5‿5 ≡ tx⊐ty
  ! 0‿1‿2‿3‿4   ≡ ⊐tx
  ! 0‿1‿2‿3‿4‿4 ≡ ⊐ty
  x ← Inv tx
  y ← Inv ty
  ! x ≡ Inv Vert x
  ! y ≡ Inv Vert y
  ! ((Vert x) ⊐ (Vert y)) ≡ (⍉>x⊐¨x) ⊐ (⍉>x⊐¨y)
}

# 32
_ob ← {𝔽¨(+⌜´↕¨≢𝕩)⊔𝕩}
School ← +´_ob ×⌜
Carry ← {(⊢ ↓˜ 0=⊑){1↓+˝0‿¯1⌽˘0∾˜˘⌊(÷⟜10≍10⊸|)𝕩}_fix 0∾𝕩}
Multiply ← {
  # We will emulate complex support here
  # A leading length-2 axis gives real and imaginary parts
  # ¯1⋆r is (m.Cos≍m.Sin) π × r
  # Mul does complex multiplication
  Cube     ← {𝕩⥊˜2⥊˜2⋆⁼≠𝕩}˘
  Roots    ← {m←•math ⋄ (m.Cos≍m.Sin) π × ↕⊸÷ 𝕩}
  Mul      ← -˝∘× ≍ +˝∘×⟜⌽
  Butterfly← {(⊏⎉1𝕨)𝕊⍟(1<=𝕨)(+˝˘𝕩)≍⎉(-=𝕨)𝕨Mul-˝˘𝕩}
  FFT      ← {        ⥊˘ (       Roots 2÷˜≠⊏𝕩) Butterfly○Cube 𝕩}
  IFT      ← {(≠⊏𝕩)÷˜ ⥊˘ (-⌾(1⊸⊏)Roots 2÷˜≠⊏𝕩) Butterfly○Cube 𝕩}
  m ← ⌈⌾(2⋆⁼⊢) ¯1+𝕨+○≠𝕩
  ⊏ 𝕨 Mul⌾{𝕊⁼:IFT𝕩;FFT𝕩}○(2‿m⊸↑) 𝕩
}
! {
  m ← 4‿6⥊↕23
  # ⊢_ob m
  x←3‿2‿3‿9‿0‿4‿2
  y←1‿9‿9‿1‿4
  res ← 3‿29‿48‿57‿122‿96‿59‿90‿22‿18‿8
  ! res ≡ +´ _ob x ×⌜ y
  ! res ≡ x School y
  ! 6‿4‿5‿0‿2‿2‿8‿2‿3‿8‿8 ≡ Carry +´ _ob x ×⌜ y
  [xl,yl] ← 2‿128 •rand.Range 10
  ! 1e¯8 > ⌈´ | (xl Multiply yl) - 256↑xl School yl
}

# 33
# It's more consistent to define Base2 taking bits to value, because
# Base2 Binary 𝕩 is 𝕩 for natural numbers but Binary Base2 𝕩 drops
# leading zeros.
Base2 ← {𝕊⁼𝕩: Binary 𝕩; 2⊸×⊸+˜´⌽𝕩}
Josephus ← 1⊸⌽⌾(Base2⁼)
! ∧´ 1 = Josephus¨ 2⋆↕10
! ∧´ 2 = {(1+𝕩) -○(Josephus¨) 𝕩} 10⋆1+↕5
! 7‿1‿19‿5 ≡ Josephus¨ 7‿16‿25‿34

# 34
_pow ← {𝔽´𝔽˜⍟(/2|⌊∘÷⟜2⍟(↕1+·⌊2⋆⁼⊢)𝕩)𝕨}
! 847288609443 ≡ 3 ×_pow 25

# 35
Tc←{𝕊𝕩: 0𝕊𝕩; (⊑𝕩)=⊑⌽𝕩 ? ⍷𝕨 ; (𝕨∾𝕨⊏𝕩) 𝕊 𝕩⊏𝕩}
Tc2←{/⊑˘ (⊢∨∨˝∘∧⎉1‿∞˜)_fix(↕≠𝕩)=⌜𝕩}
# Can also use Solve from bqn-libs matrix.bqn in place of SolveLTri˜⍉
Tc3←{/ (1↑˜≠𝕩) SolveLTri˜⍉ (=⌜˜↕≠𝕩)-(↕≠𝕩)=⌜˜𝕩+𝕩=⊢´𝕩}
! {
  i←↕19
  b←i=⌜2+i      # edges are (i,2+i)
  t←(⊢∨∨˝∘∧⎉1‿∞˜)_fix b  # transitive closure of b
  # •Show b⊏".∘"
  # •Show t⊏".∘"
  x← 1‿4‿5‿5‿7‿6‿9‿9‿10‿12‿11‿14‿14‿15‿16‿18‿18‿18‿20‿20‿20
  # •Show (↕≠x)≍x
  res←0‿1‿4‿7‿9‿12‿14‿16‿18‿20
  ! res ≡ Tc x
  ! (1↓res) ≡ Tc2 x
  ! (¯1↓res) ≡ Tc3 x
}

# 36
Fib←{1≥𝕩 ? 𝕩 ; (𝕊𝕩-2)+𝕊𝕩-1}
Fib1←{𝕊𝕩: 0‿1𝕊𝕩; 0=𝕩 ? ⊑𝕨 ; (1↓𝕨∾+´𝕨)𝕊𝕩-1}
Fib2←{⊑+`∘⌽⍟𝕩↕2}
Fib3←{⌊0.5+r÷˜(2÷˜1+r←√5)⋆𝕩}
# Fib4←{1•math.GCD+⟜÷´0∾𝕩⥊1}  # Once •math.GCD supports fractions
Fib5 ← ⊑ ↕ +˝∘•math.Comb⎉1‿∞ ⌽∘↕
PDX←+˝∘×⎉1‿∞
Fib6a←{0‿1⊑(=⌜˜↕2)PDX´PDX˜⍟(/⌽Binary 𝕩)∨⌜˜↕2}
Fib7←{⌊r÷˜-´𝕩⋆˜2÷˜1+1‿¯1×r←5⋆0.5}
Fib8←{+´ (∾·(↓⟜0‿1¨)¬)⍟𝕩 ⥊0}

! {
  res←0‿1‿1‿2‿3‿5‿8‿13‿21‿34
  ! res ≡ Fib ¨↕10
  ! res ≡ Fib1¨↕10
  ! res ≡ Fib2¨↕10
  ! res ≡ Fib3¨↕10
  ! res ≡ Fib5¨↕10
  ! res ≡ Fib6a¨↕10
  ! res ≡ Fib7¨↕10
  ! res ≡ Fib8¨↕10
}

# 37
G←{(0⊸∾˘ ∾ 1⊸∾˘∘⌽)⍟𝕩↕1‿0}
B←{(0⊸∾˘ ∾ 1⊸∾˘)⍟𝕩↕1‿0}
! (B 3) ≡ ≠`˘ G 3
! (G 3) ≡ ≠`⁼˘ B 3

# Bonus: for the online JS REPL
# •SetPlot "scatter"
# (B 10) •Plot○((2⊸×⊸+˜´⌽)˘) G 10

# 38
Hanoi ← {¯1↓(⥊⊢≍⎉0˜≠⥊⊑⊑⟨1‿5‿2⋄0‿3‿4⟩˙)⍟𝕩⥊1}
! 0‿1‿3‿0‿4‿5‿0 ≡ Hanoi 3

# 39
Ack ← {
  0 𝕊 𝕩: 1+𝕩;
  𝕨 𝕊 0: (𝕨-1) 𝕊 1;
  (𝕨-1) 𝕊 𝕨 𝕊 𝕩-1
}
! 9 ≡ 2 Ack 3
! 29 ≡ 3 Ack 2

# 40
# If _H solves the halting problem (𝔽 _H 𝕩 is 1 iff 𝔽𝕩 halts) then the
# following function causes a paradox.
# F←{𝕊 _H 𝕩 ? 𝕊 𝕩; ⟨⟩}

# 41
Cholesky ← {
  1≥≠𝕩 ? √𝕩 ;
  n←≠𝕩
  p←⌈n÷2
  q←⌊n÷2
  x←⟨p,p⟩↑𝕩 ⋄ y←⟨p,-q⟩↑𝕩 ⋄ z←⟨-q,-q⟩↑𝕩
  l0 ← 𝕊 x
  l1 ← 𝕊 z - (t←+⍉ly) +˝∘×⎉¯1‿∞ ly ← l0 SolveLTri y
  ∾ [l0‿(p‿q⥊0), t‿l1]
}
! {
  a ← [
    231‿  42‿ ¯63‿ 16‿ 26
     42‿ 199‿¯127‿¯68‿ 53
    ¯63‿¯127‿ 245‿ 66‿¯59
     16‿ ¯68‿  66‿112‿¯75
     26‿  53‿ ¯59‿¯75‿ 75
  ]
  l ← Cholesky a
  ! ∧´⥊ 1e8 > a |∘- l +˝∘×⎉¯1‿∞ +⍉l
  ! ∧´⥊ (0≠l) ≤ ≥⌜˜↕≠l
}

# 42
Minors ← {(/¨≠⟜<↕≠𝕩)(⍉⊏)⎉0‿∞ 𝕩}⎉2⍟2
Minors1 ← {𝕊 mat: >{mat ⍉∘{𝕩/˜¬𝕨=↕≠𝕩}´ ⌽𝕩}¨↕≢𝕩}
! (Minors ≡ Minors1) 3‿4⥊↕12
! (Minors ≡ Minors1) 4‿4⥊'A'+↕26

# 43
S1 ← {
  𝕊 0: ⋈1;
  (0∾t)+(t∾0)× 𝕩-1⊣t←𝕊 𝕩-1
}
S2 ← {
  𝕊 0: ⋈1;
  (0∾t)+(t∾0)×↕𝕩+1⊣t←𝕊 𝕩-1
}
! ⟨ 0, 6, 11, 6, 1 ⟩ ≡ S1 4
! ⟨ 0, 1,  7, 6, 1 ⟩ ≡ S2 4

# 44
XEA ← {(𝕨∾1‿0) {0=⊑𝕩 ? 𝕨; 𝕩 𝕊 𝕨-𝕩×⌊(⊑𝕨)÷⊑𝕩} (𝕩∾0‿1)}
CRT ← {
  m‿r 𝕊 n‿s:
  gcd‿a‿b ← m XEA n
  lcm ← m×n÷gcd
  c ← lcm|gcd÷˜(r×b×n)+(s×a×m)
  ! (r=m|c)∧(s=n|c)
  lcm∾c
}
! 2‿¯1‿1 ≡ 4 XEA 6
! 12‿9 ≡ 4‿1 CRT 6‿3

# 45
# If you have complex support:
# ! 0 = 1 + ⋆π×0i1

# 46
Sieve←{
  4≥𝕩 ? 𝕩⥊0‿0‿1‿1;
  𝕊 n:
  r←⌊√n
  p ← 2‿3‿5‿7‿11‿13‿17‿19‿23‿29‿31‿37‿41‿43
  p ↩ (1+(×`p)⊸⍋⌾<n-1)↑p
  b ← 0⌾(1⊸⊑) 1 {m←n⌊𝕨×≠𝕩 ⋄ (m⥊𝕩)>m⥊𝕨↑1}´ ⌽p
  {
    r≥q←b⊸⊐⌾<1 ?
    b 0¨⌾((q∾q×/b↑˜⌈n÷q)⊸⊏)↩
    𝕊 𝕩∾q
  ;
    b 1¨⌾(𝕩⊸⊏)↩
  }p
}
! 2‿3‿5‿7‿11‿13‿17‿19‿23‿29 ≡ /Sieve 30
! 78498 ≡ +´Sieve 1e6

# 47
Pg ← •rand.Deal{
  d ← 𝕩+𝕩
  s ← 𝕩×𝕩
  t ← 𝕩↑˘𝕩‿d⥊(¬d)↑'a'+𝕩𝔽26
  p ← ⍋(𝔽s)+s×/+`(¯1⊸⋆×𝕩-˜⌽)↕d
  (⌽↕𝕩) ⌽⟜{1↓⥊' '≍˘𝕩}˘ 𝕩‿𝕩⥊p⊏⥊t
}
#•Show Pg¨ 4‿5‿6‿7
TestPg ← {n𝕊p:
  ! (>(«∨»)⍟(↕n)1(⊢∾∾)0⥊˜n-1) ≡ ' '≠p
  rows ← (<' '⊸≠⊸/)˘p
  ! ∧´ (<"") (»(∧≡↕∘≠)∘⊒¨⊢) rows
  ! ∧´∊ ¯1⊑rows
}
TestPg⟜Pg¨ 4‿5‿6‿7

# 48
Stick ← {
 c ← 𝕩 •rand.Range 3         # where the car is hidden
 i ← 𝕩 •rand.Range 3         # your initial choice of door
 +´c=i                       # number of cars that you win
}
Change ← {
 c ← 𝕩 •rand.Range 3                      # where the car is hidden
 i ← 𝕩 •rand.Range 3                      # your initial choice of door
 j ← (c×i≠c)+(3|i+1+•rand.Range¨𝕩⥊2)×i=c  # your changed choice
 +´c=j                                    # number of cars that you win
}
#•Show Stick‿Change {𝕎𝕩}¨ 1e6

# 49
# +´(1+↕∞)⋆-s ←→ ×´÷1-(⍭↕∞)⋆-s
