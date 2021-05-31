# Tester that checks primitives on random arguments

# Linear congruential RNG; result in ↕2⋆16
rr ← 2⋆16 # Random range
_makeRand ← {st←𝕗
  d‿m←2⋆15‿31
  {𝕤⋄ d ⌊∘÷˜ st ↩ m|2531011+214013×st }
}
RandGen ← 1234 _makeRand
RandSh ← ⊢ ⥊ ·RandGen¨ (↕×´)
Rand ← { 𝕩⌈↩1 ⋄ 𝕨 ⊢⊘⥊ 𝕩 | 0 rr⊸×⊸+˜´ (𝕨RandGen⊘(RandSh∘⊣)⊢)¨↕⌈rr⋆⁼𝕩 }
_randChoose ← { Rand∘(≠𝕗)◶𝕗 }
_randUnbounded ← { 𝕊⊸+⍟(1=-)⟜Rand 𝕗 }

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
    Rand                                     # Uniform
    Rand 128⊸⌊                               # Small
    -⟜1 ⌊ Rand∘(1⌈⌈)⌾((2⋆3+⊢)⁼) + ¯7+Rand∘15 # Near power of two
  ⟩_randChoose

  RandRank ← 4 _randUnbounded

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
RandArith ← {
  •internal.Squeeze (1⊸<⊸×m÷2) -˜ 𝕩 Rand m←2⋆𝕨
}
# 𝕩 is bound
RandMonArith ← RandArith⟜RandShape
RandDyArith ← {
  Prefix ← (∨`⌾⌽ 𝕩 ≥ ×`)⊸/ (Rand 1+≠)⊸↑
  𝕨⊸RandArith¨ (Rand 2) ⌽ ≍○<⟜Prefix RandShape 𝕩
}

types ← 0‿3‿4‿5‿6
types { ! (𝕨+𝕩)≡𝕨--𝕩 }´∘RandDyArith⌜ 100⥊1e3
