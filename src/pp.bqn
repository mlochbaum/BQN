# Primitive processor
# Used in pr.bqn and ../test/ref.bqn for handling source code with
# primitive redefinitions.
# Defining a primitive shadows previous definitions, so earlier uses
# of the primitive still use the old definition.
# This is handled by using a new name each time it's defined.

⟨chrs, GetReplacements⟩ ← •args
nc ← ≠¨chrs

# Scheme for primitive replacement names
init ← (nc/(' '∾¨1‿2/↑"_")∾¨"FMD")∾¨('A'+nc+´⊸↑⥊3∾⌜○↕26)
post ← nc/(2‿1/↑"_")∾¨' '

# All replacements: input and output
⟨in,out⟩ ← GetReplacements ⟨⥊¨∾chrs, init∾¨'0'∾¨post⟩

# Number of redefinitions so far, minus one
itr ← ¯1⥊˜≠in

lf←@+10
Tokenize←{
  wc←"_¯.π∞"∾∾"0aA"+⟜↕¨10‿26‿26             # Word characters

  # Resolve comments and strings
  s‿d←/¨2↑sm‿dm‿c‿n←𝕩⊸=¨"'""#"∾lf
  g←⍋q←∾⟨  s⋄¯1↓d⋄/c⟩ ⋄q↩g⊏q                # Open indices
  e← g⊏∾⟨2+s⋄ 1↓d⋄-⟜»∘⊏⟜(0∾+`c)⊸//n∾1⟩      # Matching close indices
  Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟(0=¯1⊑⊢)       # Mark reachable openings
  ab←(≠𝕩)↑/⁼⥊((≠↑∾⟜≠Se 1∾0¨)q⍋e)/⍉q≍e       # Open/close masks

  k←(n∧ab)<»(𝕩='•')∨(∧⟜«𝕩∊wc)∨≠`ab          # Token continuation mask
  (¯1+`¬k)⊔𝕩
}

E_proc_sub ← {tok←𝕩
  spec ← ⟨in, ⥊¨lf∾",⋄", ⥊¨"←↩"⟩
  tt ← spec (+`≠¨)⊸⍋ ti ← spec ∾⊸⊐ tok
  nextSep ← ⌊`⌾⌽ (≠-⊢×≠-↕∘≠) sep ← 1=tt

  ri ← / 0=tt                               # Replacement indices
  asgn ← 𝕨 × ri ⊏ (1»sep) ∧ «2=tt           # and which are assignments
  c ← ri ⊏ ti
  ord ← ⍋ +⟜(asgn×⊏⟜nextSep⊸-) ri           # Put LHS after RHS
  cinc ← c {n←𝕩/𝕨⋄(-≠n)↓+`⌾((⍋𝕨∾n)⊸⊏)𝕩∾¯1¨n}⌾(ord⊸⊏) asgn
  rplc ← c 0⊸≤◶⟨⊑⟜out,⊑⟜init∾'0'⊸+∾⊑⟜post⟩¨ cinc + c⊏itr
  itr +↩ +´¨ (c∾≠in)⊔asgn
  "←"¨⌾((1+asgn/ri)⊸⊏) rplc⌾(ri⊸⊏) tok
}
E_proc ⇐ ∾ 1⊘⊣ { 𝕨⊸E_proc_sub⌾((" "⊸≢¨𝕩)⊸/) 𝕩 } Tokenize∘⊢
