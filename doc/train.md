*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/train.html).*

# Function trains

Trains are an important aspect of BQN's [tacit](tacit.md) programming capabilities. In fact, a crucial one: with trains and the [identity functions](identity.md) Left (`⊣`) and Right (`⊢`), a fully tacit program can express any explicit function whose body is a statement with `𝕨` and `𝕩` used only as arguments (that is, there are no assignments and `𝕨` and `𝕩` are not used in operands or lists. Functions with assignments may have too many variables active at once to be directly translated but can be emulated by constructing lists. But it's probably a bad idea). Without trains it isn't possible to have two different functions that each use both arguments to a dyadic function. With trains it's perfectly natural.

BQN's trains are the same as those of Dyalog APL, except that Dyalog is missing the minor convenience of BQN's [Nothing](expression.md#nothing) (`·`). There are many Dyalog-based documents and videos on trains you can view on the [APL Wiki](https://aplwiki.com/wiki/Train).

## 2-train, 3-train

Trains are an adaptation of the mathematical convention that, for example, two functions `F` and `G` can be added to get a new function `F+G` that applies as `(F+G)(x) = F(x)+G(x)`. With a little change to the syntax, we can do exactly this in BQN:

        (⊢+⌽) ↕5

So given a list of the first few natural numbers, that *same* list *plus* its *reverse* gives a list of just one number repeated many times. I'm sure if I were [Gauss](https://en.wikipedia.org/wiki/Carl_Friedrich_Gauss#Anecdotes) I'd be able to find some clever use for that fact. The mathematical convention extends to any central operator and any number of function arguments, which in BQN means we use any three functions, and call the train with a left argument as well—the only numbers of arguments BQN syntax allows are 1 and 2.

        7 (+≍-) 2

Here [Couple](couple.md) (`≍`) is used to combine two units into a list, so we get seven plus and minus two. It's also possible to leave out the leftmost function of a train, or replace it with `·`. In this case the function on the right is called, then the other function is called on its result—it's identical to the mathematical composition `∘`, which is also part of BQN.

        (∾⌽) "ab"‿"cde"‿"f"
        (·∾⌽) "ab"‿"cde"‿"f"
        ∾∘⌽ "ab"‿"cde"‿"f"

The three functions `∾⌽`, `·∾⌽`, and `∾∘⌽` are completely identical: [Join](join.md#join) of [Reverse](reverse.md). Why might we want **three** different ways to write the same thing? If we only want to define a function, there's hardly any difference. However, these three forms have different syntax, and might be easier or harder to use in different contexts. As we'll see, we can use `∾∘⌽` inside a train without parenthesizing it, and string `·∾⌽` but not `∾⌽` together with other trains. Let's look at how the train syntax extends to longer expressions.

## Longer trains

Function application in trains, as in other contexts, shares the lowest precedence level with assignment. Modifiers and strands (with `‿`) have higher precedence, so they are applied before forming any trains. Once this is done, an expression is a *subject expression* if it ends with a subject and a *function expression* if it ends with a function (there are also modifier expressions, which aren't relevant here). A train is any function expression with multiple functions or subjects in it: while we've seen examples with two or three functions, any number are allowed.

Subject expressions are the domain of "old-school" APL, and just apply one function after another to a subject, possibly assigning some of the results (that's the top-level picture—anything can still happen within parentheses). Subjects other than the first appear only as left arguments to functions, which means that two subjects can't appear next to each other because the one on the left would have no corresponding function. Here's an example from the compiler (at one point), with functions and assignments numbered in the order they are applied and their arguments marked with `«»`, and a fully-parenthesized version shown below.

    cn←pi∾lt←/𝕩≥ci←vi+nv
     «6 «5 «43«2 «1 «0»

    cn←(pi∾(lt←(/(𝕩≥(ci←(vi+nv))))))

Function expressions have related but different rules, driven by the central principle that functions can be used as "arguments". Because roles can no longer be used to distinguish functions from their arguments, every function is assumed to have two arguments unless there's nothing to the left of it, or an assignment. In trains, assignments can't appear in the middle, only at the left side after all the functions have been applied. Here's another example from the compiler. Remember that for our purposes `` ⌈` `` behaves as a single component.

    ⊢>¯1»⌈`
    «1 «0»

    ⊢>(¯1»⌈`)

In a train, arguments alternate strictly with combining functions between them. Arguments can be either functions or subjects, except for the rightmost one, which has to be a function to indicate that the expression is a train. Trains tend to be shorter than subject expressions partly because to keep track of this alternation in a train of all functions, you need to know where each function is relative to the end of the train (subjects like the `¯1` above only occur as left arguments, so they can also serve as anchors).

## Practice training

The train `` ⊢>¯1»⌈` `` is actually a nice trick to get the result of [Mark Firsts](selfcmp.md#mark-firsts) `∊𝕩` given the result of [Classify](selfcmp.md#classify) `⊐𝕩`, without doing another search. Let's take a closer look, first by applying it mechanically. To do this, we apply each "argument" to the train's argument, and then combine them with the combining functions.

    (⊢ > ¯1 » ⌈`) 𝕩
    (⊢𝕩) > (¯1) » (⌈`𝕩)
    𝕩 > ¯1 » ⌈`𝕩

So—although not all trains simplify so much—this confusing train is just `` {𝕩>¯1»⌈`𝕩} ``! Why would I write it in such an obtuse way? To someone used to working with trains, the function `` (⊢>¯1»⌈`) `` isn't any more complicated to read: `⊢` in an argument position of a train just means `𝕩` while `` ⌈` `` will be applied to the arguments. Using the train just means slightly shorter code and two fewer `𝕩`s to trip over.

This function's argument is Classify (`⊐`) of some list (in fact this technique also works on the [index-of](search.md#index-of)-self `𝕩⊐𝕩`). Classify moves along its argument, giving each major cell a number: the first unused natural number if that value hasn't been seen yet, and otherwise the number chosen when it was first seen. It can be implemented as `⍷⊐⊢`, another train!

        ⊢ sc ← ⊐ "tacittrains"

Each `'t'` is `0`, each `'a'` is `1`, and so on. We'd like to discard some of the information from Classify, to just find whether each major cell had a new value. Here are the input and desired result:

        sc ≍ ∊ "tacittrains"

The result should be `1` when a new number appears, higher than all the previous numbers. To do this, we first find the highest previous number by taking the [maximum](arithmetic.md#additional-arithmetic)-[scan](scan.md) `` ⌈` `` of the argument, then [shifting](shift.md) to move the previous maximum to the current position. The first cell is always new, so we shift in a `¯1`, so it will be less than any element of the argument.

        ¯1 » ⌈`sc
        (¯1»⌈`) sc

Now we compare the original list with the list of previous-maximums.

        sc > ¯1»⌈`sc
        (⊢>¯1»⌈`) sc

## Composing trains

The example above uses a train with five functions: an odd number. Trains with an odd length are always composed of length-3 trains, and they themselves are composed the same way as subject expressions: an odd-length train can be placed in the last position of another train without parentheses, but it needs parentheses to go in any other position.

But we also saw the length-2 train `∾⌽` above. Even-length trains consist of a single function (`∾`) applied to a function or odd-length train (`⌽`); another perspective is that an even-length train is an odd-length train where the left argument of the final (leftmost) function is left out, so it's called with only a right argument. An even-length train *always* needs parentheses if it's used as one of the functions in another train. However, it can also be turned into an odd-length train by placing `·` at the left, making the implicit missing argument explicit. After this it can be used at the end of an odd-length train without parentheses. To get some intuition for even-length trains, let's look at an example of three functions used together: the [unique](selfcmp.md#deduplicate) (`⍷`) [sorted](order.md#sort) (`∧`) [absolute values](arithmetic.md#additional-arithmetic) (`|`) of an argument list.

        ⍷∧| 3‿4‿¯3‿¯2‿0

If it doesn't have to be a function, it's easiest to write it all out! Let's assume we want a tacit function instead. With three one-argument functions, we can't use a 3-train, as the middle function in a 3-train always has two arguments. Instead, we will compose the functions with 2-trains. Composition is associative, meaning that this can be done starting at either the left or the right.

        ((⍷∧)|) 3‿4‿¯3‿¯2‿0
        (⍷(∧|)) 3‿4‿¯3‿¯2‿0

We might make the first train above easier to read by using Atop (`∘`) instead of a 2-train. Atop is a 2-modifier, so it doesn't need parentheses when used in a train. The second train can also be changed to `⍷∧∘|` in the same way, but there is another option: the rightmost train `∧|` can be expanded to `·∧|`. After this it's an odd-length train in the last position, and doesn't need parentheses anymore.

        (⍷∘∧|) 3‿4‿¯3‿¯2‿0
        (⍷·∧|) 3‿4‿¯3‿¯2‿0

These two forms have a different emphasis, because the first breaks into subfunctions `⍷∘∧` and `|` and the second into `⍷` and `∧|`. It's more common to use `⍷∘∧` as a unit than `∧|`, so in this case `⍷∘∧|` is probably the better train.

Many one-argument functions strung together is [a major weakness](../commentary/problems.md#trains-dont-like-monads) for train syntax. If there are many such functions it's probably best to stick with a block function instead!

        {⍷∧|𝕩} 3‿4‿¯3‿¯2‿0

In our example, there aren't enough of these functions to really be cumbersome. If `⍷∘∧` is a common combination in a particular program, then the train `⍷∘∧|` will be more visually consistent and make it easier to use a utility function for `⍷∘∧` if that's wanted in the future.
