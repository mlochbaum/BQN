*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/fold.html).*

# Fold and Insert

The closely related 1-modifiers Fold (`´`) and Insert (`˝`) apply a dyadic operand function `𝔽` repeatedly between elements or major cells of `𝕩`. Neither is quite like the APL2-style Reduce operator (`/` or `⌿` in APL), although I sometimes use the term "reduction" to mean either Fold or Insert. There are a bunch of other names like "accumulate" and "aggregate" for this class of calculations—I don't know which is best but I know "catamorphism" is worst.

A distinguishing feature of APL-family reductions is that they don't use an initial value, and try to derive an "identity element" from the operand if the argument array is empty. BQN retains this capability but also allows the programmer to supply an initial value as `𝕨`.

## Fold

As its glyph suggests, Fold is slightly simpler than Insert. The argument `𝕩` must always be a list, and Fold applies `𝔽` between elements—always two at a time—of the list to yield a single result value. In this sense, `𝔽´` removes a layer of [depth](depth.md) from `𝕩`, although it's not necessarily true that the depth of `𝔽´𝕩` is less than that of `𝕩` because the function `𝔽` might increase depth.

        +´ 2‿4‿3‿1
        +´ ⟨2‿4, 3‿1⟩

Any function can be used as an operand. With Maximum (`⌈`) you can find the largest number out of an entire list, and likewise for Minimum (`⌊`).

        ⌈´ 2‿4‿3‿1
        ⌊´ 2‿4‿3‿1
        ×´ 2‿4‿3‿1  # Product as well

The [logic](logic.md) function And (`∧`) tests if all elements of a boolean list are 1, while Or (`∨`) tests if any are 1.

        ∧´ 1‿1‿0
        ∨´ 1‿1‿0

### Identity values

Folding over a list of length 1 never calls the operand function: it returns the lone element unchanged.

        !´ ⟨⎊⟩

Folding over a list of two values applies `𝔽` once, since `𝔽` is always called on two arguments. But what about zero values? Should `𝔽` be applied minus one times? Sort of. BQN checks to see if it knows an *identity value* for the operand function, and returns that, never calling the function. This works for the arithmetic functions we showed above, always returning a single number.

        +´ ⟨⟩  # Add nothing up, get zero
        ⌈´ ⟨⟩  # The smallest number
        ∧´ ⟨⟩  # All the elements in the list are true…

The full list of identity values Fold has to use is shown below.

| Id   | Fn  | Fn  | Id   |
|-----:|:---:|:---:|-----:|
|  `0` | `+` | `-` |  `0` |
|  `1` | `×` | `÷` |  `1` |
|  `1` | `⋆` | `¬` |  `1` |
|  `∞` | `⌊` | `⌈` | `¯∞` |
|  `0` | `∨` | `∧` |  `1` |
|  `0` | `≠` | `=` |  `1` |
|  `0` | `>` | `≥` |  `1` |

### Right-to-left

The functions we've shown so far are associative (ignoring floating point imprecision), meaning it's equally valid to combine elements of the argument list in any order. But it can be useful to fold using a non-associative function. In this case you must know that Fold performs a *right fold*, starting from the array and working towards the beginning.

        ≍○<´ "abcd"

        'a' ≍○< 'b' ≍○< 'c' ≍○< 'd'  # Expanded form

Using the pair function `≍○<` as an operand shows the structure nicely. This fold first pairs the final two characters `'c'` and `'d'`, then pairs `'b'` with that and so on. This matches BQN's right-to-left order of evaluation. More declaratively we might say that each character is paired with the result of folding over everything to its right.

BQN doesn't provide a left Fold (`` ` `` is Scan). However, you can fold from the left by reversing (`⌽`) the argument list and also reversing (`˜`) the operand function's argument order.

        ≍○<˜´ ⌽ "abcd"

One consequence of this ordering is that folding with Minus (`-`) gives an alternating sum, where the first value is added, the second subtracted, the third added, and so on. Similarly, `÷` gives an alternating product, with some elements multiplied and some divided.

        -´ 30‿1‿20‿2‿10

The operand `+⟜÷` is a quick way to compute a [continued fraction](https://en.wikipedia.org/wiki/Continued_fraction)'s value from a list of numbers. Here are a few terms from the continued fraction for *e*.

        +⟜÷´ 2‿1‿2‿1‿1‿4‿1‿1

### Initial element

When the operand isn't just an arithmetic primitive, folding with no initial element can be dangerous. Even if you know `𝕩` isn't empty, saving you from an "Identity not found" error, the case with only one element can easily violate expectations. Here's a somewhat silly example of a function meant to merge elements of the argument into a single list (`∾⥊¨` is a much better way to do this):

        ∾○⥊´ ⟨2‿4≍6‿8,"abcd",0⟩

        ∾○⥊´ ⟨2‿4≍6‿8,"abcd"⟩

        ∾○⥊´ ⟨2‿4≍6‿8⟩

The result always has rank 1, until the one-element case, when `∾○⥊` is never applied and can't deshape anything. Using Fold with lots of complex operands and no initial element can make a program fragile.

However, it's easy to specify an initial element for Fold: simply pass it as `𝕨`. Because `𝕨` behaves like an element of `𝕩`, it doesn't need to be enclosed and will usually have one smaller depth. For `∾○⥊` the natural starting element for a fold that returns a list is the empty list.

        ⟨⟩ ∾○⥊´ ⟨2‿4≍6‿8⟩

The initial element is used in the first function application, so it behaves as though it's added to the end of the list (`∾⟜<˜` would accomplish this as well).

        "end" ∾○⥊´ ⟨"start","middle"⟩

Folding with `𝕨` never needs to come up with an identity value, and the number of function applications is exactly the length of `𝕩`. A function `P` can be applied to each element of `𝕩` before operating using `𝕨P⊸F´𝕩`, which is equivalent to `𝕨 F´ P¨𝕩` except for the order in which `F` and `P` are invoked (if they have side effects).

        "STOP" ⌽⊸∾´ "ABCDE"‿"012"‿"abcd"
