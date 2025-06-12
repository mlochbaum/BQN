*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/fiveyears.html).*

# Five-year review of BQN design

The first commit separating [BQN2NGN](https://github.com/mlochbaum/BQN2NGN) from ngn/apl, entitled [Change all the functions](https://github.com/mlochbaum/BQN2NGN/commit/8960cfe2511bb4f53bf5567ff31751acf52bb889), was made on May 10, 2020. BQN's [design process](history.md) has no definite beginning, but a concrete implementation marks the first step of evaluating that design. Five years later, what findings can other designers of similar languages take from it? I lay out my personal impressions here.

Many people assume that the goal of any serious language is to be the best, at least in its paradigm—this is not at all how I thought of BQN. I wanted to play it safe and make a solid foundation both for programming and for more ambitious designers in the future. APL offers time-tested ideas (with or without a passing grade): for example, I've discussed how evaluating [left to right](ltr.md) was too big of a change to consider. I also wanted to get to a [stable](stability.md) core language quickly; I think real advances in array programming will come from explorations by multiple designers over time, not me obsessively polishing this one particular view of it. The upshot is that "I trusted APL too much" was the expected and accepted kind of error, and "my ideas were too bold" should be much rarer!

I'll focus on specifics of language design, and primitives in particular. I do think some other aspects of BQN, like the web REPL and documentation, have pushed language developers to improve on these quality-of-life features. But I don't have so much insight into these choices as there's not as much feedback, and [Uiua](https://www.uiua.org/)'s probably a better example now anyway.

## Primitives

I won't say too much about glyph choices, but it's worth noting that having a convention for primitive functions versus 1- and 2-modifiers is very helpful for learners. I like superscripts but Unicode options for them are very sparse so I suffer for it.

I've discussed [overloading](overload.md) and I don't necessarily support trying to pack in a monadic and dyadic meaning for every glyph, but here I'll stick to that framework to evaluate BQN on its own terms.

### Arithmetic

I mostly stuck with APL's treatment of [arithmetic](../doc/arithmetic.md), and mostly I still think it's fine (having `⌈` and `⌊` for maximum and minimum is such a big improvement over non-array languages). Modulus's argument order is right in isolation but backwards relative to `÷`, and `|` isn't very suggestive, so `%` or similar for `|˜` might be better. I'm not happy with `×` for sign and would rather just remove it in favor of `÷⟜|`, or `0(<->)𝕩`, or even `¯1⋆0>𝕩` since that shows up too—although mostly `×` just ends up as a less clear golf for `0<𝕩`. Still feel weird about pairing `+` with complex conjugate but I guess it's got to go somewhere.

Adding `√` seems like a no-brainer to me (some APLs do it too). There are precision issues around `𝕨√𝕩` since `𝕩⋆÷𝕨` rounds twice, but it's better for the implementation to deal with this stuff than the programmer.

The glyph `⋆` (star) has caused minor confusion with `*` (asterisk) from APL but avoids confusion with `*` from everywhere else. I don't have a strong opinion on whether it's worth it or not.

Character arithmetic is great, every language with characters should use it, [some newer array languages](https://aplwiki.com/wiki/Character_arithmetic) are already on board.

[Linear extensions](../doc/logic.md#extension) of logic functions `∧∨¬`: well, GCD and LCM are clearly rather niche but I don't think the bilinear extensions add a lot of value either. `¬` as `1-𝕩` is more useful, very nice that `-⟜¬` sending 0,1 to -1,1 also works as a linear map. The dyadic Span feels good to use when it shows up but isn't that common. The character `¬` is better than `~` for these because of how the vertical part suggests the added 1.

Leaving out [comparison tolerance](https://aplwiki.com/wiki/Comparison_tolerance) has been okay but not entirely painless: you have to be pretty careful when taking the floor of a floating-point computation for example. A global comparison tolerance trades these issues for less noticeable ones in a larger fraction of code, like being wrong on actual near-integers, and weird results and bad performance on searches. I'm still inclined to say it's easier to program correctly with tolerance, but it's a small difference and I don't think it's worth making a bunch of primitives stateful.

IEEE 754 issues: you have to [identify](../implementation/primitive/arithmetic.md#negative-zero) -0 with 0 if you want to safely optimize with integer arrays, which you do. We kept IEEE's other float extensions (with all NaNs indistinguishable, allowing us to NaN-box pointers and characters). `¯∞` and `∞` are a clear win, and NaN is mixed. It's nice that arithmetic can't error on numbers, and it's often possible to arrange comparisons so that edge cases are handled without extra code, but it's also common for otherwise correct code to give wrong results when NaN is involved.

### Array manipulation

I'm happy with the glyphs for [array properties](../doc/shape.md) Rank (`=`), Length (`≠`), [Depth](../doc/depth.md) (`≡`), and Shape (`≢`). Rank is such a basic property that it feels much better to have a dedicated primitive even if it only saves a character, and comparisons like `≤○=` are fairly common. Depth is ugly, as it has to deeply traverse the array when you usually just want to know if the depth is larger than some constant. I think `1⌊≡`, that is, 0 for an atom, and 1 for an array, should be considered instead.

#### Flat arrays

[Reshape](../doc/reshape.md) (`⥊`) ignoring the shape of `𝕩` is a blunder; it should work on the first axis like in J—this is *far* more useful with computed lengths in particular. This would remove the major reason to pair it with Deshape so there's room for some rethinking here. Another idea to consider is restricting reshape (non-computed at least) to the exact case, and separating out cyclic extension: then cycling could be a multi-axis primitive like Take.

On that note, [Reverse/Rotate](../doc/reverse.md) (`⌽`), [Take and Drop](../doc/take.md) (`↑↓`), [Replicate](../doc/replicate.md) (`/`), and [Join To](../doc/join.md) (`∾`) are all classics, they're fine. Of course Take uses fills, so if you don't like that… maybe it should cycle?

[Shifts](../doc/shift.md) `»«` are super useful, and mostly avoid the problems APL's 2-wise reduction has with length 0. There can still be boundary issues, like it's common to want `»⊸≠` except the first result is always 1, and no particular shifted value guarantees that. Well `1»≠⟜«` is solid assuming there's a fill, but it's pretty confusing. Also you can't shift a unit into an array with rank>1, maybe the left argument should be rank-extended.

I declare the [Transpose](../doc/transpose.md) (`⍉`) changes a great success! Yeah, dyadic Transpose is still hard for people to understand and some might prefer J's version, but it's all better than what APL had.

#### Nested arrays

The nested result of [Range](../doc/range.md) (`↕`) on a list argument can be convenient, but it's slow and doesn't encourage array thinking. This suits BQN fine, and I don't think there's much call for an alternative like K's odometer, as the dedicated array programmer would mostly use `⌜` regardless.

[Enlist/Pair](../doc/pair.md) (`⋈`) is very useful, pretty embarrassing it took me over a year to add it. [Solo/Couple](../doc/couple.md) (`≍`) now seems somewhat less important but is still nice to have, particularly for stuff like zipping with `≍˘`.

[Enclose](../doc/enclose.md) (`<`) is what it is. [Merge](../doc/couple.md) (`>`) is good and I'm still happy with the choice to be strict about shapes, even if it's annoying in code golf. The multi-dimensional form of [Join](../doc/join.md#join) (`∾`) comes in handy a lot when working with rank-2 arrays. The extension to allow some elements to have lower ranks was a nightmare to define and tough to implement too. Not having it was frustrating, but it might be possible to get by just allowing a mix of rank-0 and rank-1 elements in a list as a special case.

[Prefixes](../doc/prefixes.md) (`↑`), Suffixes (`↓`), and [Windows](../doc/windows.md) (`↕`) are not pulling their weight. They're useful theoretical tools but aren't very practical. For prefixes/suffixes you almost always want either `1↓↑`, `≠↑↑`, `1↓↓`, or `≠↑↓`, and figuring out which one is a headache. I'd suggest `¯1⊸↓` and `1⊸↓` as better uses for the glyphs `↑` and `↓` respectively (so pairwise differences are `↓-↑` for example). And writing a windowed reduction with `+˝˘k↕𝕩` is a lot of ceremony, but really for performance you mostly want `+˝((≠𝕩)¬k)↕𝕩`, but this is also not great because it copies when you could be taking slices. There's still a lot to dislike about it but APL's windowed reduction might be the winner for not-2-wise cases (just, not sharing a glyph with normal reduction). I often think of performance as pointing the way to better design, and I believe it did here but I was insufficiently informed: what I had seen was a bunch of hacks for various cases in Dyalog, and what I didn't know about was the van Herk/Gil-Werman [method](https://github.com/mlochbaum/Singeli/blob/master/doc/minfilter.md) which beautifully handles associative functions on any window size in linear time using scans. Roughly `k×≠𝕩` function calls for not-provably-associative operands is still not *good*, but seems more palatable now.

### Selection

[Select](../doc/select.md) (`⊏`) is all good, about the best you could hope for as a functional form of APL bracket indexing (it doesn't cover omitted indices except at the end, but the Rank modifier works for initial ones, and internal ones are pretty rare). It wouldn't quite have worked in APL floating array model, because selecting a cell with `(<¨c)⊏𝕩` would be indistinguishable from `c⊏𝕩`. There's still an ambiguity with `⟨⟩⊏𝕩`, which could mean `𝕩` and not `0↑𝕩`, but it's a non-issue in practice.

[Pick](../doc/pick.md) (`⊑`)… what a mess. It works well for selecting a single element, but the nested format for multiple elements is never what you want. I'm fairly convinced now that a better structure would be to always have one element of `𝕨` corresponding to each axis of `𝕩`, but allow these elements to be arrays or more deeply nested with a shared structure. Something like ``(+´𝕨×(1»×`)⌾⌽≢𝕩)⊏⥊𝕩``. There's even an extension to allow a shorter `𝕨` for selecting cells of `𝕩`, if each element of `𝕨` is an array of numbers, as selecting 0-cells in this way gives the same result as picking elements.

I'm not terribly fond of First (`⊑`) and First Cell (`⊏`), and often prefer `⊣´` and `⊣˝`, pronounced "leftmost". These let you pass in a default result as `𝕨`, and immediately suggest the "rightmost" functions `⊢´` and `⊢˝` (but don't try `𝕨` with these, they will return it in all cases).

### Indices and grouping

[Indices](../doc/replicate.md#indices) (`/`) is great of course (how did it take until the 2010s for anyone to add this to APL?), and the pairing with Replicate is very natural. Not having a multi-dimensional form can be annoying in various domains, but as it's not compatible with the 1-dimensional form I still wouldn't want to jam them together.

[The inverse](../doc/replicate.md#inverse) `/⁼` should absolutely be supported if inverses are defined, and extending to unsorted arguments has also been entirely positive for us. I demand credit for the heroic struggle of getting this into J, after [nearly 15 years](https://www.jsoftware.com/pipermail/programming/2010-September/020289.html) of advocacy: I unilaterally implemented it in Dyalog, added it to BQN influencing other languages to do so too, and finally was able to point out the long list of supporting languages and convince Henry to do it in 2024.

Similarly, I think at least the rank-1 form of [Group](../doc/group.md) (`⊔`) would be worth including in most array languages. APL's Key and K's group are poor substitutes because they leave out empty groups and can have ordering issues (although some approaches to dicts with fill values might fix this satisfactorily in K's case).

Both Indices inverse and Group have a [nasty gotcha](problems.md#group-doesnt-include-trailing-empty-groups) where the result length will be too short if indices at the end of the range aren't present, making various programs subtly wrong if the length isn't specified. In the particular case that the indices come from a search `u⊐keys` for some "universe" of possible values `u`, the length should be `≠u`, and a function that takes both the universe and keys would of course know this. In Singeli I defined a single search/group builtin `findmatches` that gives a nested result containing every matching index for each searched value; if elements of `u` are unique then this is also the same as `(≠u) ↑ ⊔ u⊐keys`. It's cool in terms of enabling a lot of functionality with very little implementation work, but using it directly is often pretty clunky so you wouldn't want to get rid of the simpler primitives for it.

### Ordering

[Sorting](../doc/order.md#sort) functions `∧∨` are good and the glyphs aligning with `⍋⍒` is intuitive. Maybe you could ask for sort-by functions but `⍋⊸⊏` is good enough for me, and makes the order of arguments clear; J's `/:` is backwards isn't it?

Equally happy with [Bins Up](../doc/order.md#bins) `⍋` and Bins Down `⍒`. Bins Down isn't used a ton, but one nice feature is that it allows `≠∘⊣-⌽⊸⍒` for `⍋` with exclusive comparisons (and I don't view the pair `⍋⍒` as taking up significantly more resources than a single Bins Up function would; if you understand one then you understand the other).

### Searching

[Index Of](../doc/search.md#index-of) (`⊐`), [Member Of](../doc/search.md#member-of) (`∊`), [Mark Firsts](../doc/selfcmp.md#mark-firsts) (`∊`), and [Deduplicate](../doc/selfcmp.md#deduplicate) (`⍷`), and for that matter [Match](../doc/match.md) (`≡`) and Not Match (`≢`) are the same as APL with the widely-recognized issue in high-rank Member Of cleared up. None of the search glyphs are especially good. No regrets about dropping the set functions Union, Intersection, Without, because the details are hard enough to remember that using `∊` is just less work. Well, I do write out Without often enough that it doesn't seem crazy as a primitive, just not compelling.

[Classify](../doc/selfcmp.md#classify) (`⊐`) is nice! I like how if you have multiple self-search things to do on a list with complicated elements, you can call it once and then use the result like the argument but without the hashing overhead. It also turns Group into [Key](https://aplwiki.com/wiki/Key), which is important if you don't have that primitive.

[Occurrence Count](../doc/selfcmp.md#occurrence-count) (`⊒`) is all right, it's useful somewhat often and is tricky to implement otherwise. But the dyadic [Progressive Index Of](../doc/search.md#progressive-index-of) is rubbish, hardly ever used and not hard to write in terms of Occurrence Count. Sure, a dedicated implementation's faster, but most uses don't need the performance, and it's not that easy to do, with challenges that differ from other search functions. Sorry to waste everyone's time.

The idea with the shorter result of [Find](../doc/find.md) (`⍷`) is that it exposes the symmetry of the problem under reversal, so that `(≠𝕩)↑𝕨⍷𝕩` marks the start of each match and `(-≠𝕩)↑𝕨⍷𝕩` marks the end. Mostly people think in terms of the start and just find this confusing. Also we ended up having to break the strict shape arithmetic to support short `𝕩`. I don't really like Find generally, it feels more like it belongs to a text processing toolkit than array programming. Also the high-rank case is basically never used and no one has a good implementation. Probably it's the only reasonable extension, but you could also just not define it.

### Iteration

Right-to-left fold, the big mistake you've been waiting for. With decent enough mathematical arguments for it, I didn't feel comfortable breaking with APL. Instead I should have noted that [BQN's not mathematics](math.md) and that K was just fine going left to right. In addition to being better for lots of general-purpose programming because you see the elements in index order, it would make the placement of the initial value `𝕨` on the left much more intuitive.

There's no denying that the split of list-wise [Fold](../doc/fold.md) (`´`) and cell-wise [Insert](../doc/fold.md) (`˝`), but column-wise [Scan](../doc/scan.md) (`` ` ``), is super weird: scan corresponds to `¨˝` and not either fold directly. But having the right modifiers `´` and `` ` `` for lists is really important, and then needing `¨˝` for APL2-style reduction is less bad than `F´<˘` for Insert. The high-rank scan isn't quite as good as a dedicated one for lists because you have to enclose `𝕨`, but would you really add a second scan modifier for that?

At present, `` ` `` probably beats `\` as the most troublesome character a programming language can have, because all sorts of markdown-based stuff uses it for code and there's not even a consistent way to escape it. Strongly recommend avoiding both of these.

[Each](../doc/map.md) (`¨`) and [Table](../doc/map.md) (`⌜`) are good, throwing out APL's weird `∘.` is a pretty easy decision. Haven't learned anything about [Rank](../doc/rank.md#rank) (`⎉`) that I didn't know when I started (I even complained about it in the documentation), it's clunky but sometimes you need it. [Cells](../doc/rank.md) (`˘`) has worked out great as the most common special case however.

I'm down on [Depth](../doc/depth.md#the-depth-modifier) (`⚇`), because it's rarely useful, the details are hard to understand, and the programmer can implement it more explicitly and flexibly with recursion. Should have given more thought to how I never liked J's `L:` either. The cases each-left `⚇¯1‿∞`, each-right `⚇∞‿¯1`, and pervasion `⚇0` all seem like fine choices for more specialized primitives, they'd just take up a lot of characters.

BQN's [Repeat](../doc/repeat.md) (`⍟`) is J's with some obvious adjustments. No problems here; handling an array for `𝕘` is a bit complicated and not crucial but is nice to have. A different language might add repeat-until type primitives but I still think it's inappropriate to try to special-case them into Repeat. We've added `•_while_` which covers the most important cases but becomes ugly if you want to save intermediate results.

### Combinators

The primitives `⊣⊢˙˜∘○⊸⟜⊘◶` feel like an appropriate set for a language that wants to make [tacit](../doc/tacit.md) programming nice but isn't that focused on it. Nothing to add beyond [quoting myself](https://chat.stackexchange.com/transcript/52405?m=54577483#54577483) a month into development: "`⊸`/`⟜` are extremely magical and make tacit programming like 20% easier."

### Undo, Under

I hardly know what to say about [structural Under](../doc/under.md) (`⌾`). Most people find it intuitive, except the things they intuit are often not the same! The basic flat array case is very easy to implement using indices `↕∘≠⌾⥊𝕩`, but even then ruling out non-structural functions and checking for duplicates takes some work, and beyond it, nested cases run into all sorts of little implementation issues. Similar functionality can be provided in a way that's more like old imperative APL than new functional stuff. I highly recommend [Understanding selective assignment](https://doi.org/10.1145/75144.75153), where Jim Brown gives a more unified and consistent approach to APL2's assignment, and so-called "mutable value semantics" works by passing mutable views into variables with exclusive ownership.

[Undo](../doc/undo.md) (`⁼`) is complicated to support and could be left out, but the benefits are significant. Using it for computational Under is worth questioning. One point in favor is that some cases of Under that look structural like `𝔽⌾⍉` or `𝔽⌾⌽` sometimes aren't because `𝔽` changes the shape and instead are relying on the inverse of `𝔾`.

### Errors

Making [Assert](../doc/assert.md) (`!`) a primitive feels very right in retrospect: of course it's meaningless from a mathematical view of programming but it's a fundamental part of writing code. [Catch](../doc/assert.md#catch) (`⎊`) could safely be a system modifier, as you often want to use it with `•CurrentError` anyway, but I don't have any issue with it as a primitive either.

## Grammar

A [context-free grammar](../doc/context.md) and [first-class functions](../doc/functional.md) are important features, but BQN's system with case-insensitive variables is not the only way to bring these to APL. TinyAPL's explicit role-conversion syntax is more intuitive and makes converting un-named values as easy as named ones, at the cost of adding that extra syntax.

Modifiers are a major source of unjustified complexity. I'm entirely happy with leaving out J's 2-modifier partial application and 1-modifier composition, and would want to go further. One way is to cut out named modifiers entirely, and have a primitive 2-modifier that can apply a monadic function like `arg&Fn`. Named 2-modifiers are so hard to read in an expression context that I might actually prefer the structure of `⟨+,×⟩&Oper` over `+ _oper_ ×`. Of course I still like all the `⊸⟜○` primitives and wouldn't want to get rid of them like K does. But like K's adverbs, a primitive modifier might have an underlying function value; perhaps `(⊸)` would even convert to a function role.

### Array notation

Always consider destructuring when thinking about [array notation](../doc/arrayrepr.md#array-literals), since primitives are fine for forming arrays but only syntax is good for destructuring.

I'm still all for explicit stranding `‿`; a less-obvious benefit over implicit is that it works on functions. It doesn't fully substitute for `⟨⟩` because, besides looking ugly with large structures, it can't form 1-element lists (`⋈` can do that in code, but not in destructuring).

I held off on adding high-rank notation `[]` for a while so I know what a difference it makes, and… it's been kind of disappointing. Having it for destructuring headers is good but doesn't come up often. New programmers are always expecting `[]` to be the list notation, and it'd let you copy-paste JSON too, so doing that and ditching `⟨⟩` would be tempting if I started over. Also note that the high-rank notation doesn't let you form rank-0 or many empty arrays, so it's not "complete" in any sense.

### Blocks

[Blocks](../doc/block.md) are one component of BQN that had major additions over time, so earlier features were sometimes designed without knowledge of later ones. One bit of ugliness is that the header `name:` is for an immediate block although it could be a monadic function with implied `𝕊`; the main reason for this is at the time I wanted `name→` for an early return, and I've removed that from the spec and all but it still kind of feels like a feature we want so it's all very confusing.

[Headers](../doc/block.md#block-headers) feel way more complex than they need to be, and a huge chunk of that is all the different modifier combinations. Again just dropping user-defined modifiers is possible—this also means no `𝔽𝔾𝕗𝕘𝕣` in the character set. APL has no immediates, although I'd say that exacerbates the issue that choosing modifiers over first-class functions for the nicer syntax leaves you with worse functionality. An approach without this issue would be to support immediate modifiers only, requiring non-immediate ones to be nested.

Determining the syntax of a block from special names `𝕩`, `𝔽`, etc. in the body is something I'd want to get away from if at all possible. This comes from dfns versus dops in APL, but BQN's use for functions versus immediate blocks really highlights the issue and is a common source of confusion and errors. Making any block with no header a function is probably the practical solution, even though I hate giving functions the simpler syntax when immediate blocks are more fundamental. The thing where two headerless (and predicate-less!) function bodies define the monadic and dyadic cases is useless; this should be spelled out with at least an `𝕊𝕩:` header on the first one.

The convention that `𝕨` means `·` in a monadic block function call is quirky but has held up okay. It's definitely easier to write ambivalent code this way than using tacit combinators.

Namespaces are just about perfect at being namespaces (other than missing convenience features we should add eventually). Sometimes people would like to have this level of syntax support for dictionaries/maps instead… I'm not into it. The purpose of export syntax `a‿b‿c⇐` is maybe kind of muddled: if you have that at the top of a file and then `a←…` later on, there's no hint it was exported, so requiring `a⇐…` could be better.

## Overall thoughts

Clear mistakes: backwards folds `´` and `˝`; APL-style instead of J-style (first-axis) Reshape `⥊`; Progressive Index of `⊒`.

Major successes: character arithmetic; shift functions `»«`; structural Under `⌾`; hooks `⊸⟜`.

Other primitive candidates: flip `<˘⍉>`; restructured Pick ([see above](#selection)); [case](https://aplwiki.com/wiki/Case) `{𝕨⊏⎉0‿1⍉>𝕩}`; windowed reduction.

Stepping back a bit, for the do-it-yourself programmer I say there is a lot of value in the right set of [primitives](primitive.md) on immutable arrays. Most of it's in the boring obvious ones—think intersection, not union, of array languages. And a simple symbol can be the best expression of a simple function, but we spend so much effort to adapt our high-minded multi-dimensional theory to the human factors of 1-dimensional text! Improving array programming is a noble goal but I'm increasingly interested in projects like [Lil](https://beyondloom.com/decker/lil.html) that treat it as a means and not an end. So I hope BQN has made some progress in showing that arrays can sit comfortably even with the vulgar art of object-oriented programming.

Wait, what's that? You want to hear what this review says about… *me*? Oh, I have the skills of every other designer put together, and all of the humility that Dijkstra doesn't! Thanks for asking!
