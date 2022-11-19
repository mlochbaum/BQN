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
        · 𝕊 ' ': spl⇐1 ;             # Space: break and delete it
        prev Fn cur: ⟨spl,str⟩⇐
          spl←0 ⋄ str←⟨cur⟩          # Include and don't break...
          { prev=cur ? spl+↩1 ; @ }  # except at equal characters
      }
      GV‿GS ← {𝕏¨}¨ ⟨ {⟨s⇐str⟩:s;""}
                      {𝕩.spl} ⟩
      r ← Proc{»𝔽¨⊢} 𝕩
      (∾¨ GV ⊔˜ ·+`GS) r
    }
    •Show Split hw  # ⟨ "Hel" "lo," "World!" ⟩

It's not the most idiomatic BQN you'll see, but that's because this piece of code uses nearly all the syntax in the language (and a good number of the primitives).

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

The function `Lower` is defined to be `-⟜diff`, but it uses a different arrow `⇐` to do this. This is an [export](namespace.md#exports), and it declares that `Lower` is a *field* of a namespace that can be accessed from the outside. Having a `⇐` in it is also what makes the block define a namespace. `Lower` itself won't be used for a while, but `Upper` is accessed a few lines down, with `case.Upper`.

`Lower` is created with a modifier again, this time the 2-modifier `⟜`. We've now seen one each of the three [*primitive*](primitive.md) types: function, 1-modifier, and 2-modifier. There are a lot of primitives, but some simple rules tell you which type they have. Primitives are functions by default, but superscript characters are 1-modifiers (`` ´⁼˘¨˜` `` in our program), and ones with an unbroken circle are 2-modifiers (`⟜∘⌾`; `⍉` is a broken circle so it's a function). Variable names follow a [similar system](expression.md#role-spellings), where functions start with an uppercase letter and subjects with a lowercase one.

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

        case.Upper⌾(⊑¨) hw

        hw case.Upper⌾(⊑¨)↩  # Sets new value for hw

That converts the first character of each string to uppercase! `case.Upper` is the case conversion function defined before, so that part makes sense. The rest of the function, `⌾(⊑¨)`, would be pronounced "[Under](under.md) the [First](pick.md#first) of [Each](map.md#one-argument-mapping)", which… pretty much makes sense too? The First Each function extracts the first element of each list in `hw`, the part that used to be `"hw"` but is now `"HW"`.

        ⊑¨ hw

        case.Upper "hw"

The Under modifier keeps track of where that string came from and puts it *back*, to produce a new, altered array. It's kind of special, like Undo, but works on all sorts of fancy selections. It's also worth pointing out that `case.Upper` applies to a string here, not an individual character. That's because arithmetic is [pervasive](arithmetic.md#pervasion), so that functions made of arithmetic naturally work on arrays. Although in this case it wasn't really necessary, because it's also possible to map over the two strings and uppercase the first character of each separately:

        case.Upper⌾⊑¨ "hello"‿"world"

Modifiers are applied from left to right, opposite to functions (1-modifiers also take the operand on the left while prefix functions have the argument on the right). So `case.Upper⌾⊑¨` means `(case.Upper⌾⊑)¨`.

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

## Breaking hello

Now we're going to play around with the string `hw` or `"Hello, World!"` that we've constructed, and see a few ways to construct functions. If you're starting out you won't need many of the details here for a while, so you may want to stop after getting the basic idea and revisit this page later.

    # Split at spaces and repeated characters
    Split ← {
      !1==𝕩 ⋄ (!2=•Type)¨𝕩
      Proc ← {
        · 𝕊 ' ': spl⇐1 ;             # Space: break and delete it
        prev Fn cur: ⟨spl,str⟩⇐
          spl←0 ⋄ str←⟨cur⟩          # Include and don't break...
          { prev=cur ? spl+↩1 ; @ }  # except at equal characters
      }
      GV‿GS ← {𝕏¨}¨ ⟨ {⟨s⇐str⟩:s;""}
                      {𝕩.spl} ⟩
      r ← Proc{»𝔽¨⊢} 𝕩
      (∾¨ GV ⊔˜ ·+`GS) r
    }
    •Show Split hw  # ⟨ "Hel" "lo," "World!" ⟩

The big definition `Split` is a [block function](block.md), using `{}` like the namespace `case`—that was an immediate block. The difference is that `Split` contains an `𝕩`, which indicates an argument. We also see that blocks can be nested within each other. The inner blocks contain other characters like `⇐` and `𝔽` that can change the nature of a block, but these only affect the block immediately containing them.

To begin with, `Split` tests its argument `𝕩`. There are two tests, with a statement [separator](token.md#separators) `⋄` between them. The diamond, as well as `,`, is interchangeable with a newline. The tests are done with the function [Assert](assert.md) (`!`).

    !1==𝕩 ⋄ (!2=•Type)¨𝕩

First, `Split` requires that the [rank](shape.md) `=𝕩` be 1, that is, `𝕩` must be a list. In `1==𝕩`, `=` has two meanings, depending on whether it has a left argument. Next, it checks that each element has a character [type](../spec/system.md#operation-properties).

The subexpression `!2=•Type` is a function [train](train.md), and it happens to have a simple expansion, as `(!2=•Type)e` is `!2=•Type e`. It matters that `2` is just a number; if it were a function it would be applied to `e`. We'll discuss trains more later. This one is applied with [Each](map.md#one-argument-mapping) to test every element of `𝕩`. This does form an array result, but it's not used.

### Subfunction

The function `Proc` is called on each character of `𝕩` along with the previous character, and says what to do at that position. Also, it's deliberately inconsistent to cover more BQN features. Here's the whole thing:

    Proc ← {
      · 𝕊 ' ': spl⇐1 ;             # Space: break and delete it
      prev Fn cur: ⟨spl,str⟩⇐
        spl←0 ⋄ str←⟨cur⟩          # Include and don't break...
        { prev=cur ? spl+↩1 ; @ }  # except at equal characters
    }

Unlike `Split`, which only contains a sequence of statements, `Proc` has some structure. Let's reduce each block *body* to a `…` to see it better.

    Proc ← {
      · 𝕊 ' ': … ;
      prev Fn cur: …
    }

This function has two bodies with `;` in between. Each one has a *header*, separated from the body with a `:`. A header indicates the kind of the block as a whole, and also which inputs the body after it works on. It mirrors the way the block should be used. In the right context, both `· 𝕊 ' '` and `prev Fn cur` would be valid function calls. Which tells us `Proc` is a function.

The first header, `· 𝕊 ' ':`, is more specific. The function is unlabelled, since `𝕊` just indicates the block function it's in (useful for [recursion](block.md#self-reference)). The right argument is `' '`, a space character, so this body will only be used if `𝕩` is a space. And the left argument is… `·`, which is called [Nothing](expression.md#nothing). Both here and as an assignment target, Nothing indicates an ignored value. This body *does* require a left argument, but it doesn't name it. And the body itself is just `spl⇐1`. The `⇐` makes this body (only this one!) return a namespace, which has only the field `spl`.

The next header, `prev Fn cur:`, sets names for the function and its arguments, but doesn't constrain them other than requiring two arguments. So it applies in all the cases where the previous one didn't match, that is, when `𝕩` isn't `' '`. The body starts with `⟨spl,str⟩⇐`, and the `⇐` means it will return a namespace too. This is an [export statement](namespace.md#exports), which declares `spl` and `str` to be fields but doesn't define them—they must be defined somewhere else in the block, which is what happens next.

    prev Fn cur: ⟨spl,str⟩⇐
      spl←0 ⋄ str←⟨cur⟩          # Include and don't break...
      { prev=cur ? spl+↩1 ; @ }  # except at equal characters

Both `⟨spl,str⟩` and `⟨cur⟩` are written with [list notation](arrayrepr.md#brackets), giving a list of two names, then one value. While `⟨spl,str⟩` can also be written `spl‿str`, there's no way to write `⟨cur⟩` with stranding.

On the last line we're now three blocks deep! This block also has two bodies, but they don't have headers. A [predicate](block.md#predicates) `prev=cur ?` tests whether to use the first body, which increments `spl` with [modified assignment](expression.md#assignment). Note that `𝕨=𝕩` wouldn't work here, because the special names `𝕨` and `𝕩` pertain only to the surrounding block, and `Proc` is a level up. However, the idiomatic way to write this part would be the much shorter `spl←prev=cur`, since BQN's booleans are 0 and 1.

The end result of `Proc` is always a namespace. It has a field `spl` set to 1 if `𝕩` is `' '` or the two arguments are equal. And if `𝕩` isn't `' '`, it has another field `str` set to `⟨𝕩⟩`.

### Extraction

Once `Proc` is applied to all the characters, we'll end up with a list of namespaces (which, yes, is over-engineered for what we're doing). The following statement defines two functions `GV` and `GS` to extract fields from this list.

    GV‿GS ← {𝕏¨}¨ ⟨ {⟨s⇐str⟩:s;""}
                    {𝕩.spl} ⟩

Going left to right, `GV‿GS` indicates [destructuring assignment](expression.md#destructuring), which will expect a list of two values on the right and take it apart to assign the two names. The right hand side is the function `{𝕏¨}¨` applied to a list.

`{𝕏¨}` is a block function, like `Split` but a lot shorter. It uses the uppercase `𝕏` instead of `𝕩`, so that it treats `𝕩` as a function (it doesn't *require* it to be a function, though: see [mixing roles](context.md#mixing-roles)). It adds an Each `¨` onto its argument. This is used to convert the two functions in the list from functions that work on a namespaces to functions that work on a list of them.

The list is split across two lines, using newline as a [separator](token.md#separators) instead of `,` or `⋄`. Its second function `{𝕩.spl}` is simpler: it takes a namespace `𝕩` and gets the field named `spl`.

The first function is more complicated, because the argument namespace might or might not have an `str` field. The list-like notation `⟨s⇐str⟩` is another example of destructuring assignment, but this time it destructures a namespace, using an [alias](namespace.md#imports) to give it a short name. This header leaves off the function name `𝕊`, using a [special rule](block.md#special-names-in-headers) for one-argument functions. Arguments in headers are very similar to assignment targets, but if the destructuring doesn't match it tries the next body (if there is one) instead of giving an error. So if the argument is a namespace with an `str` field then `{⟨s⇐str⟩:s;""}` returns that field's value, and otherwise it returns `""`.

### Assembly

Now that `Split` has defined `Proc`, `GV` (get value), and `GS` (get split), it's ready to do its work.

    r ← Proc{»𝔽¨⊢} 𝕩
    (∾¨ GV ⊔˜ ·+`GS) r

The first line here applies `Proc` to each character and the one before it, using `' '` as the character "before" the first. `Proc{»𝔽¨⊢} 𝕩` is a fancy way to write `(»𝕩) Proc¨ 𝕩`, which we'll explain in a moment. First, here's what the [Nudge](shift.md) function `»` does.

        hw
        »hw

It moves its argument forward by one, adding a space character (the array's [fill](fill.md)) but keeping the same length. This gives the previous characters that we want to use for `Proc`'s left argument. Here [Each](map.md#each) is used with two arguments, so that it iterates over them simultaneously, like a "zip" in some languages.

What about the fancy syntax `Proc{»𝔽¨⊢} 𝕩`? The block `{»𝔽¨⊢}` is an immediate 1-modifier because it uses `𝔽` for an [operand](block.md#operands) but not the arguments `𝕨` or `𝕩`. This means it acts on `Proc` only, giving `»Proc¨⊢`, which is a [train](train.md) because it ends in a function `⊢`. Following the rules for a 3-train, `(»Proc¨⊢)𝕩` expands to `(»𝕩) Proc¨ (⊢𝕩)`, and since `⊢` is the [identity function](identity.md), `⊢𝕩` is `𝕩`.

Since a display of lots of namespaces isn't too enlightening, we'll skip ahead and show what the results of `GV` and `GS` on those lists would be. `GV` turns each character into a string, except it makes a space into the empty string. `GS` has a `1` in the places where we want to split the string.

        sp ← ' '=hw
        gv ← (1-sp) ⥊¨ hw
        gs ← sp ∨ »⊸= hw

        gv

        gs

### More assembly

    (∾¨ GV ⊔˜ ·+`GS) r

The next part is a bigger train. Trains are grouped into threes starting at the end, which takes some time to get used to. Here's a diagram showing how this one works.

<!--GEN
"gv"‿"gs" DrawEval "∾¨ GV ⊔˜ ·+`GS"
-->

There are actually three train groupings here: from right to left, ``·+`GS``, `GV ⊔˜ …`, and `∾¨ …`. Two of them are 2-trains, which apply one function to the result of another, but the one with `⊔` is a 3-train, applying a function to two results. In the end, functions `GS` and `GV` are applied to `r`. In fact, to evaluate the entire train we can replace these two functions with their results, giving ``∾¨ (GV r) ⊔˜ ·+`(GS r)``.

        ∾¨ gv ⊔˜ ·+`gs

In this expression, [Nothing](expression.md#nothing) can be removed without changing the meaning. It's used in the train to force `` +` `` to apply to `GS` as a 2-train instead of also taking `⊔˜` as a left argument. The [Scan](scan.md) `` +` `` is a prefix sum, progressively adding up the numbers in `gs`.

        gs

        +`gs

The next bit uses [Swap](swap.md) to switch the order: ``gv ⊔˜ +`gs`` is ``(+`gs) ⊔ gv``, but sometimes the different order can read better (here it was mostly to squeeze Nothing into the program, I'll admit). [Group](group.md) then splits `gv` up based on the indices given: the first three elements become element 0 of the result, the next three element 1, and the rest element 2.

        (+`gs) ⊔ gv

Then Join Each uses two functions we've seen before to build the final result!
