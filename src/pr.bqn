#!/usr/bin/env bqn

# Process BQN runtime
rtt ← ('0'-˜⊑)⍟= ⊑ •args∾2  # Runtime type: 0, 1, or all
rtn ← 2⊸≤◶⥊‿↕ rtt           # File numbers included
final‿extra ← (1↓•args) (⊣∾≠⊸↓) ""‿""

glyphs ← •Import "glyphs.bqn"

# Provided values, to be passed in through the constants array
alias‿def ← (⊑¨ ⋈ 1⊸↓¨) ⟨"&Type","∩Fill","⍣Log",
                         "$GroupLen","%GroupOrd","⍝_fillBy_"⟩
keep ← "!+-×÷⋆⌊=≤≢⥊⊑↕⌜`⊘⎊"
chrext ← glyphs ∾¨ ((+´·∧`'_'=0‿¯1⊸⊏)¨def) ⊔ alias
Typ ← chrext⊸((+`≠¨)∘⊣⍋∾⊸⊐)

in0‿out0 ← ⟨"∩⍝+-×⌊=≤≢⥊⊑↕⌜⊘", "⌊⌈|<>≠≥⊢⊣∾⋈↑↓⊏˙˜¨´∘○⊸⟜◶⍟"⟩
in2 ← alias∾keep
out2 ← ∾glyphs
in‿out ← rtt ⊑ ⟨in0,out0⟩‿⟨⍷in2∾out0,out2⟩‿⟨in2,out2⟩
in ∾↩ extra

inputs ⇐ ⟨out0, ((⍋Typ)⊸⊏in2)∾extra⟩
need ⇐ Typ⊸⊔ in

GetRepls ← { c‿n←𝕩 ⋄ ⟨c,c⊣⌾((c∊⥊¨in)⊸/)n⟩∾¨⟨def,⥊¨alias⟩ }

⟨E_proc⟩ ← glyphs‿GetRepls •Import "pp.bqn"

rslt ← "⟨"∾"⟩"«∾","⊸∾¨out  # Output all primitives
raw ← ∾ (•FLines "r"∾'0'⊸+∾".bqn"˙)¨ rtn
raw (¬final∊˜' '⊣´¨⊢)⊸/⍟(1=rtt)↩
{𝕤⋄ raw∾˜↩⟨"glyphs←"""∾out∾"%"""⟩ ⋄ rslt∾˜↩"{PrimInd↩⊑𝕩⊐<⋄𝕩‿SetPrims‿SetInv}"}⍟⊢ ∨´1=rtn
raw ∾↩ ⟨rslt⟩
src ⇐ E_proc ∾∾⟜(@+10)¨ raw
