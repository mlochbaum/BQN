*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/order.html).*

# Ordering functions

BQN has six functions that order arrays as part of their operation (the [comparison functions](arithmetic.md#comparisons) `≤<>≥` only order atoms, so they aren't included). These come in three pairs, where one of each pair uses an ascending ordering and the other uses a descending ordering.

- `∨∧`, Sort, puts major cells of `𝕩` in order
- `⍒⍋`, Grade, outputs the permutation that Sort would use to rearrange `𝕩`
- `⍒⍋`, Bins, takes an ordered `𝕨` and determines where each cell of `𝕩` fits in this ordering.

The array ordering shared by all six is described last. For lists it's "dictionary ordering": two lists are compared one element at a time until one runs out, and the shorter one comes first in case of a tie. Operation values aren't ordered, so if an argument to an ordering function has a function or modifier somewhere in it then it will fail unless all the orderings can be decided without checking that value.

You can't provide a custom ordering function to Sort. The function would have to be called on one pair of cells at a time, which is contrary to the idea of array programming, and passing in a function with side effects could lead to implementation-specific behavior. Instead, build another array that will sort in the order you want (for example, by selecting or deriving the property you want to sort on). Then Grade it, and use the result to select from the original array.

## Sort

You've probably seen it before. Sort Up (`∧`) reorders the [major cells](array.md#cells) of its argument to place them in ascending order, and Sort Down (`∨`) puts them in descending order. Every ordering function follows this naming convention—there's an "Up" version pointing up and a "Down" version going the other way.

        ∧ "delta"‿"alpha"‿"beta"‿"gamma"

        ∨ "δαβγ"

Sort Down always [matches](match.md) Sort Up [reversed](reverse.md), `⌽∘∧`. The reason for this is that BQN's array ordering is a [total order](https://en.wikipedia.org/wiki/Total_order), meaning that if one array doesn't come earlier or later than another array in the ordering then the two arrays match. Since any two non-matching argument cells are strictly ordered, they will have one ordering in `∧` and the opposite ordering in `∨`. After the reverse, any pair of non-matching cells are ordered the same way in `⌽∘∧` and `∨`. Since these two results have the same major cells in the same order, they match. However, note that the results will not always behave identically because Match doesn't take [fill elements](fill.md) into account (if you're curious, take a look at `1↑¨∨⟨↕0,""⟩` versus `1↑¨⌽∘∧⟨↕0,""⟩`).

## Grade

<!--GEN
d ← 60‿68
pad ← 1.3‿0.2

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-family=BQN,monospace|font-size=22px|text-anchor=middle"
cg ← "font-size=18px|text-anchor=end"
lg ← "class=lilac|stroke-width=2|stroke-linecap=round"
ig ← "fill=currentColor|font-size=14|opacity=0.8"
mg ← "fill=currentColor|font-size=22"
Gec ← "class="⊸∾⊸Ge¨⟜(<˘)
ci ← "Number"‿"String"

Text ← ("text" Attr "dy"‿"0.32em"∾(Pos d⊸×))⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d⊸×
Paths ← lg Ge Line∘+⟜(≍˘⟜-0.2⋈˜0.08×·÷´-˝˘)¨
Rp ← Pos⊸∾⟜("width"‿"height"≍˘FmtNum)○(d⊸×)

xt ← '''(∾∾⊣)¨"sort"
wt ← FmtNum wv ← ⍋xt

{
tx ← ↕∘≠ xt ⋄ y ← +`0.6‿1‿0.44
dim ← ⟨1.5+≠xt, 0.4+¯1⊑y⟩ ⋄ sh ← ¯1.8‿0
tp ← ⍉ tx ⋈⌜ y

((∾˜d)×((-∾+˜)pad)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ sh Rp dim
  Paths ≍⟜(¯1↓y)¨(wv⊏tx)⋈¨tx
  mg Ge (3⥊"String"⋈⊑ci) Gec tp Text¨ [xt,wt,wv⊏xt]
  ig Ge ("class="∾⊑ci) Ge (-⟜0‿0.33¨ Text¨ (FmtNum ↕≠xt)˙) ⊏tp
  cg Ge (¯0.8≍¨y) Text⟜Highlight¨ "𝕩"‿"⍋𝕩"‿"∧𝕩"
⟩
}
-->

Grade is more abstract than Sort. Rather than rearranging the argument's cells immediately, it returns a list of [indices](indices.md) (more precisely, a permutation) giving the ordering that would sort them.

        ⊢ l ← "planet"‿"moon"‿"star"‿"asteroid"

        ∧ l

        ⍋ l

Given our list `l` of things in a solar system, Sort Up orders them by size, or maybe alphabetically. What does `⍋l` do? Its result also orders these items, but instead of listing them directly, each element is the *index* of that cell in the argument. So the way to read it is that the first item in sorted order is cell `3` of the argument, `"asteroid"`. The second is cell `1`, `"moon"`, and the third—forget this, we made programming languages for a reason.

        (⍋l) ⊏ l

### Ordinals

<!--GEN
{
tx ← ↕∘≠ xt ⋄ y ← +`0.6‿1‿1
dim ← ⟨1.5+≠xt, 0.4+¯1⊑y⟩ ⋄ sh ← ¯1.8‿0
tp ← ⍉ tx ⋈⌜ y

((∾˜d)×((-∾+˜)pad)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ sh Rp dim
  Paths (⋈¨⟜tx˘(≍⟜⍋wv)⊏tx) ≍¨⟜<˘ 2↕y
  mg Ge ("String"<⊸∾ci) Gec tp Text¨ [xt,wt,FmtNum⍋wv]
  ig Ge (3⥊ci) Gec (-⟜(⋈⟜0.33¨0.035×↕≠xt) Text¨ (FmtNum ↕≠xt)˙)˘ tp
  cg Ge (¯0.8≍¨y) Text⟜Highlight¨ "𝕩"‿"⍋𝕩"‿"⍋⍋𝕩"
⟩
}
-->

So the elements of the Grade of an array correspond to the cells of that array after it's sorted. It's tempting if you don't have the sorted list handy to try to match them up with major cells of the original array, but this never makes sense—there's no relationship. However, applying Grade *twice* gives us a list that does correspond to the original argument quite usefully: it says, for each major cell of that argument, what rank it has relative to the others (smallest is 0, next is 1, and so on, breaking ties in favor of which cell comes earlier in the argument). Experienced APL programmers call this pattern the "ordinals" idiom.

        l ≍ ⍋⍋ l

How does it work? First, let's note that `⍋l` is a *permutation*: it contains exactly the numbers `↕≠l`, possibly in a different order. In other words, `∧⍋l` is `↕≠l`. Permuting an array rearranges the cells but doesn't remove or duplicate any. This implies it's always invertible: given a permutation `p`, some other permutation `q` will have `𝕩 ≡ q⊏p⊏𝕩` for every `𝕩` of the right length. This would mean that while `⍋l` transforms `l` to `∧l`, the inverse of `⍋l` transforms `∧l` back into `l`. That's what we want: for each cell of `l`, the corresponding number in the inverse of `⍋l` is what index that cell has after sorting.

But what's the inverse `q` of a permutation `p`? Our requirement is that `𝕩 ≡ q⊏p⊏𝕩` for any `𝕩` with the same length as `p`. Setting `𝕩` to `↕≠p` (the identity permutation), we have `(↕≠p) ≡ q⊏p`, because `p⊏↕≠p` is just `p`. But if `p` is a permutation then `∧p` is `↕≠p`, so our requirement could also be written `(∧p) ≡ q⊏p`. Now it's all coming back around again. We know exactly how to get `q`! Defining `q←⍋p`, we have `q⊏p ↔ (⍋p)⊏p ↔ ∧p ↔ ↕≠p`, and `q⊏p⊏𝕩 ↔ (q⊏p)⊏𝕩 ↔ (↕≠p)⊏𝕩 ↔ 𝕩`.

The fact that Grade Up inverts a permutation is useful in itself. Note that this applies to Grade Up specifically, and not Grade Down. This is because the identity permutation is ordered in ascending order. Grade Down would invert the reverse of a permutation, which is unlikely to be useful. So the ordinals idiom that goes in the opposite direction is actually not `⍒⍒` but `⍋⍒`. The initial grade is different, but the way to invert it is the same.

### Stability

When sorting an array, we usually don't care how matching cells are ordered relative to each other (although as mentioned above it's possible to detect it by using fill elements carefully. They maintain their ordering). Grading is a different matter, because often the grade of one array is used to order another one.

        ⊢ t ← [ "dog"‿4, "ant"‿6, "pigeon"‿2, "pig"‿4 ]

        1 ⊏˘ t

        (1⊏˘t) ⍋⊸⊏ t

Here we order a table by its second column. Maybe in this case it's not a problem if "dog" and "pig" trade places. But unpredictability is never good—would you get the same results with a different implementation of BQN? And for many other applications of Grade the ordering of equal elements is important. So BQN specifies that matching cells are always ordered by their indices. The same rule applies for Grade Down, so that for example the grade in *either* direction of an array `𝕩` where all cells are the same is `↕≠𝕩`. One effect is that `⍋𝕩` is not always the same as `⌽⍒𝕩`, even though `∧𝕩` always matches `⌽∨𝕩`. And in the table below we can see that the numbers are all reversed but "dog" and "pig" stay in the same order.

        (1⊏˘t) ⍒⊸⊏ t

To see some of the possibilities of Grade, you might pick apart the following expression, which is used to reverse elements of the right argument in groups of the given length.

        (⌽⍒/3‿4‿5) ⊏ "012abcdABCDE"

## Bins

<!--GEN
{
wt‿xt ← "bins"‿"grades"
b ← wt⍋xt
tx ← ↕∘≠ xt ⋄ y ← +`0.5‿1.6‿0.8
dim ← ⟨1.5+≠xt, 0.5+¯1⊑y⟩ ⋄ sh ← ¯1.8‿0
ig ← "fill=currentColor|font-size=16|opacity=0.8|class=Number"
pa ← "path"At"class=green|style=fill:none|stroke-width=2|stroke-linecap=round|opacity=0.9"

PD ← ∾∾¨⟜FmtNum
brk ← "m vm "PD 3×2‿¯6‿7‿0‿¯1
dot ← "hm hm h"⊸PD¨ (⊑d)×dl←(0.4⌾(¯1⊸⊑)⋈1⌾⊑) 7⥊0.12‿0.1‿0
bin ← ∾("M "PD d×(-0.27+´⊑dl)⋈0.25+⊑y)⌾⊑⥊(<brk)≍˘dot(1⌽⌽⊸∾)3⥊<"h"PD⟨6-˜⊑d⟩

qu ← <˘Text⟜""""¨ (2↑y)⋈˜¨¯0.25≍˘0.75-˜≠¨wt‿xt
tt ← qu ∾¨⌾(2⊸↑) y (⋈˜¨⟜(↕≠)Text¨⊢)¨ ⟨wt,xt,FmtNum b⟩

((∾˜d)×((-∾+˜)1‿0.2)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ sh Rp dim
  lg Ge (⋈¨⟜tx˘(0.6-˜b⊸⊏)⊸≍tx) (Line≍+·≍˘⟜-0.04×÷○(-´)⋈5˙)¨⟜<˘ 2↕0.34⊸+⌾⊑y
  pa Elt "d"‿bin
  mg Ge (1‿1‿0⊏ci) "class="⊸∾⊸Ge¨ tt
  ig Ge ((⋈⟜(0.39+⊑y)¨-⟜0.6) Text¨ FmtNum) ↕1+≠wt
  cg Ge (¯0.8≍¨y) Text⟜Highlight¨ "𝕨"‿"𝕩"‿"𝕨⍋𝕩"
⟩
}
-->

The two Bins functions are written with the same symbols `⍋` and `⍒` as Grade, but take two arguments instead of one. More complicated? A little, but once you understand Bins you'll find that it's a basic concept that shows up in the real world all the time.

Bins behaves like a [search function](search.md) with respect to rank: it looks up [cells](array.md#cells) from `𝕩` relative to major cells of `𝕨`. However, there's an extra requirement: the left argument to Bins must already be sorted according to whichever ordering is used. If it isn't, you'll get an error.

        5‿6‿2‿4‿1 ⍋ 3

        0‿3‿4‿7‿9 ⍒ 3

Given this, the simplest definition of `𝕨⍋𝕩` (or `𝕨⍒𝕩`) is that for each cell in `𝕩` of rank `(=𝕨)-1`, it counts the number of major cells from `𝕨` that come earlier in the ordering, or match that cell.

Why would that be useful? How about an example. A pinball machine has some high scores on it. You play, and your rank is the number of scores higher than yours (in this case, if you tie someone's score, you won't unseat them).

        hs ← 1e7×627‿581‿578‿553‿520  # High scores

        hs ⍒ 1e7×565‿322‿788‿627

A score of `565e7` sits between `578e7` and `553e7` at rank 3, `322e7` wouldn't make the list, `788e7` would beat everyone, and `627e7` would tie the high score but not beat it. The same principles apply to less spring-loaded things like character indices and line numbers (`𝕨` is the index of the start of each line), or percentage scores and letter grades on a test (`𝕨` is the minimum score possible for each grade). In each case, it's better to think of Bins not as a counting exercise but as finding "what bin" something fits into.

## Array ordering

Most of the time you won't need to worry about the details of how BQN arrays are ordered. It's documented here because, well, that's what documentation does.

BQN's *array ordering* is an extension of the number and character ordering given by `≤` to [arrays](array.md). In this system, any two arrays that have only numbers and characters for atoms can be compared with each other. Furthermore, some arrays that contain incomparable atoms (operations or namespaces) might be comparable, if the result of the comparison can be decided before reaching these atoms. Array ordering never depends on [fill elements](fill.md). If comparing two arrays succeeds, there are three possibilities: the first array is smaller, the second is smaller, or the two arrays [match](match.md). All of the "Up" ordering functions use this ordering directly, so that smaller arrays come earlier, and the "Down" ones use the opposite ordering, with larger arrays coming earlier.

Comparing two atoms is defined to work the same way as the [comparison functions](arithmetic.md#comparisons) `≤<>≥`. Numbers come earlier than characters and otherwise these two types are ordered in the obvious way. To compare an atom to an array, the atom is enclosed and then compared with the array ordering defined below. The result of this comparison is used except when the two arrays match: in that case, the atom is considered smaller.

Two arrays of the same shape are compared by comparing all their corresponding elements, in index order. This comparison stops at the first pair of different elements (which allows later elements to contain operations without causing an error). If any elements were different, then they decide the result of the comparison. If all the elements matched, then by definition the two arrays match.

The principle for arrays of different shapes is the same, but there are two factors that need to be taken into account. First, it's not obvious any more what it means to compare corresponding elements—what's the correspondence? Second, the two arrays can't match because they have different shapes. So even if all elements end up matching one of them needs to come earlier.

<!--GEN
{
a   ← ⟨ 'a'+⥊⟜(↕×´)3‿3, 2‿5⥊"abdeghjlpo" ⟩
dim ← 1.7‿0.6+⌈´s←⌽∘≢¨a ⋄ sh ← ¯1.2‿¯0.8
p   ← 0‿0.2 × <1.5‿1
cl  ← "class="⊸∾¨ "bluegreen"‿"yellow"
cc  ← "class=lilac|stroke-width=3"
cd  ← "class=red|stroke-width=3|style=fill:none"

((∾˜d)×((-∾+˜)1.6‿0.2)+sh∾dim) SVG ⟨
  "rect" Elt rc ∾ sh Rp dim
  cl ∾⟜"|stroke-width=2|opacity=0.4"⊸Ge¨ p ("rect"⊸Elt +⟜(⋈˜-÷2) Rp ⊢)¨ s
  g Ge cl Ge¨ p (<⊸+⟜(⋈˜⌜´·↕¨≢)Text¨⊢)¨ a
  ("rect"At cc) Elt (2÷˜+´p) (-⟜(÷⟜2)Rp 2‿0+⊢) 0.7‿0.8
  ("circle"At cd) Elt "r"‿"cx"‿"cy"≍˘FmtNum 22∾d×2‿0+2÷˜+´p
  "font-size=14|text-anchor=middle|fill=currentColor" Ge ⟨
    1.15‿0.62 Text "≤3 compared values"
    ⟨¯0.2‿2.5,4.4‿¯0.3⟩ Text⟜(∾⟜"×"⊸∾´FmtNum∘⌽)¨ s
  ⟩
⟩
}
-->

Let's discuss correspondence first. One way to think about how BQN makes arrays correspond is that they're simply laid on top of each other, lining up the first (as in `⊑`) elements. So a shape `⟨4⟩` array will match up with the first row of a shape `5‿3` array, but have an extra element off the end. A simple way to think about this is to say that the lower rank array is brought up to a matching rank by putting `1`s in front of the shape, and then lengths along each axis are matched up by padding the shorter array along that axis with a special "nothing" element. This "nothing" element will be treated as smaller than any actual array, because this rule recovers the "dictionary ordering" rule that a word that's a prefix of a longer word comes before that word. In the case of the shapes `⟨4⟩` and `5‿3`, if the three overlapping elements match then the fourth element comes from the first row and is present in the first array but not the second. So the shape `5‿3` array would be considered smaller without even looking at its other four rows.

It can happen that two arrays of different shape have all matching elements with this procedure: either because one array's shape is the same as the other's but with some extra `1`s at the beginning, or because both arrays are empty. In this case, the arrays are compared first by rank, with the higher-rank array considered larger, and then by shape, beginning with the leading axes.
