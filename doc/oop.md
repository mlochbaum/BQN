*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/oop.html).*

# Object-oriented programming in BQN

BQN's [namespaces](namespace.md) can be used to support a simple form of [object-oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming) (OOP) without type checking or inheritance. It's suitable for some program architectures but not others: making OOP work as a solution to every problem isn't a BQN design goal. In fact, BQN was never designed to support OOP at all! I added namespaces or modules as a way to structure programs. The techniques we're going to discuss are all just ways to use namespaces, and if it ever starts seeming like confusing magic it might help to go back to this model. However, thinking of namespaces as objects can be quite powerful in the right circumstances, and on this page I'm going to frame things in OOP terms. The following table shows which well-known aspects of OOP are supported in BQN:

Feature             | In BQN?
--------------------|--------
Objects             | [Yes](#objects) (namespaces)
Classes             | [Yes](#classes) (function returning namespace)
Fields              | [Yes](#objects)
Methods             | [Yes](#objects)
Class variables     | [Yes](#class-members) (awkward syntax)
Access              | Public or instance-private
`this`              | No ([well…](#self-reference))
Inheritance (is-a)  | No
Composition (has-a) | [Yes](#composition)
Interfaces          | No
Abstract classes    | No
Mixins              | Not really (needs `this`)

## Objects

An object in BQN is simply a namespace: its fields and methods are variables in the namespace, and a variable can be accessed outside of the namespace with dot syntax if it's exported with `⇐`. Unexported variables are instance-private in OOP parlance, meaning that they're only visible to the object containing them. They could be utilities, or hold state for the object. As an example, the object below implements the [Tower of Hanoi](https://en.wikipedia.org/wiki/Tower_of_Hanoi) puzzle with five disks. You can view the state (a list of disks occupying each of the three rods) with `towerOfHanoi.View`, or move the top disk from one rod to another with `towerOfHanoi.Move`.

        towerOfHanoi ← {
          l ← ↕¨5‿0‿0
          View ⇐ {𝕤
            l
          }
          Move ⇐ {from‿to:
            l ↩ Transfer´⌾(𝕩⊸⊏)⍟(≠´𝕩) l
          }
          # Move a disk from 𝕨 to 𝕩
          Transfer ← {
            "No disk to move"!0<≠𝕨
            "Can't place larger disk on smaller one"!(0<≠)◶⟨1,𝕨<○⊑⊢⟩𝕩
            ⟨1↓𝕨, 𝕨⊏⊸∾𝕩⟩
          }
        }

Two variables `l` and `Transfer` aren't exported, for two different reasons. `l` encodes the state of the tower, but it's only exposed with the function `View`, which allows the internal representation to be changed freely. `Transfer` is just a utility function. While it's not dangerous to use outside of the object, there's no reason to expose it through `towerOfHanoi`'s interface. If it's wanted in another place it should be moved to a common location.

Here are the results of a few applications of these functions.

        t ← towerOfHanoi
        t.View@

        t.Move 0‿2

        t.Move 1‿2

        t.Move 0‿1

        t.Move 2‿1

## Classes

The object above is a singleton: there's just one of it, at least in the scope it occupies. It's often more useful to have a class that can be used to create objects. What we'll call a "class" is a namespace function, that is, a function that contains `⇐` and so returns a namespace. It's very easy to convert a singleton object to a class: [just add](control.md#blocks-and-functions) a no-op `𝕤` line to force it to be a function, and call it with `@` when needed.

    MakeStack ← {𝕤
      st←@
      Push⇐{   st↩𝕩‿st}
      Pop ⇐{𝕤⋄ r‿s←st ⋄ st↩s ⋄ r}
    }

But arguments don't have to be ignored: often it makes sense to use one or two arguments to initialize the object. For example, the stack class above can be modified to use `𝕩` as an initial list of values for the stack.

    MakeStackInit ← {
      st←@
      Push⇐{   st↩𝕩‿st}
      Pop ⇐{𝕤⋄ r‿s←st ⋄ st↩s ⋄ r}
      Push¨ 𝕩
    }

A stack is a particularly simple class to make because its state can be represented efficiently as a BQN value. Other data structures don't allow this, and will often require an extra `Node` class in an implementation—see `MakeQueue` below.

## Mutability

An object is one way to transform *variable mutation* `↩` into [*mutable data*](lexical.md#mutation). These are two different concepts: `↩` changes which value is attached to a *name* in a scope, while mutable data means that the behavior of a particular *value* can change. But if a value is linked to a scope (for an object, the scope that contains its fields), then variable mutation in that scope can change the value's behavior. In fact, in BQN this is the only way to create mutable data. Which doesn't mean it's rare: functions, modifiers, and namespaces are all potentially mutable. The difference between objects and the operations is just a matter of syntax. Mutability in operations can only be observed by calling them. For instance `F 10` or `-_m` could return a different result even if the variables involved don't change value. Mutability in an object can only be observed by accessing a member, meaning that `obj.field` or `⟨field⟩←obj` can yield different values over the course of a program even if `obj` is still the same object.

Let's look at how mutability plays out in an example class for a single-ended queue. This queue works by linking new nodes to the tail `t` of the queue, and detaching nodes from the head `h` when requested (a detached node will still point to `h`, but nothing in the queue points to *it*, so it's unreachable and will eventually be garbage collected). Each node has some data `v` and a single node reference `n` directed tailwards; in a double-ended queue or more complicated structure it would have more references. You can find every mutable variable in the queue by searching for `↩`, which shows that `t` and `h` in the queue, and `n` in a node, may be mutated. It's impossible for the other variables to change value once they're assigned.

    MakeQueue ← {𝕤
      t←h←e←{SetN⇐{h↩𝕩}}
      Node←{v⇐𝕩⋄n⇐e ⋄ SetN⇐{n↩𝕩}}
      Push⇐{t.SetN n←Node 𝕩 ⋄ t↩n}
      Pop ⇐{𝕤⋄v←h.v⋄h↩h.n⋄{e=h?t↩e;@}⋄v}
    }

Unlike a stack, a node's successor isn't known when it's created, and it has to be set. You might be inclined to make `n` settable directly, but we'll get more mileage out of a setter function `SetN`. This allows us to create a pseudo-node `e` (for "empty") indicating there are no values in the queue. Because it has no `.v` field, if `h` is `e` then `Pop` gives an error (but in a real implementation you'd want to test explicitly instead in order to give an appropriate error message). In fact it doesn't have an `n` field, and essentially uses the queue head `h` instead. With this empty "node", the queue definition is straightforward. The only tricky part to remember is that if `Pop` removes the last node, resulting in `e=h`, then the tail has to be set to `e` as well, or it will keep pointing to the removed node and cause bugs.

## Composition

BQN classes don't support inheritance because there's no way to extend an existing class with new fields. But a lot of OOP enthusiasts these days are promoting [composition over inheritance](https://en.wikipedia.org/wiki/Composition_over_inheritance), and here BQN does pretty well. Forwarding methods from another class is as simple as a multiple assignment, like `⟨View⟩` below (in a real program `undoableTowerOfHanoi` should almost certainly be a class, but I introduced `towerOfHanoi` before classes, and I'm not about to write it again just to add an `𝕤`).

    undoableTowerOfHanoi ← {
      Push‿Pop ← MakeStack@     # Copy methods as private
      ⟨View⟩ ⇐ t←towerOfHanoi   # Copy and export
      Move ⇐ t.Move ⊣ Push
      Undo ⇐ t.Move∘⌽∘Pop
    }

This class composes a Tower of Hanoi with an undo stack that stores previous moves. To undo a move from `a` to `b`, it moves from `b` to `a`, although if you felt really fancy you might define `Move⁼` in `towerOfHanoi` instead with an [undo header](undo.md#undo-headers) `𝕊⁼𝕩: 𝕊⌽𝕩`.

It's also possible to copy several variables and only export some of them, with an export statement. For example, if I wasn't going to make another method called `Move`, I might have written `View‿Move ← towerOfHanoi` and then `View⇐`. In fact, depending on your personal style and how complicated your classes are, you might prefer to avoid inline `⇐` exports entirely, and declare all the exports at the top.

## Self-reference

An object's class is given by `𝕊` in examples like `MakeStack` above. Remember, a class is an ordinary BQN function! It might be useful for an object to produce another object of the same class (particularly if it's immutable), and an object might also expose a field `class⇐𝕤` to test whether an object `o` belongs to a class `c` with `o.class = c`.

For an object to know its own value it needs some outside help, such as a special constructor:

    IntrospectiveClass ← {𝕩.This 𝕩}∘{
      This ⇐ { this↩𝕩 }
      # Now the object definition as usual
      value ⇐ 𝕩
    }

Why not a system value `•this` that just gets the current namespace's value? First, the concept of the "current namespace" is a little fuzzy; above `this` uses lexical scope, which system values normally don't have access to. Also, if `•this` is used before the namespace is done being defined, it could be an object with undefined fields, something that doesn't exist in BQN now (a block body doesn't have any sort of control flow other than the early exit `?`, so it can only finish by executing every statement, and a namespace is only available once its block returns). So setting `this` at the end seems to be a better match for BQN's namespace semantics.

## Class members

As with `this`, creating variables that belong to a class and not its objects is a do-it-yourself sort of thing (or more positively, not at all magic (funny how programmer jargon goes the opposite way to ordinary English)). It's an easy one though, as this is exactly what [lexical scoping](lexical.md) does:

    staticClass ← {
      counter ← 0
      {𝕤
        class ⇐ staticClass
        Count ⇐ {𝕤⋄ counter+↩1 }
      }
    }

Now `StaticClass` is the inner function, because that function is the block's result, and it has some extra state that only it knows how to access. The differences in the definition are that `staticClass` ends up with a subject role and that each object's `class` has to be set to `staticClass` instead of the shortcut `𝕤`, but these are purely syntactic issues: under it all, `staticClass` is the same as any other class, but has some extra state attached.
