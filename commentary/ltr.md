*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/ltr.html).*

# Left to right ordering?

APL's right-to-left (RtL) evaluation order is something many programmers ask about, and something I've questioned personally as well. In fact the first significant language I designed, called [I](https://github.com/mlochbaum/ILanguage), used a left to right (LtR) ordering for all code. I hope to work with this ordering again in future languages! And changing BQN's compiler to order things differently wouldn't be too large of a task. But that would be a different language. I'd better stick with BQN for a while instead of building up a pile of partial languages.

I'm still of (at least) two minds about a left-to-right APL, in that I'm fairly sure I prefer writing code from left to right but I'm also worried this won't fit in with other aspects of an APL-family language. In BQN I decided that changing the order relative to APL was simply too radical. Why the cowardice? Well, I hope it's better described as pragmatism. BQN is designed to avoid losing the good parts of APL\360, up to my own interpretation of course. For a big change like LtR, I honestly can't say whether it leads to a better language, and in the worst case it could make the entire thing unusable. BQN makes a lot of changes, with a few candidates like this (trying to unify functions and modifiers would be another example). But the risk profile for these big unknowns isn't acceptable: only one has to go wrong to ruin my work, and as more are added this goes from possible to likely. So I stuck with relatively smaller changes I was more confident in.

I've thought about adding some sort of pipe notation (the `$` character is open) to BQN, but I'm currently against it. It would be complicated and hard to design, and at the end of the day not all that much better than splitting a statement into a sequence of assignments.

## Other attempts

As for programming precedent, stack-based languages such as Forth go from left to right. In Java-style object-oriented programming, methods go from left to right. This style of "method chaining" is particularly prevalent in Javascript.

- There's an [APL Wiki category](https://aplwiki.com/wiki/Category:Left_to_right) that gathers some left-to-right languages. [Jelly](https://github.com/DennisMitchell/jellylanguage) is likely the most widely used of these, but being a code golfing language it's explicitly designed for brevity first and usability second.
- [xs](https://github.com/smabie/xs) is a concatenative (or stack-based) array language not yet on APL Wiki.
- Milan Lajtoš is working on the Fluent language for his "new kind of paper". Its LtR nature is mentioned in [this post](https://mlajtos.mu/posts/new-kind-of-paper-2).
- Adám Brudzewsky and others did some investigation into LtR APL specifically in the [LPA/NQB thread](https://topanswers.xyz/apl?q=1660).

## General considerations

English text is read left to right. This in itself is not decisive in either direction: many contend that the way to read a function is first to read the function, then its argument. Although I usually read the other way, I do find that order to be useful sometimes.

- Function application is pronounced "f of x", following the mathematical convention.
- Similarly, composition is pronounced "g of f" or "g compose f". The alternative "f then g", however, feels more natural to me.
- Transformation is nearly always given with the initial state first followed by the final state: "from rags to riches". Sometimes programmers use this convention as well: "png2jpg".

Although mathematical functions are usually evaluated right-to-left, infix operations such as basic arithmetic are usually left-to-right. Of note is the fact that infinite series which start at zero and proceed upwards must be thought of as being evaluated in the positive direction, which is universally rendered as rightwards in number lines.

- Function application is written function-first.
- Function composition is ordered right-to-left.
- Arrows indicating function types and in diagrams are written left-to-right.

See page 147 of [this report](http://www.hpl.hp.com/techreports/Compaq-DEC/SRC-RR-169.pdf) for a more thorough discussion of how these three contexts interact.

## In APL

The most pressing problem that LtR ordering would solve is that a sequence of expressions (separated by `,⋄` or newlines) runs in source order, while function applications within an expression go the other way. List notation makes it worse, and with large block functions the order's nearly impossible to follow: instead each one should be named, and then they can be assembled into expressions later.

But LtR introduces a similar problem with assignment: the name really needs to be on the left to allow easily scanning definitions, but this conflicts with the evaluation order. Placing the name on the left would also break inline assignment (where an intermediate result is assigned and execution continues), although many people consider this an anti-pattern anyway.

While APL functions run right to left, *modifiers* run left to right. This is harder to learn but it's possible the opposing directions are better for expressivity. On the other hand, if the directions are aligned then it makes sense to unify functions and modifiers. The thing that prevents it in BQN is that a 1-argument function has only a right argument while a 1-modifier uses a left operand: to unify them, `𝕗` would have to correspond to `𝕩` and `𝕘` to `𝕨`, which I consider dangerously confusing.
