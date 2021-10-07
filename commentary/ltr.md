*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/ltr.html).*

# Left to right ordering?

APL's right-to-left evaluation order is something many programmers ask about, and something I've questioned personally as well. In fact the first significant language I designed, called [I](https://github.com/mlochbaum/ILanguage), used a left to right ordering for all code.

I settled fairly quickly on sticking to the left to right ordering in BQN. I'm still of (at least) two minds about this, in that I'm fairly sure I prefer writing code from left to right but I'm also worried this won't fit in with other aspects of an APL-family language. BQN is an entirely different project than I is, and it's informed much more by APL than I. So I didn't so much switch to RtL as start over, and not switch back to LtR. I wrote about that in [this message](https://chat.stackexchange.com/transcript/52405?m=57926316#57926316) (lots more discussion above).

## Considerations

English text is read left to right. This in itself is not decisive in either direction: many contend that the way to read a function is first to read the function, then its argument. Although I usually read the other way, I do find that order to be useful sometimes.

- Function application is pronounced "f of x", following the mathematical convention.
- Similarly, composition is pronounced "g of f" or "g compose f". The alternative "f then g", however, feels more natural to me.
- Transformation is nearly always given with the initial state first followed by the final state: "from rags to riches". Sometimes programmers use this convention as well: "png2jpg".

Although mathematical functions are usually evaluated right-to-left, infix operations such as basic arithmetic are usually left-to-right. Of note is the fact that infinite series which start at zero and proceed upwards must be thought of as being evaluated in the positive direction, which is universally rendered as rightwards in number lines.

- Function application is written function-first.
- Function composition is ordered right-to-left.
- Arrows indicating function types and in diagrams are written left-to-right.

See page 147 of [this report](http://www.hpl.hp.com/techreports/Compaq-DEC/SRC-RR-169.pdf) for an interesting argument.

As for programming precedent, stack-based languages such as Forth go from left to right. In Java-style object-oriented programming, methods go from left to right. This style of "method chaining" is particularly prevalent in Javascript.
