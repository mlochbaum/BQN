*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/selfcmp.html).*

# Self-search functions

<!--GEN
d ← 48‿22

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "font-family=BQN,monospace|font-size=18px|text-anchor=middle"
hg ← "class=purple|stroke-width=0|opacity=0.5"
cg ← "font-size=24px"
lg ← "stroke-width=0.5|stroke=currentColor|fill=none"

xl ← ≠ xc ← ⊐ xt ← '''(Highlight∾∾⊣)¨"mississippi"
xn ← ≠ xu ← xt /˜ xf ← 0= xo ← ⊒ xt

Text ← ("text" Attr "dy"‿"0.32em"∾(Pos d⊸×))⊸Enc
Path ← "path" Elt "d"⋈·∾⊣∾¨·FmtNums(d⊏˜∊⟜" Vv")⊸×
Rp ← Pos⊸∾⟜("width"‿"height"≍˘FmtNum)○(d⊸×)

tx ← ↕xl ⋄ y ← » yd ← +`0.6+1.2‿1‿xn‿1.8‿1.8
dim ← ⟨1.5+xl,¯1⊑yd⟩ ⋄ sh ← ¯1.6‿¯1.1
tp ← (⥊tx≍¨⎉1((¯1↓y)+0‿0‿1‿0×⌜xc))∾(↕≠xu)≍¨¯1⊑y
hp ← 0.2‿¯0.7(+⟜(1‿0×sh)≍¯2⊸×⊸+)1‿0×dim
Pp ← "M VL M H" Path {⟨𝕩,⊑y,0.3+3⊑y,𝕨,0.5-˜4⊑y,𝕩,𝕨+2⊑y,xl-0.6⟩}

defs ← "defs" Enc ("mask"At"id=m") Enc ⟨
  "rect" Elt "fill"‿"white" ∾ sh Rp dim
  "fill=black" Ge ("rect" Elt (- Rp 2×⊢)⟜(7‿10÷d))¨ 0‿0.1⊸+¨⌾(xl⊸↑)tp
⟩

((∾˜d)×((-∾+˜)0.8‿0.4)+sh∾dim) SVG defs ∾ g Ge ⟨
  "rect" Elt rc ∾ sh Rp dim
  hg Ge ("rect" Elt ·Rp˝ {𝕩⊸+⌾(1⊑⊏)hp})¨ 1‿3⊏y
  (lg∾"|mask=url(#m)") Ge (↕≠xu) Pp¨ xf / tx
  tp Text¨ xu ∾˜ ⥊ xt ∾ Highlight∘•Repr¨ >xc‿xo‿xf
  cg Ge (¯0.05+¯1≍¨(2÷˜xn-1)⊸+⌾(2⊸⊑)y) Text⟜Highlight¨ "𝕩"<⊸∾⥊¨"⊐⊒∊⍷"
⟩
-->

BQN has four self-search functions, Classify (`⊐`), Occurrence Count (`⊒`), Mark Firsts (`∊`), and Deduplicate (`⍷`). Each of these is a monadic function that obtains its result by comparing each major cell of the argument (which must have rank at least 1) to the earlier major cells with [match](match.md). For example, Mark Firsts indicates the cells that don't match any earlier cell, making them the first of their kind.

        ∊ "abaacb"

When the argument is a list, its major cells are units and thus contain one element each, so it's just as valid to say that a self-search function compares elements of its argument. Only with a higher-rank argument does the major cell nature become apparent.

        ⊢ arr ← >"abc"‿"dcb"‿"abc"‿"bcd"‿"dcb"
        ∊ arr

The result has one number for each major cell, or in other words is a list with the same length as its argument. Three self-search functions follow this pattern, but Deduplicate (`⍷`) is different: it returns an array of the same rank but possibly a shorter length than the argument.

## Classify

Classify is the universal self-search function, in that it preserves all the self-search information in its argument. It gives each different cell value a natural number, ordered by first appearance.

        ⊐ 5‿6‿2‿2‿5‿1

[Coupling](couple.md) the argument to the result shows how values are numbered. Each `5` is `0` in the result, each `6` is `1`, `2` is `2` in this particular case, and `1` is `3`.

        ≍⟜⊐ 5‿6‿2‿2‿5‿1

Applying Classify before another self-search function will never change the result, except in the case of Deduplicate (`⍷`), which constructs its result from cells in the argument. In particular, Classify is [idempotent](https://en.wikipedia.org/wiki/Idempotent), meaning that applying it twice is the same as applying it once.

        ∊   "dbaedcbcecbcd"
        ∊ ⊐ "dbaedcbcecbcd"

        {(𝕏≡𝕏∘⊐)"dbaedcbcecbcd"}¨ ⊐‿⊒‿∊‿⍷

### Classify and Deduplicate

Classify is also related to [Deduplicate](#deduplicate). In a way they are complements: applying both in sequence always gives a completely uninteresting result!

        ⊢ c ← >"yellow"‿"orange"‿"yellow"‿"purple"‿"orange"‿"yellow"
        ⍷ ⊐ c
        ⊐ ⍷ c

Applying both separately, in contrast, gives completely interesting results. These results contain all information from the original argument, as `⍷` indicates which cells it contained and `⊐` indicates where they were located. The function [Select](select.md) (`⊏`) reconstructs the argument from the two values.

        ⍷ c
        ⊐ c
        (⊐c) ⊏ (⍷c)

One way to view this relationship is to consider an idea from linear algebra, where an idempotent transformation is called a "projection". That means that the argument might be any value but the result is part of a smaller class of values, and any argument from that smaller class is left the same. What arrays do the two functions project to? The result of Deduplicate is an array with no repeated major cells. The result of Classify is a list of natural numbers, but it also has an additional property: each number in the list is at most one higher than the previous numbers, and the first number is zero. This comes from the way Classify numbers the cells of its argument. When it finds a cell that hasn't appeared before (at a lower index), it always chooses the next higher number for it.

Applying both Classify and Deduplicate gives an array that has both properties (this isn't the case for all pairs of projections—we need to know that Classify maintains the uniqueness property for Deduplicate and vice-versa). It has no duplicate major cells, *and* it's a list of natural numbers that starts with 0 and never goes up by more than one. Taken together, these are a tight constraint! The first element of the argument has to be 0. The next can't be 0 because it's already appeared, but it can't be more than one higher—it has to be 1. The next can't be 0 or 1, and has to be 2. And so on. So the result is always `↕n` for some `n`. In fact it's possible to determine the length as well, by noting that each function preserves the number of unique major cells in its argument. Classify does this because distinct numbers in the output correspond exactly to distinct major cells in the input; Deduplicate does this because it only removes duplicate cells, not distinct ones. So the final result is `↕n`, where `n` is the number of unique major cells in the argument.

### Mark Firsts

*See the [APL Wiki page](https://aplwiki.com/wiki/Unique_Mask) on this function as well.*

Mark Firsts (`∊`) is the simplest self-search function: it returns `0` for any major cell of the argument that is a duplicate of an earlier cell and `1` for a major cell that's the first with its value. To implement [Deduplicate](#deduplicate) in terms of Mark Firsts, just [filter](replicate.md) out the duplicates with `∊⊸/`.

        ∊   3‿1‿4‿1‿5‿9‿2‿6‿5

        ∊⊸/ 3‿1‿4‿1‿5‿9‿2‿6‿5

Mark Firsts has other uses, of course. Instead of keeping the unique values, you might remove the first of each value with `¬∘∊⊸/`. You can use `∧´∊` to check that an array has no duplicate major cells, or `+´∊` to count the number of unique ones.

What about marking the elements that appear exactly once? There's a trick for this: find the cells that are firsts running both forwards (`∊`) and [backwards](reverse.md) (`∊⌾⌽`). Such a cell has no equal before it, nor after it, so it's unique in the entire array.

        (∊∧∊⌾⌽) "duck"‿"duck"‿"teal"‿"duck"‿"goose"

Remember that you don't have to apply the result of Mark Firsts to the same array you got it from! For example, it might be useful in a database application to find unique values in a particular column but use these to filter the entire table, or one other column.

### Occurrence Count

Occurrence Count (`⊒`) is a somewhat more sophisticated take on the idea behind Mark Firsts: instead of just testing whether a cell is a duplicate, it returns a number indicating how many previous cells match it. This means that Mark Firsts can be implemented with `0=⊒`.

        ⊒   2‿7‿1‿8‿1‿7‿1‿8‿2‿8‿4

        ≍⟜⊒ 2‿7‿1‿8‿1‿7‿1‿8‿2‿8‿4

        0=⊒ 2‿7‿1‿8‿1‿7‿1‿8‿2‿8‿4  # First appearances marked

While Occurrence Count maintains more information than Mark Firsts, it's still not as much as [Classify](#classify). We can swap many digits around while keeping the occurrence counts the same; Classify would detect these changes.

        ⊒   7‿1‿2‿8‿7‿1‿1‿2‿8‿8‿4

One easy example with Occurrence count is to take a list that has duplicates and return exactly one copy of each duplicate element. Taking each value where the count is 1 ensures that the result has no duplicates, and that every cell that appears twice or more in the argument is represented in the result, since the second occurrence has count 1. Results are ordered by the position of these second occurrences, so a different method might be needed if the ordering is important.

        (1=⊒)⊸/ "aaaabcddcc"

An interesting combination is Occurrence Count applied to the result of [Indices](replicate.md#indices) (`/`). The result counts up to each number from the argument in turn; in other symbols, it's `∾↕¨`. This version is interesting because it doesn't create any nested arrays, just lists of natural numbers.

        ⊒ / 2‿3‿4

A more efficient way when `⊒` doesn't have a fast implementation is `` /(¯1⊸⊑↕⊸-⊏⟜»)+` ``, but that's clearly quite a bit more complicated.

### Deduplicate

*There's also an [APL Wiki page](https://aplwiki.com/wiki/Unique) on this function.*

Deduplicate removes every major cell from the argument that matches an earlier cell, resulting in an array with the same rank but possibly a shorter length. It might also be described as returning the unique major cells of the argument, ordered by first occurrence. Deduplicate Under Reverse (`⍷⌾⌽`) orders by last occurrence instead.

        ⍷ >"take"‿"drop"‿"drop"‿"pick"‿"take"‿"take"

        ⍷⌾⌽ >"take"‿"drop"‿"drop"‿"pick"‿"take"‿"take"

The relationship between Classify and Deduplicate is discussed [above](#classify-and-deduplicate).
