*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/problems.html).*

# Problems with BQN

Every language has some issues that everyone can agree make programming harder. Sometimes there is a simple solution that has not yet been discovered; sometimes the problem is inherent to the language because it's caused by fundamental choices (or anywhere in between). Below are problems I have identified in BQN, ordered from what I consider the most severe to the least. This is independent of whether the issue can be solved—if it somehow went away, how much better would the language be?

I've omitted problems that are obviously addressed by speculated extensions. Of course adding A fixes the problem "doesn't have A". Problems that only exist in reference to some existing convention (e.g. unfamiliarity to APLers) are also left out, unless the convention manifests technically (Unicode support).

### Empty arrays lose type information
A pretty fundamental problem with dynamically-typed array languages. Prototypes are intended to solve it, but they don't really. It doesn't help that the notion of type is fluid: elements of an array in one moment can be axis lengths in the next; did the numeric value go from not being type information to being type information? Inferred type might help here, particularly the ability of one part of the program to ask another part for type information during compilation. But that needs to be specified if programmers are going to rely on it, which sounds difficult.

### Incoherent monad-dyad builtin pairs
BQN inherits the functions `+×⌊⌈|`, and adds the functions `∧∨<>≠≡≢↕⍷`, that are only paired for their glyphs and not for any other reason (that is, both function valences match the symbol but they don't match with each other). I find there are just not enough good glyphs to separate all of these out, but I'm sure the pairings could be improved.

### Control flow substitutes have awkward syntax
At the moment BQN has no control structures, instead preferring modifiers, function recursion, and headers. When working with pure functions, these can be better than control structures. For more imperative programming they're a lot worse. Given that blocks without headers also end up with an unexpected type if you don't use the inputs, it's safe to say BQN isn't great for imperative programming overall. But that's a big loss, and it's very much worth fixing if it can be done with something like a single control structure that conditionally or repeatedly executes an immediate block.

### Glyphs are hard to type
There's been a lot of work done on this. Still there, still a problem. On the other hand, glyphs are easy to read, and write by hand!

### Tacit and one-line functions are hard to debug
This problem hasn't manifested yet as BQN has no debugger, but it's something to keep in mind. Traditional line-by-line debuggers don't work when the line is doing so much work. Something like J's dissect or some kind of hybrid would probably do better.

### Search function depth
The simplest way to define a search function like Index Of is to require the left argument to be a list, and search for an element that matches the right argument. But this means you can only search for one element at a time, which is annoying and doesn't work for Progressive Index Of. So we instead treat the searched argument as a list of major cells. Then we decide to search for cells of the other argument that have the same rank as those cells, since only cells with the same rank can match. That's a little strange for Bins, where it still makes sense to compare cells of different ranks. Furthermore, the result of any search function is always an array. To search for a single element and get an plain number, you need something like `list⊸⊐⌾<elt`.

### Trigonometry
There are a lot of standard functions and I don't want to use separate primitives or a menu-style primitive like APL Circle for them. You can define all the functions eventually if you use complex exponential and take real and imaginary parts and inverses, but this doesn't sound well-suited for implementation. And there should be a math library that gives you the standard functions with normal names, but how will it be implemented?

### Right-to-left multi-line functions go upwards
If you include multiple multi-line functions in what would otherwise be a one-liner, the flow in each function goes top to bottom but the functions are executed bottom to top. I think the fix here is to just say give your functions names and don't do this.

### Hard to search part of an array or in a different order
This includes index-of-last, and searching starting at a particular index, when the desired result indices are to the array to be seached *before* it is modified. Given indices `i` into an array `𝕨` (for example `⌽↕≠𝕨` or `a+↕b`), this section can be searched with `(i∾≠𝕨)⊏˜(i⊏𝕨)⊐𝕩`. But this is clunky and difficult for the implementation to optimize.

### Subtraction, division, and span are backwards
The left argument feels much more like the primary one in these cases (indeed, this matches the typical left-to-right ordering of binary operators in mathematics). The commonly-paired `⌊∘÷` and `|` have opposite orders for this reason. Not really fixable; too much precedent.

### Nothing (`·`) interacts strangely with Before and After
Since `𝕨F⊸G𝕩` is `(F𝕨)G𝕩` and `𝕨F⟜G𝕩` is `𝕨F G𝕩` in the dyadic case, we might expect these to devolve to `G𝕩` and `F G𝕩` when `𝕨` is not present. Not so: instead `𝕩` is substituted for the missing `𝕨`. And Before and After are also the main places where a programmer might try to use `𝕨` as an operand, which doesn't work either (the right way is the train `𝕨F⊢`). It's also a little strange that `v F˜·` is `·`, while `·F v` is `F v`.

### Can't access array ordering directly
Only `⍋⍒` use array ordering rather than just array equality or numeric ordering. Getting at the actual ordering to just compare two arrays is more difficult than it should be (but not *that* difficult: `⥊⊸⍋⌾<` is TAO `≤`).

### Syntactic type erasure
A programmer can call a modifier on either a syntactic function or subject, but there's no way to know within the modifier which syntax that operand had. Maybe this is a better design, but it doesn't feel quite right that `f˜` is `f`-Swap if `f` has a function value. The subject syntax suggests it should be Constant. Instead the Constant modifier `˙` has been added partially to mitigate this.

### Comparison tolerance
Kind of necessary for practical programming, but how should it be invoked or controlled? A system variable like `⎕CT`? Per-primitive control? Both? Which primitives should use it?

Definitely | Maybe      | Definitely not
-----------|------------|---------------
`=≠≤≥<>`   | `≡≢⊐⊒∊⍷\|` | `⍋⍒`

### No access to fast high-precision sum
Fold has a specific order of application, which must be used for `` +` ``. But other orders can be both faster and more precise (in typical cases) by enabling greater parallelism. Generally ties into the question of providing precision control for a program: it could be fixed by a flag that enables BQN to optimize as long as the results will be at least as precise (relative to the same program in infinite precision) as the spec.

### High-rank array notation
The proposed Dyalog array notation `[]` for high-rank arrays: it's the same as BQN's lists `⟨⟩` except it mixes at the end. This works visually because the bottom level—rows—is written with stranding. It also looks okay with BQN strands but clashes with BQN lists. At that point it becomes apparent that specifying whether something is a high-rank array at the top axes is kind of strange: shouldn't it be the lower axes saying to combine with higher ones?

### Poor font support 
Characters `⥊∾⟜⎉⚇˜` and double-struck letters are either missing from many fonts or drawn strangely.

### Choose and Repeat have order swapped
In Choose, the selector goes on the left; in Repeat, the count goes on the right. Could be a strength in some contexts, since you can change Repeat-as-If to Choose if you don't like the ordering, but maybe a language that forces the programmer to make semantic decisions for syntactic reasons is not providing the greatest of services.

### Index Of privileges the first match
It could be more sound to look at all matches, but using just the first one is too convenient. J has an index-of-last function; in BQN you have to reverse the left argument and then do arithmetic: `≠∘⊣-1+⌽⊸⊐`.

### Glyphs that aren't great
Blanket issue for glyphs that need work. Currently I find `⥊⊏⊑⊐⊒⍷⁼⎉⚇` to not be particularly good fits for what they describe.

### Group doesn't include trailing empty groups
But there are workarounds, described in [its documentation](doc/group.md). dzaima has suggested allowing a single extra element in the index argument to specify the result shape. Another possibility is for the result prototype to be specified to allow overtaking.

### Axis ordering is big-endian
The most natural ordering for polynomial coefficients and base representations is little-endian, because it aligns element `i` of the list with power `i` of the argument or base. It also allows a forward scan instead of a reverse one. Array axes go the other way. However, there are advantages to this ordering as well. For example, it's common to act only on the first few axes, so having them at the beginning of the array is good (`≠a ←→ ⊑∘≢a`).

### Trains don't like monads
If you have the normal mix of monads and dyads you'll need a lot of parentheses and might end up abusing `⟜`. Largely solved with the "nothing" glyph `·`, which acts like J's Cap (`[:`) in a train, but still a minor frustration.

### Inverse is not fully specified
So it seems a bit strange to rely on it for core language features like `/⁼`. On the other hand, this is a good fit for `⋆⁼` since we are taking an arbitrary branch of a complex function that has many of them. I'm pretty sure it's impossible to solve the issue as stated but it might be possible to move to less hazardous constructs. Structural Under is a start.

### Prefixes/Suffixes add depth and Windows doesn't
It's an awkward inconsistency. Prefixes and Suffixes have to have a nested result, but Windows doesn't have to be flat; it's just that making it nested ignores the fact that it does have an array structure.

### At which scope does a block function belong?
As a general principle, a programmer should make choices in one part of a program that constrain other parts of the program most tightly. This is a weak principle, but often it doesn't conflict with any other preferences and can be followed for free. For example it's usually best to define a variable in the smallest possible scope, so the reader knows it isn't used outside that scope. The same principle applies to blocks, but there is another conflicting principle: placing the block in a broader scope guarantees it won't access the variables in narrower ones. There's no position that will tell the reader, for example, that a function only uses variables local to itself and that it's only used within one particular scope.

This is an issue with any lexically-scoped language; it's unlikely BQN can solve it. On the other hand, I'm surprised I've never seen any discussion of such a universal issue.

### Rank/Depth negative zero
A positive operand to Rank indicates the cell rank, so positive zero means to act on 0-cells. A negative operand indicates the frame length, so negative zero should act on the entire array. But it can't because it's equal to positive zero. Similar issue with Depth. Positive/negative is not really the right way to encode the frame/cell distinction, but it's convenient. Fortunately ∞ can be used in place of negative zero, but there can still be problems if the rank is computed.

### Must read the body to find headerless block's type
You have to scan for headers or double-struck names (and so does a compiler). A little inelegant, and difficult to describe in BNF. This can usually be fixed by adding a block header, except in the case of immediate modifiers: even an immediate modifier with a header can be made into a deferred modifier by adding a special name like `𝕨`.

### Each block body has its own label
In a block with multiple bodies, the label (the self-name part of the header) refers to the entire block. However, there's no way to give only one label to the entire block. If you want to consistently use the same internal name, then you may have to write it many times. It's also a weird mismatch, conceptually.

### Have to be careful about intermediate results with affine characters
A computation like `(a+b)÷2` (midpoint between characters `a` and `b`, of the distance between them is even) or `5>v-n` (equivalent to `v<5+n`) is conceptually okay, but the first will always fail because `a+b` is invalid while the second will (even worse!) fail only if `v` is a character with code point smaller than `n`. Arithmetic manipulations that would be valid for numbers aren't for the number-character system.

Numbers and characters are subsets of a linear space with components "characterness" (0 for numbers and 1 for characters) and value (code point for characters). Numbers are a linear subspace, and characters a subset of an affine one. Their union isn't closed under addition and subtraction in either component. Usually this is good, as failing when the user creates a nonexistent character or double-character can catch a lot of errors. But not always.

### Monadic argument corresponds to left for `/` and `⊔`
Called dyadically, both functions shuffle cells of the right argument around, which is consistent with other selection-type functions. But the monadic case applies to what would be the left argument in the dyadic case.

### Hard to manipulate the result of a modifier
Trains and compositions make it easy to work with the results of functions, in some sense. The same can't be said for modifiers: for example, in a non-immediate block modifier, the derived function is `𝕊`, but you can't apply `˜` to it. This seems to call for modifer trains but people who worked with early J are confident they're not worth it. Or were they just not designed right?

### Monadic `⊑` versus `>`
Both pull out elements and reduce the depth. But they face in opposite directions. However, neither should be thought of as the inverse to `<`: that's `<⁼`. And `>` can't reduce the depth to 0, so it's pretty different from `⊑` or `<⁼`.

The directions of `⊏⊐` and so on were mainly chosen to line up with `∊`: the argument that indices apply to (that is, the one that is searched or selected from) corresponds to the open side of the function. I'd probably prefer new glyphs that don't have this sort of directionality, however.

### Can't take Prefixes or Suffixes on multiple axes
This is a natural array operation to do, and results in an array with a joinable structure, but as Prefixes and Suffixes are monadic there's no way to specify the number of axes to use.

### Modified assignment modifies the left (secondary) argument
So you end up with `˜↩` a lot of the time. For ordinary assignment it's pretty reasonable to say the value is primary, but modified assignment flips this around.

### And/Or/Max/Min are all tangled up
Boolean And (`∧`) and Or (`∨`) are identical to Min (`⌊`) and Max (`⌈`) when restricted to Boolean arguments, and this would fit nicely with their monadic role as sorting functions: for example `a∧b ←→ ⊑∧a‿b`. Furthermore the pairing of Min with Floor and Max with Ceiling is mnemonic only and not especially natural. The reason I have not used these glyphs for Min and Max, and have instead extended them to the somewhat superfluous [arithmetic logical functions](doc/logic.md) is that Min and Max have different [identity elements](https://aplwiki.com/wiki/Identity_element) of `∞` and `¯∞` rather than `1` and `0`. Having to code around empty arrays when using `∧´` would be a fairly big issue.

The other drawback of Min (`∧`) and Max (`∨`) is that the symbols are counterintuitive, but I have found a way to remember them: consider the graph of variables `a←x` and `b←¬x` for x from 0 to 1: two crossed lines. Now the graph of `a∧b` is a caret shape and `a∨b` is a vee.

### Acting on windows can be awkward
When taking Windows along more than one axis, acting on the resulting array requires the Rank modifier, duplicating either the right argument rank or (negated) left argument length. A nested Windows would only require Each.

### Inputs to modifiers are called operands?
"Operand" is derived from "operator". "Modificand" would be better if it weren't both made up and hideous.

### Converting a function expression to a subject is tricky
You can name it, you can write `⊑⟨Expr⟩` or `(Expr)˙0`, and if it doesn't use special names you can write `{Expr}`. All of these are at least a little awkward in reasonable cases. Should there be a dedicated syntax? Note that going the other way, from subject to function, isn't too bad: the modifier `{𝔽}` does it.

### Scan ordering is weird
Scan moves along the array so that it uses results as left arguments, which is opposite to the usual right-to-left order of evaluation. But I think this is still better than scanning the array in reverse. You can always use Swap on the operand, or recover the APL scan ordering by doing a Reduce-Each on Prefixes.

### Only errors in functions can be caught
The modifier `⎊` allows errors in a function to be caught, but a more natural unit for this is the block (scope, really). However, catching errors shouldn't be common in typical code, in the sense that an application should have only a few instances of `⎊`. Ordinary testing and control flow should be preferred instead.

### Bins is inconsistent with Index of
In Dyalog APL, Interval Index is identical to Index Of if the left argument has no duplicate cells and every right argument cell intolerantly matches a left argument cell. In BQN they're off by one—Bins is one larger. But all the caveats for the Dyalog relation indicate this might not be so fundamental.

### Exact result of Power is unspecified
The other arithmetic functions round to nearest, and compound functions such as `⊥` have been removed. But Power makes no guarantees, and the result could change over time based on different special code. Dyadic logarithm is similar, but expected because of its inverse status.

### Empty left argument to Select
Select chooses whether the left argument maps to right argument axes or selects from the first axis only based on its depth. Without prototypes an empty array has depth 1, so it selects no major cells. However, it could also select from no axes (a no-op) and in some contexts the other behavior would be surprising.

### Unclear primitive names
Blanket issue for names that I don't find informative: "Solo", "Bins", "Unique Mask", "Find", and "Group".

### Strands go left to right
This is the best ordering, since it's consistent with `⟨⋄⟩` lists. And code in a strand probably shouldn't have side effects anyway. Still, it's an odd little tack-on to say separators *and strands* go left to right, and it complicates the implementation a little.

### Should have a rounding function
There is a standard way to round floats—to nearest integer, ties to even—but it's fairly hard to implement and would have to be specially recognized for performance. It would be nice to have a better way to access this.

### Primitive name capitalization
I went with "Index of" and "Less Than or Equal to" but the last word blends into surrounding text. Should they be fully capitalized or hyphenated?

## Solved problems

Problems that existed in mainstream APL or a transitional BQN that have in my opinion been put to rest (while in some cases introducing new problems). Listed in reverse chronological order by time solved, by my recollection.

### Array reductions are annoying
There are really three kinds of reduction a BQN programmer might want to use.
- `𝔽´` Apply the function between elements of a list (Lisp).
- `𝔽˝` Apply it between major cells of an array (SHARP).
- `𝔽¨˝` Apply it between elements of an array, enclosing results to get a new array (NARS).

BQN bounced between these some at first; eventually I decided it really needed two, with `𝔽˝` equivalent to `𝔽´<˘`. The last requires two symbols, but they can always be used together as a unit, so I think this is no longer annoying.

### "Modifier" and "composition" terminology
1-modifiers and 2-modifiers used to be called "modifiers" and "compositions", respectively, and sometimes "operators" collectively. The new names are much better, although they do leave a disconnect between the names for modifiers, and those for their inputs—"operands".

### Can't return from inner functions
Fixed by adding block returns such as `label←` to jump out of a block with header name `label`. Hopefully these don't cause too many new problems.

This was an issue with using functions as control flow. For example, when looping through an array with Each, you can't decide to exit early. In a curly-brace language you would just use a for loop and a return. In BQN, we need… longjmp? Maybe not as crazy as it sounds, and potentially worth it in exchange for replacing control structures.

### Ambivalent explicit functions
Fixed with multiple bodies: if there are two bodies with no headers such as `{2×𝕩;𝕨-𝕩}`, they are the monadic and dyadic case.

### How to choose a partitioning function?
Fixed with [Group](doc/group.md), which I found May 2020. Group serves as a much improved [Partition](https://aplwiki.com/wiki/Partition). However, it doesn't partition along multiple axes, so a dedicated partition function that does this could also be wanted. Or could Group be made to work with multiple axes as well as multidimensional indices?

### Key doesn't do what you want
Fixed with [Group](doc/group.md) to my satisfaction, except for the trailing-empty-group problem. There were various issues with Key operators in J and Dyalog, such as the fact that the ordering and presence of groups depends on where and whether the keys appear. Also, Dyalog's Key can return keys and values, but they are in a different format than the input: an array of pairs instead of two arrays. Monadic Group returns indices, which can be used how the programmer wants.

### Greek letter issues
Fixed by not using Greek letters. In particular, the idea of using fancy Latin letters as fixed names for function arguments was suggested in proto-BQN sessions, possibly by Nathan Rogers.

### Stranding gotchas
Fixed with list notation, which descends from the array notation developed by Phil Last and later Adám Brudzewsky. The problem that array notation has much more cluttered syntax than stranding has pretty much been fixed by the ligature character `‿`, which I discovered during proto-BQN discussions.

### Functions are not first class
Fixed by allowing a variable to be written with a different syntactic class than it was created with, suggested by Adám in proto-BQN discussions.

### APL is not context-free
Fixed with the casing conventions for variable names, which I think I first saw in [APL\iv](https://aplwiki.com/wiki/APL%5Civ), although the cases are swapped relative to BQN.

### Selective assignment requires a named variable
Fixed with structural Under, which I developed in 2017 and 2018.

### It's hard use an array as a major cell
Fixed with `≍`: dyadic form from A+ and monadic/dyadic pair from J.

### Scan and Windowed Reduce shouldn't always reduce
Fixed with Prefix, Suffix, and Infix operators in J. Changed to functions in BQN.
