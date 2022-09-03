*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/why.html).*

# Why use BQN?

There are plenty of clean, modern languages out there, and a good number of array languages. I don't think any other language fits both descriptions quite so well as BQN, and I find the combination lets me write powerful and reliable programs quickly. What you find in the language will depend on your background.

If you haven't yet used an array language, BQN will present you with new ways of thinking that can streamline the way you work with data and algorithms. There's no denying that array programming has begun to creep into the mainstream, and you might be wondering if BQN has anything to offer when you can hack reduces and filters with the best of them. It does: real array programming is different in character, with more and better array operations on immutable multidimensional arrays, and syntax better suited to them. Performance that resembles a low-level compiled language more than a high-level dynamic one. Primitives flow together and compose better—one aspect that sets BQN apart from other array languages is a set of combinators that's more intuitive than previous attempts. I also happen to think BQN's [character arithmetic](../tutorial/expression.md#character-arithmetic) system would improve just about any language.

If your favorite language is J, you are missing out even more! Array programmers never seem willing to accept that good ideas can come from people other than Iverson and that legends like John McCarthy and Barbara Liskov advanced human knowledge of how to express computation. They did, and being able to casually pass around first-class functions and mutable closures, with namespaces keeping everything organized, is a huge quality of life improvement. Writing APL again is claustrophobic, the syntax worries and constraints in functionality suddenly rushing back. BQN's mutable objects make methods such as graph algorithms that just don't have a good array implementation (no, your O(n³) matrix method doesn't scale) possible, even natural. With bytecode compilation and NaN-boxing, a natural fit for the based array model, it evaluates that scalar code many times faster than APL or J. The Unix-oriented scripting system stretches seamlessly from quick sketch to multi-file program.

BQN has no intention of being the last word in programming, but could be a practical and elegant tool in your kit—even if only used to inform your use of another language. Give it a try!

## Versus APL and J

Here are some more specific comparisons against the two most similar languages to BQN. I'll try to bring up the areas where BQN can be considered worse, but my focus here is definitely on BQN's strong points—I'm not trying to offer an unbiased account.

BQN is more like APL, but adopts some of the developments made by J as well. However, it's much simpler than both, with fewer and less overloaded primitives as well as less special syntax (J has fewer syntactic rules, but more special cases handled during execution that I think *should* have been designed as syntax).

The major differences are listed on [the front page](../README.md#whats-the-language-like) ("But it's redesigned…"): [based arrays](../doc/based.md), [list notation](../doc/arrayrepr.md), [context-free grammar](../doc/context.md) and [first-class functions](../doc/functional.md), [reworked primitives](../doc/primitive.md), and dedicated [namespace syntax](../doc/namespace.md).

In addition to these, BQN's [block system](../doc/block.md) extends APL dfns with headers, adding some very useful functionality: the header specifies block type and argument names, and also allows for some pattern matching when used with multiple block bodies.

Since this section gets into the details, it's worth highlighting stranding, a feature I think of as an obvious improvement but that many BQN newcomers see as an obvious sign that I don't know what I'm doing! My full argument for this decision is [here](../doc/arrayrepr.md#why-not-whitespace); the two key points are that stranding is a source of ambiguity that can strike at any time, requiring a correction with `⊢` or `]`, and that typing `‿` is really not hard I promise.

BQN's heavier-weight `⟨⟩` syntax for lists also has its own advantages, because it can be formatted nicely across multiple lines, and also allows functions and modifiers to be used easily as elements. Being able to easily map over a list of functions is surprisingly useful!

BQN has no built-in control structures, which can be quite an adjustment coming from certain styles of APL or J. The [control structures](../doc/control.md) page gives some ways to write in a more imperative style, but it's definitely not the same.

Primitives in BQN are pure functions that don't depend on interpreter settings. The following kinds of interpreter state don't apply:
- The index origin is 0.
- APL and J use approximate comparison in primitives, controlled by a value called the comparison tolerance (`⎕CT` in APL). The choice of which primitives use it and how is kind of arbitrary, and a nonzero comparison tolerance can lead to confusion, bugs, and unavoidable performance problems in some primitives. Nonetheless, I planned to add tolerant comparison to BQN—until I realized that after a year spent programming in BQN I'd hardly noticed its absence, and no one had asked for it either.
- Random number generation isn't a primitive: instead there's a global generator `•rand` and initialized generators with `•MakeRand`. This makes managing independent generators easier, and with namespaces [you get](../spec/system.md#random-generation) several convenient functions for different use cases.

Some factors specific to APL or J are given in the sections below.

### APL

*See also the [BQN-Dyalog APL dictionary](../doc/fromDyalog.md). I compare to Dyalog here as it's the most widely used dialect.*

BQN cleans up some awkward syntax left over from when each APL operator was special: the outer product is written `Fn⌜` rather than `∘.fn`, and reduction `Fn´ arr` is separated from compress `b/arr` instead of [overloading](https://aplwiki.com/wiki/Function-operator_overloading).

BQN adopts [leading axis theory](../doc/leading.md) as developed in SHARP APL and applied in A+ and J. With this it can collapse APL pairs such as `⌽⊖` and `/⌿` to one primitive each, and remove APL's complicated function axis (such as `⌽[2]`) mechanism. The Rank modifier `⎉` then applies these primitives to non-leading axes. While this method is required in J and also favored by many users of Dyalog APL, it definitely doesn't enjoy universal support—it can be harder to learn, and less convenient for some common cases. Summing rows with `+/` in APL is quite convenient, and BQN's `+˝⎉1`, or `+˝˘` for matrices, just aren't as nice.

Arguably BQN cuts down the set of primitives too much. Base conversion `⊥⊤`, partitioning `⊂⊆`, and matrix division `⌹` are commonly asked-for primitives, but they don't match [my conception](primitive.md) of a primitive. And while each can be implemented (with short snippets, other than `⌹` which requires a library), there's definitely a convenience loss. But there's always [ReBQN](../doc/rebqn.md)…

BQN's version of the Power modifier `⍟` allows an array operand to specify multiple results, for example `Fn⍟(↕4)` to get 0 up to 3 iterations. Intermediate results are saved, so the number of calls only depends on the highest iteration number present. On the other hand, BQN has no direct equivalent of Power Limit `⍣≡`, requiring it to be [implemented manually](https://mlochbaum.github.io/bqncrate/?q=power%20limit).

An APL selective assignment `arr[2 3]+←1` should usually be written with [Under](../doc/under.md) in BQN: `1⊸+⌾(2‿3⊸⊏)arr` (but the correspondence might not always be so direct). You can think of this as a very fancy At (`@`) operator, that lets you pull out an arbitrary part of an array.

Dfns are adjusted in a few ways that make them more useful for general-purpose programming. A BQN block always runs to the last statement, so a block like `{Update 𝕩 ⋄ 1+x}` won't return early. Writing modification with `↩` makes it clearer which variable's which. Dfns also do a weird shadowing thing where `a←1⋄a←2` makes two different variables; in BQN this is an error because the second should use `↩`. Tradfns are removed entirely, along with control structures.

BQN doesn't have an exact replacement for dfn guards, although the [predicate](../doc/block.md#predicates) `?` can look similar: `{2|⍵ : 1+3×⍵ ⋄ ⍵÷2}` is equivalent to `{2|𝕩 ? 1+3×𝕩 ; 𝕩÷2}`. But note that where APL uses the statement separator `⋄`, BQN uses the body separator `;`. This means that the if-true branch in BQN can consist of multiple statements (including additional predicates), but also that the if-false branch can't access variables defined in or before the condition. In both cases the "better" behavior can be obtained with an extra set of braces and possibly assigning names to arguments `⍵`/`𝕩`. I think guards end up being cleaner when they work, and predicates are more versatile.

BQN's namespaces have a dedicated syntax, are *much* easier to create than Dyalog namespaces, and have better performance. I use them all the time, and they feel like a natural part of the language.

### J

*See also the [BQN-J dictionary](../doc/fromJ.md). J is under development again and a moving target. I stopped using it completely shortly after starting work on BQN in 2020, and while I try to keep up to date on language changes, some remarks here might not fit with the experience you'd get starting with J today.*

To me building with J feels like making a tower out of wood and nails by hand: J itself is reliable but I soon don't trust what I'm standing on. J projects start to feel hacky when I have multiple files, locales, or a bit of global state. With BQN I begin to worry about maintainability only when I have enough functions that I can't remember what arguments they expect, and with lexically-scoped variables I simply don't use global state. If you don't reach this scale (in particular, if you use J as a calculator or spreadsheet substitute) you won't feel these concerns, and will have less to gain by moving to BQN. And if you go beyond, you'd need to augment your programs with rigorous documentation and testing in either language.

The biggest difference could be in file loading. If you write a script that depends on other files, and want it to work regardless of the directory it's called from, you need to deal with this. In J, `>{:4!:3 ''` gives the name of the most recently loaded script (the current one, if you put it before any imports), but to make it into a utility you need this glob of what's-going-on:

    cur_script =: {{(4!:3$0) {::~ 4!:4<'y'}}

In BQN it's `•path`. And usually you don't need it because `•Import` resolves paths relative to the file containing it (if you want to use the shell's current directory, you have to use `•wdpath` explicitly).

J uses numeric codes; BQN uses mostly names. So J's `1&o.` is BQN's `•math.Sin`, and `6!:9` corresponds to BQN's `•MonoTime`.

J uses bytestrings by default, making Unicode handling a significant difficulty ([see](https://code.jsoftware.com/wiki/Vocabulary/uco) `u:`). BQN strings are lists of codepoints, so you don't have to worry about how they're encoded or fight to avoid splitting up UTF-8 bytes that need to go together.

But J has its type advantages as well. I miss complex number support in BQN, as it's an optional extension that we haven't yet implemented. And BQN has a hard rule that only one numeric type is exposed to the programmer, which means high-precision integers and rationals aren't allowed at all for a float-based implementation. I think this rule is worth it because J's implicit type conversion is hard to predict and an unexpected numeric type can cause sporadic or subtle program errors.

BQN uses a modifier `⟜` for J's hook, adding `⊸` for a reversed version (which I use nearly twice as often). This frees up the 2-train, which is made equivalent to Atop (`∘`). It's the system Roger Hui came to advocate, since he argued in favor of a hook conjunction [here](https://code.jsoftware.com/wiki/Essays/Hook_Conjunction%3F) and made 2-train an Atop when he brought it to Dyalog APL. As an example, the J hook `(#~0&<:)` to remove negative numbers becomes `0⊸≤⊸/` in BQN. Hooks are also the topic of [Array Cast episode 14](https://www.arraycast.com/episodes/episode17-tacit4-the-dyadic-hook), where the panel points out that in J, adding a verb at the far left of a dyadic train changes the rest of the train from dyadic to monadic or vice-versa, an effect that doesn't happen in BQN.

J locales are not first-class values, and BQN namespaces are. I think BQN's namespaces are a lot more convenient to construct, although it is lacking an inheritance mechanism (but J's path system can become confusing quickly). More importantly, BQN namespaces (and closures) are garbage collected. J locales leak unless manually freed by the programmer. J has no mutable data at all; to simulate it properly you'd have to write your own tracing garbage collector, as the J interpreter doesn't have one.

In J, each function has a built-in rank attribute: for example the ranks of `+` are `0 0 0`. This rank is accessed by the "close" compositions `@`, `&`, and `&.`. Choosing the shorter form for the close compositions—for example `@` rather than `@:`—is often considered a mistake within the J community. And function ranks are unreliable: consider that the ranks of `]@:+`, a function that always has the same result as `+`, are `_ _ _`. In BQN there aren't any close compositions at all, and no function ranks. J's `&.>` is simply `¨`, and other close compositions, in my opinion, just aren't needed.

J has several adverbs (key, prefix, infix, outfix…) to slice up an argument in various ways and apply a verb to those parts. In BQN, I rejected this approach: there are modifiers for basic iteration patterns, and functions such as [Group](../doc/group.md) (`⊔`) that do the slicing but don't apply anything. So `</.~a` is `⊐⊸⊔a`, but `fn/.~a` is `>Fn¨⊐⊸⊔a` (I also reject J's implicit merge except for the Rank modifier, as I don't think function results should be assumed homogeneous by default). BQN's approach composes better, and is more predictable from a performance perspective.

Gerunds are J's answer to BQN's first-class functions. For example J's ``(%&2)`(1+3*])@.(2&|)`` would be written `2⊸|◶⟨÷⟜2,1+3×⊢⟩` with a list of functions. I think lists of functions are a big improvement, since there's no need to convert between gerund and function, and no worries about arrays that just happen to be valid gerunds (worried about losing the ability to construct gerunds? Constructing tacit functions in BQN is much easier). Unrelated to these fundamental issues, passing J functions around either as values or gerunds presents some idiosyncratic challenges, discussed below.

#### Named functions

Its impact on the programmer is smaller than a lot of the issues above, but this section describes a behavior that I find pretty hard to justify. What does the identifier `fn` indicate in a J expression? The value of `fn` in the current scope, one might suppose. Nope—only if the value is a noun. Let's make it a function.

       fn =: -
       fn`-
    ┌──┬─┐
    │fn│-│
    └──┴─┘

The tie adverb `` ` `` makes gerund representations of both operands and places them in a list. It returns `'fn';,'-'` here: two different strings for what we'd think of as the same function. But it's just being honest. The value of `fn` really is more like a name than the primitive `-`. To see this we can pass it in to an adverb that defines its own local, totally separate copy of `fn`.

       fn{{u 3}}
    _3
       fn{{
         fn =. %  NB. local assignment
         u 3
       }}
    0.333333

That's right, it is not safe to use `fn` as an operand! Instead you're expected to write `fn f.`, where `f.` ([fix](https://code.jsoftware.com/wiki/Vocabulary/fdot)) is a primitive that recursively expands all the names. Okay, but if you didn't have these weird name wrappers everywhere you wouldn't have to expand them. Why?

       a =: 3 + b
       b =: a^:(10&<) @: -:
       b 100
    15.25

This feature allows tacit recursion and mutual recursion. You can't do this in BQN, because `A ← 3 + B` with no `B` defined is a reference to an undefined identifier. You have to use `{B𝕩}` instead. So this is actually kind of nice. 'Cept it's broken:

       b f.  NB. impossible to fix all the way
    (3 + b)^:(10&<)@:-:

       b f.{{
         b =. 2
         u 100
       }}
    |domain error: b
    |       u 100

A tacit-recursive function can't be called unless its definition is visible, period. We gained the ability to do this cool tacit recursion thing, and all it cost us was… the ability to reliably use functions as values at all, which should be one of the things tacit programming is *good* for.

It gets worse.

       g =: -
       f =: g
       g =: |.
       f i. 3
    2 1 0
       <@f i. 3
    ┌─┬─┬─┐
    │0│1│2│
    └─┴─┴─┘

This should not be possible. `f` here doesn't behave like `-`, or quite like `|.`: in fact there is no function that does what `f` does. The result of `f` depends on the entire argument, but `<@f` encloses rank 0 components! How long would it take you to debug an issue like this? It's rare, but I've run into it in my own code and seen similar reports on the forums.

The cause is that the value of `f` here—a named `g` function—is not just a name, but also comes with a function rank. The function rank is set by the assignment `f =: g`, and doesn't change along with `g`. Calling `f` doesn't rely on the rank, but `@` does, so `<@f` effectively becomes `<@|."-`, mixing the two versions of `g`. The only explanation I have for this one is implementation convenience.
