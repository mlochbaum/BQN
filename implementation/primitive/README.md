*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/primitive/index.html).*

# Primitive implementation notes

Commentary on the best methods I know for implementing various primitives. Often there are many algorithms that are viable in different situations, and in these cases I try to discuss the tradeoffs.

- [Replicate](replicate.md)
- [Sorting](sort.md)
- [Searching](search.md)
- [Transpose](transpose.md)
- [Randomness](random.md)

Raw speed is of course the most important factor; I also consider predictability and memory usage to be important. Predictability mostly for the benefit of the programmer, but it's also important when there are multiple algorithms to be able to compute which one will be fastest. In some cases an algorithm is best on some subset of inputs, but is effectively useless because it's too difficult to tell if the input falls in that set. Whitney and other K users sometimes profess that binary size is critically important; I don't believe this.

My experience in optimization is mostly with Dyalog APL, which uses 1-byte, 2-byte, and 4-byte integers, 8-byte floats, and bit booleans. These are also the types handled efficiently by SIMD instructions, and I think they are the best choice for any array language without special precision requirements. I am most interested in x86 with vector extensions up to AVX2, as I think this is the hardware most users currently have.

It's difficult to know when better algorithms exist. I try to research the state of the art and to estimate how much room for improvement there is, but it will come as no surprise if I've completely overlooked something that's simple in hindsight, or postulated a lower bound that can be beaten with a clever trick.
