*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/tacit.html).*

# Tacit (point-free) programming in BQN

[Tacit programming](https://en.wikipedia.org/wiki/Tacit_programming) ([APL Wiki](https://aplwiki.com/wiki/Tacit_programming)) is a general term used to refer to ways to define functions that don't refer to arguments directly (say, with identifiers). Instead, tacit programs are built up by combining smaller functions together; we'll discuss the ways BQN offers to combine functions on this page. Since primitive functions like those returning the left (`⊣`) and right (`⊢`) arguments, and selection functions (`⊏⊑`), are available as building blocks, tacit programming doesn't keep the programmer from pinpointing a specific part of the input, as the description might lead you to believe. Nonetheless, it has its limitations. In larger tacit programs, moving values to the right place is tedious and error-prone because of the lack of a convenient labelling mechanism, and important context tends to disappear in a sea of symbols.

In smaller amounts—portions of a line—tacit programming can be the clearest way to express an idea, particularly when just one or two variables are used a few times. Consider the following three expressions to filter only the positive values from a list:

        l ← 0‿5‿¯2‿1‿¯3‿¯4

        (0<l)/l
        {(0<𝕩)/𝕩} l
        0⊸<⊸/ l

The first of these expressions is the most direct, but with the variable name buried inside, it can't be used on an intermediate value and its input will have to be named. The other two forms stand alone as functions, so they can easily be placed anywhere in a program, even as an operand. But with even the small amount of structure added by a BQN anonymous function, the second method has more organization than action! The third, tacit, version strips away most of the organizing syntax to leave us with the essential pieces `0`, `<`, and `/` joined by combinators. The explicit function uses `𝕩` as a sort of pronoun ("I want the elements of it where it's greater than zero"), while the tacit one elides it ("give me the elements greater than zero").

The ability to easily combine tacit and "explicit" programming such as statements or anonymous functions, far from being only a way to mitigate the disadvantages of these two methods, brings new advantages that no single paradigm could accomplish. Purely tacit programming *requires* programs to use *no* local variable names, but partly tacit programming *allows* them to use *fewer* names. That means names can be used only for the parts of a program that represent clean, human-understandable concepts. Another possible stategic choice is to use the fact that variables in a tacit expression are expanded as it's formed but those inside a block aren't. So `F←a⊸+` can be chosen to "freeze" the value of `a` in `F` without having to use an extra variable, while `F←{a+𝕩}` uses the current value of `a` each time `F` is called.

The rest of this page describes BQN's tacit programming facilities. Deciding when to use them is a matter of taste, and experience.

## Identity functions

These are the simplest functions possible. `⊢𝕩` is `𝕩` and `⊣𝕩` is `𝕩`. `𝕨⊢𝕩` is `𝕩` and `𝕨⊣𝕩` is `𝕨`. `⊢` returns its right argument and `⊣` returns its left argument but will settle for the right one if there's just one. `⊢` is `{𝕩}` and `⊣` is `{𝕩;𝕨}`. We will use them quite frequently here and you can decide at the end whether it's really worth it to soak up two symbols just to do nothing. Not that you'll change *my* mind about it.

## Trains

In modern APL and its relatives, the backbone of tacit infrastructure is the *function train*. Trains can take some practice to understand and use well, so they're described in more depth on [a dedicated page](train.md).

Trains are closely related to the mathematical convention that, for example, two functions `F` and `G` can be added to get a new function `F+G` that applies as `(F+G)(x) = F(x)+G(x)`. In fact, with a little change to the syntax, we can do exactly this in BQN:

        (⊢+⌽) ↕5

So given a list of the first few natural numbers, that [*same*](#identity-functions) list *plus* its *reverse* gives a list of just one number repeated many times. I'm sure if I were [Gauss](https://en.wikipedia.org/wiki/Carl_Friedrich_Gauss#Anecdotes) I'd be able to find some clever use for that fact. The mathematical convention extends to any central operator and any number of function arguments, which in BQN means we use any three functions, and call the train with a left argument as well—the only numbers of arguments BQN syntax allows are 1 and 2.

        7 (+≍-) 2

Here [Couple](couple.md) (`≍`) is used to combine two units into a list, so we get seven plus and minus two. It's also possible to leave out the leftmost function of a train, or replace it with `·`. In this case the function on the right is called, then the other function is called on its result—it's identical to the mathematical composition `∘`, which is also part of BQN.

        (∾⌽) "ab"‿"cde"‿"f"
        (·∾⌽) "ab"‿"cde"‿"f"
        ∾∘⌽ "ab"‿"cde"‿"f"

The three functions `∾⌽`, `·∾⌽`, and `∾∘⌽` are completely identical. Why might we want **three** different ways to write the same thing? If we only want to define a function, there's hardly any difference. However, these three forms have different syntax, and might be easier or harder to use in different contexts. As we'll see, we can use `∾∘⌽` inside a train without parenthesizing it, and string `·∾⌽` but not `∾⌽` together with other trains. Let's look at how the train syntax extends to longer expressions.

## Combinators

<!--GEN combinator.bqn-->
