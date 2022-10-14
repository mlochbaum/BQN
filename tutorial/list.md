*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/tutorial/list.html).*

# Tutorial: Working with lists

Enough with all these preliminaries like learning how to read basic expressions. Let's get into what makes BQN special.

        ⟨1, 2, 3⟩

This is a list. Wait for it…

        ⟨1, 2, 3⟩ + 1

There we go. Now in BQN arrays are not just lists, which are a 1-dimensional data structure, but can have any number of dimensions. In this tutorial we're going to discuss lists only, leaving the 5-dimensional stuff for later. So we're really only seeing the power of [K](https://aplwiki.com/wiki/K), an APL-family language that only uses lists (and dictionaries, which BQN doesn't have). K was powerful enough for Arthur Whitney to found [two](https://en.wikipedia.org/wiki/Kx_Systems) [companies](https://shakti.com/) and make millions and millions of dollars, and BQN's compiler also runs almost entirely on lists, so this is probably enough power for one webpage.

## List notation

There are three kinds of list notation in BQN. Each of them has a subject role overall, even if expressions used inside it might have other roles. First, a *string* is a list of characters, and is written by placing those characters in double quotes.

    "Text!"

<!--GEN prim.bqn
Primitives ⟨"""%%String", "⟨%(%Start list", "⟩%)%End list", "⋄%;%Separator", ",%%Separator"⟩
-->
Just one character needs to be escaped to be used a string: the double quote has to be written twice—a lone double quote would end the string, of course. Any other character, including a newline, can be placed directly in a string. For example, `"'"""` is a string with two characters, the single and double quote.

Second, *list notation* uses angle brackets `⟨⟩`. The *elements* in the list are kept apart with one of the three *separator* characters: `,`, `⋄`, and newline. Anything can be used as an element, even a function, or a modifier like `∘`. Here's a list containing a number, a 2-modifier, a string, and a non-string list:

    ⟨ π, ∘, "element" ⋄ ⟨'l',1,5,'t'⟩ ⟩

The two characters `,` and `⋄` are completely interchangeable, and newline is nearly the same but has the additional function of ending a comment (I guess now's as good a time as any to officially point out that *comments* start with `#` and end with a newline, and have no effect on the program but may in rare cases have an effect on the reader). You can use extra separators anywhere in a list: leading, trailing, and repeated separators are ignored.

    ⟨
      "putting"         # This is a comment
      "a",              # That , wasn't needed
      "list"
                        # An extra newline won't hurt anything
      "on","multiple"   # Two elements here
      "lines"
    ⟩

<!--GEN
Primitives ⟨"#%%Comment", "‿% %Strand"⟩
-->
Finally, *strand notation* is a shortcut for simple lists, like one that just lists a few numbers. It's written with the *ligature* `‿`, which has a higher precedence than either functions or operators (and is typed with backslash-space on the BQN keyboard). A sequence of values joined with ligatures becomes a list, so that for example the following two expressions are equivalent:

    ⟨2,+,-⟩
    2‿+‿-

Strand notation is shorter and looks less cluttered in this example. As with lists, anything goes in a strand, but if it's the result of a function or operator, or another strand, then it has to be put in parentheses first. With one set of parentheses, a strand will be just as long as the equivalent bracketed list, and with two you're better off using the list.

An individual ligature is part of BQN syntax, not a value, and it doesn't do something specific like a function does. It's the sequence of ligatures that makes whatever they join together into a list. So if we parenthesize either ligature below, we get a different result! Ligatures aren't right-associative or left-associative.

        0‿1‿2

        (0‿1)‿2

        0‿(1‿2)

## BQN types

Now that six of the seven BQN types have been introduced, let's make a diagram:

<!--GEN
types ← ⍉"Number"‿"Character"‿"Array"≍"Function"‿"1-modifier"‿"2-modifier"
sh ← ≢ types
p ← 96‿38
dim ← (2×p) + sh × d1 ← 136‿64
rp ← 8÷d1
Posd ← Pos d1⊸×
Size ← "width"‿"height" ≍˘ ·FmtNum d1×⊢
cl ← {"class"‿𝕩}¨ "purple"‿"bluegreen"‿"yellow"

TP ← "text" Attr "dy"‿"0.32em"∾˜Posd⊘(∾⟜Posd)
ts← (≍⌜´0.5+↕¨sh) TP⊸Enc¨ types
l ← (cl TP¨ (0.75≍¨1(-≍+)1.2)∾<2.2‿2.3) Enc¨ "Data"‿"Operation"‿"Atom"
RD← (Size ⟨⊑sh,1⟩-2×rp)∾Posd
r ← (2↑cl) {"rect" Elt 𝕩∾"rx"‿"10px"≍𝕨}⟜RD¨ 0(rp+≍)¨↕1⊑sh

Round ← {
  v ← (𝕨⊸×÷+´⌾(×˜))¨ ¯1⊸⌽⊸- 𝕩
  or← 0< v +´∘×⟜(⌽-⌾⊑)¨ 1⌽v
  "Z"∾˜ 'M'⌾⊑ ∾ ⥊ (('L'∾Fmt)¨ v+𝕩) ≍˘ or ('A'∾·Fmt(𝕨‿𝕨∾0‿0)∾∾)¨ (1⌽-v)+𝕩
}
a ← "path" Elt >⟨"d"‿(12 Round d1⊸×¨ ⥊ ((⊢≍˘1⊸⌽) 0‿2‿3) ≍¨ ↕3),¯1⊑cl⟩

FS ← {𝕩 Enc˜ "g"Attr⟨"font-size",(Fmt𝕨)∾"px"⟩}
((0‿2-p)∾dim) SVG ⟨
  "g stroke-width='2'" Enc a‿r
  "g text-anchor='middle' fill='currentColor'" Enc 18‿18 FS¨ ts‿l
⟩
-->

Lists are just one-dimensional arrays. These types are divided into *data types*, which correspond to a subject role, and *operation types*, which each have a matching role. Also, any value that's not an array, such as everything we used in the last tutorial, is called an *atom*.

## Arithmetic on lists

Arithmetic functions automatically apply to each element of a list argument. If both arguments are lists, they have to have the same length, and they're matched up one element at a time.

        ÷ ⟨2,3,4⟩

        "APL" + 1

        "31415" - '0'

        4‿3‿2‿1 ⋆ 1‿2‿3‿4

This list application works recursively, so that lists of lists (and so on) are handled as well. We say that arithmetic functions are *pervasive*. They dig into their arguments until reaching the atoms.

        2 × ⟨0‿2 ⋄ 1‿3‿5⟩

        ⟨ 10, 20‿30 ⟩ + ⟨ 1‿2, 3 ⟩

## Some list functions

<!--GEN
Primitives ⟨"⋈%Z%Enlist%Pair", "∾%,%%Join To", "⌽%q%Reverse%Rotate"⟩
-->
Let's introduce a few primitives to work with lists.

Make one or two arguments into a list with `⋈`, pronounced Enlist in the one-argument case and Pair in the two-argument case. This is kind of the same thing as list notation, and in fact I'd write the two examples below as list literals. But BQN is set up to get the most out of functions, so it's very useful to have a function version of that special syntax for lists built in.

        ⋈ "elt"

        2 ⋈ 4

Concatenate lists with Join To (`∾`). The little chain link symbol—technically "inverted lazy S"—is my favorite in BQN. Hook those lists together!

        ⟨1,2,3⟩ ∾ "abc"

        0 ∾ ⟨1,2,3⟩

        "plural" ∾ 's'

The last two examples show that you can join a list to an atom, making it the first or last element of the result. This is a little suspect because if you decide the data being stored is more complicated and start using a list instead of an atom, then it will no longer be used as a single element but rather a subsection of the result. So I would only use that shortcut for something like a numeric literal that's clearly an atom and will stay that way, and otherwise wrap those atomic arguments in some `⟨⟩` brackets. Join will even work with two atoms, but in that case it makes more sense to use Pair instead.

Reverse (`⌽`) puts the list back to front.

        ⌽ "drawer"

With a left argument `⌽` means Rotate instead, and shifts values over by the specified amount, wrapping those that go off the end to the other side. A positive value rotates to the left, and a negative one rotates right.

        2 ⌽ ⟨0,1,2,3,4⟩

        ¯1 ⌽ "bcdea"

### …and modifiers

<!--GEN
Primitives ⟨"¨%2%Each", "´%5%Fold", "∾%,%Join%Join To"⟩
-->
The 1-modifier Each (`¨`) applies its operand to every element of a list argument, like `map` in a functional programming language. So here's how we'd reverse each of three lists.

        ⌽¨ "abcd"‿"ABCDEF"‿"01"

Given two list arguments, Each pairs the corresponding elements—first with first, second with second, and so on, like a `zip` function. If just one argument's a list and the other's an atom, it reuses the atom in every pair instead. This many-to-many or one-to-many pairing is the same as we saw for arithmetic. But Each only ever goes one level deep while arithmetic keeps going until it reaches a non-list.

        "abc" ⋈¨ "ABC"

        "string"‿"list"‿"array" ∾¨ 's'

Next, Fold (`´`) is the higher-order function also known as reduce or accumulate. The argument has to be a list, and it applies its operand function between all the elements of that list. For example, `+´` gives the sum of a list and `×´` gives its product.

        +´ 2‿3‿4
        ×´ 2‿3‿4

To match the order of BQN evaluation, Fold moves over its argument array from right to left. You'd get the same result by writing the operand function in between each element of the argument list, but you'd also write the function a lot of times.

        -´ 1‿2‿3‿4‿5
        1-2-3-4-5

With this evaluation order, `-´` gives the *alternating sum* of its argument, which comes up in math once in a while. Think of it this way: the left argument of each `-` is a single number, while the right argument is made up of all the numbers to the right subtracted together. So each `-` flips the sign of every number to its right, and every number is negated by all the `-`s to its left. The first number (`1` above) never gets negated, the second is negated once, the third is negated twice, returning it to its original value… the signs alternate.

*Hey, isn't it dissonant that the first, second, and third numbers are negated zero, one, and two times? Not if you call them the zeroth, first, and second…*

You can fold with the Join To function to join several lists together:

        ∾´ ⟨ "con", "cat", "enat", "e" ⟩

But you shouldn't! Just `∾` will do the job for you—with no left argument it's just called "Join" (it's like Javascript's `.join()`, but with no separator and not specific to strings). And it could do more jobs if you had more dimensions. But let's not push it.

        ∾ ⟨ "con", "cat", "enat", "e" ⟩

## Example: base decoding

Some people like to imagine that robots or other techno-beings speak entirely in binary-encoded ASCII, like for instance "01001110 01100101 01110010 01100100 00100001". This is dumb for a lot of reasons, and the encoded text probably just says something inane, but you're a slave to curiosity and can't ignore it. Are one and two-thirds tutorials of BQN enough to clear your conscience?

<!--GEN
Primitives ⟨"↕%d%Range%", "⊸%h%Bind?%"⟩
-->
Almost. It's really close. There are just two things missing, so I'll cover those and can we agree one and three-quarters is pretty good? First is Range (`↕`), which is called on a number to give all the natural numbers less than it:

        ↕ 8

Natural numbers in BQN start at 0. I'll get to the second primitive in a moment, but first let's consider how we'd decode just one number in binary. I'll pick a smaller one: 9 is 1001 in binary. Like the first 1 in decimal 1001 counts for one thousand or `10⋆3`, the first one in binary 1001 counts for 8, which is `2⋆3`. We can put each number next to its place value like this:

        8‿4‿2‿1 ⋈¨ 1‿0‿0‿1

To get the value we multiply each number by its place value and then add them up.

        +´ 8‿4‿2‿1 × 1‿0‿0‿1

Now we'd like to generate that list `8‿4‿2‿1` instead of writing it out, particularly because it needs to be twice as long to decode eight-bit ASCII characters (where the first bit is always zero come on robots would never use such an inefficient format). It's the first four powers of two, or two to the power of the first four natural numbers, in reverse. While we're at it, let's get `1‿0‿0‿1` from `"1001"` by subtracting `'0'`. Nice.

        2 ⋆ ↕4

        ⌽2⋆↕4

        (⌽2⋆↕4) × "1001"-'0'

        +´ (⌽2⋆↕4) × "1001"-'0'

Lot of functions up there. Notice how I need to use parentheses for the left argument of a function if it's compound, but never for the right argument, and consequently never with a one-argument function.

<!--GEN evalexp.bqn
Eval "wh↩19⌾(¯1⊸⊑)wh"
DrawEval "+´ (⌽2⋆↕4) × ""1001""-'0'"
-->

Representing our ASCII statement as a list of lists, we convert each digit to a number as before:

        '0' -˜ "01001110"‿"01100101"‿"01110010"‿"01100100"‿"00100001"

Now we need to multiply each digit by the right place value, and add them up. The adding part is easy, just requiring an Each.

        +´¨ '0' -˜ "01001110"‿"01100101"‿"01110010"‿"01100100"‿"00100001"

Multiplication is harder, and if we try to multiply by the place value list directly it doesn't go so well.

        (⌽2⋆↕8) × '0' -˜ "01001110"‿"01100101"‿"01110010"‿"01100100"‿"00100001"

This is because the list on the left has length 8 while the list on the right has length 5. The *elements* of the list on the right have length 8, but BQN can't be expected to know you want to connect the two arguments in that particular way. Especially considering that if you happen to have 8 characters then the right argument *will* have length 8!

There are a few ways to handle this. What we'll do is *bind* the place values to `×` using the 2-modifier `⊸`. This modifier attaches a left argument to a function.

        "ab" ∾¨ ⟨ "cd", "ut" ⟩

        "ab"⊸∾¨ ⟨ "cd", "ut" ⟩

In the first bit of code above, `¨` matches up its left and right arguments. In the second, we bind `"ab"` to `∾` first—remember that modifiers associate from left to right, so that `"ab"⊸∾¨` and `("ab"⊸∾)¨` are the same—and Each only sees one argument. `"ab"`, packed inside Each's operand, is reused each time. The same principle applies to our binary problem:

        +´¨ (⌽2⋆↕8)⊸×¨ '0' -˜ "01001110"‿"01100101"‿"01110010"‿"01100100"‿"00100001"

To wrap things up, we just convert from numbers to characters by adding the null character.

        @ + +´¨ (⌽2⋆↕8)⊸×¨ '0' -˜ "01001110"‿"01100101"‿"01110010"‿"01100100"‿"00100001"

Was it as anticlimactic as you'd hoped? In fact there's a simpler way to do the base decoding as well, using `⊸`'s mirror image `⟜` in a different way. We'll discuss that in the next tutorial!

        +´ (⌽2⋆↕4) × "1001"-'0'
        +⟜(+˜)´ ⌽ "1001"-'0'

## Summary

There are three types of syntax that create lists. `"string literal"` gives a list of characters. For arbitrary lists, use enclosing angle brackets `⟨⟩` with `,` or `⋄` or newline between elements, or just connect elements with ligatures `‿`. The ligature has a higher precedence than functions or modifiers and might require parentheses, so we should add it to our precedence table:

Precedence | Role     | Associativity
-----------|----------|--------------
0          | `()⟨⟩`   | (none)
1          | `‿`      | Non-binary
2          | Modifier | Left-to-right
3          | Function | Right-to-left

The elements of a list can have any syntactic role. It's ignored and the list as a whole is a subject.

We introduced a few new primitives. The links in the table go to their full documentation pages.

Glyph | 1 arg                        | 2 args
------|------------------------------|--------
`∾`   | [Join](../doc/join.md)       | [Join To](../doc/join.md)
`⋈`   | [Enlist](../doc/pair.md)     | [Pair](../doc/pair.md)
`⌽`   | [Reverse](../doc/reverse.md) | [Rotate](../doc/reverse.md#rotate)
`↕`   | [Range](../doc/range.md)     |
`¨`   | [Each](../doc/map.md)        | [Each](../doc/map.md#each)
`´`   | [Fold](../doc/fold.md#fold)

And we saw that the arithmetic functions work naturally on lists, automatically applying to every element of a single list argument or pairing up the elements of two list arguments.

Even this small amount of list functionality is enough to tackle some little problems. We haven't even introduced a function notation yet!
