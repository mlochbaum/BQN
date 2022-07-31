*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/tutorial/variable.html).*

# Tutorial: Variables

To take a proud denizen of the eternal cosmos of values, held for a fleeting instant by the course of code, and bind it. Tie it down with a name, failing always to alter its inner nature but allowing context to reform its outer appearance. So labelled, perhaps through the progress of time it will know escape, or else find itself passed through one bond to another, ever tethered. It's a task to be approached only with respect.

        hey ← "Hi there"

        hey ∾ ", World!"

Like that.

## Defining variables

BQN uses the left-pointing arrow `←` to define variables, as shown above. Most of the time it's best to use it in a plain way, with just the name and its definition, but it's also possible to define multiple variables using list notation, or to define a variable as part of a larger expression that continues to the left (in terms of precedence, `←` behaves like a function, but it isn't one—it's a part of syntax).

        pi‿e‿ten ← ⟨ π, ⋆1, 10 ⟩

        ten × pi

        three ⋈ ten - three ← 3

A variable can't be defined twice in the same *scope*. Later we'll work with functions and other pieces of code that create their own scopes, but for now all you need to know is that all the code in a tutorial runs in the same scope. So `three` is already defined, and can't be defined again.

        three ← 4

It's a little crazy to call them variables if the definition can never change, right? Doesn't "variable" *mean* "able to change"? Fortunately, this is one way in which BQN isn't crazy. You can *modify* a variable's value with the arrow `↩` provided it's already been defined. This never does anything to the original value: that value stays the same; it's just (probably) not the value of the modified variable any more.

        three ↩ 4

        three = 3   # Wait why did I do that

        3 = three ↩ 3

        four ↩ 3    # four isn't defined yet

It's an odd distinction to have when your program is just one long sequence of statements, because there's only ever one arrow you can use: it just changes annoyingly after you define the variable for the first time. With multiple scopes this isn't the case: if you start a new scope inside another, then you'll still be able to use variables from the outside scope. Then `↩` lets you change the value of one of these variables while `←` allows you to define your own. If you're coming from a typical curly-brace language, you'd say that `←` both declares and assigns a variable, while `↩` only assigns it.

## Variable roles

        BQN ← "[many pages of specification]"

Does BQN not know about capital letters? Does it object to self-reference? Why is "`BQN`" green? At least there's an error message, and a "role" is something we've heard about before. *Assignment* means anything written with a leftward arrow—either definition or modification.

I'll first confuse you a little more by pointing out that BQN's variables are case-insensitive, and even underscore-insensitive!

        three
        thrEe
        ThReE
        thr_EE
        __three
        _T_H_R_E_E_

But the syntax highlighter still seems to care, and you'll get a strange result if you try to apply a function to one of the uppercase spellings:

        - Three

        - _three


Now might be a good time to [review](expression.md#one-or-two-arguments) the earlier material on roles, experiment, and see if you can puzzle out what's happening here. Or a good time to keep reading until the horrifying distortions these texts inevitably wrap around your existence become apparent, so I'll explain that all these names do represent the same value—they all refer to the same variable—but they have different syntactic roles. Just as the same person might sometimes stand in front of the counter to order a coffee and sometimes stand behind it pouring coffee, the same variable is spelled different ways to indicate what it might be doing right now. There's a spelling for each role:

| Spelling           | Role       | Purpose
|--------------------|------------|---------
| `lowercase`        | Subject    | Argument or operand
| `Uppercase`        | Function   | Function call or operand
| `_leftUnderscore`  | 1-modifier | 1-modifier call
| `_twoUnderscores_` | 2-modifier | 2-modifier call

The role only depends on the first character of the name, and the last one if the first one was an underscore. Whether the characters in the middle are uppercase or lowercase doesn't matter. I tend to stick to `camelCase`, but if you prefer `snake_case`, or choose depending on your current biome, that's also fine (but "snake" and "camel" aren't interchangeable, they are different animals).

By the way, you can also write numbers with underscores in the middle: they'll be ignored just like in names. This can be useful as a thousands separator, for example.

        1_000_000

## Function assignment

While you could build up a script by computing values and assigning them names, the main way to use assignment in tacit programming is to give names to functions, not data. For example, we might name the base-2 conversion function from our last tutorial:

        Base2 ← +⟜(2⊸×)´∘⌽

        Base2 1‿0‿1‿0

        Base2 "01010001"-'0'

        @ + Base2¨ '0' -˜ "01000010"‿"01010001"‿"01001110"

This strategy allows us to break down a program into smaller parts. However, you can only name a function in this way, not an expression. We'll explain later how to turn an expression into an explicit function. But one thing remains true regardless of how a function is created: functions are just another kind of BQN value, and giving a function a name uses the ordinary definition arrow `←`, not any special syntax.

Even if you define a variable to be a function at first, you're not locked in to that choice. You can modify the variable to have a different value (but remember to change the casing to match the new value's role!). If it's a data value, you'll still be able to call it as a function: it will return itself.

        Base2

        base2 ↩ 16   # Change it to a number

        Base2

        Base2 6

## Modifying part of an array

You cannot modify part of an array. You can't modify an array: an array that differs a little bit from another array *is a different array*. And this isn't just a terminology choice: it has real effects on how BQN arrays behave and even which arrays are representable, as we'll discuss later.

But say I have a list, and I want to subtract one from one of the elements. With the understanding that the resulting list is different from the first one, BQN allows this!

        "BQN"            # A list of characters

        -⟜1⌾(2⊸⊑) "BQN"  # Wait why did I do that

<!--GEN prim.bqn
Primitives ⟨ "⌾%K%Under", "⊑%I%First%Pick" ⟩
-->
Besides using some primitives we haven't seen here, the notation is a little noisy. In return it's very flexible, in that you can apply any function you want, at a location you can select with a large class of BQN functions.

<!--GEN
{
d ← 100‿48

Text ← ("text" Attr "dy"‿"0.31em"∾·Pos d⊸×)⊸Enc
Path ← ("path" Attr "class"⊸⋈≍"style"‿"fill:none"˙)⊸Elt⟜("d"⊸⋈)

vals ← -⟜1{≍⟜(𝔾¨) ⊢⋈𝔽⌾𝔾}(2⊸⊑) "BQN"

g  ← "font-size=20px|text-anchor=middle|fill=currentColor"
rc ← At "class=code|stroke-width=1|rx=12"
fc ← "font-size=18px|font-family=BQN,monospace"

Ge ← "g"⊸At⊸Enc
_arrow ← {
  a ← ((⊢≍-⌾⊑∘⌽)÷⟜(+´⌾(×˜))𝕨) +˝∘×⎉1‿∞˜ 𝕗≍-⌾⊑𝕗
  ∾"M l m l l "∾¨ FmtNum ∾⥊¨⟨𝕩-𝕨, 𝕨, -⊏a, a⟩
}
Arr ← 15‿8 _arrow
cut ← 0.2‿0.17
ars ← (×⟜(¬2×cut) Arr○(d⊸×) ×⟜(-cut)⊸+)¨⟜((<-1‿1)⊸++0‿0≍˘⌽) 2×=⟜<↕2

dim ← 5.2‿4×d
rdim ← 4‿4×d
(∾÷⟜¯2‿1<20+dim) SVG g Ge ⟨
  "rect" Elt rc∾(Pos rdim÷¯2)∾"width"‿"height"≍˘FmtNum rdim
  "stroke-width=3"‿"stroke-width=2" Ge¨ "purple"‿"yellow" Path⟜∾¨ 0‿1‿1‿1⊔⥊ars
  fc Ge ⟨
    (⍉-⊸≍1.44‿1.35×⌽<⊸=↕2) Text⟜Highlight¨ "-⟜1⌾(2⊸⊑)"‿"-⟜1"≍⋈˜"2⊸⊑"
    "class=string" Ge (⋈⌜˜-⟜¬↕2) Text¨ ⍉0‿¯1⌽¨(⌈´∘⥊≠¨)⊸(↑¨) •Repr¨ vals
  ⟩
⟩
}
-->

So let's break this down. The 2-modifier Under (`⌾`) has two operands: the left one, `-⟜1`, subtracts one, and the right one, `2⊸⊑` uses a function we haven't seen before. It uses the right operand to pick out part of its argument, then the left one acts on that part only, and the entire argument, with the necessary modifications, is returned.

<!--GEN evalexp.bqn
DrawEval "-⟜1⌾(2⊸⊑) ""BQN"""
-->

Well, the function Pick (`⊑`) isn't doing anything too special here: the left argument is an index and it picks the element at that index from the right argument (which has to be a list, although there's a more complicated case with a compound left argument that we won't talk about now). Elements of a list are numbered starting at 0. This matches with the Range (`↕`) function we saw earlier, in that the value of Range's result at a particular index is equal to that index. As an illustration, we can pair up each element of a list with its index by calling Range on the list's length.

        (↕3) ⋈¨ "BQN"

        1 ⊑ "BQN"

A sometimes-useful shorthand is that with no left argument, `⊑` indicates First, the first element of a list. So we can quickly replace the first element of a list. The second two elements don't change here, but they're written differently because unlike a list of characters—a string—a list with numbers and characters doesn't use a special notation.

        8⌾⊑ "BQN"        # Change the first element to 8

BQN doesn't have a dedicated syntax such as `list[index]` to select from a list, because a function is more consistent with the rest of BQN's notation and can be manipulated more easily. This decision has already been useful to us, because Under's right operand is a function! With a special notation we'd have to first "package" index selection into a function to use it.

<!--GEN
Primitives ⟨ "↑%r%%Take", "↓%c%%Drop" ⟩
-->
What other selection functions can we use for Under's right operand? The only limit standing in our way is our knowledge of BQN primitives, which… frankly is pretty limiting. Let's work on that. Starting with the function Take (`↑`), which selects the first few elements of a list, or the last few.

        ↕7

        4 ↑ ↕7           # The first four elements

        ⌽⌾(4⊸↑) ↕7       # And reverse them

        ⌽⌾(¯4⊸↑) ↕7      # Or reverse the last four

This function takes from the beginning if the left argument is positive and from the end if the left argument is negative. If the left argument is zero, the result is an empty list, so it doesn't really take from the beginning *or* the end. Another thing to notice about the left argument here is that it's on the left. Less circularly, these sorts of selection primitives in BQN always take the array to select from on the right and a control value describing how to select on the left. Another example is Rotate (`⌽`), where the rotation amount goes on the left. It doesn't usually make sense to use Rotate in the right operand to Under, but we can easily rotate, say, the contents of element 1 of a list, or all the elements but the first two.

        2⊸⌽⌾(1⊸⊑) "xyz"‿"ABCDE"‿"wxyz"‿"yz"

        2⊸⌽⌾(2⊸↓) "XYabcde"

Drop (`↓`), on display in the second expression above, is a sort of "opposite" to take: it returns all the elements *except* the ones that Take would select. So for example `2⊸↑` gets the first two elements but `2⊸↓` removes them. Like Take, a negative left argument works from the end, and a left argument of zero returns the full list, so it doesn't drop from the beginning or the end.

        ¯3 ↓ "abcdefgh"

        2 ↑ 4 ↓ "abcdefgh"

As you can see, by applying Take and then Drop, we can pick out a slice of a list with a given starting point (4) and length (2). Can we use Under to act on that slice only? Yes!

        ('A'-'a')⊸+ ⌾ (2 ↑ 4⊸↓)  "abcdefgh"

(Here I've snuck in a train `2 ↑ 4⊸↓` to combine the two functions. As an exercise, you might try to write that function using combinators instead, and as an extra hard exercise you might then ponder why someone would want to add trains to a language).

## Identity functions

<!--GEN
Primitives ⟨ "⊣%{%Identity%Left", "⊢%}%Identity%Right" ⟩
-->
I'm not going to lie. I'm making this its own section so it looks like I plan ahead when I write these tutorials. The function Right (`⊢`) always returns its right argument, and Left (`⊣`) returns its left argument if there is one, and the right argument otherwise.

        ⊢ "only"

        ⊣ "only"

        "left" ⊢ "right"

        "left" ⊣ "right"

They are not complicated functions: if you're confused it's because you don't understand why anyone would ever use them. Indeed, it's harder to see why these functions are useful than to see what they do. That is a fact.

## Modified assignment

Let's revisit our question about modifying an array. As we said, the answer to "how do I modify part of an array?" is simply that you can't, and that the question doesn't make sense. But there's a seemingly similar question with a very different answer: "how do I modify part of a variable whose value is an array?" This is because unlike an array, a variable isn't defined by the value it has, but by the name used to refer to it (and the scope it resides in). Here's how we would modify the variable `a`:

        a ← 4            # First it's a number
        a

        a ↩ 4‿5‿6        # Now it's a list!
        a

But this changes the value of `a` to a completely unrelated value. What if I want to apply a transformation to `a`, for example to subtract one? Of course I can write the value `a` on the right hand side of the assignment, but that's extra work and doesn't really seem to represent what I'm doing, which is conceptually just to apply a function to `a`. So BQN also has a shorthand, called *modified assignment*. Here, the modified assignment `-↩` subtracts a value from `a`.

        a ↩ a - 1
        a

        a -↩ 1

(In case you're wondering why I didn't have to write `a` again that last time, the evaluator suppresses the printed result for ordinary assignments but not modified ones. This is a feature of my website software and not the BQN language). It looks a lot like the special assignment operators `+=`, `/=`, and so on that you'll see in C or Javascript. What BQN brings to the table is that you can use any two-argument function at all here, because two-argument function are always written as operators. For example, we can prepend some elements to `a`:

        a ∾˜↩ 0‿1

But what about functions with only one argument? It's possible to do this using a dummy right argument such as the null character, `@`. To turn a function that takes one argument into one that takes two, we can compose it with a function that takes two arguments and returns one of them. The left one, since the variable to modify is on the left hand side. Perhaps… Left? (`⊣`)?

        "abcd" ⌽∘⊣ "wxyz"

        a ⌽∘⊣↩ @

But fortunately, there's a simpler syntax as well: write your one-argument function before `↩` with no right hand side. Bit of a Yoda vibe: "`a` reversed is".

        a ⌽↩

        a 4⊸-↩           # And back again

Notice that there's no need for parentheses: modifiers bind more strongly than the assignment character. Now what if we want to decrease the last two elements of `a`? That is, we want to compute the following array while storing it in `a`.

        -⟜4⌾(¯2⊸↑) a

        a                # It hasn't changed, of course

The code to do this looks the same as what we did with Reverse (`⌽`).

        a -⟜4⌾(¯2⊸↑)↩
