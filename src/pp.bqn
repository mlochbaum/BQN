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

# Make a new name for primitive 𝕩
itr ← ¯1⥊˜≠chr
Shadow ← {
  i←⊑chr⊐𝕩
  n←0 ⋄ itr↩{n↩1+𝕩}⌾(i⊑⊢)itr
  out↩((i⊑init)∾('0'+n)∾i⊑post)⌾(i⊑⊢)out
}

# Does the expression define a primitive?
E_isdef ← (3≤≠)◶⟨0,∧´⟨chr," ","←↩"⟩∊˜¨3⊸↑⟩
# Process ordinary expression
E_nodef ⇐ {
  idChars ← "_¯.π∞"∾∾"0aA"+⟜↕¨10‿26‿26
  q←≠`𝕩='"' ⋄ q∨↩≠`q<𝕩='''                 # Quotes
  f←(𝕩=@+10)≥○((1+↕∘≠)⊸(⌈`×))q<𝕩='#'       # Comments
  t ← (¯1+`·¬(»f/q)∨·»⊸∧∊⟜idChars)⊸⊔ f/𝕩   # Tokenize
  ∾ (in⊸⊐ ⊑⟜out⍟(<⟜(≠in))¨ ⊢) t            # Replace
}
# Process expression, possibly redefining a primitive
E_proc ⇐ E_isdef◶E_nodef‿{
  tail ← E_proc 3↓𝕩                        # RHS
  Shadow ⊑𝕩                                # New name
  (E_proc 1↑𝕩) ∾ "←" ∾ tail                # LHS
}
