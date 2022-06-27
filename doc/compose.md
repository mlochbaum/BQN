*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/compose.html).*

# Atop and Over

<!--GEN combinator.bqn
DrawComp ≍"∘○"
-->

Atop and Over are 2-modifiers that extend the idea of "apply this, then that" in two different ways. They're modelled after the mathematical notation f∘g to compose two functions, and both do the same thing when there's one argument: either `F∘G x` or `F○G x` is `F G x`.

| `Cmp` | `Cmp 𝕩` | `𝕨 Cmp 𝕩`      | Unified     | On list
|-------|---------|:--------------:|:-----------:|:-------:
| `F∘G` | `F G 𝕩` | `F 𝕨 G 𝕩`      | `{𝔽𝕨𝔾𝕩}`    | `F G´𝕩`
| `F○G` | `F G 𝕩` | `(G 𝕨) F G 𝕩`  | `{(𝔾𝕨)𝔽𝔾𝕩}` | `F´G¨𝕩`

When there are two arguments, we might say Atop treats the right operand `𝔾` as primary and Over treats `𝔽` as primary—the primary operand becomes dyadic while the other is always monadic. Atop applies `𝔾` directly, making it more like mathematical composition if we suppose that `𝔾` is a function that can take a pair of arguments. Over instead makes two calls to apply `𝔾` separately to both arguments, then passes the results to `𝔽`.

## Atop

Of the two modifiers on this page, Atop is more common but less impactful. The composition `F∘G` is equivalent to the 2-[train](train.md) `F G` (the trains page has hints on when you'd choose one or the other). Its definition `{F𝕨G𝕩}` means that `G` is applied to one or two arguments and `F` is applied monadically to the result. It's sort of a "default way" to compose two functions. Keeps [tacit](tacit.md) programming syntax running smoothly, without making noise about it. Not like that busybody `⊸`. Some examples:

`↕∘≠` is useful with one argument: `↕≠l` is a list of indices for `l`.

`⌊∘÷` is useful with two arguments: `⌊a÷b` is the integer part when dividing `a` by `b`, often paired with the [remainder](arithmetic.md#additional-arithmetic) `b|a`.

`⊔∘⊐` is useful with one or two arguments. From right to left, we have [Classify](selfcmp.md#classify)/[Index-of](search.md#index-of) (`⊐`) to convert values to indices, and [Group Indices](group.md) to group the indices. Er, that sounds good but what it *actually* does is to group indices of Group's argument, which correspond to indices of the original `𝕩`, according to their values as returned by `⊐`. Without a left argument, this means indices of `𝕩` are grouped corresponding to `⍷𝕩`, and if `𝕨` is provided the groups correspond to `𝕨` instead.

        ⊔∘⊐ "bbeabee"

        "abcde" ⊔∘⊐ "bbeabee"

## Over

Once you get used to Over, it's painful to go without it. I'd use it all the time in C if I could.

Usually Over is used just for the dyadic meaning. If you have a composition that only works with one argument it's typical to write it with Atop (`∘`). And cases that work with one or two arguments do come up from time to time, but they're fairly rare, so the examples below are just for two arguments.

A classic is the function `≡○∧`, which tests whether `𝕨` is a reordering of `𝕩`. The idea is to sort both arrays with `∧` to remove the ordering information, then see if they match.

        "BQN" ≡○∧ "QNB"
        "BQN" ≡○∧ "BBQ"

Another example is `/○⥊`, used to filter elements in a high-rank array. Alone, `/` won't do this because there's no automatic choice of ordering for the results. Applying [Deshape](reshape.md) (`⥊`) to both chooses index order.

        ⊢ a ← "qBrs"≍"QtuN"

        a < 'a'  # Capital letters

        (a<'a') / a  # Not allowed

        (a<'a') /○⥊ a

Over is closely connected with the [Under](under.md) modifier, which performs all the same steps but then undoes `𝔾` afterwards.
