*View this file with syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/primitive.html).*

# What is a primitive?

People sometimes wonder how the set of primitives in BQN was chosen. Outsiders to array programming might assume that the "big idea" of APL is just to take the most common tasks and write them with symbols instead of names—even Dijkstra said something like this, calling APL a "bag of tricks"! I don't think this is quite right, so I'd like to explain my personal view on why it makes sense to call a few special operations "primitives" and give them dedicated symbols. While I think this overlaps some with the ideas of other array designers, I am speaking only for myself here.

## Names versus symbols

Much of this text will be about why various functions *shouldn't* be considered primitives, so it makes sense to start with a discussion of the disadvantages of symbols and why we wouldn't want everything to use them.

- Words convey meaning more precisely
- Words can be modified or combined in more sophisticated ways
- There are many more words with established meanings
- Words are easier to input and pronounce

A broad theme is that words—that is, language rather than notation—offer more possibilities and shades of meaning. If there are two related concepts, it's often possible to give them names that make both the relation and the difference clear (say, `KeepBefore` and `KeepUpTo`). With symbols this is more difficult: only a few broad relations like mirror reflection (which is error prone!) and juxtaposition are usable. But nuanced words can also be a liability. If there is really only one possibility, then a well-chosen symbol might indicate it better and be easier to remember.

In BQN, syntactic role is also a factor. Letter casing and underscores allow any word to be written with any role, while a primitive has a fixed role. If a value might be either called as a function or passed as an argument, this will be easier if it's named.

## Primitive philosophy

Is language design a process of discovery or invention? A bit of both, of course, but I think primitive design should be mostly discovery. That is, if a function feels invented—or worse, engineered—it's not a good fit for a BQN primitive. Discovery means that the thing in question is in some sense external to the person who describes it, so that if two different people discover something then it will be the exact same thing. An invented thing will always bear marks of its inventor, from the little decisions that could have been made differently.

It's not always so clear cut, and there's a little irony in that the *collection* of all the primitives in a language is definitely engineered. While I think it's a good idea to give symbols to things that are more primitive-like and words to things that are less primitive-like, this leaves room to use symbols relatively more as in APL, or words more as in Python, to focus on different functionality to provide, or to select different primitives when there are a few that provide similar functionality.

I do think some acts of engineering are okay, if the purpose is only to make the underlying primitive functionality more accessible. For example, Range (`↕`) combines two primitive functions with disjoint domains, and Rank (`⎉`) sticks a few numbers into an arbitrarily-ordered list. I still view these as a little unfortunate, but acceptable for added convenience.

## Primitive practice

Are there primitives out there waiting to be discovered? I think so: fundamental concepts like addition, mapping, or joining one list to another would be reinvented by any society that could develop programming, and would have exactly the same meaning. But this is sort of a vague assertion, and I have no intention of getting into the question of whether anything "actually" exists. A more practical approach is to start with some properties that I associate with high-quality tools of thought:

- Simple mathematical description (or better, more than one)
- Simple specification in terms of constraints (ditto)
- Can be used to implement other operations
- Few or no useful variations are possible

These properties tend to go together: while none of them necessarily implies another, it seems rare for a function to only fit half of them. And there are arguments why we might expect this to be the case, in addition to the empirical observation. For example, if the results of a function could be specified by either of two independent constraint sets, it probably doesn't make sense to define a variation that's different on some arguments, because it wouldn't follow those same constraints. And usually complex things are implemented in terms of simpler ones, so a function that gives a nice implementation of another will tend to be simpler.

More surprising, operations that fit those criteria often have some other benefits:

- Fewer edge cases to worry about
- Relevant across multiple domains
- Efficient implementation (theoretically and in hardware)
- Combinations of primitives give useful functionality
- Relationships between primitives can be used in proofs

Again, some properties seem intuitively connected to the ones above but for others the connection isn't so obvious. They are broad patterns that I've observed over years of programming and designing.

## Arithmetic primitives

I can point out that there is already a class of functions that anyone would agree fit the description above, which are the arithmetic functions `+-×÷`. They are indispensable tools, and it's interesting to note that they are also represented with symbols (not necessarily the same ones) in nearly every language.

Why is it that a function as broadly useful as addition should exist at all? It's one example of mathematics (and even if you don't consider programming to be mathematics, it can certainly be described by mathematics) being more structured than direct reasoning can explain. This happens because math imposes structure on itself, as facts about one mathematical object can constrain the behavior of another. The structure might manifest as theorems mathematicians can prove, theorems they can't, or the fuzzier ideas sometimes called "folk theorems". A good illustration is [Ulam's spiral](https://en.wikipedia.org/wiki/Ulam%27s_spiral), the tendency of prime numbers to follow arithmetic patterns. There are a few proofs about specific patterns, and conjectures about others. The broader folk theorem that primes will show patterns in *any* simple arithmetic arrangement is too vague to even prove, but has lots of supporting evidence and is of practical use to mathematicians working in the field.

<!--GEN
p ← 176‿48
dim ← 2 × p + d ← 168‿56

rc ← At "stroke=currentColor|fill=none|stroke-width=0.8"
tg ← "g"At"font-size=14px"
cg ← "g"At"text-anchor=middle|font-size=19px"
lg ← "g"At"stroke=currentColor|stroke-width=0.4"

Text ← ("text" Attr "dy"‿"0.35em"∾·Pos d⊸×)⊸Enc
t ← ((0.63-˜0.36⌊↕3)(0.22⊸+⊸≍¨⋈≍˜¨)1∾0.5+↕2) Text¨¨ ⟨
  "Definition"‿"Exact"‿"Fuzzy"
  "Application"‿"Specific"‿"General"
⟩

((-p+d×0.1‿0.3)∾dim) SVG ("g"At"fill=currentColor") Enc ⟨
  "rect" Elt rc ∾ (Pos 0‿0)∾"width"‿"height"≍˘FmtNum 2×d
  tg Enc "end"‿"middle" ("g"Attr"text-anchor"⋈⊢)⊸Enc¨ t
  cg Enc (⥊≍⌜˜0.5+↕2) Text¨ "Algorithm"‿""‿"Primitive"‿"Design pattern"
  lg Enc (<"xy"≍⌜"12") ("line" Elt ≍˘○⥊)⟜(FmtNum d×⊢)¨ ⋈⟜⌽ 1‿1≍¯0.34‿2.1
⟩
-->

Folk theorems are a lot like design patterns in programming, in that they can guide or describe an implementation but don't appear in the code directly. A primitive, in contrast, is a precisely specified operation, so it can be used for both organization and in the actual code.

Primitives obey mathematical rules—for example that subtraction undoes addition. A sequence of primitives can be manipulated algebraically using these rules, changing it to a different sequence that does the same computation. Symbols are a good fit for algebraic manipulation because the lower overhead required to read them makes it easier to recognize groups of symbols and move them around. The programmer still has to choose what changes to make, but primitive symbols make it easier to perform them correctly.

## Programming with primitives

APL adds a few arithmetic primitives that aren't common in other languages, but its main contribution is array primitives. Some later APL-family languages including BQN also add combinators—tacit primitives for working with functions (mathematics does have the composition `∘`; the difference is that APL's combinators are for functions of one or two arguments).

The main reason for the three domains of arithmetic, functions, and arrays is simply that these are the main types used for computations in BQN. It might be interesting to note that there are no namespace primitives. In BQN namespaces are used for code organization, not computation. Something similar happens with arrays in C: they aren't the object of computation, so while there are operators for working with pointers (addition, referencing and dereferencing), there aren't any for arrays. One step that makes BQN arrays more suitable to have primitives defined on them is that they are immutable.

These days many popular langauges have standard functions or methods for working with arrays, like concatenation, reversal, and mapping. But they're usually treated more as utilities than primitives, and in some cases have extra functionality tacked on that makes them more complicated and less composable (for example Javascript's mapping passes extra arguments to the operand).

BQN's set of primitives is made with more emphasis on simple and consistent design, and of course each primitive is written with a single symbol. In a system like this, the benefits of individual primitives like fewer edge cases and applicability to multiple domains reinforce each other. Algebraic manipulation also becomes a powerful tool for refactoring, modifying, or optimizing code safely. I think that recognizing "primitiveness" as a feature of certain functions has been very helpful in designing BQN and that understanding individual primitives and their relationships makes it easier to develop correct and general code more quickly.
