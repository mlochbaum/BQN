# Primitive processor
# Used in dzref and pr.bqn for handling source code with primitive
# redefinitions.
# Defining a primitive shadows previous definitions, so earlier uses
# of the primitive still use the old definition.
# This is handled by using a new name each time it's defined.

⟨chrs, GetReplacements⟩ ← •args
nc ← ≠¨chrs
chr ← ∾chrs

# Initial primitive replacement names
init ← (nc/(' '∾¨1‿2/↑"_")∾¨"FMD")∾¨('A'+nc+´⊸↑⥊3∾⌜○↕26)
post ← nc/(2‿1/↑"_")∾¨' '
pn ← init∾¨'0'∾¨post

# All replacements: input and output
⟨in,out⟩ ← GetReplacements ⟨⥊¨chr,pn⟩

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
  ab←∨´((≠𝕩)↑·/⁼((≠↑∾⟜≠Se 1∾0¨)q⍋e)⊸/)¨q‿e  # Open/close masks

  k←»≠`ab                                   # Token continuation mask
  k∨↩»⊸∧k<𝕩∊wc                              # Group words
  k∨↩»𝕩='•'
  (¯1+`¬k)⊔𝕩
}

E_proc_sub ← {tok←𝕩
  spec ← ⟨in, ⥊¨lf∾",⋄", ⥊¨"←↩"⟩
  tt ← spec (+`≠¨)⊸⍋ ti ← spec ∾⊸⊐ tok
  nextSep ← (≠-(⌈`⊢×1+↕∘≠)⌾⌽) sep ← 1=tt

  isChr ← 0=tt
  asgn ← 𝕨 × isChr / ((1»1⊸=)∧·«2⊸=) tt
  c ← isChr / ti
  ord ← ⍋ +⟜(asgn×⊏⟜nextSep⊸-) /isChr
  cind ← c {n←𝕩/𝕨⋄(-≠n)↓+`⌾((⍋𝕨∾n)⊸⊏)𝕩∾¯1¨n}⌾(ord⊸⊏) asgn
  rplc ← c 0⊸≤◶⟨⊑⟜out,⊑⟜init∾'0'⊸+∾⊑⟜post⟩¨ cind + c⊏itr
  itr +↩ +´¨ (c∾≠in)⊔asgn
  "←"¨⌾((1+asgn//isChr)⊸⊏) rplc⌾(isChr⊸/) tok
}
E_proc ⇐ {
  tok ← Tokenize 𝕩
  ∾ (𝕨⊣1)⊸E_proc_sub⌾((" "⊸≢¨tok)⊸/) tok
}
