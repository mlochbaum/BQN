*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/group.html).*

# Group

BQN replaces the Key operator from J or Dyalog APL, and [many forms of partitioning](https://aplwiki.com/wiki/Partition_representations), with a single (ambivalent) Group function `⊔`. This function is somewhat related to the K function `=` of the same name, but results in an array rather than a dictionary.

<!--GEN
Num ← ·Highlight •Repr
Str ← ·Highlight '"'(∾∾⊣)⊢
wf ← Num¨ wv ← 0‿¯1‿¯1‿2‿0
xf ← Str¨ xv ← "zero"‿"one"‿"two"‿"three"‿"four"
zi ← ↕≠ zf ← wv⊔xf
d ← 80‿28
Pos ↩ Pos d⊸×
dim ← 7‿7.3
sh  ← 0.6‿0

rc ← At "class=code|stroke-width=1|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "text-anchor=middle|font-family=BQN,monospace"
dg ← "font-size=24px|text-anchor=start|fill=currentColor|opacity=0.9"
tg ← "font-size=18px"
cg ← "font-size=16px|text-anchor=end"
lg ← "class=yellow|stroke-width=2"
bg ← "class=green|stroke-width=1.5|style=fill:none"

C ← (↕-2÷˜-⟜1)∘≠
zgp ← (2÷˜»⊸+-⊢´)+`0.6+≠¨zf
zp ← zgp + C¨ zf

Text ← ("text" Attr Pos)⊸Enc
ty‿txf‿tt ← ⟨
  +`¯2.3‿1‿3‿1.3
  ⟨C,  C,  ∾zp, zgp⟩
  ⟨wf, xf, ∾zf, Num¨zi⟩
⟩
tp ← (tx←txf{𝕎𝕩}¨tt)≍¨¨ty
lp ← (∾wv⊸⊔)⊸(((0.2‿¯0.5×⌜0‿1)+≍)¨)´1‿2⊏tp
b ← (0.4⌈0.2+≠¨zf) {∾"M vhv"∾¨FmtNum (0‿1‿1‿0‿1⊏d)×(⟨𝕨÷¯2,¯1.8⟩+𝕩)∾⟨1,𝕨,¯1⟩}¨ 3⊑tp

((∾˜d)×(-⊸∾0‿0.6)+(¯2÷˜sh⊸+)⊸∾1‿0.2+dim) SVG g Ge ⟨
  "rect" Elt rc ∾ (Pos -dim÷2)∾"width"‿"height"≍˘FmtNum d×dim-sh
  dg Ge (¯1.2+⊑⊑tp) Text "Group"
  tg Ge ∾tp Text¨○∾ tt
  cg Ge ((¯0.8+⊑⊑tx)≍¨3↑ty) Text⟜Highlight¨ "𝕨"‿"𝕩"‿"𝕨⊔𝕩"
  lg Ge (<"xy"≍⌜"12") ("line" Elt ≍˘○⥊)⟜(FmtNum d×⍉)¨ lp
  bg Ge ("path" Elt "d"⋈⊢)¨ b
⟩
-->

## Definition

Group operates on a list of atomic-number [indices](indices.md) `𝕨` and an array `𝕩`, treated as a list of its major cells, to produce a list of groups, each containing some of the cells from `𝕩`. The two arguments have the same length, and each cell in `𝕩` is paired with the index in `𝕨` at the same position, which indicates which result group should include that cell.

        0‿1‿2‿0‿1 ≍ "abcde"  # Corresponding indices and values
        0‿1‿2‿0‿1 ⊔ "abcde"  # Values grouped by index

A few extra options can be useful in some circumstances. First, an "index" of `¯1` in `𝕨` indicates that the corresponding cell should be dropped and not appear in the result. Second, `𝕨` is allowed to have an extra element after the end, which gives a minimum length for the result: otherwise, the result will be just long enough to accomodate the highest index in `𝕨`.

        0‿¯1‿2‿2‿¯1 ⊔ "abcde"  # Drop c and e
        0‿1‿2‿2‿1‿6 ⊔ "abcde"  # Length-6 result

A third extension is that `𝕨` doesn't really have to be a list: if not, then it groups `-=𝕨`-cells of `𝕩` instead of just `¯1`-cells. These cells are placed in index order. This extension isn't compatible with the second option from above, because it's usually not possible to add just one extra element to a non-list array. One usage is to group the diagonals of a table. See if you can figure out how the code below does this.

        ⊢ a ← 'a'+⥊⟜(↕×´)3‿5
        (+⌜´·↕¨≢)⊸⊔ a

For a concrete example, we might choose to group a list of words by length. Within each group, cells maintain the ordering they had in the list originally.

        phrase ← "BQN"‿"uses"‿"notation"‿"as"‿"a"‿"tool"‿"of"‿"thought"
        ≍˘ ≠¨⊸⊔ phrase

(Could we define `phrase` more easily? See [below](#partitioning).)

If we'd like to ignore words of 0 letters, or more than 5, we can set all word lengths greater than 5 to 0, then reduce the lengths by 1. Two words end up with left argument values of ¯1 and are omitted from the result.

        1 -˜ ≤⟜5⊸× ≠¨ phrase
        ≍˘ {1-˜≤⟜5⊸×≠¨𝕩}⊸⊔ phrase

Note that the length of the result is determined by the largest index. So the result never includes trailing empty groups. A reader of the above code might expect 5 groups (lengths 1 through 5), but there are no words of length 5, so the last group isn't there. To ensure the result always has 5 groups, we can add a `5` at the end of the left argument.

        ≍˘ {5∾˜1-˜≤⟜5⊸×≠¨𝕩}⊸⊔ phrase

When Group is called dyadically, the left argument is used for the indices and the right is used for values, as seen above. When it is called monadically, the right argument, which must be a list, gives the indices and the values grouped are the right argument's indices, that is, `↕≠𝕩`.

        ≍˘ ⊔ 2‿3‿¯1‿2

Here, the index 2 appears at indices 0 and 3 while the index 3 appears at index 1.

### Multidimensional grouping

Dyadic Group allows the right argument to be grouped along multiple axes by using a nested left argument. In this case, the left argument must be a list of numeric lists, and the result has rank `≠𝕨` while its elements—as always—have the same rank as `𝕩`. The result shape is `1+⌈´¨𝕨`, while the shape of element `i⊑𝕨⊔𝕩` is `i+´∘=¨𝕨`. If every element of `𝕨` is sorted ascending and contains only non-negative numbers, we have `𝕩≡∾𝕨⊔𝕩`, that is, [Join](join.md#join) is the inverse of Partition.

Here we split up a rank-2 array into a rank-2 array of rank-2 arrays. Along the first axis we simply separate the first pair and second pair of rows—a partition. Along the second axis we separate odd from even indices.

        ⟨0‿0‿1‿1,0‿1‿0‿1‿0‿1‿0⟩ ⊔ (10×↕4)+⌜↕7

Each group `i⊑𝕨⊔𝕩` is composed of the cells `j<¨⊸⊏𝕩` such that `i≢j⊑¨𝕨`. The groups retain their array structure and ordering along each argument axis. Using multidimensional Replicate we can say that `i⊑𝕨⊔𝕩` is `(i=𝕨)/𝕩`.

The monadic case works similarly: Group Indices always satisfies `⊔𝕩 ←→ 𝕩⊔↕≠⚇1𝕩`. As with `↕`, the depth of the result of Group Indices is always one greater than that of its argument. A depth-0 argument is not allowed.

## Properties

Group is closely related to the [inverse of Indices](replicate.md#inverse), `/⁼`. In fact, inverse Indices called on the index argument gives the length of each group:

        ≠¨⊔ 2‿3‿1‿2
        /⁼∧ 2‿3‿1‿2

A related fact is that calling Indices on the result lengths of Group sorts all the indices passed to Group (removing any ¯1s). This is a kind of counting sort.

        /≠¨⊔ 2‿3‿1‿¯1‿2

Called dyadically, Group sorts the right argument according to the left and adds some extra structure. If this structure is removed with [Join](join.md#join), Group can be thought of as a kind of sorting.

        ∾ 2‿3‿1‿¯1‿2 ⊔ "abcde"
        2‿3‿1‿¯1‿2 {F←(0≤𝕨)⊸/ ⋄ 𝕨⍋⊸⊏○F𝕩} "abcde"

Group can even be implemented with the same [techniques](../implementation/primitive/sort.md#counting-and-bucket-sort) as a bucket sort, making it branchless and fast.

## Applications

The obvious application of Group is to group some values according to a known or computed property. If this property isn't a natural number, it can be turned into one using [Classify](selfcmp.md#classify) (`⊐`), which numbers the unique values in its argument by first occurrence.

        ln ← "Phelps"‿"Latynina"‿"Bjørgen"‿"Andrianov"‿"Bjørndalen"
        co ← "US"    ‿"SU"      ‿"NO"     ‿"SU"       ‿"NO"
        ≍˘ co ⊐⊸⊔ ln

If we would like a particular index to key correspondence, we can use a fixed left argument to [Index Of](search.md#index-of).

        countries ← "IT"‿"JP"‿"NO"‿"SU"‿"US"
        countries ≍˘ co countries⊸⊐⊸⊔ ln

However, this solution will fail if there are trailing keys with no values. To force the result to have a particular length you can append that length to the left argument.

        countries ↩ "IT"‿"JP"‿"NO"‿"SU"‿"US"‿"ZW"
        countries ≍˘ co countries⊸(⊐∾≠∘⊣)⊸⊔ ln

### Partitioning

In examples we have been using a list of strings stranded together. Often it's more convenient to write the string with spaces, and split it up as part of the code. In this case, the index corresponding to each word (that is, each letter in the word) is the number of spaces before it. We can get this number of spaces from a Plus-[Scan](scan.md) on the boolean list which is 1 at each space.

        ' '(+`∘=⊔⊢)"BQN uses notation as a tool of thought"

To avoid including spaces in the result, we should change the result index at each space to ¯1. Here is one way to do that:

        ' '((⊢-˜¬×+`)∘=⊔⊢)"BQN uses notation as a tool of thought"

A function with structural Under, such as `` {¯1¨⌾(𝕩⊸/)+`𝕩} ``, would also work.

In other cases, we might want to split on spaces, so that words are separated by any number of spaces, and extra spaces don't affect the output. Currently our function makes a new word with each space:

        ' '((⊢-˜¬×+`)∘=⊔⊢)"  string with  spaces   "

Trailing spaces are ignored because Group with equal-length arguments never produces trailing empty groups—to intentionally include them you'd replace `=` with `(=∾0˙)`. But in string processing we probably want to avoid empty words anywhere. To make this happen, we should increase the word index only once per group of spaces. We can do this by applying Plus Scan to a list that is 1 only for a space with no space before it. This list is produced using [Shift Before](shift.md) to get a list of previous elements. To treat the first element as though it's before a space (so that leading spaces have no effect rather than creating an initial empty group), we shift in a 1.

        (⊢≍1⊸»<⊢) ' '="  string with  spaces   "  # All, then filtered, spaces
        ≍⟜(⊢-˜¬×·+`1⊸»<⊢)' '="  string with  spaces   "  # More processing
        ' '((⊢-˜¬×·+`1⊸»<⊢)∘=⊔⊢)"  string with  spaces   "  # Final result

        ' '((¬-˜⊢×·+`»⊸>)∘≠⊔⊢)"  string with  spaces   "  # Slightly shorter
