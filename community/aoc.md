*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/community/aoc.html).*

# Advent of Code

[Advent of Code 2021](https://adventofcode.com/2021) saw great participation by the BQN community, with a total of 227 solutions published by 22 programmers. They can be found in these repositories:

<center>

[Raghu Ranganathan](https://github.com/razetime/AOC2021-BQN) •
[dzaima](https://github.com/dzaima/aoc/tree/master/2021/BQN) •
[Hannu Hartikainen](https://github.com/dancek/bqn-advent2021) •
[frasiyav](https://github.com/frasiyav/AoC2021) •
[Leah Neukirchen](https://github.com/leahneukirchen/adventofcode2021) •
[Antti Keränen](https://github.com/Detegr/aoc2021) •
[Caleb Quilley](https://gitlab.com/icen/aoc21) •
[Alex Dikelsky](https://github.com/AlexDikelsky/puzzles/tree/main/advent_of_code/advent_2021) •
[Andrey Popp](https://github.com/andreypopp/aoc2021) •
[Johnny](https://github.com/JohnnyJayJay/adventofcode-21) •
[Alvin Voo](https://github.com/alvinvoo/aoc2021) •
[Ben Dean](https://github.com/bddean/aoc-2021) •
[Josh Holland](https://git.sr.ht/~jshholland/adventofcode/tree/master/item/2021) •
[Alastair Williams](https://github.com/alephno/aoc2021/tree/main/BQN) •
[Olodus](https://github.com/Olodus/advent_of_code2021) •
[Aren Windham](https://github.com/arwn/aoc2021) •
[Dimitri Lozeve](https://github.com/dlozeve/aoc2021) •
[Alexander Wood](https://github.com/knightzmc/advent-of-code-2021) •
[Mathias Magnusson](https://github.com/mathiasmagnusson/advent-of-code-21) •
[m-lima](https://github.com/m-lima/advent-of-code-2021) •
[Dunya Kirkali](https://github.com/dunyakirkali/aoc.bqn/tree/main/2021) •
[Benjamin Applegate](https://github.com/Camto/Advent-of-Code-2021/tree/master/BQN)

</center>

<!--GEN
nam ← ⟨"Raghu","dzaima","Hannu","frasiyav","Leah","Antti","Caleb","Alex","Andrey","Johnny","Alvin","Ben","Josh","Alastair","Olodus","Aren","Dimitri","Alexander","Mathias","m-lima","Dunya","Benjamin"⟩
sol ← ⟨1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿13‿14‿15‿17‿18‿20‿21‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿20‿21,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿13‿14,1‿2‿3‿5‿6‿7‿11‿12‿13‿15‿17‿20,1‿2‿3‿4‿5‿6‿7‿9‿10,1‿2‿3‿4‿5‿6‿7‿8‿9,1‿2‿3‿4‿5‿6‿7,1‿2‿3‿4‿5‿6‿7,1‿3‿6‿7‿9,1‿2‿3‿9,6‿7‿9,1‿3,⟨3⟩,⟨3⟩,⟨1⟩,⟨1⟩,⟨1⟩⟩

Ge ← "g"⊸At⊸Enc

w ← (w0←90) + (tw←20) × 0.4+m←25
h ← (h0←56) + (th←18) ×     n←≠nam
wh ← w‿h
out← 40‿10

pa ← "class=Paren|stroke=currentColor|fill=none"
rc ← At "class=code|stroke-width=1|rx=6"
gt ← "stroke-width=1|font-size=14px|fill=currentColor"
Path ← "path" Elt "d"⊸⋈⊘(⊣∾"d"⋈⊢)

bar ← (/¯∞⊸»<-⟜1)⊸(⊏⋈¨«˜⟜≠-⊣)¨ sol-1

((-out÷2)∾wh+out) SVG gt Ge ∾⥊¨ ⟨
  <"rect" Elt rc∾(Pos 0‿0)∾"width"‿"height"≍˘FmtNum wh
  pa Ge Path¨ <∘∾˘("M "⊸∾˘"VH")∾¨FmtNum ((=⌜˜↕2)×w0‿(h0-6))∾˘⌽wh
  "text-anchor=middle" Ge ⟨
    ("text" Attr "font-size"‿"20px"∾Pos⟨w0+tw×m÷2,h0-32⟩) Enc "Day"
    "font-size=11px" Ge ((w0+tw×0.5+↕m)Pos∘⋈¨h0-10) "text"⊸Attr⊸Enc¨ FmtNum 1+↕25
  ⟩
  (10 Pos∘⋈¨h0+th×0.5+↕n) "text"⊸Attr⊸Enc¨ nam
  "stroke-width=6|class=green" Ge Path¨ (∾("M h"⥊˜≠)∾¨FmtNum)¨ (h0+th×0.25+↕n) (∾((w0+⊑∘⊢)∾⊣∾1⊑⊢)¨)¨ tw×bar
⟩
-->

In addition to these, Leah wrote two blog posts explaining her solutions for [day 6](https://leahneukirchen.org/blog/archive/2021/12/counting-lanternfish-with-bqn-and-linear-algebra.html) and [day 9](https://leahneukirchen.org/blog/archive/2021/12/surveying-lava-basins-with-bqn-and-fixpoints.html).

The number of solutions for each of the 25 days is plotted below, along with totals from AoC's [stats page](https://adventofcode.com/2021/stats). The BQN solutions are scaled to be visible here: there are 6878 times more valid AoC submissions than published BQN solutions overall.

<!--GEN
aoc ← 214183‿178707‿156934‿101905‿89145‿89611‿84430‿75496‿69537‿62465‿54756‿47769‿48691‿48892‿38342‿31413‿31285‿22540‿14786‿20695‿23507‿19100‿13132‿10362‿13510
bqn ← 19‿14‿18‿12‿13‿15‿15‿9‿13‿9‿9‿7‿9‿8‿8‿5‿7‿6‿4‿7‿6‿4‿2‿4‿4

width ← 256
pad   ← 40‿40
pad1  ← 40‿10+pad

pc ← At "class=red|r=4"
gr ← "stroke-width=1|font-size=13px|text-anchor=end|fill=currentColor"

col ← "class"⊸⋈¨"red"‿"green"
lab ← "Solutions in:"‿"Anything"‿"BQN"
win ← ⌈´¨ pts ← <∘∾˘ xy ← ⍉> ((↕≠)⋈÷⟜(+´))¨ aoc‿bqn
ar  ← ÷2
dim ← width (⊣≍×) ar
Scale ← ¬⌾(1⊸⊑) ÷⟜win
line ← (/≠¨⊏xy) ⊔ FmtNum ⍉> dim×Scale pts
((-pad1÷2)∾dim+pad1) SVG gr Ge ∾⥊¨ ⟨
  <"rect" Elt rc∾(Pos-pad÷2)∾"width"‿"height"≍˘FmtNum dim+pad
  ((col∾¨⊢)⌾(1⊸↓)(Pos(⊑dim)⊸⋈)¨18×0.5+↕3) "text"⊸Attr⊸Enc¨ lab
  "text-anchor=middle|opacity=0.8" Ge "text"⊸Attr⊸Enc˜´¨ ⟨
    ⟨"day", "dy"‿"1em"∾Pos dim×0.5‿1⟩
    ⟨"count", "transform"‿"rotate(-90)"∾"dy"‿"-0.35em"∾Pos ⌽dim×0‿¯0.5⟩
  ⟩
  <pa At⊸Path ∾("M VH")∾¨FmtNum dim(×∾⌽∘⊣)1‿0×Scale 0
  col ≍⟜"style"‿"fill:none"⊸Path⟜('M'⌾⊑∘∾·⥊ "L "∾¨⎉1⊢)¨ line
⟩
-->

The BQN counts fall off much less than the average. Most likely this is because programmers who decide to try AoC in a crazy new language like BQN tend to be more committed to the task, but BQN also has to meet some minimum bar to enable these crazy people to continue.

Just how okay is BQN? Further discussion to come.
