*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/control.html).*

# Control flow in BQN

BQN does not have ALGOL-style control structures. Instead, functional techniques can be used to control when code is evaluated. This page describes how BQN functionality can be used to emulate something more familiar to an imperative programmer.

Control structures here are always functions that act on lists of functions, although alternatives might be presented. This is because stranded functions can be formatted in a very similar way to blocks in curly-brace languages. However, there are many ways to write control flow, including simple operators and a mix of operators and more control-structure-like code. Implementing a control structure rarely takes much code with any method, so there are usually several simple ways to implement a given flow or a variation of it.

The surfeit of ways to write control structures could be a bit of an issue for reading BQN. My hope is that the community can eventually settle on a smaller set of standard forms to recommend so that you won't have to recognize all the variants given here. On the other hand, the cost of using specialized control structures is lower in a large project without too many contributors. In this case BQN's flexibility allows developers to adapt to the project's particular demands (for example, some programs use switch/case statements heavily but most do not).

The useful control structures introduced here are collected as shortened definitions below. `While` uses the slightly more complicated implementation that avoids stack overflow, and `DoWhile` and `For` are written in terms of it in order to share this property. The more direct versions with linear stack use appear in the main text.

    If      ← {𝕏⍟𝕎@}´                 # Also Repeat
    IfElse  ← {c‿T‿F: c◶F‿T@}
    While   ← {𝕩{𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}𝕨@}´  # While 1‿{... to run forever
    DoWhile ← {𝕏@ ⋄ While 𝕨‿𝕩}´
    For     ← {I‿C‿P‿A: I@ ⋄ While⟨C,P∘A⟩}

    # Switch/case statements have many variations; these are a few
    Match   ← {𝕏𝕨}´
    Select  ← {(⊑𝕩)◶(1↓𝕩)@}
    Switch  ← {c←⊑𝕩 ⋄ m‿a←<˘⍉∘‿2⥊1↓𝕩 ⋄ (⊑a⊐C)◶m@}
    Test    ← {fn←{C‿A𝕊e:C◶A‿E}´𝕩⋄Fn@}

## Blocks and functions

Control structures are generally defined to work with blocks of code, which they might skip, or execute one or more times. This might sound like a BQN immediate block, which also consists of a sequence of code to execute, but immediate blocks are always executed as soon as they are encountered and can't be manipulated the way that blocks in imperative languages can. They're intended to be used with [lexical scoping](lexical.md) as a tool for encapsulation. Instead, the main tool we will use to get control structures is the block function.

Using functions as blocks is a little outside their intended purpose, and the fact that they have to be passed an argument and are expected to use it will be a minor annoyance. The following conventions signal a function that ignores its argument and is called purely for the side effects:
- Pass `@` to a function that ignores its argument. It's a nice signal that nothing is happening and is easy to type.
- A headerless function that doesn't use an argument will be interpreted as an immediate block by default. Start it with the line `𝕤` to avoid this (it's an instruction to navel gaze: the function contemplates its self, but does nothing about it). Other options like `𝕊:`, `F:`, or `𝕩` also work, but are more visually distracting.

Even with these workarounds, BQN's "niladic" function syntax is quite lightweight, comparing favorably to a low-boilerplate language like Javascript.

    fn = ()=>{m+=1;n*=2}; fn()
    Fn ← {𝕤⋄  m+↩1,n×↩2}, Fn @

Control structures are called "statements" below to match common usage, but they are actually expressions, and return a value that might be used later.

## If

The if statement conditionally performs some action. It is similar to the Repeat (`⍟`) modifier with a right operand returning a boolean: `Fn⍟Cond 𝕩` gives `Fn 𝕩` if `Cond 𝕩` is `1`, and returns `𝕩` without calling `Fn` if `Cond 𝕩` is `0`. Here is how we might make it behave like a control structure.

    {𝕤⋄a+↩10}⍟(a<10) @

The condition `a<10` is always evaluated, so there's no need to wrap it in a function. However, the function `{𝕤⋄a<10}` could be used in place of `(a<10)`, making the entire structure into a function that could be incorporated into other control structures.

In the example shown, the value `10` appears in both the condition and the action, so it can be pulled out by using it as an argument. Depending on context this might be more or less clear.

    {a+↩𝕩}⍟(a⊸<) 10

For a more conventional presentation, the condition and action can be placed in a list, and `If` defined as a function. 

    If ← {𝕏⍟𝕎@}´
    If (a<10)‿{𝕤
      a +↩ 10
    }

The result of any of these if statements is the result of the action if it's performed, and otherwise it's whatever argument was passed to the statement, which is `@` or `10` here.

BQN's syntax for a pure if statement isn't so good, but predicates handle [if-else](#if-else) statements nicely. So in most cases you'd forego the definitions above in favor of an if-else with nothing in the else branch:

    { a<10 ? a+↩10 ; @ }

## Repeat

There's no reason the condition in an if statement from the previous section has to be boolean: it could be any natural number, causing the action to be repeated that many times. If the action is never performed, the result is the statement's argument, and otherwise it's the result of the last time the action was performed.

Another option is to use a [for-each](#for) statement with an argument of `↕n`: in this case the result is the list of each action's result.

## If-Else

In most cases, the easy way to write an if-else statement is with [predicates](block.md#predicates):

    {
      threshold < 6 ?
      a ↩ Small threshold ;  # If predicate was true
      b ↩ 1 Large threshold  # If it wasn't
    }

We might also think of an if-else statement as a kind of [switch-case](#switch-case) statement, where the two cases are true (`1`) and false (`0`). As a result, we can implement it either with Choose (`◶`) or with [case headers](block.md#case-headers) of `1` and `0`.

When using Choose, note that the natural ordering places the false case before the true one to match list index ordering. To get the typical if-else order, the condition should be negated or the statements reversed. Here's a function to get an if-else statement by swapping the conditions, and two ways its application might be written.

    IfElse ← {cond‿True‿False: cond◶False‿True @}

    IfElse ⟨𝕩<mid⊑𝕨
      {𝕤⋄ hi↩mid}
      {𝕤⋄ lo↩mid}
    ⟩

    IfElse (𝕩<mid⊑𝕨)‿{𝕤
      hi↩mid
    }‿{𝕤
      lo↩mid
    }

Case headers have similar syntax, but the two cases are labelled explicitly. In this form, the two actions are combined in a single function, which could be assigned to call it on various conditions.

    {𝕏𝕨}´ (𝕩<mid⊑𝕨)‿{
      1: hi↩mid
    ;
      0: lo↩mid
    }

The result of an if-else statement is just the result of whichever branch was used; chained if-else and switch-case statements will work the same way.

### Chained If-Else

One pattern in imperative languages is to check one condition and apply an action if it succeeds, but check a different condition if it fails, in sequence until some condition succeeds or every one has been checked. Languages might make this pattern easier by making if-else right associative, so that the programmer can write an `if` statement followed by a sequence of `else if` "statements", or might just provide a unified `elif` keyword that works similarly. BQN's predicates work really well for this structure:

    {
      a<b ? a+↩1 ;
      a<c ? c-↩1 ;
            a-↩2
    }

For a function-based approach, it's possible to nest `IfElse` expressions, but it's also possible to write a control structure that chains them all at one level. For this statement the input will be a sequence of `⟨Test,Action⟩` pairs, followed by a final action to perform if no test succeeds. The first test is always performed; other tests should be wrapped in blocks because otherwise they'll be executed even if an earlier test succeeded.

    Test ← {fn←{Cond‿Act 𝕊 else: Cond◶Else‿Act}´𝕩 ⋄ Fn@}

    Test ⟨
      (  a<b)‿{𝕤⋄a+↩1}
      {𝕤⋄a<c}‿{𝕤⋄c-↩1}
      {𝕤⋄a-↩2}
    ⟩

## Switch-Case

The simplest way to write a switch-case statement is with [case headers](block.md#case-headers) in a monadic function. A function with case headers tests its input against the headers in order until one matches, then executes the code there. To make it into a control structure, we just want to call the function on a given value.

    Match ← {𝕏𝕨}´

    Match value‿{
      0‿b: n-↩b
    ;
      a‿b: n+↩a-b
    ;
      𝕩: n∾↩𝕩
    }

A simplified version of a switch-case statement is possible if the cases are natural numbers `0`, `1`, and so on. The Choose (`◶`) modifier does just what we want. The `Select` statement below generalizes `IfElse`, except that it doesn't rearrange the cases relative to Choose while `IfElse` swaps them.

    Select ← {(⊑𝕩)◶(1↓𝕩)@}

    Select number‿{
      name ↩ "zero"
    }‿{
      name ↩ "one"
    }‿{
      name ↩ "two"
    }

To test against other possible values, the following statement takes interleaved lists of values and actions, and disentangles them. It searches through the values with `⊐`.

    Switch ← {c←⊑𝕩 ⋄ m‿a←<˘⍉∘‿2⥊1↓𝕩 ⋄ (⊑a⊐C)◶m@}

    Switch ⟨value
      "increment" ⋄ {𝕤⋄ v+↩1}
      "decrement" ⋄ {𝕤⋄ v-↩1}
      "double"    ⋄ {𝕤⋄ v×↩2}
      "halve"     ⋄ {𝕤⋄ v÷↩2}
    ⟩

Finally, the most general form of a switch statement is a [chained if-else](#chained-if-else)!

## Loop forever

It's not a particularly common pattern, but this is a good simple case to warm up for the while loop. BQN primitives usually take a predictable amount of time, and none of them will run forever! Recursion is the tool to use here. If there's a particular function that we'd like to run infinity times, we can just add `𝕨𝕊𝕩` to the end:

    {
      # Stuff to do forever
      𝕨𝕊𝕩
    } arg

To convert this to a control structure format, we want to take an action `A`, and produce a function that runs `A`, then runs itself. Finally we want to call that function on some argument, say `@`. The argument is a single function, so to call Forever, we need to convert that function to a subject role.

    Forever ← {𝕊a:{𝕊A𝕩}@}

    Forever 1⊑@‿{𝕤
      # Stuff to do forever
    }

A slicker method is to pass `𝕩` as an operand to a modifier. In a modifier, `𝕊` has the operands built in (just like `{𝕊A𝕩}` above has the environment containing `A` built in), so it will work the same way with no need for an explicit variable assignment.

    Forever ← {𝕩{𝕊𝔽𝕩}@}

The syntax here is awkward enough that it's actually better to use a while loop, with a constant condition of `1`!

    While 1‿{𝕤
      # Stuff to do forever
    }

## While

The same modifier technique used in `Forever` works for a while loop as well. Because there are now two components—the condition and action—we'll use a 2-modifier instead of a 1-modifier.

    While ← {𝕨{𝕊∘𝔾⍟𝔽𝕩}𝕩@}´

    While {𝕤⋄a<15}‿{𝕤
      a×↩2
    }

`𝔽` is the condition and `𝔾` is the action. So the inner modifier tests for the condition `𝔽`; if it's true then it runs `𝔾` followed by `𝕊`. For a do-while loop, which is a while loop that always runs the action at least once, we just need to move the test after the action:

    DoWhile ← {𝕨{𝕊⍟𝔽𝔾𝕩}𝕩@}´

Because the condition is run repeatedly, it has to be a function, and can't be a plain expression as in an if conditional.

### Low-stack version

The above version of `While` will fail in a fairly small number of iterations, because it consumes a new stack frame with each iteration. While tail call optimization could solve this, detecting the tail call in a compound function like `𝕊∘𝔾⍟𝔽` is technically difficult and would introduce overhead into a BQN interpreter. However, there is a method to make the number of required stack frames logarithmic in the number of iterations instead of linear:

    While ← {𝕩{𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}𝕨@}´

The innovation is to use `{𝔽⍟𝔾∘𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}` instead of the equivalent `{𝔽_𝕣_𝔾∘𝔽⍟𝔾𝕩}` or `{𝕊∘𝔽⍟𝔾𝕩}` (these are the same, as `𝕊` in a modifier is defined as `𝔽_𝕣_𝔾`). Here `𝔽` performs one iteration and `𝔾` tests whether to continue. The simplest approach is to perform one iteration and recurse with the same two functions. The modified approach replaces `𝔽` with `𝔽⍟𝔾∘𝔽`, that is, it doubles it while making sure the condition is still checked each iteration. The doublings compound so that recursion level `n` performs `𝔽` up to `2⋆n` times while using on the order of `n` additional stack frames. Only a hundred or two stack frames are needed to give a practically unlimited number of iterations.

## For

To begin with, are you sure you don't want a for-each loop instead? In BQN that's just a function with Each (`¨`), and it covers most common uses of a for loop.

    Fn¨ v      # for (𝕩 in v)
    Fn¨ ↕n     # for (𝕩=0; 𝕩<n; 𝕩++)
    Fn¨ k↓↕n   # for (𝕩=k; 𝕩<n; 𝕩++)  with 0≤k
    Fn¨ k+↕n-k # for (𝕩=k; 𝕩<n; 𝕩++)  with k≤n
    Fn¨ ⌽n     # for (𝕩=n; --𝕩; )

Very well… a for loop is just a while loop with some extra pre- and post-actions.

    For ← {Pre‿Cond‿Post‿Act: Pre@ ⋄ {𝕊∘Post∘Act⍟Cond 𝕩}@}

    For (c←27⊣n←0)‿{𝕤⋄1<c}‿{𝕤⋄n+↩1}‿{𝕤
      {𝕏𝕨}´ (2|c)‿{
        0: c÷↩2
      ;
        1: c↩1+3×c
      }
    }

The initialization can be a simple expression as shown; in fact it's a little silly to make initialization one of the arguments to `For` at all.Unlike in C, it's impossible to declare a variable that's local to the whole `For` loop but not its surroundings. Hopefully this is obvious from the structure of the code! Only curly braces can create a new scope, so to localize some variables in the `For` loop, just surround it in an extra set of curly braces.

The `While` loop alone allows syntax similar to the `For` loop. Perform any initialization outside of the loop, and compose the post-action with the main body using the reverse composition `{𝔾∘𝔽}`. Because the composition binds less tightly than stranding, the bracketed [list notation](arrayrepr.md#brackets) has to be used here.

    c←27 ⋄ n←0
    While ⟨{𝕤⋄1<c}, {𝕤⋄n+↩1}{𝔾∘𝔽}{𝕤
      Match (2|c)‿{
        0: c÷↩2
      ;
        1: c↩1+3×c
      }
    }⟩

### Break and continue

In a `While` or `For` loop, [returns](block.md#returns) can be used for either the break or the continue statement (or, for that matter, a multiline break) if available. Returning from the main body, either with `𝕊→` or a labelled return, is a functional version of a continue statement. To escape from the loop as a whole, it should be wrapped in a labelled immediate block. Returning from that block using its label breaks the loop. For example, the following loop 

    {brk:
      sum ← 0 ⋄ even ← ⟨⟩
      While {𝕤⋄sum<100}‿{Cnt:
        brk→⍟(15≤n) @
        sum +↩ n
        Cnt→⍟(2|n) @
        even ∾↩ n
      }
    }
