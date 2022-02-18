*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/tacit.html).*

# Tacit (point-free) programming

[Tacit programming](https://en.wikipedia.org/wiki/Tacit_programming) ([APL Wiki](https://aplwiki.com/wiki/Tacit_programming)) is a general term used to refer to ways to define functions that don't refer to arguments directly (say, with identifiers). Instead, tacit programs are built up by combining smaller functions together; we'll discuss the ways BQN offers to combine functions on this page. Since primitive functions like those returning the left (`⊣`) and right (`⊢`) arguments, and selection functions (`⊏⊑`), are available as building blocks, tacit programming doesn't keep the programmer from pinpointing a specific part of the input, as the description might lead you to believe. Nonetheless, it has its limitations. In larger tacit programs, moving values to the right place is tedious and error-prone because of the lack of a convenient labelling mechanism, and important context tends to disappear in a sea of symbols.

In smaller amounts—portions of a line—tacit programming can be the clearest way to express an idea, particularly when just one or two variables are used a few times. Consider the following three expressions to filter only the positive values from a list:

        l ← 0‿5‿¯2‿1‿¯3‿¯4

        (0<l)/l
        {(0<𝕩)/𝕩} l
        0⊸<⊸/ l

The first of these expressions is the most direct, but with the variable name buried inside, it can't be used on an intermediate value and its input will have to be named. The other two forms stand alone as functions, so they can easily be placed anywhere in a program, even as an operand. But with even the small amount of structure added by a BQN anonymous function, the second method has more organization than action! The third, tacit, version strips away most of the organizing syntax to leave us with the essential pieces `0`, `<`, and `/` joined by combinators. The explicit function uses `𝕩` as a sort of pronoun ("I want the elements of it where it's greater than zero"), while the tacit one elides it ("give me the elements greater than zero").

The ability to easily combine tacit and "explicit" programming such as statements or anonymous functions, far from being only a way to mitigate the disadvantages of these two methods, brings new advantages that no single paradigm could accomplish. Purely tacit programming *requires* programs to use *no* local variable names, but partly tacit programming *allows* them to use *fewer* names. That means names can be used only for the parts of a program that represent clean, human-understandable concepts. Another possible strategic choice is to use the fact that variables in a tacit expression are expanded as it's formed but those inside a block aren't. So `F←a⊸+` can be chosen to "freeze" the value of `a` in `F` without having to use an extra variable, while `F←{a+𝕩}` uses the current value of `a` each time `F` is called.

The rest of this page describes BQN's tacit programming facilities. Deciding when to use them is a matter of taste, and experience.

## Trains

In modern APL and its relatives, the backbone of tacit infrastructure is the *function train*. Trains can take some practice to understand and use well, so they're described in more depth on [a dedicated page](train.md). The idea of trains is that you can "apply" a function to other functions, forming a composed function where it will actually apply to their results. So a typical use is to pair two functions as shown below: the pair `»‿«` is never formed, but the result of applying `T` is a pair.

        T ← » ⋈ «    # Pair both shift functions
        T            # Nothing happens yet...

        T "abc"      # Now it forms a pair

        'X' T "abc"  # Each shift gets both arguments

## Identity functions

If you use trains even a little you'll quickly find the need to get an argument without applying any function to it. Take the pattern `{(𝕨F𝕩)G𝕨}` for example. You might expect `⊸⟜` (discussed below) to handle this, but they don't: in those combinators, the first function to be applied always has one argument, but `F` here has two. Instead, a good way to fit this into a tacit form is to note that `𝕨⊣𝕩` is defined to be `𝕨`, and substitute backwards to give `{(𝕨F𝕩)G(𝕨⊣𝕩)}`, which now has the form of a train `F G ⊣`.

        "whatsin" {(𝕨∊𝕩)/𝕨} "intersect"

        "whatsin" (∊/⊣) "intersect"

The functions `⊣⊢` are as simple as they come, but are discussed quite a bit on [their own page](identity.md). A definition is that `⊢` is `{𝕩}` and `⊣` is `{𝕩;𝕨}`, so that `⊢` returns its right argument, and `⊣` returns its left argument but will settle for the right one if there's just one.

## Combinators

<!--GEN combinator.bqn-->
