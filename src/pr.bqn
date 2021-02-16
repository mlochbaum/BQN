#!/usr/bin/env dbqn

# Process BQN runtime
# r.bqn begins with provided values and defines primitives as it goes.
# Defining a primitive shadows previous definitions, so earlier uses
# of the primitive still use the old definition.
# This is handled by using a new name each time it's defined.

# All primitives
chrs←⟨
  "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!"
  "˙˜˘¨⌜⁼´˝`"
  "∘○⊸⟜⌾⊘◶⎉⚇⍟"
⟩
nc ← ≠¨chrs
glyphs ⇐ chr ← ∾chrs

# Provided values, to be passed in through the constants array
def ← ⟨"Type","Decompose","Glyph","Fill","Log","GroupLen","GroupOrd","_fillBy_"⟩
keep ← "!+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘"
len ⇐ def+○≠keep
ki ← chr⊐keep
dt ← ⊔⟜⊒ (+´·∧`'_'=0‿¯1⊸⊏)¨ def
ns ← » ne←+`nc
kt ← ∾ (ns+≠¨dt) + ⊔⟜⊒ne⍋ki

# Initial primitive replacement names
init ← (nc/(' '∾¨1‿2/↑"_")∾¨"FMD")∾¨('A'+nc+´⊸↑⥊3∾⌜○↕26)
post ← nc/(2‿1/↑"_")∾¨' '
pn ← init∾¨'0'∾¨post

# All replacements: input and output
chrt ← ⥊¨chr
in  ← chrt                 ∾ def
out ← ((kt⊏chrt)⌾(ki⊸⊏)pn) ∾ (∾ns+dt)⊏chrt
# Make a new name for primitive 𝕩
itr ← 0⥊˜≠chr
Shadow ← {
  i←⊑chr⊐𝕩
  n←0 ⋄ itr↩{n↩1+𝕩}⌾(i⊑⊢)itr
  out↩((i⊑init)∾('0'+n)∾i⊑post)⌾(i⊑⊢)out
}

# Does the expression define a primitive?
E_isdef ← (3≤≠)◶⟨0,∧´⟨chr," ","←↩"⟩∊˜¨3⊸↑⟩
# Process ordinary expression
E_nodef ← {
  idChars ← "_¯.π∞"∾∾"0aA"+⟜↕¨10‿26‿26
  q←≠`𝕩='"' ⋄ q∨↩≠`q<𝕩=''' ⋄ f←¬∨`q<𝕩='#'  # Quotes and comments
  t ← (¯1+`·¬(»f/q)∨·»⊸∧∊⟜idChars)⊸⊔ f/𝕩   # Tokenize
  ∾ (in⊸⊐ ⊑⟜out⍟(<⟜(≠in))¨ ⊢) t            # Replace
}
# Process expression, possibly redefining a primitive
E_proc ← E_isdef◶E_nodef‿{
  tail ← E_proc 3↓𝕩                        # RHS
  Shadow ⊑𝕩                                # New name
  (E_proc 1↑𝕩) ∾ "←" ∾ tail                # LHS
}

rslt ← "⟨"∾"⟩"«∾","⊸∾¨chrt  # Output all primitives
ref ⇐ ∾∾⟜(@+10)¨ E_proc¨ (•FLines "r.bqn")∾<rslt
