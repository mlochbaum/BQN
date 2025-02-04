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

# Arithmetic on the implementation-defined number system
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
_amend     # {𝕨˙⌾(𝕗⊸⊑)𝕩} for list 𝕩
↕          # LIMITED to number 𝕩
Identity   # Left or right identity of function 𝕏
⁼          # Inverse of function 𝔽
Fill       # Enclosed fill value for 𝕩
HasFill    # Whether 𝕩 has a fill value


#⌜
# LAYER 1: Foundational operators and functions

# Combinators
◶ ← {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}   # LIMITED to number left operand result
˙ ← {𝕩⋄𝕗}
⊘ ← {𝔽𝕩;𝕨𝔾𝕩}
⊢ ← {𝕩}
⊣ ← {𝕩;𝕨}
˜ ← {𝕩𝔽𝕨⊣𝕩}
∘ ← {𝔽𝕨𝔾𝕩}
○ ← {(𝔾𝕨)𝔽𝔾𝕩}
⊸ ← {(𝔽𝕨⊣𝕩)𝔾𝕩}
⟜ ← {(𝕨⊣𝕩)𝔽𝔾𝕩}
⍟ ← {𝔾◶⊢‿𝔽}            # LIMITED to boolean right operand result

IsArray ← 0=Type
Int ← (1=Type)◶⟨0,⌊⊸=⟩      # Is an integer (including ¯∞ and ∞)
Nat ← (1=Type)◶⟨0,0⊸≤×⌊⊸=⟩  # Is a natural number

≢ ↩ IsArray◶⟨⟩‿≢  # LIMITED to monadic case
⋈ ← {⟨𝕩⟩;⟨𝕨,𝕩⟩}

# LIMITED to numeric arguments for arithmetic cases
√ ← ⋆⟜(÷2)   ⊘ (⋆⟜÷˜)      # Higher precision allowed; see spec
∧ ←            ×
∨ ←            +-×
¬ ← 1+-
| ← ×⟜×      ⊘ {𝕩-𝕨×⌊𝕩÷𝕨}  # Higher precision allowed; see spec
< ← {⟨⟩⥊⟨𝕩⟩} ⊘ (¬≤˜)
> ←            (¬≤)
≥ ← !∘0      ⊘ (≤˜)
≠ ← Length   ⊘ (¬=)
= ↩ Rank     ⊘ =
× ↩ 0⊸(<->)  ⊘ ×
# ⌊⌈ defined after pervasion below

¨ ← _eachm   # LIMITED to monadic case and array 𝕩
´ ← _fold

Rank ← 0⊑≢∘≢
Length ← (0<Rank)◶⟨1,0⊑≢⟩

_eachm←{
  # Set 𝕨⊑⥊𝕩 to 𝔽𝕨⊑⥊𝕩 for each index 𝕨
  (≢𝕩) ⥊ 0 𝔽{𝕨 (+⟜1 𝕊 𝔽∘⊑ 𝕨_amend ⊢)⍟(<⟜≠) 𝕩} ⥊𝕩
}
_fold←{
  ! 1==𝕩
  l←≠v←𝕩 ⋄ F←𝔽
  # If 𝕨 isn't given, start with the last cell of 𝕩
  r←𝕨 (0<l)◶{𝕩⋄Identity f}‿{l-↩1⋄l⊑𝕩}⊘⊣ 𝕩
  # Apply r↩(𝕨⊑v)F r for 𝕨 from l to 0
  l {𝕨 -⟜1⊸(⊣𝕊⊑⟜v⊸F)⍟(>⟜0) 𝕩} r
}

# Re-add identities for needed redefined functions
identity { f‿i←𝕨 ⋄ f˙⊸=◶𝕩‿i }´↩ ⟨ ×‿1, ∨‿0, ∧‿1 ⟩


#⌜
# LAYER 2: Pervasion
# _pervasive should be applied to all arithmetic as an IMPLICIT STEP:
# +-×÷⋆√⌊⌈|¬ and dyadic ∧∨<>≠=≤≥

# Join: elements 0…≠𝕨 come from 𝕨 and the rest from 𝕩
∾ ← {k←≠𝕨⋄k⊸≤◶⟨⊑⟜𝕨,-⟜k⊑𝕩˜⟩¨↕k+≠𝕩}  # LIMITED to two list arguments

ToArray ← IsArray◶<‿⊢

_table←{
  m←≠a←⥊𝕨 ⋄ n←≠b←⥊𝕩 ⋄ F←𝔽 ⋄ i←0
  # 𝕩 is the result index; maintain index i in 𝕨 and compute 𝕩-n×i in 𝕩
  (𝕨∾○≢𝕩)⥊{i+↩𝕩=n×i+1⋄(i⊑a)F(𝕩-n×i)⊑b}¨↕m×n
}

_eachd←{
  _e←{ # 𝕨 has rank less than or equal to 𝕩
    k←≠p←≢𝕨 ⋄ q←≢𝕩
    ! ∧´(⊑⟜p=⊑⟜q)¨↕k    # p≡k↑q
    l←×´(q⊑˜k⊸+)¨↕q≠⊸-k # ×´k↓q, size of a cell in 𝕩 (pairs with a unit)
    a←⥊𝕨 ⋄ b←⥊𝕩
    # In the inner function, 𝕨 indexes into a and (l×𝕨)+𝕩 into b
    q⥊ (≠a) (⊑⟜a 𝔽 l⊸×⊸+⊑b˙)_table○↕ l
  }
  >○=◶⟨𝔽_e,𝔽˜_e˜⟩
}

⌜ ← {(𝔽_eachm)⊘(𝔽_table)○ToArray}
¨ ↩ {(𝔽_eachm)⊘(𝔽_eachd)○ToArray}

# Pervasion recurses whenever any argument is an array
_pervasive←{
  ⊢⊘∨○IsArray◶⟨𝔽, 𝔽{𝕨𝔽_pervasive𝕩}¨⟩
}

# The modifier _pervasive applies to all arithmetic.
# For practicality when testing, basic functions are made pervasive
# instead, which works for all arithmetic except dyadic ⌊⌈.
⌊ ↩ ⌊        ⊘ ({(𝕨>𝕩)⊑𝕨‿𝕩}_pervasive)
⌈ ← -∘⌊∘-    ⊘ ({(𝕨<𝕩)⊑𝕨‿𝕩}_pervasive)


#⌜
# LAYER 3: Remove other limits
# After this all implementations are full except ∾; ↕ is monadic only

Deshape ← IsArray◶{⟨𝕩⟩}‿⥊
Reshape←{
  ! 1≥=𝕨
  s←Deshape 𝕨
  sp←+´p←¬Nat⌜s        # Number of non-numeric elements
  ! 1≥sp               # At most one allowed
  n←≠d←Deshape 𝕩
  l←sp◶(×´)‿{
    # Handle computed shapes
    lp←×´p 1⍟⊣¨𝕩       # Product of numeric elements
    ! 0<lp             # Would imply division by zero
    I←+´↕∘≠⊸×          # Index from boolean list with a single 1 (⊑/)
    e←⟨∘,⌊,⌽,↑⟩=p I⊸⊑s # Pick element and compare with possibilities
    ! +´e              # Must be one of ∘⌊⌽↑
    t←I e              # Which one is it?
    a←(2⌊t)◶⟨{!Nat𝕩⋄𝕩},⌊,⌈⟩n÷lp  # Compute and round length
    s↩p a⍟⊣¨s          # Insert it back into the shape
    # For element ↑, append fill elements to d if necessary
    {d∾↩(Fill d)⌜↕𝕩-n⋄n↩𝕩}⍟(n⊸<)⍟(3=t)lp×a
  } s
  # Size of 𝕩 is n, so n|𝕨 is a cyclic index into d. Final size is l.
  s ⥊ (↕l) {!0<n⋄⊑⟜𝕩¨n|𝕨}⍟(l≠n) d
}

Range←{
  I ← {!Nat𝕩 ⋄ ↕𝕩}             # 𝕩 is a number
  M ← {!1==𝕩 ⋄ (<⟨⟩)⋈⊸∾⌜´I¨𝕩}  # 𝕩 is a list
  IsArray◶I‿M 𝕩
}

Pick1←{
  ! 1==𝕨           # Index must be a list
  ! 𝕨=○≠s←≢𝕩       # with length equal to rank of 𝕩
  ! ∧´Int¨𝕨        # consisting of integers
  ! ∧´𝕨(≥⟜-∧<)s    # in the range [-l,l) where l is an axis length
  𝕨 +↩ s×𝕨<0       # Wrap negatives
  i ← 0(⊑⟜𝕨+⊑⟜s×⊢)´-↕⊸¬≠𝕨  # Compute index with a reverse fold
  i ⊑ ⥊𝕩
}
# Recurse if depth is greater than 1
Pickd ← {∨´⥊IsArray¨𝕨}◶Pick1‿{Pickd⟜𝕩¨𝕨}
Pick ← IsArray◶⥊‿⊢⊸Pickd
First ← {!0<≠𝕩 ⋄ 0⊑𝕩} Deshape

# Two arrays match if all the following conditions hold:
match←{¬∘(0⊑𝕨)◶(1⊑𝕨)‿𝕩}´⟨
  ⟨≠○IsArray , 0⟩  # They are both arrays, or both not arrays
  ⟨¬IsArray∘⊢, =⟩  # They are equal atoms, OR
  ⟨≠○=       , 0⟩  # They have equal ranks
  ⟨∨´≠○≢     , 0⟩  # And equal length along each axis
  {∧´⥊𝕨Match¨𝕩}    # And matching elements
⟩

Depth ← IsArray◶0‿{1+0⌈´Depth¨⥊𝕩}

⊑ ↩ First          ⊘ Pick
⥊ ↩ Deshape        ⊘ Reshape
↕ ↩ Range
◶ ↩ {𝕨((𝕨𝔽𝕩)⊑𝕘){𝔽}𝕩}  # Same definition with updated Pick

≡ ← Depth          ⊘ Match
≢ ↩ ≢              ⊘ (¬Match)


#⌜
# LAYER 4: Operators

> ↩ Merge⍟IsArray  ⊘ >
≍ ← >∘⋈
⎉ ← _rankOp_
⚇ ← _depthOp_
⍟ ↩ _repeat_
˘ ← {𝔽⎉¯1}
˝ ← _insert
` ← _scan

Drop1 ← {⊑⟜𝕩¨𝕨+↕𝕨-˜≠𝕩}  # Drop from list
Cell  ← Drop1⟜≢         # (-𝕨)-cell shape of array 𝕩

# Merge: if empty, append fill shape to array shape to reshape fill
# Otherwise, run all element ravels together
Merge←(0<≠∘⥊)◶((∾○≢⥊⊢)⟜Fill⍟HasFill)‿{
  c←≢⊑𝕩
  ! ∧´⥊(c≡≢)¨𝕩    # Shapes must match
  𝕩⊑⟜ToArray˜⌜↕c  # Shape is (≢𝕩)∾c, with corresponding axis structure
}

# Check if ranks/depths are valid: list of one to three integers
# Return ⥊𝕩
ValidateRanks←{
  ! 1≥=𝕩
  𝕩⥊↩
  ! (1⊸≤∧≤⟜3)≠𝕩
  ! ∧´Int¨𝕩
  𝕩
}
# Extract the appropriate ranks/depths for a call
# Use negative indexing and wrap with |
_ranks ← {⟨2⟩⊘⟨1,0⟩ ((⊣-1+|)˜⟜≠⊑¨<∘⊢) ValidateRanks∘𝔽}
_depthOp_←{
  n ← 𝕨 𝔾_ranks 𝕩
  neg←0>n ⋄ F←𝔽
  _d←{
    R←(𝕗+neg)_d                    # Increment
    rec ← 2⥊(neg∧𝕗≥0)∨(0⌈𝕗)≥𝕨⋈○≡𝕩  # Whether to recurse into 𝕨⊣𝕩 and 𝕩
    𝕨 rec◶(⟨R¨,R⟜(𝕩˙)¨∘⊣⟩≍⟨(𝕨{𝕏;𝕨˙⊸𝕏}r)¨∘⊢,F⟩) 𝕩
  }
  𝕨 n _d 𝕩
}
_rankOp_←{
  k←𝕨(⋈○= 0⊸≤◶⟨⌊⟜-,0⌈-⟩¨ 𝔾_ranks)𝕩 # Effective frame length
  # Enclose (-𝕨)-cells of 𝕩, that is, <⎉((=𝕩)-𝕨) 𝕩
  EncK←{
    f←⊑⟜(≢𝕩)¨↕𝕨  # 𝕨↑≢𝕩
    c←×´s←𝕨Cell𝕩
    f⥊⊑⟜(⥊𝕩)¨∘((s⥊↕c)+c×⊢)¨↕×´f
  }
  # Use <⊢ if k=0 (required to handle atoms correctly), and <⌜⊢ if k==𝕩
  Enc←(>⟜0×1+≥⟜=)◶⟨<⊢,EncK,<⌜⊢⟩
  > ((⊑k)Enc𝕨) 𝔽¨ ((1-˜≠)⊸⊑k)Enc𝕩
}

_insert←{
  ! 1≤=𝕩
  𝕨 𝔽´ <˘𝕩
}
_scan←{
  ! IsArray 𝕩
  ! 1≤=𝕩
  c←×´cs←1 Cell 𝕩
  ! (cs≡≢)𝕨
  l←≠r←⥊𝕩 ⋄ F←𝔽
  𝕨 (0<l)◶⊢‿{
    # Initial cell: cs⥊𝕨F¨c↑𝕩 if 𝕨 is given
    {r↩≥⟜c◶⟨⊑⟜(⥊𝕩)⊸F,⊢⟩⟜(⊑⟜r)¨↕l}𝕨
    # For non-initial elements, apply F to index i-c and i
    # Must be ordered to compute value i-c first
    (≢𝕩) ⥊ r {((𝕨-c)F○(⊑⟜𝕩)𝕨)𝕨_amend𝕩}´ (l-1)-↕l-c
  } 𝕩
}
_repeat_←{
  n←𝕨𝔾𝕩                       # Repetition numbers
  l←u←0                       # Min and max repetitions
  {!Int𝕩⋄!∞>|𝕩⋄l⌊↩𝕩⋄u⌈↩𝕩}⚇0 n
  b←𝕨{⊢;𝕨{𝕗˙⊸𝕏}}0             # Bind 𝕨 to 𝕏 if necessary
  i←⟨𝕩⟩⋄P←{𝕏⊣}∘B⊸{𝕎`i∾↕𝕩}     # P makes a list of repetition 0, 1, …
  pos←𝕗 P u                   # Positive repetitions
  neg←𝕗 0⊸<◶⟨i,{𝕏⁼}⊸P⟩ -l     # Negative repetitions
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

# Multi-axis primitive: 𝔾 is applied to 𝕨 and determines the maximum
# depth of the one-axis case
_onAxes_←{
  F←𝔽
  (𝔾<≡)∘⊣◶{ # One axis
    ! 1≤=𝕩
    𝕨F𝕩
  }‿{ # Multiple axes
    ! 1≥=𝕨
    ! (≠𝕨)≤=𝕩
    R←{(⊑𝕨)F(1 Drop1 𝕨)⊸R˘𝕩}⍟{0<≠𝕨}  # Recurse, then handle one axis
    𝕨R𝕩
  }⟜ToArray
}

SelSub←{
  ! IsArray 𝕨
  ! ∧´⥊Int¨ 𝕨         # All integers
  ! ∧´⥊ 𝕨 (≥⟜-∧<) ≠𝕩  # In range
  𝕨 +↩ (≠𝕩)×𝕨<0       # Wrap negatives
  c←×´s←1 Cell 𝕩
  ⊑⟜(⥊𝕩)¨(c×𝕨)+⌜s⥊↕c  # Extend each index to a whole cell
}
Select←ToArray⊸(SelSub _onAxes_ 1)

JoinTo←{
  s←𝕨⋈○≢𝕩
  a←1⌈´k←≠¨s          # Argument ranks k and result rank a
  ! ∧´1≥a-k           # Can add at most one axis
  c←(k¬a)+⟜(↕a-1)⊸⊏¨s # Cell shapes
  ! ≡´c
  l←+´(a=k)⊣◶1‿(⊑⊢)¨s # Total length
  (⟨l⟩∾⊑c)⥊𝕨∾○⥊𝕩
}

Take←{
  T←{
    ! Int 𝕨
    l←≠𝕩
    # Indices, with clamp and modulus so that fills are all l
    i←(l+1)|¯1⌈l⌊((𝕨<0)×𝕨+l)+↕|𝕨
    # Don't get the fill if not needed, as it can error
    i⊏JoinTo⟜(1⊸Cell⥊Fill)⍟(∨´l=i)𝕩
  }
  # Add leading 1s to shape of 𝕩 first if necessary
  𝕨 T _onAxes_ 0 (⟨1⟩⥊˜0⌈𝕨-○≠⊢)⊸∾∘≢⊸⥊𝕩
}
Drop←{
  s←(≠𝕨)(⊣↑⊢∾˜1⥊˜0⌈-⟜≠)≢𝕩  # Padded shape
  ((s×¬⊸-𝕨>0)+(-s)⌈s⌊𝕨)↑𝕩  # Clamp and complement, then use Take
}
Prefixes ← {!1≤=𝕩 ⋄ (↕1+≠𝕩)Take¨<𝕩}
Suffixes ← {!1≤=𝕩 ⋄ (↕1+≠𝕩)Drop¨<𝕩}

ShiftBefore ← {!𝕨1⊸⌈⊸≤○=𝕩 ⋄ ( ≠𝕩) ↑ 𝕨 JoinTo 𝕩}
ShiftAfter  ← {!𝕨1⊸⌈⊸≤○=𝕩 ⋄ (-≠𝕩) ↑ 𝕩 JoinTo 𝕨}
Nudge     ← (1↑0↑⊢)⊸ShiftBefore
NudgeBack ← (1↑0↑⊢)⊸ShiftAfter

Windows←{
  ! 1≥=𝕨
  ! (≠𝕨)≤=𝕩
  ! ∧´Nat¨⥊𝕨
  s←𝕨≠⊸↑≢𝕩
  ! ∧´𝕨≤1+s
  𝕨{
    i ← s(¬+⌜○↕⊢)⥊𝕨  # Cell indices in 𝕩: add leading and trailing axes
    c ← ><¨⊸⊏⟜𝕩¨i    # Select the cells
    ((≢i)∾𝕨≠⊸↓≢𝕩)⥊c  # Reshape in case it's empty
  }⍟(0<≠𝕨)𝕩
}⟜ToArray

Reverse ← {!1≤=𝕩 ⋄ (-↕⊸¬≠𝕩)⊏𝕩}
Rotate ← {!Int𝕨 ⋄ l←≠𝕩⋄(l|𝕨+↕l)⊏𝕩} _onAxes_ 0

Indices←{
  ! 1==𝕩
  ! ∧´Nat¨𝕩
  ⟨⟩∾´𝕩⥊¨↕≠𝕩
}
Rep ← Indices⊸⊏
# Expand unit 𝕨 to length of 𝕩, and check length match for a list
Replicate ← ({0<=𝕨}◶(⊣˘)‿{!𝕨=○≠𝕩⋄𝕨}Rep⊢) _onAxes_ (1-0=≠)


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

identity { f‿i←𝕨 ⋄ f˙⊸=◶𝕩‿i }´↩ ⟨ ∨‿0, ∧‿1 ⟩

# Join of empty: multiply shape by (leading) fill shape
JoinEmpty ← ({!𝕨≤○≠𝕩⋄𝕨≠⊸((𝕨×↑)∾↓)𝕩}○≢⥊⊢)⟜Fill⍟HasFill

Join←(0<≠∘⥊)◶⟨JoinEmpty, (0<=)◶{!IsArray𝕩⋄>𝕩}‿{
  ! IsArray 𝕩
  s←≢¨𝕩
  a←(≢𝕩){(s⊑˜(j=𝕩)⊸×)¨↕𝕨}¨j←↕r←=𝕩    # Skeleton: elements 0,0,…k,…0 along each axis
  h←(¬⟜(⌈´)≠¨)¨a                     # Which positions have the axis
  ! ∧´∧´¨0≤h                         # Rank can only change by 1 along a line
  o←+`⊑¨h                            # Starting position of each axis in ⊑𝕩
  t←(¯1⊑o)↓⊑s                        # Trailing axes
  l←h{𝕎𝕩}¨˜(»o){⊣◶⟨1,𝕨⊸⊑⟩¨⟜𝕩}¨a      # Length of each position on each axis
  ! s≡(<t)∾⌜´h⥊¨¨l                   # Shape agreement
  i←(<⟨⟩)∾⌜´h{((↕¯1⊸⊑)-𝕩/𝕨⥊¨»)+`𝕩}¨l # Indices: ∾↕∘≢¨𝕩 if no trailing axes
  >i<¨⊸⊏⍟(0<≠∘⊣)¨l/𝕩
}⟩

Group←{
  ! IsArray 𝕩
  𝕨 ⋈∘ToArray⍟(2>≡)↩
  ! 1==𝕨
  {!∧´Int¨𝕩⋄!∧´¯1≤𝕩}∘⥊¨𝕨  # Atoms in 𝕨 must be integers ≥¯1
  n←+´r←=¨𝕨               # Number of ranks grouped for each result axis (r); total (n)
  ! n≤=𝕩
  ld←(∾≢⌜𝕨)-n↑≢𝕩          # Extra elements
  ! ∧´(0⊸≤∧≤⟜(r/1=r))ld   # Must be 0 extra, or possibly 1 for rank 1 components
  dr←r⌊(0»+`r)⊏ld∾⟨0⟩     # Whether each result axis has a minimum length
  s←dr⊣◶⟨0,¯1⊸⊑⟩¨𝕨        # Minimum shape required by extra elements
  𝕨↩dr(⥊¯1⊸↓⍟⊣)¨𝕨         # Remove extra elements; deshape components
  s⌈↩1+¯1⌈´¨𝕨             # Result shape
  𝕩↩((≠¨𝕨)∾n↓≢𝕩)⥊𝕩        # Merge axes of 𝕩 that are handled together in 𝕨
  (𝕨⊸=/𝕩˙)¨↕s             # Construct each result group by filtering
}
GroupInds←{
  ! 1==𝕩
  𝕩 ⊔ ↕ (1<≡)◶≠‿(∾≢¨) 𝕩
}

# Searching: use all-pairs comparisons
IndexOf←{
  c←1-˜=𝕨
  ! 0≤c
  ! c≤=𝕩
  𝕨 ∧○(0<≠)⟜⥊◶⟨0⥊˜c-⊸↓≢∘⊢, (+˝∧`)≢⎉c⎉c‿∞⟩ ToArray 𝕩
}
MarkFirst←{
  ! 1≤=𝕩
  u←0↑𝕩
  (0<≠)◶⟨⟨⟩,{⊑𝕩∊u}◶{u∾↩𝕩⋄1}‿0˘⟩𝕩
}
Find←{
  r←=𝕨
  ! r≤=𝕩
  𝕨 ≡⎉r ((1+r-⊸↑≢𝕩)⌊≢𝕨)⊸↕⎉r 𝕩
}○ToArray

ReorderAxes←{
  𝕩<⍟(0=≡)↩
  ! 1≥=𝕨
  𝕨⥊↩
  ! (≠𝕨)≤=𝕩
  ! ∧´Nat¨𝕨
  r←(=𝕩)-+´¬∊𝕨      # Result rank: duplicates in 𝕨 reduce it
  ! ∧´𝕨<r
  𝕨∾↩𝕨(¬∘∊˜/⊢)↕r    # Add unused axes to the end
  (𝕨⊸⊏⊑𝕩˙)¨↕⌊´¨𝕨⊔≢𝕩 # Reorder indices to select result elements
}
Transpose←(0<=)◶⟨ToArray,(=-1˙)⊸ReorderAxes⟩

# Sorting
Cmp ← ⌈○IsArray◶{ # No arrays
  𝕨(>-<)𝕩
}‿{ # At least one array
  ed←-´e←𝕨⋈○(∧´0<≢)𝕩
  𝕨(ed=0)◶ed‿{
    # Backup ordering by rank
    c←𝕨×∘-○(IsArray+=)𝕩
    # l is the number of elements to compare
    # Also update backup ordering c if lengths differ
    s←≢𝕨 ⋄ t←≢𝕩 ⋄ r←𝕨⌊○=𝕩
    l←s{i←+´∧`𝕨=𝕩⋄m←(×´e)×´i↑𝕨⋄{c↩×-´𝕩⋄m×↩⌊´𝕩}∘(⊑¨⟜𝕨‿𝕩)⍟(r⊸>)i⋄m}○(r↑⌽)t
    # Compare elements, stopping at the first difference
    a←⥊𝕨⋄b←⥊𝕩
    Trav←(=⟜l)◶{Trav∘(1+𝕩)⍟(0⊸=)a Cmp○(𝕩⊸⊑)b}‿c
    Trav 0
  }𝕩
}

_grade←{
  ! 1≤=𝕩
  # Compare all cells and break ties with indices
  # Then sum and invert as a permutation
  i⊐˜+´˘(𝔽⎉∞‿¯1⎉¯1‿∞˜𝕩)(⌈⟜0+=⟜0⊸×)>⌜˜i←↕≠𝕩
}
_bins←{
  c←1-˜=𝕨                       # Rank of compared cells
  ! 0≤c
  ! c≤=𝕩
  LE←𝔽⎉c≤0˙                     # Does 𝕨 precede 𝕩?
  ! (0<≠)◶⟨1,∧´·LE˝˘2↕⊢⟩𝕨       # 𝕨 must be ordered
  𝕨 (0<≠𝕨)◶⟨0⎉c∘⊢,+˝LE⎉¯1‿∞⟩ 𝕩  # Number of 𝕨 cells preceding or matching each 𝕩 cell
}

# In the result of ⍋⍋, matching cells get consecutive indices
# Select with ⊐˜ to get the first, and subtract for the occurrence count
OccurrenceCount ← (⊢-⊏)⟜(⍋⍋)⊐˜
# Tag each cell with an occurrence count, then search
ProgressiveIndexOf ← {𝕨⊐○(((≢∾2˙)⥊≍˘⟜OccurrenceCount∘⥊)𝕨⊸⊐)𝕩}
