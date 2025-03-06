*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/index.html).*

# Primitive implementation notes

Commentary on the best methods I know for implementing various primitives. Often there are many algorithms that are viable in different situations, and in these cases I try to discuss the tradeoffs.

- [Arithmetic](arithmetic.md)
- [Fold and Scan](fold.md)
- [Replicate](replicate.md)
- [Sorting](sort.md) ([Sortedness flags](flagsort.md))
- [Searching](search.md)
- [Select](select.md)
- [Transpose](transpose.md)
- [Take and Drop](take.md)
- [Randomness](random.md)
- [Data types](types.md)

It may be helpful to read [bencharray](https://mlochbaum.github.io/bencharray/pages/summary.html) measurements and commentary in conjunction with these notes. In addition to the implementations themselves, the [CBQN](https://github.com/dzaima/CBQN) source code has comments at the top of many files in src/builtins/ that compactly list the methods used.

Raw speed is of course the most important factor; I also consider predictability and memory usage to be important. Predictability mostly for the benefit of the programmer, but it's also important when there are multiple algorithms to be able to compute which one will be fastest. In some cases an algorithm is best on some subset of inputs, but is effectively useless because it's too difficult to tell if the input falls in that set. Whitney and other K users sometimes profess that binary size is critically important; I don't believe this.

CBQN uses 1-byte, 2-byte, and 4-byte integers, 8-byte floats, and bit booleans. The various advantages of these types are discussed [here](types.md). We optimize for x86 and 64-bit ARM with vector extensions, focusing on AVX2 rather than AVX-512 because of the slow rollout of these wider instructions.

It's difficult to know when better algorithms exist. I try to research the state of the art and to estimate how much room for improvement there is, but it will come as no surprise if I've completely overlooked something that's simple in hindsight, or postulated a lower bound that can be beaten with a clever trick.
