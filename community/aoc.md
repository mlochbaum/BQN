*View this file with graphs and stuff [here](https://mlochbaum.github.io/BQN/community/aoc.html).*

# Advent of Code

[Advent of Code 2021](https://adventofcode.com/2021) saw great participation by the BQN community, with a total of 234 solutions published by 22 programmers. They can be found in these repositories:

<center>

[dzaima](https://github.com/dzaima/aoc/tree/master/2021/BQN) •
[Hannu Hartikainen](https://github.com/dancek/bqn-advent2021) •
[Raghu Ranganathan](https://github.com/razetime/AOC2021-BQN) •
[frasiyav](https://github.com/frasiyav/AoC2021) •
[Leah Neukirchen](https://github.com/leahneukirchen/adventofcode2021) •
[Antti Keränen](https://github.com/Detegr/aoc2021) •
[Caleb Quilley](https://gitlab.com/icen/aoc21) •
[Alvin Voo](https://github.com/alvinvoo/aoc2021) •
[Alex Dikelsky](https://github.com/AlexDikelsky/puzzles/tree/main/advent_of_code/advent_2021) •
[Andrey Popp](https://github.com/andreypopp/aoc2021) •
[Johnny](https://github.com/JohnnyJayJay/adventofcode-21) •
[Josh Holland](https://git.sr.ht/~jshholland/adventofcode/tree/master/item/2021) •
[Ben Dean](https://github.com/bddean/aoc-2021) •
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

Below, problems solved in BQN are shown in green, and problems solved in other languages in faint red.

<!--GEN
nam ← ⟨"dzaima","Hannu","Raghu","frasiyav","Leah","Antti","Caleb","Alvin","Alex","Andrey","Johnny","Josh","Ben","Alastair","Olodus","Aren","Dimitri","Alexander","Mathias","m-lima","Dunya","Benjamin"⟩
sol ← ⟨1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿13‿14‿15‿17‿18‿20‿21‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿20‿21,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿13‿14,1‿2‿3‿5‿6‿7‿11‿12‿13‿15‿17‿20,1‿2‿3‿4‿5‿6‿7‿9‿10,1‿2‿3‿4‿5‿6‿7‿8,1‿2‿3‿4‿5‿6‿7,1‿3‿6‿7‿9,1‿2‿3‿9,6‿7‿9,1‿3,⟨3⟩,⟨3⟩,⟨1⟩,⟨1⟩,⟨1⟩⟩
als ← ⟨⟨⟩,⟨⟩,⟨⟩,⟨⟩,12‿16‿19‿22‿23,⟨⟩,⟨⟩,⟨⟩,⟨12⟩,⟨⟩,⟨8⟩,⟨⟩,⟨⟩,⟨2⟩,⟨⟩,1‿2‿3‿4‿5‿8‿10‿11‿12,2‿5‿6‿7‿9‿10‿12‿13‿14‿15‿16‿17‿20‿21,1‿2,1‿2,2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17,⟨⟩,⟨⟩⟩

Ge ← "g"⊸At⊸Enc

w ← (w0←90) + (tw←20) × 0.4+m←25
h ← (h0←56) + (th←18) ×     n←≠nam
wh ← w‿h
out← 40‿10

pa ← "class=Paren|stroke=currentColor|fill=none"
rc ← At "class=code|stroke-width=1|rx=6"
gt ← "stroke-width=1|font-size=14px|fill=currentColor"
Path ← "path" Elt "d"⊸⋈⊘(⊣∾"d"⋈⊢)

Ct ← (/¯∞⊸»<-⟜1)⊸(⊏⋈¨«˜⟜≠-⊣)¨ -⟜1
Bp ← (0<≠¨)⊸/ (h0+th×0.25+↕n) (∾((w0+⊑∘⊢)∾⊣∾1⊑⊢)¨)¨ tw×Ct
Bars ← (Path·∾("M h"⥊˜≠)∾¨FmtNum)¨ Bp

((-out÷2)∾wh+out) SVG gt Ge ∾⥊¨ ⟨
  <"rect" Elt rc∾(Pos 0‿0)∾"width"‿"height"≍˘FmtNum wh
  pa Ge Path¨ <∘∾˘("M "⊸∾˘"VH")∾¨FmtNum ((=⌜˜↕2)×w0‿(h0-6))∾˘⌽wh
  "text-anchor=middle" Ge ⟨
    ("text" Attr "font-size"‿"20px"∾Pos⟨w0+tw×m÷2,h0-32⟩) Enc "Day"
    "font-size=11px" Ge ((w0+tw×0.5+↕m)Pos∘⋈¨h0-10) "text"⊸Attr⊸Enc¨ FmtNum 1+↕25
  ⟩
  (10 Pos∘⋈¨h0+th×0.5+↕n) "text"⊸Attr⊸Enc¨ nam
  "stroke-width=6|class=green|opacity=0.9" Ge Bars sol
  "stroke-width=6|class=red|opacity=0.2" Ge Bars als
⟩
-->

Some wrote about aspects of the Advent experience: Leah explained her solutions for [day 6](https://leahneukirchen.org/blog/archive/2021/12/counting-lanternfish-with-bqn-and-linear-algebra.html) and [day 9](https://leahneukirchen.org/blog/archive/2021/12/surveying-lava-basins-with-bqn-and-fixpoints.html), Hannu [reflected](https://hannuhartikainen.fi/blog/advent-of-bqn/) on the choice of BQN, and Raghu [commented on](https://razetime.github.io/blog1/2022/01/09/aoc-bqn.html) each problem.

The number of BQN solutions for each of the 25 days is plotted below, along with totals from AoC's [stats page](https://adventofcode.com/2021/stats). The BQN solutions are scaled to be visible here: there are 6827 times more valid AoC submissions than published BQN solutions overall.

<!--GEN
aoc ← 217224‿181389‿159388‿103644‿90769‿91314‿86089‿76948‿71024‿63865‿56022‿48928‿49937‿50161‿39483‿32456‿32350‿23568‿15719‿21624‿24531‿20149‿14206‿11655‿14959
bqn ← 19‿14‿18‿12‿13‿15‿15‿10‿13‿10‿10‿8‿10‿9‿8‿6‿8‿7‿4‿7‿6‿4‿1‿3‿4

width ← 256
pad   ← 40‿40
pad1  ← 40‿10+pad

pc ← At "class=red|r=4"
gr ← "stroke-width=1.2|font-size=13px|text-anchor=end|fill=currentColor"

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

Just how okay is BQN? Hannu [made the case](https://hannuhartikainen.fi/blog/advent-of-bqn/) for optimism. Hannu writes that BQN's slogan "might be the best [further glowing praise/context]", in stark contrast to that time [Bryce and Conor agreed](https://adspthepodcast.com/2021/12/17/Episode-56.html) that it was a bad slogan. And Andrey offers [suspiciously positive comments](https://news.ycombinator.com/item?id=29521264) as well. The list includes "good text editor support", but Johnny remarked on the forums that he didn't manage a good editor/REPL setup—a second contradiction, meaning that I can now prove the Riemann hypothesis in *two* independent ways. Johnny also cited little support for string handling and low-information error messages as obstacles. I like that these aren't tied to the core language, and can eventually be improved, even though it won't be easy. dzaima complained about frequent confusion between functions and immediate blocks, and right-to-left folds being the much less useful direction. I dislike that dzaima is right a lot.

All three non-dzaimas of the last paragraph are essentially array outsiders, with little or no experience with languages like J or APL. In fact I think this describes the majority of Adventurers in BQN (although the list also includes array junkies like Raghu and Leah, and they've predictably made it further than most participants). Reaching out to a general programming audience wasn't initially a goal of BQN because I didn't think it *was* within reach. I realized this was wrong, and began to adjust course, in the early days, but am pleased to continue getting even more wrong.

With all this said, a handful of reports about recreational programming is a pretty poor basis for judging a programming language. Advent of Code was more useful as a checkup on BQN and its environment, resulting in fixes to documentation and implementation. And dzaima improved various aspects of performance as a way to cheat in speed battles with ngn/k.

BQN did do okay in terms of performance. At times programmers on the forum commented about having slow solutions (tens of seconds) or having to rewrite an obviously unsatisfactory algorithm. I don't think anyone mentioned having to switch languages for performance reasons, which is good news for an implementation as young as CBQN. But also not a surprise, as it's pretty fast with scalar code for an interpreter: about 10 times slower than C when I've measured it. Array code is usually faster, but can be slower. A particular problem was that in-place mutation `⌾(i⊸⊑)` is only fast for very simple cases. Of course, this problem only arises because BQN's arrays are immutable, highlighting that immutable arrays, despite being perfect in every way, can be a pain. In a serious application you might be willing to endure more pain and use a mutable array object, to ensure good performance.
