# This file gives reference implementations of BQN primitives assuming
# limited initial functionality. Implementations are designed to be
# simple and not fast.

# In some cases an operation is defined with limited functionality at
# first and later expanded. For convenience, rather than renaming these
# limited versions, every primitive use refers to the most recent
# definition in source code, as if redefinitions shadowed previous
# primitive definitions.


#⌜
# LAYER 0: Assumed functionality

# IEEE 754, except NaN results cause an error and -0 is converted to 0.
# LIMITED to the stated cases and atomic arguments.
+          #                Add
-          # Negate         Subtract
×          #                Multiply
÷          # Reciprocal     Divide
⋆          # Exponential    Power
⌊          # Floor
=          #                Equals
≤          #                Less Than or Equal to

# Other basic functionality that we need to assume
Type       # 0 if 𝕩 is an array, 1 if a number, >1 otherwise
!          # 𝕩 is 0 or 1; throw an error if it's 0
≢          # LIMITED to monadic case
⥊          # LIMITED to array 𝕩 and (×´𝕨)≡≢𝕩
⊑          # LIMITED to natural number 𝕨 and list 𝕩
_amend     # {𝕨˙⌾(𝕗⊸⊑)𝕩}
↕          # LIMITED to number 𝕩
Identity   # Left or right identity of function 𝕏
⁼          # Inverse of function 𝔽
Fill       # Enclosed fill value for 𝕩


#⌜
# LAYER 1: Foundational operators and functions

# Combinators
◶ ← {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}     # LIMITED to number left operand result
˙ ← {𝕩⋄𝕗}
⊘ ← {𝕨((1˙𝕨)-0)◶𝔽‿𝔾 𝕩}
⊢ ← {𝕩}
⊣ ← {𝕩}⊘{𝕨}
˜ ← {𝕩𝔽𝕨⊣𝕩}
∘ ← {𝔽𝕨𝔾𝕩}
○ ← {(𝔾𝕨)𝔽𝔾𝕩}
⊸ ← {(𝔽𝕨⊣𝕩)𝔾𝕩}
⟜ ← {(𝕨⊣𝕩)𝔽𝔾𝕩}
⍟ ← {𝕨𝔾◶⊢‿𝔽𝕩}   # LIMITED to boolean right operand result

IsArray←0=Type
Int←(1=Type)◶⟨0,⌊⊸=⟩
Nat←(1=Type)◶⟨0,0⊸≤×⌊⊸=⟩

≢ ↩ IsArray◶⟨⟩‿≢  # LIMITED to monadic case

# LIMITED to numeric arguments for arithmetic cases
√ ← ⋆⟜(÷2)   ⊘ (⋆⟜÷˜)
∧ ←            ×
∨ ←            (+-×)
¬ ← 1+-
| ← ×⟜×      ⊘ {𝕩-𝕨×⌊𝕩÷𝕨}
< ← {⟨⟩⥊⟨𝕩⟩} ⊘ (¬≤˜)
> ←            (¬≤)
≥ ← !∘0      ⊘ (≤˜)
≠ ← Length   ⊘ (¬=)
= ↩ Rank     ⊘ =
× ↩ 0⊸(<->)  ⊘ ×
⌊ ↩ ⌊        ⊘ {𝕨{(𝕨>𝕩)⊑𝕨‿𝕩}_perv𝕩}
⌈ ← -∘⌊∘-    ⊘ {𝕨{(𝕨<𝕩)⊑𝕨‿𝕩}_perv𝕩}

¨ ← _eachm   # LIMITED to monadic case and array 𝕩
´ ← _fold

Rank ← 0⊑≢∘≢
Length ← (0<Rank)◶⟨1⋄0⊑≢⟩

_eachm←{
  r←⥊𝕩 ⋄ F←𝔽
  E←(≠r)⊸≤◶{r↩r𝕩_amend˜F𝕩⊑r⋄E𝕩+1}‿⊢
  E 0 ⋄ (≢𝕩)⥊r
}
{ Identity ↩ 𝕨˙⊸=◶Identity‿𝕩 }´¨ ⟨
  ×‿1, ¬‿1
  ⌊‿∞ , ⌈‿¯∞
  ∨‿0 , ∧‿1
  ≠‿0 , =‿1
  >‿0 , ≥‿1
⟩
_fold←{
  ! 1==𝕩
  l←≠v←𝕩 ⋄ F←𝔽
  r←𝕨 (0<l)◶{𝕩⋄Identity f}‿{l↩l-1⋄l⊑𝕩}⊘⊣ 𝕩
  {r↩(𝕩⊑v)F r}¨(l-1)⊸-¨↕l
  r
}


#⌜
# LAYER 2: Pervasion
# After defining _perv, we apply it to all arithmetic functions,
# making them pervasive. I'm not going to write that out.

ToArray ← IsArray◶<‿⊢

∾ ← {k←≠𝕨⋄k⊸≤◶⟨⊑⟜𝕨⋄-⟜k⊑𝕩˜⟩¨↕k+≠𝕩}  # LIMITED to two list arguments

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
    q⥊⥊(≠a) (⊑⟜a𝔽l⊸×⊸+⊑b˙)_table○↕ l
  }
  (>○=)◶⟨𝔽_e⋄𝔽˜_e˜⟩
}

⌜ ← {(𝔽_eachm)⊘(𝔽_table)○ToArray}
¨ ↩ {(𝔽_eachm)⊘(𝔽_eachd)○ToArray}
_perv←{ # Pervasion
  (⊢⊘∨○IsArray)◶⟨𝔽⋄𝔽{𝕨𝔽_perv𝕩}¨⟩
}


#⌜
# LAYER 3: Remove other limits
# Now all implementations are full except ∾; ↕ is monadic only

Deshape←IsArray◶{⟨𝕩⟩}‿⥊
Reshape←{
  ! 1≥=𝕨
  s←Deshape 𝕨
  sp←+´p←¬Nat⌜s
  ! 1≥sp
  n←≠d←Deshape 𝕩
  l←sp◶(×´)‿{
    lp←×´p⊣◶⊢‿1¨𝕩
    ! 0<lp
    I←+´↕∘≠⊸×
    t←I e←⟨∘,⌊,⌽,↑⟩=(I p)⊑s
    ! +´e
    a←(2⌊t)◶⟨{!Nat𝕩⋄𝕩},⌊,⌈⟩n÷lp
    s↩p⊣◶⊢‿a¨s
    {d∾↩(Fill d)⌜↕𝕩-n⋄n↩𝕩}⍟(n⊸<)⍟(3=t)lp×a
  } s
  s⥊(↕l){!0<n⋄⊑⟜𝕩¨n|𝕨}⍟(l≠n)d
}

Range←{
  I←{!Nat𝕩⋄↕𝕩}
  M←{!1==𝕩⋄(<⟨⟩)⥊⊸∾⌜´I¨𝕩}
  IsArray◶I‿M 𝕩
}

Pick1←{
  ! 1==𝕨
  ! 𝕨=○≠s←≢𝕩
  ! ∧´Int¨𝕨
  ! ∧´𝕨(≥⟜-∧<)s
  𝕨↩𝕨+s×𝕨<0
  (⥊𝕩)⊑˜0(⊑⟜𝕨+⊑⟜s×⊢)´-↕⊸¬≠𝕨
}
Pickd←(∨´∘⥊IsArray¨∘⊣)◶Pick1‿{Pickd⟜𝕩¨𝕨}
Pick←IsArray◶⥊‿⊢⊸Pickd
First←(0<≠)◶⟨!∘0,0⊸⊑⟩∘Deshape

match←{¬∘(0⊑𝕨)◶(1⊑𝕨)‿𝕩}´⟨
  ⟨≠○IsArray , 0⟩
  ⟨¬IsArray∘⊢, =⟩
  ⟨≠○=       , 0⟩
  ⟨∨´≠○≢     , 0⟩
  {∧´⥊𝕨Match¨𝕩}
⟩

Depth←IsArray◶0‿{1+0⌈´Depth¨⥊𝕩}

⊑ ↩ First          ⊘ Pick
⥊ ↩ Deshape        ⊘ Reshape
↕ ↩ Range
◶ ↩ {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}  # Same definition, new Pick

≡ ← Depth          ⊘ Match
≢ ↩ ≢              ⊘ (¬Match)


#⌜
# LAYER 4: Operators

> ↩ Merge⍟IsArray  ⊘ >
⋈ ← {⟨𝕩⟩} ⊘ {⟨𝕨,𝕩⟩}
≍ ← >∘⋈
⎉ ← _rankOp_
⚇ ← _depthOp_
⍟ ↩ _repeat_
˘ ← {𝔽⎉¯1}
˝ ← _insert
` ← _scan

DropV← {⊑⟜𝕩¨𝕨+↕𝕨-˜≠𝕩}
Cell ← DropV⟜≢

Merge←(0<≠∘⥊)◶((∾○≢⥊⊢)⟜Fill)‿{
  c←≢⊑𝕩
  ! ∧´⥊(c≡≢)¨𝕩
  𝕩⊑⟜ToArray˜⌜↕c
}
ValidateRanks←{
  ! 1≥=𝕩
  𝕩↩⥊𝕩
  ! (1⊸≤∧≤⟜3)≠𝕩
  ! ∧´Int¨𝕩
  𝕩
}
_ranks ← {⟨2⟩⊘⟨1,0⟩ ((⊣-1+|)˜⟜≠⊑¨<∘⊢) ValidateRanks∘𝔽}
_depthOp_←{
  neg←0>n←𝕨𝔾_ranks𝕩 ⋄ F←𝔽 ⋄ B←{𝕏}⊘{𝕨˙⊸𝕏}
  _d←{
    R←(𝕗+neg)_d
    𝕨(2⥊(neg∧𝕗≥0)∨(0⌈𝕗)≥⋈○≡)◶(⟨R¨⋄R⟜(𝕩˙)¨∘⊣⟩≍⟨(𝕨 B r)¨∘⊢⋄F⟩)𝕩
  }
  𝕨 n _d 𝕩
}
_rankOp_←{
  k←𝕨(⋈○= (0≤⊢)◶⟨⌊⟜-,0⌈-⟩¨ 𝔾_ranks)𝕩
  Enc←{
    f←⊑⟜(≢𝕩)¨↕𝕨
    c←×´s←𝕨Cell𝕩
    f⥊⊑⟜(⥊𝕩)¨∘((s⥊↕c)+c×⊢)¨↕×´f
  }
  Enc↩(>⟜0×1+≥⟜=)◶⟨<⊢,Enc,<⌜⊢⟩
  > ((⊑k)Enc𝕨) 𝔽¨ ((1-˜≠)⊸⊑k)Enc𝕩
}
_insert←{
  ! 1≤=𝕩
  𝕨 𝔽´ <˘𝕩
}
_scan←{
  ! IsArray 𝕩
  ! 1≤=𝕩
  F←𝔽
  cs←1 Cell 𝕩
  ! (cs≡≢)𝕨
  l←≠r←⥊𝕩
  𝕨 (0<l)◶⊢‿{
    c←×´cs
    {r↩≥⟜c◶⟨⊑⟜(⥊𝕩)⊸F⋄⊢⟩⟜(⊑⟜r)¨↕l}𝕨
    {r↩r𝕩_amend˜𝕨F○(⊑⟜r)𝕩}⟜(c⊸+)¨↕l-c
    (≢𝕩)⥊r
  } 𝕩
}
_repeat_←{
  n←𝕨𝔾𝕩
  f←⊑𝕨⟨𝔽⟩⊘⟨𝕨𝔽⊢⟩𝕩
  l←u←0
  {!Int𝕩⋄l↩l⌊𝕩⋄u↩u⌈𝕩}⚇0 n
  b←𝕨{𝕏⊣}˙⊘{𝕨˙{𝔽𝕏⊣}}0
  i←⟨𝕩⟩⋄P←B⊸{𝕎`i∾↕𝕩}
  pos←𝕗 P u
  neg←𝕗 0⊸<◶⟨i,{𝕏⁼}⊸P⟩ -l
  (|⊑<⟜0⊑pos‿neg˙)⚇0 n
}


#⌜
# LAYER 5: Structural functions

⊏ ← 0⊸Select       ⊘ Select
↑ ← Prefixes       ⊘ Take
↓ ← Suffixes       ⊘ Drop
↕ ↩ ↕              ⊘ Windows
» ← Nudge          ⊘ ShiftBefore
« ← NudgeBack      ⊘ ShiftAfter
⌽ ← Reverse        ⊘ Rotate
/ ← Indices        ⊘ Replicate

_onAxes_←{
  F←𝔽
  (𝔾<≡)∘⊣◶{ # One axis
    ! 1≤=𝕩
    𝕨F𝕩
  }‿{ # Multiple axes
    ! 1≥=𝕨
    ! 𝕨≤○≠≢𝕩
    R←{(⊑𝕨)F(1 DropV 𝕨)⊸R˘𝕩}⍟{0<≠𝕨}
    𝕨R𝕩
  }⟜ToArray
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
  s←𝕨⋈○≢𝕩
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
    i⊏JoinTo⟜(1⊸Cell⥊Fill)⍟(∨´l=i)𝕩
  }
  𝕨 T _onAxes_ 0 (⟨1⟩⥊˜0⌈𝕨-○≠⊢)⊸∾∘≢⊸⥊𝕩
}
Drop←{
  s←(≠𝕨)(⊣↑⊢∾˜1⥊˜0⌈-⟜≠)≢𝕩
  ((s×¯1⋆𝕨>0)+(-s)⌈s⌊𝕨)↑𝕩
}
Prefixes ← {!1≤=𝕩 ⋄ (↕1+≠𝕩)Take¨<𝕩}
Suffixes ← {!1≤=𝕩 ⋄ (↕1+≠𝕩)Drop¨<𝕩}

ShiftBefore ← {!𝕨1⊸⌈⊸≤○=𝕩 ⋄ ( ≠𝕩) ↑ 𝕨 JoinTo 𝕩}
ShiftAfter  ← {!𝕨1⊸⌈⊸≤○=𝕩 ⋄ (-≠𝕩) ↑ 𝕩 JoinTo 𝕨}
Nudge     ← (1↑0↑⊢)⊸ShiftBefore
NudgeBack ← (1↑0↑⊢)⊸ShiftAfter

Windows←{
  ! 1≥=𝕨
  ! 𝕨≤○≠≢𝕩
  ! ∧´Nat¨⥊𝕨
  s←(≠𝕨)↑≢𝕩
  ! ∧´𝕨≤1+s
  𝕨{(∾⟜(𝕨≠⊸↓≢𝕩)∘≢⥊>)<¨⊸⊏⟜𝕩¨s(¬+⌜○↕⊢)⥊𝕨}⍟(0<≠𝕨)𝕩
}

Reverse ← {!1≤=𝕩 ⋄ (-↕⊸¬≠𝕩)⊏𝕩}
Rotate ← {!Int𝕨 ⋄ l←≠𝕩⋄(l|𝕨+↕l)⊏𝕩} _onAxes_ 0

Indices←{
  ! 1==𝕩
  ! ∧´Nat¨𝕩
  ⟨⟩∾´𝕩⥊¨↕≠𝕩
}
Rep ← Indices⊸⊏
Replicate ← {0<=𝕨}◶(⥊˜⟜≠Rep⊢)‿{!𝕨=○≠𝕩⋄𝕨Rep𝕩} _onAxes_ (1-0=≠)


#⌜
# LAYER 6: Everything else

∾ ↩ Join           ⊘ JoinTo
⊔ ← GroupInds      ⊘ Group
⍉ ← Transpose      ⊘ ReorderAxes
∊ ← MarkFirst      ⊘ (IndexOf˜<≠∘⊢)
⍷ ← ∊⊸/            ⊘ Find
⊐ ← ⍷⊸IndexOf      ⊘ IndexOf
⍋ ←   Cmp _grade   ⊘ (  Cmp _bins)
⍒ ← -∘Cmp _grade   ⊘ (-∘Cmp _bins)
∧ ↩ ⍋⊸⊏            ⊘ ∧
∨ ↩ ⍒⊸⊏            ⊘ ∨
⊒ ← OccurrenceCount⊘ ProgressiveIndexOf

{ Identity ↩ 𝕨˙⊸=◶Identity‿𝕩 }´¨ ⟨ ∨‿0 , ∧‿1 ⟩

JoinEmpty ← ({!𝕨≤○≠𝕩⋄𝕨≠⊸((𝕨×≠⊸↑)∾↓)𝕩}○≢⥊⊢)⟜Fill

Join←(0<≠∘⥊)◶⟨JoinEmpty, (0<=)◶{!IsArray𝕩⋄>𝕩}‿{
  ! IsArray 𝕩
  s←≢¨𝕩
  a←(≢𝕩){(s⊑˜(j=𝕩)⊸×)¨↕𝕨}¨j←↕r←=𝕩
  h←(¬⟜(⌈´)≠¨)¨a
  ! ∧´∧´¨0≤h
  o←+`⊑¨h
  t←(¯1⊑o)↓⊑s
  l←h{𝕎𝕩}¨˜(»o){⊣◶⟨1,𝕨⊸⊑⟩¨⟜𝕩}¨a
  ! s≡(<t)∾⌜´h⥊¨¨l
  i←(<⟨⟩)∾⌜´h{((↕¯1⊸⊑)-𝕩/𝕨⥊¨»)+`𝕩}¨l
  >i<¨⊸⊏⍟(0<≠∘⊣)¨l/𝕩
}⟩

Group←{
  ! IsArray 𝕩
  𝕨↩⋈∘ToArray⍟(2>≡)𝕨
  ! 1==𝕨
  {!∧´Int¨𝕩⋄!∧´¯1≤𝕩}∘⥊¨𝕨
  n←+´r←=¨𝕨
  ! n≤=𝕩
  ld←(∾≢⌜𝕨)-n↑≢𝕩
  ! ∧´(0⊸≤∧≤⟜(r/1=r))ld
  dr←r⌊(0»+`r)⊏ld∾⟨0⟩
  s←dr⊣◶⟨0,¯1⊸⊑⟩¨𝕨
  𝕨↩dr(⥊¯1⊸↓⍟⊣)¨𝕨
  s⌈↩1+¯1⌈´¨𝕨
  𝕩↩((≠¨𝕨)∾n↓≢𝕩)⥊𝕩
  (𝕨⊸=/𝕩˙)¨↕s
}
GroupInds←{
  ! 1==𝕩
  𝕩 ⊔ ↕ (1<≡)◶≠‿(∾≢¨) 𝕩
}

# Searching
IndexOf←{
  c←1-˜=𝕨
  ! 0≤c
  ! c≤=𝕩
  𝕨 ∧○(0<≠)⟜⥊◶⟨0⥊˜c-⊸↓≢∘⊢, (+˝∧`)≢⎉c⎉c‿∞⟩ ToArray 𝕩
}
MarkFirst←{
  ! 1≤=𝕩
  u←0↑𝕩
  (0<≠)◶⟨⟨⟩,{⊑𝕩∊u}◶{u↩u∾𝕩⋄1}‿0˘⟩𝕩
}
Find←{
  r←=𝕨
  ! r≤=𝕩
  𝕨 ≡⎉r ((1+r-⊸↑≢𝕩)⌊≢𝕨)⊸↕⎉r 𝕩
}○ToArray

ReorderAxes←{
  𝕩↩<⍟(0=≡)𝕩
  ! 1≥=𝕨
  𝕨↩⥊𝕨
  ! 𝕨≤○≠≢𝕩
  ! ∧´Nat¨⥊𝕨
  r←(=𝕩)-+´¬∊𝕨
  ! ∧´𝕨<r
  𝕨↩𝕨∾𝕨(¬∘∊˜/⊢)↕r
  (𝕨⊸⊏⊑𝕩˙)¨↕⌊´¨𝕨⊔≢𝕩
}
Transpose←(0<=)◶⟨ToArray,(=-1˙)⊸ReorderAxes⟩

# Sorting
Cmp ← ⌈○IsArray◶{ # No arrays
  𝕨(>-<)𝕩 # Assume they're numbers
}‿{ # At least one array
  e←𝕨-˜○(∨´0=≢)𝕩
  𝕨(e=0)◶e‿{
    c←𝕨×∘-○(IsArray+=)𝕩
    s←≢𝕨 ⋄ t←≢𝕩 ⋄ r←𝕨⌊○=𝕩
    l←s{i←+´∧`𝕨=𝕩⋄m←×´i↑𝕨⋄{c↩×-´𝕩⋄m↩m×⌊´𝕩}∘(⊑¨⟜𝕨‿𝕩)⍟(r⊸>)i⋄m}○(r↑⌽)t
    a←⥊𝕨⋄b←⥊𝕩
    Trav←(=⟜l)◶{Trav∘(1+𝕩)⍟(0⊸=)a Cmp○(𝕩⊸⊑)b}‿c
    Trav 0
  }𝕩
}

_grade←{
  ! 1≤=𝕩
  i⊐˜+´˘(𝔽⎉∞‿¯1⎉¯1‿∞˜𝕩)(⌈⟜0+=⟜0⊸×)>⌜˜i←↕≠𝕩
}
_bins←{
  c←1-˜=𝕨
  ! 0≤c
  ! c≤=𝕩
  LE←𝔽⎉c≤0˜
  ! (0<≠)◶⟨1,∧´·LE˝˘2↕⊢⟩𝕨
  𝕨 (0<≠𝕨)◶⟨0⎉c∘⊢,+˝LE⎉¯1‿∞⟩ 𝕩
}

OccurrenceCount ← ⊐˜(⊢-⊏)⍋∘⍋
ProgressiveIndexOf ← {𝕨⊐○(((≢∾2˙)⥊≍˘⟜OccurrenceCount∘⥊)𝕨⊸⊐)𝕩}
