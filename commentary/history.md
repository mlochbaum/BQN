*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/history.html).*

# BQN's development history

I ([Marshall Lochbaum](https://mlochbaum.github.io/)) began designing BQN as a "fixed APL" in collaboration with my colleagues at [Dyalog](https://aplwiki.com/wiki/Dyalog_Ltd.), and decided to take it on as a personal project when I chose to leave the company several months later in early 2020. BQN is influenced by my array language background, previous work in programming design, studies of APL history, and design discussions before and after starting work on the language. I developed most of the novel functionality in BQN, and am at the end of the day the one who writes the spec, but it includes significant contributions from collaborators, most notably [dzaima](https://github.com/dzaima) and [Adám Brudzewsky](https://github.com/abrudz).

### Background

I learned [J](https://aplwiki.com/wiki/J) as my first computer programming language in 2009, and it's been my language of choice for personal projects from then until I started working with BQN. My first exposure to APL was [Dyalog APL](https://aplwiki.com/wiki/Dyalog_APL), which I began learning gradually after starting work at Dyalog in 2017; while I understand every primitive in detail (I've substantially reimplemented most of them), I've never written even a medium-sized script with it. I studied APL's history and many other APL dialects while helping to create the new [APL Wiki](https://aplwiki.com/wiki/Main_Page) in late 2019. In particular, I found [A+](https://aplwiki.com/wiki/A+) to be a very sound design and nominally took it as the starting point for BQN. As a result, BQN draws more from a general concept of APL than any particular dialect.

I have been working on programming language design since 2011 or earlier. The start of my first major language, [I](https://github.com/mlochbaum/ILanguage), might be placed in 2012 when I published a paper on its approach to mapping, unifying J's trains and function rank. By this time I had worked with several languages including Python and Factor, and implemented little interpreters in Java, Scala, and Haskell. There are many new ideas in I and some of them have made it to BQN, but the language has served mainly as a warning: its pure and simple syntax and approach to array and tacit programming lead to a rigidity that seems to take over from any human designer. And the end result is not usable. So I sought out constructs that would give back some control, like APL's two-layer function/operator syntax and explicit functions (although Dyalog has lexical scoping, it is crippled by the lack of closures and I ended up learning proper use of lexical scoping from Javascript—I've never done real work with any actual Lisp). Another language that I envisioned before BQN, called Iridescence, goes further in this direction, with Python-like syntax that is "noisy" relative to APL. It remains purely theoretical (I'll implement it some day) but has already had an influence on some BQN primitives.

The idea of a "fixed APL" is always percolating in the APL community, because of its long history and strong [backwards compatibility](https://aplwiki.com/wiki/Backwards_compatibility) requirements. BQN arose out of sessions by the Young APLers Group (YAG, unfortunately) inside Dyalog after I suggested that wild ideas for the future of APL might be a good topic for meetings (the previous order of business, right at YAG's formation, was creating the APL Wiki). At these meetings [Adám](https://github.com/abrudz), [Richard Park](https://rikedyp.uk/), [Nathan Rogers](https://www.dyalog.com/blog/2019/08/welcome-nathan-rogers/), and sometimes others discussed and proposed many ideas including the sketch I created that ended up as the blueprint of BQN. When I left Dyalog (putting an end to any notions of using those ideas at the company), I joined [The APL Orchard](https://chat.stackexchange.com/rooms/52405/the-apl-orchard) forum, which most YAG members already used, to post about BQN. [dzaima](https://github.com/dzaima) quickly began building his own BQN implementation using the existing dzaima/APL, and has discussed and contributed to most BQN design decisions since.

[Shapecatcher](https://shapecatcher.com/index.html) is an essential resource for finding appropriate unicode characters. I've been using it heavily, and so has everyone else interested in glyph choices.

## Timeline

The table documents when I encountered features or interesting decisions in BQN. The "source" field indicates how I became aware of the idea while the "person" field gives, to the best of my knowledge, the original inventor (in blank entries and those that start with "w/", I am an inventor).

| Date | Source | Person | Feature | Link
|-----:|--------|--------|---------|-----
| 2009 | J      | Iverson, Hui, Whitney, etc. | Array programming, function-level programming, leading axis theory, tacit programming
| 2012 | I      | I | Hook operators `⊸⟜` (as `hH`)
| 2014 | J      | Smith | Occurrence count and Progressive Index-Of (`⊒`) | [0](http://www.jsoftware.com/pipermail/programming/2014-June/037746.html), [1](http://www.jsoftware.com/pipermail/programming/2016-January/044047.html)
| 2016 | [Dyalog](https://aplwiki.com/wiki/Dyalog_APL) | Scholes | dfns `{}`
| 2017 | Dyalog | | Structural Under
| 2018 | Dyalog | Last, Brudzewsky | [Array notation](https://aplwiki.com/wiki/Array_notation) `⟨⟩`
|      | [APL\iv](https://aplwiki.com/wiki/APL%5Civ) | ktye | Variable case/type connection
|      | [Extended](https://github.com/abrudz/dyalog-apl-extended) | Brudzewsky | Computed axes in reshape
| 2019 | Iridescence | | Prefix, Suffix, Windows
|      | Iridescence | | Multidimensional Join
|      | [A+](https://aplwiki.com/wiki/A+) | Whitney | Interval Index as `⍋`
| 2020 | YAG    | | Define/modify distinction `↩`
|      |        | Brudzewsky | Cross-roles
|      |        | w/ Park? | Ligature `‿`
|      |        | w/ Rogers | Double-struck special names
|      |        | Rogers | Assert primitive `!`
|  -05 | [ngn/apl](https://aplwiki.com/wiki/Ngn/apl) | Nikolov | Multiple function bodies `;`
|  -06 | BQN    | | Group (`⊔`) | [0](https://chat.stackexchange.com/transcript/52405?m=54600976#54600976), [1](https://chat.stackexchange.com/transcript/message/55456874#55456874)
|      | | | Nothing (`·`) | [0](https://chat.stackexchange.com/transcript/message/54703617#54703617)
|      | | dzaima | Inverse headers `𝕊⁼:` | [0](https://chat.stackexchange.com/transcript/52405?m=54639280#54639280), [1](https://chat.stackexchange.com/transcript/message/55860071#55860071)
|      | | w/ dzaima | Headers `:` | [0](https://chat.stackexchange.com/transcript/52405?m=54768112#54768112), [1](https://chat.stackexchange.com/transcript/message/54776688#54776688)
|  -07 | | | Symbols for computed axes in `⥊` | [0](https://chat.stackexchange.com/transcript/52405?m=55093689#55093689)
|      | | | Affine characters and null literal `@` | [0](https://chat.stackexchange.com/transcript/52405?m=55438211#55438211)
|      | | | Shift functions | [0](https://chat.stackexchange.com/transcript/message/55528973#55528973)
|      | [CL](https://en.wikipedia.org/wiki/Common_Lisp), BQN | w/ Mårtenson, dzaima | Import/export `⇐` | [0](https://chat.stackexchange.com/transcript/message/55661706#55661706), [1](https://chat.stackexchange.com/transcript/message/55767519#55767519)

## Features

Discussion of specific features from the timeline above, with more detail.

#### Structural Under

I developed structural Under in 2017 and 2018. By [Dyalog '17](https://aplwiki.com/wiki/Dyalog_user_meeting#Dyalog_.2717) I had figured out the basic concept, and sometime later I discovered it could be unified with J's Under operator, which was being considered for inclusion in Dyalog.

#### Prefix, Suffix, and Windows

I discovered Prefix, Suffix, and Windows while thinking about Iridescence, probably in 2019. They are influenced by J's Prefix, Suffix, and Infix operators, but in Iridescence, with no distinction between functions and arrays, Prefix is just the Take function, and Suffix is Drop!

#### Array notation

APL [array notation](https://aplwiki.com/wiki/Array_notation) has been developed mainly by Phil Last and later Adám Brudzewsky. The big difference from array literals in other languages is the idea that newline should be a separator equivalent to `⋄`, as it is in ordinary APL execution including dfns. The changes I made for BQN, other than the ligature `‿` discussed below, were to use dedicated bracket pairs `⟨⟩` and `[]`, and to allow `,` as a separator.

I picked out the ligature character `‿` between YAG meetings, but I think Richard Park was most responsible for the idea of a "shortcut" list notation.

#### Double-struck special names

There was a lot of discussion about names for arguments at YAG (no one liked alpha and omega); I think Nathan Rogers suggested using Unicode's mathematical variants of latin letters and I picked out the double-struck ones. My impression is that we were approaching a general concensus that "w" and "x" were the best of several bad choices of argument letters, but that I was the first to commit to them.

#### Assert primitive

Nathan Rogers suggested that assertion should be made a primitive to elevate it to a basic part of the language. I used J's `assert` often enough for this idea to make sense immediately, but I think it was new to me. He suggested the dagger character; I changed this to the somewhat similar-looking `!`. The error-trapping modifier `⎊` is identical to J's `::`, but J only has the function `[:` to unconditionally throw an error, with no way to set a message.

#### Context-free grammar

In YAG meetings, I suggested adopting [APL\iv](https://aplwiki.com/wiki/APL%5Civ)'s convention that variable case must match variable type in order to achieve a context-free grammar. Adám, a proponent of case-insensitive names, pointed out that the case might indicate the type the programmer wanted to use instead of the value's type, creating cross roles. Although I considered swapping subjects and functions, I ended up using exactly the conventions of his APL [style guide](https://abrudz.github.io/style/#nc).

#### Headers

The idea of dfn headers is very common in the APL community, to the extent that it's hard to say which proposals lead to the form now used in BQN. A+ has headers which are similar but go outside the braces, and BQN headers aren't all that different from tradfn headers either. I found when creating BQN2NGN that ngn/apl allows dfns to include a monadic and dyadic case, separated by a semicolon. Some time later I realized that the ability to include multiple bodies is very powerful with headers because it enables a primitive sort of pattern matching, something I already wanted to squeeze into the language. I discussed this with dzaima, who added header support to dzaima/BQN almost immediately and was thus able to investigate the details of the format.

#### Group

I've been fiddling with the idea of function or map inversion (preimage creation, really) for several years, and in fact independently discovered something very similar to K's Group function `=`, which is an excellent tool for languages that have dictionaries. I liked this approach as it didn't have all the ordering issues that J's Key has. However, I also didn't really want to introduce dictionaries to BQN, as they have a very strange relation to multidimensional arrays—are arrays like dictionaries with multiple keys, or dictionaries with a single vector key? I've been a proponent of `/⁼` as a programming tool for [much longer](http://www.jsoftware.com/pipermail/programming/2010-September/020302.html). I'd also developed a sophisticated view of [partition representations](https://aplwiki.com/wiki/Partition_representations) while studying an extension to Dyalog's Partitioned Enclose proposed by Adám and included in Dyalog 18.0. I finally put all this together while fighting with Key to develop BQN's compiler: I realized that if the "key" argument was restricted to array indices, then it would make sense for the result to be an array, and that this was simply the "target indices" partition representation minus the requirement that those indices be nondecreasing.

#### Before `⊸` and After `⟜`

It happens that BQN's Before (`⊸`) and After (`⟜`) modifiers are identical to I's hook (`h`) and backhook (`H`), but it took some time to arrive at this point. The hook function in I comes from J's 2-train, also called hook (I had probably seen Roger Hui's [remarks](https://code.jsoftware.com/wiki/Essays/Hook_Conjunction%3F) that he would prefer hook to be a conjunction, with 2-trains indicating composition instead, but I don't think Roger has proposed a reverse hook). But the model for Before and After was initially APL's Compose (`∘`) and the complement [Reverse Compose](https://aplwiki.com/wiki/Reverse_Compose) that Adám created for Extended Dyalog APL. I noticed the similarity to Bind and decided to unify Binds and Composes at around the same time that I picked the symbols `⊸⟜`. However, I kept the idea that the one-argument case should be simple composition unless the bound operand had a subject role. Eventually I decided the violation of [syntactic type erasure](problems.md#syntactic-type-erasure) was too inconsistent and settled on the current definition. Now I think these forms are better even ignoring constant functions, although I do occasionally run into cases where I'd like to use APL's Compose.

#### Constant modifier

The idea of a constant function is nothing new; I named it `k` in I, taking influence from the [SKI](https://en.wikipedia.org/wiki/SKI_combinator_calculus) calculus. It was actually Adám who suggested adding it to Dyalog with the glyph `⍨`, although I was the one who campaigned for it and introduced it to the public in version 18.0. It wasn't initially clear that a dedicated modifier was needed in BQN because the treatment of data types as constant functions seems to fill this role, but I eventually found that I needed a constant function returning a function too often to leave it out.
