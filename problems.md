# Problems with BQN

Every language has some issues that everyone can agree make programming harder. Sometimes there is a simple solution that has not yet been discovered; sometimes the problem is inherent to the language because it's caused by fundamental choices (or anywhere in between). Below are problems I have identified in BQN, ordered from what I consider the most severe to the least. This is independent of whether the issue can be solved—if it somehow went away, how much better would the language be?

I've omitted problems that are obviously addressed by speculated extensions. Of course adding A fixes the problem "doesn't have A". Problems that only exist in reference to some existing convention (e.g. unfamiliarity to APLers) are also left out, unless the convention manifests technically (Unicode support).

### Reduction depth
There are really three kinds of reduction a BQN programmer might want to use:
- Apply the function between elements of a list (Lisp).
- Apply it between major cells of an array (SHARP).
- Apply it between elements of an array, enclosing results to get a new array (NARS).

Converting between these is not difficult but awkard enough to be an annoyance when programming, and because reductions are extremely common that makes this a big problem. Is there any reduction operator that works as an acceptable compromise? Is there even any combination of two operators that works?

### Empty arrays lose type information
A pretty fundamental problem with dynamically-typed array languages. Prototypes are intended to solve it, but they don't really. It doesn't help that the notion of type is fluid: elements of an array in one moment can be axis lengths in the next; did the numeric value go from not being type information to being type information? Inferred type might help here, particularly the ability of one part of the program to ask another part for type information during compilation. But that needs to be specified if programmers are going to rely on it, which sounds difficult.

### Control flow with function selection has awkward syntax
At the moment BQN has no control structures, instead preferring function recursion, iteration, and selection. Selection is awkward because the result of selecting from a list of functions must be a value syntactically. It also often doesn't need an argument, since it can refer to values from the containing function because of lexical scoping. There should probably be a function that takes a function argument and invokes it, possible with an empty list as a dummy left argument. Somewhat like the operator `{𝔽}`. But also: should a `{}` object that doesn't refer to its arguments be special? Some kind of "block" construct?

### Incoherent monad-dyad builtin pairs
BQN inherits the functions `+×⌊⌈|`, and adds the functions `∧∨<>≠≡≢↕⍷`, that are only paired for their glyphs and not for any other reason. I find there are just not enough good glyphs to separate all of these out, but I'm sure the pairings could be improved.

### Can't return from inner functions
This is an issue with using functions as control flow. For example, when looping through an array with Each, you can't decide to exit early. In a curly-brace language you would just use a for loop and a return. In BQN, we need… longjmp? Maybe not as crazy as it sounds, and potentially worth it in exchange for replacing control structures.

### Glyphs are hard to type
There's been a lot of work done on this. Still there, still a problem. On the other hand, glyphs are easy to read, and write by hand!

### Tacit and one-line functions are hard to debug
This problem hasn't manifested yet as BQN has no debugger, but it's something to keep in mind. Traditional line-by-line debuggers don't work when the line is doing so much work. Something like J's dissect or some kind of hybrid would probably do better.

### Search function depth
The simplest way to define a search function like Index Of is to require the left argument to be a list, and search for an element that matches the right argument. But this means you can only search for one element at a time, which is annoying and doesn't work for Progressive Index Of. So we instead treat the searched argument as a list of major cells. Then we decide to search for cells of the other argument that have the same rank as those cells, since only cells with the same rank can match. That's a little strange for Bins, where it still makes sense to compare cells of different ranks. Furthermore, the result of any search function is always an array. To search for a single element and get an unboxed number, you need something like `list⊸⊐⌾<elt`.

### Trigonometry
There are a lot of standard functions and I don't want to use separate primitives or a menu-style primitive like APL Circle for them. You can define all the functions eventually if you use complex exponential and take real and imaginary parts and inverses, but this doesn't sound well-suited for implementation. And there should be a math library that gives you the standard functions with normal names, but how will it be implemented?

### Ambivalent explicit functions
Currently there's no way to define the two valences separately, and I don't know of an easy way to check whether there is a left argument.

### Right-to-left multi-line functions go upwards
If you include multiple multi-line functions in what would otherwise be a one-liner, the flow in each function goes top to bottom but the functions are executed bottom to top. I think the fix here is to just say give your functions names and don't do this.

### Subtraction, division, and span are backwards
The left argument feels much more like the primary one in these cases (indeed, this matches the typical left-to-right ordering of binary operators in mathematics). Not really fixable; too much precedent.

### Can't access array ordering directly
Only `⍋⍒` use array ordering rather than just array comparison or numeric ordering. Getting at the actual ordering to just compare two arrays is more difficult than it should be.

### Comparison tolerance
Kind of necessary for practical programming, but how should it be invoked or controlled? A system variable like `⎕CT`? Per-primitive control? Both? Which primitives should use it?

Definitely | Maybe      | Definitely not
-----------|------------|---------------
`≤<>≥=≠`   | `≡≢⊐⊒∊⍷\|` | `⍋⍒`

### High-rank array notation
The proposed Dyalog array notation `[]` for high-rank arrays: it's the same as BQN's lists `⟨⟩` except it mixes at the end. This works visually because the bottom level—rows—is written with stranding. It also looks okay with BQN strands but clashes with BQN lists. At that point it becomes apparent that specifying whether something is a high-rank array at the top axes is kind of strange: shouldn't it be the lower axes saying to combine with higher ones?

### Poor font support 
Characters `⥊∾⟜⎉⚇˜` and double-struck letters are either missing from many fonts or drawn strangely.

### Trains don't like monads
If you have the normal mix of monads and dyads you'll need a lot of parentheses and might end up abusing `⟜`. A partial solution is to have a special "no argument" glyph `·` that works like `𝕨` during a monadic function call. In a train it would function like J's Cap (`[:`).

### Index Of privileges the first match
It could be more sound to look at all matches, but using the first one is too convenient. J has an index-of-last function; in BQN you have to reverse the left argument and then do arithmetic: `≠∘⊣-1+⌽⊸⊐`.

### Glyphs that aren't great
Blanket issue for glyphs that need work. Currently I find `⥊⊏⊑⊐⊒⍷⁼⎉⚇` to not be particularly good fits for what they describe.

### Axis ordering is big-endian
The most natural ordering for polynomial coefficients and base representations is little-endian, because it aligns element `i` of the list with power `i` of the argument or base. It also allows a forward scan instead of a reverse one. Array axes go the other way. However, there are advantages to this ordering as well. For example, it's common to act only on the first few axes, so having them at the beginning of the array is good (`≠a ←→ ⊑∘≢a`).

### Inverse is not fully specified
So it seems a bit strange to rely on it for core language features like `/⁼`. On the other hand, this is a good fit for `⋆⁼` since we are taking an arbitrary branch of a complex function that has many of them. I'm pretty sure it's impossible to solve the issue as stated but it might be possible to move to less hazardous constructs. Structural Under is a start.

### Monadic `⊑` versus `>`
Both pull out elements and reduce the depth. But they face in opposite directions.

The directions of `⊏⊐` and so on were mainly chosen to line up with `∊`: the argument that indices apply to (that is, the one that is searched or selected from) corresponds to the open side of the function. I'd probably prefer new glyphs that don't have this sort of directionality, however.

### Monadic argument corresponds to left for `/` and `⊔`
Called dyadically, both functions shuffle cells of the right argument around, which is consistent with other selection-type functions. But the monadic case applies to what would be the left argument in the dyadic case.

### Prefixes/Suffixes add depth and Windows doesn't
It's an awkward inconsistency. Prefixes and Suffixes have to have a nested result, but Windows doesn't have to be flat; it's just that making it nested ignores the fact that it does have an array structure.

### Rank/Depth negative zero
A positive operand to Rank indicates the cell rank, so positive zero means to act on 0-cells. A negative operand indicates the frame length, so negative zero should act on the entire array. But it can't because it's equal to positive zero. Similar issue with Depth. Positive/negative is not really the right way to encode the frame/cell distinction, but it's convenient. Fortunately ∞ can be used in place of negative zero, but there can still be problems if the rank is computed.

### Must read the body to find explicit definition's type
You have to scan for `𝕗𝔽𝕘𝔾` (and so does a compiler). A little inelegant, and requires a fair amount of preprocessing to be able to say the parser is still context-free.

### Can't take Prefixes or Suffixes on multiple axes
This is a natural array operation to do, and results in an array with a joinable structure, but as Prefixes and Suffixes are monadic there's no way to specify the number of axes to use.

### And/Or/Max/Min are all tangled up
Boolean And (`∧`) and Or (`∨`) are identical to Min (`⌊`) and Max (`⌈`) when restricted to Boolean arguments, and this would fit nicely with their monadic role as sorting functions: for example `a∧b ←→ ⊑∧a‿b`. Furthermore the pairing of Min with Floor and Max with Ceiling is mnemonic only and not especially natural. The reason I have not used these glyphs for Min and Max, and have instead extended them to the somewhat superfluous [arithmetic logical functions](doc/logical.md) is that Min and Max have different [identity elements](https://aplwiki.com/wiki/Identity_element) of `∞` and `¯∞` rather than `1` and `0`. Having to code around empty arrays when using `∧´` would be a fairly big issue.

The other drawback of Min (`∧`) and Max (`∨`) is that the symbols are counterintuitive, but I have found a way to remember them: consider the graph of variables `a←x` and `b←¬x` for x from 0 to 1: two crossed lines. Now the graph of `a∧b` is a caret shape and `a∨b` is a vee.

### Acting on windows can be awkward
When taking Windows along more than one axis, acting on the resulting array requires the Rank operator, duplicating either the right argument rank or (negated) left argument count. A nested Windows would only require Each.

### Group doesn't include trailing empty groups
But there are workarounds, described in [its documentation](doc/group.md). dzaima has suggested allowing a single extra element in the index argument to specify the result shape. Another possibility is for the result prototype to be specified to allow overtaking.

### Scan ordering is weird
Scan moves along the array so that it uses results as left arguments, which is opposite to the usual right-to-left order of evaluation. But I think this is still better than scanning the array in reverse. You can always use Swap on the operand, or recover the APL scan ordering by doing a Reduce-Each on Prefixes.

### Bins is inconsistent with Index of
In Dyalog APL, Interval Index is identical to Index Of if the left argument has no duplicate cells and every right argument cell intolerantly matches a left argument cell. In BQN they're off by one—Bins is one larger. But all the caveats for the Dyalog relation indicate this might not be so fundamental.

### Exact result of Power is unspecified
The other arithmetic functions round to nearest, and compound functions such as `⊥` have been removed. But Power makes no guarantees, and the result could change over time based on different special code. Dyadic logarithm is similar, but expected because of its inverse status.

### Empty left argument to Select
Select chooses whether the left argument maps to right argument axes or selects from the first axis only based on its depth. Without prototypes an empty array has depth 1, so it selects no major cells. However, it could also select from no axes (a no-op) and in some contexts the other behavior would be surprising.

### Unclear primitive names
Blanket issue for names that I don't find informative: "Solo", "Bins", "Unique Mask", "Find", and "Group".

### "Modifier" and "composition" terminology
Since the two have different syntax, it's important that they have completely separate names. "Modifier" is good but "composition" is not, as it doesn't seem to fit with Rank, Depth, or Iterate. There's also often a need for a term that refers to both. I've been using "operator" but that can be confusing.

### Should have a rounding function
There is a standard way to round floats—to nearest integer, ties to even—but it's fairly hard to implement and would have to be specially recognized for performance. It would be nice to have a better way to access this.

### Primitive name capitalization
I went with "Index of" and "Less Than or Equal to" but the last word blends into surrounding text. Should they be fully capitalized or hyphenated?

## Solved problems

Problems that existed in mainstream APL or a transitional BQN that have in my opinion been put to rest (while in some cases introducing new problems). Listed in reverse chronological order by time solved, by my recollection.

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
