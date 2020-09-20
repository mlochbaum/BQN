*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/tutorial/expression.html).*

# Tutorial: BQN expressions

## Arithmetic

All right, let's get started! Since you can run BQN online from the [REPL](https://mlochbaum.github.io/BQN/try.html) there aren't any real technical preliminaries, but if you'd like to look at non-web-based options head over to [running.md](../running.md).

In the code blocks shown here, input is highlighted and indented, while output is not colored or indented. To experiment with the code, you can click the `↗️` arrow in the top right corner to open it in the REPL.

        2 + 3
        6-   5
        - 1.5

Shown above are a few arithmetic operations. BQN manages to pass as a normal programming language for three lines so far. That's a big accomplishment for BQN! Earth's a confusing place!

The number of spaces between *primitive functions* like `+` and `-` and their *arguments* doesn't matter: you can use as much or as little as you like. No spaces inside numbers, of course.

        2 × π
        9 ÷ 2
        ÷ ∞

Okay, now BQN looks like normal (grade-school) mathematics, which is sort of like looking normal. Pi (`π`) represents [that real famous number](https://en.wikipedia.org/wiki/Pi) and Infinity (`∞`) is part of the number system (the BQN spec allows an implementation to choose its number system, and all existing implementations use double-precision floats, like Javascript or Lua). In analogy with the one-argument form of Minus (`-`) giving the negation of a number, Divide (`÷`) with only one argument gives its reciprocal.

A number can be raised to the power of another with Power, written `⋆`. That's a star rather than an asterisk; BQN doesn't use the asterisk symbol. If it's called without a left argument, then `⋆` uses a base of [Euler's number](https://en.wikipedia.org/wiki/E_(mathematical_constant)) *e* and is called Exponential.

        2 ⋆ 3
        3 ⋆ 2
        ⋆ 1   # There's no constant for e but you can get it this way
        ⋆ 2.3

You could use Power to take square roots and *n*-th roots, but BQN also provides the primitive `√` for this purpose. If no left argument is provided, then it is the Square Root function; with a left argument it is called Root and raises the right argument to the power of one divided by the left argument.

        √ 2
        3 √ 27

On the BQN keyboard, the six functions just given are all typed with the `+` and `-` keys. To type the non-ASCII ones, use a backslash prefix. The three functions Plus, Times, and Power on the plus key are paired with their "reciprocal" versions Minus, Divide, and Square Root on the minus key.

    - +   # Ordinary keys
    ÷ ×   # \
    √ ⋆   # \ shift

In case you're wondering, Logarithm—the other inverse of Power—is written `⋆⁼`. We'll get to it in the section on modifiers.

## Compound expressions

It's sometimes useful to write programs with more than one function in them. Here is where BQN and any sort of normality part ways.

        2×3 - 5
        (2×3) - 5

I bet if you try hard you'll remember how much you hated learning to do exponentiation before multiplication and division before addition and subtraction. Didn't I tell you Earth was a confusing place? BQN treats all functions—not just primitives but the ones you'll define as well—the same way. They are evaluated from right to left, and parentheses can be used to group subexpressions that have to be evaluated before being used as arguments.

For a longer example, here's an expression for the [volume of a sphere](https://en.wikipedia.org/wiki/Sphere#Enclosed_volume) with radius 2.

        (4÷3) × π × 2⋆3

The evaluation order is shown below, with the function `⋆` on the first line evaluated first, then `×` on the next, and so on. The effect of the parentheses is that `÷` is evaluated before the leftmost `×`.

     =              2⋆3
                π ×
         4÷3
        (   ) ×

The following rule might help you to internalize this system in addition to identifying when parentheses are needed: an expression never needs to end with a parenthesis, or contain two closing parentheses in a row. If it does, at least one set of parentheses can be removed.

## One or two arguments?

What about functions without a left argument? Let's find an equation with lots of square roots in it… [looks good](https://en.wikipedia.org/wiki/Nested_radical#Denesting).

        √ 3 + 2 × √2
        1 + √2

They are the same, and now you can't say that BQN is the most complicated thing on this particular page! Just to make sure, we can find the difference by subtracting them, but we need to put the left argument in parentheses:

        (√3 + 2×√2) - 1+√2

But wait: how do we know that `√` in the expressions above uses the one-argument form? Remember that it can also take a left argument. For that matter, how do we know that `-` takes two arguments and not just one? Maybe this looks trivial now that we are just doing arithmetic, and a good enough answer for right now is that a function is called with one argument if there is nothing to its left, or another function, and with two arguments otherwise. But it gets more complicated as we expand the syntax with expressions that can return functions and so on, so it's never to early to start looking at a more rigorous viewpoint. In BQN, the way expressions are evaluated—the sequence of function calls and other operations—is determined by the *syntactic role* of the things it contains. A few rules of roles make sense of what's seen so far:

* *Numeric literals* such as `1` and `π` are *subjects*.
* *Primitive functions* are *functions* (gasp).
* A function's arguments are subjects. To call a function it must have a subject on the right, and may have a subject on the left, which is used as the left argument.
* A function's result is a subject—or, more precisely, a function call expression is a subject.
* A set of parentheses has the same role as whatever's inside it.

Perhaps more than you thought! To really get roles, it's important to understand that a role is properly a property of an expression, and not its value. In language implementation terms, roles are used only to parse expressions, giving a syntax tree, but don't dictate what values are possible when the tree is evaluated. So it's possible to have a function with a number role or a number with a function role. The reason this doesn't happen with the numeric literals and primitives we've introduced is that these tokens have a constant value. `×` or `∞` have the same value in any possible program, and so it makes sense that their types and roles should correspond. When we introduce identifiers, we'll see this correspondence break down—and why that's good!

## Character arithmetic

Gosh, that's a lot of arithmetic up there. Maybe adding characters will mix things up a bit? Hang on, you can't add characters, only subtract them… let's back up.

        'c'

A character is written with single quotes. As in the C language, it's not the same as a string, which is written with double quotes. There are no escapes for characters: any source code character between single quotes becomes a character literal, even a newline. Characters permit some kinds of arithmetic:

        'c' + 1
        'h' - 'a'

But as I blurted earlier, you can't add two characters (and **no** you can never concatenate things by adding them). It's also an error to negate a character or subtract it from a number. Characters reside in an \[intimidating word for simple concept warning\] [affine space](http://videocortex.io/2018/Affine-Space-Types/) \[no relation to those fancy Rust things called linear and affine types\], meaning that the following operations are allowed:
* Adding a number to a character gives a character
* Subtracting two characters gives a number.
Other examples of affine spaces are
* Points on a line (with no origin). You can move a point by a distance or find the distance between two points, but can't add points.
* Times in seconds. You can find the interval between two times or shift a time by some number of seconds, but adding two times together is nonsense.
* Pointers in a computer's memory. I'll let you verify for yourself that the rules are the same.

Want to shift an uppercase character to lowercase? Affine characters to the rescue:

        'K' + 'A'-'a'

Convert a character to a digit? Here you go:

        '4' - '0'

The one thing affine characters won't let you do is find some special "starting character": the main distinguishing factor between a linear and an affine space is that an affine space has no origin. However, for some kinds of programming finding a character's code point is important, so BQN also includes a special literal for the null character, written `@`:

        '*' - @
        @ + 97

It's a convenient way to write non-printing characters without having to include them in your source code: for example `@+10` is the newline character.

Addition and subtraction with affine characters have all the same algebraic properties that they do with numbers. One way to see this is to think of values as a combination of "characterness" (0 for numbers and 1 for characters) and either numeric value or code point. Addition and subtraction are done element-wise on these pairs of numbers, and are allowed if the result is a valid value, that is, its characterness is 0 or 1 and its value is a valid code point if the characterness is 1. However, because the space of values is no longer closed under addition and subtraction, certain rearrangements of valid computations might not be valid, because one of the values produced in the middle isn't legal.

## Modifiers

Functions are nice and all, but to really bring us into the space age BQN has a second level of function called *modifiers* (the space age in this case is when operators were introduced to APL in the early 60s—hey, did you know the [second APL conference](https://aplwiki.com/wiki/APL_conference#1970) was held at Goddard Space Flight Center?). While functions apply to subjects, modifiers can apply to functions *or* subjects, and return functions. For example, the 1-modifier `˜` modifies one function by swapping the arguments before calling it (Swap), or copying the right argument to the left if there's only one (Self).

        2 -˜ 'd'  # Subtract from
        +˜ 3  # Add to itself

This gives us two nice ways to square a value:

        ×˜ 4
        2 ⋆˜ 4

What's wrong with `4⋆2`? Depends on the context. Because of the way evaluation flows from right to left, it's usually best if the right argument to a function is the one that's being manipulated directly while the left argument is sort of a "control value" that describes how to manipulate it. That way several manipulations can be done in a row without any parentheses required. `⋆` can go either way, but if "squaring" is the operation being done then the *left* argument is one being squared, so it's the active value. The Swap modifier allows us to put it on the right instead.

Another 1-modifier is Undo (`⁼`). BQN has just enough computer algebra facilities to look like a tool for Neanderthals next to a real computer algebra system, and among them is the ability to invert some primitives. In general you can't be sure when Undo will work (it might even be undecidable), but the examples I'll give here are guaranteed by [the spec](../spec/inferred.md#undo) to always work in the same way. Starting with a *third* way to square a number:

        √⁼ 4

The most important use for Undo in arithmetic is the logarithm, written `⋆⁼`. That's all a logarithm is: it undoes the Power function! With no left argument `⋆⁼` is the natural logarithm. If there's a left argument then Undo considers it part of the function to be undone. The result in this case is that `⋆⁼` with two arguments is the logarithm of the right argument with base given by the left one.

        ⋆⁼ 10
        2 ⋆⁼ 32    # Log base 2
        2 ⋆ 2 ⋆⁼ 32
        10 ⋆⁼ 1e4  # Log base 10 of a number in scientific notation

Another 1-modifier, which at the moment is tremendously useless, is Constant `˙`. It turns its operand into a constant function that always returns the operand (inputs to modifiers are called *operands* because *modificands* is just too horrible).

        2 3˙ 4

Well, I guess it's not pedagogically useless, as it does demonstrate that a modifier can be applied to subjects as well as functions. Even though `3` is a subject, `3˙` is a function, and can be applied to and ignore the two arguments `2` and `4`.

With three examples you may have noticed that 1-modifiers tend to cluster at the top of the screen. In fact, every primitive 1-modifer is a superscript character: we've covered `˜⁼˙`, and the remaining array-based modifiers `` ˘¨⌜´˝` `` will show up later.
