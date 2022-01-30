*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/namespace.html).*

# Namespaces

A namespace is a type of value that groups together several values (fields) from the same scope. A block or file returns a namespace if it contains any export arrows `⇐` at the top level, and fields from namespaces can be accessed with either dot syntax or destructuring assignment. A namespace can be mutable only if any of the code in it uses `↩` to change the value of a field.

The following quick example shows a few ways to use a namespace returned by `•Import`:

    ns ← •Import "file.bqn"
    ⟨something, abbr⇐abbreviation⟩ ← ns  # Destructure
    ns.DoThing 6                         # Dot syntax

An here's how the contents of file.bqn might look in order to define the variables used above:

    ⟨something, DoThing⟩⇐     # Declare exports
    abbreviation ⇐ "sth"      # Define and export
    _something ← {𝕗}          # Separate definition
    DoThing ← "TODO"⊸!

## Uses

The features of namespaces that make them useful in BQN programming are encapsulation and mutability. But these are exactly the same features that [closures](lexical.md#closures) provide! In fact a namespace is not much more than a closure with a name lookup system. Consequently namespaces don't really expand the basic functionality of the language, but just make it easier to use.

Namespaces improve encapsulation by allowing many values to be exported at once. With only one way to call them, functions and modifiers aren't such a good way to define a large part of a program. With a namespace you can define lots of things and expose exactly the ones you want to the rest of the world. For example, it's typical for files to define namespaces. A reader can see the exported values just by searching for `⇐`, and if you're nice, you might declare them all at the beginning of the file. Careful use of exports can guarantee that potentially dangerous functions are used correctly: if it's only valid to call function `B` after function `A` has been called, export `AB⇐{A𝕩⋄B𝕩}` and don't export `B`.

Mutability means that the behavior of one namespace can change over the course of the program. Mutability is often a liability, so make sure you really need it before leaning too heavily on this property. While there's no way to tell from the outside that a particular namespace is mutable, you can tell it isn't if the source code doesn't contain `↩`, as this is the only way it can modify the variables it contains.

A namespace that makes use of mutability is essentially an object: a collection of state along with operations that act on it. [Object-oriented programming](oop.md) is the other major use of namespaces. Contrary to the name, there's never a need to orient your programming around objects, and it's perfectly fine to use an object here or there when you need to, for instance to build a mutable queue of values.

## Exports

The double arrow `⇐` is used to export variables from a block or file, making the result a namespace instead of the result of the last line. There are two ways to export variables. First, `←` in the variable definition can be replaced with `⇐` to export the variable as it's defined. Second, an export statement consisting of an assignment target followed by `⇐`, with nothing to the right, exports the variables in the target and does nothing else. These export statements can be placed anywhere in the relevant program or body, including before declaration or on the last line, and a given variable can be exported any number of times. The block in the example below has two statements that export variables, exporting `a`, `b`, and `c`.

    example ← {
      b‿c⇐   # Non-definition exports can go anywhere
      a⇐2    # Define and export
      b←1+a
      c←b‿"str"
    }

## Imports

There are also two ways to get values out of a namespace, such as `example` defined above. First, it might be used in a [destructuring](expression.md#destructuring) assignment like the one below. This assignment's target looks like a list, where each entry specifies one of the names exported by the block and what it should be assigned to. The element can be either a single name, like `b`, which gives both, or an aliasing expression like `b2⇐b`. In this case, the value `b` from the namespace is used, but it's given the name `b2` instead of `b`. Imported names can be repeated—but the variables defined can't—and all the names can be spelled with any role (the role is ignored).

    ⟨alias⇐a, b, c0‿c1⇐c, b2⇐b⟩ ← example

If aliasing with `⇐` is never used (or each use is parenthesized), the names can be given as a strand with `‿`.

    c‿a ← example

The arrows `⇐` used for importing don't indicate that the surrounding block is a namespace or export variables. However, a single statement can both import and export, if it's a destructuring assignment and the main assignment arrow is `⇐`.

    ⟨two, vars⟩ ⇐ •Import "stuff.bqn"

The second way to get a value (just one at a time) from a namespace is dot syntax: write the namespace, then a dot `.`, then another name.

    example.b

    {n⇐7}.n

The syntax is any subject followed by a dot and then a name. This can be chained like `a.b.c` if a namespace has a value that is also a namespace (and so on).
