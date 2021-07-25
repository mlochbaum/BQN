*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/order.html).*

# Ordering functions

BQN has six functions that order arrays as part of their operation (the [comparison functions](arithmetic.md#comparisons) `≤<>≥` only order atoms, so they aren't included). These come in three pairs, where one of each pair uses an ascending ordering and the other uses a descending ordering.

- `∨∧`, Sort, rearranges the argument to order it
- `⍒⍋`, Grade, outputs the permutation that Sort would use to rearrange it
- `⍒⍋`, Bins, takes an ordered `𝕨` and determines where each cell of `𝕩` fits in this ordering.

The array ordering shared by all six is described last. For lists it's "dictionary ordering": two lists are compared one element at a time until one runs out, and the shorter one comes first in case of a tie. Operation values aren't ordered, so if an argument to an ordering function has a function or modifier somewhere in it then it will fail unless all the orderings can be decided without checking that value.

You can't provide a custom ordering function to Sort. The function would have to be called on one pair of cells at a time, which is contrary to the idea of array programming, and passing in a function with side effects could lead to implementation-specific behavior. Instead, build another array that will sort in the order you want (for example, by selecting or deriving the property you want to sort on). Then Grade it, and use the result to select from the original array.

## Sort

You've probably seen it before. Sort Up (`∧`) reorders the major cells of its argument to place them in ascending order, and Sort Down (`∨`) puts them in descending order. Every ordering function follows this naming convention—there's an "Up" version pointing up and a "Down" version going the other way.

        ∧ "delta"‿"alpha"‿"beta"‿"gamma"

        ∨ "δαβγ"

Sort Down always [matches](match.md) Sort Up [reversed](reverse.md), `⌽∘∧`. The reason for this is that BQN's array ordering is a [total order](https://en.wikipedia.org/wiki/Total_order), meaning that if one array doesn't come earlier or later that another array in the ordering then the two arrays match. Since any two non-matching argument cells are strictly ordered, they will have one ordering in `∧` and the opposite ordering in `∨`. With the reverse, any pair of non-matching cells are ordered the same way in `⌽∘∧` and `∨`. Since these two results have the same major cells in the same order, they match. However, note that the results will not always behave identically because Match doesn't take [fill elements](fill.md) into account (if you're curious, take a look at `⊑¨∨⟨↕0,""⟩` versus `⊑¨⌽∘∧⟨↕0,""⟩`).

## Grade

*See the [APL Wiki page](https://aplwiki.com/wiki/Grade) for a few more examples. BQN only has the monadic form.*

Grade is more abstract than Sort. Rather than rearranging the argument's cells immediately, it returns a list of indices (more precisely, a permutation) giving the ordering that would sort them.

        ⊢ l ← "planet"‿"moon"‿"star"‿"asteroid"

        ∧ l

        ⍋ l

Given our list `l` of things in a solar system, Sort Up orders them by size, or maybe alphabetically. What does `⍋l` do? Its result also orders these items, but instead of listing them directly, each element is the *index* of that cell in the argument. So the way to read it is that the first item in sorted order is cell `3` of the argument, `"asteroid"`. The second is cell `1`, `"moon"`, and the third—forget this, we made programming languages for a reason.

        (⍋l) ⊏ l

### Ordinals

So the elements of the Grade of an array correspond to the cells of that array after it's sorted. It's tempting if you don't have the sorted list handy to try to match them up with major cells of the original array, but this never makes sense—there's no relationship. However, applying Grade *twice* gives us a list that does correspond to the original argument quite usefully: it says, for each major cell of that argument, what rank it has relative to the others (smallest is 0, next is 1, and so on, breaking ties in favor of which cell comes earlier in the argument). Experienced APL programmers call this pattern the "ordinals" idiom.

        l ≍ ⍋⍋ l

How does it work? First, let's note that `⍋l` is a *permutation*: it contains exactly the numbers `↕≠l`, possibly in a different order. In other words, `∧⍋l` is `↕≠l`. Permuting an array rearranges the cells but doesn't remove or duplicate any. This implies it's always invertible: given a permutation `p`, some other permutation `q` will have `𝕩 ≡ q⊏p⊏𝕩` for every `𝕩` of the right length. This would mean that while `⍋l` transforms `l` to `∧l`, the inverse of `⍋l` transforms `∧l` back into `l`. That's what we want: for each cell of `l`, the corresponding number in the inverse of `⍋l` is what index that cell has after sorting.

But what's the inverse `q` of a permutation `p`? Our requirement is that `𝕩 ≡ q⊏p⊏𝕩` for any `𝕩` with the same length as `p`. Setting `𝕩` to `↕≠p` (the identity permutation), we have `(↕≠p) ≡ q⊏p`, because `p⊏↕≠p` is just `p`. But if `p` is a permutation then `∧p` is `↕≠p`, so our requirement could also be written `(∧p) ≡ q⊏p`. Now it's all coming back around again. We know exactly how to get `q`! Defining `q←⍋p`, we have `q⊏p ↔ (⍋p)⊏p ↔ ∧p ↔ ↕≠p`, and `q⊏p⊏𝕩 ↔ (q⊏p)⊏𝕩 ↔ (↕≠p)⊏𝕩 ↔ 𝕩`.

The fact that Grade Up inverts a permutation is useful in itself. Note that this applies to Grade Up specifically, and not Grade Down. This is because the identity permutation is ordered in ascending order. Grade Down would actually invert the reverse of a permutation, which is unlikely to be useful. So the ordinals idiom that goes in the opposite direction is actually not `⍒⍒` but `⍋⍒`. The initial grade is different, but the way to invert it is the same.

### Stability

When sorting an array, we usually don't care how matching cells are ordered relative to each other (although it's possible to detect it by using fill elements carefully. They maintain their ordering). Grading is a different matter, because often the grade of one array is used to order another one.

        ⊢ t ← >⟨ "dog"‿4, "ant"‿6, "pigeon"‿2, "pig"‿4 ⟩

        1 ⊏˘ t

        (1⊏˘t) ⍋⊸⊏ t

Here we order a table by its second column. Maybe in this case it's not a problem if "dog" and "pig" trade places. But unpredictability is never good—would you get the same results with a different implementation of BQN? And for many other applications of Grade the ordering of equal elements is important. So BQN specifies that matching cells are always ordered by their indices. The same rule applies for Grade Down, so that for example the grade in *either* direction of an array `𝕩` where all cells are the same is `↕≠𝕩`. One effect is that `⍋𝕩` is not always the same as `⌽⍒𝕩`, even though `∧𝕩` always matches `⌽∨𝕩`. And in the table below we can see that the numbers are all reversed but "dog" and "pig" stay in the same order.

        (1⊏˘t) ⍒⊸⊏ t

To see some of the possibilities of Grade, you might pick apart the following expression, which is used to reverse elements of the right argument in groups of the given length.

        (⌽⍒/3‿4‿5) ⊏ "012abcdABCDE"

## Bins

*There's also an [APL Wiki page](https://aplwiki.com/wiki/Interval_Index) on this function, but be careful as the Dyalog version has subtle differences.*

The two Bins functions are written with the same symbols `⍋` and `⍒` as Grade, but take two arguments instead of one. More complicated? A little, but once you understand Bins you'll find that it's a basic concept that shows up in the real world all the time.

Bins behaves like a [search function](search.md) with respect to rank: it looks up cells from `𝕩` relative to major cells of `𝕨`. However, there's an extra requirement: the left argument to Bins is already sorted according to whichever ordering is used. If it isn't, you'll get an error.

        5‿6‿2‿4‿1 ⍋ 3
        0‿3‿4‿7‿9 ⍒ 3

Given this, the simplest definition of `𝕨⍋𝕩` (or `𝕨⍒𝕩`) is that for each cell in `𝕩` of rank `(=𝕨)-1`, it counts the number of major cells from `𝕨` that come earlier in the ordering, or match that cell.

Why would that be useful? How about an example. A pinball machine has some high scores on it. You play, and your rank is the number of scores higher than yours (in this case, if you tie someone's score, you won't unseat them).

        hs ← 1e7×627‿581‿578‿553‿520  # High scores

        hs ⍒ 1e7×565‿322‿788‿627

A score of `565e7` sits between `578e7` and `553e7` at rank 3, `322e7` wouldn't make the list, `788e7` would beat everyone, and `627e7` would tie the high score but not beat it. The same principles apply to less spring-loaded things like character indices and line numbers (`𝕨` is the index of the start of each line), or percentage scores and letter grades on a test (`𝕨` is the minimum score possible for each grade). In each case, it's better to think of Bins not as a counting exercise but as finding "what bin" something fits into.

## Array ordering

Most of the time you won't need to worry about the details of how BQN arrays are ordered. It's documented here because, well, that's what documentation does.

The array ordering defines some arrays to be smaller or larger than others. All of the "Up" ordering functions use this ordering directly, so that smaller arrays come earlier, and the "Down" ones use the opposite ordering, with larger arrays coming earlier. For arrays consisting only of characters and numbers, with arbitrary nesting, the ordering is always defined. If an array contains an operation, trying to order it relative to another array might give an error. If comparing two arrays succeeds, there are three possibilities: the first array is smaller, the second is smaller, or the two arrays [match](match.md).

Comparing two atoms is defined to work the same way as the [comparison functions](arithmetic.md#comparisons) `≤<>≥`. Numbers come earlier than characters and otherwise these two types are ordered in the obvious way. To compare an atom to an array, the atom enclosing and then compared with the array ordering defined below. The result of this comparison is used except when the two arrays match: in that case, the atom is considered smaller.

Two arrays of the same shape are compared by comparing all their corresponding elements, in index order. This comparison can stop at the first pair of different elements (which allows later elements to contain operations without causing an error). If any elements were different, then they decide the result of the comparison. If all the elements matched, then by definition the two arrays match.

The principle for arrays of different shapes is the same, but there are two factors that need to be taken into account. First, it's not obvious any more what it means to compare corresponding elements—what's the correspondence? Second, the two arrays can't match because they have different shapes. So even if all elements end up matching one of them needs to come earlier.

BQN's *array ordering* is an extension of the number and character ordering given by `≤` to arrays. In this system, any two arrays consisting of only numbers and characters for atoms can be compared with each other. Furthermore, some arrays that contain incomparable atoms (operations) might be comparable, if the result of the comparison can be decided before reaching these atoms. Array ordering does not depend on the fill elements for the two arguments.

Let's discuss correspondence first. One way to think about how BQN makes arrays correspond is that they're simply laid on top of each other, lining up the first (as in `⊑`) elements. So a shape `⟨4⟩` array will match up with the first row of a shape `5‿3` array, but have an extra element off the end. A simple way to think about this is to say that the lower rank array is brought up to a matching rank by putting `1`s in front of the shape, and then lengths along each axis are matched up by padding the shorter array along that axis with a special "nothing" element. This "nothing" element will be treated as smaller than any actual array, because this rule recovers the "dictionary ordering" rule that a word that's a prefix of a longer word comes before that word. In the case of the shapes `⟨4⟩` and `5‿3`, if the three overlapping elements match then the fourth element comes from the first row and is present in the first array but not the second. So the shape `5‿3` array would be considered smaller without even looking at its other four rows.

It can happen that two arrays of different shape have all matching elements with this procedure: either because one array's shape is the same as the other's but with some extra `1`s at the beginning, or because both arrays are empty. In this case, the arrays are compared first by rank, with the higher-rank array considered larger, and then by shape, beginning with the leading axes.
