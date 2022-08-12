*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/overload.html).*

# Primitive overloading

The expression `3↕↕6` uses `↕` twice to do two completely different things ([Windows](../doc/windows.md) and [Range](../doc/range.md)). This is a [dark side](problems.md#incoherent-monad-dyad-builtin-pairs) of *overloading*, or the practice of stuffing one value with multiple meanings. Should a new array language use overloading? Should BQN have used it, for that matter?

The easy answer is to say it's better for BQN to use fewer special characters, so packing more meaning into them makes sense. If all the awkward pairs were split up, there wouldn't be room on the keyboard, requiring another modifier key or something (K, which sticks to ASCII and mostly uses one character per primitive, overloads primitives more often and in more ways). But mostly I didn't have any better ideas than using, say, `≠` for Length and `≢` for Shape. The number of nice symbols in Unicode is much smaller than you'd expect. In a language that isn't tied to Unicode symbols, such as one that uses mainly words or allows multi-character primitives, I'd definitely recommend splitting up primitives where the meanings don't fit together. [Klong](https://aplwiki.com/wiki/Klong) is a nice effort in this direction.

BQN does get rid of a fair amount of APL overloading. Every modifier is best described as one thing with an optional left argument, with some looseness for `˜⊸⟜`. The numerous [meanings](https://aplwiki.com/wiki/Dot) of `.` are reduced to two, the decimal in numbers and namespace field reference. The [function-operator](https://aplwiki.com/wiki/Function-operator_overloading) overloads `/⌿\⍀` are separated out. Parentheses aren't used for lists like in K or a Dyalog [proposal](https://aplwiki.com/wiki/Array_notation), which avoids inconvenience with 0- and 1-element lists.

But other things could be split up and aren't. The list below gives a few kinds of overloading: each presents the question of whether it should be considered one thing or two, which another language might answer differently.

- `⌽`: reverse versus rotate?
- `-`: negate versus subtract?
- `↕number` versus `↕list`?
- `↑`: one axis versus many?
- `/boolean` versus `/integer`?

Overloading is built deep into APL in a few ways. I think Iverson came to view packing more functionality into the same "space" as a fundamentally good thing; he developed this trend in papers published at I.P. Sharp, with J as the maximalist culmination. I think J should have cut back on new primitives and used the extra space given by its spelling system to draw connections, but it's packed with overloading instead, such as `+:` meaning double monadically and nand dyadically (the second meaning is obscure enough that I avoided it when writing J code). At the same time, when overloading is used well it can make primitives easier to remember and use. Let's start at the bottom of the list, with the most defensible form of overloading.

## Equivalent overloading

APL isn't really a "one obvious way to do it" in the sense that Python is, but it does follow a principle I'd describe as "one way is enough". That means that if APL already has a way to represent some data or a computation, it won't add another without a concrete benefit like shorter or faster code. This is why APL booleans are a kind of integer (I defend this decision [here](../tutorial/combinator.md#booleans)), and why it has one array datatype instead of various kinds of collection or a separate string type.

This means that something like the number 1 can mean many things, like an index or a count or a boolean, and the replicate function `/` might mean repeating or filtering. It's overloading, but it's a very consistent form because the mathematical description of what's going on in either case is the same. But it's not the only way—some statically-typed languages like Java and Haskell prefer to declare classes to split things up, so that the type system can check things for the user. An extreme example is a system that takes user input but needs to sanitize or escape it before passing it to certain functions. The APL way would be to represent both unsafe and safe input as strings, which is obviously dangerous.

However, the advantage of representing everything in a consistent format is that methods that work on one thing tend to work on many things. Want to reverse a string? It's just `⌽`. Defining boolean negation `¬𝕩` more generally as `1-𝕩` makes some arithmetic more obvious, for example `+´¬l` is `(≠l)-+´l`. And connections can be made at a higher level too: if you learn a rule like `a⊏b⊏c` ←→ `(a⊏b)⊏c`, that applies for every meaning of `⊏`. As long as `a` and `b` are flat arrays, that is, which highlights a conflict between this sort of compatible overloading and other sorts of extension.

## Extensions

Heading further into the woods, we see that the APL family extends functions in ways that don't follow strictly from the definition. Usually this happens within a single primitive. For example, First (monadic `⊑`) is only natural to apply to an array, since otherwise there's no first element. But it's defined to return an atom with no changes, effectively treating it as a unit array. This sort of implicit promotion is used just about everywhere it could be, since in all cases it's obvious what needs to be done and inconvenient to require explicit conversion.

If that was all, it would hardly be worth mentioning. A more significant family of extensions is the [use of depth](../doc/depth.md#testing-depth-for-multiple-axis-primitives) to allow a primitive to work on multiple axes in general but also to have a convenient one-axis form. Then there's [character arithmetic](../doc/arithmetic.md#character-arithmetic), allowing `'a' + 3`. In fact, isn't array arithmetic itself a big extension?

There are examples outside the array world that I find worse than anything in BQN. `+` for string catenation. This no longer obeys commutativity or distributivity: it's not safe to rearrange `a + b` to `b + a` or `(a+b)*c` to `(a*c)+(b*c)` in languages that do this! NumPy and MATLAB allow a boolean array to be used as an index, performing filtering. This one doesn't obey the rule that the length of `a[b]` is the length of `b`, or any other length-based rules really.

Sometimes what seems like an extension can be unified into a single more general primitive. For example, APL has [scalar extension](https://aplwiki.com/wiki/Scalar_extension) to allow you to add, say, a scalar to a list in `1 + 2‿3‿4`. J and BQN use the more general [leading axis agreement](../doc/leading.md#leading-axis-agreement), which has this extension as a special case (although incidentally, BQN removes some unprincipled extension of list-like functions like Reverse to rank-0 arguments). Character arithmetic can also be viewed in this way considering numbers and characters to be pairs of "characterness" 0 or 1, and a numeric value.

I think many primitive pairs, such as `-`, `⋆`, `«`, `⥊`, and `⍉`, fall into this category too. Primitives like can be described as a general dyadic function, and a monadic case that comes from a default left argument (sometimes dependent on the right argument: it's `(=𝕩)-1` for `⍉`). The primitive `⋈` is so tight it might be considered a fully compatible overload, returning a list of all arguments. Such primitive pairs can sometimes be used ambivalently in simple ways (`⋆⁼` is pretty nice), but more often the usefulness is just that it's easier to think about each pair as one thing rather than two. It's just two views of the same idea.

## Mnemonic overloading

Okay, we are slipping down the slope nicely, now what about the primitives where the two halves don't quite do the same thing? Take `∾` to start smoothly. The dyadic form joins two lists and the monadic form joins a list of lists. Well, this is really one function that takes its arguments in a slightly unusual way, since dyadic `∾` is `∾∘⋈`. The primitive `↑` for Prefixes/Take (`↓` too) is similar, but in a trickier way: if `𝕨` is between `0` and `≠𝕩`, `𝕨↑𝕩` is a prefix of `𝕩`. Then `↑` is the list of all these prefixes, so `𝕨⊑↑𝕩` is `𝕨↑𝕩`. It's almost a kind of partial application.

These primitives are easier to remember in the same way that it's much easier to memorize just `⊏` instead of a select function and a separate first-cell function. If I weren't allowed to overload them together, I probably just wouldn't include monadic `↑↓⊏` (or `√⋆`, even `-`?), and maybe not even dyadic `∾`.

In `/` and `⊔`, the monadic case is like the dyadic one but using indices (with the [minor issue](problems.md#monadic-argument-corresponds-to-left-for--and-) that `𝕨` swaps over to `𝕩`). Either form can be implemented in terms of the other. I still think of each of these primitives as a single concept, instead of two closely related ones.

And then we reach the cases that I think of as purely mnemonic, in that they the two cases are closely related, and it's useful to know this when programming, but neither one can be written in terms of the other. [Both meanings](../doc/order.md) of `⍋` use array ordering, and the connections between them run pretty deep (that might require another article to explore properly). A weaker example is `⌊`, which in both cases returns the greatest value smaller than or equal to any argument, but restricts the result to be an integer in the monadic case.

The examples are all primitive pairs now, and that's because BQN doesn't use mnemonic overloading within primitives (APL does occasionally, such as `○`, and J has a number of kitchen-sink primitives like `;.` and `p:`). And of course, there's a level after this where there's just no connection. BQN glyphs aren't chosen randomly, so the reason that this happens is that both functions are separately a fit for the glyph. But as I said at the beginning, in a language not tied to primitive glyphs there's no reason to do this.

Here's my list of how the primitives fit together. The table fits into rows, but there are no hard distinctions; I've tried to put the more coherent pairs of functions closer the the beginning of each row.

Tier       | Primitive pairs
-----------|-----------------
Unified    | `⋈≍˙˘¨⌜∘○⌾⊘◶⎉⚇⎊`
Compatible | ``-÷⋆√¬⊏⊑«»⍉⥊´˝`⁼⍟``
Similar    | `∾!/⊔⊣⊢↑↓˜⊸⟜`
Mnemonic   | `⍋⍒⊒⊐⌽∊⌊⌈`
Bad        | `+×\|∧∨<>≠=≡≢↕⍷`

## So?

Well, is overloading good or bad? All I can really say is that array languages depend on it a lot, although even then I don't know if it's more than C++ or Python.

A major difference in the way APL and friends do monadic-dyadic overloading is that it applies to values, not syntax. That is, in most languages an operator isn't a first-class value (it might be a wrapper for a function that is) and has to be called immediately. At this point the number of operands is known. So it's always possible to distinguish, say, subtraction and negation, from the immediately surrounding code. When `-` is a first-class value and you can write `Minus ← -`, this is no longer possible. This can be a challenge when reading some code, and it's a *big* barrier when translating code from one array language to another.

But the kinds of overloading other than primitive pairs *do* apply to other dynamic languages. After all, everyone knows you can't just translate Python to Ruby directly. If you have some NumPy code that does `a[b]` and want to translate it to BQN, you need to figure out whether `b` is a boolean array so you know whether to write `b⊏a` or `b/a`. In some cases you might need both. And this issue goes all the way up to the simplest forms of overloading like promoting atoms to unit arrays. There's no sensible way to get rid of *all* of those, is there? Or does a strong enough static type system fix the problem? Dunno. I'm still waiting on my big answers notation.
