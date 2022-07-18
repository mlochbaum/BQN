*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/tacit.html).*

# Tacit programming

[Tacit programming](https://aplwiki.com/wiki/Tacit_programming) (or "point-free" in some other languages) is a term for defining functions without referring to arguments directly, which in BQN means programming without [blocks](block.md). Instead, tacit programs are built up by combining smaller functions together; we'll discuss the ways BQN offers to combine functions on this page. Since primitive functions like those returning the left (`⊣`) and right (`⊢`) arguments, and selection functions (`⊏⊑`), are available as building blocks, tacit programming doesn't keep the programmer from pinpointing a specific part of the input, as the description might lead you to believe. Nonetheless, it has its limitations. In larger tacit programs, moving values to the right place is tedious and error-prone because of the lack of a convenient labelling mechanism, and important context tends to disappear in a sea of symbols.

In smaller amounts—portions of a line—tacit programming can be the clearest way to express an idea, particularly when just one or two variables are used a few times. Consider the following three expressions to filter only the positive values from a list:

        l ← 0‿5‿¯2‿1‿¯3‿¯4

        (0<l)/l
        {(0<𝕩)/𝕩} l
        0⊸<⊸/ l

The first of these expressions is the most direct, but with the variable name buried inside, it can't be used on an intermediate value—its input will have to be named. The other two forms stand alone as functions, so they can easily be placed anywhere in a program, even as an operand. But with even the small amount of structure added by a BQN anonymous function, the second method has more organization than action! The third, tacit, version strips away most of the organizing syntax to leave us with the essential pieces `0`, `<`, and `/` joined by combinators. The explicit function uses `𝕩` as a sort of pronoun ("I want the elements of it where it's greater than zero"), while the tacit one elides it ("give me the elements greater than zero").

The ability to easily combine tacit and "explicit" programming in blocks isn't only a way to mitigate the disadvantages of these two methods, but brings new advantages that no single paradigm could accomplish. Purely tacit programming *requires* programs to use *no* named local variables, but partly tacit programming *allows* them to use *fewer* names. That means names can be used only for the parts of a program that represent clean, human-understandable concepts. Another possible strategic choice is to use the fact that variables in a tacit expression are expanded as it's formed but those inside a block aren't. So `F←a⊸+` can be chosen to "freeze" the value of `a` in `F` without having to use an extra variable, while `F←{a+𝕩}` uses the current value of `a` each time `F` is called.

The rest of this page describes BQN's tacit programming facilities. Deciding when to use them is a matter of taste, and experience.

## Trains

In modern APL and its relatives, the backbone of tacit infrastructure is the *function train*. Trains can take some practice to understand and use well, so they're described in more depth on [a dedicated page](train.md). The idea of trains is that you can "apply" a function to other functions, forming a composed function where it will actually apply to their results. So a typical use is to [pair](pair.md) two functions as shown below: the pair `»‿«` is never formed, but the result of applying `T` is a pair.

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

Here's a table of all the typical tacit combinators for reference. The yellow lines show which values are passed to functions in order to evaluate each combinator: we start with values `𝕩` and maybe `𝕨` at the bottom, and the result is the single value that comes out at the top, after applying the functions.

<!--GEN combinator.bqn-->

Each of these combinators has its role to play in tacit code. To start with, [Constant](constant.md) (`˙`) is the subtlest one, because it's used everywhere, in a sense, but rarely needs to be made explicit. This is because data values already behave like constant functions. For example, the train `4+×` might more precisely be written `4˙+×`, but trains conveniently handle this part already. However, it *is* often used at the end of a train, to force the last part into a function role. `×-1` isn't a train—it just evaluates to ¯1. But `×-1˙` is the train that multiplies its arguments and subtracts 1.

Using [Self and Swap](swap.md) is pretty straightforward. Swap in particular is often useful if your arguments happen to be the wrong way around. For example, `⌊∘÷˜⋈|` gives you the integer part and remainder when dividing `𝕨` by `𝕩`. For compatibility with math, `÷` is "backwards" from a BQN perspective, but `˜` will fix that right up. And while we're at it, let's note that [Atop](compose.md#atop) is just another way to write a 2-train, so that `⌊∘÷˜` is `(⌊÷)˜` but avoids the parentheses.

        3 (⌊∘÷˜⋈|) 13  # 13 = 1+3×4

[Before and After](hook.md) are tacit powerhouses. Yes, `F⊸G` is just `F∘⊣G⊢` and `G⟜F` is `⊣G F∘⊢`. But the symmetric symbols make these cases a lot easier to read and manipulate as a programmer (just remember, pointy-side function is applied first!). It's common to write big tacit functions with the pattern `(…)⊸Fn 𝕩`, so a lot of processing is applied to `𝕩` and then the result of this is passed along with `𝕩` to `Fn`. And of course binds like `÷⟜2`, dividing by 2, or `¯1⊸»`, shifting in a ¯1, are very often helpful.

[Over](compose.md#over) is a bit weirder, and you'll have to learn when to recognize this pattern (of course, a repeated function is a strong hint). Perhaps you'd compare the first element of two lists with `≡○⊑`, for example.

## Conditionals

There are two main ways to perform conditional logic in tacit code. Although, a note first: for arithmetic, array operations that use booleans as numbers can often fill in for conditionals, and they're a lot faster. So, to replace every space character with a hyphen, try this function that multiplies the difference between those characters by a mask that's 1 where `𝕩` is a space, then subtracts that back from `𝕩`.

        " -" (⊢--´∘⊣×⊑⊸=) "ab cde  f "

The [Repeat](repeat.md) (`⍟`) modifier makes a nice "if" conditional. `F⍟G`, assuming the result of `G` is a boolean, is equivalent to `{𝕨G𝕩?𝕨F𝕩;𝕩}`. Note how `𝕨` gets passed in to both functions. Often you'll want `𝔽` to apply to `𝕩` only, and in this case, you need to make this explicit with `⊢` or similar.

        3 (2÷˜⊢)⍟< 7  # halve 𝕩 if greater than 𝕨

For more complicated "if-else" or "select" type conditionals, use [Choose](choose.md) (`◶`). Watch for ordering here: `F◶⟨G0,G1⟩` puts the two parts in the opposite order to Repeat, and list element 1 comes after element 0 even though it might seem more intuitive for the "true" value to come first.

## Valences

An ambivalent function is one that can take one or two arguments. Tacit code has a hot-and-cold kind of relationship with it. In cases that fit well with Atop, Over, and trains, it tends to work very well. In others, it might [not work](../commentary/problems.md#cant-always-transfer-ambivalence-in-tacit-code) at all. An example is the `{𝕨𝔽𝔾𝕩}` combinator: there's just no tacit equivalent. However, any ambivalent *function* can still be represented, because [Valences](valences.md) (`⊘`) combines a separate monadic and dyadic case.

When designing complex ambivalent functions, it's often best to mix tacit programming with blocks. I usually think of the block as the base for this, since `𝕨` tends to work with, and might put small tacit functions like `⊢⊘∾` inside, or tack on shared functionality such as `⌽∘…` on the outside.

## Example: combinations

As an example, we'll look at the following [combinations function](https://en.wikipedia.org/wiki/Binomial_coefficient) implementation from bqncrate (substituting the conventional `k` and `n` in for `i0` and `j0`):

    k(-÷○(×´)1⊸+)⟜↕˜n  # Number of unordered selections (combinations) of k items from n choices

This function takes the typical approach of multiplying numbers that start at `n` and go down, and dividing by numbers starting at `1` and going up. It's easier to understand from the BQN code, really:

        n←5 ⋄ k←3

        ⟨n-↕k, 1+↕k⟩

        (×´n-↕k) ÷ (×´1+↕k)

(The `3` can be eliminated by replacing `k` with `k⌊n-k`. Figuring out how to do that can be a tacit exercise for later?)

This says there are 10 ways to choose 3 out of 5 different options. Of course it's easy enough to make it into a function of `k` and `n`:

        k {(×´𝕩-↕𝕨)÷×´1+↕𝕨} n

But we are on the tacit page, so we'd like to make it tacit. For better or for worse. There's a mechanical way to do this for many functions, using only identity functions and trains, and making no simplifications. First parenthesize all monadic function calls, as these will become 2-trains. Then replace `𝕨` and `𝕩` with `⊣` and `⊢`, and add a `˙` to constants. For the number `1` the added `˙` isn't necessary unless it comes at the end of a train, but we include it here to show the principle.

    {(×´𝕩-↕𝕨)÷×´1+↕𝕨}

    {(×´𝕩-(↕𝕨))÷(×´1+(↕𝕨))}  # Parenthesize monadic functions

     (×´⊢-(↕⊣))÷(×´1˙+(↕⊣))   # 𝕨 to ⊣ and 𝕩 to ⊢

It's not pretty, but does give the same result.

        k ((×´⊢-(↕⊣))÷(×´1˙+(↕⊣))) n

This misses entirely the draw of tacit programming for this example, which is that it allows us to combine the repeated `↕` and `×´` functions—not that we can't do it in a block function, but it turns out to be more natural in tacit code. Here's a list of transformations that turn the block into *nice* tacit code, not just any tacit code.

    {(×´𝕩-↕𝕨)÷×´1+↕𝕨}

    ↕⊸{(×´𝕩-𝕨)÷×´1+𝕨}   # The ↕ is applied to every instance of 𝕨

    ↕⊸((×´⊢-⊣)÷(×´1+⊣)) # Mechanically transform to tacit

    ↕⊸((×´-˜)÷(×´1+⊣))  # ⊢-⊣ is -˜

    ↕⊸(-˜÷○(×´)1+⊣)     # Both arguments to ÷ have ×´ applied

    (-÷○(×´)1+⊢)⟜↕˜     # Move ˜ to the outside

The bqncrate version changes `1+⊢` to `1⊸+`, but otherwise matches the final line. As you can see, there are a few slightly different ways to write this function. This is a common situation. You might choose one version based on personal style, or which parts of the function you want to emphasize.

        k (-÷○(×´)1⊸+)⟜↕˜ n

A side effect of moving to tacit code is that the function is now defined in the monadic case, where it gave an error previously. It copies the left argument over to the right, and the number of ways to choose `n` items out of `n` is always `1`, so this is a pretty useless addition.

        {(×´𝕩-↕𝕨)÷×´1+↕𝕨} 10

        (-÷○(×´)1⊸+)⟜↕˜ 10

But it can confuse the reader, who might try to work out what the monadic case does before realizing this. So it's good practice to make sure the context indicates how many arguments a tacit function takes, because the function itself doesn't tell. This is also a reason to move to blocks with headers as functions get larger.
