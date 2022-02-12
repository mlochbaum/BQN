*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/problems.html).*

# Problems with BQN

Every language has some issues that everyone can agree make programming harder. Sometimes there is a simple solution that has not yet been discovered; sometimes the problem is inherent to the language because it's caused by fundamental choices (or anywhere in between). Below are problems I have identified in BQN, ordered from what I consider the most severe to the least. This is independent of whether the issue can be solved—if it somehow went away, how much better would the language be?

This list is meant to be specific, so it addresses particular features rather than overall philosophy, and only includes missing functionality if some feature would be expected to provide it but doesn't. Problems that only exist in reference to some existing convention (e.g. unfamiliarity to APLers) are also left out, unless the convention manifests technically (Unicode support).

### Empty arrays lose type information
A pretty fundamental problem with dynamically-typed array languages: when computing something (say, a sum) that depends on all elements, if there are no elements then the structure of the result is indeterminate. Shape arithmetic means the shape of a cell is always known, except when using the Rank modifier so that every cell is computed independently. [Fills](../doc/fill.md) are BQN's solution for deeper structure, but they're incomplete. They store only types and not data, but operations like Reshape that use data to determine type are common enough to make this unreliable.

### Incoherent monad-dyad builtin pairs
BQN inherits the functions `+×⌊⌈|`, and adds the functions `∧∨<>≠≡≢↕⍷`, that are only paired for their glyphs and not for any other reason (that is, both function valences match the symbol but they don't match with each other). I find there are just not enough good glyphs to separate all of these out, but I'm sure the pairings could be improved. In some future language, that is, as BQN is past the point of being able to change these.

### Glyphs are hard to type
There's been a lot of work done on this. Still there, still a problem. On the other hand, glyphs are easy to read, and write by hand!

### Search function depth
The simplest way to define a search function like Index Of is to require `𝕨` to be a list, and search for an element that matches `𝕩`. But this means you can only search for one element at a time, which is annoying and doesn't work for Progressive Index Of. So we instead treat the searched argument as a list of major cells. Then we decide to search for cells of the other argument that have the same rank as those cells, since only cells with the same rank can match. That's a little strange for Bins, where it still makes sense to compare cells of different ranks. Furthermore, the result of any search function is always an array. To search for a single element and get an plain number, you need something like `list⊸⊐⌾<elt`.

### Body determines a headerless block's type
The major problem here is the ease of programmer error: it's common to want a function that ignores the argument, and get an immediate block. Some syntactic contexts catch this error; some don't.

In a body with no header, you have to scan double-struck names, and so does a compiler. A little inelegant, and difficult to describe in BNF. You could just always use headers, but are you really going to?

### Control flow substitutes have awkward syntax
At the moment BQN has no control structures, instead [preferring](../doc/control.md) headers, recursion, and modifiers. When working with pure functions, these can be better than control structures, but it doesn't fit an imperative style so well. With predicates, decision trees are okay but looping code is substantially worse than it is in imperative languages, particularly if tail recursion can't be relied on.

One particular sore point with Repeat (`⍟`) and Choose (`◶`) is that the condition and action(s) always apply to the same set of arguments. Often you'd like them to apply to completely different things: this seems like the sort of thing that split compose `F⊸G⟜H` solved for trains, but here there's no such solution.

### Syntactic type erasure
A programmer can call a modifier on either a syntactic function or subject, but there's no way to know within the modifier which syntax that operand had. Maybe this is a better design, but it doesn't feel quite right that `f˜` is `f`-Swap if `f` has a function value. The subject syntax suggests it should be Constant. Instead the Constant modifier `˙` has been added partially to mitigate this.

### Group doesn't include trailing empty groups
A length can now be specified either in an extra element in any rank-1 component of `𝕨`, or by overtaking, since the result's fill element is an empty group. However, it still seems like it would be pretty easy to end up with a length error when a program using Group encounters unexpected data. It's a fundamental safety-convenience tradeoff, though, because specifying a length has to take more code in the general case.

### Variable-length loops
If the intended length of a loop isn't known before it begins, it can't be implemented with BQN primitives. The sensible way to handle such loops should be recursion… except that BQN implementations have stack limits. Some of them could support tail recursion, but for others it would be pretty hard and the result would be a lot of fragmentation. So uglier techniques are required, like `•_while_`, or the [low-stack recursion](../doc/control.md#low-stack-version) that no one could be expected to invent.

### An unmatched predicate loses locals
For example `{0≤a←𝕩-2 ? a ; -a}` doesn't compile: the `;` separates bodies and the second one never defines `a`. This can be fixed by enclosing in an immediate block, which might then require you to reassign some special names. So it's only ever a syntactic difficulty, but it gets pretty annoying at times.

The root cause is repurposing the header-body system for an if-else thing (I found it quite surprising for this to be the worst issue caused by the approach). It can't be fixed with an extension, because the variable might really not be defined: consider `{l𝕊𝕩: a←+´l⋄⊑l?0 ; a}`. If called with no left argument, it will go into the second case, never seeing an `a←`.

### Hard to search part of an array or in a different order
This includes index-of-last, and searching starting at a particular index, when the desired result indices are to the array to be seached *before* it is modified. Given indices `i` into an array `𝕨` (for example `⌽↕≠𝕨` or `a+↕b`), this section can be searched with `(i∾≠𝕨)⊏˜(i⊏𝕨)⊐𝕩`. But this is clunky and difficult for the implementation to optimize.

### Right-to-left multi-line functions go upwards
If you include multiple multi-line functions in what would otherwise be a one-liner, the flow in each function goes top to bottom but the functions are executed bottom to top. I think the fix in BQN is to just say give your functions names and don't do this. But [left to right](ltr.md) programming beckons.

### Trains don't like monads
If you have the normal mix of monads and dyads you'll need a lot of parentheses and might end up abusing `⟜`. Largely solved with the Nothing syntax `·`, which acts like J's Cap (`[:`) in a train, but still a minor frustration.

### Under/bind combination is awkward
It's most common to use Under with dyadic structural functions in the form `…⌾(i⊸F)`, for example where `F` is one of `/` or `↑`. This is frustrating for two reasons: it requires parentheses, and it doesn't allow `i` to be computed tacitly. If there's no left argument then the modifier `{𝔽⌾(𝕨⊸𝔾)𝕩}` can be more useful, but it doesn't cover some useful cases such as mask `a ⊣⌾(u⊸/) b`.

### List splicing is fiddly
It's common when manipulating text to want to replace a slice with a different slice with an unrelated length. Structural Under works well for this if the new slice has the same length but doesn't otherwise (an implementation could choose to support it, but *only* if the slice is extracted using two Drops, not Take). So in general the programmer has to cut off initial and final segments and join them to the new slice. If the new slice is computed from the old one it's much worse, as there will be duplication between the code to extract that slice and the other segments. The duplication can be avoided with Group using `∾F⌾(1⊸⊑)(s‿e⍋↕∘≠)⊸⊔`, but this is a lot of work and will execute slowly without some special support. In fact, everything here is liable to run slowly, making too many copies of the unmodified part of the stream.

Dyalog's solution here (and dzaima/BQN's) is Regex, which is a nice feature but also an entire second language to learn.

### Subtraction, division, and span are backwards
The left argument feels much more like the primary one in these cases (indeed, this matches the typical left-to-right ordering of binary operators in mathematics). The commonly-paired `⌊∘÷` and `|` have opposite orders for this reason. Not really fixable; too much precedent.

### Poor font support 
Characters `⥊∾⟜⎉⚇˜` and double-struck letters are either missing from many fonts or drawn strangely.

### Deshape and Reshape can't ignore trailing axes
If you want to repeat 3 major cells until there are 7 of them, or combine the first 4 axes of a rank-6 array, what's your best option? Nothing's too good: you could compute a full shape for Reshape, enclose cells and merge afterwards (for example `7⊸⥊⌾(<˘)`), use Select to reshape one axis to multiple, or use `∾˝` to merge two axes (with possible empty-array issues). This is particularly dangerous with computed-length reshapes like `2‿∘⥊…`, since the idea of splitting off a length-2 axis from an array's first axis is generally useful, but this version has an implicit Deshape first.

J's Reshape analogue (`$`) only ever applies to the first axis. I now think this is probably a better primitive to have overall, as `$⟜⥊` gives the APL behavior back and is rarely needed. It's not an intuitive pair with Deshape though.

### Long trains are hard for humans to parse
In a train consisting only of functions, the behavior of a function (whether it's applied directly to arguments, or to the results of other functions) is determined by its distance from the right side of the train. With a longer train it gets easy to lose track of whether the distance is even or odd. Sure, any bit of syntax gets hard when you put too much of it on a line, but it's notable that with trains this happens very quickly. The length where difficulty begins varies from about 4 to 8 parts, depending on the reader. A train of only functions is the worst case, as subjects can only go in one position and thus serve as anchors.

### Prefixes/Suffixes add depth and Windows doesn't
It's an awkward inconsistency. Prefixes and Suffixes have to have a nested result, but Windows doesn't have to be flat; it's just that making it nested ignores the fact that it does have an array structure.

### Converting a function expression to a subject is tricky
You can name it, you can write `⊑⟨Expr⟩` or `(Expr)˙0`, and if it doesn't use special names you can write `{Expr}`. All of these are at least a little awkward in reasonable cases. Should there be a dedicated syntax? Note that going the other way, from subject to function, isn't too bad: the modifier `{𝔽}` does it, as does `○⊢`.

### Can't Reduce or Scan over arrays jointly
Each allows you to move along two arrays simultaneously (sure, three isn't good, but you can usually split into two Each-ed functions). Reduce and Scan are stuck with one, so you might need to pass in a list of tuples. Scan also encourages you to pack a few values into the result, leaving you the same annoying structure. A nested-transpose primitive, similar to `<˘⍉>`, would help a lot.

### Axis ordering is big-endian
The most natural ordering for polynomial coefficients and base representations is little-endian, because it aligns element `i` of the list with power `i` of the argument or base. It also allows a forward scan instead of a reverse one. Array axes go the other way. However, there are advantages to this ordering as well. For example, it's common to act only on the first few axes, so having them at the beginning of the array is good (`≠a ←→ ⊑∘≢a`).

### Inverse is not fully specified
So it seems a bit strange to rely on it for core language features like `/⁼` (well, that one in particular has been specified, and extended even). On the other hand, this is a good fit for `⋆⁼` since we are taking an arbitrary branch of a complex function that has many of them. I'm pretty sure it's impossible to solve the issue as stated but it might be possible to move to less hazardous constructs. Structural Under is a start.

### Choose and Repeat have order swapped
In Choose, the selector goes on the left; in Repeat, the count goes on the right. Could be a strength in some contexts, since you can change Repeat-as-If to Choose if you don't like the ordering, but maybe a language that forces the programmer to make semantic decisions for syntactic reasons is not providing the greatest of services.

### Have to enclose Scan initial element
The most common case for Scan is of course applying to a list. Here there can only be one element, but it has to go in a unit array to keep Scan general. The reductions dodge this by leaving out the APL2 style, and Scan hits it dead on.

### Can't mix define and modify in multiple assignment
Say `a` is a pair and `h` isn't defined yet; how would you set `h` to the first element of `a` and change `a` to be just the second? `h‿a↩a` doesn't work because `h` isn't defined, so the best I have is `h←@⋄h‿a↩a`. A heavier assignment syntax wouldn't break down; BQN could allow `⟨h←,a⟩↩a` but I don't think this merits special syntax.

### Tolerant comparison
APL has it and BQN doesn't; after some experience it seems this causes few problems, and the extra effort required for the algorithms that do need it is negligible (anyway, it's better to be aware when your code relies on imprecise equality). APL and J also tolerate inexact indices and lengths, which is also something that could be supported.

### Named modifiers use way more space than primitive ones
`F _m_ G` versus `F∘G`: the syntax is the same but these don't feel the same at all. This is the worst case, as with primitive operands, `+_m_÷` isn't as far from `+∘÷`. It means a style-conscious programmer has to adjust the way they write code depending on whether things are named, and makes named modifiers feel less integrated into the language. A mix of named modifiers with primitive modifiers or trains can also look inconsistent.

### Return value prevents optimization
Run something like `a←↕1e6 ⋄ {a-⌾(𝕩⊸⊑)↩}¨↕100` and you'll get poor performance in current CBQN. This is because `a` is part of the function result to be used by `¨`, creating a reference and preventing in-place updates. The function needs to return something else, with `⋄@` at the end maybe. Various strategies could fix this by tracking whether the result will be needed.

### Can't always transfer ambivalence in tacit code
For example, there's no tacit equivalent of the old APL (NARS) `∘`, which in explicit BQN is simply `{𝕨𝔽𝔾𝕩}`. Similarly, `{(𝔽𝕨)𝔾𝕩}` is missing. The contrast with Atop and Over, which work very smoothly, can be jarring and make it harder to get an intuition for what the code is doing.

### Index Of privileges the first match
It could be more sound to look at all matches, but using just the first one is too convenient. J has an index-of-last function; in BQN you have to reverse the left argument and then do arithmetic: `≠∘⊣-1+⌽⊸⊐`. I'm treating index-of-last as part of [a different problem](#hard-to-search-part-of-an-array-or-in-a-different-order) higher up though.

### Negative indices don't fail by default
The typical case when selecting from an array is that a negative index doesn't make sense, and you'd prefer it to give an error. But negative indices are pretty useful in some contexts so BQN trades safety for convenience. Manually checking that indices are non-negative is easier than full range checking, but the issue is that you have to do it manually at all.

### At which scope does a block function belong?
As a general principle, a programmer should make choices in one part of a program that constrain other parts of the program most tightly. This is a weak principle, but often it doesn't conflict with any other preferences and can be followed for free. For example it's usually best to define a variable in the smallest possible scope, so the reader knows it isn't used outside that scope. The same principle applies to blocks, but there is another conflicting principle: placing the block in a broader scope guarantees it won't access the variables in narrower ones. There's no position that will tell the reader, for example, that a function only uses variables local to itself and that it's only used within one particular scope.

This is an issue with any lexically-scoped language; it's unlikely BQN can solve it. On the other hand, I'm surprised I've never seen any discussion of such a universal issue.

### Acting on windows can be awkward
When taking Windows along more than one axis, acting on the resulting array requires the Rank modifier, duplicating either the right argument rank or (negated) left argument length. A nested Windows would only require Each.

### Rank/Depth negative zero
A positive operand to Rank indicates the cell rank, so positive zero means to act on 0-cells. A negative operand indicates the frame length, so negative zero should act on the entire array. But it can't because it's equal to positive zero. Similar issue with Depth. Positive/negative is not really the right way to encode the frame/cell distinction, but it's convenient. Fortunately ∞ can be used in place of negative zero, but there can still be problems if the rank is computed.

### Nothing (`·`) interacts strangely with Before and After
Since `𝕨F⊸G𝕩` is `(F𝕨)G𝕩` and `𝕨F⟜G𝕩` is `𝕨F G𝕩` in the dyadic case, we might expect these to devolve to `G𝕩` and `F G𝕩` when `𝕨` is not present. Not so: instead `𝕩` is substituted for the missing `𝕨`. And Before and After are also the main places where a programmer might try to use `𝕨` as an operand, which doesn't work either (the right way is the train `𝕨F⊢`). It's also a little strange that `v F˜·` is `·`, while `·F v` is `F v`.

### Glyphs that aren't great
Blanket issue for unintuitive glyphs. Currently I find `⥊⊏⊑⊐⊒⍷⁼⎉⚇` to not be particularly good fits for what they describe.

### Can't access array ordering directly
Only `⍋⍒` use array ordering rather than just array equality or numeric ordering. Getting at the actual ordering to just compare two arrays is not hard but also not obvious: `⍋⌾⋈` is TAO `≤`.

### Tacit evaluation is opaque
Evaluating a derived function does a lot of work that often can't be connected with any particular source location. This is why stack traces don't dig into tacit functions, for now at least. For the interactive side of debugging, `•Show` is so powerful in tacit code that I'm not sure this is even an issue, but it's still worth keeping in mind if BQN adds a more traditional debugger. And it's troublesome for implementers, who tend to rely on stepping through opcodes.

### No access to fast high-precision sum
Fold has a specific order of application, which must be used for `` +` ``. But other orders can be both faster and more precise (in typical cases) by enabling greater parallelism. Generally ties into the question of providing precision control for a program: it could be fixed by a flag that enables BQN to optimize as long as the results will be at least as precise (relative to the same program in infinite precision) as the spec. Absent this feature it will probably be provided with `•math.Sum`.

### No one right way to check if a value is an array
The mathematical approach is `0<≡𝕩`, which can be slow without runtime support, while the efficient approach is `0=•Type𝕩`, which is ugly and uses a system function for something that has nothing at all to do with the system. These are minor flaws, but programmers shouldn't have to hesitate about which one they want to use.

### Tacit code can't build lists easily
It's unergonomic, and also quadratic in a naive runtime. The problem of course is that tacit code can only combine up to two values at a time, while in explicit code, list notation combines any number of them. In a language less beholden to syntax, `List` would simply be a function with an arbitrary number of arguments and you'd be able to form trains with it—although this *does* require distinguishing when it's used as a train versus as a plain function. First-class functions get you this behavior if you really need it.

### Monadic argument corresponds to left for `/` and `⊔`
Called dyadically, both functions shuffle cells of the right argument around, which is consistent with other selection-type functions. But the monadic case applies to what would be the left argument in the dyadic case.

### High-rank array notation awkwardness
The notation `[]` will be added for high-rank arrays, the same as BQN's lists `⟨⟩` except it mixes at the end. It looks okay with BQN strands but clashes with BQN lists. At that point it becomes apparent that specifying whether something is a high-rank array at the top axes is kind of strange: shouldn't it be the lower axes saying to combine with higher ones? A more concrete point of awkwardness is that literal notations can only form arrays with rank 1 or more, preventing unit arrays from being destructured. Syntax with `<` and `[]` would be complete over non-empty arrays.

### Assert has no way to compute the error message
In the compiler, error messages could require expensive diagnostics, and in some cases the message includes parts that can only be computed if there's an error (for example, the index of the first failure). However, Assert (`!`) only takes a static error message, so you have to first check a condition, then compute the message, then call Assert on that. Kind of awkward, but better than it used to be before one-argument Assert was changed to use `𝕩` for the message. The issue generally applies to high-quality tools built in BQN, where giving the user good errors is a priority.

### Monadic `⊑` versus `>`
Both pull out elements and reduce the depth. But they face in opposite directions. However, neither should be thought of as the inverse to `<`: that's `<⁼`. And `>` can't reduce the depth to 0, so it's pretty different from `⊑` or `<⁼`.

The directions of `⊏⊐` and so on were mainly chosen to line up with `∊`: the argument that indices apply to (that is, the one that is searched or selected from) corresponds to the open side of the function. I'd probably prefer new glyphs that don't have this sort of directionality, however.

### Can't take Prefixes or Suffixes on multiple axes
This is a natural array operation to do, and results in an array with a joinable structure, but as Prefixes and Suffixes are monadic there's no way to specify the number of axes to use.

### Hard to manipulate the result of a modifier
Trains and compositions make it easy to work with the results of functions, in some sense. The same can't be said for modifiers: for example, in a non-immediate block modifier, the derived function is `𝕊`, but you can't apply `˜` to it. This seems to call for modifier trains but people who worked with early J were confident they're not worth it. Except they just added them back. Who knows.

### Modified assignment modifies the left (secondary) argument
So you end up with `˜↩` a lot of the time. For ordinary assignment it's pretty reasonable to say the value is primary, but modified assignment flips this around.

### Changing boundary behavior can require very different code
This mainly applies to pairwise operations; for bigger stencils you'd use Windows, and probably handle boundaries with multidimensional selection. For pairwise operations there are four different paths you might use: decrease size using `↓`; periodic conditions with `⌽`; fixed or computed boundaries with `«` and `»`; and increased size with `∾`. Having all this flexibility is great, and it's hard to imagine a parametrized system that offers the same without being difficult to remember. However, some of these functions take lengths and some take values, the latter class only works on one dimension at a time, and for `∾` the argument can go on either side. This is frustrating if you have a reason to switch between the conditions.

### Only errors in functions can be caught
The modifier `⎊` allows errors in a function to be caught, but a more natural unit for this is the block (scope, really). However, catching errors shouldn't be common in typical code, in the sense that an application should have only a few instances of `⎊`. Ordinary testing and control flow should be preferred instead.

### Modifiers look looser than trains without spaces
Consider `⋆∘-×˜`. It's just a sequence of three functions so the use of `∘` rather than `·` is to highlight structure: `⋆∘-` is more tightly bound so the suggestion is to consider this composition as a single entity. But in fact `-` is closer to `×˜` than to `⋆`, intuitively suggesting the opposite. Adding a space fixes it: `⋆∘- ×˜` visually connects `⋆∘-`. It's unfortunate that this is something the writer must do rather than something the notation encourages.

### Have to be careful about intermediate results with affine characters
A computation like `(a+b)÷2` (midpoint between characters `a` and `b`, of the distance between them is even) or `5>v-n` (equivalent to `v<5+n`) is conceptually okay, but the first will always fail because `a+b` is invalid while the second will (even worse!) fail only if `v` is a character with code point smaller than `n`. Arithmetic manipulations that would be valid for numbers aren't for the number-character system.

Numbers and characters are subsets of a linear space with components "characterness" (0 for numbers and 1 for characters) and value (code point for characters). Numbers are a linear subspace, and characters a subset of an affine one. Their union isn't closed under addition and subtraction in either component. Usually this is good, as failing when the user creates a nonexistent character or double-character can catch a lot of errors. But not always.

### Each block body has its own label
In a block with multiple bodies, the label (the self-name part of the header) refers to the entire block. However, there's no way to give only one label to the entire block. If you want to consistently use the same internal name, then you may have to write it many times. It's also a weird mismatch, conceptually.

### And/Or/Max/Min are all tangled up
Boolean And (`∧`) and Or (`∨`) are identical to Min (`⌊`) and Max (`⌈`) when restricted to Boolean arguments, and this would fit nicely with their monadic role as sorting functions: for example `a∧b ←→ ⊑∧a‿b`. Furthermore the pairing of Min with Floor and Max with Ceiling is mnemonic only and not especially natural. The reason I have not used these glyphs for Min and Max, and have instead extended them to the somewhat superfluous [arithmetic logical functions](../doc/logic.md) is that Min and Max have different [identity elements](https://aplwiki.com/wiki/Identity_element) of `∞` and `¯∞` rather than `1` and `0`. Having to code around empty arrays when using `∧´` would be a fairly big issue.

The other drawback of Min (`∧`) and Max (`∨`) is that the symbols are counterintuitive, but I have found a way to remember them: consider the graph of variables `a←x` and `b←¬x` for x from 0 to 1: two crossed lines. Now the graph of `a∧b` is a caret shape and `a∨b` is a vee.

### Inputs to modifiers are called operands?
"Operand" is derived from "operator". "Modificand" would be better if it weren't both made up and hideous.

### Scan ordering is weird
Scan moves along the array so that it uses results as left arguments, which is opposite to the usual right-to-left order of evaluation. But I think this is still better than scanning the array in reverse. You can always use Swap on the operand, or recover the APL scan ordering by doing a Reduce-Each on Prefixes.

### Bins is inconsistent with Index of
In Dyalog APL, Interval Index is identical to Index Of if the left argument has no duplicate cells and every right argument cell intolerantly matches a left argument cell. In BQN they're off by one—Bins is one larger. But all the caveats for the Dyalog relation indicate this might not be so fundamental.

### Empty left argument to Select
Select chooses whether `𝕨` maps to axes of `𝕩` or selects from the first axis based only on its depth. An empty array has depth 1, so it selects no major cells. However, it could also select from no axes (a no-op) and in some contexts the other behavior would be surprising.

There's a similar problem with `⟨⟩` as a left argument to `⊑`: it could be a list of no indices, or a length-0 index. Currently it's treated as an index, causing errors when `𝕨` is a variable-length list of indices. This could be mostly fixed with backwards compatibility by choosing the other way when `𝕩` has nonzero rank.

### Special names other than 𝕣 can't be written as modifiers
I decided that it was better to allow `𝕨_m_𝕩` to work with no spaces than to allow `_𝕩` to be a modifier, and this rule also helps keep tokenization simple. But to apply `𝕩` as a modifier you have to give it a different name. Could actually be a good thing in that it encourages you to stick to functions, as they're nicer in lots of other ways.

### Nothing in header is something in body
Since `·` is used for an ignored value in destructuring, the header `·𝕊𝕩:` indicates that `𝕨` has some value, that is, that it's not `·`.

### Exact result of Power is unspecified
The other arithmetic functions round to nearest, and compound functions such as `⊥` have been removed. But Power makes no guarantees, and the result could change over time based on different special code. Dyadic logarithm is similar, but expected because of its inverse status.

### Unclear primitive names
Blanket issue for names that I don't find informative: "Solo", "Bins", "Find", and "Group".

### Tacit exports can leak data
One of the nice facets of BQN's module system is that it provides perfect encapsulation: if you have variables `a` and `b` in a namespace (or closure) initialized so that `a≤b`, and all exported operations maintain the property that `a≤b`, then that property will always be true. Well, not quite: if you define, say `Inc ⇐ IncA ⊣ IncB` to increase the values of both `a` and `b` by `𝕩`, then `Inc` maintains `a≤b`, but `IncA` doesn't—and it can be extracted with `•Decompose`. This isn't too serious because it sounds impossible to do accidentally, and it's easy to protect against.

### Strands go left to right
This is the best ordering, since it's consistent with `⟨⋄⟩` lists. And code in a strand probably shouldn't have side effects anyway. Still, it's an odd little tack-on to say separators *and strands* go left to right, and it complicates the implementation a little.

### Primitive name capitalization
I went with "Index of" and "Less Than or Equal to" but the last word blends into surrounding text. Should they be fully capitalized or hyphenated? I've started to capitalize when there's ambiguity actually.

## Solved problems

Problems that existed in mainstream APL or a transitional BQN that have in my opinion been put to rest (while in some cases introducing new problems). Listed in reverse chronological order by time solved, by my recollection.

### Trigonometry
Solved with namespaces. dzaima/BQN uses `•math` to expose math functions, but it could also be provided in a system library (still deciding). It's up to the implementation how the functions are implemented.

There are a lot of standard functions and I don't want to use separate primitives or a menu-style primitive like APL Circle for them. You can define all the functions eventually if you use complex exponential and take real and imaginary parts and inverses, but this doesn't sound well-suited for implementation. And there should be a math library that gives you the standard functions with normal names, but how will it be implemented?

### Should have a rounding function
Also placed in the math namespace.

There is a standard way to round floats—to nearest integer, ties to even—but it's fairly hard to implement and would have to be specially recognized for performance. It would be nice to have a better way to access this.

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
Fixed with [Group](../doc/group.md), which I found May 2020. Group serves as a much improved [Partition](https://aplwiki.com/wiki/Partition). Later extended to multiple axes as well to get all the functionality.

### Key doesn't do what you want
Fixed with [Group](../doc/group.md) to my satisfaction, except for the trailing-empty-group problem. There were various issues with Key operators in J and Dyalog, such as the fact that the ordering and presence of groups depends on where and whether the keys appear. Also, Dyalog's Key can return keys and values, but they are in a different format than the input: an array of pairs instead of two arrays. Monadic Group returns indices, which can be used how the programmer wants.

### Greek letter issues
Fixed by not using Greek letters. In particular, the idea of using fancy Latin letters as fixed names for function arguments was suggested in proto-BQN sessions, possibly by Nathan Rogers.

### Stranding gotchas
Fixed with list notation, which descends from the array notation developed by Phil Last and later Adám Brudzewsky. The problem that array notation has much more cluttered syntax than stranding has pretty much been fixed by the ligature character `‿`, which I discovered during proto-BQN discussions.

### Functions are not first class
Fixed by allowing a variable to be written with a different syntactic role than it was created with, suggested by Adám in proto-BQN discussions.

### APL is not context-free
Fixed with the casing conventions for variable names, which I think I first saw in [APL\iv](https://aplwiki.com/wiki/APL%5Civ), although the cases are swapped relative to BQN.

### Selective assignment requires a named variable
Fixed with structural Under, which I developed in 2017 and 2018.

### It's hard use an array as a major cell
Fixed with `≍`: dyadic form from A+ and monadic/dyadic pair from J.

### Scan and Windowed Reduce shouldn't always reduce
Fixed with Prefix, Suffix, and Infix operators in J. Changed to functions in BQN.
