src ← ""⊸≢¨⊸/ (∧`'#'⊸≠)⊸/¨ •FLines "../spec/reference.bqn"
lines ← (¯1↓∾)¨(src∾¨@+10)⊔˜+`»0=+`+´¨+˝-˝("{⟨"≍"}⟩")=⌜src
assume‿defs ← (∨´∊⟜"←↩")¨⊸⊔ lines
LC ← ⊢+('a'-'A')×1="A["⊸⍋
anames‿names ← (LC' '⊸≠⊸/)¨¨ ⟨assume, (∧`·¬∊⟜"←↩")⊸/¨ defs⟩

nIsP←(1=≠)¨names
NextSame ← ≠(⊢⍋⊸⊏○∾«¨)⊔∘⊐
range ← {(≠⌜˜ ∧ nIsP ≤⎉1 ≥⌜˜ ∧ (NextSame𝕩)>⌜⊢) ↕≠𝕩} names

idChars ← "_¯.π∞𝕣"∾∾"0aA"+⟜↕¨10‿26‿26
defTok ← (¯1+`·¬·»⊸∧∊⟜idChars)⊸⊔¨ defs
depend ← <∘/˘ range ∧ > (names∊LC¨)¨ (0=·+`·-˝"{"‿"}"≡⌜⊢)⊸/¨defTok
order ← {{(𝕨⊸∨𝕊⍟(𝕩<○≠⊢)𝕩∾/)(0»∨`)⊸<𝕨<∧´∘⊏⟜𝕨¨l}⟜/0¨l←𝕩} depend

chrs ← •Import "../src/glyphs.bqn"

def‿keep ← ⊑¨⌾(1⊸⊑) (1=≠)¨⊸⊔ anames
keep∾↩"⌾⎊"
pre←⟨"Type←•Type","_amend←{𝕨˙⌾(𝕗⊸⊑)𝕩}","Identity←{𝕏´⟨⟩}"
     "Fill←⊑∘»1↑⥊","HasFill←1∘Fill⎊0"⟩

GetRepls ← {
  ki ← (⊑¨⊑𝕩)∊keep
  ⊣⌾(ki⊸/)` 𝕩
}

⟨E_proc⟩ ← chrs‿GetRepls •Import "../src/pp.bqn"

rslt ← "⟨"∾"⟩"«∾","⊸∾¨∾chrs  # Output all primitives
•BQN ∾∾⟜(@+10)¨ pre ∾ order∾⟜≠⊸⊏E_proc¨ defs∾<rslt
