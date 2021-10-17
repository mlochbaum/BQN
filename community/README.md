*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/community/index.html).*

# BQN community links

Yes, BQN has users! This page gathers links to work by the community. To get in touch, please use our [chat forums](forums.md).

For code repositories using BQN, see:

- Github repositories [tagged BQN](https://github.com/topics/bqn)
- [bqn-rest](https://codeberg.org/CptJimKirk/bqn-rest), for web APIs
- Josh Holland's [solutions](https://git.sr.ht/~jshholland/trybqn/tree) to TryAPL problems

And the links below point to BQN submissions on some sites that encourage shorter-form programming.

- [Rosetta Code](https://rosettacode.org/wiki/Category:BQN) (consider translating [APL versions](https://rosettacode.org/wiki/Category:APL)?)
- Stack Exchange [Code Golf & Coding Challenges](https://codegolf.stackexchange.com/search?tab=newest&q=BQN)
- Codidact [Code Golf](https://codegolf.codidact.com/posts/search?utf8=%E2%9C%93&search=BQN&sort=age)

And also:

- Some reference pages: [compact functions](https://pastebin.com/raw/ynsghrHM), [compact everything](https://xj-ix.luxe/wiki/bqn/bqn.txt), [big everything](https://gist.github.com/dzaima/52b47f898c5d43f72dc2637d6cdadedd)
- Asher Mancinelli's [youtube channel](https://www.youtube.com/channel/UCZ5sL4E662VP1ZwC4h85ttQ) includes walkthroughs of BQN programs.
- Lukas Hermann writes some [Observable notebooks](https://observablehq.com/@lsh?tab=notebooks) based on BQN.
- [BQN fan art](fanart.md)

## Can I help out?

Certainly! There are never enough hours in the day and contributors from beginner to advanced programmers are all welcome. If you're interested I recommend you ask on the forums first to get a feel for what exactly is needed.

You will certainly feel an urge to skip this paragraph and get to the fun stuff, but the most important resource for implementing a language is **testing** and the most valuable one for building a language community is accessible introductions to the language and **learning materials**. These are both very demanding, but if you're willing to put in the work to advance BQN in the most effective way then this is it. One form of documentation that many users would appreciate is short descriptions—a sentence or two with examples—of the primitives for each glyph that can be displayed as help in the REPL. To be honest I'm lousy at making these and would prefer for someone else to do it.

Work on BQN's **implementation** generally requires a high level of programming skill. We are focusing development effort on [CBQN](https://github.com/dzaima/CBQN) (see this [source overview](https://github.com/dzaima/CBQN/blob/master/src/README.md)). It's true that the entire compiler and a (decreasing) portion of the runtime is written in BQN, but it would be hard to do much with these as they are very nearly complete, and work satisfactorily. On the other hand, there is a lot that needs to be written in C, including [system values](../spec/system.md) and higher-performance [primitives](../implementation/primitive/README.md). And there's no need to work on *our* implementation! BQN's [specification](../spec/README.md) and [tests](../test/README.txt) are there to make sure you can write a conforming implementation, and extend it with your own ideas. It's also possible to take advantage of the self-hosted BQN sources by writing a [virtual machine](../implementation/vm.md) that allows you to embed BQN in the language of your choice.

Building **libraries** for BQN users can make writing programs in the language much more approachable. You are a better judge of which libraries are needed than I. Port some code from another language, implement some useful functionality in a field you specialize in, or try something new that interests you. A library should be structured as a file (which might load other files) that loads a namespace. This isn't too well-documented now, but see the [namespace documentation](../doc/namespace.md) for hints.

Those are possibilities, not limitations. The best way to contribute might be fixing something I never knew was wrong.
