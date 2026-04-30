# BQN runtime part 1. Requires:
#   Type Fill Log GroupLen GroupOrd _fillBy_
#   +-×÷⋆⌊⌈|<>=≠≤≥≢⊢⊣⥊∾⋈↑↓↕⊏⊑!⌜˙˜¨´`∘○⊸⟜◶⊘⍟
# Filled in by runtime: glyphs and default PrimInd
# Provides: all BQN primitives

Ind1 ← { 0 Fill +`(0⌈≠-1˙)⊸↑GroupLen+`𝕩 }
/ ← Ind1 ⊘ (Ind1⊸⊏)  # LIMITED to natural number list 𝕩/𝕨

Decompose ← {0‿𝕩}
PrimInd ← {𝕩}
SetPrims ← {Decompose‿PrimInd ↩ 𝕩}
SetInv   ← {{swapInverse 𝕏↩}𝕨 ⋄ inverse 𝕏↩}

IsArray ← 0=Type
IsAtom  ← 1≤Type
Int ← (1=Type)◶⟨0,⌊⊸=⟩
Nat ← (1=Type)◶⟨0,|∘⌊⊸=⟩
ToArray ← <⍟IsAtom
IsSimple ← 1×´IsAtom⌜
Deshape ← IsArray◶{𝕩Fill⟨𝕩⟩}‿⥊
Cell ← ↓⟜≢
MatchS ← 1×´=¨
PermInv ← 1⌜⊸GroupOrd

_qSearch ← {+´·×`𝕗(1-=)⌜<}
_glyphLookup_ ← {
  {PrimInd𝕩} ⊑ ((𝕘⊑˜𝕗_qSearch)⌜glyphs)˙
}
_isGlyph ← { (glyphs _qSearch 𝕗) = {PrimInd𝕩} }
IsJoin ← '∾'_isGlyph
IsTable ← '⌜'_isGlyph
DIsConst ← (4=0⊸⊑)◶0‿('˙'_isGlyph 2⊸⊑)

Split2 ← { s←2⊸×⌜↕(≠𝕩)÷2 ⋄ ⟨s⊏𝕩,(1⊸+⌜s)⊏𝕩⟩ }
_lookup_ ← {
  k‿v←Split2 𝕘 ⋄ k _glyphLookup_ (v∾⟨𝕗⟩)
}
ScalId ← @ _lookup_ ⟨
  '+',0 , '-',0
  '×',1 , '÷',1
  '⋆',1 , '¬',1
  '⌊',∞ , '⌈',¯∞
  '∨',0 , '∧',1
  '≠',0 , '=',1
  '>',0 , '≥',1
⟩
TabId ← {
  id ← (4=0⊸⊑)◶⟨0,(IsTable 2⊸⊑)⟩◶⟨@,ScalId 1⊸⊑⟩ Decompose 𝕩
  "´: Identity not found" ! @>id ⋄ <id
}
Identity ← { 𝕨 @⊸=◶⟨⊢⊘Reshape,TabId𝕩˙⟩ ScalId𝕩 }

_fold←{
  "´: 𝕩 must be a list" ! 1==𝕩
  𝕨 (0<≠)⊘1◶⟨Identity 𝕗˙, 𝔽´⟩ 𝕩
}

_eachd←{
  _d←{ # Equal ranks
    "Mapping: Equal-rank argument shapes don't agree" ! 𝕨 MatchS○≢ 𝕩
    𝕨𝔽¨𝕩
  }
  _e←{ # 𝕨 has smaller or equal rank
    p←≢𝕨 ⋄ k←=𝕨 ⋄ q←≢𝕩
    "Mapping: Argument shape prefixes don't agree" ! p MatchS k↑q
    l←1×´k↓q
    m←≠a←⥊𝕨 ⋄ b←⥊𝕩
    q⥊m (⊑⟜a𝔽l⊸×⊸+⊑b˙)⌜○↕ l×m>0
  }
  =○=◶⟨>○=◶⟨𝔽_e⋄𝔽˜_e˜⟩⋄𝔽_d⟩
}

_perv←{ # Pervasion
  R←+○IsArray◶⟨
    𝔽
    {R⌜𝕩}⊘(>○IsArray◶{𝕨˙⊸R⌜𝕩}‿{R⟜(𝕩˙)⌜𝕨}) _fillBy_ {𝕨R𝕩}
    {𝕨R _eachd𝕩} _fillBy_ {𝕨(3≤Type𝕨)◶R‿⊣𝕩}  # Function 𝕨 may indicate no fill
  ⟩
}

# Sorting
CLE ← (<⟜@≤·=˜⊢)≤≤  # Place NaNs after other numbers
Cmp0 ← CLE˜-CLE
Cmp1 ← (0<1×´≢∘⊢)◶⟨1, IsArray∘⊢◶(1-2×≤)‿{𝕨Cmp1𝕩}⟜(0⊑⥊)⟩
CmpLen ← {
  ed←-´e←𝕨⋈○(1×´0⊸<⌜)𝕩
  𝕨(ed=0)◶⟨ed,0⟩‿{
    SM←Cmp0 ⋈ ≥⊑⋈
    c‿r←𝕨SM○≠𝕩
    l←𝕨{
      i←0+´×`𝕨=¨𝕩
      m←(×´e)×´i↕⊸⊏𝕨
      {k‿l←SM´𝕩⋄c↩k⋄m×↩l}∘(<⊑⌜𝕨‿𝕩˙)⍟(r⊸>)i
      m
    }○{𝕩⊏˜(¯1+≠𝕩)⊸-⌜↕r}𝕩
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
  cmps ← {𝕏˜}⌜⍟𝕗⟨Cmp,Cmp0,Cmp≤0˙,CLE⟩
  _getC_ ← { 𝕨 𝕘{(𝕨 𝕏 _getCellCmp 𝕗)≤0˙}⍟(𝕩≤1) 𝔽 𝕩⊑cmps }
  0 Fill {
    "⍋𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
    l←≠𝕩
    (2≤l)◶⟨↕∘l,{
      m1←1=m←1×´1 Cell 𝕩
      𝕩↩⥊𝕩
      a0←1⋄ts←0⋄{a0×↩1≤𝕩⋄ts+↩𝕩}∘Type⌜𝕩
      cs←a0+2×m1
      Merge ← { # Merge sort
        le ← 𝕩{𝕏○(⊑⟜𝕗)} _getC_ m cs
        B←l⊸≤◶⊢‿l
        (↕l){
          i←-d←𝕨 ⋄ j←ei←ej←0
          e←3 ⋄ G←LE○(⊑⟜(m⊸×⌜⍟(1-m1)𝕩)) ⋄ c←⟨1-G,0,1,2⟩
          s←(8≤d)⊑⟨+,{(𝕩-1){e↩2⋄j↩i⋄i↩𝕩}⍟G⍟(1-e)𝕩}⟩
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
  }⊘{
    cx←(=𝕩)-c←1-˜=𝕨
    "⍋ or ⍒: Rank of 𝕨 must be at least 1" ! 0≤c
    "⍋ or ⍒: Rank of 𝕩 must be at least cell rank of 𝕨" ! 0≤cx
    sw←1 Cell 𝕨 ⋄ nw←≠𝕨
    𝕩↩ToArray𝕩 ⋄ sx←cx Cell 𝕩 ⋄ lz←1×´sz←cx↑≢𝕩
    sz ⥊ 𝕨 (0<nw)◶{𝕩⋄0⌜↕lz}‿{
      a0w←IsSimple𝕨 ⋄ Gw←⊑⟜𝕨 ⋄ lw←1×´sw
      lew←{𝕏○Gw} _getC_ lw a0w+2×1=lw
      "⍋ or ⍒: 𝕨 must be sorted" ! 1×´LEw⟜(lw⊸+)∘(lw⊸×)⌜↕nw-1
      a0←IsSimple∘𝕩⊸×⍟⊢a0w ⋄ Gx←⊑⟜𝕩
      cd‿lc←sw CmpLen sx
      le ← cd {Gw⊸𝕏⟜Gx}_getC_ lc a0+2×1=lc
      B←lw⊸×⊸LE
      BinSearch ← {
        Bx ← B⟜𝕩
        R ← {a←Bx m←𝕩+h←⌊𝕨÷2⋄(h+a×𝕨-2×h)R a⊑𝕩‿m}⍟(>⟜1)
        1 + (nw+1) R ¯1
      }
      (BinSearch (1×´sx)⊸×)⌜ ↕lz
    }○⥊ 𝕩
  }
}

⍋ ← 0 _grade
⍒ ← 1 _grade

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
    sh ⥊ 𝕨 (e←0<n×k)◶⟨0,s MatchS cx⊸Cell⟩◶{𝕩⋄(ind◶⟨n⊸>,⊢⟩ n×e)⌜↕lx}‿{
      cc ← (⊑⟜(⥊𝕨))⊸(1-Match)⟜(⊑⟜(⥊𝕩)) _getCellCmp k
      𝕨 ×○(8<≠∘⥊)◶{𝕩
        i‿j←(k⊸×⌜↕)⌜n‿lx ⋄ {Red CC⟜𝕩⌜i}⌜j
      }‿{
        g←Reverse⍒𝕨
        i←g⊏˜(0⌈-⟜1)⌜⥊(g⊏𝕨)⍋𝕩
        adj←ind⊑⟨1⊸-,⊣--⟜n⊸×⟩
        i(⊣ Adj CC○(k⊸×))¨↕lx
      } 𝕩
    } 𝕩
  }⟜ToArray
}
_self←{
  "∊𝕩 or ⊐𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  g←⍋𝕩
  k←1×´1 Cell 𝕩
  cc ← (1-Match)○(⊑⟜(⥊𝕩)) _getCellCmp k
  0 Fill (PermInv g) ⊏ g 𝔽 0⊸<◶⟨1, -⟜1 CC○(⊑⟜(k⊸×⌜g)) ⊢⟩⌜↕≠𝕩
}

Find←{
  r←=𝕨 ⋄ d←(=𝕩)-r
  "𝕨⍷𝕩: Rank of 𝕨 cannot exceed rank of 𝕩" ! 0≤d
  i←<0 ⋄ j←⥊⟜(↕1×´⊢)d↑s←≢𝕩
  (≢𝕨) { A←×⟜𝕩⌜⊸(+⌜)⟜↕ ⋄ i A↩𝕨 ⋄ j A↩0⌈1+𝕩-𝕨 }¨ d↓s
  0 Fill (𝕨 Match (⥊𝕩)⊏˜i+⌜<)⌜ j
}○ToArray

Indices←{
  "/𝕩: 𝕩 must have rank 1" ! 1==𝕩
  "/𝕩: 𝕩 must consist of natural numbers" ! 1×´Nat⌜𝕩
  / 𝕩
}
IndicesInv←{
  IA 1==𝕩
  IA 1×´Nat⌜𝕩
  GroupLen 𝕩
}
SelfClas ← (PermInv∘⍋∘/˜⊏˜¯1+`⊢) _self
OccurrenceCount ← ↕∘≠⊸(⊣-¨·⌈`×¨) _self

Transpose←(1<=)◶⟨ToArray,{
  l←≠𝕩 ⋄ m←1×´c←1 Cell 𝕩
  (⥊𝕩)⊏˜(c⥊↕m)+⟜(m⊸×)⌜↕l
}_fillBy_⊢⟩
TransposeInv←{
  r←1-˜=𝕩 ⋄ s←≢𝕩 ⋄ l←r⊑s ⋄ c←r↑s
  (⥊𝕩)⊏˜(↕l)+⟜(l⊸×)⌜c⥊↕1×´c
}_fillBy_⊢⍟{IX IsArray𝕩⋄1<=𝕩}

_reorderAxesSub_←{
  "𝕨⍉𝕩: 𝕨 must have rank at most 1" ! 1≥=𝕨
  𝕨↩Deshape𝕨 ⋄ 𝕩↩ToArray𝕩
  "𝕨⍉𝕩: Length of 𝕨 must not exceed rank of 𝕩" ! (≠𝕨)≤r←=𝕩
  "𝕨⍉𝕩: 𝕨 must consist of valid axis indices" ! 1∧´(Nat∧<⟜r)⌜𝕨
  r𝔽↩n←GroupLen𝕨
  k←≠a←𝔾 𝕨∾/0⊸=⌜n
  c‿d←k(↑⋈↓)≢𝕩
  l‿s←a⊸Group1⌜⋈⟜Stride c
  (⌊´⌜l) (0<≠∘⊢)◶⟨∾⟜d⊸⥊,((<0)+⌜´s(<+´)⊸(×⌜)⟜↕¨⊣)⊏(⟨1×´c⟩∾d)⥊⊢⟩ ⥊𝕩
}
HandleDupAxes←{
  r←𝕨-0+´(0⌈-⟜1)⌜𝕩
  "𝕨⍉𝕩: Skipped result axis" ! (≠𝕩)≤r
  r
}
ReorderAxes ← HandleDupAxes _reorderAxesSub_ ⊢
ReorderAxesInv ← {IA 1≥0⌈´𝕩⋄𝕨} _reorderAxesSub_ PermInv

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
  EI‿er←𝕩 ⋄ _cr←{⊢⊣er!𝔽}
  0⊸≤◶⟨0⊸≤_cr+, >_cr⟩ ⊣ EI∘⊢
}⌜⟨
  ⟨"𝕨⊑𝕩: Indices in 𝕨 must consist of integers"!Int,"𝕨⊑𝕩: Index out of range"⟩
  ⟨"𝕨⊏𝕩: Indices in 𝕨 must be integers"!⌊⊸=,"𝕨⊏𝕩: Indices out of range"⟩
⟩
Pick0←{
  "𝕨⊑𝕩: 𝕩 must be a list when 𝕨 is a number" ! 1==𝕩
  𝕩⊑˜(≠𝕩)NormIndP𝕨
}
Pick1←{
  "𝕨⊑𝕩: Indices in compound 𝕨 must be lists" ! 1==𝕨
  "𝕨⊑𝕩: Index length in 𝕨 must match rank of 𝕩" ! 𝕨=○≠s←≢𝕩
  i←0⋄𝕨{i↩(𝕩NormIndP𝕨)+𝕩×i}¨s
  i⊑⥊𝕩
}⟜ToArray
Pickd←IsArray◶⟨1,IsSimple⥊⟩∘⊣◶{Pickd⟜𝕩⌜𝕨}‿Pick1
Pick←IsArray∘⊣◶Pick0‿Pickd

_multiAxis←{
  gl‿Test‿d1‿aa‿Single‿Ind ← 𝕗
  pre ← "𝕨"∾gl∾"𝕩: "
  es ← pre∾"𝕩 must have rank at least 1 for simple 𝕨"
  er ← pre∾"Compound 𝕨 must have rank at most 1"
  el ← pre∾"Length of compound 𝕨 must be at most rank of 𝕩"
  et ← pre∾"𝕨 must be an array of numbers or list of such arrays"
  tt ← d1 ⊑ ⟨⊢ , et ! 1×´·⥊IsArray◶⟨aa,1×´·⥊(1=Type)⌜⟩⌜ ⟩
  Test∘⊣◶{ # Multiple axes
    er ! 1≥=𝕨 ⋄ TT 𝕨
    l←≠𝕨↩⥊𝕨 ⋄ el ! l≤=𝕩
    i←𝕨Ind¨p←l↑s←≢𝕩
    j←i (0<1×´≠∘⥊⌜i)◶⟨{⟨⟩⥊˜Join1≢⌜𝕨}, {j←<0⋄𝕨{j↩(j×⌜<𝕩)+⌜𝕨}¨𝕩⋄j}⟩ p
    j ⊏ (⟨1×´p⟩∾l↓s)⥊𝕩
  }‿{
    es ! 1≤=𝕩
    𝕨 Single 𝕩
  }
}

FirstCell←{
  "⊏𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  "⊏𝕩: 𝕩 cannot have length 0" ! 0<≠𝕩
  (<0) ⊏ 𝕩
}
Select ← ⟨"⊏"
  1×´·(1=Type)⌜⥊ ⋄ 1,0
  {(≠𝕩)⊸NormIndS⌜𝕨} ⊏ ⊢
  {𝕩⊸NormIndS⌜𝕨}
⟩_multiAxis○ToArray
First ← IsArray◶⟨⊢, (0<≠)◶⟨!∘"⊑𝕩: 𝕩 can't be empty",0⊸⊑⟩⥊⟩

Reverse←{
  "⌽𝕩: 𝕩 must have rank at least 1" ! 1≤=𝕩
  l←≠𝕩
  ((l-1)⊸-⌜↕l) ⊏ 𝕩
}
RotCheck ← ("𝕨⌽𝕩: 𝕨 must consist of integers" ! Int)⊸⊢
RotReduce ← RotCheck⊸{
  𝕩+↩0=𝕩 ⋄ r←𝕨-𝕩×⌊𝕨÷𝕩
  "𝕨⌽𝕩: 𝕨 too large" ! r<𝕩
  r
}
RotL ← ↓∾↑
Rot ← (1==∘⊢)◶⟨RotL⟜(↕≠)⊏⊢,RotL⟩
Rotate ← ⟨"⌽"
  IsAtom, 0,0
  (0<≠∘⊢)◶⟨RotCheck⊸⊢, RotReduce⟜≠ Rot ⊢⟩
  (RotReduce RotL ·↕⊢)
⟩_multiAxis⟜ToArray _fillBy_ ⊢

RepInd←(2⌊=∘⊣)◶{
  𝕨↩(0⊑⥊)⍟IsArray𝕨
  "𝕨/𝕩: 𝕨 must consist of natural numbers" ! Nat 𝕨
  e←r←𝕨
  {e+↩r⋄1+𝕩}⍟{e=𝕨}˜`↕r×𝕩
}‿{
  "𝕨/𝕩: Lengths of components of 𝕨 must match 𝕩" ! 𝕩=≠𝕨
  "𝕨/𝕩: 𝕨 must consist of natural numbers" ! 1×´|∘⌊⊸=⌜𝕨
  / 𝕨
}‿{
  "𝕨/𝕩: Components of 𝕨 must have rank 0 or 1" ! 0˙
}
Replicate←⟨"/"
  ((0<≠)×´(1=Type)⌜)∘⥊, 1,1
  RepInd⟜≠ ⊏ ⊢
  RepInd
⟩_multiAxis○ToArray _fillBy_ ⊢
ReplicateInv ← (1==)◶⟨0,0=≠⟩∘⊣◶⟨ToArray⊸{
  IA 1≥=𝕨
  IA 1×´(1=Type)◶⟨0,1⊸≤∧⌊⊸=⟩⌜⥊𝕨
  IX 1≤=𝕩 ⋄ n←≠𝕩
  U ← {𝕩⊸×⌜↕(IX⌊⊸=)⊸⊢n÷𝕩}0⊸⊑
  L ← »·(IA n=(≠-1˙)⊸⊑)⊸⊢+`
  𝕨 =◶U‿L⊸⊏ 𝕩
}, {IX IsArray𝕩⋄𝕩}⟩

IsPure ← {d←Decompose𝕩 ⋄ 2⊸≤◶⟨≤⟜0, (ChPure×´·𝕊⌜1⊸↓)d˙⟩0⊑d}
ChPure ← (5=0⊸⊑)◶⟨1,('◶'_isGlyph 2⊸⊑)◶⟨1,1×´·IsPure⌜·⥊3⊸⊑⟩⟩
hfils ← {𝕏´{0 Fill 𝕏}‿⊢}⌜(⊢∾{𝕏˜}⌜)⊢‿{𝕎{𝕎⊘𝕏}𝕏}
HomFil ← "=≠≡≢"_glyphLookup_(1‿1‿2‿3‿0⊏hfils)⊸{𝕎𝕩}
_fillByPure_←{
  𝕘 (3≤Type∘⊣)◶⟨{𝕨Fill𝕏},{(𝕨HomFil𝕩)_fillBy_𝕨}⍟(IsPure⊣)⟩ 𝕗
}
_each  ← {𝕨𝔽⌜⊘(𝔽_eachd)_fillByPure_𝔽○ToArray𝕩}
_table ← {𝕨𝔽⌜_fillByPure_𝔽○ToArray𝕩}

_matchF ← {rec ← {(0⊑𝕨)◶(1⊑𝕨)‿𝕩}´⟨
  ⟨=○IsArray, 0⟩
  ⟨IsArray∘⊢, 𝔽⟩
  ⟨=○=      , 0⟩
  ⟨MatchS○≢ , 0⟩
  {1×´⥊𝕨Rec¨𝕩}
⟩}
Match ← =_matchF
MatchR ← =◶⟨0=+○(=˜),1⟩_matchF
Depth ← IsArray◶0‿{1+0⌈´Depth⌜⥊𝕩}

Join1←{
  # List of lists
  "∾𝕩: 𝕩 must have an element with rank at least =𝕩" ! 0<0+´=⌜𝕩
  i←j←¯1 ⋄ e←⟨⟩ ⋄ a←𝕩
  {{e↩Deshape a⊑˜i↩𝕩⋄j↩¯1}⍟(1-i⊸=)𝕩⋄(j↩j+1)⊑e}⌜/≠⌜𝕩
}

under←{
  Err←{𝕩}
  IsErr ← (3=Type)◶⟨0,Err˙⊸=⟩
  E ← Err˙
  _errIf ← {⊢⊘×○(1-𝔽)◶⟨Err˙,𝕏⟩}
  SE ← IsErr _errIf⍟(3≥Type)

  Expand ← {
    f‿a‿i‿q←𝕩 ⋄ e←i⊑⥊a
    ⟨IsArray◶⟨⟨⟩,∾⟜⟨i⟩⟩f,e,IsArray◶⟨0,@Fill⥊⟜(↕1×´⊢)∘≢⟩e,q⟩
  }⍟(>⟜(IsArray 2⊑⊢))
  Expand2 ← {
    xf‿xa‿xi‿xq ← 𝕩
    E ← { f‿a‿i‿q←𝕩 ⋄ {f‿a‿𝕩‿q _s}⍟(1-IsStruct)⌜⍟(0<≠f) <⍟(1-IsArray) i }
    i ← (E 1 Expand IsStruct◶{xf‿xa‿𝕩‿xq}‿(1⊑Decompose))⌜ xi
    ⟨⟩‿@‿i‿⟨1,1⟩
  }
  _s ← {
    ⟨st,d‿o⟩←𝕩  # Function, input depth, output is structural
    f‿a‿i‿⟨q,r⟩←Expand2⍟(2=d) (0<d) Expand 𝕗   # Path, array reference, indices, info
    {f‿a‿𝕩‿⟨q⌈1<o,r⟩ _s}⍟(1-IsStruct)⍟(0<o) 𝕨 St i
  }
  IsStruct ← (StructD←(4=0⊸⊑)◶⟨0,s˙=2⊸⊑⟩) {Decompose𝕩}
  NS ← IsStruct _errIf
  InitS ← {¯1‿⟨𝕩⟩‿0‿⟨0,0⟩ _s}
  Nest ← {
    d←0⋄r←0 ⋄ SD ← {d⌈↩IsArray𝕩⋄𝕩}
    a ← Decompose⊸(1⊸⊑⊸((0<·≠0⊑⊣)◶⟨{r⌈↩1⊑3⊑𝕨⋄SD 2⊑𝕨},{r↩1⋄𝕩}⟩) ⍟(StructD⊣)) _perv 𝕩
    ⟨⟩‿@‿a‿⟨d,r⟩ _s
  }
  Es ← {f‿a‿i‿q←𝕩⋄{f‿a‿𝕩‿q _s}⌜i}
  _nested ← {
    p0‿p1←(⌊⋈⌈)´≠⌜pw‿px←0⊸⊑⌜a←(1 Expand 1⊑Decompose)⌜ 𝕨‿𝕩
    p ← 0+´×`(⊑⟜pw=⊑⟜px)⌜↕p0
    (p=p1)◶⟨
      Nest 𝔽○Es
      {𝕩_s}(2↑⊢)∾𝔽○(2⊸⊑)⋈⌈¨○(3⊑⊢)
    ⟩´a
  }
  _withNest ← {
    (0<+○IsStruct)◶⟨𝔽, Nest 𝔽○(Es∘(1 Expand 1⊑Decompose)⍟IsStruct)⟩
  }
  _rankStruct_ ← {
    ss←↕0 ⋄ Wr←{ss∾↩⟨𝕩⟩⋄𝕩} ⋄ _rd←{i←𝕗⋄{𝕩⋄(i+↩1)⊢i⊑ss}}
    _r_ ← {
      Min←<◶⊢‿⊣
      𝕘 {𝕏○({𝕩_s}⍟(0 _rd))}⍟(3≤Type)↩
      k←𝕨(⋈○(=2⊸⊑⍟(0 _rd)) (0≤⊢)◶⟨Min⟜-,⊣-Min⟩¨ 𝔾_ranks)𝕩
      c←0<+´ss⋄Enc←0 _rd◶⟨EncRank,{f‿a‿i‿q←𝕩⋄{f‿a‿𝕩‿q _s}⌜𝕨 EncRank i}⟩
      c◶⟨Merge,{𝕏⟨Merge,2‿1⟩}∘Nest⟩ ((0⊑k)Enc𝕨) 𝔽_each ((1-˜≠)⊸⊑k)Enc𝕩
    }
    𝕨 𝔽_r_𝔾○((1 Expand 1⊑Decompose)⍟(Wr IsStruct)) 𝕩
  }
  _depthStruct_←{
    n←𝕨𝔾_ranks𝕩 ⋄ F←𝔽 ⋄ B←{𝕏}⊘{𝕨˙⊸𝕏}
    "Under ⚇: depths must be less than 0, or ∞"!1×´(∞⊸=∨0⊸>)⌜n
    _tf←{𝕗⌜_withNest} ⋄ _ef←{𝕗_eachd _withNest}
    a ← {(𝕨 B 𝕗)_tf𝕩}‿{𝔽⟜(𝕩˙)_tf𝕨}‿_ef
    _d←{ t←2⊸×⊸+´0⊸>⌜𝕗 ⋄ 𝕗{𝕩⋄m←(t-1)⊑a⋄(+⟜1⌜𝕗)_d _m}⍟(0<t) f }
    𝕨 n _d 𝕩
  }

  _amb ← {(IsStruct⊢)◶⟨𝕏, 𝕩‿𝕗{𝕨𝕏𝕗}⟩}
  _mon ← {(𝕗_amb𝕩)⊘(NS𝕩)}
  _dy  ← {(NS𝕩)⊘(𝕗_amb𝕩)}
  k‿v ← Split2 ⟨
    "⊢⊣˜∘○⊸⟜⊘◶",  ⊢  # ˙ handled specially
    "´˝",         {r←𝕩⋄{IsArray∘⊢◶⟨E,𝔽_r⟩}}
    "=≠≢",        1‿0 _mon
    "<",          0‿2 _mon
    "⋈",          0‿2 {+○IsStruct◶⟨𝕏, 𝕩‿𝕗{𝕏𝕗}⊘E, Nest 𝕏⟩}
    "≍",          1‿1 _mon  # Dyad combines
    "↕/»«",       1‿1 _dy
    "⊔",          1‿2 _dy
    "⥊⌽⍉⊏",       1‿1 _amb
    "↑↓",         {(1‿2 _amb𝕩)⊘(1‿1 _amb𝕩)}
    "⊑",          1‿2 _amb
    ">",          2‿1 _mon
    "∾",          2‿1 {+○IsStruct◶⟨𝕏, 𝕩‿𝕗{𝕏𝕗}⊘E, 𝕏_nested⟩}
    "¨⌜",         {m←𝕩⋄{𝔽 _m _withNest}}
    "˘",          {𝕩⋄{𝔽 _rankStruct_ ¯1}}
    "⎉",          rankStruct˙
    "⚇",          depthStruct˙
  ⟩
  NSPrim ← (Type-3˙)◶⟨NS, {m←𝕩⋄{NS(𝕗_m)˙0}}, {m←𝕩⋄{NS(𝕗_m_𝕘)˙0}}⟩
  SP ← (Join1 k)_glyphLookup_((k≠⌜⊸/v)∾⟨NSPrim⟩)

  Recompose ← ⊣◶⟨
    ⊢                  # 0 primitive
    ⊢                  # 1 block
    {𝕎𝕏}´⊢             # 2-train
    {F‿G‿H←𝕩⋄F G H}    # 3-train
    {F‿m←𝕩⋄F _m}       # 4 1-modifier
    {F‿m‿G←𝕩⋄F _m_ G}  # 5 2-modifier
  ⟩
  Recomp ← (E˙=≥⟜3⊸⊑)◶⟨Recompose,E˙⟩

  SFN ← 0⊸≤◶⟨3,2⊸≤◶⊢‿2⟩∘(0⊑⊢)◶⟨
    SE · {p←SP𝕩⋄P𝕩} 1⊑⊢           #  0 primitive
    E˙                            #  1 block
    DIsConst◶⟨SE 0⊸⊑ Recomp {SFN⌜1↓𝕩}, {(1⊑𝕩)˙}⟩  # other operation
    SE 1⊑⊢                        # ¯1 constant
  ⟩⟜{Decompose𝕩}

  # Traverse indices 𝕩 and values 𝕨.
  # Return flat lists ⟨indices,values⟩, or err if 𝕨 doesn't capture 𝕩.
  conform ← {𝕎◶0‿𝕏}´⟨IsArray⊢, =○=, MatchS○≢⟩
  GetInserts ← {
    v‿d←𝕨
    count←1⋄DC←IsArray◶⟨0,d◶⟨1,1+0⌈´{count+↩¯1+≠d←⥊𝕩⋄DC⌜d}⟩⟩⋄depth←DC𝕩
    𝕩 (2⌊depth)◶(⋈○⋈)‿(Conform◶⟨Err˙,⋈○⥊⟩)‿{
      Fail←{𝕊‿0}
      # 𝕎 is parent traversal; 𝕩 is current components of ind and val
      Trav←(IsArray 0⊑⊢)◶⟨⋈, Conform´∘⊢◶Fail‿{
        Parent←𝕎 ⋄ n←≠0⊑a←⥊⌜𝕩 ⋄ j←¯1
        Child←Trav⟜{𝕩⊸⊑⌜a}
        { j+↩1 ⋄ f←n⊸≤◶⟨𝕊˙⊸Child,Parent˙⟩j ⋄ F 0 }
      }⟩
      next ← 0 Trav 𝕨‿𝕩
      res ← {n‿o←Next𝕩⋄next↩n⋄o}⌜ ↕count
      (next=fail)◶⟨0⊸⊑⌜ ⋈ 1⊸⊑⌜, Err˙⟩ res
    } v
  }⍟(1-IsErr∘⊢)

  _insert_ ← {
    i‿v←𝕗_indRec⍟𝕘 𝕩
    root‿x←𝕗
    Set1←{
      𝕩↩ToArray𝕩
      s←≢𝕩⋄l←≠d←⥊𝕩
      "Cannot modify fill with Structural Under"!1∧´@⊸>⌜i
      gl←l GroupLen i ⋄ v⊏˜↩gl GroupOrd i
      j←0⋄Adv←{(j+↩𝕩)-1}⊑v˙
      CM←"⌾: Incompatible result elements in structural Under"!MatchR
      s⥊(↕l)2⊸⌊◶⟨⊑⟜d,Adv,Adv{(𝕨˙CM(j-𝕩)⊸+⊑v˙)⌜↕𝕩-1⋄𝕨}⊢⟩¨gl
    }
    _at_ ← {(↕≠𝕩)𝔽⍟((𝔾𝕩)=⊣)¨𝕩}
    Set ← 0⊸{ (𝕨≥≠root)◶⟨≢⥊(1+𝕨)⊸𝕊_at_(𝕨⊑root˙)∘⥊, Set1⟩ _fillBy_ ⊢ 𝕩 }
    IsArray∘root◶⟨0⊑v˙, 𝕘◶⟨0,0∨´IsErr⌜∘v⟩◶⟨Set,Err˙⟩⟩ x
  }

  _indRec ← {
    root‿x←𝕗 ⋄ iv←𝕩
    l ← GroupLen i ← (1=Type)◶⟨0⊑0⊑1⊑Decompose,¯1⟩⌜ 0⊑iv
    ind‿val ← (l GroupOrd i)⊸⊏⌜ iv ⋄ rec←0
    ic ← (1<·≠0⊑⊢)◶⟨2⊑⊢,{rec↩1⋄𝕩_s}(⋈1↓0⊑⊢)∾1↓⊢⟩∘(1⊑Decompose)⌜ ind
    j←0 ⋄ IJ←{(j+↩𝕩) ⊢ val ⋈⟜1⊸GetInserts○((j⊸+⌜↕𝕩)⊸⊏) ic}
    m ← (⊢ ⋈ ⊑⟜(⥊x) {⟨⟩‿𝕨 _insert_ rec⍟(1-IsErr) 𝕩} ·IJ⊑⟜l)⌜ /0⊸<⌜l
    t ← (/ ¯1⊸=⌜i)⊸⊏⌜ iv
    {(𝕩⊸⊑⌜m)∾𝕩⊑t}⌜ ↕2
  }

  {
    val←𝕨𝔽○𝔾𝕩
    s←𝕘 SFN⊸{𝕎𝕩} InitS 𝕩
    root‿ind‿⟨d,rec⟩ ← IsStruct◶⟨0‿Err‿⟨0,0⟩,0‿2‿3⊏1⊑Decompose⟩ s
    Comp ← {𝕏val}·Inverse𝔾˙
    IsErr◶⟨Comp⍟IsErr root‿𝕩 _insert_ rec, Comp⟩ val‿d GetInserts ind
  }
}

≡ ← Depth          ⊘ Match
≢ ↩ IsArray◶(↕0)‿≢ ⊘ (1-Match)

IF ← ⊢⊣!∘≡  # Intersect fill
IEF← (0<≠)◶⟨⊢_fillBy_ Fill, ⊢_fillBy_ IF⟜ToArray´⟩∘⥊
HasFill ← 0=·Fill⊢_fillBy_(@⍟(3≤Type∘⊣))⟜(↕0)
_fillMerge_ ← {(0<≠∘⥊)◶⟨(𝔾○≢⥊⟨⟩˙)_fillBy_⊢⟜Fill⍟HasFill, 𝔽 ⊣_fillBy_⊢ IEF⟩}
Merge←{
  c←≢0⊑⥊𝕩
  (">𝕩: Elements of 𝕩 must have matching shapes" ! c =○≠◶0‿MatchS ≢)⌜⥊𝕩
  (Deshape⌜𝕩)⊑˜⌜c⥊↕1×´c
}_fillMerge_∾⍟IsArray

JoinTo←(1<⌈○=)◶(∾○⥊)‿{
  a←1-˜𝕨⌈○=𝕩
  s←𝕨⋈○≢𝕩
  "𝕨∾𝕩: Rank of 𝕨 and 𝕩 must differ by at most 1" ! 1×´(a≤≠)⌜s
  c←(≠-a˙)⊸↓⌜s
  "𝕨∾𝕩: Cell shapes of 𝕨 and 𝕩 must match" ! MatchS´c
  l←0+´(a<≠)◶1‿(0⊑⊢)⌜s
  (⟨l⟩∾0⊑c)⥊𝕨∾○⥊𝕩
}○ToArray _fillBy_ IF

_s0←{s←𝕨⋄F←𝔽⋄{o←s⋄s F↩𝕩⋄o}⌜𝕩}
Stride←Reverse 1 ×_s0 Reverse
JoinM←{
  # Multidimensional
  n←≠z←⥊𝕩 ⋄ s←≢⌜z ⋄ r←=𝕩
  sh←≢𝕩 ⋄ p←1 ⋄ i←j←he←<0
  (Stride sh){
    q←𝕨
    a←𝕩⊑sh
    h←-⟜(1-˜0⌈´rr)⌜rr←=⌜z⊏˜q⊸×⌜↕a
    "∾𝕩: Incompatible element ranks" ! 1×´0⊸≤⌜h
    hl←≠ih←q⊸×⌜/h
    sf←s⊏˜⥊((a×q)⊸×⌜↕p)+⌜ih+⌜↕q
    si←⥊he⊣⌜↕hl×q
    "∾𝕩: Incompatible element ranks" ! 1×´si<⟜≠¨sf
    m←si⊑¨sf
    lf←m⊏˜q⊸×⌜↕hl
    "∾𝕩: 𝕩 element shapes must be compatible" ! m MatchS ⥊(↕p)⊢⌜lf⊣⌜↕q
    k ← / l←{i←¯1⋄⊢◶1‿{(i+↩𝕩)⊑lf}⌜h}
    c ← (↕≠k)-¨k ⊏ 0+_s0 l
    he↩ he +⌜ h
    i ↩ (i ×⌜ k⊏l) +¨ i⊢⌜c
    j ↩ j ×⟜a⊸+⌜ k
    p×↩a
  }¨↕r
  d←(=0⊑z)-0⊑he↩⥊he
  "∾𝕩: 𝕩 element trailing shapes must match" ! he MatchS (=-d˙)⌜z
  G←(Deshape⌜z){𝕨⊑𝕩⊑𝕗}¨
  i (0<d)◶G‿{
    Tr←(≠-d˙)⊸↓⋄t←Tr 0⊑s
    "∾𝕩: 𝕩 element trailing shapes must match" ! 1×´(t MatchS Tr)⌜s
    ti←t⥊↕tp←×´t⋄(𝕨tp⊸×⊸+⌜ti)G𝕩⊣⌜ti
  } j
}
Join←(2⌊=)◶⟨
  Merge, (1×´(1≥=)⌜)◶JoinM‿Join1, JoinM
⟩_fillMerge_{
  r←≠𝕨 ⋄ d←≠𝕩
  "∾𝕩: empty 𝕩 fill rank must be at least argument rank" ! d≥r
  (↕d)(r≤⊣)◶⟨⊑⟜𝕨⊸×,⊢⟩¨𝕩
} ⊣ "∾𝕩: 𝕩 must be an array"!IsArray

_takeDrop←{
  take ← 1 - 𝕗
  gl   ← 𝕗⊑"↑"‿"↓"
  noop ← 𝕗⊑⟨1-=⟜|, 1-0⊸=⟩
  inds ← 𝕗⊑⟨
    { 𝔽⍟(𝕨⊸<)a←|𝕩 ⋄ (0<𝕩)◶⟨¯∞⍟(<⟜0)⌜+⟜(𝕨+𝕩)⌜, ¯∞⍟(𝕨⊸≤)⌜⟩↕a }
    { 𝔽 ⋄ 0⊸<◶⟨↕0⌈+,<∘⊢+⌜·↕0⌈-⟩ }
  ⟩
  pre ← "𝕨"∾gl∾"𝕩: 𝕨 must "
  ernk ← pre∾"have rank at most 1"
  eint ← pre∾"consist of integers"
  IsArray∘⊣◶{
    eint ! Int 𝕨
    p←0≤𝕨
    l←𝕨p◶⟨0⌈+,⌊⟩≠𝕩
    F←𝕩{(Fill𝕗)˙⌜↕𝕩}
    k←1⋄S←⊢ ⋄ 𝕨⊸{k×´↩c←1 Cell𝕩 ⋄ S↩(⟨(0⌈(≠𝕩)-⊢)⍟(1-take)|𝕨⟩∾c)⊸⥊}⍟(1<=) 𝕩
    S ((|∘𝕨-≠∘𝕩){𝕩p◶⟨∾˜,∾⟩F𝕨×k}⍟(>⟜0)⊢)⍟take (l×k) (take=p)◶↓‿↑ ⥊𝕩
  }‿{
    ernk ! 1≥=𝕨
    𝕨 ↩ ⥊𝕨
    eint ! 1×´Int⌜𝕨
    r ← ≠𝕨
    s ← r {(1⌜∘↕𝕨-≠𝕩)∾𝕩}⍟(>⟜≠) ≢𝕩
    _c ← { (×⟜𝕗⌜𝕨) +⌜ 𝕩 }
    i←<0 ⋄ k←1 ⋄ UIk←{ i (k×𝕨)_c↩ k ↕⊸(𝕨_c)⍟(1-=⟜1) 𝕩 ⋄ k↩1 ⋄ ≠𝕩 }
    doFil←0
    sh ← (r↑s) Noop◶{k×↩𝕨⋄𝕨}‿(⊣ UIk {𝕩⋄doFil↩1}_inds)¨ 𝕨
    (0<=i)◶(s⊸⥊)‿{
      sh ∾↩ t ← r↓s
      {i 𝕩_c↩ ↕𝕩}⍟(1-1⊸=) k×´t
      Sel ← ⊑⟜(⥊𝕩)
      𝕩{Sel↩0⊸≤◶⟨(Fill𝕨)˙,Sel⟩}⍟⊢doFil
      Sel⌜ sh ⥊ i
    } 𝕩
  }_fillBy_⊢ ⟜ ToArray
}
Take ← 0 _takeDrop
Drop ← 1 _takeDrop

ShiftCheck←{
  "« or »: 𝕩 must have rank at least 1" ! 1≤=𝕩
  s←1 Cell 𝕩
  𝕨 {  # Only if called with two arguments
    "« or »: 𝕨 must not have higher rank than 𝕩" ! 0≤𝕩
    "« or »: Rank of 𝕨 must be at least rank of 𝕩 minus 1" ! 1≥𝕩
    "« or »: 𝕨 must share 𝕩's major cell shape" ! s MatchS (1-𝕩)↓≢𝕨
  } 𝕩-○=𝕨
  (𝕨1⊘{(𝕩≤○=⊢)◶1‿≠𝕨}𝕩) ×´ s
}
ShiftBefore←{
  n←𝕨 ShiftCheck 𝕩
  m←n⌊l←≠d←⥊𝕩
  (≢𝕩) ⥊ (𝕨(0<l)◶d‿{(Fill𝕩)⌜↕𝕨}⟜𝕩⊘(↑⟜Deshape˜)m) ∾ (l-m)↑d
} _fillBy_ (⊢⊘IF)
ShiftAfter←{
  n←𝕨 ShiftCheck 𝕩
  m←n⌊l←≠d←⥊𝕩
  (≢𝕩) ⥊ (m↓d) ∾ 𝕨(0<l)◶d‿{(Fill𝕩)⌜↕𝕨}⟜𝕩⊘(n⊸-⊸↓⟜Deshape˜)m
} _fillBy_ (⊢⊘IF)

RangeCheck ← "↕𝕩: 𝕩 must consist of natural numbers"!Nat
Range ← IsArray◶(↕⊣RangeCheck)‿{
  "↕𝕩: 𝕩 must be a number or list"!1==𝕩 ⋄ RangeCheck⌜𝕩
  (0 Fill 0⌜𝕩)Fill 0⊸Fill⌜(0<1×´⊢)◶⟨⥊⟜⟨⟩,(<⟨⟩)⋈⊸∾⌜´↕⌜⟩𝕩
}
Windows←{
  "𝕨↕𝕩: 𝕨 must have rank at most 1" ! 1≥=𝕨
  r←≠𝕨↩Deshape 𝕨 ⋄ 𝕩↩ToArray𝕩
  𝕨{
    "𝕨↕𝕩: Length of 𝕨 must be at most rank of 𝕩" ! r≤=𝕩
    "𝕨↕𝕩: 𝕨 must consist of natural numbers" ! ×´Nat⌜𝕨
    s←≢𝕩
    l←(r↑s)(1+-)¨𝕨
    "𝕨↕𝕩: Window length 𝕨 must be at most axis length plus one" ! ×´0⊸≤⌜l
    k←1×´t←r↓s
    Win ← {
      str ← Reverse ×`⟨k⟩∾s⊏˜{𝕩⊸-⌜↕𝕩}r-1
      (⥊𝕩) ⊏˜ k +⌜⟜(t⥊↕)˜⍟(0<≠t) l +⌜○(+⌜´str{𝕨⊸×⌜↕𝕩}¨⊢) 𝕨
    }
    𝕨 (0<(k×´l)×´⊣)◶⟨{⟨⟩⥊˜l∾𝕨∾t},Win⟩ 𝕩
  }_fillBy_⊢⍟(0<r)𝕩
}

EncCell ← {
  f←𝕨↑≢𝕩 ⋄ c←1×´s←𝕨Cell𝕩 ⋄ d←⥊𝕩
  i←s⥊↕c
  t←{d⊏˜(c×𝕩)⊸+⌜i}⌜↕1×´f
  e←Fill d⊢_fillBy_(0⍟(3≤Type)⊣)↕0
  (d⊣_fillBy_⊢˜e˙⌜i) Fill f⥊t
}
EncRank ← (>⟜0×1+≥⟜=)◶⟨<⊢,EncCell,<⌜_fillBy_<⊢⟩
_cells ← {
  F←𝔽 ⋄ _m←{𝔽⌜⊘(𝔽¨)_fillByPure_𝔽○(1⊸EncCell)}
  D←{ "˘: Argument lengths don't agree" ! 𝕩=○≠𝕨 ⋄ 𝕨 F _m 𝕩 }
  Merge 𝕨 2⊸×⊸+○(0<=)◶⟨<F,{𝕨˙⊸F _m𝕩},{F⟜(𝕩˙)_m𝕨},D⟩ 𝕩
}
_insert←{
  "˝: 𝕩 must have rank at least 1" ! 1≤=𝕩
  F←𝔽
  Id ← {
    s ← 1↓≢𝕩
    JoinSh ← {"˝: Identity does not exist"!0<≠𝕨 ⋄ 𝕨×⟜(0⊸<)¨↕≠𝕨}
    s (1-IsJoin∘⊢)◶⟨JoinSh⥊𝕩˙, Identity⟩ f
  }
  𝕨 (0<≠)⊘1◶Id‿{𝕨F´1 EncCell 𝕩} 𝕩
}

ReshapeT ← "∘⌊⌽↑"_glyphLookup_(↕5)
Reshape←{
  "𝕨⥊𝕩: 𝕨 must have rank at most 1" ! 1≥=𝕨
  s←Deshape 𝕨
  sp←0+´p←Nat◶⟨1,∞⊸=⟩⌜s
  "𝕨⥊𝕩: 𝕨 must consist of natural numbers" ! 1≥sp
  n←≠d←Deshape 𝕩
  l←sp◶(1×´⊢)‿{
    lp←1×´p⊣◶⊢‿1¨𝕩
    "𝕨⥊𝕩: Can't compute axis length when rest of shape is empty" ! 0<lp
    i←0+´p×¨↕≠p
    t←ReshapeT i⊑s
    "𝕨⥊𝕩: 𝕨 must consist of natural numbers or ∘ ⌊ ⌽ ↑" ! t<4
    Chk ← ⊢ ⊣ "𝕨⥊𝕩: Shape must be exact when reshaping with ∘" ! ⌊⊸=
    a←(2⌊t)◶⟨Chk,⌊,⌈⟩n÷lp
    s↩p⊣◶⊢‿a¨s
    {d∾˜_fillBy_⊢˜↩(Fill d)⌜↕𝕩-n⋄n}⍟(n⊸<)⍟(3=t)lp×a
  } s
  s⥊{
    "𝕨⥊𝕩: Can't produce non-empty array from empty 𝕩" ! 0<n
    l >⟜≠◶⟨↑, ⊣(⊢∾-⟜≠↑⊢)÷⟜2⊸{𝕨𝕊⟜(∾˜)⍟(>⟜≠)𝕩}⟩ 𝕩
  }_fillBy_⊢⍟(1-l=n) d
}

_group←{
  "⊔: Grouping argument must consist of integers" ! 1×´Int⌜𝕩
  "⊔: Grouping argument values cannot be less than ¯1" ! 1×´¯1⊸≤⌜𝕩
  GL←GroupLen⋄𝕩↩𝕨(-˜⟜≠{GL↩(0⌈𝕨⊑𝕩)GL⊢⋄𝕨↑𝕩}⊢)⍟(0⊘⊣)𝕩
  d←(l←GL𝕩)GroupOrd𝕩
  i←0⋄(𝔽d⊏˜{(i+↩𝕩)⊢i⊸+⌜↕𝕩})⌜l
}
GroupInds←{
  "⊔𝕩: 𝕩 must be a list" ! 1==𝕩
  G←⊢_group
  (1<≡)◶⟨
    ↕∘0             Fill G
    ((⊢Fill⥊⟜⟨⟩)0⌜) Fill (<<⟨⟩) ∾⌜⌜´ {⊏⟜(⥊Range≢𝕩)⌜ G⥊𝕩}∘ToArray⌜
  ⟩ 𝕩
}
Group1←{
  n←=𝕨
  "𝕨⊔𝕩: Rank of simple 𝕨 must be at most rank of 𝕩" ! n≤=𝕩
  ld←(≢𝕨)-¨n↑s←≢𝕩
  dr←(1=n)◶⟨0,1=0⊸⊑⟩ld
  "𝕨⊔𝕩: Lengths of 𝕨 must equal to 𝕩, or one more only in a rank-1 component" ! dr◶⟨1×´0⊸=⌜,1⟩ld
  SX←((n==𝕩)◶{c←1×´t←n↓s⋄𝕩⊏˜(c⊸×⊸+)⌜⟜(t⥊↕c)}‿{⊏⟜𝕩} ⥊𝕩)∘⊣ _fillBy_ ⊢⟜𝕩
  (SX⟨⟩) Fill dr SX _group ⥊𝕨
}○ToArray
GroupM←{
  "𝕨⊔𝕩: Compound 𝕨 must be a list" ! 1==𝕨
  n←0+´r←=⌜𝕨
  "𝕨⊔𝕩: Total rank of 𝕨 must be at most rank of 𝕩" ! n≤=𝕩
  ld←(Join1≢⌜𝕨)-¨n↑≢𝕩
  "𝕨⊔𝕩: Lengths of 𝕨 must equal to 𝕩, or one more only in a rank-1 component" ! 1×´ld((0≤⊣)×≤)¨r/1⊸=⌜r
  dr←r⌊¨(0+_s0 r)⊏ld∾⟨0⟩
  l←dr-˜⟜≠¨𝕨↩Deshape⌜𝕨 ⋄ LS←∾⟜(n Cell 𝕩) Reshape 𝕩˙
  S←⊏⟜(LS⟨1×´l⟩)
  (LS 0⌜𝕨) Fill dr (1-1=≠∘⊢)◶⟨
    S _group○(0⊸⊑)
    S⌜ ·+⌜⌜´ (Stride l) {𝕨⊸×⌜⌜𝕩}¨ ⊢_group¨
  ⟩ 𝕨
}
GroupGen←{
  "𝕨⊔𝕩: 𝕩 must be an array" ! IsArray 𝕩
  𝕨(2≤≡𝕨)◶Group1‿GroupM𝕩
}

GroupIndsInv ← {
  IA 1==𝕩
  IX 1×´(1==)⌜𝕩
  j←Join1 𝕩
  IA 1×´(1≠=)⌜j
  IX 1×´Nat⌜j
  {IX𝕨<𝕩⋄𝕨}´⍟(0<≠)⌜𝕩
  g←GroupLen j
  IX 1×´≤⟜1⌜g
  o←/1⊸-⌜g
  (PermInv j∾o)⊏(/≠⌜𝕩)∾¯1⌜o
}
GroupInv ← {
  IA 1==𝕨
  IA 1×´Nat⌜𝕨
  IX 1==𝕩
  IX 1×´(⊣`(0⊸<×=)¨⊢)=⌜𝕩
  n←≠⌜𝕩 ⋄ m←0
  𝕨≠⊸=◶{IX 𝕩=1-˜≠𝕨⋄m↩𝕩⊑𝕨⋄𝕩↑𝕨}‿⊣↩0+´n
  l←GroupLen𝕨
  IX l⌈⟜m⊸=○≠𝕩
  IX l MatchS l≠⊸↑n
  (PermInv l GroupOrd 𝕨) ⊏ Join 𝕩
}

ValidateRanks←{
  "⎉ or ⚇: 𝔾 result must have rank at most 1" ! 1≥=𝕩
  𝕩↩Deshape𝕩
  "⎉ or ⚇: 𝔾 result must have 1 to 3 elements" ! (1⊸≤×≤⟜3)≠𝕩
  "⎉ or ⚇: 𝔾 result must consist of integers" ! 1×´Int⌜𝕩
  𝕩 ⊏˜ (≠𝕩)⊸(-+1-˜⌊∘÷˜×⊣)⌜ 𝕨
}
_ranks ← {⟨2⟩⊘⟨1,0⟩ ValidateRanks 𝔽}
_depthOp_←{
  neg←0⊸>⌜n←𝕨𝔾_ranks𝕩 ⋄ F←𝔽 ⋄ B←{𝕏}⊘{𝕨˙⊸𝕏}
  fb←0 ⋄ SFB←{𝕩⋄sfb↩0⋄fb↩((3≤Type)◶1‿IsPure f)⊑{𝕘⋄𝔽}‿{𝔽_fillBy_𝔾}}
  _tf←{𝕗⌜_fb_𝕗} ⋄ _ef←{𝕗_eachd _fb_ 𝕗}
  _d←{
    r←0 ⋄ GR←𝕗{SFB𝕩⋄gr↩0⋄R↩(𝕗+¨neg)_d}
    Tw‿Tx←⟨0⟩⊸∾⍟(2>≠)neg{(𝕨×0≤𝕩)⊑⟨(0⌈𝕩)<≡,0⟩}¨𝕗
    (2×Tw)⊸+⟜Tx◶⟨
      F, {GR 0⋄(𝕨 B r)_tf𝕩}, {GR 0⋄R⟜(𝕩˙)_tf𝕨}, {GR 0⋄𝕨R _ef𝕩}
    ⟩
  }
  𝕨 n _d 𝕩
}
_rankOp_←{
  Min←<◶⊢‿⊣
  k←𝕨(⋈○= (0≤⊢)◶⟨Min⟜-,⊣-Min⟩¨ 𝔾_ranks)𝕩
  Merge ((0⊑k)EncRank𝕨) 𝔽_each ((1-˜≠)⊸⊑k)EncRank𝕩
}

_repeat_←{
  F←𝔽 ⋄ b←𝕨{𝕏⊣}˙⊘{𝕨˙{𝔽𝕏⊣}}0
  n←𝕨𝔾𝕩
  Multi←{
    l←u←0
    {"⍟: 𝕨𝔾𝕩 must consist of integers"!Int𝕩⋄l⌊↩𝕩⋄u⌈↩𝕩}_perv n
    i←⟨𝕩⟩⋄P←B⊸{𝕎`i∾↕𝕩}
    pos←f P u
    neg←f 0⊸<◶⟨i,Inverse⊸P⟩ -l
    (|⊑<⟜0⊑pos‿neg˙)_perv n
  }
  (Nat n)◶Multi‿{𝕩(B f)∘⊢´↕n} 𝕩
}

÷ ↩ ÷ _perv
⋆ ↩ ⋆ _perv
√ ← ⋆⟜(÷2)   ⊘ (⋆⟜÷˜)
| ↩ (|       ⊘ (>○|◶{𝕩-𝕨×⌊𝕩÷𝕨}‿(+⍟(<⟜0◶⟨0⊸>,0⊸<⟩))) ) _perv
⌊ ↩ (⌊       ⊘ (⊣⍟<)) _perv
⌈ ↩ (-∘⌊∘-   ⊘ (⊣⍟>)) _perv
∧ ← ⍋⊸⊏      ⊘ (× _perv)
∨ ← ⍒⊸⊏      ⊘ ((+-×) _perv)
× ↩ (0⊸(<->) ⊘ ×) _perv
< ↩ <        ⊘ ((1-≥) _perv)
> ↩ Merge    ⊘ ((1-≤) _perv)
≠ ↩ ≠        ⊘ ((1-=) _perv)
= ↩ =        ⊘ (= _perv)
≥ ↩ !∘"≥: Needs two arguments" ⊘ (≥ _perv)
≤ ↩ !∘"≤: Needs two arguments" ⊘ (≤ _perv)
+ ↩ + _perv
- ↩ - _perv
¬ ← 1+-

⊐ ← SelfClas       ⊘ (1 _search)

ProgressiveIndexOf ← 0 Fill {
  c←1-˜=𝕨
  "⊒: Rank of 𝕨 must be at least 1" ! 0≤c
  "⊒: Rank of 𝕩 must be at least cell rank of 𝕨" ! c≤=𝕩
  𝕨⊐○(⋈¨⟜(≢⥊OccurrenceCount∘⥊) 𝕨⊸⊐)𝕩
}

⁼ ← {Inverse 𝕗}
IsConstant ← (3≤Type)◶⟨1 ⋄ DIsConst∘{Decompose𝕩}⊢⟩
AtopInverse ← {(𝕏𝕎)⊘(𝕏⟜𝕎)}○{Inverse𝕩}
TrainInverse ← '⊣'_isGlyph{
  t‿f‿g‿h←𝕩
  K←¬IsConstant
  I ← K∘⊣◶⟨{𝕏⁼{𝕨𝔽𝔾𝕩}(𝕨G⁼⊢)},K∘⊢◶⟨{𝕎⁼𝕩G{SwapInverse𝕗}⊢},INF˙⟩⟩
  f 𝔽∘⊣◶⟨I, {INF⊘(⊣𝕏⁼G⁼)}⟩ h
}
_fInvCases ← {
  IB ← !∘"Can't invert blocks (add an undo header?)"
  FInv ← (0⊸⊑ ⊣◶(1(↑∾⟨IB˙⟩∾↓)𝕗) ⊢) {Decompose𝕩}
  Type◶(1(⊢∾↑)3‿1‿2/{⊢⊣𝕩IX∘≡⊢}‿FInv‿(!∘"Cannot invert modifier"))
}
Inverse ← ⟨
  {PrimInverse𝕩} 1⊸⊑                     # 0 primitive
  1⊸⊑ AtopInverse 2⊸⊑                    # 2-train
  TrainInverse                           # 3-train
  1⊸⊑    {𝕏𝕨}⟜{Mod1Inverse𝕩} 2⊸⊑         # 4 1-modifier
  1‿3⊸⊏ {𝕏´𝕨}⟜{Mod2Inverse𝕩} 2⊸⊑         # 5 2-modifier
⟩_fInvCases

SwapInverse ← ⟨
  {SwapPrimInverse𝕩} 1⊸⊑                               # 0 primitive
  1⊸⊑ AtopInverse⟜{𝕏˜} 2⊸⊑                             # 2-train
  TrainInverse ⟨0,¬IsConstant,0,1⟩ {𝕏˜}∘⊢⍟{𝕎𝕩}¨ ⊢      # 3-train
  1⊸⊑ {𝕏𝕨}⟜{SwapMod1Inverse𝕩} 2⊸⊑                      # 4 1-modifier
  IsArray◶⟨Inverse,0⊸⊑⟩ 1‿3⊸⊏ {(SwapMod2Equiv𝕩)´𝕨} 2⊸⊑ # 5 2-modifier
⟩_fInvCases

IA ← "⁼: Inverse failed"⊸!
IX ← "⁼: Inverse does not exist"⊸!
INF← "⁼: Inverse not found"!0˙
_invChk_ ← {i←𝕨𝔽𝕩⋄IX 𝕩≡𝕨𝔾i⋄i}
↕ ↩ Range          ⊘ Windows
⊏ ↩ FirstCell      ⊘ Select _fillBy_ ⊢
⌽ ← Reverse        ⊘ Rotate
↑ ↩ Prefixes       ⊘ Take
↓ ↩ Suffixes       ⊘ Drop
_catInv ← {
  T‿Dr‿C←𝕗
  {
    d←𝕩-○=𝕨 ⋄ IX(0⊸≤∧≤⟜1)d
    l←d◶≠‿1𝕨 ⋄ IX l≤≠𝕩
    IX (ToArray𝕨)≡d◶⟨l⊸T,C⟩𝕩 ⋄ l Dr 𝕩
  }
}
IsCpx ← '⍳'_isGlyph
_withComplex_ ← { IsCpx◶𝔽‿𝔾 }
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
  '≠', IA∘0 ⊘ ({B←0⊸=∨1⊸=⋄IX B𝕩⋄IA B𝕨⋄𝕩≠𝕨} _perv)
  '<', {IX IsArray𝕩⋄IX 0==𝕩⋄0⊑⥊𝕩}⊘(IA∘0)
  '⊢', ⊢
  '⊣', ⊢⊘(⊢⊣IX∘≡)
  '∾', IA∘0 ⊘ (↑‿↓‿⊏ _catInv)
  '≍', {IX 1 =≠𝕩⋄ ⊏𝕩} ⊘ {IX 2 =≠𝕩⋄IX(ToArray𝕨)≡ ⊏𝕩⋄1⊏𝕩}
  '⋈', {IX⟨1⟩≡≢𝕩⋄0⊑𝕩} ⊘ {IX⟨2⟩≡≢𝕩⋄IX        𝕨 ≡0⊑𝕩⋄1⊑𝕩}
  '↑', {IX 1==𝕩⋄IX 0<≠𝕩⋄IX 0<=r←(≠-1˙)⊸⊑𝕩⋄r}_invChk_↑ ⊘ (IA∘0)
  '↓', {IX 1==𝕩⋄IX 0<≠𝕩⋄IX 0<=r←   0   ⊑𝕩⋄r}_invChk_↓ ⊘ (IA∘0)
  '↕', (1==)◶⟨0,(0<≠)◶⟨1,IsAtom 0⊸⊑⟩⟩◶≢‿≠_invChk_↕ ⊘ (IA∘0)  # Should trace edge and invChk
  '⌽', ⌽ ⊘ (-⊸⌽ ⊣ IX∘IsArray∘⊢)
  '⍉', TransposeInv ⊘ ReorderAxesInv
  '/', IndicesInv ⊘ (ReplicateInv _invChk_ Replicate)
  '⊔', GroupIndsInv ⊘ GroupInv
⟩ _withComplex_ {(-𝕏)⊘(𝕏-)}
SwapPrimInverse ← INF _lookup_ ⟨
  '+', ÷⟜2⊘(-˜)
  '-', IA∘0⊘+
  '×', √⊘(÷˜)
  '÷', IA∘0⊘×
  '⋆', IA∘0⊘√
  '√', IA∘0⊘(Log _perv˜)
  '∧', √⊘(÷˜)
  '∨', (¬√∘¬)⊘(-˜÷1-⊣)
  '¬', IA∘0⊘(+-1˙)
  '∾', {IX 1≤=𝕩⋄l←⌊2÷˜c←≠𝕩⋄IX c=2×l⋄l(↑(⊢⊣IX∘≡)↓)𝕩} ⊘ (⟨-⊸↑,-⊸↓,(≠-1˙)⊏⊢⟩_catInv)
  '≍', {IX 2 =≠𝕩⋄IX≡˝𝕩⋄ ⊏𝕩} ⊘ {IX 2 =≠𝕩⋄IX(ToArray𝕨)≡1⊏𝕩⋄ ⊏𝕩}
  '⋈', {IX⟨2⟩≡≢𝕩⋄IX≡´𝕩⋄0⊑𝕩} ⊘ {IX⟨2⟩≡≢𝕩⋄IX        𝕨 ≡1⊑𝕩⋄0⊑𝕩}
⟩ _withComplex_ {(2÷˜𝕏⟜-)⊘(𝕏⟜-˜)}
⌜ ↩ _table
¨ ↩ _each
∾ ↩ Join           ⊘ JoinTo
» ← ShiftBefore
« ← ShiftAfter
Mod1Inverse ← INF˙ _lookup_ ⟨
  '⁼', ⊢
  '˜', {SwapInverse𝕩}
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
  '⌾', {𝕎⁼⌾𝕏}  # Need to verify for computational Under
  '⍟', Int∘⊢◶⟨IA∘0˙,{𝕎⍟(-𝕩)}⟩
  '⊘', {(𝕎⁼)⊘(𝕏⁼)}
  '⊸', IsConstant∘⊣ ⊣◶{INF⊘𝕏}‿⊢ {𝕎⊸(𝕏⁼)}
  '⟜', {(𝕨IsConstant∘⊢◶⟨IA∘0˙,{𝕩𝕎{SwapInverse𝕗}⊢}⟩𝕩)⊘(𝕏⁼𝕎⁼)}
⟩

SwapMod1Inverse ← INF˙ _lookup_ ⟨
  '˜', {(SwapInverse𝕩)⊘(𝕏⁼)}
  '⁼', {INF⊘((SwapInverse𝕩)˜)}
  '¨', {𝕏˜¨⁼}
  '⌜', {𝕏˜⌜⁼}
  '˘', {𝕏˜˘⁼}
⟩
SwapMod2Equiv ← ⟨INF⟩ _lookup_ ⟨
  '∘', {𝕎𝕏˜}
  '○', {𝕎˜○𝕏}
  '⊘', {(𝕎˜)⊘(𝕏˜)}
  '⊸', {𝕏˜⟜𝕎}
  '⟜', {𝕏⊸(𝕎˜)}
⟩

´ ↩ _fold
˝ ← _insert
⁼ ↩ {i←Inverse𝕗⋄𝕨I𝕩}
˘ ← _cells
⊑ ↩ First          ⊘ Pick
◶ ↩ {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}  # Same definition, new Pick
⚇ ← _depthOp_
⎉ ← _rankOp_
⥊ ↩ Deshape        ⊘ Reshape
≍ ← >∘⋈ _fillBy_ (⊢⊘IF)
⋈ ↩ {𝕩Fill⟨𝕩⟩}     ⊘ (⋈○⊑ _fillBy_ IF○<)
⊔ ← GroupInds      ⊘ GroupGen
⍉ ← Transpose      ⊘ ReorderAxes
∊ ← ⊢_self         ⊘ (0 _search˜)
⍷ ← ∊⊸/            ⊘ Find
⊒ ← OccurrenceCount⊘ ProgressiveIndexOf
/ ↩ Indices        ⊘ Replicate
