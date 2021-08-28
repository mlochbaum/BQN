*View this file with a real REPL [here](https://mlochbaum.github.io/BQN/index.html).*

# BQN: finally, an APL for your flying saucer

<center>

[documentation](doc/README.md) • [specification](spec/README.md) • [tutorials](tutorial/README.md) • [implementation](implementation/README.md)

</center>

*Try it online below (shift-enter to run), on [this page](https://mlochbaum.github.io/BQN/try.html), or [in our chat](#where-can-i-find-bqn-users). Use [CBQN](https://github.com/dzaima/CBQN) offline; details [here](running.md).*
<!--GEN
E ← ⊐⟜":"⊸(↑At"class="∾1⊸+⊸↓)⊸Enc
repl ← "div:cont" E ⟨
  "div:kb" E ""
  "div:rel" E ⟨
    "textarea:code|rows=1|spellcheck=false" E "<⟜'a'⊸/ ""Big Questions Notation"""
    "svg:demo|viewBox=0 -6 4 12" E "path" Elt "d"‿"M1 -6H0L1 0L0 6H1L4 0z"
  ⟩
  "pre:rslt" E """B Q N"""
⟩
repl ∾< ∾(""Enc˜"script"Attr"src"≍○<∾⟜".js")¨"bqn"‿"repl"
-->

**BQN** is a new programming language in the APL lineage, which aims to remove irregular and burdensome aspects of the APL tradition and put the great ideas on a firmer footing. While its use demands a solid understanding of functions and multidimensional arrays, BQN's focus on providing simple, consistent, and powerful array operations (and documentation!) makes it a good language for learning array programming and building stronger array intuition.

BQN maintains many of the ideas that made APL\360 revolutionary in 1966:
* Human-friendly [**infix notation**](tutorial/expression.md) has no precedence rules to remember.
* [**Built-in array operations**](doc/primitive.md) handle any number of dimensions easily.
* [**Higher-order functions**](doc/primitive.md#modifiers) allow basic functions to be applied in more powerful ways.

It incorporates concepts developed over years of APL practice:
* With the [**leading axis model**](doc/leading.md), simpler primitives span the same functionality.
* [Trains](doc/train.md) and combinators enable **tacit programming**.
* Lightweight [**anonymous functions**](doc/block.md) (like [dfns](https://aplwiki.com/wiki/Dfn)) borrow some power from Lisp.

But BQN is redesigned from the ground up, with brand new ideas to make these paradigms easier to use and less likely to fail.
* The [**based array model**](doc/based.md) eliminates the surprise of floating arrays and the hassle of explicit boxes, while dedicated [**list notation**](doc/arrayrepr.md#list-literals) does away with the [gotchas](doc/arrayrepr.md#why-not-whitespace) of [stranding](https://aplwiki.com/wiki/Strand_notation).
* [**Context-free grammar**](doc/context.md) makes it easier for machines and humans to understand code, and naturally leads to [**first-class functions**](doc/functional.md), which can even be used to [reinvent control structures](doc/control.md).
* [**New symbols**](keymap.md) for built-in functionality make the syntactic role of every primitive instantly visible, and aim to be more consistent and intuitive.
* No-nonsense [**namespace syntax**](doc/namespace.md) encapsulates data and even allows for a little [object-oriented programming](doc/oop.md).

## What kind of name is "BQN"?

It's three letters, that happen to match the capitals in "Big Questions Notation". You can pronounce it "bacon", but are advised to avoid this unless there's puns.

## What does BQN look like?

Rather strange, most likely:

        ⊑+`∘⌽⍟12↕2  # The 12th Fibonacci number

More snippets are programmed into the live demo at the top of the page: hit the arrow at the right of the code window to see them. For longer samples, you can [gaze into the abyss](src/c.bqn) that is the self-hosted compiler, or the [shallower but wider abyss](src/r1.bqn) of the runtime, or take a look at the friendlier [markdown processor](md.bqn) used to format and highlight documentation files. This repository also has [some translations](examples/fifty.bqn) from ["A History of APL in 50 Functions"](https://www.jsoftware.com/papers/50/).

## How do I work with the character set?

Right at the beginning, you can use the bar above the online REPL to enter BQN code: hover over a character to see a short description, and click to insert it into the editor. But you'll soon want to skip the clicking and use keyboard input. I type the special characters using a backslash escape, so that, for example, typing `\` then `z` writes `⥊` (the backslash character itself is not used by BQN). The online REPL supports this method out of the box, and the [editor plugins](editors/README.md) include or link to ways to enable it for editors, browsers, shells, and so on.

The [font comparison page](https://mlochbaum.github.io/BQN/fonts.html) shows several fonts that support BQN (including the one used on this site, BQN386). Most other monospace fonts are missing some BQN characters, such as double-struck letters `𝕨`, `𝕩` and so on, which will cause these characters to be rendered with a fallback font and possibly have the wrong width or look inconsistent. The double-struck characters also require two bytes in UTF-16, which breaks rendering in many Windows terminals. If you have this problem, VS Code and [wsl-terminal](https://github.com/mskyaxl/wsl-terminal) with an appropriate font definitely support them.

## Why would I use it?

There are plenty of clean, modern languages out there, and a good number of array languages. I don't think any other language fits both descriptions quite so well as BQN, and I find the combination lets me write powerful and reliable programs quickly. What you find in the language will depend on your background.

If you haven't yet used an array language, BQN will present you with new ways of thinking that can streamline the way you work with data and algorithms. There's no denying that array programming has begun to creep into the mainstream, and you might be wondering if BQN has anything to offer when you can hack reduces and filters with the best of them. It does: real array programming is different in character, with more and better array operations on immutable multidimensional arrays, and syntax better suited to them. Performance that resembles a low-level compiled language more than a high-level dynamic one. Primitives flow together and compose better—one aspect that sets BQN apart from other array languages is a set of combinators that's more intuitive than previous attempts. I also happen to think BQN's [character arithmetic](tutorial/expression.md#character-arithmetic) system would improve just about any language.

If your favorite language is J, you are missing out even more! Array programmers never seem willing to accept that good ideas can come from people other than Iverson and that legends like John McCarthy and Barbara Liskov advanced human knowledge of how to express computation. They did, and being able to casually pass around first-class functions and mutable closures, with namespaces keeping everything organized, is a huge quality of life improvement. Writing APL again is claustrophobic, the syntax worries and constraints in functionality suddenly rushing back. BQN's mutable objects make methods such as graph algorithms that just don't have a good array implementation (no, your O(n³) matrix method doesn't scale) possible, even natural. With bytecode compilation and NaN-boxing, a natural fit for the based array model, it evaluates that scalar code many times faster than APL or J. The Unix-oriented scripting system stretches seamlessly from quick sketch to multi-file program.

BQN has no intention of being the last word in programming, but could be a practical and elegant tool in your kit—even if only used to inform your use of another language. Give it a try!

## How do I get started?

*The documentation still has some pages missing (not many now), while the tutorials are probably less than half complete. I don't think this is much of an impediment any more. Ask about anything you find confusing on the forums.*

BQN's [**tutorials**](tutorial/README.md) are intended as an introduction to array programming with BQN. They assume only knowledge of elementary mathematics, but will probably be hard to follow if you have *no* programming experience. BQN has a lot in common with dynamically-typed functional languages like Lisp, Julia, or Javascript, so knowledge of these languages will be particularly helpful. The tutorials end abruptly right now, so you'll have to switch to the documentation, which is less structured.

If you're already an array programmer, you might start with the [**documentation**](doc/README.md) right away, using the [BQN-Dyalog APL](doc/fromDyalog.md) or [BQN-J](doc/fromJ.md) dictionary as a quick reference where appropriate. Be aware of two key differences between BQN and existing array languages beyond just the changes of [primitives](doc/primitive.md)—if these differences don't seem important to you then you don't understand them! BQN's [based array model](doc/based.md) is different from both a flat array model like J and a nested one like APL2, Dyalog, or GNU APL in that it has true non-array values (plain numbers and characters) that are different from depth-0 scalars. BQN also uses [syntactic roles](doc/context.md) rather than dynamic type to determine how values interact, that is, what's an argument or operand and so on. This system, along with lexical closures, means BQN fully supports Lisp-style [functional programming](doc/functional.md).

A useful tool for both beginners and experienced users is [**BQNcrate**](https://mlochbaum.github.io/bqncrate/), a searchable collection of BQN snippets to solve particular tasks. If you have a question about how you might approach a problem, give it a try by typing in a relevant keyword or two.

## Where can I find BQN users?

There's a BQN [Matrix](https://matrix.org/) channel at #bqn:matrix.org, which you can see in the Element web client with [this link](https://app.element.io/#/room/%23bqn:matrix.org), and one on Discord that you can join with [this invite](https://discord.gg/SDTW36EhWF). The two channels are bridged so that comments in one appear in both. The Discord server has other array programming channels as well, with the corresponding Matrix channels gathered in [this space](https://app.element.io/#/room/%23array:matrix.org) (link uses Element's spaces beta). BQN and the other channels are very active: you wouldn't believe how many people are here to discuss arrays all day!

BQNBot will run your code from chat! Begin your message with `bqn)` and our friend (designation B-QN) will evaluate the rest and show the output. While putting your code in blocks `` `like this` `` is easier to read, the bot just operates on plain text and doesn't require it.

In addition to these forums, you can contact me personally via Github issues or with the email address shown in my Github profile.

## Can I help out?

Certainly! There are never enough hours in the day and contributors from beginner to advanced programmers are all welcome. If you're interested I recommend you ask on the forums first to get a feel for what exactly is needed.

You will certainly feel an urge to skip this paragraph and get to the fun stuff, but the most important resource for implementing a language is **testing** and the most valuable one for building a language community is accessible introductions to the language and **learning materials**. These are both very demanding, but if you're willing to put in the work to advance BQN in the most effective way then this is it. One form of documentation that many users would appreciate is short descriptions—a sentence or two with examples—of the primitives for each glyph that can be displayed as help in the REPL. To be honest I'm lousy at making these and would prefer for someone else to do it.

Work on BQN's **implementation** generally requires a high level of programming skill. We are focusing development effort on [CBQN](https://github.com/dzaima/CBQN) (see this [source overview](https://github.com/dzaima/CBQN/blob/master/src/README.md)). It's true that the entire compiler and a (decreasing) portion of the runtime is written in BQN, but it would be hard to do much with these as they are very nearly complete, and work satisfactorily. On the other hand, there is a lot that needs to be written in C, including [system values](spec/system.md) and higher-performance [primitives](implementation/primitive/README.md). And there's no need to work on *our* implementation! BQN's [specification](spec/README.md) and [tests](test/README.txt) are there to make sure you can write a conforming implementation, and extend it with your own ideas. It's also possible to take advantage of the self-hosted BQN sources by writing a [virtual machine](implementation/vm.md) that allows you to embed BQN in the language of your choice.

Building **libraries** for BQN users can make writing programs in the language much more approachable. You are a better judge of which libraries are needed than I. Port some code from another language, implement some useful functionality in a field you specialize in, or try something new that interests you. A library should be structured as a file (which might load other files) that loads a namespace. This isn't too well-documented now, but see the [namespace documentation](doc/namespace.md) for hints.

Those are possibilities, not limitations. The best way to contribute might be fixing something I never knew was wrong.
