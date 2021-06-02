# Tester that checks primitives on random arguments

opts ← {
help ← 1↓"
Fuzz testing. Options:
  -h, --help: Print this message and exit
  -b: Maximum bound (1e3)
  -n: Number of iterations (100)
  -t: Element type (0 3 4 5 6)
  -p: Primitives: both | mon%dy | mon%dy%both

Any number of types or bounds can be given; all combinations are tested."

  o ← "-h"‿"--help"‿"-b"‿"-n"‿"-t"‿"-p"
  oo ← (≠o) = oi ← o ⊐ a←•args
  •Exit∘•Out∘help⍟(∨´2⊸>) oi

  opts ← 2↓o≠⊸↑ a ⊔˜ (¬-˜⊢× oi⊏˜ ↕∘≠⌈`∘×¬)oo
  bounds‿num‿types‿prims ⇐ •BQN¨¨⌾(¯1⊸↓) opts
  "Only one iteration number can be given" ! 1≥≠num
  num ↩ ≠◶⟨100,+´⟩ num
  types ↩ 0‿3‿4‿5‿6⍟(0=≠) types
  bounds ↩ ⟨1e3⟩⍟(0=≠) bounds

  prims ↩ ((⊢-˜¬×+`+2×·¬∨´)'%'⊸=)¨⊸(⊔○∾) prims
  "At most three %-separated primitive groups allowed" ! 3≥≠prims
  arith ← ∾`"+-×÷⋆√⌊⌈¬|"‿"∧∨≤<>≥=≠"
  Pr ← {
    𝕩 ↩ 2 (↑((¬∘∊/⊣)∾⊢)¨⊏) 3 ↑ 𝕩
    "Only arithmetic primitives supported" ! ∧´∾𝕩∊¨arith
    𝕩
  }
  monArith‿dyArith ⇐ •BQN∘⥊¨¨ prims ↩ (0<≠)◶arith‿Pr prims
}

Squeeze‿ListVariations‿Variation‿ClearRefs ← •internal

Range ← (•MakeRand 2).Range
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

  Augment ← {
    d ← 1+⌊𝕨÷1⌈×´𝕩         # Maximum bound that can be added, plus 1
    C ← 10⊸+ Rand⊸< 1.2⊸√  # Decide whether to add
    d (𝕨 𝕊 ⟨∾,∾˜⟩_randChoose⟜RandBound˜)⍟(C⊣) 𝕩
  }
  Combine ← ⟨
    Rand∘≠⊸⌽ (2+Rand∘≠)⊸{×´¨𝕨↑(𝕨|↕∘≠)⊸⊔𝕩}∘⊢ # Random number of groups
    ×´¨ (⊐·Rand¨⥊˜∘≠)⊸⊔∘⊢                   # Distribute randomly
  ⟩_randChoose
  RandShape ⇐ ⊢ Augment ⟨
    ⊢ (⊢ ⌊∘× ⊢ ≠⊸√ (Sigmoid⊸÷1⌈×´⊸÷˜)) · Rand¨ (RandRank⌈√<Rand)⊸⥊
    ⊢ Combine⟜Factor 1⌈RandBound
  ⟩_randChoose
}

# 𝕨 is 2⋆⁼bits in type; 𝕩 is shape
⟨RandArith⟩ ← {
  RandInt ← { (1⊸<⊸×m÷2) -˜ 𝕩 Rand m←2⋆2⋆𝕨 }

  floats ← ⟨2⋆¯1074,2⋆¯1022,(2-2⋆¯52)×2⋆1023⟩
  RandFloat ← ⟨
    (floats∾2⋆0‿8‿32‿100)_randChoose × Range⟜0 - 2÷˜Rand∘3
    ⊢ (Rand⟜≠⊏⊢) (Rand(⊣≥⌈´⊸⌊)3+Rand∘+)˜∘≠⊸/∘(∾⟜-0∾floats∾∞)
  ⟩_randChoose

  RandTyped ← =⟜6◶⟨RandInt,RandFloat⊣⟩

  RN ← (0⌈-⟜1) ⌊ 1‿RandRank‿RandBound _randChoose
  RandSplit ← ⌽⍟(Rand∘2) (-≍⊢)⟜RN
  Combine ← (⍋Rand˜∘≠)⊸⊏⍟(Rand∘2) ∾

  RL ← {𝕨RandList𝕩}
  RandList ⇐ ⟨
    RandTyped                               # Random
    ∧‿∨_randChoose RandTyped                # Sort
    ⊢ ⥊ RL⟜(1⌈RN)                           # Repeat
    Combine Rand‿⊢_randChoose⊸RL¨⟜RandSplit # Partition
  ⟩{ 8⊸≤◶⟨0,Rand∘(≠𝕗)⟩◶𝕗 }
  RandArith ⇐ Squeeze ⊢ ⥊ RandList⟜(×´)
}

# 𝕩 is bound
RandMonArith ← RandArith⟜RandShape
RandDyArith ← {
  Prefix ← (∨`⌾⌽ 𝕩 ≥ ×`)⊸/ (Rand 1+≠)⊸↑
  𝕨⊸RandArith¨ (Rand 2) ⌽ ≍○<⟜Prefix RandShape 𝕩
}

_testConsistent_ ← {Match←𝔾
  v ← <˘⍉> (5⌊´≠¨)⊸((Rand⟜≠⊏⊢)¨) ListVariations¨ a←𝕨≍○<𝕩
  (ClearRefs@) ⊢ (∧´ ⊏ Match¨ 1⊸↓) (𝕨 (𝔽⊑∘⊢)⊘(𝔽´⊢) Variation¨⟜a)¨ v
}

FlatMatch ← ≡◶⟨∧´∘⥊=∨∧○(≠˜),1⟩

TestMonArith ← {
  t ← 𝕨 RandMonArith 𝕩
  { ! 𝕏 _testConsistent_ FlatMatch t }¨ opts.monArith
}
TestDyArith ← {
  t ← 𝕨 RandDyArith 𝕩
  { ! 𝕏 _testConsistent_ FlatMatch´ t }¨ opts.dyArith
}

t←opts.types ⋄ b←opts.num/opts.bounds
t TestMonArith⌜ b
t TestDyArith ⌜ b
