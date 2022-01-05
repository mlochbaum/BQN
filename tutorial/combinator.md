*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/tutorial/combinator.html).*

# Tutorial: Combinators

BQN has a normal enough curly-brace syntax for functions and so on. I don't want to talk about it just yet. Before you get to thinking about how to write [FORTRAN in any language](http://www.pbm.com/~lindahl/real.programmers.html) in BQN, let's see if we can acquire some instincts about idiomatic BQN the way that only being stuck in a tightly restricted and horribly confining programming environment can accomplish.

There are benefits to being tightly restricted and horribly confined! In programming. I don't just mean that it forces you to learn new techniques like I said, I mean that using the restricted style we will learn is actually a better way to write portions of a program. This is because a restriction you apply in one part of a program is a promise you can rely on in the rest of the program. So what are we giving up, and what can we rely on in return?

*Tacit programming* does not use variables during the execution of a function (but you might use them for convenience in order to *construct* a tacit program). Variables allow you to use any accessible value in the program with the same level of ease. Tacit code doesn't. In fact it becomes pretty unusable when more than about three values are active at once. One consequence is that tacit code won't cause confusion by modifying far-away variables. But something unique to the tacit paradigm is that when only a small number of values are active—which is always true in a small enough portion of a program!—it has more powerful ways to describe the way these values flow through the program. The main way it achieves this is with combinators.

## What's a combinator?

(It's when you can't stop adding suffixes to "combine"). In the first tutorial, we briefly presented three *combinators*, `∘`, `˜`, and `˙`. These are functions or modifiers that produce a result from their inputs (arguments or operands) only by applying functions to arguments. For example, let's look at a composition:

        |∘- 6

This composition starts with the three values `|`, `-`, and `6`. To produce its result, it first applies `-` to `6`, giving `¯6`, a new value that it's free to use later. Then it applies `|` to `¯6`, giving `6` again. Bit of a waste.

In BQN's combinators, the result of a function application is never used as a function itself. This allows us to use a graphic like the one below to represent a combinator. In each graph, function applications are illustrated with the name of the function linked by yellow lines to its arguments below (this is the same view as the expression diagrams we've been using, flipped upside down and cleaned up a little).

<!--GEN ../doc/combinator.bqn
DrawComp ≍"∘"
-->

The expression `|∘- 6` matches `𝔽∘𝔾 𝕩` on the left: to evaluate we would start with `𝕩`, which is `6`, at the bottom, then apply `𝔾` or `-`, then `𝔽` or `|`. However, we can see at the right that `|∘-` might also be called with two arguments: in this case it is `𝔾` or `-` at the bottom that receives both arguments.

        7 |∘- 9

So `|∘-` is the absolute difference: a useful function for a change! If we have two points represented as lists of numbers, we can go further: the *sum* of absolute differences is the [Manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry) between them.

        14‿8 |∘- 19‿6
        14‿8 +´∘|∘- 19‿6

This means that if you are at 14th and 8th, and want to get to 19th and 6th, or vice-versa, you must walk at least seven blocks total: five to get from 14th to 19th and two from 8th to 6th, not necessarily in that order. The function `+´∘|∘-` actually uses both cases of `∘`: the one-argument case for `+´∘|`, and the two argument case for the `∘-` part.

<!--GEN prim.bqn
Primitives ⟨
  "˜%`%Self%Swap"
  "˙%""%Constant"
  "∘%j%Atop"
⟩
-->
We've seen three combinators so far: Atop (`∘`), Self/Swap (`˜`), and Constant (`˙`). The 1-modifiers are much simpler than Atop, as they only have a single function to call, and Constant never even calls it! Other 1-modifier combinators are possible—for example one that calls its operand twice—but not particularly useful (the Repeat modifier `⍟` is much more general). For that matter, I still haven't explained why Constant is useful. I'll admit, it was added a lot later than the other combinators. We'll get to it, though.

<!--GEN
DrawComp ≍"∘˜˙"
-->

## Comparisons

<!--GEN
Primitives ⟨
  "<%%%Less Than"
  ">%%%Greater Than"
  "≠%/%Length%Not Equals"
  "=%%Rank%Equals"
  "≤%<%%Less Than or Equal to"
  "≥%>%%Greater Than or Equal to"
⟩
-->
Before we go further, let's introduce some new functions that we might like to use with combinators. BQN includes the full mathematical suite of [comparisons](https://en.wikipedia.org/wiki/Inequality_(mathematics)), with their standard widely-known Unicode symbols. It's surprising how much having the proper symbols instead of digraphs like `!=` or `>=` improves readability!

The comparisons are functions like any other—specifically, they are all two-argument functions, and the same symbol with only one argument might mean something else. Given two numbers or characters, they return `1` if these arguments compare in the specified way and `0` if they don't: for example, `<` returns `1` when the left argument is strictly less than the right and `>` returns `1` if the right is strictly less than the left. Characters are always considered to be greater than numbers, as though a larger "characterness" counts for more than any number.

        3 < 4
        4 > ∞
        ∞ < @

### Booleans

The return values `0` and `1` are natural choices because BQN has no dedicated boolean type: instead, in BQN, the word *boolean* indicates a number that's 0 or 1, much like "natural number" selects a subset of the possible numbers. This is a choice that might be at odds with your own programming experience, and especially clashes with the world of typed functional programming, where even using the boolean type rather than a dedicated type for an option might be considered a code smell! The design principle guiding this decision, and most of BQN's type system, is that there should only be one type that accomplishes any given programming task. Any distinctions that it has are there because they are really necessary: conflating numbers and characters would make working with strings too difficult, and functions can't really be combined with modifiers because one-argument functions and 1-modifiers take their inputs on different sides.

The advantage of this strategy is that you will spend much less time thinking about types when writing programs. The decisions are already made: if there are a few things, they go in a list; if there a few possible values in a qualitative category then they should be labelled with numbers. And if some value has multiple interpretations then BQN is less likely to require an explicit conversion between these. For example, while the result of `=` might be taking to say *whether* two atoms have equal values, maybe it also says *how many times* the atom on the left appears in the right argument—which is at most one, because there's only one right argument. A silly distinction, or is it? An important property of counts is that we can add them together, for instance, to find how many times the letter "e" appears in a string.

        'e' = "George Boole"

        +´ 'e' = "George Boole"

        'e' +´∘= "George Boole"  # With a combinator

This, a well-typed and well-spoken programmer should declare, is an outrage! The purpose of types is to *protect* us from applying functions to types they're not intended for, because the most likely result is that such an application doesn't make sense. Static types provide a valuable service by catching these dangerous actions at compile time and allowing a programmer to prove that they never happen. Well… this is all true. BQN chooses not to pay the type price of this service and so doesn't get the type protection. And it helps that it's consistent about this choice, so you know that BQN's types are never the answer to these sorts of safety concerns. You will have to find a different way to avoid type errors: perhaps just programming carefully in a small or one-off program, and testing and code review or even external tools in a large one. All that said, I think programmers from outside the array programming world (and even many inside!) drastically underestimate how often a boolean value is really just a narrow-minded take on a counting number.

### Comparing whole arrays

<!--GEN
Primitives ⟨
  "≡%m%Depth%Match"
  "≢%M%%Not Match"
⟩
-->
Programmers not as inclined to grandiose philosophical discursions will note from the example above that `=` is a pervasive function, like arithmetic functions such as `+` and `⋆`. This can be useful, as that example shows, but it's difficult to use `=` to check whether, for example, two lists are the same. For equal-length lists we might compare element-wise and then multiply the results together (giving `0` if the resulting list contained a `0`):

        "abcd" ×´∘= "abdd"

For arbitrary values it's harder: we need to know whether the arguments are atoms or lists, and whether they have the same length, and what happens if some of their *elements* are lists? To avoid all this trouble, the function Match (`≡`) tests whether its arguments are identical, returning `1` if they are and `0` if they aren't—always an atomic return value and never a list.

        "abcd" ≡ "abdd"
        "abc"‿"de" ≡ "abc"‿"de"

In analogy with Not Equals (`≠`) testing whether two atoms are different, Not Match (`≢`) tests whether two arbitrary values differ.

        2‿3‿4‿2 ≠ 3‿3‿2‿2
        2‿3‿4‿2 ≢ 3‿3‿2‿2

## Length, rank, and depth

I said above that the comparison functions might have a different meaning when called with only one argument, so let's cover a few of these.

Length (`≠`) gives the number of elements in a list. For atoms it returns 1; it can't result in an error.

        ≠ "testing"
        ≠ ⟨⟩
        ≠ ⟨ π, ∘, "element" ⋄ ⟨'l',1,5,'t'⟩ ⟩
        ≠ 4

Rank (`=`) returns `0` when called on an atom and `1` when called on a list. I'm **absolutely sure** this boolean result is not just a narrow-minded take on a counting number. But don't assume that every value with rank 0 is an atom.

        = 0.5
        = ↕3
        = 'a'
        = "a"

Depth (`≡`) gives the recursive nesting depth of its argument: the greatest number of times you can take an element before reaching an atom. That is, for an atom, it's 0, but for a list, it's one more than the highest depth of any element.

        ≡ "dream"                  # An ordinary dream
        ≡ "d"‿"r"‿"e"‿"a"‿"m"      # What if the letters were strings?
        ≡ ⟨ "d"‿"r"‿"e"‿"a"‿"m" ⟩  # We have to go deeper

You probably won't end up using Depth too much. The data in a typical program has a fixed, known depth, so there's no point in asking BQN what it is. But it might be useful if you want to write a utility function that's flexible about its input. `0<≡a` is the idiomatic way to test whether `a` is an array.

## Composition

We've discussed Atop (`∘`), but hopefully you've intuited that it's not the end of the story as far as compositions go. In fact BQN has **three** more modifiers that could reasonably be interpreted as varieties of composition.

### Over

<!--GEN
Primitives ⟨
  "○%k%Over"
⟩
-->
Let's start by returning to a computation mentioned when we introduced Match (`≡`), that of testing whether two arrays have the same length.

        (≠"string") = ≠"sting"

This code, to a BQN programmer, should look offensive. The exact same function is called twice, even though an English description only mentions it once. Not to mention that the call on the left is far away from the rest of the expression and requires an extra set of parentheses. It's possible to factor out the repeated `≠` using Each and Reduce, but now the code is harder to read:

        =´≠¨ ⟨"string","sting"⟩

This is a very common pattern, and a sensible language should have a better way to handle it! BQN does, in the form of a 2-modifier called Over.

        "string" =○≠ "sting"

Let's use the list formation function Enlist/Pair (`⋈`) to see what happens more clearly:

        "string" ⋈○≠ "sting"
        ⋈○≠ "sting"

Atop always applies its right operand once, passing every argument (that is, one or two of them) in that call. Over calls its right operand on each argument individually. The results are then all used as arguments to the left operand. If there's only one argument, Atop and Over turn out to be the same: both of them call the right operand, then the left, like ordinary mathematical composition. Here are the two together for comparison.

<!--GEN
DrawComp ≍"∘○"
-->

### Before and After

Atop (`∘`) and Over (`○`) are both symmetric in some sense: with two arguments, `(F∘G)˜` is `F∘(G˜)`, and `(F○G)˜` is `(F˜)○G`. Put another way, reversing the order of arguments to Atop or Over as a whole is the same as reversing the order of every two-argument function inside—`G` for `F∘G` and `F` for `F○G`. If it's not obvious why this is the case, work it out for yourself by walking through how these functions would apply to their arguments! This causes their diagrams to be symmetric as well. Swap (`˜`) also has a symmetric diagram, and it's very easy to show that it's symmetric: take a look at `(F˜)˜` and `(F˜)˜`. In both cases I started with `F˜`, but in one case I applied `˜` to the entire function and in the other I applied it on the inside, to `F` only. And I won't tell you which is which.

<!--GEN
Primitives ⟨
  "⊸%h%Before/Bind"
  "⟜%l%After/Bind"
⟩
-->
Sometimes we'd like to handle the arguments differently, so BQN has a pair of 2-modifiers to apply a function to one argument only: Before (`⊸`) and After (`⟜`). Each is written with a circle for composition (remember, every 2-modifier has a circle in it!), with a line pointing to the function that takes only one argument. Here's how that works with some example functions and arguments.

After     | Before
----------|------------
`2 ⋆⟜- 3` | `2  ⋆⊸-  3`
`2 ⋆ - 3` | `(⋆ 2) - 3`

The order of application matches the way the two modifiers' names are pronounced in English. `⋆⟜-` is "Power After Negation", so that it negates `3` first, then raises `2` to that power. `⋆⊸-` is "Exponent Before Subtracting", so it takes the natural exponent of `2` first, and then subtracts `3`. After doesn't need parentheses when it's expanded to a full phrase, so you might think of it as the more "natural" of the two.

        2 ⋆⟜- 3
        2 ⋆⊸- 3

Despite this, I tend to use `⊸` a little more than `⟜`. As one example, remember that Rotate (`⌽`) rotates its right argument to the left by an amount given by the left argument. But a negative left argument goes in the opposite direction, so `-⊸⌽` is a compact way to write the "opposite rotate".

        4 -⊸⌽ " before"  # Rotate to the right by four
        4 ⌽⁼  " before"  # Okay this time Undo is better

Here are the diagrams for Before and After: as promised, they're not symmetrical. The function on the circle side of the symbol always goes on top, since it's the one that takes two arguments. If you find these diagrams to be a helpful way to visualize things, you might picture picking up the expression at the ring to drag that function up and away from the rest of the expression.

<!--GEN
DrawComp ≍"⊸⟜"
-->

What about the one-argument case? The structure of application is exactly the same, except that there's only one argument available, so it's used in both input positions. If I describe it that way, it sounds like lazy design, but the ability to use one argument in two ways makes the one-argument versions of Before and After even more useful than the two-argument ones. For example, consider the function `y = x×(1-x)`, which gives a parabola that's equal to 0 at 0 and 1, and peaks between them when x is 0.5. The function Not (`¬`, which we'll discuss in a later tutorial) is defined so that `¬x` is `1-x`, which conveniently allows us to write this function as either `¬⊸×` or `×⟜¬`.

        ¬⊸× 0.5

What if we want to call it on eight equally-spaced numbers between 0 and 1? Well, `↕8` gives us eight equally-spaced numbers, but to rescale them we'd want to divide by `8`. That's `(↕8)÷8`, but it's nicer to use Before again.

        ↕⊸÷ 8

        ¬⊸× ↕⊸÷ 8

Our list of arguments stops before reaching 1, because `↕8` doesn't include `8`. If we wanted a list from 0 to 1 *inclusive*, we'd need to divide by `7` (that is, `8-1`) instead of `8`. We can do this as well! But first we need to understand some other ways to apply Before and After.

#### Bind

We showed in the first tutorial that a modifier's operand doesn't have to be a function, but can also be a data value. That hasn't come up yet, except for a cryptic use of "Bind" (`⊸`?) in the function `(⌽2⋆↕8)⊸×¨` from the last tutorial. How does that work? Some kind of secret identity for Before and After?

        1⊸+ 5
        +⟜1 5

Nope, just the regular identity, plus the fact that BQN allows data values to be applied as functions. Specifically, *constant* functions, that ignore the arguments and just return themselves. For a simpler example, let's use `˜` (but remember that BQN has a dedicated constant modifier `˙` which is better to use if you're trying to define a constant function since it will also work on function or modifier operands).

        "const"˜ 5
        @ "const"˜ 6

The modifier `˜` applies its operand function to the arguments, after swapping them around or whatever. In this case, the operand function is a data type (not a function or modifier), so it ignores those arguments! Our "Bind" modifiers work the same way: for example, `1⊸+ 5` is `(1 5)+5`, or it would be if `1` were a function. Applying `1` to `5` gives `1`, so the final result is `1+5` or `6`.

To use Bind, you have to remember that the line points towards the constant value. Otherwise the constant will be applied last, and it'll return itself as the final result regardless of what you did before.

        +⊸1 5

Here's another way to look at splitting up an expression with Bind: to split up `2⋆5` we can either Bind 2 Before Power, or Bind 5 After Power. Which one to use depends on the situation.

Before  |         | After
--------|---------|--------
`2⊸⋆ 5` | `2 ⋆ 5` | `⋆⟜5 2`

Back to our unsatisfactory list of numbers. We have the first, but we want the second.

        ↕⊸÷ 8
        (↕8) ÷ 7

What function turns 8 into 7? We can bind `1` to `-` on the left:

        -⟜1 8

Now we need to apply `↕` *and* this function to `8`, dividing the results. It turns out we can do this using both Before and After. On one side we'll have `↕8`, and on the other `-⟜1 8`.

        ↕⊸÷⟜(-⟜1) 8

This structure—Before on the left, After on the right—is also useful with two arguments: I call it "split compose", and it applies one function to the left argument and another to the right before passing them both to the middle function (if the functions on both sides are the same, that would be Over!). Although it turns out it's not needed in the one-argument case. You'll get the same result just by jamming the functions together. This is called a "train" and we should probably leave it for another tutorial before going too far off the rails.

        (↕÷-⟜1) 8

## Base decoding continued

We're speeding up a bit now, so in the examples below it might take some time for you to break down what I did and why. Remember that you can open any expression in the REPL in order to change parts of it or view the syntax. And don't get discouraged just because of how long it takes to understand a line of code! First, you'll surely get faster in fitting the pieces together. Second, a line of BQN often has more code in it than a line in other languages, because primitives have such short names. Think about how much *functionality* you can read and understand rather than how few *lines* you get through.

In the last tutorial I [went over](list.md#example-base-decoding) a way to decode a list of strings containing binary codes for ASCII characters:

        @ + +´¨ (⌽2⋆↕8)⊸×¨ '0' -˜ "01000010"‿"01010001"‿"01001110"

Now that we know our combinators, we can do a bit more work on this code. First, we can rather mechanically turn it into a standalone function (fit to be passed as an operand, or given a name, if we knew how to give things names). Just bind each left argument to the corresponding function, and then join all the functions with `∘`.

        @⊸+ +´¨ (⌽2⋆↕8)⊸×¨ -⟜'0' "01000010"‿"01010001"‿"01001110"

        (@⊸+)∘(+´¨)∘((⌽2⋆↕8)⊸×¨)∘(-⟜'0') "01000010"‿"01010001"‿"01001110"

We might clean up a little by combining the functions that use `¨`. Here `+´` doesn't need parentheses because it comes at the left of a group of modifiers. For that matter, neither does `@⊸+`.

        @⊸+∘(+´∘((⌽2⋆↕8)⊸×)¨)∘(-⟜'0') "01000010"‿"01010001"‿"01001110"

Because `×` is commutative, the argument `(⌽2⋆↕8)` can be placed on either side. While I usually default to Before, in this case moving it to the right lets us remove a set of parentheses and use the dot product `+´∘×`, a nice combination.

        @⊸+∘(+´∘×⟜(⌽2⋆↕8)¨)∘(-⟜'0') "01000010"‿"01010001"‿"01001110"

There's another algorithm ([Horner's rule](https://en.wikipedia.org/wiki/Horner%27s_method)) that gives us somewhat simpler code. The idea is that instead of multiplying a number by its place value, we split the number into its lowest digit, and the rest. In base 10, for example, we might have `1234 = (123×10)+4`. After performing that expansion three more times, we have:

        (((((1×10)+2)×10)+3)×10)+4
        ((1×⟜10⊸+2)×⟜10⊸+3)×⟜10⊸+4   # Make the combining step a function
        4+⟜(10⊸×)3+⟜(10⊸×)2+⟜(10⊸×)1 # Flip the combining function around
        +⟜(10⊸×)´ 4‿3‿2‿1            # Now it's a BQN fold
        +⟜(10⊸×)´ ⌽ 1‿2‿3‿4          # To fold in reverse, reverse then fold

(Why does `+⟜(10⊸×)` need parentheses when `×⟜10⊸+` doesn't? Why doesn't the reversed expression have outer parentheses?). Changing this from base 10 to base 2 is pretty simple (although a character-counter might not stop until reaching the less obvious function `+˜⊸+˜´∘⌽`).

        +´∘×⟜(⌽2⋆↕8) "01010001"-'0'
        +⟜(2⊸×)´∘⌽ "01010001"-'0'

Plugging that back in, we have another base-decoding function:

        @⊸+∘(+⟜(2⊸×)´∘⌽¨)∘(-⟜'0') "01000010"‿"01010001"‿"01001110"

With the still-mysterious trains, this function could even be cleaned up more, removing the clutter of `∘`s and `()`s that makes it hard to focus on what one part of the function is doing:

        (@+ ·+⟜(2⊸×)´∘⌽¨ -⟜'0') "01000010"‿"01010001"‿"01001110"

## Summary

BQN has a full complement of comparison functions, which are pervasive (work on atoms only) like arithmetic functions. The non-pervasive functions Match (`≡`) and Not Match (`≢`) compare entire arrays. Comparison functions return `1` if the comparison holds and `0` if it doesn't; these two numbers make up the "booleans".

Glyph | 1 arg                     | 2 args
------|---------------------------|--------
`<`   |                           | [Less Than](../doc/arithmetic.md#comparisons)
`>`   |                           | [Greater Than](../doc/arithmetic.md#comparisons)
`≠`   | [Length](../doc/shape.md) | [Not Equals](../doc/arithmetic.md#comparisons)
`=`   | [Rank](../doc/shape.md)   | [Equals](../doc/arithmetic.md#comparisons)
`≤`   |                           | [Less Than or Equal to](../doc/arithmetic.md#comparisons)
`≥`   |                           | [Greater Than or Equal to](../doc/arithmetic.md#comparisons)
`≡`   | [Depth](../doc/depth.md)  | [Match](../doc/match.md)
`≢`   |                           | [Not Match](../doc/match.md)

A combinator is a function or modifier that produces its result from its inputs purely by applying functions to arguments, without introducing any external values. BQN's combinators can all be described with diagrams showing how arguments are passed through operands, with the result emerging at the top. The diagrams below define six combinators in BQN.

<!--GEN
DrawComp "∘˜˙"≍"○⊸⟜"
-->

A data value (number, character, or array) can be applied as a function, in which case it ignores any arguments and returns itself. In particular, using a data value as the left operand of Before or the right operand of After is called Bind because it attaches that data value as an argument to the other operand.

This section was a bit long because combinators are conceptually difficult, but as you can see we didn't cover all that much material (and our diagrams *fully* define the combinators in question, which is unusual in a summary!). The tacit style we've used here can be very confusing or uncomfortable at first, maybe *because* it's so radically simple. We'll keep working with it in future tutorials, and it should start to feel more solid and logical. Even if not, that's okay! As I said, BQN has a more explicit function style as well, and it's completely possible to program without ever using a combinator. But perhaps you'll find that a well-placed Over or Bind can make things a lot smoother.
