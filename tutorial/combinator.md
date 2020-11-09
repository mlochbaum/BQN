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

<!--GEN
Primitives ⟨
  "○%k%Over"
  "⊸%h%Before/Bind"
  "⟜%l%After/Bind"
⟩
-->
We've discussed Atop (`∘`), but hopefully you've intuited that it's not the end of the story as far as compositions go. In fact BQN has **three** more functions that could reasonably be interpreted as varieties of composition. Let's start by returning to a computation mentioned when we introduced Match (`≡`), that of testing whether two arrays have the same length.

        (≠"string") = ≠"sting"

This code, to a BQN programmer, should look offensive. The exact same function is called twice, even though an English description only mentions it once. Not to mention that the call on the left is far away from the rest of the expression and requires an extra set of parentheses. It's possible to factor out the repeated `≠` using Each and Reduce, but now the code is harder to read:

        =´≠¨ ⟨"string","sting"⟩

This is a very common pattern, and a sensible language should have a better way to handle it! BQN does, in the form of a 2-combinator called Over.

        "string" =○≠ "sting"

Let's use the list formation function Solo/Couple (`≍`) to see what happens more clearly:

        "string" ≍○≠ "sting"
        ≍○≠ "sting"

Atop always applies its right operand once, passing every argument (that is, one or two of them) in that call. Over calls its right operand on each argument individually. The results are the all used as arguments to the left operand. If there's only one argument, Atop and Over turn out to be the same: each calls the right operand, then the left, matching ordinary mathematical composition. Here are the two together for comparison.

<!--GEN
DrawComp ≍"∘○"
-->
