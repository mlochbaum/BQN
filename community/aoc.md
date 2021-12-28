*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/community/aoc.html).*

# Advent of Code

[Advent of Code 2021](https://adventofcode.com/2021) saw great participation by the BQN community, with a total of 225 solutions published by 22 programmers. They can be found in these repositories:

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
[Ben Dean](https://github.com/bddean/aoc-2021) •
[Alvin Voo](https://github.com/alvinvoo/aoc2021) •
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

In addition to these, Leah wrote two blog posts explaining her solutions for [day 6](https://leahneukirchen.org/blog/archive/2021/12/counting-lanternfish-with-bqn-and-linear-algebra.html) and [day 9](https://leahneukirchen.org/blog/archive/2021/12/surveying-lava-basins-with-bqn-and-fixpoints.html).

The number of solutions for each of the 25 days is plotted below, along with totals from AoC's [stats page](https://adventofcode.com/2021/stats). The BQN solutions are scaled to be visible here: there are 6839 times more valid AoC submissions than published BQN solutions overall.

<!--GEN
aoc ← 212619‿177297‿155605‿100935‿88219‿88679‿83481‿74615‿68643‿61663‿53952‿47051‿47966‿48138‿37624‿30770‿30625‿21869‿14145‿20024‿22761‿18378‿12258‿9212‿12204
bqn ← 19‿14‿18‿12‿13‿15‿15‿8‿12‿9‿9‿7‿9‿8‿8‿5‿7‿6‿4‿7‿6‿4‿2‿4‿4

width ← 256
pad   ← 40‿40
pad1  ← 40‿10+pad

pa ← At "class=Paren|stroke=currentColor"
pc ← At "class=red|r=4"
rc ← At "class=code|stroke-width=1|rx=6"
gr ← "g" At "stroke-width=1|font-size=13px|text-anchor=end|fill=currentColor"
Path ← "path" Elt ⊣∾"d"⋈⊢

col ← "class"⊸⋈¨"red"‿"green"
lab ← "Solutions in:"‿"Anything"‿"BQN"
win ← ⌈´¨ pts ← <∘∾˘ xy ← ⍉> ((↕≠)⋈÷⟜(+´))¨ aoc‿bqn
ar  ← ÷2
dim ← width (⊣≍×) ar
Scale ← ¬⌾(1⊸⊑) ÷⟜win
line ← (/≠¨⊏xy) ⊔ FmtNum ⍉> dim×Scale pts
((-pad1÷2)∾dim+pad1) SVG gr Enc ∾⥊¨ ⟨
  <"rect" Elt rc∾(Pos-pad÷2)∾"width"‿"height"≍˘FmtNum dim+pad
  ((col∾¨⊢)⌾(1⊸↓)(Pos(⊑dim)⊸⋈)¨18×0.5+↕3) "text"⊸Attr⊸Enc¨ lab
  ("g" At "text-anchor=middle|opacity=0.8") Enc "text"⊸Attr⊸Enc˜´¨ ⟨
    ⟨"day", "dy"‿"1em"∾Pos dim×0.5‿1⟩
    ⟨"count", "transform"‿"rotate(-90)"∾"dy"‿"-0.35em"∾Pos ⌽dim×0‿¯0.5⟩
  ⟩
  pa⊸Path¨ ((0⊸≤∧≤⟜1)/·<∘∾˘("M "⊸∾˘"VH")∾¨·FmtNum dim(×∾˘⌽∘⊣)(=⌜˜↕2)⊸×) Scale 0
  col ≍⟜"style"‿"fill:none"⊸Path⟜('M'⌾⊑∘∾·⥊ "L "∾¨⎉1⊢)¨ line
⟩
-->

The BQN counts fall off much less than the average. Most likely this is because programmers who decide to try AoC in a crazy new language like BQN tend to be more committed to the task, but BQN also has to meet some minimum bar to enable these crazy people to continue.

Just how okay is BQN? Further discussion to come.
