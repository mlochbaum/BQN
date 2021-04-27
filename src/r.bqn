# BQN runtime. Requires:
#   Type Fill Log GroupLen GroupOrd _fillBy_
#   !+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘
# Filled in by runtime: glyphs and default PrimInd
Decompose ← {0‿𝕩}
PrimInd ← {𝕩}
SetPrims ← {Decompose‿PrimInd ↩ 𝕩}

◶ ← {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}     # LIMITED to number left operand result
⊢ ← {𝕩}
⊣ ← {𝕩}⊘{𝕨}
˙ ← {𝕩⋄𝕗}
˜ ← {𝕩𝔽𝕨⊣𝕩}
∘ ← {𝔽𝕨𝔾𝕩}
○ ← {(𝔾𝕨)𝔽𝔾𝕩}
⊸ ← {(𝔽𝕨⊣𝕩)𝔾𝕩}
⟜ ← {(𝕨⊣𝕩)𝔽𝔾𝕩}
⍟ ← {𝕨((𝕨𝔾𝕩)⊑⊢‿𝕗){𝔽}𝕩}   # LIMITED to boolean right operand result

IsArray←0=Type
Int←(1=Type)◶⟨0,⌊⊸=⟩
Nat←(1=Type)◶⟨0,0⊸≤×⌊⊸=⟩
Deshape←IsArray◶{𝕩Fill⟨𝕩⟩}‿⥊
Pair ← {⟨𝕩⟩} ⊘ {⟨𝕨,𝕩⟩}
Box ← {𝕩Fill⟨⟩⥊⟨𝕩⟩}
ToArray ← Box⍟(1-IsArray)

# LIMITED to numeric arguments for arithmetic cases
≥ ←            ≤˜
< ← Box      ⊘ (1-≥)
> ←            (1-≤)
⌊ ↩ ⌊        ⊘ (⊣-≥×-)
⌈ ← -∘⌊∘-    ⊘ (⊣-≤×-)
| ← 0⊸≤◶-‿⊢
≠ ← (0<=)◶⟨1⋄0⊑≢⟩  # LIMITED to monadic case

_fold←{
  "´: 𝕩 must be a list" ! 1==𝕩
  l←≠v←𝕩 ⋄ F←𝔽
  r←𝕨 (0<l)◶{𝕩⋄Identity f}‿{l↩l-1⋄l⊑𝕩}⊘⊣ 𝕩
  ({r↩𝕩 F r}(l-1)⊸-⊑𝕩˙)⌜↕l
  r
}
´ ← _fold

∾ ← {k←≠𝕨⋄k⊸≤◶⟨⊑⟜𝕨⋄-⟜k⊑𝕩˜⟩⌜↕k+≠𝕩}  # LIMITED to two list arguments
↑ ← {⊑⟜𝕩⌜↕𝕨}                       # LIMITED to number 𝕨 and list 𝕩
↓ ← {(𝕨⊸+⊑𝕩˙)⌜↕(≠𝕩)-𝕨}             # LIMITED to number 𝕨 and list 𝕩
Cell ← ↓⟜≢

GetCells←(1==∘⊢)◶{
  c←1×´s←1 Cell 𝕩
  𝕨((⥊𝕩)⊑˜c⊸×⊸+)⌜s⥊↕c
}‿{
  ⊑⟜𝕩⌜𝕨
} _fillBy_ ⊢
⊏ ← GetCells  # LIMITED to depth-1 natural number left argument

_qSearch ← {+´·×`𝕗(1-=)⌜<}
_glyphLookup_ ← {
  {PrimInd𝕩} ⊑ ((𝕘⊑˜𝕗_qSearch)⌜glyphs)˙
}
_isGlyph ← { (glyphs _qSearch 𝕗) = {PrimInd𝕩} }
IsJoin ← '∾'_isGlyph

Split2 ← { s←2⊸×⌜↕(≠𝕩)÷2 ⋄ ⟨s⊏𝕩,(1⊸+⌜s)⊏𝕩⟩ }
_lookup_ ← {
  k‿v←Split2 𝕘 ⋄ k _glyphLookup_ (v∾⟨𝕗⟩)
}
Identity ← {𝕏0} ("´: Identity not found"!0˙) _lookup_ ⟨
  '+',0 , '-',0
  '×',1 , '÷',1
  '⋆',1 , '¬',1
  '⌊',∞ , '⌈',¯∞
  '∨',0 , '∧',1
  '≠',0 , '=',1
  '>',0 , '≥',1
⟩

_eachd←{
  _d←{ # Equal ranks
    p←≢𝕨
    "Mapping: Equal-rank argument shapes don't agree" ! 1(⊑⟜p=⊑⟜(≢𝕩))⊸×´↕=𝕨
    p⥊ (⊑⟜(⥊𝕨)𝔽⊑⟜(⥊𝕩))⌜↕1×´p
  }
  _e←{ # 𝕨 has smaller or equal rank
    p←≢𝕨 ⋄ k←=𝕨 ⋄ q←≢𝕩
    "Mapping: Argument shape prefixes don't agree" ! 1(⊑⟜p=⊑⟜q)⊸×´↕k
    l←1(q⊑˜k⊸+)⊸×´↕(=𝕩)-k
    a←⥊𝕨 ⋄ b←⥊𝕩
    q⥊⥊(≠a) (⊑⟜a𝔽l⊸×⊸+⊑b˙)⌜○↕ l
  }
  =○=◶⟨>○=◶⟨𝔽_e⋄𝔽˜_e˜⟩⋄𝔽_d⟩
}

_perv←{ # Pervasion
  R←𝔽{𝕨𝔽_perv𝕩}
  +○IsArray◶⟨
    𝔽
    R⌜⊘(>○IsArray◶{𝕨{𝕗R𝕩}⌜𝕩}‿{𝕩{𝕩R𝕗}⌜𝕨}) _fillBy_ R
    R _eachd _fillBy_ R
  ⟩
}

# Sorting
Cmp0 ← ≥-≤
Cmp1 ← (0<1×´≢∘⊢)◶⟨1, IsArray∘⊢◶(1-2×≤)‿{𝕨Cmp1𝕩}⟜(0⊑⥊)⟩
CmpLen ← {
  e←𝕨-○(1×´0⊸<⌜)𝕩
  𝕨(e=0)◶⟨e,0⟩‿{
    SM←Cmp0 Pair ≥⊑Pair
    c‿r←𝕨SM○≠𝕩
    l←𝕨{
      i←0+´×`𝕨=_eachd𝕩
      m←1×´i↕⊸⊏𝕨
      {k‿l←SM´𝕩⋄c↩k⋄m×↩l}∘(<⊑⌜𝕨‿𝕩˙)⍟(r⊸>)i
      m
    }○{(𝕩⊑˜(¯1+≠𝕩)⊸-)⌜↕r}𝕩
    ⟨c,l⟩
  }𝕩
}
_getCellCmp ← {
  Ci←𝔽⋄c←𝕨⊣0⋄l←𝕩
  Cc←{
    a←𝕨⋄b←𝕩
    S←(l⊸=)◶{S∘(1+𝕩)⍟(0⊸=)a Ci○(𝕩⊸+)b}‿c
    S 0
  }
  (𝕨 ⊢⊘{𝕨⍟(0⊸=)𝕏} ci˙)⍟(1=l) cc
}
Cmp ← +○IsArray◶⟨
  Cmp0
  IsArray∘⊣◶⟨Cmp1,-Cmp1˜⟩
  {
    lc←𝕨CmpLen○≢𝕩
    cc ← (⊑⟜(⥊𝕨))⊸Cmp⟜(⊑⟜(⥊𝕩)) _getCellCmp´ lc
    Cc˜0
  }
⟩

_grade ← {
  gt ← 𝕗
  cmps ← {𝕏˜}⌜⍟𝕗⟨Cmp,Cmp0,Cmp≤0˙,≤⟩
  0 Fill {
    "⍋𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
    l←≠𝕩
    (2≤l)◶⟨↕∘l,{
      m1←1=m←1×´1 Cell 𝕩
      𝕩↩⥊𝕩
      a0←1⋄ts←0⋄{a0×↩1≤𝕩⋄ts+↩𝕩}∘Type⌜𝕩
      cs←a0+2×m1
      Merge ← { # Merge sort
        le ← m {(𝕏 _getCellCmp m)≤0˙}⍟(1-m1) 𝕩{𝕏○(⊑⟜𝕗)} cs⊑cmps
        B←l⊸≤◶⊢‿l
        (↕l){
          i←-d←𝕨 ⋄ j←ei←ej←0
          e←3 ⋄ G←LE○(⊑⟜(m⊸×⌜⍟(1-m=1)𝕩)) ⋄ c←⟨1-G,0,1,2⟩
          s←(8≤d)⊑⟨+,{(𝕩-1){𝕩⋄e↩2⋄j↩i⋄i↩𝕩}⍟G⍟(1-e)𝕩}⟩
          N←{i↩d+𝕨⋄ej↩B d+ei↩B j↩d+𝕩⋄e↩l≤j⋄S ei⋄i R j}
          R←{𝕨e◶c𝕩}◶{e+↩2×ei=i↩1+𝕨⋄𝕨}‿{e+↩ej=j↩1+𝕩⋄𝕩}‿N
          {(i R j)⊑𝕩}⟜𝕩⌜𝕩
        }´(2⋆ni-1+⊢)⌜↕ni←⌈2 Log l+l=0
      }
      # Counting sort for small-range ints
      bl←bu←0 ⋄ Count←{GroupLen⊸GroupOrd (gt⊑⟨-⟜bl,bu⊸-⟩)⌜𝕩}
      sr←((3=cs)×ts=l)◶⟨0,(1×´⌊⊸=⌜)◶0‿{((bu↩⌈´𝕩)-bl↩⌊´𝕩)≤2×l}⟩𝕩
      sr◶Merge‿Count 𝕩
    }⟩𝕩
  }
}
_binSearch ← {
  B ← 𝔽
  {
    R←{𝕨{a←B m←𝕩+h←⌊𝕨÷2⋄(h+a×𝕨-2×h)R a⊑𝕩‿m}⍟(>⟜1)𝕩}
    1+(𝕩+1)R ¯1
  }⍟(0⊸<)
}
_bins←{
  c←1-˜=𝕨
  "⍋ or ⍒: Rank of 𝕨 must be at least 1" ! 0≤c
  "⍋ or ⍒: Rank of 𝕩 must be at least cell rank of 𝕨" ! c≤=𝕩
  𝕩↩ToArray 𝕩
  lw←1×´sw←1 Cell 𝕨
  cw←𝔽○(⊑⟜(⥊𝕨)) _getCellCmp lw
  "⍋ or ⍒: 𝕨 must be sorted" ! 0⊸<◶⟨1,1×´·(cw≤0˙)⟜(lw⊸+)∘(lw⊸×)⌜↕∘-⟜1⟩≠𝕨
  cx←c-˜=𝕩
  sx←cx Cell 𝕩 ⋄ lc←sw CmpLen sx
  cc ← (⊑⟜(⥊𝕨))⊸𝔽⟜(⊑⟜(⥊𝕩)) _getCellCmp´ lc
  B←(1×´sw)⊸×⊸Cc≤0˙
  0 Fill (≠𝕨)⊸{B⟜𝕩 _binSearch 𝕨}⌜ (1×´sx)⊸×⌜ ⥊⟜(↕1×´⊢)⊑⟜(≢𝕩)⌜↕cx
}

⍋ ← 0 _grade ⊘ (Cmp  _bins)
⍒ ← 1 _grade ⊘ (Cmp˜ _bins)

# Searching
_search←{ # 0 for ∊˜, 1 for ⊐
  ind ← 𝕗
  red ← 𝕗⊑⟨1-×´,+´×`⟩
  0 Fill {
    c←1-˜=𝕨
    "p⊐𝕩 or 𝕨∊p: p must have rank at least 1" ! 0≤c
    "p⊐n or n∊p: Rank of n must be at least cell rank of p" ! c≤=𝕩
    n←≠𝕨 ⋄ k←1×´s←1 Cell 𝕨 ⋄ cx←c-˜=𝕩
    lx←1×´sh←cx↑≢𝕩
    sh ⥊ 𝕨 (0<n)◶⟨0,s MatchS cx⊸Cell⟩◶{𝕩⋄(ind×n)⌜↕lx}‿{
      cc ← (⊑⟜(⥊𝕨))⊸(1-Match)⟜(⊑⟜(⥊𝕩)) _getCellCmp k
      𝕨 ×○(8<≠∘⥊)◶{𝕩
        i‿j←(k⊸×⌜↕)⌜n‿lx ⋄ {Red CC⟜𝕩⌜i}⌜j
      }‿{
        g←Reverse⍒𝕨
        i←(g⊑˜0⌈-⟜1)⌜(g⊏𝕨)⍋𝕩
        adj←ind⊑⟨1⊸-,⊣--⟜n⊸×⟩
        ⊑⟜i⊸(⊣ Adj CC○(k⊸×))⌜↕lx
      } 𝕩
    } ToArray𝕩
  }
}

Indices←{
  "/: Replication argument must have rank 1" ! 1==𝕩
  l←≠𝕩
  0 Fill {
    "/: Amounts to replicate must be natural numbers" ! 1×´Nat⌜𝕩
    k←l-1
    N ← ((⊢+-×0=𝕩⊑˜⊢)`k⊸-⌜↕l)⊑˜k-⊢  # Next nonzero
    E ← ⊑⟜(+`𝕩)
    ei←E i←N 0
    {{ei↩E i↩N𝕩+1⋄i}⍟(𝕩=ei)i}⌜↕E k
  }⍟(0<l)𝕩
}
Rep ← Indices⊸⊏

Transpose←(0<=)◶⟨ToArray,{
  l←≠𝕩 ⋄ m←1×´c←1 Cell 𝕩
  (c⥊↕m)(+⟜(m⊸×)⊑(⥊𝕩)˙)⌜↕l
}_fillBy_⊢⟩
TransposeInv←{
  r←1-˜=𝕩 ⋄ s←≢𝕩 ⋄ l←r⊑s ⋄ c←⊑⟜s⌜↕r
  (↕l)(+⟜(l⊸×)⊑(⥊𝕩)˙)⌜c⥊↕1×´c
}_fillBy_⊢⍟{IX IsArray𝕩⋄0<=𝕩}

Reverse←{
  "⌽𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  l←≠𝕩
  ((l-1)⊸-⌜↕l) ⊏ 𝕩
}
Rot←{
  "𝕨⌽𝕩: 𝕨 must consist of integers" ! Int𝕨
  l←≠𝕩 ⋄ 𝕨-↩l×⌊𝕨÷l+l=0 ⋄ ((𝕨+⊢-l×(l-𝕨)≤⊢)⌜↕l) ⊏ 𝕩
}

Prefixes←{
  "↑𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  0⊸⊑⊸Fill ↕⊸⊏⟜𝕩⌜ ↕1+≠𝕩
}
Suffixes←{
  "↓𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  l←≠𝕩
  l⊸⊑⊸Fill {𝕩⊸+⌜↕l-𝕩}⊸⊏⟜𝕩⌜ ↕1+l
}

NormIndP‿NormIndS←{
  ei‿er←𝕩 ⋄ _cr←{⊢⊣er!𝔽}
  0⊸≤◶⟨0⊸≤_cr+, >_cr⟩ ⊣ ei!Int∘⊢
}⌜⟨
  "𝕨⊑𝕩: Indices in 𝕨 must consist of integers"‿"𝕨⊑𝕩: Index out of range"
  "𝕨⊏𝕩: Indices in 𝕨 must be integers"‿"𝕨⊏𝕩: Indices out of range"
⟩
Pick0←{
  "𝕨⊑𝕩: 𝕩 must be a list when 𝕨 is a number" ! 1==𝕩
  𝕩⊑˜(≠𝕩)NormIndP𝕨
}
Pick1←{
  "𝕨⊑𝕩: Indices in compound 𝕨 must be lists" ! 1==𝕨
  "𝕨⊑𝕩: Index length in 𝕨 must match rank of 𝕩" ! 𝕨=○≠s←≢𝕩
  i←0⋄(⊑⟜𝕨{i↩(𝕩NormIndP𝕨)+𝕩×i}⊑⟜s)⌜↕≠𝕨
  i⊑Deshape𝕩
}⟜ToArray
Pickd←(0<0+´IsArray⌜∘⥊∘⊣)◶Pick1‿{Pickd⟜𝕩⌜𝕨}
Pick←IsArray∘⊣◶Pick0‿Pickd

FirstCell←{
  "⊏𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  "⊏𝕩: 𝕩 cannot have length 0" ! 0<≠𝕩
  (<0) ⊏ 𝕩
}
SelSub←{
  "𝕨⊏𝕩: 𝕨 must be an array" ! IsArray 𝕨
  𝕨 (≠𝕩)⊸NormIndS⌜⊸⊏ 𝕩
}
First ← IsArray◶⟨⊢, (0<≠)◶⟨Fill,0⊸⊑⟩⥊⟩

IsPure ← {d←Decompose𝕩 ⋄ 2⊸≤◶⟨≤⟜0, 1(𝕊d⊑˜1⊸+)⊸×´·↕1-˜≠∘d⟩0⊑d}
_fillByPure_←{
  𝕘 (3≤Type∘⊣)◶⟨{𝕨Fill𝕏},{(𝕨HomFil𝕩)_fillBy_𝕨}⍟(IsPure⊣)⟩ 𝕗
}

StructErr←{𝕩}
IsStructErr ← (3=Type)◶⟨0,StructErr˙⊸=⟩
_under_←{
  val←𝕨𝔽○𝔾𝕩
  # Construct indices
  Inds ← IsArray◶⟨0,⥊⟜(↕1×´⊢)≢⟩ 𝕩 ⊑⟜⥊⍟(IsArray⊢)´ Reverse
  _s_ ← {
    f←𝕗
    st‿d‿o←𝕩
    g←𝕨 St Inds∘{f↩f(IsArray⊣)◶⟨⟩‿∾⟨𝕩⟩}⍟(d>IsArray) 𝕘
    {f _s_ 𝕩}⍟o g
  }
  IsStruct ← (5=0⊸⊑)◶⟨0,s˙=2⊸⊑⟩ Decompose
  sf ← isStruct StructFn 𝕘 ⋄ SR ← ¯1 _s_ 0
  root‿ind ← IsStruct◶⟨0‿StructErr,1‿3⊏Decompose⟩ SF sr

  # Traverse indices 𝕩 and values 𝕨.
  # Return flat lists ⟨indices,values⟩, or structErr if 𝕨 doesn't capture 𝕩.
  GetInserts←{
    count←0⋄depth←{IsArray◶⟨{𝕩⋄count+↩1⋄0},1+0⌈´𝕊⌜∘⥊⟩𝕩}𝕩
    𝕩 (2⌊depth)◶(Pair○Pair)‿(StructConform◶⟨StructErr˙,Pair○⥊⟩)‿{
      Fail←{𝕊‿0}
      # 𝕎 is parent traversal; 𝕩 is current components of ind and val
      Trav←(IsArray 0⊑⊢)◶⟨Pair, StructConform´∘⊢◶Fail‿{
        Parent←𝕎 ⋄ n←≠0⊑a←⥊⌜𝕩 ⋄ j←¯1
        Child←Trav⟜{𝕩⊸⊑⌜a}
        { j+↩1 ⋄ f←n⊸≤◶⟨𝕊˙⊸Child,Parent˙⟩j ⋄ F 0 }
      }⟩
      next ← 0 Trav 𝕨‿𝕩
      res ← {n‿o←Next𝕩⋄next↩n⋄o}⌜ ↕count
      (next=fail)◶⟨0⊸⊑⌜ Pair 1⊸⊑⌜, StructErr˙⟩ res
    } 𝕨
  }⍟(1-IsStructErr∘⊢)
  Struct←{
    i‿v←𝕨
    Set1←𝕨⊸{
      𝕩↩ToArray𝕩
      s←≢𝕩⋄l←≠d←⥊𝕩
      gl←l GroupLen i ⋄ g←gl GroupOrd i
      Sel←v⊑˜⊑⟜g
      j←0⋄Adv←Sel{(j+↩𝕩)-1}
      CM←"⌾: Incompatible result elements in structural Under"!Match⟜Sel
      s⥊2⊸⌊◶⟨⊑⟜d,Adv,Adv{(𝕨CM(j-𝕩)⊸+)⌜↕𝕩-1⋄𝕨}⊢⟩⟜(⊑⟜gl)⌜↕l
    }
    _at_ ← {𝔽⍟((𝔾𝕩)=⊣)⟜(⊑⟜𝕩)⌜ ↕≠𝕩}
    Set ← 0⊸{ (𝕨≥≠root)◶⟨≢⥊(1+𝕨)⊸𝕊_at_(𝕨⊑root˙)∘⥊, Set1⟩ 𝕩 }
    IsArray∘root◶⟨0⊑v˙, Set⟩ 𝕩
  } _fillBy_ ⊢
  IsStructErr◶⟨Struct⟜(𝕩˙), {𝕏val}·Inverse𝔾˙⟩ val GetInserts ind
}

MatchS ← 1×´=_eachd
match←{(0⊑𝕨)◶(1⊑𝕨)‿𝕩}´⟨
  ⟨=○IsArray, 0⟩
  ⟨IsArray∘⊢, =⟩
  ⟨=○=      , 0⟩
  ⟨MatchS○≢ , 0⟩
  {1×´⥊𝕨 Match _eachd 𝕩}
⟩
structConform ← {𝕎◶0‿𝕏}´⟨IsArray⊢, =○=, MatchS○≢⟩
Depth←IsArray◶0‿{1+0⌈´Depth⌜⥊𝕩}

≡ ← Depth          ⊘ Match
≢ ↩ IsArray◶⟨⟩‿≢   ⊘ (1-Match)
¨ ← {𝕨𝔽⌜⊘(𝔽_eachd)_fillByPure_𝔽○ToArray𝕩}

IF ← ⊢⊣!∘≡  # Intersect fill
IEF← (0<≠)◶⟨⊢_fillBy_ Fill, ⊢_fillBy_ IF´⟩∘⥊
_fillMerge_ ← {(0<≠∘⥊)◶⟨(𝔾○≢⥊⟨⟩˙)_fillBy_⊢⟜Fill, 𝔽 ⊣_fillBy_⊢ IEF⟩}
Merge←{
  c←≢0⊑⥊𝕩
  (">𝕩: Elements of 𝕩 must have matching shapes" ! c =○≠◶0‿MatchS ≢)⌜⥊𝕩
  (Deshape⌜𝕩)⊑˜⌜c⥊↕1×´c
}_fillMerge_∾⍟IsArray

Join1←{
  # List of lists
  i←j←¯1 ⋄ e←⟨⟩ ⋄ a←𝕩
  {{e↩a⊑˜i↩𝕩⋄j↩¯1}⍟(1-i⊸=)𝕩⋄(j↩j+1)⊑e}⌜Indices≠⌜𝕩
}
JoinM←{
  # Multidimensional
  n←≠z←⥊𝕩 ⋄ s←≢⌜z ⋄ d←≠0⊑s ⋄ r←=𝕩
  "∾𝕩: Elements of 𝕩 must all have the same rank" ! 1×´(d=≠)⌜s
  "∾𝕩: 𝕩 element rank must be at least argument rank" ! d≥r
  _s0←{s←𝕨⋄F←𝔽⋄{o←s⋄s F↩𝕩⋄o}⌜𝕩}
  sh←≢𝕩 ⋄ p←1 ⋄ i←j←<0
  (Reverse 1×_s0 Reverse sh){
    q←𝕨
    a←𝕩⊑sh
    m←𝕩⊸⊑⌜s
    l←(q⊸×⊑m˙)⌜↕a
    "∾𝕩: 𝕩 element shapes must be compatible" ! 1×´m=¨⥊(↕p)⊢⌜l⊣⌜↕q
    k ← Indices l
    c ← -⟜(⊑⟜(k ⊏ 0+_s0 l))⌜ ↕≠k
    i ↩ (i ×⟜(⊑⟜l)⌜ k) +¨ i⊢⌜c
    j ↩ j ×⟜a⊸+⌜ k
    p×↩a
  }¨↕r
  G←(⥊⌜z){𝕨⊑𝕩⊑𝕗}¨
  i (r<d)◶G‿{
    Dr←((r⊸+)⌜↕d-r)⊸⊏
    t←Dr 0⊑s
    "∾𝕩: 𝕩 element trailing shapes must match" ! 1×´(×´t=¨Dr)⌜s
    ti←t⥊↕tp←×´t⋄(𝕨tp⊸×⊸+⌜ti)G𝕩⊣⌜ti
  } j
}
Join←(2⌊=)◶⟨
  Merge, (1×´(1==)⌜)◶JoinM‿Join1, JoinM
⟩_fillMerge_{
  r←≠𝕨 ⋄ d←≠𝕩
  "∾𝕩: empty 𝕩 fill rank must be at least argument rank" ! d≥r
  (r≤⊣)◶⟨⊑⟜𝕨⊸×,⊢⟩⟜(⊑⟜𝕩)⌜↕d
} ⊣ "∾𝕩: 𝕩 must be an array"!IsArray

Recompose ← ⊣◶⟨
  ⊢                  # 0 primitive
  ⊢                  # 1 block
  {𝕎𝕏}´⊢             # 2-train
  {F‿G‿H←𝕩⋄F G H}    # 3-train
  {F‿m←𝕩⋄F _m}       # 4 1-modifier
  {F‿m‿G←𝕩⋄F _m_ G}  # 5 2-modifier
⟩
structFn ← {
  E←StructErr˙
  _errIf←{⊢⊘×○(1-𝔽)◶⟨StructErr˙,𝕏⟩}
  SE ← IsStructErr _errIf⍟(3≥Type)

  _sfn_ ← {(𝕎⊢)◶⟨𝕏, 𝕩‿𝕗‿𝕘{𝕨𝕏𝕗}⟩}
  Mon←{𝕏⊘E} ⋄ Dy←{E⊘𝕏}
  k‿v ← Split2 ⟨
    "⊢⊣˜∘○⊸⟜⊘◶",  ⊢
    "=≠≢",        Mon 1 _sfn_ 0
    "<",          Mon 0 _sfn_ 1
    "≍",          Mon 1 _sfn_ 1  # Dyad combines
    "↕/»«⊔",      Dy  1 _sfn_ 1
    "⥊↑↓⌽⍉⊏⊑",        1 _sfn_ 1
  # ">",          Mon 2 _sfn_ 1
  # "∾",          Mon 2 _sfn_ 1  # Dyad combines
  # "˘⎉¨⌜",
  # "⚇",
  ⟩
  SP ← (Join1 k)_glyphLookup_((k≠⌜⊸Rep v)∾⟨{
    NS ← 𝕎 _errIf
    (Type-3˙)◶⟨NS, {m←𝕩⋄{NS(𝕗_m)˙0}}, {m←𝕩⋄{NS(𝕗_m_𝕘)˙0}}⟩ 𝕩
  }⟩)
  StructPrim ← {p←SP𝕩⋄𝕨P𝕩}

  0⊸≤◶⟨3,2⊸≤◶⊢‿2⟩∘(0⊑⊢)◶⟨
    SE ⊣ StructPrim 1⊑⊢             #  0 primitive
    StructErr˙˙                     #  1 block
    0⊸⊑ Recompose {𝕨˙⊸StructFn⌜1↓𝕩} #    other operation
    SE 1⊑⊢                          # ¯1 constant
  ⟩⟜{Decompose𝕩}
}

_takeDrop←{
  ⟨gl,Noop,_inds⟩←𝕗
  pre ← "𝕨"∾gl∾"𝕩: 𝕨 must "
  ernk ← "have rank at most 1"
  eint ← "consist of integers"
  {
    ernk ! 1≥=𝕨
    𝕨 ↩ Deshape 𝕨
    eint ! 1×´Int⌜𝕨
    r ← ≠𝕨
    s ← r {(1⌜∘↕𝕨-≠𝕩)∾𝕩}⍟(>⟜≠) ≢𝕩
    _c ← { (×⟜𝕗⌜𝕨) +⌜ 𝕩 }
    i←<0 ⋄ k←1 ⋄ UIk←{ i (k×𝕨)_c↩ k ↕⊸(𝕨_c)⍟(1-=⟜1) 𝕩 ⋄ k↩1 ⋄ ≠𝕩 }
    doFil←0
    sh ← (⊑⟜s Noop◶{k×↩𝕨⋄𝕨}‿(⊣ UIk {𝕩⋄doFil↩1}_inds) ⊑⟜𝕨)⌜ ↕r
    (0<=i)◶(s⊸⥊)‿{
      sh ∾↩ t ← (s⊑˜r⊸+)⌜↕(≠s)-r
      {i 𝕩_c↩ ↕𝕩}⍟(1-1⊸=) k×´t
      Sel ← ⊑⟜(⥊𝕩)
      𝕩{Sel↩0⊸≤◶⟨(Fill𝕨)˙,Sel⟩}⍟⊢doFil
      Sel⌜ sh ⥊ i
    }_fillBy_⊢ ToArray 𝕩
  }
}
Take ← ⟨"↑" ⋄ 1-=⟜| ⋄ { 𝔽⍟(𝕨⊸<)a←|𝕩 ⋄ (0<𝕩)◶⟨¯∞⍟(<⟜0)⌜+⟜(𝕨+𝕩)⌜, ¯∞⍟(𝕨⊸≤)⌜⟩↕a }⟩_takeDrop
Drop ← ⟨"↓" ⋄ 1-0⊸= ⋄ { 𝔽 ⋄ 0⊸<◶⟨↕0⌈+,<∘⊢+⌜·↕0⌈-⟩ }⟩_takeDrop

ShiftCheck←{
  "« or »: 𝕩 must have rank at least 1" ! 1≤=𝕩
  d←𝕩-○=𝕨
  "« or »: 𝕨 must not have higher rank than 𝕩" ! 0≤d
  "« or »: Rank of 𝕨 must be at least rank of 𝕩 minus 1" ! 1≥d
  s←1 Cell 𝕩
  "« or »: 𝕨 must share 𝕩's major cell shape" ! 1×´(⊑⟜s=+⟜(1-d)⊑(≢𝕨)˙)⌜↕≠s
  1×´s
}
ShiftBefore←{
  c←𝕨 ShiftCheck 𝕩
  n←c×(𝕩≤○=⊢)◶1‿≠𝕨
  (≢𝕩)⥊n⊸≤◶⟨⊑⟜(Deshape𝕨),-⟜n⊑(⥊𝕩)˙⟩⌜↕c×≠𝕩
}
ShiftAfter←{
  c←𝕨 ShiftCheck 𝕩
  l←c×≠𝕩
  n←c×(𝕩≤○=⊢)◶1‿≠𝕨
  m←l-n
  (≢𝕩)⥊m⊸≤◶⟨+⟜n⊑(⥊𝕩)˙,-⟜m⊑(Deshape𝕨)˙⟩⌜↕l
}
FC←{ # Fill cell
  "« or »: 𝕩 must have rank at least 1" ! 1≤=𝕩
  (Fill 𝕩)⌜ ⥊⟜(↕1×´⊢) 1 Cell 𝕩
}

Range←{
  I←{"↕𝕩: 𝕩 must consist of natural numbers"!Nat𝕩⋄↕𝕩}
  M←{"↕𝕩: 𝕩 must be a number or list"!1==𝕩⋄(0⌜𝕩)Fill(<⟨⟩)Pair⊸∾⌜´I⌜𝕩}
  IsArray◶I‿M 𝕩
}
Windows←{
  "𝕨↕𝕩: 𝕨 must have rank at most 1" ! 1≥=𝕨
  r←≠𝕨↩Deshape 𝕨
  𝕨{
    "𝕨↕𝕩: Length of 𝕨 must be at most rank of 𝕩" ! r≤=𝕩
    "𝕨↕𝕩: 𝕨 must consist of natural numbers" ! ×´Nat⌜𝕨
    s←≢𝕩
    l←(1+⊑⟜s-⊑⟜𝕨)⌜↕r
    "𝕨↕𝕩: Window length 𝕨 must be at most axis length plus one" ! ×´0⊸≤⌜l
    k←1×´t←(r⊸+⌜↕s≠⊸-r)⊏s
    str ← Reverse ×`⟨k⟩∾{(s⊑˜𝕩⊸-)⌜↕𝕩}r-1
    ⊑⟜(⥊𝕩)⌜ k +⌜⟜(t⥊↕)˜⍟(1-=⟜1) l +⌜○(+⌜´str{𝕨⊸×⌜↕𝕩}¨⊢) 𝕨
  }_fillBy_⊢⍟(0<r)𝕩
}

˘ ← {𝕨 𝔽 _rankOp_ ¯1 𝕩}
_onAxes_←{
  F←𝔽
  (𝔾<≡)∘⊣◶{ # One axis
    "First-axis primitive: 𝕩 must have rank at least 1" ! 1≤=𝕩
    𝕨F𝕩
  }‿{ # Multiple axes
    "Multi-axis primitive: 𝕨 must have rank at most 1" ! 1≥=𝕨
    "Multi-axis primitive: Length of 𝕨 must be at most rank of 𝕩" ! 𝕨≤○≠≢𝕩
    l←≠𝕨 ⋄ W←⊑⟜(⥊𝕨)
    0{(W𝕨)F(1+𝕨)⊸𝕊˘⍟(𝕨<l-1)𝕩}⍟(0<l)𝕩
  }⟜ToArray
}

Replicate ← (0<=∘⊣)◶{
  𝕨↩(0⊑⥊)⍟IsArray𝕨
  "/: Amounts to replicate must be natural numbers" ! Nat 𝕨
  e←r←𝕨
  ({e+↩r⋄1+𝕩}⍟{e=𝕨}˜`↕r×≠𝕩) ⊏ 𝕩
}‿{
  "𝕨/𝕩: Lengths of components of 𝕨 must match 𝕩" ! 𝕨=○≠𝕩
  𝕨 Rep 𝕩
} _onAxes_ (1-0=≠) _fillBy_ ⊢

PermInv ← 1¨⊸GroupOrd
_self←{
  "∊𝕩 or ⊐𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  g←⍋𝕩
  0 Fill (PermInv g) ⊏ g 𝔽 0⊸<◶⟨1,-⟜1≢○(⊑⟜(g⊏<˘⍟(1<=)𝕩))⊢⟩⌜↕≠𝕩
}
SelfClas ← (PermInv∘⍋∘(Indices⊸⊏)˜⊏˜¯1+`⊢) _self

ReshapeT ← "∘⌊⌽↑"_glyphLookup_(↕5)
Reshape←{
  "𝕨⥊𝕩: 𝕨 must have rank at most 1" ! 1≥=𝕨
  s←Deshape 𝕨
  sp←0+´p←(1-Nat)⌜s
  "𝕨⥊𝕩: 𝕨 must consist of natural numbers" ! 1≥sp
  n←≠d←Deshape 𝕩
  l←sp◶(1×´⊢)‿{
    lp←1×´p⊣◶⊢‿1¨𝕩
    "𝕨⥊𝕩: Can't compute axis length when rest of shape is empty" ! 0<lp
    i←0+´⊑⟜p⊸×⌜↕≠p
    t←ReshapeT i⊑s
    "𝕨⥊𝕩: 𝕨 must consist of natural numbers or ∘ ⌊ ⌽ ↑" ! t<4
    Chk ← ⊢ ⊣ "𝕨⥊𝕩: Shape must be exact when reshaping with ∘" ! ⌊⊸=
    a←(2⌊t)◶⟨Chk,⌊,⌈⟩n÷lp
    s↩p⊣◶⊢‿a¨s
    {d∾↩(Fill d)⌜↕𝕩-n⋄n}⍟(n⊸<)⍟(3=t)lp×a
  } s
  s⥊{
    𝕩(0<n)◶⟨<∘Fill⊸(⊣⌜)⋄{i←¯1⋄m←n-1⋄{𝕩⋄(i+↩1-n×i=m)⊑d}⌜𝕩}⟩↕l
  }_fillBy_⊢⍟(1-l=n)d
}
⥊ ↩ Deshape        ⊘ ⥊

_group←{
  "⊔: Grouping argument must consist of integers" ! 1×´Int⌜𝕩
  "⊔: Grouping argument values cannot be less than ¯1" ! 1×´¯1⊸≤⌜𝕩
  GL←GroupLen⋄𝕩↩𝕨(-˜⟜≠{GL↩(𝕨⊑𝕩)GL⊢⋄𝕨↑𝕩}⊢)⍟(0⊘⊣)𝕩
  d←(l←GL𝕩)GroupOrd𝕩
  i←0⋄(𝔽{𝕩⋄(i↩i+1)⊢i⊑d}⌜∘↕)⌜l
}
GroupInds←{
  "⊔𝕩: 𝕩 must be a list" ! 1==𝕩
  G←⊢_group
  (1<≡)◶⟨
    ↕∘0             Fill G
    ((⊢Fill⥊⟜⟨⟩)0⌜) Fill (<<⟨⟩) ∾⌜⌜´ {⊏⟜(⥊Range≢𝕩)⌜ G⥊𝕩}⌜
  ⟩ 𝕩
}
Group1←ToArray⊸{
  n←=𝕨
  "𝕨⊔𝕩: Rank of simple 𝕨 must be at most rank of 𝕩" ! n≤=𝕩
  ld←(≢𝕨)-¨n↑s←≢𝕩
  dr←(1=n)◶⟨0,1=0⊸⊑⟩ld
  "𝕨⊔𝕩: Lengths of 𝕨 must equal to 𝕩, or one more only in a rank-1 component" ! dr◶⟨1×´0⊸=⌜,1⟩ld
  SX←((n==𝕩)◶{c←1×´t←n↓s⋄(𝕩⊑˜c⊸×⊸+)⌜⟜(t⥊↕c)}‿{⊑⟜𝕩⌜} ⥊𝕩)∘⊣ _fillBy_ ⊢⟜𝕩
  (SX⟨⟩) Fill dr SX _group ⥊𝕨
}
GroupGen←{
  "𝕨⊔𝕩: 𝕩 must be an array" ! IsArray 𝕩
  𝕨(2≤≡𝕨)◶Group1‿GroupM𝕩
}

÷ ↩ ÷ _perv
⋆ ↩ ⋆ _perv
√ ← ⋆⟜(÷2)   ⊘ (⋆⟜÷˜)
| ← (|       ⊘ {𝕩-𝕨×⌊𝕩÷𝕨}) _perv
⌊ ↩ (⌊       ⊘ {(𝕨>𝕩)⊑𝕨‿𝕩}) _perv
⌈ ↩ (-∘⌊∘-   ⊘ {(𝕨<𝕩)⊑𝕨‿𝕩}) _perv
∧ ← ⍋⊸⊏      ⊘ (× _perv)
∨ ← ⍒⊸⊏      ⊘ ((+-×) _perv)
× ↩ (0⊸(<->) ⊘ ×) _perv
< ↩ Box      ⊘ ((1-≥) _perv)
> ↩ Merge    ⊘ ((1-≤) _perv)
≠ ↩ ≠        ⊘ ((1-=) _perv)
= ↩ =        ⊘ (= _perv)
≥ ← ("≥: No monadic form"!0˙) ⊘ (≥ _perv)
≤ ↩ ("≤: No monadic form"!0˙) ⊘ (≤ _perv)
+ ↩ + _perv
- ↩ - _perv
¬ ← 1+-
HomFil ← {((𝕎0) Fill 𝕏)⊘𝕏}⍟(+´⟨=,≠,≡,≢⟩=⊣)

ValidateRanks←{
  "⎉ or ⚇: 𝔽 result must have rank at most 1" ! 1≥=𝕩
  𝕩↩⥊𝕩
  "⎉ or ⚇: 𝔽 result must have 1 to 3 elements" ! (1⊸≤∧≤⟜3)≠𝕩
  "⎉ or ⚇: 𝔽 result must consist of integers" ! 1∧´Int⌜𝕩
  𝕩
}
_ranks ← {⟨2⟩⊘⟨1,0⟩ ((⊣-1+|)˜⟜≠⊑¨<∘⊢) ValidateRanks∘𝔽}
_depthOp_←{
  neg←0>n←𝕨𝔾_ranks𝕩 ⋄ F←𝔽
  _d←{
    R←(𝕗+neg)_d
    𝕨(×⟜2⊸+´2 Reshape (neg∧𝕗≥0)∨(0⌈𝕗)≥Pair○≡)◶⟨R¨⋄R⟜𝕩⌜∘⊣⋄(𝕨R⊢)⌜∘⊢⋄F⟩𝕩
  }
  𝕨 n _d 𝕩
}
_rankOp_←{
  k←𝕨(Pair○= (0≤⊢)◶⟨⌊⟜-,0⌈-⟩¨ 𝔾_ranks)𝕩
  Enc←{
    f←(↕𝕨)⊏≢𝕩
    c←1×´s←𝕨Cell𝕩⋄i←s⥊↕c
    (f⥊((⥊𝕩)⊏˜i+c×⊢)⌜↕1×´f)˙_fillBy_{(<𝕩)⌜i} 𝕩
  }
  Enc↩(>⟜0×1+≥⟜=)◶⟨<⊢,Enc,<⌜⊢⟩
  > ((0⊑k)Enc𝕨) 𝔽¨ ((1-˜≠)⊸⊑k)Enc𝕩
}
_insert←{
  "˝: 𝕩 must have rank at least 1" ! 1≤=𝕩
  F←𝔽
  Id ← {
    s ← 1↓≢𝕩
    JoinSh ← {"˝: Identity does not exist"!0<≠𝕨 ⋄ 𝕨×0<↕≠𝕨}
    s ¬∘IsJoin∘⊢◶⟨JoinSh⥊𝕩˙, Reshape⟜Identity⟩ f
  }
  𝕨 (0<≠)⊘1◶Id‿{𝕨F´<˘𝕩} 𝕩
}

JoinTo←∨○(1<=)◶(∾○⥊)‿{
  s←𝕨Pair○≢𝕩
  a←1⌈´k←≠⌜s
  "𝕨∾𝕩: Rank of 𝕨 and 𝕩 must differ by at most 1" ! 1∧´1≥a-k
  c←(k¬a)+⟜(↕a-1)⊸⊏¨s
  "𝕨∾𝕩: Cell shapes of 𝕨 and 𝕩 must match" ! MatchS´c
  l←0+´(a=k)⊣◶1‿(0⊑⊢)¨s
  (⟨l⟩∾0⊑c)⥊𝕨∾○⥊𝕩
} _fillBy_ IF

_repeat_←{
  F←𝔽 ⋄ b←𝕨{𝕏⊣}˙⊘{𝕨˙{𝔽𝕏⊣}}0
  n←𝕨𝔾𝕩
  Multi←{
    l←u←0
    {"⍟: Repetition numbers in 𝕨𝔾𝕩 must be integers"!Int𝕩⋄l↩l⌊𝕩⋄u↩u⌈𝕩}_perv n
    i←⟨𝕩⟩⋄P←B⊸{𝕎`i∾↕𝕩}
    pos←f P u
    neg←f 0⊸<◶⟨i,Inverse⊸P⟩ -l
    (|⊑<⟜0⊑pos‿neg˙)_perv n
  }
  (Nat n)◶Multi‿{𝕩(B f)∘⊢´↕n} 𝕩
}

↕ ↩ Range          ⊘ Windows
⌽ ← Reverse        ⊘ (Rot _onAxes_ 0)
/ ← Indices        ⊘ Replicate
» ← FC⊸ShiftBefore ⊘ ShiftBefore _fillBy_ (⊢⊘IF)
« ← FC⊸ShiftAfter  ⊘ ShiftAfter  _fillBy_ (⊢⊘IF)

GroupM←{
  "𝕨⊔𝕩: Compound 𝕨 must be a list" ! 1==𝕨
  n←0+´r←=⌜𝕨
  "𝕨⊔𝕩: Total rank of 𝕨 must be at most rank of 𝕩" ! n≤=𝕩
  ld←(Join≢⌜𝕨)-n↑≢𝕩
  "𝕨⊔𝕩: Lengths of 𝕨 must equal to 𝕩, or one more only in a rank-1 component" ! 1∧´(0⊸≤∧≤⟜(r/1=r))ld
  dr←r⌊(0»+`r)⊏ld∾⟨0⟩
  l←dr-˜≠⌜𝕨↩⥊⌜𝕨 ⋄ LS←∾⟜(n Cell 𝕩) Reshape 𝕩˙
  S←⊏⟜(LS⟨1×´l⟩)
  (LS 0⌜𝕨) Fill dr (1≠≠∘⊢)◶⟨S _group○(0⊸⊑), S⌜ ·+⌜⌜´ (⌽×`1»⌽l) × ⊢_group¨⟩ 𝕨
}

↑ ↩ Prefixes       ⊘ Take
↓ ↩ Suffixes       ⊘ Drop
⊔ ← GroupInds      ⊘ GroupGen
⊐ ← SelfClas       ⊘ (1 _search)
∊ ← ⊢_self         ⊘ (0 _search˜)
⎉ ← _rankOp_

Find←{
  r←=𝕨
  "⍷𝕩: Rank of 𝕨 cannot exceed rank of 𝕩" ! r≤=𝕩
  0 Fill 𝕨 ≡⎉r ((1+r-⊸↑≢𝕩)⌊≢𝕨)⊸↕⎉r 𝕩
}○ToArray

OccurrenceCount ← 0 Fill ⊐˜(⊢-⊏)⍋∘⍋
ProgressiveIndexOf ← 0 Fill {
  c←1-˜=𝕨
  "⊒: Rank of 𝕨 must be at least 1" ! 0≤c
  "⊒: Rank of 𝕩 must be at least cell rank of 𝕨" ! c≤=𝕩
  𝕨⊐○(Pair¨⟜(≢⥊OccurrenceCount∘⥊) 𝕨⊸⊐)𝕩
}

ReorderChk←{
  "𝕨⍉𝕩: 𝕨 must have rank at most 1" ! 1≥=𝕨
  "𝕨⍉𝕩: Length of 𝕨 must not exceed rank of 𝕩" ! 𝕨≤○≠≢𝕩
  "𝕨⍉𝕩: 𝕨 must consist of natural numbers" ! 1∧´Nat⌜⥊𝕨
}
ReorderAxesSub←{
  (𝕨⊸⊏Pick𝕩˙)⌜↕⌊´⌜𝕨⊔≢𝕩
} _fillBy_ ⊢
ReorderAxes←{
  𝕨 ReorderChk 𝕩
  𝕨↩⥊𝕨
  r←(=𝕩)-0+´¬∊𝕨
  "𝕨⍉𝕩: Skipped result axis" ! 1∧´𝕨<r
  (𝕨∾𝕨(¬∘∊˜/⊢)↕r) ReorderAxesSub 𝕩
}
ReorderAxesInv←{
  𝕨 ReorderChk 𝕩
  𝕨↩⥊𝕨
  r←=𝕩
  IA 1∧´(∊∧<⟜r)𝕨
  (PermInv 𝕨∾𝕨(¬∘∊˜/⊢)↕r) ReorderAxesSub 𝕩
}

⁼ ← {Inverse 𝕗}
_inv_ ← {𝕘⋄𝕨𝔽𝕩}
_undo ← {𝕗 (≢∧INF˙⊸≢)◶0‿((5=0⊸⊑)◶1‿(inv˙≢(≠-2˙)⊸⊑)∘Decompose⊢)◶⊢‿{𝕏_inv_(𝕎_invChk_𝕏)} Inverse 𝕗}
IsConstant ← (3≤Type)◶⟨1 ⋄ (4=0⊸⊑)◶0‿('˙'_isGlyph(≠-1˙)⊸⊑)∘{Decompose𝕩}⊢⟩
AtopInverse ← {(𝕏𝕎)⊘(𝕏⟜𝕎)}○{Inverse𝕩}
TrainInverse ← {
  t‿f‿g‿h←𝕩
  K←¬IsConstant
  f K∘⊣◶⟨{𝕏⁼{𝕨𝔽𝔾𝕩}(𝕨G⁼⊢)},K∘⊢◶⟨{𝕎⁼𝕩G{SwapInverse𝕗}⊢},INF˙⟩⟩ h
}
FuncInverse ← (0⊸⊑ ⊣◶⟨
  {PrimInverse𝕩} 1⊸⊑                     # 0 primitive
  ("Cannot currently invert blocks"!0˙)˙ # 1 block
  1⊸⊑ AtopInverse 2⊸⊑                    # 2-train
  TrainInverse                           # 3-train
  1⊸⊑    {𝕏𝕨}⟜{Mod1Inverse𝕩} 2⊸⊑         # 4 1-modifier
  1‿3⊸⊏ {𝕏´𝕨}⟜{Mod2Inverse𝕩} 2⊸⊑         # 5 2-modifier
⟩ ⊢) {Decompose𝕩}
Inverse ← Type◶(3‿1‿2/{⊢⊣𝕩IX∘≡⊢}‿FuncInverse‿("Cannot invert modifier"!0˙))

∾ ↩ Join           ⊘ JoinTo
IA ← "⁼: Inverse failed"⊸!
IX ← "⁼: Inverse does not exist"⊸!
INF← "⁼: Inverse not found"!0˙
_invChk_ ← {i←𝕨𝔽𝕩⋄IX 𝕩≡𝕨𝔾i⋄i}
GroupIndsInv ← {
  IA 2=≡𝕩
  IX 1∧´1==⌜𝕩
  j←∾𝕩
  IX 1∧´Nat⌜j
  IX 1∧´j>∾¯1»¨𝕩
  g←GroupLen j
  IX 1∧´g≤1
  o←/¬g
  (⍋j∾o)⊏(/≠¨𝕩)∾¯1¨o
}
GroupInv ← {
  IA 1==𝕨
  IA 1∧´Nat⌜𝕨
  i←⊔𝕨
  IX i≡○(≠¨)𝕩
  i ⍋⊸⊏○∾ 𝕩
}
⊏ ↩ FirstCell      ⊘ (ToArray⊸(SelSub _onAxes_ 1)) _fillBy_ ⊢
PrimInverse ← INF _lookup_ ⟨
  '+', +⊘(-˜)
  '-', -
  '×', ⊢_invChk_×⊘(÷˜)
  '÷', ÷
  '⋆', Log _perv
  '√', ×˜⊘(⋆˜)
  '∧', ⊢_invChk_∧⊘(÷˜)
  '∨', ⊢_invChk_∨⊘(-˜÷1-⊣)
  '¬', ¬
  '<', {IX IsArray𝕩⋄IX 0==𝕩⋄0⊑⥊𝕩}⊘(IA∘0)
  '⊢', ⊢
  '⊣', ⊢⊘(⊢⊣IX∘≡)
  '∾', IA∘0 ⊘ {d←𝕩-○=𝕨⋄IX(0⊸≤∧≤⟜1)d⋄l←d◶1‿≠𝕨⋄IX l≤≠𝕩⋄IX 𝕨≡d◶⟨⊏,l⊸↑⟩𝕩⋄l↓𝕩}
  '≍', {IX 1=≠𝕩⋄⊏𝕩} ⊘ {IX 2=≠𝕩⋄IX 𝕨≡⊏𝕩⋄1⊏𝕩}
  '↑', ¯1⊸⊑_invChk_↑ ⊘ (IA∘0)
  '↓',  0⊸⊑_invChk_↓ ⊘ (IA∘0)
  '↕', ≢_invChk_↕ ⊘ (IA∘0)  # Should trace edge and invChk
  '⌽', ⌽ ⊘ (-⊸⌽)
  '⍉', TransposeInv ⊘ ReorderAxesInv
  '/', {IA 1==𝕩⋄IA 1∧´Nat⌜𝕩⋄IX(1∧´¯1⊸↓≤1⊸↓)𝕩⋄GroupLen𝕩}⊘(IA∘0)
  '⊔', GroupIndsInv ⊘ GroupInv
⟩
SwapInverse ← INF _lookup_ ⟨
  '+', ÷⟜2⊘(-˜)
  '-', IA∘0⊘+
  '×', √⊘(÷˜)
  '÷', IA∘0⊘×
  '⋆', IA∘0⊘√
  '√', IA∘0⊘(÷Log)
  '∧', √⊘(÷˜)
  '∨', (¬√∘¬)⊘(-˜÷1-⊣)
  '¬', IA∘0⊘(+-1˙)
⟩
⌜ ↩ {𝕨𝔽⌜_fillByPure_𝔽○ToArray𝕩}
Mod1Inverse ← INF˙ _lookup_ ⟨
  '˜', SwapInverse
  '¨', {𝕏⁼¨                     ⊣·IX 0<≡∘⊢}
  '⌜', {𝕏⁼⌜⊘(IA∘0)              ⊣·IX 0<≡∘⊢}
  '˘', {(IX∘IsArray⊸⊢𝕏⁼)˘       ⊣·IX 0<=∘⊢}
  '`', {(⊏∾¯1⊸↓𝕏1⊸↓)⍟(1<≠)⊘(»𝕏⊢)⊣·IX 0<=∘⊢}∘{𝕏⁼¨}
⟩
⍟ ↩ _repeat_
⌾ ← _under_
Mod2Inverse ← INF˙ _lookup_ ⟨
  '∘', AtopInverse
  '○', {Fi←𝕎⁼⋄𝕏⁼ Fi⊘(𝕏⊸Fi)}
  '⌾', {𝕎⁼⌾𝕏}  # Need to verify for computation Under
  '⍟', Int∘⊢◶⟨IA∘0˙,0⊸≤◶{𝕎⍟(-𝕩)_invChk_(𝕎⍟𝕩)}‿{𝕎⍟(-𝕩)}⟩
  '⊘', {(𝕎⁼)⊘(𝕏⁼)}
  '⊸', IsConstant∘⊣ ⊣◶{INF⊘𝕏}‿⊢ {𝕎⊸(𝕏⁼)}
  '⟜', {(𝕨IsConstant∘⊢◶⟨IA∘0˙,{𝕩𝕎{SwapInverse𝕗}⊢}⟩𝕩)⊘(𝕏⁼𝕎⁼)}
⟩ { inv˙⊸=◶⟨𝔽,{𝕏_inv_𝕎}˙⟩ }

˝ ← _insert
⁼ ↩ _undo
⊑ ↩ First          ⊘ Pick
◶ ↩ {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}  # Same definition, new Pick
⚇ ← _depthOp_
⥊ ↩ Deshape        ⊘ Reshape
≍ ← >∘Pair _fillBy_ (⊢⊘IF)
⍉ ← Transpose      ⊘ ReorderAxes
⊒ ← OccurrenceCount⊘ ProgressiveIndexOf
⍷ ← ∊⊸/            ⊘ Find
