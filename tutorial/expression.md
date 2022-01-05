*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/tutorial/expression.html).*

# Tutorial: BQN expressions

## Arithmetic

All right, let's get started! Since you can run BQN online from the [REPL](https://mlochbaum.github.io/BQN/try.html) there aren't any real technical preliminaries, but if you'd like to look at non-web-based options head over to [running.md](../running.md).

In the code blocks shown here, input is highlighted and indented, while output is not colored or indented. To experiment with the code, you can click the `↗️` arrow in the top right corner to open it in the REPL.

        2 + 3
        6-   5
        - 1.5

<!--GEN prim.bqn
Primitives ⟨"+%%%Add", "-%%Negate%Subtract"⟩
-->
Shown above are a few arithmetic operations. BQN manages to pass as a normal programming language for three lines so far. That's a big accomplishment for BQN! Earth's a confusing place!

The number of spaces between *primitive functions* like `+` and `-` and their *arguments* doesn't matter: you can use as much or as little as you like. No spaces inside numbers, of course.

        2 × π
        9 ÷ 2
        ÷ ∞

<!--GEN
Primitives ⟨
  "×%=%%Multiply"
  "÷%-%Reciprocal%Divide"
  "π%p%Pi"
  "∞%8%Infinity"
⟩
-->
Okay, now BQN looks like normal (grade-school) mathematics, which is sort of like looking normal. Pi (`π`) represents [that real famous number](https://en.wikipedia.org/wiki/Pi) and Infinity (`∞`) is also part of the number system (the BQN spec allows an implementation to choose its number system, and all existing implementations use double-precision floats, like Javascript or Lua). In analogy with the one-argument form of Minus (`-`) giving the negation of a number, Divide (`÷`) with only one argument gives its reciprocal.

A number can be raised to the power of another with Power, written `⋆`. That's a star rather than an asterisk; BQN doesn't use the asterisk symbol. If it's called without a left argument, then `⋆` uses a base of [Euler's number](https://en.wikipedia.org/wiki/E_(mathematical_constant)) *e* and is called Exponential.

        2 ⋆ 3
        3 ⋆ 2
        ⋆ 1   # e isn't built in but you can get it this way
        ⋆ 2.3

<!--GEN
Primitives ⟨"⋆%+%Exponential%Power", "√%_%Square Root%Root"⟩
-->
You could use Power to take square roots and *n*-th roots, but BQN has a primitive `√` for this purpose. If no left argument is provided, then it's the Square Root function; with a left argument it's called Root, and raises the right argument to the power of one divided by the left argument.

        √ 2
        3 √ 27

On the BQN keyboard, the six functions just given are all typed with the `+` and `-` keys. To type the non-ASCII ones, use a backslash prefix. The three functions Plus, Times, and Power on the plus key are paired with their "reciprocal" versions Minus, Divide, and Square Root on the minus key.

    - +   # Ordinary keys
    ÷ ×   # \
    √ ⋆   # \ shift

In case you're wondering, Logarithm—the other inverse of Power—is written `⋆⁼`. We'll see how that works when we introduce `⁼` in the section on 1-modifiers.

## Compound expressions

It's sometimes useful to write programs with more than one function in them. Here is where BQN and any sort of normality part ways.

        2×3 - 5
        (2×3) - 5

I bet if you try hard you'll remember how much you hated learning to do exponentiation before multiplication and division before addition and subtraction. Didn't I tell you Earth was a confusing place? BQN treats all functions—not only primitives, but also the ones you define—the same way. They're evaluated from right to left, and parentheses form subexpressions that are evaluated entirely before they can be used.

For a longer example, here's an expression for the [volume of a sphere](https://en.wikipedia.org/wiki/Sphere#Enclosed_volume) with radius 2.

        (4÷3) × π × 2⋆3

The evaluation order is diagrammed below, with the function `⋆` on the first line evaluated first, then `×` on the next, and so on. The effect of the parentheses is that `÷` is evaluated before the leftmost `×`.

<!--GEN evalexp.bqn
DrawEval "(4÷3) × π × 2⋆3"
-->

The online REPL includes a tool to create diagrams like the one shown above. To enable it, click the "explain" button. Then a diagram of your source code will be shown above the result each time you run an expression.

The following rule might help you to internalize this system in addition to identifying when parentheses are needed: an expression never needs to end with a parenthesis, or have two closing parentheses in a row. If it does, at least one set of parentheses can be removed without changing the meaning.

## One or two arguments?

What about functions without a left argument? Let's find an equation with lots of square roots in it… [looks good](https://en.wikipedia.org/wiki/Nested_radical#Denesting).

        √ 3 + 2 × √2
        1 + √2

They are the same, and now you can't say that BQN syntax is the most complicated thing on this particular page! Just to make sure, we can find the difference by subtracting them, but we need to put the left argument of the subtraction in parentheses:

        (√3 + 2×√2) - 1+√2

That's a fairly large expression, so here's another evaluation diagram to check your understanding.

<!--GEN
wh↩19⌾(¯1⊸⊑)wh
DrawEval "(√3 + 2×√2) - 1+√2"
-->

But wait: how do we know that `√` in the expressions above uses the one-argument form? Remember that it can also take a left argument. For that matter, how do we know that `-` takes two arguments and not just one? Maybe this looks trivial right now: a good enough answer while we're only doing arithmetic is that a function is called with one argument if there is nothing to its left, or another function, and with two arguments otherwise. But it will get more complicated as we expand the syntax with expressions that can return functions and so on, so it's a good idea to discuss the foundations that will allow us to handle that complexity. In BQN, the way expressions are evaluated—the sequence of function calls and other operations—is determined by the *syntactic role* of the things it contains. A few rules of roles make sense of the syntax seen so far:

* *Numeric literals* such as `1` and `π` are *subjects*.
* *Primitive functions* are *functions* (gasp).
* A function's arguments are subjects. To call a function it must have a subject on the right, and may have a subject on the left, which is used as the left argument.
* A function's result is a subject—or, more precisely, a function call expression is a subject.
* A set of parentheses has the same role as whatever's inside it.

Perhaps more than you thought! To really get roles, it's important to understand that a role is properly a property of an expression, and not its value. In language implementation terms, roles are used only to parse expressions, giving a syntax tree, but don't dictate what values are possible when the tree is evaluated. So it's possible to have a function with a number role or a number with a function role. The reason this doesn't happen with the numeric literals and primitives we've introduced is that these tokens have a constant value. `×` or `∞` have the same value in any possible program, and so it makes sense that their types and roles should correspond. When we introduce identifiers, we'll see this correspondence break down—and why that's good!

## Character arithmetic

Gosh, that's a lot of arithmetic up there. Maybe adding characters will mix things up a bit? Hang on, you can't add characters, only subtract them… let's back up.

        'c'

A character is written with single quotes. As in the C language, it's not the same as a string, which is written with double quotes. There are no escapes for characters: any source code character between single quotes becomes a character literal, even a newline. Some kinds of arithmetic e[x](https://xkcd.com/1537/)tend to characters:

        'c' + 1
        'h' - 'a'

But as I blurted earlier, you can't add two characters (and **no** you can never concatenate things by adding them). It's also an error to negate a character or subtract it from a number. Characters reside in an \[intimidating word for simple concept warning\] [affine space](http://videocortex.io/2018/Affine-Space-Types/) \[no relation to those fancy Rust things called linear and affine types\], meaning that the following operations are allowed:
* Adding a number to a character gives a character.
* So does subtracting a number from a character.
* Subtracting two characters gives a number.
Other examples of affine spaces are
* Points on a line (with no origin). You can move a point by a distance or find the distance between two points, but can't add points.
* Times in seconds. You can find the interval between two times or shift a time by some number of seconds, but adding two times together is nonsense.
* Pointers in a computer's memory. Verify for yourself that the rules are the same, if you like.

Want to shift an uppercase character to lowercase? Affine characters to the rescue:

        'K' + 'a'-'A'

Convert a digit to its value? Here you go:

        '4' - '0'

The one thing affine characters won't let you do is find some special "starting character": the main distinguishing factor between a linear and an affine space is that an affine space has no origin. However, for some kinds of programming finding a character's code point is important, so BQN also includes a special literal for the null character, written `@`:

        '*' - @
        @ + 97

<!--GEN
Primitives ⟨"'%%Character", "@%%Null character"⟩
-->
It's a convenient way to write non-printing characters without having to include them in your source code: for example `@+10` is the newline character.

Addition and subtraction with affine characters have all the same algebraic properties that they do with numbers. One way to see this is to think of values as a combination of "characterness" (0 for numbers and 1 for characters) and either numeric value or code point. Addition and subtraction are done element-wise on these pairs of numbers, and are allowed if the result is a valid value, that is, its characterness is 0 or 1 and its value is a valid code point if the characterness is 1. However, because the space of values is no longer closed under addition and subtraction, certain rearrangements of valid computations might not work, if one of the values produced in the middle isn't legal.

## Modifiers

Functions are nice and all, but to really bring us into the space age BQN has a second level of function called *modifiers* (the space age in this case is when operators were introduced to APL in the early 60s—hey, did you know the [second APL conference](https://aplwiki.com/wiki/APL_conference#1970) was held at Goddard Space Flight Center?). While functions apply to subjects, modifiers can apply to functions *or* subjects, and return functions. For example, the 1-modifier `˜` modifies one function—that's where the 1 comes from—by swapping the arguments before calling it (Swap), or copying the right argument to the left if there's only one (Self).

        2 -˜ 'd'  # Subtract from
        +˜ 3      # Add to itself

This gives us two nice ways to square a number:

        ×˜ 4
        2 ⋆˜ 4

What's wrong with `4⋆2`? Depends on the context. Because of the way evaluation flows from right to left, it's usually best if the right argument to a function is the one that's being manipulated directly while the left argument is sort of a "control value" that describes how to manipulate it. That way several manipulations can be done in a row without any parentheses required. `⋆` can go either way, but if "squaring" is the operation being done then the *left* argument is the one being squared, so it's the active value. The Swap modifier allows us to put it on the right instead.

<!--GEN
Primitives ⟨"˜%`%Swap%Self", "⁼%3%Undo", "˙%""%Constant"⟩
-->
Another 1-modifier is Undo (`⁼`). BQN has just enough computer algebra facilities to look like a tool for Neanderthals next to a real computer algebra system, and among them is the ability to invert some primitives. In general you can't be sure when Undo will work (it might even be undecidable), but the examples I'll give here are guaranteed by [the spec](../spec/inferred.md#undo) to always work in the same way. Starting with a *third* way to square a number:

        √⁼ 4

But the most important use for Undo in arithmetic is the logarithm, written `⋆⁼`. That's all a logarithm is: it undoes the Power function! With no left argument `⋆⁼` is the natural logarithm. If there's a left argument then Undo considers it part of the function to be undone. The result in this case is that `⋆⁼` with two arguments is the logarithm of the right argument with base given by the left one.

        ⋆⁼ 10
        2 ⋆⁼ 32    # Log base 2
        2 ⋆ 2 ⋆⁼ 32
        10 ⋆⁼ 1e4  # Log base 10 of a number in scientific notation

Another 1-modifier, which at the moment is tremendously useless, is Constant `˙`. It turns its operand into a constant function that always returns the operand (inputs to modifiers are called *operands* because *modificands* is just too horrible).

        2 3˙ 4

Well, I guess it's not pedagogically useless, as it does demonstrate that a modifier can be applied to subjects as well as functions. Even though `3` is a subject, `3˙` is a function, and can be applied to and ignore the two arguments `2` and `4`.

With three examples you may have noticed that 1-modifiers tend to cluster at the top of the line. In fact, every primitive 1-modifer is a superscript character: we've covered `˜⁼˙`, and the remaining array-based modifiers `` ˘¨⌜´˝` `` will show up later.

## 2-modifiers

Made it to the last role, the 2-modifier (if you think something's been skipped, you're free to call subjects 0-modifiers. They don't modify anything. Just not when other people can hear you). To introduce them we'll use Atop `∘`, which composes two functions as in mathematics. The resulting function allows one or two arguments like any BQN function: these are all passed to the function on the right, and the result of that application is passed to the function on the left. So the function on the left is only ever called with one argument.

        3 ×˜∘+ 4  # Square of 3 plus 4
        -∘(×˜) 5  # Negative square of 5

<!--GEN
Primitives ⟨"∘%j%Atop"⟩
-->
For example, the first expression `3 ×˜∘+ 4` expands to `×˜ 3 + 4`. Summing up, we get `×˜ 7`, which from the previous section is `7 × 7`, or `49`.

It's past time we covered how the syntax for modifiers works. Remember how I told you you hated learning the order of operations? No? Good. Modifiers bind more tightly than functions, so they are called on their operands before those operands can be used as arguments. As the parentheses above suggest, modifiers associate from left to right, the opposite order as functions. For example, the first expression above is evaluated in the order shown below. First we construct the square function `×˜`, then compose it with `+`, and finally apply the result to some arguments.

<!--GEN
DrawEval "3 ×˜∘+ 4"
-->

This ordering is more consistent with the rule that a 1-modifier's operand should go to its left. If we tried going from right to left we'd end up with `×(˜∘+)`, which uses `˜` as an operand to `∘`. But a modifier can't be used as an operand. To make it work we'd have to give 1-modifiers a higher precedence than 2-modifiers.

In fact, the rules for modifiers are exactly the same as those for functions, but reversed. So why is there a distinction between 1- and 2-modifiers, when for functions we can look to the left to see whether there is a left argument? The reason is that it's natural to follow a 1-modifier by a subject or function that isn't supposed to be its operand. Using an example from the last section, `+˜ 3` has a subject to the right of the 1-modifier `˜`. Even worse, `+˜ ÷ 3` looks just like `+∘ ÷ 3`, but it's two functions `+˜` and `÷` applied to `3` while the version with Atop is a single function `+∘÷` applied to `3`. So the two-layer system of functions and modifiers forces modifiers to have a fixed number of operands even though every function (including those derived by applying modifiers) can be called with one or two arguments.

Remember that 1-modifiers are all superscripts? The characters for 2-modifiers use a different rule: each contains an *unbroken* circle (that is, lines might touch it but not go through it). The 2-modifiers in BQN are the combinators `∘○⊸⟜⊘`, the sort-of-combinators  `⌾◶⍟`, and the not-at-all-combinators `⎉⚇⎊`. And the functions that make that unbroken circle rule necessary are written `⌽⍉`. Since every primitive is a function, 1-modifier, or 2-modifier, you can always tell what type (and role) it has: a superscript is a 1-modifier, an unbroken circle makes it a 2-modifier, and otherwise it's a function.

## Summary

The objects we've seen so far are:

| Type        | Example  | Meaning
|-------------|----------|---------
| Numbers     | `1.2e3`, `π`
| Characters  | `'c'`, `@`
| Functions   | `+`      | Plus ([arithmetic docs](../doc/arithmetic.md))
|             | `-`      | Minus, Negate
|             | `×`      | Times
|             | `÷`      | Divide, Reciprocal
|             | `⋆`      | Power
|             | `√`      | (Square) Root
|             | `⋆⁼`     | Logarithm
| 1-modifiers | `˜`      | Swap, Self
|             | `⁼`      | Undo
|             | `˙`      | Constant
| 2-modifiers | `∘`      | Atop

Except for `⋆⁼`, which is just a particular case of a modifier applied to a function, everything we've seen is either a *literal* (characters and numbers) or a *primitive* (functions and modifiers), and has a fixed value. Primitive 1-modifiers have superscript characters and 2-modifiers contain unbroken circles. Other primitives are always functions.

It's legal to add a number to a character or subtract one character from another, but not to add two characters, negate a character, or subtract it from a number.

BQN's expression grammar is governed by syntactic roles. For literals and primitives, type and syntactic role always match up:

Role       | Types
-----------|--------------
Subject    | Number, Character
Function   | Function
1-modifier | 1-modifier
2-modifier | 2-modifier

So that's a really dumb table but if you put things in a table they suddenly become more important somehow. On another note, here's our precedence table so far:

Precedence | Role     | Input roles       | Output role | Associativity
-----------|----------|-------------------|-------------|--------------
0          | `()`     | Whatever          | Same thing  | (none)
1          | Modifier | Function, subject | Function    | Left-to-right
2          | Function | Subject           | Subject     | Right-to-left

Maybe BQN grammar's not all that bad.
