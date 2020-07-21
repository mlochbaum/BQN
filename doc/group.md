*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/group.html).*

# Group

BQN replaces the [Key](https://aplwiki.com/wiki/Key) operator from J or Dyalog APL, and [many forms of partitioning](https://aplwiki.com/wiki/Partition_representations), with a single (ambivalent) Group function `⊔`. This function is somewhat related to the K function `=` of the same name, but results in an array rather than a dictionary.

The BQN prototype does not implement this function: instead it uses `⊔` for a Group/Key function very similar to `{⊂⍵}⌸` in Dyalog APL, and also has a Cut function `\`. The new BQN Group on numeric arguments (equivalently, rank-1 results) can be defined like this:

    ⊔↩((↕1+(>⌈´))=¨<)∘⊣ /¨⟜< ↕∘≠⍠⊢

Once defined, the old BQN Key (dyadic) is `⍷⊸⊐⊸⊔` and Group (monadic) is `⍷⊸⊐⊔↕∘≠` using the Deduplicate or Unique Cells function `⍷` (BQN2NGN spells it `∪`). Cut on matching-length arguments is `` +`⊸⊔ ``.

## Definition

Group operates on a numeric list of indices and an array, treated as a list of its major cells or "values", to produce a list of groups, each of which is a selection from those cells. The two arrays have the same length, and each value cell is paired with the index at the same position. That index indicates the result group the cell should go into, with an "index" of ¯1 indicating that it should be dropped and not appear in the result.

        0‿1‿2‿0‿1 ≍ "abcde"  # Corresponding indices and values
        0‿1‿2‿0‿1 ⊔ "abcde"  # Values grouped by index

For example, we might choose to group a list of words by length. Within each group, cells maintain the ordering they had in the list originally.

        phrase ← "BQN"‿"uses"‿"notation"‿"as"‿"a"‿"tool"‿"of"‿"thought"
        ⥊˘ ≠¨⊸⊔ phrase

(Could we define `phrase` more easily? See [below](#partitioning).)

If we'd like to ignore words of 0 letters, or more than 5, we can set all word lengths greater than 5 to 0, then reduce the lengths by 1. Two words end up with left argument values of ¯1 and are omitted from the result.

        1 -˜ ≤⟜5⊸× ≠¨ phrase
        ⥊˘ {1-˜≤⟜5⊸×≠¨𝕩}⊸⊔ phrase

Note that the length of the result is determined by the largest index. So the result never includes trailing empty groups. A reader of the above code might expect 5 groups (lengths 1 through 5), but there are no words of length 5, so the last group isn't there.

When Group is called dyadically, the left argument is used for the indices and the right is used for values, as seen above. When it is called monadically, the right argument, which must be a list, gives the indices and the values grouped are the right argument's indices, that is, `↕≠𝕩`.

        ⥊˘ ⊔ 2‿3‿¯1‿2

Here, the index 2 appears at indices 0 and 3 while the index 3 appears at index 1.

### Multidimensional grouping

Dyadic Group allows the right argument to be grouped along multiple axes by using a nested left argument. In this case, the left argument must be a list of numeric lists, and the result has rank `≠𝕨` while its elements—as always—have the same rank as `𝕩`. The result shape is `1+⌈´¨𝕨`, while the shape of element `i⊑𝕨⊔𝕩` is `i+´∘=¨𝕨`. If every element of `𝕨` is sorted ascending and contains only non-negative numbers, we have `𝕩≡∾𝕨⊔𝕩`, that is, Join is the inverse of Partition.

Here we split up a rank-2 array into a rank-2 array of rank-2 arrays. Along the first axis we simply separate the first pair and second pair of rows—a partition. Along the second axis we separate odd from even indices.

        ⟨0‿0‿1‿1,0‿1‿0‿1‿0‿1‿0⟩⊔(10×↕4)+⌜↕7

Each group `i⊑𝕨⊔𝕩` is composed of the cells `j<¨⊸⊏𝕩` such that `i≢j⊑¨𝕨`. The groups retain their array structure and ordering along each argument axis. Using multidimensional Replicate we can say that `i⊑𝕨⊔𝕩` is `(i=𝕨)/𝕩`.

The monadic case works similarly: Group Indices always satisfies `⊔𝕩 ←→ 𝕩⊔↕≠⚇1𝕩`. As with `↕`, the depth of the result of Group Indices is always one greater than that of its argument. A depth-0 argument is not allowed.

## Properties

Group is closely related to the inverse of Indices, `/⁼`. In fact, inverse Indices called on the index argument gives the length of each group:

        ≠¨⊔ 2‿3‿1‿2
        /⁼∧ 2‿3‿1‿2

A related fact is that calling Indices on the result of Group sorts all the indices passed to Group (removing any ¯1s). This is a kind of counting sort.

        /≠¨⊔ 2‿3‿1‿¯1‿2

Called dyadically, Group sorts the right argument according to the left and adds some extra structure. If this structure is removed with Join, Group can be thought of as a kind of sorting.

        ∾ 2‿3‿1‿¯1‿2 ⊔ "abcde"
        2‿3‿1‿¯1‿2 {F←(0≤𝕨)⊸/ ⋄ 𝕨⍋⊸⊏○F𝕩} "abcde"

Group can even be implemented with the same techniques as a bucket sort, which can be branchless and fast.

## Applications

The obvious application of Group is to group some values according to a known or computed property. If this property isn't an integer, it can be turned into one using Unique and Index Of (the combination `⍷⊸⊐` has been called "self-classify").

        ln ← "Phelps"‿"Latynina"‿"Bjørgen"‿"Andrianov"‿"Bjørndalen"
        co ← "US"    ‿"SU"      ‿"NO"     ‿"SU"       ‿"NO"
        ⥊˘ co ⍷⊸⊐⊸⊔ ln

If we would like a particular index to key correspondence, we can use a fixed left argument to Index Of.

        countries ← "IT"‿"JP"‿"NO"‿"SU"‿"US"
        countries ∾˘ co countries⊸⊐⊸⊔ ln

However, this solution will fail if there are trailing keys with no values. To force the result to have a particular length you can append that length as a dummy index to each argument, then remove the last group after grouping.

        countries ↩ "IT"‿"JP"‿"NO"‿"SU"‿"US"‿"ZW"
        countries ∾˘ co countries{𝕗⊸⊐⊸(¯1↓⊔○(∾⟜(≠𝕗)))} ln

### Partitioning

In examples we have been using a list of strings stranded together. Often it's more convenient to write the string with spaces, and split it up as part of the code. In this case, the index corresponding to each word (that is, each letter in the word) is the number of spaces before it. We can get this number of spaces from a prefix sum on the boolean list which is 1 at each space.

        ' '(+`∘=⊔⊢)"BQN uses notation as a tool of thought"

To avoid including spaces in the result, we should change the result index at each space to ¯1. Here is one way to do that:

        ' '((⊢-˜¬×+`)∘=⊔⊢)"BQN uses notation as a tool of thought"

A function with structural Under, such as `` {¯1¨⌾(𝕩⊸/)+`𝕩} ``, would also work.

In other cases, we might want to split on spaces, so that words are separated by any number of spaces, and extra spaces don't affect the output. Currently our function makes a new word with each space:

        ' '((⊢-˜¬×+`)∘=⊔⊢)"  string with  spaces   "

However, trailing spaces are ignored because Group never produces trailing empty groups (to get them back we would use a dummy final character in the string). To avoid empty words, we should increase the word index only once per group of spaces. We can do this by taking the prefix sum of a list that is 1 only for a space with no space before it. To make such a list, we can use the [Windows](windows.md) function. We will extend our list with an initial 1 so that leading spaces will be ignored. Then we take windows of the same length as the original list: the first includes the dummy argument followed by a shifted copy of the list, and the second is the original list. These represent whether the previous and current characters are spaces; we want positions where the previous wasn't a space and the current is.

        ≍⟜(<˝≠↕1∾⊢) ' '="  string with  spaces   "  # All, then filtered, spaces
        ≍⟜(⊢-˜¬×+`∘(<˝≠↕1∾⊢))' '="  string with  spaces   "  # More processing
        ' '((⊢-˜¬×+`∘(<˝≠↕1∾⊢))∘=⊔⊢)"  string with  spaces   "  # Final result
