# Tester that checks primitives on random arguments

opts ← {
help ← 1↓"
Fuzz testing. Options:
  -h, --help: Print this message and exit
  -r: Random seed, u to use •UnixTime then print (1)
  -b: Maximum bound (1e3)
  -z: Don't generate large zero-product shapes (0)
  -o: Show full function output when it fails a test (0)
  -f: Failures allowed before stopping (1)
  -n: Number of iterations (100)
  -t: Element type (0 3 4 5 6)
  -p: Primitives: both | mon%dy | mon%dy%both
  -m: Modifier operands (dyadic arithmetic)

Any number of types or bounds can be given; all combinations are tested."

  o ← "-h"‿"--help"‿"-b"‿"-z"‿"-o"‿"-f"‿"-n"‿"-t"‿"-p"‿"-m"‿"-r"
  oo ← (≠o) = oi ← o ⊐ a←•args
  •Exit∘•Out∘help⍟(∨´2⊸>) oi

  opts ← 2↓o≠⊸↑ a ⊔˜ (¬-˜⊢× oi⊏˜ ↕∘≠⌈`∘×¬)oo
  bounds‿zerobound‿showres‿numfail‿num‿types‿prims‿modop‿seed ⇐ •BQN¨¨⌾(¯3⊸↓) opts
  _default_ ← { (∾"Only one "‿𝕘‿" can be given") ! 1≥≠𝕨 ⋄ 𝕩𝔽∘⊣´𝕨 }
  num ⊢_default_"iteration number"↩ 100
  types ↩ 0‿3‿4‿5‿6⍟(0=≠) types
  bounds ↩ ⟨1e3⟩⍟(0=≠) bounds
  zerobound‿showres‿numfail ⊣´¨˜↩ 0‿0‿1
  seed "u"⊸≡◶⟨•BQN,•Show(2⋆31)|⌊∘•UnixTime⟩_default_"random seed"↩ 1

  modop ∾↩
  prims ((⊢-˜¬×+`+2×·¬∨´)'%'⊸=)¨⊸(⊔○∾)↩
  "At most three %-separated primitive groups allowed" ! 3≥≠prims
  prims ↩ 2 (↑((¬∘∊/⊣)∾⊢)¨⊏) 3 ↑ prims

  Failed ⇐ {𝕊: •Exit∘1⍟(0⊸=) numfail -↩ 1}
}

Squeeze‿ListVariations‿Variation‿ClearRefs ← •internal

⟨Range,Subset⟩ ← •MakeRand opts.seed
Rand ← {𝕨 Range 1⌈𝕩}
_randChoose ← { Rand∘(≠𝕗)◶𝕗 }
_randUnbounded ← { 𝕊⊸+⍟(1=-)⟜Rand 𝕗 }
RandRank ← 4 _randUnbounded

# Prime factorization
⟨Factor⟩ ← {
  p ← (¬∘∊/⊣)⟜(⥊×⌜˜)2↓↕m←60
  Pr ← {m<𝕩}◶{𝕩↑p}‿{ m↩(×˜m)⌊2×𝕩 ⋄ p∾↩1↓/1(m⥊0<↕)⊸∧´p ⋄ Pr 𝕩 }
  Factor ⇐ {
    !(1=•Type𝕩)∧(𝕩=⌊𝕩)∧0<𝕩
    ∧ 𝕩 {(0<≠∘⊢)◶⟨⥊⊣,⊢∾𝕊⟩⍟(>⟜1)˜⟜(𝕨÷×´)𝕩/˜0=𝕩|𝕨} Pr ⌈√𝕩
  }
}

Sigmoid ← (40≤|)◶⟨1(-÷+)˜⋆,×⟩

# 𝕩 is maximum bound plus 1 for both functions
⟨RandBound,RandShape⟩ ← {
  RandBound ⇐ ⟨
    Rand                                         # Uniform
    Rand 128⊸⌊                                   # Small
    (0⌈-⟜1) ⌊ Rand∘(1⌈⌈)⌾((2⋆3+⊢)⁼) + ¯7+Rand∘15 # Near power of two
  ⟩_randChoose

  z ← opts.zerobound
  Squash ← {                       # Multiply by constant so product is ≤𝕨
    a←(∧`𝕨>×`÷⊢⋆1+↕∘≠)⊸/∘∨⍟z 𝕩     # Numbers that don't need to go below 1, if z
    ⌊ 𝕩 × (≠a) √ Sigmoid⊸÷1⌈𝕨÷˜×´a
  }
  Augment ← {
    d ← 1+⌊𝕨÷1⌈×´z⌈𝕩       # Maximum bound that can be added, plus 1
    C ← 10⊸+ Rand⊸< 1.2⊸√  # Decide whether to add
    d (𝕨 𝕊 ⟨∾,∾˜⟩_randChoose⟜RandBound˜)⍟(C⊣) 𝕩
  }
  Combine ← ⟨
    Rand∘≠⊸⌽ (2+Rand∘≠)⊸{×´¨𝕨↑(𝕨|↕∘≠)⊸⊔𝕩}∘⊢ # Random number of groups
    ×´¨ (⊐·Rand¨⥊˜∘≠)⊸⊔∘⊢                   # Distribute randomly
  ⟩_randChoose
  RandShape ⇐ ⊢ Augment ⟨
    ⊢ Squash · Rand¨ (RandRank⌈√<Rand)⊸⥊
    ⊢ Combine⟜Factor 1⌈RandBound
  ⟩_randChoose
}

RandShape1 ← 1⊸∾⍟(0=≠) RandShape

# 𝕨 is 2⋆⁼bits in type; 𝕩 is shape
gen ← {
  getGen ← •Import "fuzzgen.bqn"
  Generate ← { 𝕨𝕊t:
    s ← 𝕨 Range⊘⊣ 2⋆31  # Random seed
    AsFn ← (GetGen •MakeRand s)⊸•ns.Get⍟=
    d ← Squeeze {=◶⊑‿(AsFn∘⊑{{∾}≡𝕨?𝕎𝕩;(2=≠𝕩)◶⟨𝕎⊑,𝕎´⟩𝕩}·𝕊¨⌾⌽1⊸↓)𝕩} 𝕩
    {1≥≠⥊d? d ; seed⇐s, template⇐t, data⇐d}
  }
  Dat ⇐ {𝕩.data}⍟(6=•Type)
  # Formatting for error output
  Format ⇐ {
    6≠•Type𝕩 ? •Repr𝕩 ;
    TrimPar ← (¯1↓1⊸↓)⍟('('=⊑)
    TxtApply ← {{∾}≡𝕨?"∾"∾' '⌾⊑∾"‿"⊸∾¨𝕩;∾⟜" "⊸∾´⌽⌾(2⊸↑)⍟(3=≠)⟨𝕨⟩∾TrimPar⌾(¯1⊸⊑)𝕩}
    FmtTemp ← {=◶⟨•Repr⊑,"("∾")"∾˜=◶⟨•Repr,"g."⊸∾⟩∘⊑TxtApply·𝕊¨1⊸↓⟩𝕩}
    ∾⟨"{g←", •Repr 𝕩.seed, "•Import""fuzzgen.bqn""⋄"
      TrimPar FmtTemp 𝕩.template
      "}"⟩
  }

  RN ← (0⌈-⟜1) ⌊ 1‿RandRank‿RandBound _randChoose
  RandSplit ← ⌽⍟(Rand∘2) (-≍⊢)⟜RN

  _a ← {⟨𝔽⟩∾⋈}                # Apply function symbolically
  _ra← {(⋈Rand∘≠⊸⊑∘𝕗)∾⋈}      # Same, choosing randomly from list
  _flat ← { <∘⊢ ⥊_a 𝔽⟜(×´⥊) } # Generate list, then reshape

  _Rec_ ← {
    S ← {𝕨R𝕩}
    R ← ⟨
      𝔽                                  # Random
      ∧‿∨_ra 𝔽                           # Sort
      ⊢ ⟨⥊,"Stretch"⟩_ra S⟜(1⌈RN)        # Repeat
      "Shuffle"_a⍟(Rand∘2) ⟨∾⟩ ∾ <⊸(𝔾‿⊢_randChoose⊸S¨)⟜RandSplit # Partition
    ⟩{ 8⊸≤◶⟨0,Rand∘(≠𝕗)⟩◶𝕗 }
    R _flat
  }

  floats ← ⟨2⋆¯1074,2⋆¯1022,(2-2⋆¯52)×2⋆1023⟩
  RandFloat ← ⟨
    (floats∾2⋆0‿8‿32‿100)_randChoose ×_a (2÷˜Rand∘3) -˜_a⍟(0≠⊣) "Unit"_a
    ⊢ "Sel"_a ·<(Rand(⊣≥⌈´⊸⌊)3+Rand∘+)˜∘≠⊸/∘(∾⟜-0∾floats∾∞)
  ⟩_randChoose
  RandTyped ← =⟜6◶⟨"Int"_a, RandFloat⊢⟩
  Arith ⇐ Generate RandTyped _Rec_ Rand

  ContractRange ← (⟨≍⟜0,0≍-⟩_randChoose·RN-˜´)⊸+
  RandInterval ← <⊸("Interval"_a) _Rec_ ContractRange

  Index ⇐ Generate (0⊸≍ ⊣ ·!0⊸<)⊸RandInterval

  ch_end ← 17×2⋆16
  ChR ← 0≍ch_end⌊2⋆2⋆⊣
  Char ⇐ Generate ·"ToChar"_a ChR⊸RandInterval

  Struct ⇐ Generate =⟜6◶⟨
    ⟨"Int"_a, "ToChar"_a <∘ChR⊸("Interval"_a)⟩_randChoose
    "Unit"_a⊢
  ⟩_flat
}

_testConsistent_ ← {Match←𝔾 ⋄ F←𝔽
  Arr ← 0=•Type
  ListVar ← Arr◶(5⥊@)‿ListVariations
  Var ← Arr∘⊢◶⊢‿Variation
  v ← <˘⍉> (5⌊´≠¨)⊸(((0∾Rand⌾(-⟜1))⟜≠⊏⊢)¨) ListVar¨ a←gen.Dat¨o←𝕨⋈𝕩
  c ← (∧´ ⊏ Match¨ 1⊸↓) r ← (𝕨 (F⊑∘⊢)⊘(F´⊢) Var¨⟜a)¨ v
  {c?@;                             # If results don't match:
    •Show f ⋄ •Out∘gen.Format¨o     # Output function and arguments
    gv ← (⍒≠¨)⊸⊏ ⊔⊐Match⌜˜r         # Variations grouped by result
    •Show ⊏˘⍟(¬opts.showres) >(⊏⟜(>v)⋈⊑⊑r˙)¨ gv
    opts.Failed@
  }
  ClearRefs@
  c
}

FlatMatch ← ≡◶⟨∧´∘⥊=∨∧○(≠˜),1⟩

_testMonArith ← {
  (𝕨 gen.Arith RandShape 𝕩)⊸{ 𝕏 _testConsistent_ FlatMatch 𝕨 }¨ 𝕗
}

RandDyShape ← {
  Prefix ← (∨`⌾⌽ 𝕩 ≥ ×`)⊸/ (Rand 1+≠)⊸↑
  (Rand 2) ⌽ ⋈⟜Prefix RandShape 𝕩
}
_testDyArith ← {f←𝕗
  ch ← 0<+´≠¨ pmn ← (∊⟜f⥊¨⊢) +‿-‿¬
  {
    sh ← RandDyShape 𝕩
    Atom ← ⊑⍟(Rand∘2)⍟(0==)⍟(0=•Type)
    _t ← { 𝕏 _testConsistent_ FlatMatch´ 𝕗 }
    (Atom¨ 𝕨⊸gen.Arith¨ sh)_t¨ f
    {
      k←𝕩
      rca ← gen.Dat¨Atom¨⟨gen.Char,gen.Arith⟩{k𝕎𝕩}¨sh
      Fit ← -⟜(@+1-˜17×2⋆16)⌈-⟜@⌊⊢
      # Remove -⟜@ to test full-range ¬ (extended from 1+-)
      ⟨⌽⍟(Rand 2)-∘Fit⟜-`,Fit`,(-⟜@⌊1+Fit)`⟩ { (𝕎rca)_t 𝕩 }¨¨ pmn
      { (sh (k gen.Char ⊣)⌾(1⊸⊑) rca)_t¨ 𝕩 }⍟(0<≠) ∾1↓pmn
    }⍟(ch∧0⊸<∧≤⟜5) 𝕨
  }
}

_testMonFold ← {
  l ← 𝕨 gen.Arith RandBound 𝕩
  Pad ← gen.Arith∘1⍟(⊑∊⟜√‿|‿≤‿<)⍟(0=≠∘gen.Dat∘⊢)  # Avoid missing identity
  modop {m←𝕩 ⋄ 𝕨_m _testConsistent_ FlatMatch 𝕨 Pad l }⌜ 𝕗
}
_testDyFold ← {
  i‿l ← ¯1 (⊑⋈↓) gen.Dat 𝕨 gen.Arith 1 + RandBound 𝕩
  modop {m←𝕩 ⋄ i 𝕨_m _testConsistent_ FlatMatch l }⌜ 𝕗
}
_testMonScan ← {
  l ← 𝕨 gen.Arith (∨`⌾⌽ 𝕩 ≥ ·×`1⌾⊑)⊸/⍟(0=⊑) RandShape1 𝕩
  Pad ← (𝕨 gen.Arith 1⌾⊑∘≢∘gen.Dat∘⊢)⍟(⊑∊⟜√‿|‿≤‿<)⍟(0=≠∘⊢)
  modop {m←𝕩 ⋄ 𝕨_m _testConsistent_ FlatMatch 𝕨 Pad l }⌜ 𝕗
}
_testDyScan ← {
  i‿l ← 𝕨⊸gen.Arith¨ 1⊸↓⊸⋈ (∧`𝕩≥·×`1⌾⊑)⊸/⍟(0=⊑) RandShape1 𝕩
  modop {m←𝕩 ⋄ i 𝕨_m _testConsistent_ FlatMatch l }⌜ 𝕗
}

_testMonStruct ← { # ⥊≍⌽⍉⊏
  k ← 3|1+ ⌽‿⊏ ⊐ 𝕗
  sh ← k ⊏ {𝕏𝕨}` (1+⌈´k) ↑ ⟨RandShape 𝕩, 1⊸∾⍟(0=≠), 1⊸∾⍟(0=⊑)⟩
  ((⊐sh) ⊏ 𝕨⊸gen.Struct¨ ⍷sh) { 𝕏 _testConsistent_ ≡ 𝕨 }¨ 𝕗
}

_testDyStruct ← { # ⥊↑↓↕⌽⍉ (no overtake)
  d ← 𝕨 gen.Struct sh ← RandShape 𝕩
  l ← RandShape 𝕩
  K ← (Rand 1+≠)⊸↑
  RR ← ≍ ⟨⊑⊸+,⊢´⊸-⟩_randChoose RandBound∘¬˜
  RT ← (-RR¨⊢)K
  p‿r ← <˘⍉> ⟨⟨⥊,(0∾1⊸↓)⍟(sh>○(0=×´)⊢)∘l⟩, ⟨↓,l‿RT _randChoose⟩
              ⟨⌽,RT+˜⟩, ⟨↑,RT⟩, ⟨↕,0 RR¨ 1+K⟩, ⟨⍉,(⍋⊏⊐)Rand˜∘≠⟩⟩
  (r⊏˜p⊐𝕗) { (𝕎sh) 𝕏 _testConsistent_ ≡ d }¨ 𝕗
}

_testDim ← { # ≠=≢
  (𝕨 gen.Struct RandShape 𝕩)⊸{ 𝕏 _testConsistent_ ≡ 𝕨 }¨ 𝕗
}

_testCombine ← { # ≍∾«»
  a ← 𝕨 gen.Struct sh ← RandShape1 𝕩
  bs ← (RandBound 1⊸+)⌾⊑⍟({≍}≠𝕗) sh
  swap ← (Rand 2)⊑{𝔽}‿˜
  ((⊐bs) ⊏ 𝕨⊸gen.Struct¨ ⍷bs) { a 𝕏 _testConsistent_ ≡ _swap 𝕨 }¨ 𝕗
}

_testMonSearch ← { # ⊐⊒∊⍷∧∨⍋⍒
  (𝕨 gen.Arith RandShape1 𝕩)⊸{ 𝕏 _testConsistent_ ≡ 𝕨 }¨ 𝕗
}
_testDySearch ← { # ⊐⊒∊⍋⍒
  sh ← RandShape1 𝕩
  k ← ⍋‿⍒⊐𝕗
  a‿b ← 𝕨⊸gen.Arith¨ ⟨sh, (0⊸<◶⟨-⟜⌊RandShape∘𝕩,RandShape⟩·⌊𝕩÷1⌈×´)⊸∾ 1↓sh⟩
  as ← (⊐k) ⊏ {𝕏gen.Dat a}¨(⍷k)⊏∧‿∨‿⊢
  as { 𝕨 𝕏 _testConsistent_ ≡ b }¨ {𝕏˜}⍟(∊˙⊸=)¨ 𝕗
}

RandRep ← -⟜((0⌊1⊸↑)⊸»)∘∧ 1⊸+⊸(gen.Dat gen.Index)⟜⥊
_testIndices ← { # /⊔
  (RandRep○RandBound˜ 𝕩)⊸{ 𝕏 _testConsistent_ ≡ 𝕨 }¨ 𝕗
}
_testSelect ← { # /⊏⊔
  l‿sh ← (⍋≠¨)⊸⊏ RandShape¨ 𝕩‿𝕩
  n ← RandBound 𝕩
  d ← 𝕨 gen.Struct sh
  RandInd ← ∧○(0⊸≠)◶⟨⟨⟩,gen.Index⟜(⥊‿RandShape _randChoose)˜⟩
  g ← ({⊏} = 𝕗) ⊏ RandRep‿RandInd
  g { (n         𝕎  0⊣´sh) 𝕏 _testConsistent_ ≡ d }¨ 𝕗
  g { (l gen.Dat∘𝕎¨l≠⊸↑sh) 𝕏 _testConsistent_ ≡ d }⍟((0<≠l)∨⊔˙⊸≠)¨ 𝕗
}

cases ← [
  ⟨∾`"+-×÷⋆√⌊⌈¬|"‿"∧∨≤<>≥=≠", testMonArith‿testDyArith⟩
  ⟨"⥊≍⌽⍉⊏"‿"⥊↑↓↕⌽⍉", testMonStruct‿testDyStruct⟩  # Monadic «» hard to test
  ⟨"≠=≢"‿"", testDim‿@⟩
  ⟨""‿"≍∾«»", @‿testCombine⟩
  ⟨"⊐⊒∊⍷∧∨⍋⍒"‿"⊐⊒∊⍋⍒", testMonSearch‿testDySearch⟩
  ⟨"/⊔"‿"/⊏⊔", testIndices‿testSelect⟩
# ↕<∾↑↓≡>⊑ % ⊑⍷
  ⟨"´"‿"´", testMonFold‿testDyFold⟩
  ⟨"˝`"‿"˝`", testMonScan‿testDyScan⟩
# ˘⎉¨⚇⌜⁼⍟
]
MakeTests ← {
  prim‿test ← <∘>˘ ⍉ 𝕨
  m ← 𝕩 ∊¨⎉1 prim
  ((∾"Unsupported primitives: "‿"%"∾¨/¨⟜𝕩) ! 0˙)⍟(∨´∨´¨) ¬∨˝m
  p ← •BQN∘⥊¨¨ 𝕩
  t ← <∘{t←2⊑𝕩⋄(/´2↑𝕩)_t}˘ (∨´¨⊏˘)⊸/ ⍉>⥊¨⟨m,p˙˘m,test⟩
  1 {𝕎⊢𝕏}´ t
}

pr ← (⊑cases)⍟(0=·+´≠¨) opts.prims
modop ← •BQN∘⥊¨ (1⊑⊑cases)⍟(0=≠) opts.modop
opts.types (cases MakeTests pr)⌜ opts.num/opts.bounds
