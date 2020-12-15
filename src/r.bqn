# BQN runtime. Requires:
# Type Decompose Glyph GetFill Log GroupLen GroupOrd  !+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘
Decompose
Glyph

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
Deshape←IsArray◶{⟨𝕩⟩}‿⥊
Pair ← {⟨𝕩⟩} ⊘ {⟨𝕨,𝕩⟩}
Box ← {⟨⟩⥊⟨𝕩⟩}
ToArray ← Box⍟(1-IsArray)

# LIMITED to numeric arguments for arithmetic cases
≥ ←            ≤˜
< ← Box      ⊘ (1-≥)
> ←            (1-≤)
⌊ ↩ ⌊        ⊘ (>⊑{𝕨‿𝕩})
⌈ ← -∘⌊∘-    ⊘ (<⊑{𝕨‿𝕩})
| ← 0⊸≤◶-‿⊢
≠ ← (0<=)◶⟨1⋄0⊑≢⟩  # LIMITED to monadic case

_fold←{
  "´: 𝕩 must be a list" ! 1==𝕩
  l←≠v←𝕩 ⋄ F←𝔽
  r←𝕨 (0<l)◶{𝕩⋄Identity f}‿{l↩l-1⋄l⊑𝕩}⊘⊣ 𝕩
  {r↩(𝕩⊑v)F r}⌜(l-1)⊸-⌜↕l
  r
}
´ ← _fold

Cell←{(𝕨⊸+⊑𝕩˙)⌜↕(≠𝕩)-𝕨}⟜≢

∾ ← {k←≠𝕨⋄k⊸≤◶⟨⊑⟜𝕨⋄-⟜k⊑𝕩˜⟩⌜↕k+≠𝕩}  # LIMITED to two vector arguments

GetCells←(1==∘⊢)◶{
  c←1×´s←1 Cell 𝕩
  𝕨((⥊𝕩)⊑˜c⊸×⊸+)⌜s⥊↕c
}‿{
  ⊑⟜𝕩⌜𝕨
}
⊏ ← GetCells  # LIMITED to depth-1 natural number left argument

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
  +○IsArray◶⟨𝔽⋄R⌜⊘(>○IsArray◶{𝕨{𝕗R𝕩}⌜𝕩}‿{𝕩{𝕩R𝕗}⌜𝕨})⋄R _eachd⟩
}

Cmp0 ← ≥-≤
Cmp1 ← (0<1×´≢∘⊢)◶⟨1, IsArray∘⊢◶(1-2×≤)‿{𝕨Cmp1𝕩}⟜(0⊑⥊)⟩
Cmp ← +○IsArray◶⟨
  Cmp0
  IsArray∘⊣◶⟨Cmp1,-Cmp1˜⟩
  {
    lc←𝕨CmpLen○≢𝕩
    cc ← (⊑⟜(⥊𝕨))⊸Cmp⟜(⊑⟜(⥊𝕩)) _getCellCmp´ lc
    Cc˜0
  }
⟩
_grade_←{
  "⍋𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  l←≠𝕩
  m←1×´1 Cell 𝕩
  d←⥊𝕩
  # Counting sort for small-range ints
  bl←bu←0⋄r←1-{((bu↩⌈´𝕩)-bl↩⌊´𝕩)≤2×l}⟜𝕩⍟⊢((m=1)×32<l)◶0‿(1×´Int⌜)d
  r◶⟨GroupLen⊸GroupOrd (𝕘⊑⟨-⟜bl,bu⊸-⟩)⌜ ⋄ 𝔽{𝕩⋄
    # Merge sort
    GT←(m 𝔽○(⊑⟜d) _getCellCmp 0)>0˜
    B←l⊸≤◶⊢‿l
    (↕l){
      i←-d←𝕨 ⋄ j←ei←ej←0
      e←3 ⋄ G←GT○(⊑⟜(m⊸×⌜⍟(1-m=1)𝕩)) ⋄ c←⟨G,0,1,2⟩
      s←(8≤d)⊑⟨+,{(𝕩-1){𝕩⋄e↩2⋄j↩i⋄i↩𝕩}⍟(1-G)⍟(1-e)𝕩}⟩
      N←{i↩d+𝕨⋄ej↩B d+ei↩B j↩d+𝕩⋄e↩l≤j⋄S ei⋄i R j}
      R←{𝕨e◶c𝕩}◶{e+↩2×ei=i↩1+𝕨⋄𝕨}‿{e+↩ej=j↩1+𝕩⋄𝕩}‿N
      {(i R j)⊑𝕩}⟜𝕩⌜𝕩
    }´(2⋆ni-1+⊢)⌜↕ni←⌈2 Log l+l=0
  }⟩𝕩
}

Indices←{
  "/: Replication argument must have rank 1" ! 1==𝕩
  l←≠𝕩
  {
    "/: Amounts to replicate must be natural numbers" ! 1×´Nat⌜𝕩
    k←l-1
    N ← ((⊢+-×0=𝕩⊑˜⊢)`k⊸-⌜↕l)⊑˜k-⊢  # Next nonzero
    E ← ⊑⟜(+`𝕩)
    ei←E i←N 0
    {{ei↩E i↩N𝕩+1⋄i}⍟(𝕩=ei)i}⌜↕E k
  }⍟(0<l)𝕩
}

Transpose←{
  l←≠𝕩 ⋄ m←1×´c←1 Cell 𝕩
  (c⥊↕m)(+⟜(m⊸×)⊑(⥊𝕩)˙)⌜↕l
}⍟(0<=)
TransposeInv←{
  r←1-˜=𝕩 ⋄ s←≢𝕩 ⋄ l←r⊑s ⋄ c←⊑⟜s⌜↕r
  (↕l)(+⟜(l⊸×)⊑(⥊𝕩)˙)⌜c⥊↕1×´c
}⍟(0<=)

Reverse←{
  "⌽𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  l←≠𝕩
  ((l-1)⊸-⌜↕l) ⊏ 𝕩
}
Rot←{
  "𝕨⌽𝕩: 𝕨 must consist of integers" ! Int𝕨
  l←≠𝕩 ⋄ 𝕨-↩l×⌊𝕨÷l ⋄ ((𝕨+⊢-l×(l-𝕨)≤⊢)⌜↕l) ⊏ 𝕩
}

Prefixes←{
  "↑𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  ↕⊸⊏⟜𝕩⌜↕1+≠𝕩
}
Suffixes←{
  "↓𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  l←≠𝕩
  {𝕩⊸+⌜↕l-𝕩}⊸⊏⟜𝕩⌜↕1+l
}

_sort ← {(𝕗⊑⟨Cmp,Cmp˜⟩)_grade_𝕗 ⊸ ⊏}

FirstCell←{
  "⊏𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  (<0) GetCells 𝕩
}
SelSub←{
  "𝕨⊏𝕩: 𝕩 must be an array" ! IsArray 𝕨
  "𝕨⊏𝕩: Indices in 𝕨 must be integers" ! 1×´⥊Int⌜ 𝕨
  l←≠𝕩
  "𝕨⊏𝕩: Indices out of range" ! 1×´⥊ ((-l)⊸≤×l⊸>)⌜ 𝕨
  𝕨 (⊢+l×0>⊢)⌜⊸⊏ 𝕩
}

_under_←{
  i←↕l←1×´s←≢𝕩
  v←𝕨𝔽○𝔾𝕩 ⋄ gi←𝔾s⥊i
  n←(IsArray gi)⊑{⟨𝕩⟩}‿⥊ ⋄ v↩N v ⋄ gi↩N gi
  g←Cmp0 _grade_ 0 gi
  P←(≠g)⊸≤◶⟨(⊑⟜g)⊑gi˜,l⟩
  e←P j←0
  s⥊{e=𝕩}◶⟨⊑⟜(⥊𝕩),{𝕩⋄r←(j⊑g)⊑v⋄e↩P j↩1+j⋄r}⟩⌜i
}

¨ ↩ {𝕨(𝔽⌜)⊘(𝔽_eachd)○ToArray𝕩}

match←{(0⊑𝕨)◶(1⊑𝕨)‿𝕩}´⟨
  ⟨=○IsArray, 0⟩
  ⟨IsArray∘⊢, =⟩
  ⟨=○=      , 0⟩
  ⟨1×´=¨○≢  , 0⟩
  {1×´⥊𝕨Match¨𝕩}
⟩
Depth←IsArray◶0‿{1+0(⊣-≤×-)´Depth⌜⥊𝕩}

≡ ← Depth          ⊘ Match
≢ ↩ IsArray◶⟨⟩‿≢   ⊘ (1-Match)

Merge←{
  c←≢0⊑⥊𝕩
  ">𝕩: Elements of 𝕩 must have matching shapes" ! 1×´(c≡≢)⌜⥊𝕩
  𝕩⊑⟜Deshape˜⌜c⥊↕1×´c
}⍟(0<≠∘⥊)⍟IsArray

Join←(1==)◶⟨1,1-1×´(1==)⌜⟩◶{
  # List of lists
  i←j←¯1 ⋄ e←⟨⟩ ⋄ a←𝕩
  {{e↩a⊑˜i↩𝕩⋄j↩¯1}⍟(1-i⊸=)𝕩⋄(j↩j+1)⊑e}⌜Indices≠⌜𝕩
}‿{
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
}⍟{"∾𝕩: 𝕩 must be an array" ! IsArray 𝕩 ⋄ 0<≠⥊𝕩}

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
    fill←0
    sh ← (⊑⟜s Noop◶{k×↩𝕨⋄𝕨}‿(⊣ UIk {fill↩1}_inds) ⊑⟜𝕨)⌜ ↕r
    (0<=i)◶(s⊸⥊)‿{
      sh ∾↩ t ← (s⊑˜r⊸+)⌜↕(≠s)-r
      {i 𝕩_c↩ ↕𝕩}⍟(1-1⊸=) k×´t
      Sel ← ⊑⟜(⥊𝕩)
      {Sel↩0⊸≤◶⟨(GetFill𝕩)˙,Sel⟩}⍟⊢fill
      Sel⌜ sh ⥊ i
    } ToArray 𝕩
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
  (GetFill 𝕩)⌜ ⥊⟜(↕1×´⊢) 1 Cell 𝕩
}

Windows←{
  "𝕨↕𝕩: 𝕩 must be an array" ! IsArray 𝕩
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
  }⍟(0<r)𝕩
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
  }
}

÷ ↩ ÷ _perv
⋆ ↩ ⋆ _perv
√ ← ⋆⟜(÷2)   ⊘ (⋆⟜÷˜)
| ← (|       ⊘ {𝕩-𝕨×⌊𝕩÷𝕨}) _perv
⌊ ↩ (⌊       ⊘ {(𝕨>𝕩)⊑𝕨‿𝕩}) _perv
⌈ ↩ (-∘⌊∘-   ⊘ {(𝕨<𝕩)⊑𝕨‿𝕩}) _perv
∧ ← 0 _sort  ⊘ (× _perv)
∨ ← 1 _sort  ⊘ ((+-×) _perv)
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
identity ← (0⊑⟨"´: Identity not found"!0˜⟩) {(0⊑𝕨){𝕗=𝕩}◶𝕩‿(1⊑𝕨)}´ ⟨+‿0,-‿0,×‿1,÷‿1,⋆‿1,√‿1,∧‿1,∨‿0,¬‿1,|‿0,⌊‿∞,⌈‿¯∞,<‿0,≤‿1,=‿1,≥‿1,>‿0,≠‿0⟩

Reshape←{
  "𝕨⥊𝕩: 𝕨 must have rank at most 1" ! 1≥=𝕨
  s←Deshape 𝕨
  sp←+´p←¬Nat⌜s
  "𝕨⥊𝕩: 𝕨 must consist of natural numbers" ! 1≥sp
  n←≠d←Deshape 𝕩
  l←sp◶(×´)‿{
    lp←×´p⊣◶⊢‿1¨𝕩
    "𝕨⥊𝕩: Can't compute axis length when rest of shape is empty" ! 0<lp
    i←+´p×↕≠p
    t←ReshapeT i⊑s
    "𝕨⥊𝕩: 𝕨 must consist of natural numbers or ∘ ⌊ ⌽ ↑" ! t<4
    Chk ← ⊢ ⊣ "𝕨⥊𝕩: Shape must be exact when reshaping with ∘" ! ⌊⊸=
    a←(2⌊t)◶⟨Chk,⌊,⌈⟩n÷lp
    s↩p⊣◶⊢‿a¨s
    {d∾↩(GetFill d)⌜↕𝕩-n⋄n}⍟(n⊸<)⍟(3=t)lp×a
  } s
  s⥊{
    𝕩(0<n)◶⟨GetFill⊸(⊣⌜)⋄{⊑⟜d⌜n|𝕩}⟩↕l
  }⍟(l≠n)d
}
⥊ ↩ Deshape        ⊘ ⥊

Range←{
  I←{"↕𝕩: 𝕩 must consist of natural numbers"!Nat𝕩⋄↕𝕩}
  M←{"↕𝕩: 𝕩 must be a number or list"!1==𝕩⋄(<⟨⟩)⥊⊸∾⌜´I⌜𝕩}
  IsArray◶I‿M 𝕩
}

_ranks ← {⟨2⟩⊘⟨1,0⟩((⊣-1+|)˜⟜≠⊑¨<∘⊢)⥊∘𝔽}
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
    c←×´s←𝕨Cell𝕩
    f⥊⊑⟜(⥊𝕩)⌜∘((s⥊↕c)+c×⊢)⌜↕×´f
  }
  Enc↩(>⟜0×1+≥⟜=)◶⟨<⊢,Enc,<⌜⊢⟩
  > ((0⊑k)Enc𝕨) 𝔽¨ ((1-˜≠)⊸⊑k)Enc𝕩
}
_insert←{
  "˝: 𝕩 must have rank at least 1" ! 1≤=𝕩
  𝕨 𝔽´ <˘𝕩
}
˝ ← _insert


JoinTo←∨○(1<=)◶(∾○⥊)‿{
  s←𝕨Pair○≢𝕩
  a←1⌈´k←≠⌜s
  "𝕨∾𝕩: Rank of 𝕨 and 𝕩 must differ by at most 1" ! ∧´1≥a-k
  c←(k¬a)+⟜(↕a-1)⊸⊏¨s
  "𝕨∾𝕩: Cell shapes of 𝕨 and 𝕩 must match" ! ≡´c
  l←+´(a=k)⊣◶1‿(0⊑⊢)¨s
  (⟨l⟩∾0⊑c)⥊𝕨∾○⥊𝕩
}

Rep ← Indices⊸⊏
Replicate ← IsArray∘⊣◶{
  "/: Amounts to replicate must be natural numbers" ! Nat 𝕨
  e←r←𝕨
  ({e+↩r⋄1+𝕩}⍟{e=𝕨}˜`↕r×≠𝕩) ⊏ 𝕩
}‿{
  "𝕨/𝕩: Lengths of components of 𝕨 must match 𝕩" ! 𝕨=○≠𝕩
  𝕨 Rep 𝕩
} _onAxes_ (1-0=≠)

↑ ← Prefixes       ⊘ Take
↓ ← Suffixes       ⊘ Drop
↕ ↩ Range          ⊘ Windows
⌽ ← Reverse        ⊘ (Rot _onAxes_ 0)
/ ← Indices        ⊘ Replicate
» ← FC⊸ShiftBefore ⊘ ShiftBefore
« ← FC⊸ShiftAfter  ⊘ ShiftAfter

_group←{
  "⊔: Grouping argument must consist of integers" ! ∧´Int⌜𝕩
  "⊔: Grouping argument values cannot be less than ¯1" ! ∧´¯1≤𝕩
  d←(l←GroupLen𝕩)GroupOrd𝕩
  i←0⋄(𝔽{𝕩⋄(i↩i+1)⊢i⊑d}⌜∘↕)⌜l
}
GroupInds←{
  "⊔𝕩: 𝕩 must be a list" ! 1==𝕩
  G←⊢_group
  (1<≡)◶⟨G , (<<⟨⟩) ∾⌜⌜´ {⊏⟜(⥊↕≢𝕩)⌜ G⥊𝕩}⌜⟩ 𝕩
}
GroupGen←{
  "𝕨⊔𝕩: 𝕩 must be an array" ! IsArray 𝕩
  𝕨↩Pair∘ToArray⍟(2>≡)𝕨
  "𝕨⊔𝕩: Compound 𝕨 must be a list" ! 1==𝕨
  n←+´=⌜𝕨
  "𝕨⊔𝕩: Total rank of 𝕨 must be at most rank of 𝕩" ! n≤=𝕩
  "𝕨⊔𝕩: Lengths of components of 𝕨 must be compatible with 𝕩" ! ∧´(Join≢⌜𝕨)=n↑≢𝕩
  l←≠⌜𝕨↩⥊⌜𝕨
  S←⊏⟜(𝕩⥊˜⟨×´l⟩∾n Cell 𝕩)
  (1≠≠)◶(S _group 0⊸⊑)‿(S⌜ ·+⌜⌜´ (⌽×`1»⌽l) × ⊢_group⌜) 𝕨
}

Pick1←{
  "𝕨⊑𝕩: Indices in compound 𝕨 must be lists" ! 1==𝕨
  "𝕨⊑𝕩: Index length in 𝕨 must match rank of 𝕩" ! 𝕨=○≠s←≢𝕩
  "𝕨⊑𝕩: Indices in 𝕨 must consist of integers" ! ∧´Int⌜𝕨
  "𝕨⊑𝕩: Index out of range" ! ∧´𝕨(≥⟜-∧<)s
  𝕨↩𝕨+s×𝕨<0
  (⥊𝕩)⊑˜0(⊑⟜𝕨+⊑⟜s×⊢)´-↕⊸¬≠𝕨
}
Pickd←(∨´IsArray⌜∘⥊∘⊣)◶Pick1‿{Pickd⟜𝕩⌜𝕨}
Pick←IsArray◶⥊‿⊢⊸Pickd

# Sorting
CmpLen ← {
  e←𝕨-˜○(∨´0⊸=)𝕩
  𝕨(e=0)◶⟨0,e⟩‿{
    c←×𝕨-○≠𝕩
    r←𝕨⌊○≠𝕩
    l←𝕨{
      i←+´∧`𝕨=𝕩
      m←×´⊑⟜𝕨⌜↕i
      {c↩×-´𝕩⋄m↩m×⌊´𝕩}∘(⊑¨⟜𝕨‿𝕩)⍟(r⊸>)i
      m
    }○(((-1+↕r)+≠)⊸{⊑⟜𝕩⌜𝕨})𝕩
    ⟨l,c⟩
  }𝕩
}
_getCellCmp ← {
  Ci←𝔽⋄l←𝕨⋄c←𝕩
  Cc←{
    a←𝕨⋄b←𝕩
    S←(l⊸=)◶{S∘(1+𝕩)⍟(0⊸=)a Ci○(𝕩⊸+)b}‿c
    S 0
  }
  (1≠l)⊑(𝕩⍟(0⊸=)𝔽)‿Cc
}

_binSearch ← {
  B ← 𝔽
  {
    R←{𝕨{a←B m←𝕩+h←⌊𝕨÷2⋄(h+a×2|𝕨)R a⊑𝕩‿m}⍟(>⟜1)𝕩}
    1+(𝕩+1)R ¯1
  }⍟(0⊸<)
}
_bins←{
  c←1-˜=𝕨
  "⍋ or ⍒: Rank of 𝕨 must be at least 1" ! 0≤c
  "⍋ or ⍒: Rank of 𝕩 must be at least cell rank of 𝕨" ! c≤=𝕩
  lw←×´sw←1 Cell 𝕨
  cw←lw 𝔽○(⊑⟜(⥊𝕨)) _getCellCmp 0
  "⍋ or ⍒: 𝕨 must be sorted" ! 0⊸<◶⟨1,∧´0≤˜·cw⟜(lw⊸+)⌜lw×↕∘-⟜1⟩≠𝕨
  cx←c-˜=𝕩
  sx←cx Cell 𝕩 ⋄ lc←sw CmpLen sx
  cc ← (⊑⟜(⥊𝕨))⊸𝔽⟜(⊑⟜(⥊𝕩)) _getCellCmp´ lc
  B←(×´sw)⊸×⊸Cc≤0˜
  (≠𝕨)⊸{B⟜𝕩 _binSearch 𝕨}⌜ (×´sx) × ⥊⟜(↕×´)⊑⟜(≢𝕩)⌜↕cx
}

⚇ ← _depthOp_
⎉ ← _rankOp_
⍋ ← Cmp  _grade_ 0 ⊘ (Cmp  _bins)
⍒ ← Cmp˜ _grade_ 1 ⊘ (Cmp˜ _bins)

# Searching
_search←{ # 0 for ∊˜, 1 for ⊐
  ind ← 𝕗
  red ← 𝕗⊑⟨¬∧˝,+˝∧`⟩
  {
    c←1-˜=𝕨
    "p⊐𝕩 or 𝕨∊p: p must have rank at least 1" ! 0≤c
    𝕨 ∧○(8<≠∘⥊)◶⟨
      (0<≠𝕨)◶⟨0⎉c∘⊢, Red≢⌜○((0<c)◶⟨⊢,<⎉c⟩)⟩
      { g←⌽⍒𝕨 ⋄ i←g⊏˜0⌈1-˜(g⊏𝕨)⍋𝕩 ⋄ (≠𝕨)(⊣+i⊸-⊸×)⍟ind(i⊏𝕨)≡⎉c𝕩 }
    ⟩ ToArray𝕩
  }
}
PermInv ← 1¨⊸GroupOrd
_self←{
  "∊𝕩 or ⊐𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  g←⍋𝕩
  (PermInv g) ⊏ g 𝔽 0⊸<◶⟨1,-⟜1≢○(⊑⟜(g⊏<˘⍟(1<=)𝕩))⊢⟩⌜↕≠𝕩
}
SelfClas ← (PermInv∘⍋∘/˜⊏˜1-˜+`∘⊢) _self
Find←{
  r←=𝕨
  "⍷𝕩: Rank of 𝕨 cannot exceed rank of 𝕩" ! r≤=𝕩
  𝕨 ≡⎉r (≢𝕨) ↕⎉r 𝕩
}

≍ ← >∘Pair
∾ ↩ Join           ⊘ JoinTo
⊔ ← GroupInds      ⊘ GroupGen
⊐ ← SelfClas       ⊘ (1 _search)
∊ ← ⊢_self         ⊘ (0 _search˜)

ReorderChk←{
  "𝕨⍉𝕩: 𝕨 must have rank at most 1" ! 1≥=𝕨
  "𝕨⍉𝕩: Length of 𝕨 must not exceed rank of 𝕩" ! 𝕨≤○≠≢𝕩
  "𝕨⍉𝕩: 𝕨 must consist of natural numbers" ! ∧´Nat⌜⥊𝕨
}
ReorderAxesSub←{
  (𝕨⊸⊏Pick𝕩˙)⌜↕⌊´⌜𝕨⊔≢𝕩
}
ReorderAxes←{
  𝕨 ReorderChk 𝕩
  𝕨↩⥊𝕨
  r←(=𝕩)-+´¬∊𝕨
  "𝕨⍉𝕩: Skipped result axis" ! ∧´𝕨<r
  (𝕨∾𝕨(¬∘∊˜/⊢)↕r) ReorderAxesSub 𝕩
}
ReorderAxesInv←{
  𝕨 ReorderChk 𝕩
  𝕨↩⥊𝕨
  r←=𝕩
  IA ∧´(∊∧<⟜r)𝕨
  (PermInv 𝕨∾𝕨(¬∘∊˜/⊢)↕r) ReorderAxesSub 𝕩
}
⍉ ← Transpose      ⊘ ReorderAxes

OccurrenceCount ← ⊐˜(⊢-⊏)⍋∘⍋
ProgressiveIndexOf ← {𝕨⊐○((≠∾2˙)⥊·≍˘⟜OccurrenceCount𝕨⊸⊐)𝕩}

⊏ ← FirstCell      ⊘ (ToArray⊸(SelSub _onAxes_ 1))
⊑ ↩ (0⊑⥊)          ⊘ Pick
◶ ↩ {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}  # Same definition, new Pick
⁼ ← {Inverse 𝕗}

_repeat_←{
  n←𝕨𝔾𝕩
  l←u←0
  {"⍟: Repetition numbers in 𝕨 must be integers"!Int𝕩⋄l↩l⌊𝕩⋄u↩u⌈𝕩}⚇0 n
  a←𝕩⋄_p←{𝔽∘⊣`⟨a⟩∾↕0+𝕩}
  pos←(𝕨𝔽 ⊢)_p u
  neg←(𝕨𝔽⁼⊢)_p-l
  (|⊑<⟜0⊑pos‿neg˙)⚇0 n
}

ReshapeT ← ⟨∘,⌊,⌽,↑⟩⊑∘⊐<

⍟ ↩ _repeat_
⥊ ↩ Deshape        ⊘ Reshape
⌾ ← _under_
⊒ ← OccurrenceCount⊘ ProgressiveIndexOf
⍷ ← ∊⊸/            ⊘ Find

IA ← "⁼: Inverse failed"⊸!
IX ← "⁼: Inverse does not exist"⊸!
INF← "⁼: Inverse not found"!0˙
_invChk_ ← {i←𝕨𝔽𝕩⋄IX 𝕩≡𝕨𝔾i⋄i}
GroupIndsInv ← {
  IA 1==𝕩
  j←∾𝕩
  IA∧´Nat⌜j
  g←GroupLen j
  IX∧´g≤1
  o←/¬g
  (⍋j∾o)⊏(/≠¨𝕩)∾¯1¨o
}
GroupInv ← {
  IA 1==𝕨
  IA ∧´Nat⌜𝕨
  (⊔𝕨) ⍋⊸⊏○∾ 𝕩
}
_lookup_ ← {
  s ← 2×↕(≠𝕘)÷2
  (⊑(s⊏𝕘)⊐<) ⊑ (((1+s)⊏𝕘)∾⟨𝕗⟩)˙
}
PrimInverse ← INF _lookup_ ⟨
  +, +⊘(-˜)
  -, -
  ×, ⊢⊘(÷˜)
  ÷, ÷
  ⋆, Log _perv
  √, ×˜⊘(⋆˜)
  ∧, ⊢_invChk_∧⊘(÷˜)
  ∨, ⊢_invChk_∨⊘(-˜÷1-⊣)
  ¬, ¬
  <, {IX IsArray𝕩⋄IX 0==𝕩⋄⊑𝕩}⊘(IA∘0)
  ⊢, ⊢
  ⊣, ⊢⊘(⊢⊣IX∘≡)
  ∾, IA∘0 ⊘ {d←𝕩-○=𝕨⋄IX(0⊸≤∧≤⟜1)d⋄l←d◶1‿≠𝕨⋄IX l≤≠𝕩⋄IX 𝕨≡d◶⟨⊏,l⊸↑⟩𝕩⋄l↓𝕩}
  ≍, {IX 1=≠𝕩⋄⊏𝕩} ⊘ {IX 2=≠𝕩⋄IX 𝕨≡⊏𝕩⋄1⊏𝕩}
  ↑, ¯1⊸⊑_invChk_↑ ⊘ (IA∘0)
  ↓,    ⊑_invChk_↓ ⊘ (IA∘0)
  ↕, ≢_invChk_↕ ⊘ (IA∘0)  # Should trace edge and invChk
  ⌽, ⌽ ⊘ (-⊸⌽)
  ⍉, TransposeInv ⊘ ReorderAxesInv
  /, {IA 1==𝕩⋄IA∧´Nat⌜𝕩⋄IX(∧´¯1⊸↓≤1⊸↓)𝕩⋄GroupLen𝕩}⊘(IA∘0)
  ⊔, GroupIndsInv ⊘ GroupInv
⟩
⌜ ↩ {𝕨𝔽⌜○ToArray𝕩}
_inv_ ← {𝕘⋄𝕨𝔽𝕩}
AtopInverse ← {(𝕏𝕎)⊘(𝕏⟜𝕎)}○{Inverse𝕩}
Mod1Inverse ← INF˙ _lookup_ ⟨
  ˜, INF _lookup_ ⟨
    +, ÷⟜2⊘(-˜)
    -, IA∘0⊘+
    ×, √⊘(÷˜)
    ÷, IA∘0⊘×
    ⋆, IA∘0⊘√
    √, IA∘0⊘(÷Log)
    ∧, √⊘(÷˜)
    ∨, (¬√∘¬)⊘(-˜÷1-⊣)
    ¬, IA∘0⊘(+-1˙)
  ⟩
  ¨, {𝕏⁼¨       ⊣·IA 0<≡∘⊢}
  ⌜, {𝕏⁼⌜⊘(IA∘0)⊣·IA 0<≡∘⊢}
  ˘, {𝕏⁼˘       ⊣·IA 0<=∘⊢}
  `, {(⊏∾¯1⊸↓𝕏⁼¨1⊸↓)⍟(1<≠)⊘(IA∘0)}
⟩ {
  0⊸⊑ {𝕏𝕨}⟜𝔽 1⊸⊑
}
IsConstant ← (3≤Type)◶⟨1 ⋄ 4‿˙ ≡ 0‿¯1⊏Decompose⟩
Mod2Inverse ← INF˙ _lookup_ ⟨
  _inv_, {𝕏_inv_𝕎}
  ∘, AtopInverse
  ○, {Fi←𝕎⁼⋄𝕏⁼ Fi⊘(𝕏⊸Fi)}
  ⌾, {𝕎⁼⌾𝕏}  # Need to verify for computation Under
  ⍟, Int∘⊢◶⟨IA∘0˙,{𝕎⍟(-𝕩)}⟩
  ⊘, {(𝕎⁼)⊘(𝕏⁼)}
  ⊸, IsConstant∘⊣ ⊣◶{INF⊘𝕏}‿⊢ {𝕎⊸(𝕏⁼)}
  ⟜, IsConstant∘⊢◶⟨INF˙,{(𝕨𝕏˜⁼⊢)⊘(IA∘0)}⟩
⟩ {
  0‿2⊸⊏ {𝕏´𝕨}⟜𝔽 1⊸⊑
}
TrainInverse ← {
  f‿g‿h←𝕩
  K←¬IsConstant⊸∧⟜((⊑⟨⊢⟩)⊸=)
  f K◶⟨{𝕨G⁼⊢},K˜◶⟨{𝕩G˜⁼⊢},INF˙⟩⟩ h
}
FuncInverse ← (⊑ ⊣◶⟨
  PrimInverse∘⊑⊢                         # 0 primitive
  ("Cannot currently invert blocks"!0˙)˙ # 1 block
  AtopInverse´⊢                          # 2-train
  TrainInverse                           # 3-train
  Mod1Inverse                            # 4 1-modifier
  Mod2Inverse                            # 5 2-modifier
⟩ 1⊸↓) Decompose
Inverse ← Type◶(3‿1‿2/{⊢⊣𝕩IX∘≡⊢}‿FuncInverse‿("Cannot invert modifier"!0˙))
⁼ ↩ {𝕗 (≠∧INF˙⊸≠)◶0‿(5‿_inv_≢0‿¯2⊏Decompose∘⊢)◶⊢‿{𝕏_inv_(𝕎_invChk_𝕏)} Inverse 𝕗}
