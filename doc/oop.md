*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/oop.html).*

# Object-oriented programming in BQN

BQN's [namespaces](namespace.md) can be used to support a simple form of [object-oriented programming](https://en.wikipedia.org/wiki/Object-oriented_programming) (OOP) without type checking or inheritance. It's suitable for some program architectures but not others: making OOP work as a solution to every problem isn't a BQN design goal. In fact, BQN was never designed to support OOP at all! I added namespaces or modules as a way to structure programs. The techniques we're going to discuss are all just ways to use namespaces, and if it ever starts seeming like confusing magic it might help to go back to this model. However, thinking of namespaces as objects can be quite powerful in the right circumstances, and on this page I'm going to frame things in OOP terms. The following table shows which well-known aspects of OOP are supported in BQN:

Feature             | In BQN?
--------------------|--------
Objects             | [Yes](#objects) (namespaces)
Classes             | [Yes](#classes) (function returning namespace)
Fields              | [Yes](#objects)
Methods             | [Yes](#objects)
Class variables     | [Sort of](#class-variables)
Access              | Public/instance-private
`this`              | No
Inheritance (is-a)  | No
Composition (has-a) | [Yes](#composition)
Interfaces          | No
Abstract classes    | No
Mixins              | Not really (needs `this`)

## Objects

An object in BQN is simply a namespace: its fields and methods are variables in the namespace, and one of these can be accessed outside of the namespace with dot syntax if it's exported with `⇐`. Unexported variables are instance-private in OOP parlance, meaning that only they're only visible to the object containing them. These might be used simply as utilities or they might hold state for the object. As an example, the object below implements the [Tower of Hanoi](https://en.wikipedia.org/wiki/Tower_of_Hanoi) puzzle with five disks. You can view the state (a list of disks occupying each of the three rods) with `towerOfHanoi.View`, or move the top disk from one rod to another with `towerOfHanoi.Move`.

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

Two fields `l` and `Transfer` aren't exported, for two different reasons. `l` encodes the state of the tower, but it's often better to expose it with the function `View` instead to allow the internal representation to be changed freely. `Transfer` is just a utility function. It's not dangerous to use outside of the object but there's no reason to expose it through `towerOfHanoi`'s interface: if it's wanted in another place it should be moved to a common location.

Here are the results of a few applications of these functions.

        t ← towerOfHanoi
        t.View@
    ⟨ ⟨ 0 1 2 3 4 ⟩ ⟨⟩ ⟨⟩ ⟩
        t.Move 0‿2
    ⟨ ⟨ 1 2 3 4 ⟩ ⟨⟩ ⟨ 0 ⟩ ⟩
        t.Move 1‿2
    ! "No disk to move"
        t.Move 0‿1
    ⟨ ⟨ 2 3 4 ⟩ ⟨ 1 ⟩ ⟨ 0 ⟩ ⟩
        t.Move 2‿1
    ⟨ ⟨ 2 3 4 ⟩ ⟨ 0 1 ⟩ ⟨⟩ ⟩

## Classes

The object above is a singleton: there's just one of it, at least in the scope it occupies. It's often more useful to have a class that can be used to create objects. What we'll call a "class" is a namespace function, that is, a function that contains `⇐` and so returns a namespace. It's very easy to convert a singleton object to a class: just add a no-op `𝕤` line to force it to be a function, and call it with `@` when needed.

    MakeStack ← {𝕤
      st←@
      Push⇐{   st↩𝕩‿st}
      Pop ⇐{𝕤⋄ r‿s←st ⋄ st↩s ⋄ r}
    }

But there's no need to ignore the argument: often it's useful to initialize a class using one or two arguments. For example, the stack class above can be modified to use `𝕩` as an initial list of values for the stack.

    MakeStack ← {
      st←@
      Push⇐{   st↩𝕩‿st}
      Pop ⇐{𝕤⋄ r‿s←st ⋄ st↩s ⋄ r}
      Push¨ 𝕩
    }

A stack is a particularly simple class to make because its state can be represented efficiently as a BQN value. Other data structures don't allow this, and will often require an extra `Node` class when they are implemented.

## Mutability

    MakeQueue ← {𝕤
      t←h←e←{SetN⇐{h↩𝕩}}
      Node←{v⇐𝕩⋄n⇐e ⋄ SetN⇐{n↩𝕩}}
      Push⇐{t.SetN n←Node 𝕩 ⋄ t↩n}
      Pop ⇐{𝕤⋄v←h.v⋄{t↩𝕩}⍟(e⊸=)h↩h.n⋄v}
    }

## Composition

## Class variables

## Self-reference

An object's class is given by `𝕊`. Remember, a class is an ordinary BQN function! It might be useful for an object to produce another object of the same class (particularly if it's immutable), and an object might also expose a field `class⇐𝕤` to test whether an object `o` belongs to a class `c` with `o.class = c`.

It's not currently possible for an object to know its own value without some outside help, such as a special constructor:

    IntrospectiveClass ← {
      obj ← {
        this⇐@
        SetThis ⇐ { !this=@ ⋄ this↩𝕩 }
      }
      obj.setThis obj
    }

This is a pretty clunky solution, and exports a useless method `SetThis` (which gives an error if it's ever called). It would be possible for BQN to define a system value `•this` that just gets the namespace's value. It would work only at the top level, so it would have to be assigned (`this←•this`) in order to use it in functions. This means it's always used before the namespace is done being defined, so a drawback is that it introduces the possibility that an object used in a program has undefined fields. The reason this isn't possible for objects without `•this` is that BQN's blocks don't have any sort of control flow, so that they always execute every statement in order. The namespace becomes accessible as a value once the block finishes, and at this point every statement has been executed and every field is initialized.
