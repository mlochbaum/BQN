*View this file with a real REPL [here](https://mlochbaum.github.io/BQN/index.html).*

# BQN: finally, an APL for your flying saucer

<center>

[documentation](doc/README.md) • [specification](spec/README.md) • [tutorials](tutorial/README.md) • [implementation](implementation/README.md) • [community](community/README.md)

</center>

*Try it online below (arrow at the right for more samples and shift-enter to run), on [this page](https://mlochbaum.github.io/BQN/try.html), or [in our chat](#where-can-i-find-bqn-users). Use [CBQN](https://github.com/dzaima/CBQN) offline; details [here](running.md).*
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
repl ∾< ∾(""Enc˜"script"Attr"src"⋈∾⟜".js")¨"bqn"‿"repl"
-->

Want to learn and use a modern, powerful language centered on Ken Iverson's array programming paradigm? BQN **now provides**:

- A simple, consistent, and [stable](commentary/stability.md) array programming language
- A low-dependency C implementation using bytecode compilation: [installation](running.md)
- Basic [system functions](spec/system.md) for common math, file, and IO operations
- Documentation with examples, visuals, explanations, and rationale for features

BQN **will provide**:

- State of the art array performance: takes some time, but I developed many of Dyalog APL's current algorithms and know we'll get there
- Interfaces to connect with other languages, like a C FFI and JSON and CSV tools
- A standard system to install and use libraries and packages, and support for package managers
- Replace or extend primitives to make a BQN-like language suited for specialized domains

At present, I think BQN is a good choice for learning array programming, scripting, small- to medium-scale number crunching, and recreational programming.

## What kind of name is "BQN"?

It's three letters, that happen to match the capitals in "Big Questions Notation". You can pronounce it "bacon", but are advised to avoid this unless there's puns.

## What's the language like?

BQN aims to remove irregular and burdensome aspects of the APL tradition, and put the great ideas on a firmer footing. It maintains many of the ideas that made APL\360 revolutionary in 1966:
* Human-friendly [**infix notation**](tutorial/expression.md) has no precedence rules to remember.
* [**Built-in array operations**](doc/primitive.md) handle any number of dimensions easily.
* [**Higher-order functions**](doc/primitive.md#modifiers) allow basic functions to be applied in more powerful ways.

It incorporates concepts developed over years of APL practice:
* With the [**leading axis model**](doc/leading.md), simpler primitives span the same functionality.
* [Trains](doc/train.md) and combinators enable **tacit programming**.
* Lightweight [**anonymous functions**](doc/block.md) (like [dfns](https://aplwiki.com/wiki/Dfn)) borrow some power from Lisp.

But it's redesigned from the ground up, with many features new to the array paradigm:
* The [**based array model**](doc/based.md) eliminates the surprise of floating arrays and the hassle of explicit boxes, while dedicated [**list notation**](doc/arrayrepr.md#list-literals) does away with the [gotchas](doc/arrayrepr.md#why-not-whitespace) of [stranding](https://aplwiki.com/wiki/Strand_notation).
* [**Context-free grammar**](doc/context.md) makes it easier for machines and humans to understand code, and naturally leads to [**first-class functions**](doc/functional.md), which can even be used to [reinvent control structures](doc/control.md).
* [**New symbols**](keymap.md) for built-in functionality make the syntactic role of every primitive instantly visible, and aim to be more consistent and intuitive.
* No-nonsense [**namespace syntax**](doc/namespace.md) encapsulates data and even allows for a little [object-oriented programming](doc/oop.md).

To see what a BQN program might look like, you can [gaze into the abyss](src/c.bqn) that is the self-hosted compiler, or try the friendlier [markdown processor](md.bqn) used to build this website. Or the collection of scripts at [bqn-libs](https://github.com/mlochbaum/bqn-libs).

Not sold? See [why BQN?](commentary/why.md) for an outline of what all these features add up to in terms of programming power.

## How do I work with the character set?

Right at the beginning, you can use the bar above the online REPL to enter BQN code: hover over a character to see a short description, and click to insert it into the editor. But you'll soon want to skip the clicking and use keyboard input. I type the special characters using a backslash escape, so that, for example, typing `\` then `z` writes `⥊` (the backslash character itself is not used by BQN). The online REPL supports this method out of the box, and the [editor plugins](editors/README.md) include or link to ways to enable it for editors, browsers, shells, and so on.

The [font comparison page](https://mlochbaum.github.io/BQN/fonts.html) shows several fonts that support BQN (including the one used on this site, BQN386). Most other monospace fonts are missing some BQN characters, such as double-struck letters `𝕨`, `𝕩` and so on, which will cause these characters to be rendered with a fallback font and possibly have the wrong width or look inconsistent. The double-struck characters also require two bytes in UTF-16, which breaks rendering in many Windows terminals. If you have this problem, VS Code and [wsl-terminal](https://github.com/mskyaxl/wsl-terminal) with an appropriate font definitely support them.

## Where can I find BQN users?

Chat forum links below; either of the bold ones will open in a browser without much hassle if you just want to get on quickly. Further forum details [here](community/forums.md).

|           | Discord                                     | Matrix            | …in Element |
|-----------|---------------------------------------------|-------------------|-------------|
| All rooms | [**Invite**](https://discord.gg/SDTW36EhWF) | #array:matrix.org | [Space](https://app.element.io/#/room/%23array:matrix.org)
| BQN room  |                                             | #bqn:matrix.org   | [**Room**](https://app.element.io/#/room/%23bqn:matrix.org)

[Discord](https://en.wikipedia.org/wiki/Discord_(software)) is a popular commercial chat client and Element is a similar UI for the open chat protocol [Matrix](https://matrix.org/). They're bridged together so that messages in one appear in the other. Most discussion happens on these (they're quite active), but see also the [community](community/README.md) page for activities and such in other places.

Also feel free to contact me personally via Github issues or with the email address shown in my Github profile.

## How do I get started?

*The documentation still has some pages missing (not many now), while the tutorials are probably less than half complete. I don't think this is much of an impediment any more. Ask about anything you find confusing on the forums.*

BQN's [**tutorials**](tutorial/README.md) are intended as an introduction to array programming with BQN. They assume only knowledge of elementary mathematics, but will probably be hard to follow if you have *no* programming experience. BQN has a lot in common with dynamically-typed functional languages like Lisp, Julia, or Javascript, so knowledge of these languages will be particularly helpful. The tutorials end abruptly right now, so you'll have to switch to the documentation, which is less structured.

If you're already an array programmer, you might start with the [**documentation**](doc/README.md) right away, using the [BQN-Dyalog APL](doc/fromDyalog.md) or [BQN-J](doc/fromJ.md) dictionary as a quick reference where appropriate. Be aware of two key differences between BQN and existing array languages beyond just the changes of [primitives](doc/primitive.md)—if these differences don't seem important to you then you don't understand them! BQN's [based array model](doc/based.md) is different from both a flat array model like J and a nested one like APL2, Dyalog, or GNU APL in that it has true non-array values (plain numbers and characters) that are different from depth-0 scalars. BQN also uses [syntactic roles](doc/context.md) rather than dynamic type to determine how values interact, that is, what's an argument or operand and so on. This system, along with lexical closures, means BQN fully supports Lisp-style [functional programming](doc/functional.md).

A useful tool for both beginners and experienced users is [**BQNcrate**](https://mlochbaum.github.io/bqncrate/), a searchable collection of BQN snippets to solve particular tasks. If you have a question about how you might approach a problem, give it a try by typing in a relevant keyword or two.
