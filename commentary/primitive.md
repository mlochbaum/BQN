*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/primitive.html).*

# What is a primitive?

People sometimes wonder how the set of primitives in BQN was chosen. Outsiders to array programming might assume that the "big idea" of APL is just to take the most common tasks and write them with symbols instead of names—even Dijsktra thought something like this, calling APL a "bag of tricks"! I don't think this is quite right, so I'd like to explain my personal view on why it makes sense to call a few special operations "primitives" and give them dedicated symbols. While I think this overlaps some with the ideas of other array designers, I am speaking only for myself here.

## Names versus symbols

Much of this text will be about why various functions *shouldn't* be considered primitives, so it makes sense to start with a discussion of the disadvantages of symbols and why we wouldn't want everything to use them.

- Words convey meaning more precisely
- Words can be modified or combined in more sophisticated ways
- There are many more words with established meanings
- Words are easier to input and pronounce

A broad theme is that words—that is, language rather than notation—offer more possibilities and shades of meaning. If there are two related concepts, it's often possible to give them names that make both the relation and the difference clear (say, `KeepBefore` and `KeepUpTo`). With symbols this is more difficult: only a few broad relations like mirror reflection (which is error prone!) and juxtaposition are usable. But nuanced words can also be a liability. If there is really only one possibility, then a well-chosen symbol might indicate it better and be easier to remember.

In BQN, syntactic role is also a factor. Letter casing and underscores allow any word to be written with any role. Primitive glyphs follow their own rules, but a primitive has a fixed role. If a value might be either called as a function or passed as an argument, this is easier if it's named.

## Primitive philosophy

Is language design a process of discovery or invention? A bit of both, of course, but I think primitive design should be mostly discovery. That is, if a function feels invented—or worse, engineered—it's not a good fit for a BQN primitive. Discovery means that the thing in question is in some sense external to the person who describes it, so that if two different people discover something then it will be the exact same thing. An invented thing will always bear marks of its inventor, from the little decisions that could have been made differently.

It's not always so clear cut, and there's a little irony in that the *collection* of all the primitives in a language is definitely engineered. While I think it's a good idea to give symbols to things that are more primitive-like and words to things that are less primitive-like, this leaves room to use symbols relatively more as in APL, or words more as in Python, to focus on different functionality to provide, or to select different primitives when there are a few that provide similar functionality.

## Primitive practice

Are there primitives out there waiting to be discovered? I think so: fundamental concepts like addition, mapping, or joining one list to another would be reinvented by any society that could develop programming, and would have exactly the same meaning. But this is sort of a vague assertion, and I have no intention of getting into the question of whether anything "actually" exists. A more practical approach is to start with some properties that I've found to be desirable in APL primitives:

- Simple mathematical description
- One or more simple sets of constraints or axioms that specify it
- Can be used to implement other operations
- Few or no useful variations are possible

These properties tend to go together: while none of them necessarily implies another, it seems rare for a function to only fit half of them. And there are arguments why we might expect this to be the case, in addition to the empirical observation. For example, if the results of a function could be defined by either of two independent constraint sets, it probably doesn't make sense to define a variation that's different on some arguments, because it wouldn't follow those same constraints. And usually complex things are implemented in terms of simpler ones, so a function that gives a nice implementation of another will tend to be simpler.

More surprising, operations that fit those criteria often have some other benefits:

- Fewer edge cases to worry about
- Relevant across multiple domains
- Efficient implementation (theoretically and in hardware)
- Combinations of primitives give useful functionality
- Relationships between primitives can be used in proofs

Again, some properties seem intuitively connected to the ones above but for others the connection isn't so obvious. They are broad patterns that I've observed over years of programming and designing.

## Arithmetic primitives

I can point out that there is already a class of functions that anyone would agree fit the description above, which are the arithmetic functions `+-×÷`. They are indispensible tools, and it's interesting to note that they are also represented with symbols (not necessarily the same ones) in nearly every language.

Why is it that a function as broadly useful as addition should exist at all? It's one example of mathematics (and even if you don't considere programming to be mathematics, it can certainly be described by mathematics) being more structured than direct reasoning can explain. This happens because math imposes structure on itself, by way of proofs.
