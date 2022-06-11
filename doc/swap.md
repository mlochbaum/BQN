*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/swap.html).*

# Self and Swap

<!--GEN combinator.bqn
DrawComp ≍"˜"
-->

Have the arguments to a function, but not in the right places? Self/Swap (`˜`) will fix it for you. There are only two APL-style 1-modifiers—that is, operands used as functions and applied to arguments—that make sense, and `˜` is both of them. It always calls its operand with two arguments: if there are two arguments to begin with, they are exchanged (Swap), and if there's only one, it's used for both arguments (Self).

| Name | Call   | Definition
|------|--------|:----------:
| Self | ` F˜𝕩` |    `𝕩F𝕩`
| Swap | `𝕨F˜𝕩` |    `𝕩F𝕨`

Since `𝕩` always becomes the left argument, these two definitions can be unified as `{𝕩𝔽𝕨⊣𝕩}`, noting that [Left](identity.md) returns `𝕨` if it's given and `𝕩` if not.

Swap is arguably less transformative. Some common examples are `-˜` and `÷˜`, since these two functions run the [wrong way](../commentary/problems.md#subtraction-division-and-span-are-backwards) for BQN's evaluation order. This is very often useful in [tacit](tacit.md) programming, and less needed for explicit code. While it sometimes allows for shorter code by making a pair of parentheses unnecessary (say, `(a×b)-c` is `c-˜a×b`), I personally don't think this is always a good idea. My opinion is that it should be used when it makes the semantics a better fit for BQN, but putting the primary argument on the right and a secondary or control argument on the left.

        'a' ⋈˜ 'b'

        " +" ⊏˜ 0‿1‿1‿0‿0≍1‿0‿1‿0‿1

Moving on, Self re-uses one argument twice. In this way it's a little like [Over](compose.md), which re-uses one *function* twice. A common combination is with [Table](map.md#table), `⌜˜`, so that the operand function is called on each combination of elements in `𝕩` to form a square result. For example, `=⌜˜` applied to `↕n` gives the identity matrix of size `n`.

        ×˜ 4

        =⌜˜ ↕3

Note that Self isn't needed with [Before](hook.md) (`⊸`) [and After](hook.md) (`⟜`), which essentially have a copy built in: for example `F⊸G 𝕩` is the same as `F⊸G˜ 𝕩` by definition.
