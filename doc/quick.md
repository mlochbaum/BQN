*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/quick.html).*

# A quick start to BQN

Here's a little BQN program:

    #! /usr/bin/env bqn

    # Case conversion utilities
    case ← {
      diff ← -´ "Aa"
      Lower ⇐ -⟜diff
      Upper ⇐ Lower⁼
    }

    hw ← <˘ 2‿∘ ⥊ "helloworld"
    hw case.Upper⌾(⊑¨)↩
    •Out hw ↩ ∾ ⥊⍉ [hw, ", "‿"!"]  # Hello, World!

    # Split at spaces and repeated characters
    Split ← {
      !1==𝕩 ⋄ (!2=•Type)¨𝕩
      Proc ← {
        · 𝕊 ' ': spl⇐1 ⋄ str⇐"" ;    # Space: break and delete it
        prev Proc cur: spl‿str⇐
          spl←0 ⋄ str←⋈cur           # Include and don't break...
          { prev≡cur ? spl+↩1 ; @ }  # except at equal characters
      }
      r ← (»𝕩) Proc¨ 𝕩
      GV←{𝕩.str} ⋄ GS←{⟨s⇐spl⟩:s}
      (∾¨ GV¨ ⊔˜ ·+`GS¨) r
    }
    •Show shw ← Split hw  # ⟨ "Hel" "lo," "World!" ⟩

    fns ← ⟨⌽, split
           case.Lower⌾⊑⟩
    •Show fns {𝕎𝕩}¨ shw   # ⟨ "leH" ⟨ "lo," ⟩ "world!" ⟩

It's not the most idiomatic BQN you'll see, but that's because this piece of code uses every piece of syntax in the language (and a good number of the primitives).

If you save it with the name hello.bqn and have BQN [installed](../running.md), the script can be run with `$ bqn hello.bqn` from a shell. Because of the `#!` line at the top, `$ ./hello.bqn` also works if `bqn` is in your path and hello.bqn is executable. It can also be run from another BQN file in the same directory, or REPL started there, using `•Import "hello.bqn"`. Or just copy-paste it into the [online REPL](https://mlochbaum.github.io/BQN/try.html).

Now let's see how it works.

## Case conversion

    # Case conversion utilities
    case ← {
      diff ← -´ "Aa"
      Lower ⇐ -⟜diff
      Upper ⇐ Lower⁼
    }

This part of the code defines a [namespace](namespace.md) using braces `{}`, then [assigns](expression.md#assignment) it to the name `case`. There are three assignments inside the namespace too. Since BQN uses [lexical scoping](lexical.md), code outside the namespace can't access the variables `diff`, `Lower`, and `Upper` directly. Oh, and the first line is a [comment](token.md#comments).

The value `diff` is the result of applying a [function](ops.md#functions) `-´` to the argument `"Aa"`. Function application is always written just by placing a function next to its arguments like this—a prefix application if there's one argument, infix if there are two, and that's the most arguments you can have. This doesn't limit BQN's capabilities because it's easy to pass a list as an argument. In fact, `"Aa"` is a [string](token.md#characters-and-strings), which means a list of characters. Characters are written with single quotes, so it's a list of `'A'` and `'a'`.

        -´ "Aa"    # Prefix application

        'A' - 'a'  # Infix application

The function `-´` is a *compound* function, because it consists of another function `-` (it's just [subtraction](arithmetic.md#basic-arithmetic)) passed to a 1-[modifier](ops.md#modifiers) [Fold](fold.md) (`´`). Fold applies its operand function `-` between the elements of its list argument `"Aa"`. For a more familiar example, `+´` could sum a list of numbers. But here we end up taking the difference between two characters, an instance of [character arithmetic](arithmetic.md#character-arithmetic). Characters are always Unicode code points, and this operation takes the difference between their numeric values. The important point is that the difference between any lowercase Latin character and its uppercase version is always the same number (specifically -32, which is written `¯32` because `¯` can be part of a [numeric literal](token.md#numbers) while the function `-` can't). Adding this number to a lowercase letter translates it to uppercase:

        diff ← -´ "Aa"
        'b' + diff

The function `Lower` is defined to be `-⟜diff`, but it uses a different arrow `⇐` to do this. This is an [export](namespace.md#exports), and it declares that `Lower` is a *field* of a namespace that can be accessed from the outside. Having a `⇐` in it is also what makes the block define a namespace. `Lower` isn't accessed in the rest of the program, but `Upper` is, with `case.Upper`.

`Lower` is created with a modifier again, this time the 2-modifier `⟜`. We've now seen one each of the three [*primitive*](primitive.md) types: function, 1-modifier, and 2-modifier. There are a lot of primitives, but some simple rules tell you which type they have. Primitives are functions by default, but superscript characters are 1-modifiers (`` ´˘¨˜` `` in our program), and ones with an unbroken circle are 2-modifiers (`⟜∘⌾`; `⍉` is a broken circle so it's a function). Variable names follow a [similar system](expression.md#role-spellings), where functions start with an uppercase letter and subjects with a lowercase one.

[After](hook.md) (`⟜`) takes two operands, `-` and `diff`, to produce a function—specifically, it binds `diff` as the right argument of `-`, so that calling it on an argument subtracts `diff` from that argument.

        -⟜diff 'G'

        'G' - diff

`Upper` could be written the same way, with `+⟜diff` or `diff⊸+`. Instead, it's defined to be the inverse of `Lower` with [Undo](undo.md) (`⁼`). BQN knows a few algebraic tricks to invert primitives and compound functions, and `-⟜diff` is well within its capabilities.

## Saying hello

The next part of the program begins to use BQN's array-oriented capabilities. It consists of three statements, which BQN evaluates in order (after the previous statement, which defined `case`).

    hw ← <˘ 2‿∘ ⥊ "helloworld"
    hw case.Upper⌾(⊑¨)↩
    •Out hw ↩ ∾ ⥊⍉ [hw, ", "‿"!"]  # Hello, World!

The first one takes the string `"helloworld"` and turns it into a list of two strings.

        <˘ 2‿∘ ⥊ "helloworld"

This is our first expression that evaluates two functions, and has a lot of other stuff going on besides. Let's draw out the expression grouping. The online REPL can also do this for you if you click "Explain" before running your expression.

<!--GEN ../tutorial/evalexp.bqn
DrawEval "<˘ 2‿∘ ⥊ ""helloworld"""
-->

The two functions evaluated are `<˘` and `⥊`. Functions all have the same precedence, and are evaluated from right to left—the same order as `f(g(h(x)))` in math but without the parentheses. Applying a modifier like `˘` has higher precedence than function application, and so does [stranding](arrayrepr.md#strands) `‿`. Stranding is a quick way to write a list; `2‿∘` could also be written `⟨2,∘⟩` using the [brackets](arrayrepr.md#brackets) found later in the program. Elements can be anything: here `2` is a list and `∘` is a 2-modifier.

        2‿∘

The first function applied is [Reshape](reshape.md), which reshapes its right argument according to the shape on the left. So a shape of `2‿5` would turn our 10-character list into a 2×5 array. But `2‿∘` isn't really a shape: the `∘` indicates a [computed length](reshape.md) to be filled in based on the size of the array being reshaped.

        2‿5 ⥊ "helloworld"
        2‿∘ ⥊ "helloworld"

This result is a 2-dimensional [array](array.md) of characters. A list is also a kind of array, but with only one dimension. We say a list has *rank* 1, while the new array has rank 2. But the next thing we do is turn our array into a list of lists:

        <˘ 2‿∘ ⥊ "helloworld"

The function that does this is [Enclose](enclose.md) [Cells](rank.md), `<˘`. The Cells modifier means we're working with *major cells*, which are the parts of an array with one less dimension. For a rank-2 array, these are its rows, while for a list, they're rank-0 arrays (or [units](enclose.md#whats-a-unit)), each containing a single element. Enclose Cells applies Enclose to each major cell of its argument to produce the major cells of its result. Enclosing a cell wraps it up in a rank-0 array, and using these for the result's major cells creates a list, whose elements are the rows of the rank-2 array. What happens to this list of lists next?

### Title case

    hw case.Upper⌾(⊑¨)↩

This statement consists of the name `hw` just defined, a compound function, and then the new character `↩`. This is another form of [assignment](expression.md#assignment), like `←`, but it changes the value of an existing variable instead of defining a new one. There's also some special `↩` syntax here: the expression `val Fn↩` is shorthand for `val ↩ Fn val`, avoiding the need to write the name `hw` twice (and `val Fn↩ arg` means `val ↩ val Fn arg`, like `+=` and so on from C). So we are modifying `hw` by applying this function `case.Upper⌾(⊑¨)`.

        hw ← <˘ 2‿∘ ⥊ "helloworld"
        Upper ← -⟜(-´"Aa")⁼

        Upper⌾(⊑¨) hw

        hw Upper⌾(⊑¨)↩  # Sets new value for hw

That converts the first character of each string to uppercase! `case.Upper` is the case conversion function defined before, so that part makes sense. The rest of the function, `⌾(⊑¨)`, would be pronounced "[Under](under.md) the [First](pick.md#first) of [Each](map.md#one-argument-mapping)", which… pretty much makes sense too? The First Each function extracts the first element of each list in `hw`, the part that used to be `"hw"` but is now `"HW"`.

        ⊑¨ hw

        Upper "hw"

The Under modifier keeps track of where that string came from and puts it *back*, to produce a new, altered array. It's kind of special, like Undo, but works on all sorts of fancy selections. It's also worth pointing out that `Upper` applies to a string here, not an individual character. That's because arithmetic is [pervasive](arithmetic.md#pervasion), so that functions made of arithmetic naturally work on arrays. Although in this case it wasn't really necessary, because it's also possible to map over the two strings and uppercase the first character of each separately:

        Upper⌾⊑¨ "hello"‿"world"

Modifiers are applied from left to right, opposite to functions (1-modifiers also take the operand on the left while prefix functions have the argument on the right). So `Upper⌾⊑¨` means `(Upper⌾⊑)¨`.

### Punctuation and printing

The variable `hw` is modified one more time, then printed, producing the output Hello, World!

    •Out hw ↩ ∾ ⥊⍉ [hw, ", "‿"!"]  # Hello, World!

None of these functions have a subject to the left, so they're all evaluated as prefix functions. But first, we have the [array notation](arrayrepr.md#high-rank-arrays) `[]`. This syntax forms an array from its major cells `hw` and `", "‿"!"` (another strand, a list of two strings). Because the major cells are both lists, we have another rank 2 array.

        [hw, ", "‿"!"]

The reason for forming this array is to interleave the elements, or we might say to read down the columns rather than across the rows. This ordering is done with a [Transpose](transpose.md) to exchange the two axes, then a [Deshape](reshape.md#deshape) to flatten it out, giving a list.

        ⍉ [hw, ", "‿"!"]

        ⥊ ⍉ [hw, ", "‿"!"]

Finally, [Join](join.md) combines this list of strings into a single string.

        hw ↩ ∾ ⥊⍉ [hw, ", "‿"!"]
        hw

The full statement stores this back in `hw` with `↩`, then prints it using `•Out`. Assignment can be used inline, much like a function! `•Out` is our first [system function](../spec/system.md) (see [this section](../spec/system.md#input-and-output)), and prints a string directly as output. We have now printed that which new programmers must print, and covered the basics of BQN expressions!
