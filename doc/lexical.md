*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/lexical.html).*

# Lexical scoping

BQN uses lexical scope, like most modern functional programming languages including Javascript, Scheme, and Julia, and like Dyalog APL's dfns (tradfns are dynamically scoped). This document describes how lexical scoping works, and a few small details relevant to BQN's version of it.

In short, every [block](block.md) is a separate scope, but can use identifiers in containing scopes. Each time it's evaluated, the block makes a variable for each identifier defined in it (including arguments and operands). The blocks that it contains might access these variables. At the top level of a block, identifiers must be defined before they can be used, but in child blocks, an identifier can be used even if it's defined later, as long as that use isn't evaluated before the definition can set the variable value.

## Scopes

Scoping is a mechanism that allows the same variable name to refer to different variables depending on program context. For example, the following code uses the name `a` in two ways: once for a value at the top level, and once locally in a function. With scoping, once you write `{}` to create a block, you can define any name you want inside without worrying whether it's taken.

        a ← 6
        F ← { a × 1 + a ← 𝕩 }

        F 4    # Sets a←4 internally
        a      # The outer a is unchanged

Above, the scope of the first `a` is the entire program, while the scope of the second `a` is limited to the body of `F`. So one form of context is that a name might mean different things depending on which block contains it. But even the exact same instance of a name in the source code might mean multiple things! A second kind of context is which evaluation of a block uses the name.

Without this ability BQN would be pretty limited: for example, an [object](oop.md)'s fields are variables. If the variable value didn't depend on what object contained it, there could effectively only be one instance of each object! It's not the most common use case, but recursion is the most direct way to demonstrate a name meaning multiple things at once. The (fragile) function below labels each element in a nested list structure with its index in the list containing it.

        Label ← { i←↕≠𝕩 ⋄ i ≍ 𝕊⍟=¨ 𝕩 }

        Label ⟨"ab"‿8, 7‿6‿5⟩

Each call creates the [list of indices](range.md) `i`, then calls itself using `𝕊` on each element of `𝕩` [if](repeat.md) it's a list, then [couples](couple.md) `i` to the result. This requires `i` to be unaffected by other calls to the function, which works because `i` is scoped not only to the source code location but also to the particular evaluation of the block that creates it.

These examples probably work like you expect—they're meant to highlight the features that scoping should have, in order to help show how less intuitive cases work later on.

## Visibility

A scope can view and [modify](expression.md#assignment) (with `↩`) variables in other scopes that contain it. We say these variables are *visible* in the inner scopes. Variables at the top level of a program are visible to all the code in that program, so that we might call them "global". That's somewhat misleading, because for example each file is an entire program, so if one file is imported from another then it can't read the first file's variables.

        counter ← 0
        inc ← 6
        Count ← { counter +↩ 𝕩 × inc }

        Count 0
        Count 1
        Count 1
        Count 5

So the `Count` function above increments a global `counter` by a global amount `inc`, which is visible in `Count` because it's visible everywhere. Or, not quite… if a block defines its *own* copy of `inc`, then it will lose access to the outer one. However, code that comes before that definition can still see the outer variable. So it can copy its value at the start of the block (this won't reflect later changes to the variable. Don't shadow variables you want to use!).

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

### Post-definition

In the top level a block, a variable can only be used after it's defined, and the compiler rejects any code that tries to use an undefined variable. But blocks contained in that block see variables it defines regardless of the positioning. Below, `PlusC` references the variable `c` that's defined after it (but when code is executed one line at a time like it is here, I still have to put both definitions on the same line so they are compiled together).

        PlusC ← { 𝕩+c } ⋄ c←¯1
        PlusC 7

But you'll still get an error if the variable is used before its definition is run. Unlike the single-level case, this is a runtime error and only appears when the variable is actually accessed.

        { 2+d } ⋄ d←¯2

Why define things this way? It's easier to see if you imagine the variable used is also a function. It's normal for a function to call other functions defined at the top level, of course. And it would be pretty unpleasant for BQN to enforce a specific ordering for them. It would also make recursive functions impossible except by using `𝕊`, and mutually recursive ones completely impossible. A simple rule that makes all these things just work smoothly seems much better than any alternative.

## Closures

Let's run `_makeCount` from above a few more times.

        C4_2 ← 4‿2 _makeCount  # Start at 4; increment by 2
        C1_4 ← 1‿4 _makeCount  #          1;              4

        C4_2 0
        C1_4 0
        C4_2 10
        C1_4 10
        C4_2 0
        C3_7 0  # The first one's still around too

Each result keeps its own counter and the different copies don't interfere with each other. This is because every call to `_makeCount` is isolated, happening in its own world. We say that whenever a block begins execution it creates an *environment* where all its variables are stored. This environment might even be exposed later on, as a [namespace](namespace.md).

Each counter function has access to the environment containing its `counter` and `inc`, even though the block that created that environment (`_makeCount`) has finished execution—it must have finished, since we are now using the function it returns on the last line. There's nothing particularly weird about this; just because a block creates an environment when it starts doesn't mean it has to destroy it when it finishes. From the mathematical perspective, it's easiest to say the environment exists forever, but a practical implementation will perform garbage collection to free environments that are no longer reachable.

Since a function like `C1_4` maintains access to all the variables it needs to run, we say it *encloses* those variables, and call it a *closure*. It doesn't need to modify them. For example, the following definition of the theoretical standard deviation function `StdDev` is also a closure.

    stdDev ← {
      # Arithmetic mean
      Mean ← +´ ÷ ≠

      # Return this function
      {
        Mean⌾(×˜) 𝕩 - Mean 𝕩
      }
    }

The variable `Mean` is visible only within the outer immediate block. The only way it can be accessed is by code in this block: the two calls in the returned function, which will later be renamed `stdDev`. Nothing in the block modifies it, so its value is constant. It's just a little utility that exists only for code in the block. Making it visible elsewhere is as simple as moving it out of the block, but it's best not to do this without reason. Keeping a variable in the smallest possible scope makes it easier to understand the program, because it reduces the amount of information needed to understand scopes where that variable doesn't apply.

Neither the specification nor a typical implementation keep track of what is and isn't a closure, although an advanced interpreter will probably work with some related properties. The existence of closures is an ordinary feature of lexical scoping and not a special case. However, it's sometimes a useful term for discussing the operation of a program. We might define a closure as a block that can be run and access variables from a parent scope even after the block that created that scope finishes execution.

### Environments form a tree

So a block has access to every environment that it might need a variable from, for as long as it needs. This idea is a little fuzzy, so let's clarify by describing how an implementation would figure out what can access where.

The mechanism is that each environment can have a *parent* environment (the topmost environment, which corresponds to the entire program, has no parent). When a variable is accessed, it might be in the current environment, or its parent, or that environment's parent, and so on. Every environment corresponds to one block in the source code, and its parent corresponds to the parent block, so a compiler can figure out how many levels up it will have to go based on the source code.

We've seen that one block can create many environments. An environment can have only one parent, but many children, so environments form a tree. A forest to be precise, as one execution of BQN can involve multiple programs.

How does an environment know which of the many environments corresponding to the parent scope is its parent? This information is saved when the block is reached in the program and a *block instance* is created. Unless it's an immediate block, the block instance won't be run right away: a block instance isn't the same as a block evaluation. But each block evaluation starts with a block instance, and that's where it gets the parent environment. Unlike block evaluation, which can happen anywhere, a block instance is created only during evaluation of the parent block. So the saved parent environment is simply the current environment.

## Mutation

The value of a variable can be modified with `↩`. It's similar to definition `←` in that it sets the value of the variable, but the way it interacts with scoping is completely different. Definition creates a new variable in the current scope, and modification refers to an existing variable in the current scope or a parent. In scoping terms, a modification is more like an ordinary variable reference than a definition.

When a variable's modified, functions with access to it see the new value. They have access to the variable, not any particular value that it has.

        factor ← 3
        Mul ← { factor × 𝕩 }

        Mul 6
        factor ↩ 5
        Mul 6   # A new result

Only source code with access to a variable can modify it! This means that if none of the code in a variable's scope modifies it, then the variable is constant. That is, constant once it's defined: remember that it's still possible to get an error if the variable is accessed before being defined.

        { { a } ⋄ a←4 }

With lexical scoping, variable mutation automatically leads to mutable data. This is because a function or modifier that depends on the variable value changes its behavior when the variable changes. So do objects; this slightly more concrete case is discussed [here](oop.md#mutability). The behavior change is observed by calling operations, and by accessing object fields. These are the only two actions that might behave differently when applied to the same values!

### Aliasing

Mutable values exhibit *aliasing*. This means that when two variables refer to the same mutable value (or two copies of it exist generally), changes to one also affect the other.

        record ← { r←⟨⟩ ⋄ { r ∾↩ <𝕩 } }
        Record ∞

        Record2 ← Record  # Copy the function
        Record2 "new"

        Record 0   # The added value "new" is seen here as well

This could be said to conflict with arrays, where two variables might be copies of the same array but a change to one doesn't affect the other.

        copy_a ← copy_b ← "array"

        copy_b 'b'⌾⊑↩

        copy_a

But that's not really what's happening. Aliasing has nothing to do with variables: it's a property of mutation, and there's no such thing as array mutation. `'b'⌾⊑` creates a new but related array. And `↩` changes the value of `copy_b`, not *its* value `"array"`. Similarly, if we wrote `record2 ↩ @` then nothing would happen to `record`.

You can tell whether two mutable values alias each other using Match (`≡`), because that's how it defines [block equality](match.md#block-equality). However, aliasing isn't the only way one mutable value can affect another: two functions might refer to the same variable, for instance. I think the idea that the function itself is mutable can cause some confusion, and sometimes prefer to think at a lower level—that variables don't belong to the function, but the function just knows about them. So a function is more like a file name (path) than a file. It's a static thing, but using it (calling the function or accessing the file) reads outside information that can change over time.
