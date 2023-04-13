*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/tutorial/square.html).*

# Tutorial: The Square of Power

The square of power will organize your view of algorithms and bring your programming to a more advanced level. Its four representations seem distinct, but are joined by a square helix travelling from the infinite to nothing.

        s ← "this is a string "

        (+`' '=s)⊔s

        (/1-˜+`⁼/0∾' '=s)⊔(' '≠s)/s

        (/+`⁼/' '=s)⊔¯1↓s

Examine a related puzzle. We need to know the number of `'i'` characters in each word. One way is `+´¨'i'=w`, where `w` is the list of words. But there's no need to form the list of words. As a first step, filtering both arguments can group the `'i'` characters only, not words.

        (+`s=' ') ⊔○((s='i')⊸/) s

The answer is the count of each group. The characters being grouped are irrelevant, which means monadic Group gives the answer too. More importantly, `≠¨⊔` [is equivalent](../doc/replicate.md#inverse) to `/⁼`.

        ≠¨⊔ (s='i')/+`s=' '

        /⁼(s='i')/+`s=' '

So ``(s='i')/+`s=' '`` tells which word each `'i'` is in, and `/⁼` counts them. Another solution begins with ``(s=' ')/+`s='i'``, to tell how many `'i'`s come before each space in total. The answer is not this total, but the number of `'i'`s *between* the spaces, whose prefix sum `` +` `` gives the total. Undoing the sum takes care of this. But the number of eyes between time remains elusive.

        +`⁼(s=' ')/+`s='i'

The two solutions are very similar.

     /⁼(s='i')/+`s=' '
    +`⁼(s=' ')/+`s='i'

So we have ``(/⁼a)≡(+`⁼b)``, which also implies ``a≡(/+`⁼b)`` and ``(+`/⁼a)≡b``. If we know how many spaces come before each i, we can use these relations to get the number of i's before each space.

        ⊢ wi ← (s='i')/+`s=' '  # Word index of each i

        +`/⁼ wi

        (s=' ')/+`s='i'

How can there be two different ways to translate back and forth, when the situation is completely symmetric by swapping the i and space characters? What if we use the same translator again, and not its inverse?

        +`/⁼+`/⁼ wi

A value is added at the end. The loop is saying that if we had a fourth i, which we don't, there would be 4 spaces in front, which I guess would be true if you just added it at the end. Can we go the other way? Does that work?

        /+`⁼ wi

Now it drops a value. Weird.

## Square helix proves 1 infinity is 4

        4‿4⥊(16⥊⟨/,-⟜»⟩)(⊢»{𝕎𝕩}˜`˜)<0‿0‿2‿0‿4‿1

<!--GEN
d ← 20
rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-size=18px|fill=currentColor|stroke-linecap=round|text-anchor=middle|font-family=BQN,monospace"
Text ← ("text" Attr "dy"‿"0.32em"∾ ·Pos d⊸×)⊸Enc
Path ← ("path" Attr "class"⊸⋈≍"style"‿"fill:none"˙)⊸Elt⟜("d"⊸⋈)
Line ← "line" Elt (⍉"xy"≍⌜"12")≍˘○⥊ ·FmtNum ·d⊸×˘⊢

{
c ← ≠¨ v ← 6‿4⥊(24⥊⟨-⟜»,/⟩)(⊢»{𝕎𝕩}˜`˜)<1‿1‿1‿2‿5‿7‿7

dim ← d×3+m←⌈´⊏c
dir ← ∾⟜-1‿1⋈¯1‿1

bg ← "class=bluegreen|stroke-width=2|style=fill:none|opacity=0.7"
lg ← "class=yellow|stroke-width=2"

brak ← {
  l ← 4‿10
  P ← ∾"M l l "∾¨ ·FmtNum∘⥊ ∾
  Path ∾ (((0‿¯1×l)+d×⋈⟜0)¨-⊸≍0.2) P¨ ⋈⟜⌽ -⌾⊑⊸≍l
}

(⥊¯1‿2×⌜80‿20+dim) SVG g Ge ⟨
  "rect" Elt rc ∾ (Pos -⋈˜dim)∾"width"‿"height"≍˘FmtNum 2×⋈˜dim
  bg Ge brak
  lg Ge Line¨ ⍷>¨<˘2↕⥊dir⊸×˘c+0.15
  (<˘∾(0.8+↕¨⊏c)×⌜¨dir) Text¨ FmtNum∾⊏v
  "font-size=22px" Ge (∾⟜-⋈⟜⌽0⋈m+1.5) Text¨ 4⥊Highlight¨"-⟜»"‿"/"
⟩
}
-->

<!--GEN
lc ← "font-family=sans|font-size=16"
Arr ← { ∾"M L l "∾¨ FmtNum (∾𝕩) ∾ 18‿11 +˝∘× ÷⟜(+´⌾(×˜))˘(-≍𝕨×+)´𝕩 }
ars ← 1‿¯1 Arr¨ d×(-⊸∾⌽¨¨⊸≍)˘(⋈⟜⌽-⊸⋈3.8)⋈¨¨6.5(+⋈-)0.3

dim ← 10×d
rdim ← 4‿4×d
(⥊¯1‿2×⌜80‿20+dim) SVG g Ge ⟨
  "rect" Elt rc ∾ (Pos -⋈˜dim)∾"width"‿"height"≍˘FmtNum 2×⋈˜dim
  "stroke-width=3" Ge "green"‿"purple" Path¨ <∘∾˘ars
  "font-size=22px" Ge (⥊≍˘⟜-∾⋈⟜⌽¨0⋈¨8‿5) Text¨ 2/Highlight¨"+`"‿"/"‿"-⟜»"‿"/⁼"
  (0‿1.2⊸+¨6.5×-⊸∾1‿1⋈¯1‿1) Text¨ Fmt¨ (4⥊⟨-⟜»,/⟩)(⊢»{𝕎𝕩}˜`˜)<0‿2‿2‿3
  lc Ge ((0⋈¨¯1.2‿¯0.2)+⌜6.5×-⊸∾1‿1⋈¯1‿1) Text¨ [
    "Target"‿"Division"‿"Divider"‿"Division"
    "indices"‿"lengths"‿"counts"‿"endpoints"
  ]
⟩
-->
