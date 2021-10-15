*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/birds.html).*

# BQN for birdwatchers

Some people consider it reasonable to name [combinators](primitive.md#modifiers) after types of birds. [Here's](https://www.angelfire.com/tx4/cus/combinator/birds.html) one compendium of such names, albeit still missing the Phoenix or `S'` combinator `labcd.a(bd)(cd)`. There is something wrong with these people. Some of these birds are not even real. "Quixotic bird"? Have you not heard of a quail? Nonetheless, I don't judge such afflicted souls (certainly not publicly), and have provided this translation table to explain BQN in terms they can understand.

| BQN     | Bird      |  1    | Bird        |  2
|:-------:|-----------|-------|-------------|---------
| `⊣`     | Identity  | `I`   | Kestrel     | `K`
| `⊢`     | Identity  | `I`   |             | `KI`
| `∘`     | Bluebird  | `B`   | Blackbird   | `B₁`
| `○`     | Bluebird  | `B`   | ~Dovekies   | `D₂`-like: `labcd.a(bc)(bd)`
| `˙`     | Kestrel   | `K`   |             | `KK`
| `⊸`     |           | `R*S` | Queer       | `Q`
| `⟜`     | Starling  | `S`   | ~Dove       | `D`-like: `labcd.ac(bd)`
| `˜`     | Warbler   | `W`   | Cardinal    | `C`
| `k G H` | Dove      | `D`   | Eagle       | `E`
| `F G H` | Phoenix   | `S'`  | ~Bald Eagle | `Ê`-like: `labcde.a(bde)(cde)`

Lambda calculus doesn't have BQN's polymorphism on one or two arguments, so each BQN combinator corresponds to two lambda calculus forms depending on the number of arguments, giving the two columns of birds above.

Inputs are mapped to lambda calculus arguments according to the ordering `𝔽𝔾𝕨𝕩`, and `GFH` for a 3-train `F G H`. For example, when I write that the combination `𝕨 𝔽˜ 𝕩` corresponds to a call of `C` or `labc.acb`, `a` is `𝔽` and `bc` are `𝕨𝕩`.
