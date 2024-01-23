#! /usr/bin/env bqn

# Tests for the markdown parser
# Uses the test cases at https://spec.commonmark.org/0.29/spec.json
# since Github doesn't seem to have published theirs
markdown ← •Import "../md.bqn"

tests ← ¯2 ↓˘ 8⊸(÷˜⟜≠∾⊣)⊸⥊ 2↓•file.Lines"spec.json"
tests ↩ ((⊑2+⊐⟜':')¨∘⊏ ((-','=¯1⊑⊢)↓↓)¨⎉1 ⊢) tests
testSection ← (1↓¯1↓⊢)¨ 5⊏˘tests
UnEscape ← {
  EscapeChar ← { ("\""tn"⊐𝕩) ⊏ "\"""∾@+9‿10 }
  esc ← » <` 𝕩='\'
  (¬«esc) / EscapeChar⌾(esc⊸/) 𝕩
}
RunTest ← {
  in‿exp ← UnEscape∘(1↓¯1↓⊢)¨2↑𝕩
  out ← 0 Markdown (@+10) ((⊢-˜¬×+`)∘=⊔⊢) in
  ⟨exp≡out,in,exp,out,2⊑𝕩⟩
}

{0=≠•args ?
  •Out "Pass test sections as arguments; shows array of non-matching entries"
  •Out "Available sections: "∾2↓1⌽∾""", """⊸∾¨ ⍷testSection
;
  ignore ← (2 ⊏˘ tests) ∊ ⟨"47","85"⟩
  res ← 1 ↓˘ (¬⊏˘)⊸/ RunTest˘ tests /˜ ignore < testSection ∊ •args
  •Show res
}
