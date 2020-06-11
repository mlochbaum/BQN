# Group

BQN replaces the [Key](https://aplwiki.com/wiki/Key) operator from J or Dyalog APL, and [many forms of partitioning](https://aplwiki.com/wiki/Partition_representations), with a single (ambivalent) Group function `⊔`. This function is somewhat related to the K function `=` of the same name, but results in an array rather than a dictionary.

The BQN prototype does not implement this function: instead it uses `⊔` for a Group/Key function very similar to `{⊂⍵}⌸` in Dyalog APL, and also has a Cut function `\`. The new BQN Group on numeric arguments (equivalently, rank-1 results) can be defined like this:

    ⊔↩((↕1+(>⌈´))=¨<)∘⊣ /¨⟜< ↕∘≠⍠⊢

Once defined, the old BQN Key (dyadic) is `⍷⊸⊐⊸⊔` and Group (monadic) is `⍷⊸⊐⊔↕∘≠` using the Deduplicate or Unique Cells function `⍷` (BQN2NGN spells it `∪`). Cut on matching-length arguments is `` +`⊸⊔ ``.

## Definition

Group operates on a list of indices and a list of values to produce a list of groups of values (which are lists). The lists of indices and values have the same length, and each value is paired with the index at the same position. That index indicates the result group the value should go into, with an "index" of ¯1 indicating that the value should be dropped and not appear in the result.

        0‿1‿2‿0‿1 ≍ "abcde"  ⍝ Corresponding indices and values
    ┌
      0 1 2 0 1
      a b c d e
                ┘
        0‿1‿2‿0‿1 ⊔ "abcde"  ⍝ Values grouped by index
    [ [ ad ] [ be ] [ c ] ]

For example, we might choose to group a list of words by length. Within each group, values maintain the ordering they had in the list originally.

        phrase ← "BQN"‿"uses"‿"notation"‿"as"‿"a"‿"tool"‿"of"‿"thought"
        ⥊˘ ≠¨⊸⊔ phrase
    ┌
      []
      [ [ a ] ]
      [ [ as ] [ of ] ]
      [ [ BQN ] ]
      [ [ uses ] [ tool ] ]
      []
      []
      [ [ thought ] ]
      [ [ notation ] ]
                            ┘

(Could we define `phrase` more easily? See [below](#partitioning).)

If we'd like to ignore words of 0 letters, or more than 5, we can set all word lengths greater than 5 to 0, then reduce the lengths by 1. Two words end up with left argument values of ¯1 and are omitted from the result.

        1-˜≤⟜5⊸×≠¨phrase
    [ 2 3 ¯1 1 0 3 1 ¯1 ]
        ⥊˘ {1-˜≤⟜5⊸×≠¨𝕩}⊸⊔ phrase
    ┌
      [ [ a ] ]
      [ [ as ] [ of ] ]
      [ [ BQN ] ]
      [ [ uses ] [ tool ] ]
                            ┘

Note that the length of the result is determined by the largest index. So the result never includes trailing empty groups. A reader of the above code might expect 5 groups (lengths 1 through 5), but there are no words of length 5, so the last group isn't there.

When Group is called dyadically, the left argument is used for the indices and the right is used for values, as seen above. When it is called monadically, the right argument gives the indices and the values grouped are the right argument's indices, that is, `↕≠𝕩`.

        ⥊˘ ⊔ 2‿3‿¯1‿2
    ┌
      []
      []
      [ [ 0 ] [ 3 ] ]
      [ [ 1 ] ]
                      ┘

Here, the index 2 appears at indices 0 and 3 while the index 3 appears at index 1.

## Properties

Group is closely related to the inverse of Indices, `/⁼`. In fact, inverse Indices gives the number of elements in each group for monadic Group:

        ≠¨⊔ 2‿3‿1‿2
    [ 0 1 2 1 ]
        /⁼∧ 2‿3‿1‿2
    [ 0 1 2 1 ]

A related fact is that calling Indices on the result of Group sorts all the indices passed to Group (removing any ¯1s). This is a kind of counting sort.

        /≠¨⊔ 2‿3‿1‿¯1‿2
    [ 1 2 2 3 ]

Called dyadically, Group sorts the right argument according to the left and adds some extra structure. If this structure is removed with Join, Group can be thought of as a kind of sorting.

        ∾ 2‿3‿1‿¯1‿2 ⊔ "abcde"
    [ caeb ]
        2‿3‿1‿¯1‿2 {F←(0≤𝕨)⊸/ ⋄ 𝕨⍋⊸⊏○F𝕩} "abcde"
    [ caeb ]

Group can even be implemented with the same techniques as a bucket sort, which can be branchless and fast.

## Applications

The obvious application of Group is to group some values according to a known or computed property. If this property isn't an integer, it can be turned into one using Unique and Index Of (the combination `⍷⊸⊐` has been called "self-classify").

        ln ← "Phelps"‿"Latynina"‿"Bjørgen"‿"Andrianov"‿"Bjørndalen"
        co ← "US"    ‿"SU"      ‿"NO"     ‿"SU"       ‿"NO"
        ⥊˘ co ⍷⊸⊐⊸⊔ ln
    ┌
      [ [ Phelps ] ]
      [ [ Latynina ] [ Andrianov ] ]
      [ [ Bjørgen ] [ Bjørndalen ] ]
                                     ┘

If we would like a particular index to key correspondence, we can use a fixed left argument to Index Of.

        countries ← "IT"‿"JP"‿"NO"‿"SU"‿"US"
        countries ∾˘ co countries⊸⊐⊸⊔ ln
    ┌
      [ IT ] []
      [ JP ] []
      [ NO ] [ [ Bjørgen ] [ Bjørndalen ] ]
      [ SU ] [ [ Latynina ] [ Andrianov ] ]
      [ US ] [ [ Phelps ] ]
                                            ┘

However, this solution will fail if there are trailing keys with no values. To force the result to have a particular length you can append that length as a dummy index to each argument, then remove the last group after grouping.

        countries ↩ "IT"‿"JP"‿"NO"‿"SU"‿"US"‿"ZW"
        countries ∾˘ co countries{𝕗⊸⊐⊸(¯1↓⊔○(∾⟜(≠𝕗)))} ln
    ┌
      [ IT ] []
      [ JP ] []
      [ NO ] [ [ Bjørgen ] [ Bjørndalen ] ]
      [ SU ] [ [ Latynina ] [ Andrianov ] ]
      [ US ] [ [ Phelps ] ]
      [ ZW ] []
                                            ┘

### Partitioning

In examples we have been using a list of strings stranded together. Often it's more convenient to write the string with spaces, and split it up as part of the code. In this case, the index corresponding to each word (that is, each letter in the word) is the number of spaces before it. We can get this number of spaces from a prefix sum on the boolean list which is 1 at each space.

        ' '(+`∘=⊔⊢)"BQN uses notation as a tool of thought"
    [ [ BQN ] [  uses ] [  notation ] [  as ] [  a ] [  tool ] [  of ] [  thought ] ]

To avoid including spaces in the result, we should change the result index at each space to ¯1. Here is one way to do that:

        ' '((⊢-˜¬×+`)∘=⊔⊢)"BQN uses notation as a tool of thought"
    [ [ BQN ] [ uses ] [ notation ] [ as ] [ a ] [ tool ] [ of ] [ thought ] ]

A function with structural Under, such as `` {¯1¨⌾(𝕩⊸/)+`𝕩} ``, would also work.

In other cases, we might want to split on spaces, so that words are separated by any number of spaces, and extra spaces don't affect the output. Currently our function makes a new word with each space:

        ' '((⊢-˜¬×+`)∘=⊔⊢)"  string with  spaces   "
    [ [] [] [ string ] [ with ] [] [ spaces ] ]

However, trailing spaces are ignored because Group never produces trailing empty groups (to get them back we would use a dummy final character in the string). To avoid empty words, we should increase the word index only once per group of spaces. We can do this by taking the prefix sum of a list that is 1 only for a space with no space before it. To make such a list, we can use the [Windows](windows.md) function. We will extend our list with an initial 1 so that leading spaces will be ignored. Then we take windows of the same length as the original list: the first includes the dummy argument followed by a shifted copy of the list, and the second is the original list. These represent whether the previous and current characters are spaces; we want positions where the previous wasn't a space and the current is.

        ≍⟜(<´≠↕1∾⊢) ' '="  string with  spaces   "  ⍝ All, then filtered, spaces
    ┌
      1 1 0 0 0 0 0 0 1 0 0 0 0 1 1 0 0 0 0 0 0 1 1 1
      0 0 0 0 0 0 0 0 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0
        ≍⟜(⊢-˜¬×+`∘(<´≠↕1∾⊢))' '="  string with  spaces   "  ⍝ More processing
    ┌
       1  1 0 0 0 0 0 0  1 0 0 0 0  1  1 0 0 0 0 0 0  1  1  1
      ¯1 ¯1 0 0 0 0 0 0 ¯1 1 1 1 1 ¯1 ¯1 2 2 2 2 2 2 ¯1 ¯1 ¯1
                                                              ┘
        ' '((⊢-˜¬×+`∘(<´≠↕1∾⊢))∘=⊔⊢)"  string with  spaces   "  ⍝ Final result
    [ [ string ] [ with ] [ spaces ] ]
