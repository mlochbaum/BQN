*View this file with a real REPL [here](https://mlochbaum.github.io/BQN/index.html).*

# BQN: finally, an APL for your flying saucer

<center>

[documentation](doc/README.md) • [specification](spec/README.md) • [tutorials](tutorial/README.md) • [implementation](implementation/README.md)

</center>

*Try it online below or [here](https://mlochbaum.github.io/BQN/try.html), and see [running.md](running.md) for more options.*
<!--GEN
E ← ⊐⟜":"⊸(↑At"class="∾1⊸+⊸↓)⊸Enc
repl ← "div:cont" E ⟨
  "div:kb" E ""
  "div:rel" E ⟨
    "textarea:code|rows=1|autofocus" E "<⟜'a'⊸/ ""Big Questions Notation"""
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
* **Higher-order functions** allow basic functions to be applied in more powerful ways.

It incorporates concepts developed over years of APL practice:
* With the [**leading axis model**](doc/leading.md), simpler primitives span the same functionality.
* [Trains](doc/train.md) and combinators enable **tacit programming**.
* Lightweight [**anonymous functions**](doc/block.md) (like [dfns](https://aplwiki.com/wiki/Dfn)) borrow some power from Lisp.

But BQN is redesigned from the ground up, with brand new ideas to make these paradigms easier to use and less likely to fail.
* The [**based array model**](doc/based.md) makes non-arrays (called atoms) a fundamental part of the language, and removes the surprise of floating arrays and the hassle of explicit boxes. New **array notation** eliminates the gotchas of [stranding](https://aplwiki.com/wiki/Strand_notation).
* A [**context-free grammar**](doc/context.md) where a value's syntactic role is determined by its spelling makes it easier for machines and humans to understand code.
* Oh, and it naturally leads to [**first-class functions**](doc/functional.md), which for example can be used to [reinvent control structures](doc/control.md).
* **New symbols** for built-in functionality make the syntactic role of every primitive instantly visible, and aim to be more consistent and intuitive.

## What kind of name is "BQN"?

It's three letters, that happen to match the capitals in "Big Questions Notation". You can pronounce it "bacon", but are advised to avoid this unless there's puns.

## What does BQN look like?

Rather strange, most likely:

        ⊑+`∘⌽⍟12↕2  # The 12th Fibonacci number

More snippets are programmed into the live demo at the top of the page: hit the arrow at the right of the code window to see them. For longer samples, you can [gaze into the abyss](src/c.bqn) that is the self-hosted compiler, or the [shallower but wider abyss](src/r.bqn) of the runtime, or take a look at the friendlier [markdown processor](md.bqn) used to format and highlight documentation files. This repository also has [some translations](examples/fifty.bqn) from ["A History of APL in 50 Functions"](https://www.jsoftware.com/papers/50/).

## How do I work with the character set?

Right at the beginning, you can use the bar above the online REPL to enter BQN code: hover over a character to see a short description, and click to insert it into the editor. But you'll soon want to skip the clicking and use keyboard input. I type the special characters using a backslash escape, so that, for example, typing `\` then `z` writes `⥊` (the backslash character itself is not used by BQN). The online REPL supports this method out of the box, and configuration files to enable it in various other places are included with the [editor plugins](https://github.com/mlochbaum/BQN/tree/master/editors). There's also a [bookmarklet](https://abrudz.github.io/lb/bqn) you can use to enable BQN input in any webpage in your browser.

The [font comparison page](https://mlochbaum.github.io/BQN/fonts.html) shows several fonts that support BQN (including the one used on this site, a modified version of DejaVu Sans Mono). Most other monospace fonts are missing some BQN characters, such as double-struck letters `𝕨`, `𝕩` and so on, which will cause these characters to be rendered with a fallback font and possibly have the wrong width or look inconsistent.

## How do I get started?

*Writing good learning material for a programming language is a pretty huge task, so neither the tutorials nor the documentation are complete. With some willingness to experiment and possibly outside knowledge of array programming, it's enough to get by, just not smooth sailing.*

BQN's [**tutorials**](tutorial/README.md) are intended as an introduction to array programming with BQN. They assume only knowledge of elementary mathematics, but will probably be hard to follow if you have *no* programming experience. BQN has a lot in common with dynamically-typed functional languages like Lisp, Julia, or Javascript, so knowledge of these languages will be particularly helpful. However, there's a significant (but shrinking) gap between the last tutorial and existing documentation. If you're motivated, you may be able to get across by reading material on other array languages like APL, J, NumPy, or Julia.

If you're already an array programmer, then you're in better shape: the current [**documentation**](doc/README.md) covers nearly all differences from APL, and the [BQN-Dyalog APL](doc/fromDyalog.md) or [BQN-J](doc/fromJ.md) dictionary might also be a useful resource. However, you should be aware of two key differences between BQN and existing array languages beyond just the changes of [primitives](doc/primitive.md)—if these differences don't seem important to you then you don't understand them! BQN's [based array model](doc/based.md) is different from both a flat array model like J and a nested one like APL2, Dyalog, or GNU APL in that it has true non-array values (plain numbers and characters) that are different from depth-0 scalars. BQN also uses [syntactic roles](doc/context.md) rather than dynamic type to determine how values interact, that is, what's an argument or operand and so on. This system, along with lexical closures, means BQN fully supports Lisp-style [functional programming](doc/functional.md).

A useful tool for both beginners and experienced users is [**BQNcrate**](https://mlochbaum.github.io/bqncrate/), a searchable collection of BQN snippets to solve particular tasks. If you have a question about how you might approach a problem, give it a try by typing in a relevant keyword or two.

## Where can I find BQN users?

Most BQN users are active on the [APL Orchard](https://chat.stackexchange.com/rooms/52405/the-apl-orchard) forum. If you (like me) don't have a Stack Overflow or Stack Exchange account with a few points you'll have to send an email to get forum access; see the instructions in the room description. You can also chat there by IRC: a bot mirrors messages back and forth to the #apl freenode channel. The [Matrix](https://matrix.org/) channel #apl:matrix.org is similarly linked.

The official place to ask BQN programming questions is [topanswers.xyz/apl](https://topanswers.xyz/apl) (I know it's dead, but I'm still checking it). Tag your questions with "bqn", of course.

In addition to these forums, you can contact me personally via Github issues or with the email address shown in my Github profile.
