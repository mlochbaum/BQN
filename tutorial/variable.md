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

        three ≍ ten - three ← 3

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

What's going on? Does BQN not know about capital letters? Does it object to self-reference? Why is "`BQN`" green?

If you open that statement in the online REPL, you'll see the more informative message "Role of the two sides in assignment must match" (*assignment* means anything written with a leftward arrow—either definition or modification). This is still cryptic but at least a "role" is something we've heard about before.

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
