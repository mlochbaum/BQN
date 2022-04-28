*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/constant.html).*

# Constant

<!--GEN combinator.bqn
DrawComp ≍"˙"
-->

It's one of the simple ones: `f˙𝕩` is `f`. And `𝕨f˙𝕩`? It's `f`. Like the [identity functions](identity.md), Constant doesn't compute anything but just returns one of its inputs. It's somewhat different in that it's a deferred modifier, so you have to first apply Constant to its operand and *then* to some arguments for that non-event to happen.

The design of BQN makes Constant unnecessary in most cases, because when a non-operation (number, character, array, namespace) is applied it already returns itself: `π˙` is the same function as `π`. If you've used much [tacit](tacit.md) programming, you've probably written a few [trains](train.md) like `2×+` (twice the sum), which is nicer than the equivalent `2˙×+`. However, a train has to end with a function, so you can't just put a number at the end. Applying `˙` is a convenient way to change the number from a subject to a function role.

        +÷2   # A number

        +÷2˙  # A function

        3 (+÷2˙) 7

When programming with [first-class functions](functional.md), the constant application shortcut becomes a hazard! Consider the program `{𝕨⌾(2⊸⊑) 𝕩}` to insert `𝕨` into an array `𝕩` as an element. It works fine with a number, but with a function it's broken:

        ∞ {𝕨⌾(2⊸⊑) 𝕩} 1‿2‿3‿4

        M ← -
        m {𝕨⌾(2⊸⊑) 𝕩} 1‿2‿3‿4

Here `m` is applied to `2⊑𝕩` even though we want to discard that value. Spelled as `m`, our [context-free grammar](context.md) knows it's a function argument, but this [doesn't affect](../problems.md#syntactic-type-erasure) later usage. [Under](under.md) always applies `𝔽` as a function. The proper definition of the insertion function should use a `˙`, like this:

        m {𝕨˙⌾(2⊸⊑) 𝕩} 1‿2‿3‿4
