*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/birds.html).*

# BQN for birdwatchers

*There's now a [paper](https://dl.acm.org/doi/10.1145/3520306.3534504) ([download](https://raw.githubusercontent.com/codereport/Content/main/Publications/Combinatory_Logic_and_Combinators_in_Array_Languages.pdf)) on this topic! Wild!*

Some people consider it reasonable to name [combinators](primitive.md#modifiers) after types of birds. They make lists like the [Ornithodex](https://wiki.xxiivv.com/site/logic.html#ref) or Lähteenmäki's comprehensive [Combinator birds](https://blog.lahteenmaki.net/combinator-birds.html) (naturally, there's [a list](https://combinatorylogic.com/links.html) for these lists). There is something wrong with these people. Some of these birds are not even real. "Quixotic bird"? Have you not heard of a quail? Nonetheless, I don't judge such afflicted souls (certainly not publicly), and have provided this translation table to explain BQN in terms they can understand.



|   BQN   | Bird 1   | 1        | Bird 2       | 2                              |
| :-----: | -------- | -------- | ------------ | ------------------------------ |
|   `⊣`   | Identity | `I`      | Kestrel      | `K`                            |
|   `⊢`   | Identity | `I`      | Kite         | `KI`                           |
|   `∘`   | Bluebird | `B`      | Blackbird    | `B₁`                           |
|   `○`   | Bluebird | `B`      | Psi          | `ψ`                            |
|   `˙`   | Kestrel  | `K`      |              | `KK`                           |
|   `⊸`   |          | `B₁CBSC` | Queer        | `Q`                            |
|   `⟜`   | Starling | `S`      | ~Dove        | `D`-like: `labcd.ac(bd)`       |
|   `˜`   | Warbler  | `W`      | Cardinal     | `C`                            |
| `k G H` | Dove     | `D`      | Eagle        | `E`                            |
| `F G H` | Phoenix  | `Φ`      | Pheasant     | `Φ₁`                           |

Lambda calculus doesn't have BQN's polymorphism on one or two arguments, so each BQN combinator corresponds to two lambda calculus forms depending on the number of arguments, giving the two columns of birds above.

Inputs are mapped to lambda calculus arguments according to the ordering `𝔽𝔾𝕨𝕩`, and `GFH` for a 3-train `F G H`. For example, when I write that the combination `𝕨 𝔽˜ 𝕩` corresponds to a call of `C` or `labc.acb`, `a` is `𝔽` and `bc` are `𝕨𝕩`.

Bird enthusiast Conor Hoekstra now claims what he originally mistook for a "[Golden Eagle](https://twitter.com/code_report/status/1440208242529882112)" is in fact a Pheasant. Announced in that [paper](https://github.com/codereport/Content/blob/main/Publications/Combinatory_Logic_and_Combinators_in_Array_Languages.pdf) mentioned at the top, the new identification is based on Haskell Curry's use of `Φ₁` for the combinator in a [1931 paper](https://www.jstor.org/stable/1968422).
