*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/birds.html).*

# BQN for birdwatchers

*There's now a [paper](https://dl.acm.org/doi/10.1145/3520306.3534504) ([download](https://raw.githubusercontent.com/codereport/Content/main/Publications/Combinatory_Logic_and_Combinators_in_Array_Languages.pdf)) on this topic! Wild!*

Some people consider it reasonable to name [combinators](primitive.md#modifiers) after types of birds. [Here's](https://blog.lahteenmaki.net/combinator-birds.html) one compendium of such names, and [another](https://wiki.xxiivv.com/site/ornithodex.html) that lacks its obsessive completeness but makes up for it with [rambling accounts](https://wiki.xxiivv.com/site/logic.html) of imagined forests. There is something wrong with these people. Some of these birds are not even real. "Quixotic bird"? Have you not heard of a quail? Nonetheless, I don't judge such afflicted souls (certainly not publicly), and have provided this translation table to explain BQN in terms they can understand.

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
| `F G H` | Phoenix  | `S'`     | Golden Eagle | `Ê`-like: `labcde.a(bde)(cde)` |

Lambda calculus doesn't have BQN's polymorphism on one or two arguments, so each BQN combinator corresponds to two lambda calculus forms depending on the number of arguments, giving the two columns of birds above.

Inputs are mapped to lambda calculus arguments according to the ordering `𝔽𝔾𝕨𝕩`, and `GFH` for a 3-train `F G H`. For example, when I write that the combination `𝕨 𝔽˜ 𝕩` corresponds to a call of `C` or `labc.acb`, `a` is `𝔽` and `bc` are `𝕨𝕩`.

The name "Golden Eagle" is a [fever dream](https://nitter.net/code_report/status/1440208242529882112#m) of bird enthusiast Conor Hoekstra, who saw it emerge disordered from the Bald Eagle when arguments `fg` are set equal to `cd`.
