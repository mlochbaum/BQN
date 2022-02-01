*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/rebqn.html).*

# ReBQN

The function `•BQN` evaluates a source code string passed to it as BQN in an isolated environment and returns the result. There are a few things you might want to change about this. `•ReBQN` is a function that *generates* `•BQN`-like functions, using a [namespace](namespace.md) `𝕩` for configuration. It can create a "REPL" function that saves state between evaluations, or redefine primitives, and might support extra functionality like keywords in the future.

Here are some quick examples of `•ReBQN` functionality. First, let's make a REPL function by setting `repl` to `"strict"` (no re-definitions allowed) instead of the default `"none"`. We can now define a variable in one `Repl` call and refer to it later.

        repl ← •ReBQN {repl⇐"strict"}  # Lowercase for function result

        Repl "a ← ↕10"                 # Uppercase to call

        Repl "⌽ a"

This option also powers the results shown on the BQN website: to process a document, a REPL function is created, and used to evaluate every line! Next, we can define a little ASCII calculator using a list of primitives. To mix it up a bit I've made monadic `/` here a Range function.

        calcFns ← ⟨'+'‿+, '-'‿-, '*'‿×, '/'‿(↕⊘÷)⟩

        calc ← •ReBQN {primitives⇐calcFns}

        Calc "7 / 9 - 2*2"  # BQN order of operations

        Calc "/ 9"

Options can be used in any combination. Here's a calculator REPL:

        calcRepl ← •ReBQN {repl⇐"strict", primitives⇐calcFns}

        CalcRepl "b ← 1 - a←6"

        CalcRepl "a * b"

## REPL mode

The `repl` property can have the values `"none"`, `"strict"`, and `"loose"`. If no value is given it's equivalent to `"none"`, which means that the resulting function has no memory and each evaluation is independent from the others. But the values `"strict"` and `"loose"` make evaluations take place in a shared [scope](lexical.md). Now a variable defined at the top level of one source string is visible when later ones are evaluated, and can be viewed and modified.

        do ← •ReBQN {repl⇐"loose"}

        Do¨ "a←4"‿"⟨a,b←5⟩"‿"{⟨a↩𝕩,b⟩}8"

A different `•ReBQN` result has its own scope and can't access these variables.

        doNot ← •ReBQN {repl⇐"loose"}

        DoNot "b" # surprised when this fails

The difference in `"strict"` and `"loose"` is that a loose REPL can define a variable again, which just changes its value (under the covers, the `←` is treated as a `↩`).

        Do "a ← ¯1"
        Do "a ← b‿a"

        (•ReBQN {repl⇐"strict"})⎊@¨ "a←1"‿"a←2"  # Second one errors

## Primitives

The `primitives` property specifies the full set of primitives available to the new interpreter. Without it, the existing set of primitives is kept. With it, they're all thrown out, and the ones provided are used instead. Since you often would rather extend or modify what's there, the system value `•primitives` returns the current primitives set in the form used by `•ReBQN`.

        3 ↑ •primitives

        ext ← •ReBQN {primitives⇐•primitives∾⟨'∑',+´⟩‿⟨'∏',×´⟩}

        Ext "∏1+↕7"
        Ext "∑(1↓↕)⊸(⊣/˜0=|)28"  # Sum of divisors

Appending to `•primitives` means everything from BQN's there in addition to the given functions.

What's allowed? The format for `primitives` is a list of pairs, where each pair contains one character—the glyph—and one function or modifier. A primitive can't be data, at least at present, because the compiler is only designed to handle the primitive types found in base BQN and extending this doesn't seem terribly important. The type of the primitive's value is very important, because it determines the [role](expression.md#syntactic-role) it has. Said another way, it's setting the rules of syntax!

        (•ReBQN {primitives⇐⟨'^'‿{𝕨𝔽𝕩𝔽𝕨},'%'‿∾⟩}){𝔽} "0 %^ 1‿2"

Above, `^` becomes a 1-modifier, so that it modifies `%` rather than being called directly on `1‿2` as a function.

The glyph can be any character that's not being used by BQN already. Characters like `c` or `⟩` or `:` will result in an error, as they'd break BQN syntax. Other than that, the sky's the limit! Or rather, the Unicode consortium is the limit. If they don't recognize your symbol, you're going to have to petition to make it an emoji or something. Oh well.

## Run as an executable

Of course, calling a function on a string isn't a great interface for programming. But BQN has the facilities to turn such a function into a proper script, which can then be run much like the BQN executable. The following example takes a filename followed by the `•args` to be passed in, or runs as a REPL if given no arguments.

    #! /usr/bin/env bqn
    calcFns ← ⟨'+'‿+, '-'‿-, '*'‿×, '/'‿(↕⊘÷)⟩
    calc ← •ReBQN {primitives⇐calcFns, repl⇐"loose"}
    {
      # Run on a file
      0 < ≠•args ?
        f ← •wdpath •file.At ⊑•args
        path‿name ← (∧`⌾⌽'/'⊸≠)⊸⊔f
        ⟨path,name,1↓•args⟩ Calc •file.Chars f

      # Run as REPL
      ; _while_ ← {𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}
        •GetLine∘•Show∘Calc _while_ (@⊸≢) •GetLine@
    }
