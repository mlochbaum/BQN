*View this file with graphs and stuff [here](https://mlochbaum.github.io/BQN/community/aoc.html).*

# Advent of Code

[Advent of Code 2024](https://adventofcode.com/2024) had 414 solutions published by 32 programmers, with a mix of new and returning programmers, even some who are back from 2022 after skipping a year!

<!--GEN
nam ← ⟨"Ramón Panadés","frasiyav","moussetf","NRK","dzaima","Tony Zorman","Rampoina","Tim Cooijmans","Marshall Bockrath","Caleb Quilley","Hannu Hartikainen","Conor Hoekstra","Antti Keränen","Armand Lynch","Jack Franklin","Madeline Vergani","dlozeve","Asher Harvey-Smith","Edward J. Schwartz","Tankor Smash","Manolo Martínez","David Zwitser","Erik Jonasson","Joshua Suskalo","pellertson","Mark Nelson","Mitchell Kember","LLLL Colonq","Peter Salvi","Ivan Ermakov","Jonas Lépine","Brian E"⟩
sol ← ⟨1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿17‿18‿19‿20‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿22‿23,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20,1‿2‿3‿4‿6‿7‿9‿10‿12‿13‿14‿15‿16‿18‿20‿21‿22‿23‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿18‿19‿22,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15,1‿2‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14,1‿2‿3‿4‿5‿6‿7‿8‿11‿13‿14‿17,1‿3‿5‿7‿9‿11‿13‿15‿17‿19,4‿5‿6‿7‿8‿9‿10‿11‿12‿17,1‿2‿3‿4‿5‿6‿7‿8‿9‿10,1‿2‿4‿5‿6‿7‿8‿9‿10,1‿2‿3‿4‿5‿6‿7‿8,1‿2‿7‿11‿13‿18‿19,1‿2‿3‿4,1‿2‿3,1‿2,1‿2,⟨4⟩,⟨4⟩,⟨2⟩,⟨1⟩,⟨1⟩⟩
als ← ⟨⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,16‿21,⟨⟩,⟨⟩,⟨⟩,⟨⟩,5‿8‿11‿17‿19‿24,⟨⟩,⟨22⟩,⟨⟩,⟨⟩,3‿15‿16‿17‿18‿22‿23,⟨⟩,2‿4‿8‿10‿12‿14‿16,1‿2‿3,⟨⟩,⟨3⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,1‿2‿3‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17,2‿3‿5‿7‿9‿11,⟨⟩⟩
link← ⟨"https://github.com/Panadestein/blog/tree/main/src/bqn","https://github.com/frasiyav/AoC2024","https://github.com/moussetf/AdventOfCode2024","https://codeberg.org/NRK/slashtmp/src/branch/master/AoC/2024","https://github.com/dzaima/aoc/tree/master/2024/BQN","https://github.com/slotThe/advent/tree/master/aoc2024/bqn-solutions","https://codeberg.org/Rampoina/aoc/src/branch/master/2024","https://github.com/cooijmanstim/advent2024","https://github.com/llasram/aoc2024","https://github.com/icendoan/aoc/tree/main/24","https://github.com/dancek/aoc2024","https://github.com/codereport/Advent-of-Code-2024","https://github.com/Detegr/aoc2024","https://github.com/linuxhd0/aoc2024","https://github.com/jhfranklin/aoc/tree/main/2024","https://github.com/RubenVerg/aoc2024","https://git.sr.ht/~dlozeve/advent-of-code/tree/main/item/2024","https://github.com/asherbhs/aoc/tree/main/2024","https://github.com/edmcman/advent-of-code-2024","https://github.com/tankorsmash/bqn_adventofcoded/tree/main/src/2024","https://github.com/manolomartinez/advent_of_code/tree/main/2024","https://github.com/DavidZwitser/Advent-of-Code-BQN-2024","https://github.com/coderguy57/AOC/tree/master/2024","https://git.sr.ht/~srasu/bqn-aoc/tree/main/item/src/aoc2024","https://github.com/pellertson/AOC/tree/master/2024","https://github.com/anadrome/aoc2024","https://github.com/mk12/aoc/tree/main/src/bqn","https://github.com/lcolonq/advent/tree/master/2024","https://github.com/salvipeter/advent2024","https://github.com/ivanjermakov/adventofcode/tree/master/aoc2024/src","https://github.com/TechnoJo4/aoc2024","https://github.com/Brian-ED/BQN-Advent-Of-Code/tree/main/2024"⟩

Ge ← "g"⊸At⊸Enc

w ← (w0←128) +           (tw←20) × 0.4+m←25
h ← (h0← 56) + (he←18) + (th←12) ×     n←≠nam
wh ← w‿h
out← 40‿10

pa ← "class=Paren|stroke=currentColor|fill=none"
rc ← At "class=code|stroke-width=1|rx=6"
gt ← "stroke-width=1|font-size=10px|fill=currentColor"
Path ← "path" Elt "d"⊸⋈⊘(⊣∾"d"⋈⊢)

Ct ← (/¯∞⊸»<-⟜1)⊸(⊏⋈¨«˜⟜≠-⊣)¨ -⟜1
Bp ← (0<≠¨)⊸/ (h0+th×0.25+↕n) (∾((w0+⊑∘⊢)∾⊣∾1⊑⊢)¨)¨ tw×Ct
Bars ← (Path·∾("M h"⥊˜≠)∾¨FmtNum)¨ Bp

((-out÷2)∾wh+out) SVG gt Ge ∾⥊¨ ⟨
  <"rect" Elt rc∾(Pos 0‿0)∾"width"‿"height"≍˘FmtNum wh
  pa Ge Path¨ <∘∾˘("M "⊸∾˘"VHH")∾¨FmtNum (w0‿0∾0≍˘⟨h0-6,h-he⟩)∾˘1‿2/⌽wh
  "text-anchor=middle" Ge ⟨
    ("text" Attr "font-size"‿"20px"∾Pos⟨w0+tw×m÷2,h0-32⟩) Enc "Day"
    "font-size=11px" Ge ⍉((w0+tw×0.5+↕m)Pos∘⋈⌜⟨h0-10,h+12-he⟩) "text"⊸Attr⊸Enc¨ FmtNum 1+↕25
  ⟩
  link ("a"Attr"xlink:href"⊸⋈)⊸Enc¨ (10 ("fill"‿"currentColor"∾Pos∘⋈)¨h0+th×0.5+↕n) "text"⊸Attr⊸Enc¨ nam
  "stroke-width=6|class=green|opacity=0.9" Ge Bars sol
  "stroke-width=6|class=red|opacity=0.2" Ge Bars als
⟩
-->

The number of BQN solutions for each of the 25 days is plotted below, along with totals from AoC's [stats page](https://adventofcode.com/2024/stats). The BQN solutions are scaled to be visible here: there are 4507 times more valid AoC submissions than published BQN solutions overall. This was an easier year than usual, but BQNators seem to have done very well. `•HashMap` is useful for many problems but was only released just before last year's AoC, so having it broadly available this year may have helped, and there was also a lot of [forum](forums.md) discussion to help people out of tough spots or work on improving finished solutions.

<!--GEN
aoc ← 259905‿215479‿174682‿138740‿119239‿106254‿87739‿75176‿73222‿64740‿67293‿55343‿51296‿48757‿43588‿35314‿36198‿32441‿32039‿27831‿21038‿26504‿25153‿24688‿23227
bqn ← 28‿26‿21‿24‿21‿21‿23‿20‿20‿19‿19‿17‿19‿17‿16‿12‿13‿13‿13‿10‿7‿11‿9‿7‿8

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

## Year 2023

[Advent of Code 2023](https://adventofcode.com/2023) had 227 solutions published by 31 programmers. Anyone cool has moved to [Uiua](https://www.uiua.org/), and also Github's new search leaves out tons of repositories so I can't find them as well as I did before. Below, problems solved in BQN are shown in green, and problems solved in other languages in faint red. Each name links to the repository where these are published.

<!--GEN
{
nam ← ⟨"dzaima","frasiyav","dlozeve","Jack Franklin","Rampoina","Donnie Mattingly","Manolo Martínez","Sylvia","Mark Nelson","Tim Marinin","Michael Percival","Caleb Quilley","Cheery Chen","Ryan Bethke","grhkm21","Jamie Bayne","Terrence Reilly","David Zwitser","Tyler","Conor Hoekstra","Zenna","Akshay Nair","Ethan Carlsson","Joshua Suskalo","Zack","Olivia Palmu","Giorgio Dell'Immagine","Eric Zhang","Max Siling","ven","Brian E"⟩
sol ← ⟨1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿18‿19‿20‿21‿22‿23,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿13‿14‿15‿16‿17‿18‿19‿21,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15,1‿2‿3‿4‿5‿6‿8‿9‿11‿16‿18,1‿2‿3‿4‿5‿6‿7‿9‿10‿11‿13,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11,1‿2‿4‿6‿7‿8‿9‿11‿12‿21,1‿2‿3‿4‿5‿6‿7‿8‿9‿11,1‿2‿3‿4‿5‿6‿7‿8‿9‿11,1‿2‿3‿4‿5‿6‿7‿8‿9,1‿2‿3‿4‿6‿7‿8,1‿2‿3‿4‿6‿7‿8,1‿2‿3‿4‿5‿6‿7,1‿2‿3‿4‿5‿6‿7,1‿2‿3‿4‿5‿6,1‿2‿3‿4‿5,1‿2‿3‿4,1‿4‿6,1‿2‿3,1‿2‿3,1‿2,1‿2,⟨9⟩,⟨4⟩,⟨3⟩,⟨2⟩,⟨1⟩,⟨1⟩,⟨1⟩⟩
als ← ⟨⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,⟨⟩,⟨⟩,⟨⟩,⟨⟩,2‿3‿5‿7,⟨4⟩,⟨⟩,⟨⟩,⟨⟩,1‿2‿3‿4‿5‿6‿7‿8‿10‿11‿12‿13‿14,1‿2‿3‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿4‿5‿6,1‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿23‿24‿25,2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,2‿3‿4,⟨⟩⟩
link← ⟨"https://github.com/dzaima/aoc/tree/master/2023/BQN","https://github.com/frasiyav/AoC2023","https://git.sr.ht/~dlozeve/aoc2023/tree","https://github.com/jhfranklin/aoc/tree/main/2023","https://codeberg.org/Rampoina/aoc/src/branch/master/2023","https://github.com/donniemattingly/aoc2023","https://github.com/manolomartinez/advent_of_code/tree/main/2023","https://github.com/saltysylvi/bqn-aoc/tree/main/2023","https://github.com/anadrome/aoc2023","https://github.com/timmarinin/aoc2023","https://github.com/mpizzzle/AdventOfCode/tree/master/2023","https://github.com/icendoan/aoc/tree/main/2023","https://github.com/qqii/advent-of-code-2023/tree/master","https://github.com/RKBethke/aoc23-bqn/tree/main/src","https://github.com/grhkm21/advent-of-code-2023/tree/master/bqn","https://github.com/qualiaa/aoc/tree/master/2023","https://github.com/terrencepreilly/advent/tree/main/2023","https://github.com/DavidZwitser/Advent-of-Code-BQN-2023","https://github.com/DataKinds/aoc2023","https://github.com/codereport/Advent-of-Code-2023","https://github.com/azenna/advent-of-code-2023/tree/main/bqn","https://github.com/phenax/adventure-of-coditudes-2023/tree/main/src","https://github.com/ethancarlsson/advent_2023/tree/master/solutions","https://git.sr.ht/~srasu/bqn-aoc/tree/main/item/src/aoc2023","https://github.com/zphixon/aoc2023/tree/main/src","https://github.com/RocketRace/aoc2023","https://github.com/gio54321/aoc-2023","https://github.com/ekzhang/aoc23-alpha.git","https://github.com/GoldsteinE/aoc2023","https://github.com/vendethiel/advent23","https://github.com/Brian-ED/BQN-Advent-Of-Code/tree/main/2023"⟩

Ge ← "g"⊸At⊸Enc

w ← (w0←128) +           (tw←20) × 0.4+m←25
h ← (h0← 56) + (he←18) + (th←12) ×     n←≠nam
wh ← w‿h
out← 40‿10

pa ← "class=Paren|stroke=currentColor|fill=none"
rc ← At "class=code|stroke-width=1|rx=6"
gt ← "stroke-width=1|font-size=10px|fill=currentColor"
Path ← "path" Elt "d"⊸⋈⊘(⊣∾"d"⋈⊢)

Ct ← (/¯∞⊸»<-⟜1)⊸(⊏⋈¨«˜⟜≠-⊣)¨ -⟜1
Bp ← (0<≠¨)⊸/ (h0+th×0.25+↕n) (∾((w0+⊑∘⊢)∾⊣∾1⊑⊢)¨)¨ tw×Ct
Bars ← (Path·∾("M h"⥊˜≠)∾¨FmtNum)¨ Bp

((-out÷2)∾wh+out) SVG gt Ge ∾⥊¨ ⟨
  <"rect" Elt rc∾(Pos 0‿0)∾"width"‿"height"≍˘FmtNum wh
  pa Ge Path¨ <∘∾˘("M "⊸∾˘"VHH")∾¨FmtNum (w0‿0∾0≍˘⟨h0-6,h-he⟩)∾˘1‿2/⌽wh
  "text-anchor=middle" Ge ⟨
    ("text" Attr "font-size"‿"20px"∾Pos⟨w0+tw×m÷2,h0-32⟩) Enc "Day"
    "font-size=11px" Ge ⍉((w0+tw×0.5+↕m)Pos∘⋈⌜⟨h0-10,h+12-he⟩) "text"⊸Attr⊸Enc¨ FmtNum 1+↕25
  ⟩
  link ("a"Attr"xlink:href"⊸⋈)⊸Enc¨ (10 ("fill"‿"currentColor"∾Pos∘⋈)¨h0+th×0.5+↕n) "text"⊸Attr⊸Enc¨ nam
  "stroke-width=6|class=green|opacity=0.9" Ge Bars sol
  "stroke-width=6|class=red|opacity=0.2" Ge Bars als
⟩
}
-->

The number of BQN solutions for each of the 25 days is plotted below, along with totals from AoC's [stats page](https://adventofcode.com/2023/stats). The BQN solutions are scaled to be visible here: there are 7931 times more valid AoC submissions than published BQN solutions overall.

<!--GEN
{
aoc ← 302721‿204376‿149346‿146999‿110548‿104504‿88553‿88039‿77006‿64760‿59194‿44979‿43011‿43478‿44565‿35924‿24659‿29299‿29240‿22214‿24004‿16406‿17105‿16304‿13132
bqn ← 27‿24‿21‿21‿15‿18‿15‿13‿13‿7‿11‿4‿5‿4‿4‿4‿2‿4‿3‿2‿4‿2‿2‿1‿1

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
}
-->

## Year 2022

[Advent of Code 2022](https://adventofcode.com/2022) was about twice the BQN event that 2021 was, with 406 solutions published by 46 programmers. Below, problems solved in BQN are shown in green, and problems solved in other languages in faint red. Each name links to the repository where these are published.

<!--GEN
{
nam ← ⟨"Tim Cooijmans","frasiyav","dzaima","sterni","Sylvia","Jack Franklin","Michael Percival","Caleb Quilley","Raghu R","Narazaki Shuji","Rampoina","Samuel","Joshua Suskalo","eissplitter","Dimitri Lozeve","Karim Elmougi","Mitchell Kember","Choram","Antti Keränen","Juuso Haavisto","Johnny","Olodus","N`hlest","Brian E","Hannu Hartikainen","Skye Soss","akamayu ouo","ynk","Toma","Dunya Kirkali","Perigord","James Sully","axelbdt","Ben Dean","dankeyy","Conor Hoekstra","Alpha Chen","David Cromp","Akshay Nair","Asher Harvey-Smith","extorious","Felix Riedel","Doug Kelkhoff","Adam Juraszek","calebowens","mycf"⟩
sol ← ⟨1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿15‿17‿18‿20‿21‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿21‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿18‿21,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿14‿15‿17‿18‿20,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿15‿16‿20‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿12‿14‿15‿21,3‿4‿5‿6‿7‿8‿12‿14‿17‿18‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13,1‿2‿3‿4‿5‿6‿8‿9‿10‿11‿18‿20,1‿2‿3‿4‿5‿6‿8‿9‿10‿11‿12‿13,1‿2‿3‿4‿5‿6‿7‿8‿10‿11‿12‿13,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11,1‿2‿3‿4‿5‿6‿7‿8‿9‿10,1‿2‿3‿4‿5‿6‿7‿8‿9‿10,1‿2‿3‿4‿5‿6‿7‿8‿9,1‿2‿3‿4‿6‿8‿9‿10,1‿2‿3‿4‿5‿6‿7‿8,5‿6‿7‿8‿9‿10‿11,1‿2‿3‿4‿5‿6‿7,2‿3‿4‿6‿8‿18,1‿2‿3‿4‿5‿6,1‿2‿3‿5‿12,1‿2‿6‿8‿10,1‿2‿3‿6‿8,1‿2‿3‿4‿6,9‿13‿14‿15,1‿3‿6‿8,1‿2‿3‿4,1‿2‿3‿4,1‿8‿9,1‿6‿8,1‿5‿6,1‿2‿3,1‿25,1‿2,1‿2,⟨6⟩,⟨4⟩,⟨3⟩,⟨2⟩,⟨1⟩⟩
als ← ⟨⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,16‿17‿18‿19‿20‿21‿22‿23‿24‿25,11‿12‿13‿14‿17‿18‿19‿21‿22‿23‿24,⟨⟩,1‿2‿9‿10‿11‿13‿15‿16‿19‿20‿21‿22,⟨⟩,⟨⟩,⟨7⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,⟨⟩,5‿7‿11,⟨⟩,1‿2‿3‿4,⟨⟩,⟨⟩,⟨⟩,4‿6‿7‿8‿9‿10‿11‿13‿14‿15‿16‿17‿18‿24‿25,3‿4‿5‿7‿9‿11‿12,4‿5‿7‿9‿10‿11‿12‿13‿15‿18‿20‿21‿23,⟨⟩,1‿2‿3‿4‿5‿6‿7‿8‿10‿11‿12‿16,2‿4‿5‿7‿9‿10‿11‿12‿13,⟨⟩,⟨⟩,2‿3‿4‿5‿6‿7‿10,2‿3‿4‿5,2‿3‿4‿7‿8‿9‿10‿11‿12‿13‿14‿15‿18‿20‿21‿23‿25,⟨⟩,2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿18‿20‿21‿23,⟨⟩,⟨⟩,1‿2‿3‿4‿5‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿20‿21,⟨⟩,1‿2‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿18‿22‿23‿24‿25,2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿18‿21‿25⟩
link← ⟨"https://github.com/cooijmanstim/advent2022","https://github.com/frasiyav/AoC2022","https://github.com/dzaima/aoc/tree/master/2022/BQN","https://code.tvl.fyi/tree/users/sterni/exercises/aoc/2022","https://github.com/saltysylvi/bqn-aoc2022","https://github.com/jhfranklin/aoc/tree/main/2022","https://github.com/mpizzzle/AdventOfCode/tree/master/2022","https://github.com/icendoan/aoc22","https://github.com/razetime/aoc/tree/main/22/bqn","https://github.com/shnarazk/advent-of-code/tree/main/bqn/2022","https://codeberg.org/Rampoina/aoc/src/branch/master/2022","https://github.com/SamuelSarle/advent/tree/master/adv_2022","https://git.sr.ht/~srasu/bqn-aoc/tree/main/item/src/aoc2022","https://github.com/eissplitter/aoc","https://github.com/dlozeve/aoc2022","https://github.com/karimElmougi/aoc/tree/master/2022","https://github.com/mk12/aoc/tree/main/src/bqn","https://github.com/Choram/AoC2022BQN","https://github.com/Detegr/aoc2022","https://github.com/jhvst/advent2022","https://github.com/devcordde/adventofcode-22","https://github.com/Olodus/advent_of_code2021/tree/main/2022","https://github.com/Nhlest/AoC2022/tree/main/bqn","https://github.com/Brian-ED/BQN-Advent-Of-Code/tree/main/2022","https://github.com/dancek/bqn-advent2022","https://github.com/Skyb0rg007/Advent-of-Code/tree/master/2022","https://github.com/akamayu-ouo/AoC/tree/master/2022","https://github.com/AugustUnderground/AoC2022","https://github.com/TomaSajt/AOC/tree/master/bqn/2022","https://github.com/dunyakirkali/aoc.bqn/tree/main/2022","https://github.com/Trouble-Truffle/Solutions/tree/main/AOC-2022","https://github.com/sullyj3/adventofcode2022","https://github.com/axelbdt/aoc/tree/main/2022/bqn","https://github.com/bddean/aoc/tree/main/2022","https://github.com/dankeyy/aoc22","https://github.com/codereport/Advent-of-Code-2022","https://github.com/kejadlen/advent-of-code/tree/main/2022/bqn","https://github.com/DavidCromp/aoc2022/tree/main/BQN","https://github.com/phenax/advent-of-coolio-2022","https://github.com/asherbhs/aoc2022","https://github.com/extorious/aoc2022","https://github.com/felixr/advent-of-code/tree/main/2022","https://github.com/dgkf/advent-of-code/tree/master/2022","https://github.com/juriad/advent2022","https://github.com/calebowens/Advent-of-code-RB-2022","https://github.com/0xmycf/Advent-of-code/tree/main/2022/bqn-22"⟩

Ge ← "g"⊸At⊸Enc

w ← (w0←128) +           (tw←20) × 0.4+m←25
h ← (h0← 56) + (he←18) + (th←12) ×     n←≠nam
wh ← w‿h
out← 40‿10

pa ← "class=Paren|stroke=currentColor|fill=none"
rc ← At "class=code|stroke-width=1|rx=6"
gt ← "stroke-width=1|font-size=10px|fill=currentColor"
Path ← "path" Elt "d"⊸⋈⊘(⊣∾"d"⋈⊢)

Ct ← (/¯∞⊸»<-⟜1)⊸(⊏⋈¨«˜⟜≠-⊣)¨ -⟜1
Bp ← (0<≠¨)⊸/ (h0+th×0.25+↕n) (∾((w0+⊑∘⊢)∾⊣∾1⊑⊢)¨)¨ tw×Ct
Bars ← (Path·∾("M h"⥊˜≠)∾¨FmtNum)¨ Bp

((-out÷2)∾wh+out) SVG gt Ge ∾⥊¨ ⟨
  <"rect" Elt rc∾(Pos 0‿0)∾"width"‿"height"≍˘FmtNum wh
  pa Ge Path¨ <∘∾˘("M "⊸∾˘"VHH")∾¨FmtNum (w0‿0∾0≍˘⟨h0-6,h-he⟩)∾˘1‿2/⌽wh
  "text-anchor=middle" Ge ⟨
    ("text" Attr "font-size"‿"20px"∾Pos⟨w0+tw×m÷2,h0-32⟩) Enc "Day"
    "font-size=11px" Ge ⍉((w0+tw×0.5+↕m)Pos∘⋈⌜⟨h0-10,h+12-he⟩) "text"⊸Attr⊸Enc¨ FmtNum 1+↕25
  ⟩
  link ("a"Attr"xlink:href"⊸⋈)⊸Enc¨ (10 ("fill"‿"currentColor"∾Pos∘⋈)¨h0+th×0.5+↕n) "text"⊸Attr⊸Enc¨ nam
  "stroke-width=6|class=green|opacity=0.9" Ge Bars sol
  "stroke-width=6|class=red|opacity=0.2" Ge Bars als
⟩
}
-->

The number of BQN solutions for each of the 25 days is plotted below, along with totals from AoC's [stats page](https://adventofcode.com/2022/stats). The BQN solutions are scaled to be visible here: there are 4842 times more valid AoC submissions than published BQN solutions overall.

<!--GEN
{
aoc ← 256181‿216402‿188454‿169211‿145588‿143103‿105620‿105066‿86105‿82936‿71690‿55014‿48181‿45716‿41487‿25845‿25051‿27531‿16105‿20732‿23484‿18213‿16578‿14345‿17381
bqn ← 38‿34‿33‿29‿26‿33‿21‿29‿22‿21‿15‿14‿12‿11‿12‿5‿6‿9‿3‿7‿7‿3‿4‿4‿8

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
}
-->

## Year 2021

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
{
nam ← ⟨"dzaima","Hannu","Raghu","frasiyav","Leah","Antti","Caleb","Alvin","Alex","Andrey","Johnny","Josh","Ben","Alastair","Olodus","Aren","Dimitri","Alexander","Mathias","m-lima","Dunya","Benjamin"⟩
sol ← ⟨1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿23‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿19‿20‿21‿22,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿13‿14‿15‿17‿18‿20‿21‿24‿25,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18‿20‿21,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17‿18,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14,1‿2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿13‿14,1‿2‿3‿5‿6‿7‿11‿12‿13‿15‿17‿20,1‿2‿3‿4‿5‿6‿7‿9‿10,1‿2‿3‿4‿5‿6‿7‿8,1‿2‿3‿4‿5‿6‿7,1‿3‿6‿7‿9,1‿2‿3‿9,6‿7‿9,1‿3,⟨3⟩,⟨3⟩,⟨1⟩,⟨1⟩,⟨1⟩⟩
als ← ⟨⟨⟩,⟨⟩,⟨⟩,⟨⟩,12‿16‿19‿22‿23,⟨⟩,⟨⟩,⟨⟩,⟨12⟩,⟨⟩,⟨8⟩,⟨⟩,⟨⟩,⟨2⟩,⟨⟩,1‿2‿3‿4‿5‿8‿10‿11‿12,2‿5‿6‿7‿9‿10‿12‿13‿14‿15‿16‿17‿20‿21,1‿2,1‿2,2‿3‿4‿5‿6‿7‿8‿9‿10‿11‿12‿13‿14‿15‿16‿17,⟨⟩,⟨⟩⟩

w ← (w0←90) + (tw←20) × 0.4+m←25
h ← (h0←56) + (th←18) ×     n←≠nam
wh ← w‿h

gt ← "stroke-width=1|font-size=14px|fill=currentColor"

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
}
-->

Some wrote about aspects of the Advent experience: Leah explained her solutions for [day 6](https://leahneukirchen.org/blog/archive/2021/12/counting-lanternfish-with-bqn-and-linear-algebra.html) and [day 9](https://leahneukirchen.org/blog/archive/2021/12/surveying-lava-basins-with-bqn-and-fixpoints.html), Hannu [reflected](https://hannuhartikainen.fi/blog/advent-of-bqn/) on the choice of BQN, and Raghu [commented on](https://razetime.github.io/blog/2022/01/09/aoc-bqn.html) each problem.

The number of BQN solutions for each of the 25 days is plotted below, along with totals from AoC's [stats page](https://adventofcode.com/2021/stats). The BQN solutions are scaled to be visible here: there are 6827 times more valid AoC submissions than published BQN solutions overall.

<!--GEN
{
aoc ← 217224‿181389‿159388‿103644‿90769‿91314‿86089‿76948‿71024‿63865‿56022‿48928‿49937‿50161‿39483‿32456‿32350‿23568‿15719‿21624‿24531‿20149‿14206‿11655‿14959
bqn ← 19‿14‿18‿12‿13‿15‿15‿10‿13‿10‿10‿8‿10‿9‿8‿6‿8‿7‿4‿7‿6‿4‿1‿3‿4

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
}
-->

The BQN counts fall off much less than the average. Most likely this is because programmers who decide to try AoC in a crazy new language like BQN tend to be more committed to the task, but BQN also has to meet some minimum bar to enable these crazy people to continue.

Just how okay is BQN? Hannu [made the case](https://hannuhartikainen.fi/blog/advent-of-bqn/) for optimism. Hannu writes that BQN's slogan "might be the best [further glowing praise/context]", in stark contrast to that time [Bryce and Conor agreed](https://adspthepodcast.com/2021/12/17/Episode-56.html) that it was a bad slogan. And Andrey offers [suspiciously positive comments](https://news.ycombinator.com/item?id=29521264) as well. The list includes "good text editor support", but Johnny remarked on the forums that he didn't manage a good editor/REPL setup—a second contradiction, meaning that I can now prove the Riemann hypothesis in *two* independent ways. Johnny also cited little support for string handling and low-information error messages as obstacles. I like that these aren't tied to the core language, and can eventually be improved, even though it won't be easy. dzaima complained about frequent confusion between functions and immediate blocks, and right-to-left folds being the much less useful direction. I dislike that dzaima is right a lot.

All three non-dzaimas of the last paragraph are essentially array outsiders, with little or no experience with languages like J or APL. In fact I think this describes the majority of Adventurers in BQN (although the list also includes array junkies like Raghu and Leah, and they've predictably made it further than most participants). Reaching out to a general programming audience wasn't initially a goal of BQN because I didn't think it *was* within reach. I realized this was wrong, and began to adjust course, in the early days, but am pleased to continue getting even more wrong.

With all this said, a handful of reports about recreational programming is a pretty poor basis for judging a programming language. Advent of Code was more useful as a checkup on BQN and its environment, resulting in fixes to documentation and implementation. And dzaima improved various aspects of performance as a way to cheat in speed battles with ngn/k.

BQN did do okay in terms of performance. At times programmers on the forum commented about having slow solutions (tens of seconds) or having to rewrite an obviously unsatisfactory algorithm. I don't think anyone mentioned having to switch languages for performance reasons, which is good news for an implementation as young as CBQN. But also not a surprise, as it's pretty fast with scalar code for an interpreter: about 10 times slower than C when I've measured it. Array code is usually faster, but can be slower. A particular problem was that in-place mutation `⌾(i⊸⊑)` is only fast for very simple cases. Of course, this problem only arises because BQN's arrays are immutable, highlighting that immutable arrays, despite being perfect in every way, can be a pain. In a serious application you might be willing to endure more pain and use a mutable array object, to ensure good performance.
