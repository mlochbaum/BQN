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
repl∾↩<∾(""Enc˜"script"Attr"src"≍○<∾⟜".js")¨"bqn"‿"repl"
∾∾⟜(10+@)¨ repl
-->

**BQN** is a new programming language in the APL lineage, which aims to remove irregular and burdensome aspects of the APL tradition and put the great ideas on a firmer footing. While its use demands a solid understanding of functions and multidimensional arrays, BQN's focus on providing simple, consistent, and powerful array operations (and documentation!) makes it a good language for learning array programming and building stronger array intuition.

BQN maintains many of the ideas that made APL\360 revolutionary in 1966:
* Human-friendly **infix notation** has no precedence rules to remember.
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

I type the special characters using a backslash escape, so that, for example, typing `\` then `z` writes `⥊` (the backslash character itself is not used by BQN). The online REPL supports this method out of the box, and this repository also has [scripts](https://github.com/mlochbaum/BQN/tree/master/editors) to support it, along with the standard syntax highlighting and indentation, in Vim and [Kakoune](https://kakoune.org/). When starting out, it may be easier to use the bar above the REPL: hover over a character to see a short description, and click to insert it into the editor. Finally, on Linux [this configuration file](https://github.com/mlochbaum/BQN/blob/master/editors/bqn) for [XKB](https://en.wikipedia.org/wiki/X_keyboard_extension) can be used to allow typing glyphs with a modifier key system-wide.

Few existing monospace fonts support all the BQN characters (double-struck letters like `𝕩` are a particular sticking point), which can cause these characters to be rendered with a fallback font and have the wrong width or look inconsistent. Two fonts modified to support BQN are available currently. This site uses a [modified DejaVu Sans Mono](https://github.com/mlochbaum/BQN/blob/master/docs/DejaVuBQNSansMono.ttf), and another, more playful option is [BQN386](https://github.com/dzaima/BQN386) ([demo](https://dzaima.github.io/BQN386/)). Existing font [Fairfax HD](http://www.kreativekorp.com/software/fonts/fairfaxhd.shtml) has excellent BQN support, but be careful not to confuse single quote (`'`) with the smaller acute accent (`´`). [Julia Mono](https://github.com/cormullion/juliamono) also supports all BQN characters, but with varying styles and weights.

## How do I get started?

*Writing good learning material for a programming language is a pretty huge task, so neither the tutorials not the documentation are complete. With some willingness to experiment and possibly outside knowledge of array programming, it's enough to get by, just not smooth sailing.*

BQN's [**tutorials**](tutorial/README.md) are intended as an introduction to array programming with BQN. They assume only knowledge of elementary mathematics, but will probably be hard to follow if you have *no* programming experience. BQN has a lot in common with dynamically-typed functional languages like Lisp, Julia, or Javascript, so knowledge of these languages will be particularly helpful. However, there's a significant (but shrinking) gap between the last tutorial and existing documentation. If you're motivated, you may be able to get across by reading material on other array languages like APL, J, NumPy, or Julia.

If you're already an array programmer, then you're in better shape: the current [**documentation**](doc/README.md) covers nearly all differences from APL, and the BQN-Dyalog APL [dictionary](doc/fromDyalog.md) might also be a useful resource. However, you should be aware of two key differences between BQN and existing array languages beyond just the changes of [primitives](doc/primitive.md)—if these differences don't seem important to you then you don't understand them! BQN's [based array model](doc/based.md) is different from both a flat array model like J and a nested one like APL2, Dyalog, or GNU APL in that it has true non-array values (plain numbers and characters) that are different from depth-0 scalars. BQN also uses [syntactic roles](doc/context.md) rather than dynamic type to determine how values interact, that is, what's an argument or operand and so on. This system, along with lexical closures, means BQN fully supports Lisp-style [functional programming](doc/functional.md).
