# This file gives reference implementations of BQN primitives assuming
# limited initial functionality. Implementations are designed to be
# simple and not fast.

# Not yet included: characters, complex numbers, comparison tolerance,
# selective assignment, and Under.

# In some cases an operation is defined with limited functionality at
# first and later expanded. For convenience, rather than renaming these
# limited versions, every primitive use refers to the most recent
# definition in source code, as if redefinitions shadowed previous
# primitive definitions.


#⌜
# LAYER 0: Assumed functionality

# IEEE 754, except NaN results cause an error and -0 is converted to 0.
# LIMITED to the stated cases and real number arguments.
+          #                Add
-          # Negate         Subtract
×          #                Multiply
÷          # Reciprocal     Divide
⋆          # Exponential    Power
⌊          # Floor
=          #                Equals
≤          #                Less Than or Equal to

# Other basic functionality that we need to assume
IsArray    # Return 1 if 𝕩 is an array
!          # 𝕩 is 0 or 1; throw an error if it's 0
≢          # LIMITED to monadic case
⥊          # LIMITED to array 𝕩 and (×´𝕨)≡≢𝕩
⊑          # LIMITED to natural number 𝕩 and vector 𝕨
_amend     # {(𝕗⊑𝕩)↩𝕨⋄𝕩}
↕          # LIMITED to number 𝕩
Identity   # Left or right identity of function 𝕏
⁼          # Inverse of function 𝔽
Type       # Scalar (enclosed) prototype of 𝕩


#⌜
# LAYER 1: Foundational operators and functions

# Combinators
◶ ← {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}     # LIMITED to number left operand result
⊘ ← {𝕨((1{𝔽}𝕨)-0)◶𝔽‿𝔾 𝕩}
⊢ ← {𝕩}
⊣ ← {𝕩}⊘{𝕨}
˜ ← {𝕩𝔽𝕨⊣𝕩}
∘ ← {𝔽𝕨𝔾𝕩}
○ ← {(𝔾𝕨)𝔽𝔾𝕩}
⊸ ← {(𝔽𝕨⊣𝕩)𝔾𝕩}
⟜ ← {(𝕨⊣𝕩)𝔽𝔾𝕩}

# LIMITED to numeric arguments for scalar cases
√ ← 2⊸√      ⊘ (⋆⟜÷˜)
∧ ←            ×
∨ ←            (+-×)
¬ ← 1+-
| ← ×⟜×      ⊘ {𝕩-𝕨×⌊𝕩÷𝕨}
< ← {⟨⟩⥊⟨𝕩⟩} ⊘ (¬≤˜)
> ←            (¬≤)
≥ ← !∘0      ⊘ (≤˜)
≠ ← Length   ⊘ (¬∘=)
× ↩ 0⊸(<->)  ⊘ ×
⌊ ↩ ⌊        ⊘ {(𝕨>𝕩)⊑𝕨‿𝕩}
⌈ ← -∘⌊∘-    ⊘ {(𝕨<𝕩)⊑𝕨‿𝕩}
≢ ↩ IsArray◶⟨⟩‿≢  # LIMITED to monadic case

¨ ← _eachm   # LIMITED to monadic case and array 𝕩
´ ← _reduce

_eachm←{
  r←⥊𝕩 ⋄ F←𝔽
  E←(≠r)⊸≤◶{r↩r𝕩_amend˜F𝕩⊑r⋄E𝕩+1}‿⊢
  E 0 ⋄ (≢𝕩)⥊r
}
_reduce←{
  ! 1=≠≢𝕩
  l←≠v←𝕩 ⋄ F←𝔽
  r←𝕨 (0<l)◶{𝕩⋄Identity f}‿{l↩l-1⋄l⊑𝕩}⊘⊣ 𝕩
  {r↩(𝕩⊑v)F r}¨(l-1)⊸-¨↕l
  r
}
Length ← (0<0⊑≢)◶⟨1⋄0⊑⊢⟩∘≢


#⌜
# LAYER 2: Pervasion
# After defining _perv, we apply it to all scalar functions,
# making them pervasive. I'm not going to write that out.

ToArray ← IsArray◶<‿⊢

∾ ← {k←≠𝕨⋄k⊸≤◶⟨⊑⟜𝕨⋄-⟜k⊑𝕩˜⟩¨↕k+≠𝕩}  # LIMITED to two vector arguments

_table←{
  m←≠a←⥊𝕨 ⋄ n←≠b←⥊𝕩 ⋄ F←𝔽
  r←↕m×n
  {𝕩⊸{r↩r((n×𝕨)+𝕩)_amend˜(𝕨⊑a)F(𝕩⊑b)}¨↕n}¨↕m
  (𝕨∾○≢𝕩)⥊r
}

_eachd←{
  _e←{ # 𝕨 has smaller or equal rank
    k←≠p←≢𝕨 ⋄ q←≢𝕩
    ! ∧´(⊑⟜p=⊑⟜q)¨↕k
    l←×´(q⊑˜k⊸+)¨↕q≠⊸-k
    a←⥊𝕨 ⋄ b←⥊𝕩
    q⥊⥊(≠a) (⊑⟜a𝔽l⊸×⊸+⊑b˜)_table○↕ l
  }
  (>○(≠≢))◶⟨𝔽_e⋄𝔽˜_e˜⟩
}
_perv←{ # Pervasion
  (⊢⊘∨○IsArray)◶⟨𝔽⋄𝔽{𝕨𝔽_perv𝕩}¨⟩
}

⌜ ← {(𝔽_eachm)⊘(𝔽_table)○ToArray}
¨ ↩ {(𝔽_eachm)⊘(𝔽_eachd)○ToArray}


#⌜
# LAYER 3: Remove other limits
# Now all implementations are full except ∾; ↕ is monadic only

Int←IsArray◶⟨⌊⊸=,0⟩
Nat←IsArray◶⟨0⊸≤∧⌊⊸=,0⟩

Deshape←IsArray◶{⟨𝕩⟩}‿⥊
Reshape←{
  ! 1≥≠≢𝕨
  𝕨↩⥊𝕨
  ! ∧´Nat¨𝕨
  n←≠𝕩 ⋄ l←×´𝕨
  ! n≤○(0⊸=)l
  𝕨⥊⊑⟜𝕩¨n|↕l
}⟜Deshape

Range←{
  I←{!Nat𝕩⋄↕𝕩}
  M←{!1=≠≢𝕩⋄(<⟨⟩)⥊⊸∾⌜´I¨𝕩}
  IsArray◶I‿M 𝕩
}

Pick1←{
  ! 1=≠≢𝕨
  ! 𝕨=○≠s←≢𝕩
  ! ∧´Int¨𝕨
  ! ∧´𝕨(≥⟜-∧<)s
  𝕨↩𝕨+s×𝕨<0
  (⥊𝕩)⊑˜0(⊑⟜𝕨+⊑⟜s×⊢)´-↕⊸¬≠𝕨
}
Pickd←(∨´∘⥊IsArray¨∘⊣)◶Pick1‿{Pickd⟜𝕩¨𝕨}
Pick←IsArray◶⥊‿⊢⊸Pickd

match←{¬∘(0⊑𝕨)◶(1⊑𝕨)‿𝕩}´⟨
  ⟨≠○IsArray , 0⟩
  ⟨¬IsArray∘⊢, =⟩
  ⟨≠○(≠≢)    , 0⟩
  ⟨∨´≠○≢     , 0⟩
  {∧´⥊𝕨Match¨𝕩}
⟩

Depth←IsArray◶0‿{1+0⌈´Depth¨⥊𝕩}

⊑ ↩ (0¨∘≢)⊸Pick    ⊘ Pick
⥊ ↩ Deshape        ⊘ Reshape
↕ ↩ Range
◶ ↩ {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}  # Same definition, new Pick

≡ ← Depth          ⊘ Match
≢ ↩ ≢              ⊘ (¬Match)


#⌜
# LAYER 4: Operators

> ↩ Merge          ⊘ >
≍ ← >∘Pair
⎉ ← _rankOp_
⚇ ← _depthOp_
⍟ ← _iterate_
˘ ← ⎉¯1
` ← _scan

DropV← {⊑⟜𝕩¨𝕨+↕𝕨-˜≠𝕩}
Cell ← DropV⟜≢
Pair ← {⟨𝕩⟩} ⊘ {⟨𝕨,𝕩⟩}

Merge←(0<≠∘⥊)◶⊢‿{
  c←≢⊑𝕩
  ! ∧´⥊(c≡≢)¨𝕩
  𝕩⊑⟜ToArray˜⌜↕c
}
_ranks ← {⟨2⟩⊘⟨1,0⟩((⊣-1+|)˜⟜≠⊑¨<∘⊢)⥊∘𝔽}
_depthOp_←{
  neg←0>n←𝕨𝔾_ranks𝕩 ⋄ F←𝔽
  _d←{
    R←(𝕗+neg)_d
    𝕨(2⥊(neg∧𝕗≥0)∨(0⌈𝕗)≥Pair○≡)◶(⟨R¨⋄R⟜𝕩¨∘⊣⟩≍⟨(𝕨R⊢)¨∘⊢⋄F⟩)𝕩
  }
  𝕨 n _d 𝕩
}
_rankOp_←{
  k←𝕨(Pair○(≠≢) (0≤⊢)◶⟨⌊⟜-,0⌈-⟩¨ 𝔾_ranks)𝕩
  Enc←{
    f←⊑⟜(≢𝕩)¨↕𝕨
    c←×´s←𝕨Cell𝕩
    f⥊⊑⟜(⥊𝕩)¨∘((s⥊↕c)+c×⊢)¨↕×´f
  }
  > ((⊑k)Enc𝕨) 𝔽¨ ((1-˜≠)⊸⊑k)Enc𝕩
}
_scan←{
  ! IsArray 𝕩
  ! 1≤≠≢𝕩
  F←𝔽
  (0<≠∘⥊)◶⊢‿{
    r←⥊𝕩 ⋄ l←≠𝕩 ⋄ c←×´1 Cell 𝕩
    {r↩r𝕩_amend˜𝕨F○(⊑⟜r)𝕩}⟜(c⊸+)¨↕c-˜≠r
    (≢𝕩)⥊r
  }𝕩
}
_iterate_←{
  n←𝕨𝔾𝕩
  f←⊑𝕨⟨𝔽⟩⊘⟨𝕨𝔽⊢⟩𝕩
  l←u←0
  {!Int𝕩⋄l↩l⌊𝕩⋄u↩u⌈𝕩}⚇0 n
  a←𝕩⋄_p←{𝔽∘⊣`(1+𝕩)⥊<a}
  pos←F _p u ⋄ neg←F⁼_p-l
  (|⊑<⟜0⊑pos‿neg˜)⚇0 n
}


#⌜
# LAYER 5: Structural functions

⊏ ← 0⊸Select       ⊘ Select
↑ ← Prefixes       ⊘ Take
↓ ← Suffixes       ⊘ Drop
↕ ↩ ↕              ⊘ Windows
⌽ ← Reverse        ⊘ Rotate
/ ← Indices        ⊘ Replicate

_onAxes_←{
  F←𝔽
  (𝔾<≡)∘⊣◶{ # One axis
    ! 1≤≠≢𝕩
    𝕨F𝕩
  }‿{ # Multiple axes
    ! 1≥≠≢𝕨
    ! 𝕨≤○≠≢𝕩
    R←{(⊑𝕨)F(1 DropV 𝕨)⊸R˘𝕩}⍟{0<≠𝕨}
    𝕨R𝕩
  }
}

SelSub←{
  ! IsArray 𝕨
  ! ∧´⥊Int¨ 𝕨
  ! ∧´⥊ 𝕨 (≥⟜-∧<) ≠𝕩
  𝕨↩𝕨+(≠𝕩)×𝕨<0
  c←×´s←1 Cell 𝕩
  ⊑⟜(⥊𝕩)¨(c×𝕨)+⌜s⥊↕c
}
Select←ToArray⊸(SelSub _onAxes_ 1)

JoinTo←{
  s←𝕨Pair○≢𝕩
  a←1⌈´k←≠¨s
  ! ∧´1≥a-k
  c←(k¬a)+⟜(↕a-1)⊸⊏¨s
  ! ≡´c
  l←+´(a=k)⊣◶1‿(⊑⊢)¨s
  (⟨l⟩∾⊑c)⥊𝕨∾○⥊𝕩
}

Take←{
  T←{
    ! Int 𝕨
    l←≠𝕩
    i←(l+1)|¯1⌈l⌊((𝕨<0)×𝕨+l)+↕|𝕨
    i⊏JoinTo⟜(1⊸Cell⥊Type)⍟(∨´l=i)𝕩
  }
  𝕨 T _onAxes_ 0 (⟨1⟩⥊˜0⌈𝕨-○≠⊢)⊸∾∘≢⊸⥊𝕩
}
Drop←{
  s←(≠𝕨)(⊣↑⊢∾˜1⥊˜0⌈-⟜≠)≢𝕩
  ((s×¯1⋆𝕨>0)+(-s)⌈s⌊𝕨)↑𝕩
}
Prefixes ← {!1≤≠≢𝕩 ⋄ (↕1+≠𝕩)Take¨<𝕩}
Suffixes ← {!1≤≠≢𝕩 ⋄ (↕1+≠𝕩)Drop¨<𝕩}

Windows←{
  ! IsArray 𝕩
  ! 1≥≠≢𝕨
  ! 𝕨≤○≠≢𝕩
  ! ∧´Nat¨⥊𝕨
  s←(≠𝕨)↑≢𝕩
  ! ∧´𝕨≤1+s
  𝕨{(∾⟜(𝕨≠⊸↓≢𝕩)∘≢⥊>)<¨⊸⊏⟜𝕩¨s(¬+⌜○↕⊢)⥊𝕨}⍟(0<≠𝕨)𝕩
}

Reverse ← {!1≤≠≢𝕩 ⋄ (-↕⊸¬≠𝕩)⊏𝕩}
Rotate ← {!Int𝕨 ⋄ l←≠𝕩⋄(l|𝕨+↕l)⊏𝕩} _onAxes_ 0

Indices←{
  ! 1=≠≢𝕩
  ! ∧´Nat¨𝕩
  ⟨⟩∾´𝕩⥊¨↕≠𝕩
}
Rep ← Indices⊸⊏
Replicate ← {0<≠≢𝕨}◶(⥊˜⟜≠Rep⊢)‿{!𝕨=○≠𝕩⋄𝕨Rep𝕩} _onAxes_ (1-0=≠)


#⌜
# LAYER 6: Everything else

∾ ↩ Join           ⊘ JoinTo
⊔ ← ⊔⟜(↕≠⚇1)       ⊘ Group
⍉ ← Transpose      ⊘ ReorderAxes
⊐ ← !∘0            ⊘ IndexOf
∊ ← UniqueMask     ⊘ (⊐˜<≠∘⊢)
⍷ ← ∊⊸/            ⊘ Find
⍋ ←   Cmp _grade   ⊘ (  Cmp _bins)
⍒ ← -∘Cmp _grade   ⊘ (-∘Cmp _bins)
∧ ↩ ⍋⊸⊏            ⊘ ∧
∨ ↩ ⍒⊸⊏            ⊘ ∨
⊒ ← OccurrenceCount⊘ ProgressiveIndexOf

Join←{
  C←(<⟨⟩)⥊⊸∾⌜´⊢  # Cartesian array product
  ! IsArray 𝕩
  s←≢¨𝕩
  d←≠⊑s
  ! ∧´⥊d=≠¨s
  ! d≥≠≢𝕩
  l←(≢𝕩){(𝕩⊑⟜≢a⊑˜(j=𝕩)⊸×)¨↕𝕨}¨j←↕r←≠≢a←𝕩
  ! (r↑¨s)≡C l
  i←C{p←+´¨↑𝕩⋄(↕⊑⌽p)-𝕩/¯1↓p}¨l
  >i<¨⊸⊏¨l/𝕩
}⍟(0<≠∘⥊)

Group←{
  ! IsArray 𝕩
  Chk←{!1=≠≢𝕩⋄!∧´Int¨𝕩⋄!∧´¯1≤𝕩⋄≠𝕩}
  l←(1<≡)◶Chk‿{!1=≠≢𝕩⋄Chk¨𝕩}𝕨
  ! l≤○≠≢𝕩
  ! ∧´l=l≠⊸↑≢𝕩
  (𝕨⊸=/𝕩˜)¨↕1+¯1⌈´⚇1𝕨
}

# Searching
IndexOf←{
  c←1-˜≠≢𝕨
  ! 0≤c
  𝕨 (0<≠𝕨)◶⟨0⎉c∘⊢,((+´<˘)∧`)≢⎉c⎉c‿∞⟩ 𝕩
}
UniqueMask←{
  ! 1≤≠≢𝕩
  u←0↑𝕩
  {⊑𝕩∊u}⊘{u↩u∾𝕩⋄1}‿0˘𝕩
}
Find←{
  r←≠s←≢𝕨
  ! r≤≠≢𝕩
  𝕨 ≡⎉r s ↕⎉r 𝕩
}

ReorderAxes←{
  𝕩↩<⍟(0=≡)𝕩
  ! 1≥≠≢𝕨
  𝕨↩⥊𝕨
  ! 𝕨≤○≠≢𝕩
  ! ∧´Nat¨⥊𝕨
  r←(≠≢𝕩)-+´¬∊𝕨
  ! ∧´𝕨<r
  𝕨↩𝕨∾𝕨(¬∘∊˜/⊢)↕r
  (𝕨⊸⊏⊑𝕩˜)¨↕⌊´¨𝕨⊔≢𝕩
}
Transpose←(≠∘≢-1˜)⊸ReorderAxes⍟(0<≠∘≢)

# Sorting
Cmp ← ∨○IsArray◶{ # No arrays
  𝕨(>-<)𝕩 # Assume they're numbers
}‿{ # At least one array
  e←𝕨-˜○(∨´0=≢)𝕩
  𝕨(e=0)◶e‿{
    c←𝕨×∘-○(IsArray+≠∘≢)𝕩
    s←≢𝕨 ⋄ t←≢𝕩 ⋄ r←s⌊○≠t
    l←s{i←+´∧`𝕨=𝕩⋄m←×´i↑𝕨⋄{c↩×-´𝕩⋄m↩m×⌊´𝕩}∘(⊑¨⟜𝕨‿𝕩)⍟(r⊸>)i⋄m}○(r↑⌽)t
    a←⥊𝕨⋄b←⥊𝕩
    Trav←(=⟜l)◶{Trav∘(1+𝕩)⍟(0⊸=)a Cmp○(𝕩⊸⊑)b}‿c
    Trav 0
  }𝕩
}

_grade←{
  ! 1≤≠≢𝕩
  i⊐˜+´˘(𝔽⎉∞‿¯1⎉¯1‿∞˜𝕩)(⌈⟜0+=⟜0⊸×)>⌜˜i←↕≠𝕩
}
_bins←{
  c←1-˜≠≢𝕨
  ! 0≤c
  LE←𝔽⎉c≤0˜
  ! (0<≠)◶⟨1,∧´·LE´˘2↕<˘⟩𝕨
  𝕨 (0<≠𝕨)◶⟨0⎉c∘⊢,(+´<˘)LE⎉¯1‿∞⟩ 𝕩
}

OccurrenceCount ← ⊐˜(⊢-⊏)⍋∘⍋
ProgressiveIndexOf ← {𝕨⊐○(≍˘⟜OccurrenceCount𝕨⊸⊐)𝕩}
