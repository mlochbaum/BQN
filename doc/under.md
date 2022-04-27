*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/under.html).*

# Under

<!--GEN
d ← 94‿50

Text ← ("text" Attr "dy"‿"0.31em"∾·Pos d⊸×)⊸Enc
Path ← ("path" Attr "class"⊸⋈≍"style"‿"fill:none"˙)⊸Elt⟜("d"⊸⋈)

vals ← ((-´"Aa")+⌽){≍⟜(𝔾¨) ⊢⋈𝔽⌾𝔾}(2↑1⊸↓) "udner"

g  ← "font-size=20px|text-anchor=middle|fill=currentColor"
rc ← At "class=code|stroke-width=1|rx=12"
fc ← "font-size=18px|font-family=BQN,monospace"

Ge ← "g"⊸At⊸Enc
_arrow ← {
  a ← ((⊢≍-⌾⊑∘⌽)÷⟜(+´⌾(×˜))𝕨) +˝∘×⎉1‿∞˜ 𝕗≍-⌾⊑𝕗
  ∾"M l m l l "∾¨ FmtNum ∾⥊¨⟨𝕩-𝕨, 𝕨, -⊏a, a⟩
}
Arr ← 15‿8 _arrow
cut ← 0.24‿0.17
ars ← (×⟜(¬2×cut) Arr○(d⊸×) ×⟜(-cut)⊸+)¨⟜((<-1‿1)⊸++0‿0≍˘⌽) 2×=⟜<↕2

dim ← 5.4‿4×d
rdim ← 4‿4×d
((¯4↑d×0‿0.6)+∾÷⟜¯2‿1<20+dim) SVG g Ge ⟨
  "rect" Elt rc∾(Pos rdim÷¯2)∾"width"‿"height"≍˘FmtNum rdim
  0‿2.4 Text "Under"
  "stroke-width=2.6"‿"stroke-width=2" Ge¨ "purple"‿"yellow" Path⟜∾¨ 0‿1‿1‿1⊔⥊ars
  fc Ge ⟨
    "font-size=20px"⊸Ge⌾⊑ (⍉-⊸≍1.44‿1.2×⌽<⊸=↕2) Text⟜Highlight¨ "𝔽⌾𝔾"‿"𝔽"≍⋈˜"𝔾"
    "class=string" Ge (⋈⌜˜-⟜¬↕2) Text¨ ⍉0‿¯1⌽¨(⌈´∘⥊≠¨)⊸(↑¨) •Repr¨ vals
  ⟩
⟩
-->
