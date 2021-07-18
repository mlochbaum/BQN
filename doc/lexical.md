*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/lexical.html).*

# Lexical scoping

BQN uses lexical scope, like most modern functional programming languages including Javascript, Scheme, and Julia, and like Dyalog APL's dfns (tradfns are dynamically scoped). This document describes how lexical scoping works, and a few small details relevant to BQN's version of it.

In short, every [block](block.md) is a separate scope that can refer to identifiers in containing scopes. When evaluated, the block makes a variable for each identifier defined in it (including arguments and operands). The blocks that it contains will now access these variables. In the first level of a block, variables must be defined before they can be used, but in child blocks, a variable can be used regardless of where it's defined, as long as the definition is evaluated before the child block is.

## Scopes

Scoping is a mechanism that allows the same variable name to refer to different variables depending on program context. For example, the following code uses the name `a` in two ways: once for a value at the top level, and once locally in a function. With scoping, once you write `{}` to create a block, you can define any name you want inside without worrying whether it's taken.

        a ← 6
        F ← { a × 1 + a ← 𝕩 }

        F 4    # Sets a←4 internally
        a      # The outer a is unchanged

Above, the scope of the first `a` is the entire program, while the scope of the second `a` is limited to the body of `F`. So one form of context is that a name might mean different things depending on which block contains it. But even the exact same instance of a name in the source code might mean multiple things! A second kind of context is which evaluation of a block uses the name.

Without this ability BQN would be pretty limited: for example, an [object](oop.md)'s fields are variables. If the variable value didn't depend on what object contained it, there could effectively only be one instance of each object! While it's needed all the time, the most direct way to demonstrate one name meaning multiple things is with recursion. The (fragile) function below labels each element in a nested list structure with its index in the list containing it.

        Label ← { i←↕≠𝕩 ⋄ i ≍ 𝕊⍟=¨ 𝕩 }

        Label ⟨"ab"‿8, 7‿6‿5⟩

Each call creates the [list of indices](range.md) `i`, then calls itself using `𝕊` on each element of `𝕩` [if](repeat.md) it's a list, then [couples](couple.md) `i` to the result. This requires `i` to be unaffected by other calls to the function, which works because `i` is scoped not only to the source code location but also to the particular evaluation of the block that creates it.

These examples probably work like you expect—they're meant to highlight the features that scoping should have, in order to help show how less intuitive cases work later on.

## Visibility

A scope can view and modify (with `↩`) variables in other scopes that contain it. We say these variables are visible in the inner scopes. Variables at the top level of a program are visible to all the code in that program, so that we might call them "global". That would be a little misleading though, because for example each file is an entire program, so if one file is imported from another then it can't read the first file's variables.

        counter ← 0
        inc ← 6
        Count ← { counter +↩ 𝕩 × inc }

        Count 0
        Count 1
        Count 1
        Count 5

So the `Count` function above increments and prints a global `counter` by a global amount `inc`, which is visible in `Count` because it's visible everywhere. Or, not quite… if a block defines its *own* copy of `inc`, then it will lose access to the outer one. However, code that comes before that definition can still see the outer variable. So it can copy its value at the start of the block (this won't reflect later changes to the value. Don't shadow variables you want to use!).

        { inc←3 ⋄ inc }  # inc is shadowed

        inc  # But it's still here in the outer scope

        { a←inc ⋄ inc←3 ⋄ a }  # Read before shadowing

Each scope can only define a given name once. Trying to shadow a name that's in the current scope and not a higher one gives an error at compilation.

        { inc←3 ⋄ inc←4 }

Let's go all in on shadowing and make a modifier that creates its own copies of `counter` and `inc`, returning a custom version of the `Count` function above.

        _makeCount ← { counter‿inc←𝕗 ⋄ { counter +↩ 𝕩 × inc } }

        C3_7 ← 3‿7 _makeCount  # Start at 3; inc by 7

        C3_7 0
        C3_7 1
        Count 0  # Old counter stays the same

The function `C3_7` uses the versions of `counter` and `inc` created in `_makeCount`, even though it's called not from inside `_makeCount`, but from the top-level program. This is what it means for BQN's scoping to be lexical rather than dynamic. Which identifiers are visible is determined by where the code containing them is located in the source code, not how it's called at runtime. The static nature of lexical scoping makes it much easier to keep track of how variables are used (for compilers, this means optimization opportunities), and for this reason dynamic scoping is very rare in programming languages today.

## Closures
