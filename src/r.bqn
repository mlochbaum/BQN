# BQN runtime. Requires:
# IsArray Type Log  !+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘

◶ ← {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}     # LIMITED to number left operand result
⊢ ← {𝕩}
⊣ ← {𝕩}⊘{𝕨}
˜ ← {𝕩𝔽𝕨⊣𝕩}
∘ ← {𝔽𝕨𝔾𝕩}
○ ← {(𝔾𝕨)𝔽𝔾𝕩}
⊸ ← {(𝔽𝕨⊣𝕩)𝔾𝕩}
⟜ ← {(𝕨⊣𝕩)𝔽𝔾𝕩}
⍟ ← {𝕨((𝕨𝔾𝕩)⊑⊢‿𝕗){𝔽}𝕩}   # LIMITED to boolean right operand result

Int←IsArray◶⟨⌊⊸=,0⟩
Nat←IsArray◶⟨0⊸≤×⌊⊸=,0⟩

# LIMITED to numeric arguments for scalar cases
≥ ←            ≤˜
< ← {⟨⟩⥊⟨𝕩⟩} ⊘ (1-≥)
> ←            (1-≤)
⌊ ↩ ⌊        ⊘ (>⊑{𝕨‿𝕩})
⌈ ← -∘⌊∘-    ⊘ (<⊑{𝕨‿𝕩})
≠ ← (0<=)◶⟨1⋄0⊑≢⟩  # LIMITED to monadic case

_fold←{
  "Argument to fold must be a list" ! 1==𝕩
  l←≠v←𝕩 ⋄ F←𝔽
  r←𝕨 (0<l)◶{𝕩⋄Identity f}‿{l↩l-1⋄l⊑𝕩}⊘⊣ 𝕩
  {r↩(𝕩⊑v)F r}⌜(l-1)⊸-⌜↕l
  r
}
´ ← _fold

ToArray ← <⍟(1-IsArray)
Cell←{(𝕨⊸+⊑𝕩˜)⌜↕(≠𝕩)-𝕨}⟜≢

∾ ← {k←≠𝕨⋄k⊸≤◶⟨⊑⟜𝕨⋄-⟜k⊑𝕩˜⟩⌜↕k+≠𝕩}  # LIMITED to two vector arguments

_eachd←{
  _d←{ # Equal ranks
    p←≢𝕨
    "Equal-rank argument shapes don't agree" ! 1(⊑⟜p=⊑⟜(≢𝕩))⊸×´↕=𝕨
    p⥊ (⊑⟜(⥊𝕨)𝔽⊑⟜(⥊𝕩))⌜↕1×´p
  }
  _e←{ # 𝕨 has smaller or equal rank
    p←≢𝕨 ⋄ k←=𝕨 ⋄ q←≢𝕩
    "Argument shape prefixes don't agree" ! 1(⊑⟜p=⊑⟜q)⊸×´↕k
    l←1(q⊑˜k⊸+)⊸×´↕(=𝕩)-k
    a←⥊𝕨 ⋄ b←⥊𝕩
    q⥊⥊(≠a) (⊑⟜a𝔽l⊸×⊸+⊑b˜)⌜○↕ l
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
  "Grade argument must have rank at least 1" ! 1≤=𝕩
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
  "Replication argument in Indices or Replicate must have rank 1" ! 1==𝕩
  l←≠𝕩
  {
    "Amounts to replicate must be natural numbers" ! 1×´Nat⌜𝕩
    k←l-1
    N ← ((⊢+-×0=𝕩⊑˜⊢)`k⊸-⌜↕l)⊑˜k-⊢  # Next nonzero
    E ← ⊑⟜(+`𝕩)
    ei←E i←N 0
    {{ei↩E i↩N𝕩+1⋄i}⍟(𝕩=ei)i}⌜↕E k
  }⍟(0<l)𝕩
}

Transpose←{
  l←≠𝕩 ⋄ m←1×´c←1 Cell 𝕩
  (c⥊↕m)(+⟜(m⊸×)⊑(⥊𝕩)˜)⌜↕l
}⍟(0<=)
TransposeInv←{
  r←1-˜=𝕩 ⋄ s←≢𝕩 ⋄ l←r⊑s ⋄ c←⊑⟜s⌜↕r
  (↕l)(+⟜(l⊸×)⊑(⥊𝕩)˜)⌜c⥊↕1×´c
}⍟(0<=)

SelSub←{
  "Right argument to Select must be an array" ! IsArray 𝕨
  "Indices in Select must be integers" ! 1×´⥊Int⌜ 𝕨
  l←≠𝕩
  "Select indices out of range" ! 1×´⥊ ((-l)⊸≤×l⊸>)⌜ 𝕨
  ((⊢+l×0>⊢)⌜𝕨)(1==𝕩)◶{
    c←1×´s←1 Cell 𝕩
    𝕨((⥊𝕩)⊑˜c⊸×⊸+)⌜s⥊↕c
  }‿{
    ⊑⟜𝕩⌜𝕨
  }𝕩
}

Reverse ← {
  "Reverse argument must have rank at least 1" ! 1≤=𝕩
  l←≠𝕩
  ((l-1)⊸-⌜↕l) Select 𝕩
}
Rot ← {
  "Amount to rotate must be an integer" ! Int𝕨
  l←≠𝕩 ⋄ 𝕨-↩l×⌊𝕨÷l ⋄ ((𝕨+⊢-l×(l-𝕨)≤⊢)⌜↕l) Select 𝕩
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

¨ ↩ {(𝔽⌜)⊘(𝔽_eachd)○ToArray}

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

˘ ← {𝔽 _rankOp_ ¯1}
_onAxes_←{
  F←𝔽
  (𝔾<≡)∘⊣◶{ # One axis
    "First-axis function right argument must have rank at least 1" ! 1≤=𝕩
    𝕨F𝕩
  }‿{ # Multiple axes
    "Left argument must have rank at most 1" ! 1≥=𝕨
    "Left argument length must be at most right argument rank" ! 𝕨≤○≠≢𝕩
    l←≠𝕨 ⋄ W←⊑⟜(⥊𝕨)
    0{(W𝕨)F(1+𝕨)⊸𝕊˘⍟(𝕨<l-1)𝕩}⍟(0<l)𝕩
  }
}

Select←ToArray⊸(SelSub _onAxes_ 1)
⊏ ← 0⊸Select       ⊘ Select

Merge←{
  c←≢0⊑⥊𝕩
  "Elements in Merge argument must have matching shapes" ! 1×´(c≡≢)⌜⥊𝕩
  𝕩⊑⟜Deshape˜⌜c⥊↕1×´c
}⍟(0<≠∘⥊)⍟IsArray

_sort ← {(𝕗⊑⟨Cmp,Cmp˜⟩)_grade_𝕗 ⊸ Select}

÷ ↩ ÷ _perv
⋆ ↩ ⋆ _perv
√ ← ⋆⟜(÷2)   ⊘ (⋆⟜÷˜)
| ← (0⊸≤◶-‿⊢ ⊘ {𝕩-𝕨×⌊𝕩÷𝕨}) _perv
⌊ ↩ (⌊       ⊘ {(𝕨>𝕩)⊑𝕨‿𝕩}) _perv
⌈ ↩ (-∘⌊∘-   ⊘ {(𝕨<𝕩)⊑𝕨‿𝕩}) _perv
∧ ← 0 _sort  ⊘ (× _perv)
∨ ← 1 _sort  ⊘ ((+-×) _perv)
× ↩ (0⊸(<->) ⊘ ×) _perv
< ↩ {⟨⟩⥊⟨𝕩⟩} ⊘ ((1-≥) _perv)
> ↩ Merge    ⊘ ((1-≤) _perv)
≠ ↩ ≠        ⊘ ((1-=) _perv)
= ↩ =        ⊘ (= _perv)
≥ ← ("No monadic form: ≥"!0˜) ⊘ (≥ _perv)
≤ ↩ ("No monadic form: ≤"!0˜) ⊘ (≤ _perv)
+ ↩ + _perv
- ↩ - _perv
¬ ← 1+-
identity ← (0⊑⟨"Identity not found"!0˜⟩) {(0⊑𝕨){𝕗=𝕩}◶𝕩‿(1⊑𝕨)}´ ⟨+‿0,-‿0,×‿1,÷‿1,⋆‿1,√‿1,∧‿1,∨‿0,¬‿1,|‿0,⌊‿∞,⌈‿¯∞,<‿0,≤‿1,=‿1,≥‿1,>‿0,≠‿0⟩

Deshape←IsArray◶{⟨𝕩⟩}‿⥊
Reshape←{
  "Shape argument to Reshape must have rank at most 1" ! 1≥=𝕨
  s←Deshape 𝕨
  sp←+´p←¬Nat⌜s
  "Shape in Reshape must consist of natural numbers" ! 1≥sp
  n←≠d←Deshape 𝕩
  l←sp◶(×´)‿{
    lp←×´p⊣◶⊢‿1¨𝕩
    "Can't compute axis length in Reshape when rest of shape is empty" ! 0<lp
    i←+´p×↕≠p
    t←ReshapeT i⊑s
    "Shape in Reshape must be a natural number or ∘ ⌊ ⌽ ↑" ! t<4
    Chk ← ⊢ ⊣ "Shape must be exact when reshaping with ∘" ! ⌊⊸=
    a←(2⌊t)◶⟨Chk,⌊,⌈⟩n÷lp
    s↩p⊣◶⊢‿a¨s
    {d∾↩(Type d)⌜↕𝕩-n⋄n}⍟(n⊸<)⍟(3=t)lp×a
  } s
  s⥊{
    𝕩(0<n)◶⟨Type⊸(⊣⌜)⋄{⊑⟜d⌜n|𝕩}⟩↕l
  }⍟(l≠n)d
}
⥊ ↩ Deshape        ⊘ ⥊

Range←{
  I←{"Range argument must consist of natural numbers"!Nat𝕩⋄↕𝕩}
  M←{"Range argument must be a number or list"!1==𝕩⋄(<⟨⟩)⥊⊸∾⌜´I⌜𝕩}
  IsArray◶I‿M 𝕩
}


Pair ← {⟨𝕩⟩} ⊘ {⟨𝕨,𝕩⟩}

≍ ← >∘Pair
_ranks ← {⟨2⟩⊘⟨1,0⟩((⊣-1+|)˜⟜≠⊑¨<∘⊢)⥊∘𝔽}
_depthOp_←{
  neg←0>n←𝕨𝔾_ranks𝕩 ⋄ F←𝔽
  _d←{
    R←(𝕗+neg)_d
    𝕨(×⟜2⊸+´2 Reshape (neg∧𝕗≥0)∨(0⌈𝕗)≥Pair○≡)◶(⟨R¨⋄R⟜𝕩⌜∘⊣⋄(𝕨R⊢)⌜∘⊢⋄F⟩)𝕩
  }
  𝕨 n _d 𝕩
}
⚇ ← _depthOp_
_rankOp_←{
  k←𝕨(Pair○= (0≤⊢)◶⟨⌊⟜-,0⌈-⟩¨ 𝔾_ranks)𝕩
  Enc←{
    f←⊑⟜(≢𝕩)⌜↕𝕨
    c←×´s←𝕨Cell𝕩
    f⥊⊑⟜(⥊𝕩)⌜∘((s⥊↕c)+c×⊢)⌜↕×´f
  }
  Enc↩(>⟜0×1+≥⟜=)◶⟨<⊢,Enc,<⌜⊢⟩
  > ((0⊑k)Enc𝕨) 𝔽¨ ((1-˜≠)⊸⊑k)Enc𝕩
}
⎉ ← _rankOp_
_insert←{
  "Insert argument must have rank at least 1" ! 1≤=𝕩
  𝕨 𝔽´ <˘𝕩
}
˝ ← _insert


JoinTo←∨○(1<=)◶(∾○⥊)‿{
  s←𝕨Pair○≢𝕩
  a←1⌈´k←≠⌜s
  "Rank of joined arguments must differ by at most 1" ! ∧´1≥a-k
  c←(k¬a)+⟜(↕a-1)⊸⊏¨s
  "Cell shapes of joined arguments must match" ! ≡´c
  l←+´(a=k)⊣◶1‿(0⊑⊢)¨s
  (⟨l⟩∾0⊑c)⥊𝕨∾○⥊𝕩
}

Take←{
  T←{
    "Left argument to Take or Drop must be an integer" ! Int 𝕨
    l←≠𝕩 ⋄ n←𝕨<0 ⋄ e←l⌊r←|𝕨 ⋄ s←⟨r⟩ ⋄ m←1
    i ← 𝕩{s∾↩c←1 Cell 𝕨⋄𝕩(×+⌜↕∘⊢)m↩×´c}⍟(1≠=𝕩) (l-e)+⍟n ↕e
    s⥊𝕩{(⥊𝕩)n◶⟨∾,∾˜⟩(0⊑⥊Type𝕗)⌜↕m×r-e}⍟(l<r) ⊑⟜(⥊𝕩)⌜i
  }
  𝕨 T _onAxes_ 0 ((1⌜∘↕0⌈𝕨-○≠⊢)⊸∾∘≢⥊⥊) 𝕩
}
Prefixes ← {"Prefixes argument must have rank at least 1"!1≤=𝕩 ⋄ Take⟜𝕩⌜↕1+≠𝕩}
↑ ← Prefixes       ⊘ Take
Drop←{
  s←(≠𝕨)(⊣↑⊢∾˜·1⌜∘↕0⌈-⟜≠)≢𝕩
  ((s×¯1⋆𝕨>0)+(-s)⌈s⌊𝕨)↑𝕩
}
Suffixes ← {"Suffixes argument must have rank at least 1"!1≤=𝕩 ⋄ Drop⟜𝕩⌜↕1+≠𝕩}
↓ ← Suffixes       ⊘ Drop

Windows←{
  "Windows right argument must be an array" ! IsArray 𝕩
  "Windows left argument must have rank at most 1" ! 1≥=𝕨
  "Windows left argument length must be at most right argument rank" ! 𝕨≤○≠≢𝕩
  "Windows left argument must consist of natural numbers" ! ∧´Nat⌜⥊𝕨
  s←(≠𝕨)↑≢𝕩
  "Window length must be at most axis length plus one" ! ∧´𝕨≤1+s
  𝕨{(∾⟜(𝕨≠⊸↓≢𝕩)∘≢⥊>)<⌜⊸⊏⟜𝕩¨s(¬+⌜○Range⊢)⥊𝕨}⍟(0<≠𝕨)𝕩
}

Rep ← Indices⊸⊏
Replicate ← {0<=𝕨}◶{𝕨˘⊸Rep𝕩}‿{"Replicate argument lengths must match"!𝕨=○≠𝕩⋄𝕨Rep𝕩} _onAxes_ (1-0=≠)

↕ ↩ Range          ⊘ Windows
⌽ ← Reverse        ⊘ (Rot _onAxes_ 0)
/ ← Indices        ⊘ Replicate

Join←(1≠=)◶⟨∨´1≠=⌜,1⟩◶{
  # List of lists
  i←j←¯1⋄e←⟨⟩⋄a←𝕩
  {{e↩a⊑˜i↩𝕩⋄j↩¯1}⍟(i⊸≠)𝕩⋄(j↩j+1)⊑e}⌜/≠⌜𝕩
}‿{
  # Multidimensional
  C←(<⟨⟩)⥊⊸∾⌜´⊢  # Cartesian array product
  "Join argument must be an array" ! IsArray 𝕩
  s←≢⌜𝕩
  d←≠0⊑⥊s
  "Join argument elements must all have the same rank" ! ∧´⥊d=≠⌜s
  "Join argument element rank must be at least argument rank" ! d≥=𝕩
  l←(≢𝕩){(𝕩⊑⟜≢a Pick1˜(j=𝕩)⊸×)⌜↕𝕨}¨j←↕r←=a←𝕩
  "Join argument element shapes must be compatible" ! (r⊸↑⌜s)≡C l
  i←C{p←+´⌜↑𝕩⋄(↕0⊑⌽p)-𝕩/¯1↓p}⌜l
  >i<⌜⊸⊏¨l/𝕩
}⍟(0<≠∘⥊)

_group←{
  "Grouping argument must be a list" ! 1==𝕩
  "Grouping argument must consist of integers" ! ∧´Int⌜𝕩
  "Grouping argument values cannot be less than ¯1" ! ∧´¯1≤𝕩
  d←(l←GroupLen𝕩)GroupOrd𝕩
  i←0⋄(𝔽{𝕩⋄(i↩i+1)⊢i⊑d}⌜∘↕)⌜l
}
GroupInds←{
  "Group Indices argument must be an array" ! IsArray 𝕩
  G←⊢_group
  (1<≡)◶G‿((<<⟨⟩)⥊⊸∾⌜⌜´G⌜)𝕩
}
GroupGen←{
  "Group right argument must be an array" ! IsArray 𝕩
  m←1<≡𝕨
  l←m◶≠‿{"Group left argument must consist of lists"!1==𝕩⋄≠⌜𝕩}𝕨
  "Group left argument length must be at most right argument rank" ! l≤○≠≢𝕩
  "Group argument lengths must be compatible" ! ∧´l=l≠⊸↑≢𝕩
  𝕨m◶(⊏⟜𝕩_group⊣)‿{
    ⊏⟜(𝕩⥊˜⟨×´l⟩∾(≠l)Cell𝕩)⌜ +⌜⌜´ (⌽×`⟨1⟩∾⌽1↓l) × ⊢_group⌜𝕨
  }𝕩
}

∾ ↩ Join           ⊘ JoinTo
⊔ ← GroupInds      ⊘ GroupGen

Pick1←{
  "Indices in compound Pick must be lists" ! 1==𝕨
  "Pick index length must match right argument rank" ! 𝕨=○≠s←≢𝕩
  "Pick indices must consist of integers" ! ∧´Int⌜𝕨
  "Pick index out of range" ! ∧´𝕨(≥⟜-∧<)s
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
  "Bins argument must have rank at least 1" ! 0≤c
  "Bins right argument rank is too small" ! c≤=𝕩
  lw←×´sw←1 Cell 𝕨
  cw←lw 𝔽○(⊑⟜(⥊𝕨)) _getCellCmp 0
  "Bins left argument must be sorted" ! 0⊸<◶⟨1,∧´0≤˜·cw⟜(lw⊸+)⌜lw×↕∘-⟜1⟩≠𝕨
  cx←c-˜=𝕩
  sx←cx Cell 𝕩 ⋄ lc←sw CmpLen sx
  cc ← (⊑⟜(⥊𝕨))⊸𝔽⟜(⊑⟜(⥊𝕩)) _getCellCmp´ lc
  B←(×´sw)⊸×⊸Cc≤0˜
  (≠𝕨)⊸{B⟜𝕩 _binSearch 𝕨}⌜ (×´sx) × ⥊⟜(↕×´)⊑⟜(≢𝕩)⌜↕cx
}

⍋ ← Cmp  _grade_ 0 ⊘ (Cmp  _bins)
⍒ ← Cmp˜ _grade_ 1 ⊘ (Cmp˜ _bins)

# Searching
_search←{ # 0 for ∊˜, 1 for ⊐
  ind ← 𝕗
  red ← 𝕗⊑⟨¬∧˝,+˝∧`⟩
  {
    c←1-˜=𝕨
    "Search principal argument must have rank at least 1" ! 0≤c
    𝕨 ∧○(8<≠∘⥊)◶⟨
      (0<≠𝕨)◶⟨0⎉c∘⊢, Red≢⌜○((0<c)◶⟨⊢,<⎉c⟩)⟩
      { g←⌽⍒𝕨 ⋄ i←g⊏˜0⌈1-˜(g⊏𝕨)⍋𝕩 ⋄ (≠𝕨)(⊣+i⊸-⊸×)⍟ind(i⊏𝕨)≡⎉c𝕩 }
    ⟩ ToArray𝕩
  }
}
PermInv ← 1¨⊸GroupOrd
_self←{
  "Unique mask argument must have rank at least 1" ! 1≤=𝕩
  g←⍋𝕩
  (PermInv g) ⊏ g 𝔽 0⊸<◶⟨1,-⟜1≢○(⊑⟜(g⊏<˘⍟(1<=)𝕩))⊢⟩⌜↕≠𝕩
}
SelfClas ← (PermInv∘⍋∘/˜⊏˜1-˜+`∘⊢) _self
Find←{
  r←=𝕨
  "Find left argument rank cannot exceed right argument rank" ! r≤=𝕩
  𝕨 ≡⎉r (≢𝕨) ↕⎉r 𝕩
}

⊐ ← SelfClas       ⊘ (1 _search)
∊ ← ⊢_self         ⊘ (0 _search˜)
⍷ ← ∊⊸/            ⊘ Find

ReorderChk←{
  "Left argument to Reorder Axes must have rank at most 1" ! 1≥=𝕨
  "Reorder Axes left argument length must not exceed right argument rank" ! 𝕨≤○≠≢𝕩
  "Reorder Axes left argument must consist of natural numbers" ! ∧´Nat⌜⥊𝕨
}
ReorderAxesSub←{
  (𝕨⊸⊏Pick𝕩˜)⌜↕⌊´⌜𝕨⊔≢𝕩
}
ReorderAxes←{
  𝕨 ReorderChk 𝕩
  𝕨↩⥊𝕨
  r←(=𝕩)-+´¬∊𝕨
  "No such axis in Reorder Axes" ! ∧´𝕨<r
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
ProgressiveIndexOf ← {𝕨⊐○(≍˘⟜OccurrenceCount𝕨⊸⊐)𝕩}
⊒ ← OccurrenceCount⊘ ProgressiveIndexOf

⊑ ↩ (0⊑⥊)          ⊘ Pick
◶ ↩ {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}  # Same definition, new Pick

IA ← "Inverse failed"⊸!
IX ← "Inverse does not exist"⊸!
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
inverse ← {(⊑(0⊏𝕩)⊐<) ⊑ ((1⊏𝕩)∾⟨"Inverse not found"!0˜⟩)˜} ⍉ (2∾˜2÷˜≠)⊸⥊ ⟨
  +, +⊘(-˜)
  -, -
  ×, ⊢⊘(÷˜)
  ÷, ÷
  ⋆, Log _perv
  √, ⋆⟜2⊘(⋆˜)
  ∧, ⊢_invChk_∧⊘(÷˜)
  ∨, ⊢_invChk_∨⊘(-˜÷1-⊢)
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
⁼ ← {Inverse 𝕗}

_repeat_←{
  n←𝕨𝔾𝕩
  l←u←0
  {"Repetition numbers must be integers"!Int𝕩⋄l↩l⌊𝕩⋄u↩u⌈𝕩}⚇0 n
  a←𝕩⋄_p←{𝔽∘⊣`⟨a⟩∾↕0+𝕩}
  pos←(𝕨𝔽 ⊢)_p u
  neg←(𝕨𝔽⁼⊢)_p-l
  (|⊑<⟜0⊑pos‿neg˜)⚇0 n
}
⍟ ↩ _repeat_

ReshapeT ← ⟨∘,⌊,⌽,↑⟩⊑∘⊐<
⥊ ↩ Deshape        ⊘ Reshape
⌜ ↩ {𝔽⌜○ToArray}
⌾ ← _under_
