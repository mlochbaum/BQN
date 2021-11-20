*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/functional.html).*

# Functional programming

BQN boasts of its functional capabilities, including first-class functions. What sort of functional support does it have, and how can a BQN programmer exercise these and out themself as a Schemer at heart?

First, let's be clear about what the terms we're using mean. A language has *first-class functions* when functions (however they are defined) can be used in all the same ways as "ordinary" values like numbers and so on, such as being passed as an argument or placed in a list. Lisp and JavaScript have first-class functions, C has unsafe first-class functions via function pointers, and Java 7 and APL don't have them as functions can't be placed in lists or used as arguments. This doesn't mean every operation is supported on functions: for instance, numbers can be added, compared, and sorted; while functions could perhaps be added to give a train, comparing or sorting them as functions (not representations) isn't computable, and BQN doesn't support any of the three operations when passing functions as arguments.

Traditionally, APL has worked around its lack of first-class functions with operators, that is, second-order functions. Arrays in APL are first class while functions are second class and operators are third class, and each class can act on the ones before it. However, the three-tier system has some obvious limitations that we'll discuss, and BQN removes these by making every type first class.

<!--GEN
pl ← <˘∘‿2⥊⟨
  "APL",        25‿47
  "Pascal",     45‿12
  "C",          36‿10
  "Java",       48‿17
  "C#",         40‿20
  "Python",     28‿13
  "Javascript", 23‿17
  "Julia",      16‿22
  "Lisp",       15‿28
  "Scheme",     15‿31
  "BQN",        16‿38
  "Joy",        28‿42
  "Rust",       36‿25
  "F#",         28‿23
  "Haskell",    30‿36.5
  "Idris",      26‿30
  "Coq",        26‿32
⟩
arr ← ⟨
  ⟨"Java 8", "Java", ¯11‿¯1, ¯3⟩
  ⟨"",       "APL",  "BQN",   7⟩
⟩
cat ← ⟨
  ⟨"First-class",    0, ¯2, "bluegreen", 240, 252, 220, 190,   0⟩
  ⟨"Function-level", 1, ¯2, "red",       220, 320, 130, 180, ¯34⟩
  ⟨"Pure",           1,  3, "purple",    310, 360, 120,  90,  12⟩
  ⟨"Typed",          0, ¯1, "green",     310, 290, 110,  95, ¯23⟩
  ⟨"Dependently",    0,  1, "yellow",    260, 300,  45,  45,   0⟩
⟩

gr ← "g" At "font-size=18px|text-anchor=middle|fill=currentColor"
Circ ← {
  el ← At"style=fill-opacity:0.2;stroke-opacity:0.8|stroke-width=3"
  txt← "text"At"font-size=16|stroke-width=0.4|dy=0.33em"
  (n‿o‿l)‿⟨c⟩‿p‿r‿t ← 3‿1‿2‿2‿1 /⊸⊔ 𝕩
  id ← "cat"∾𝕨
  Fn ← ⊣∾"("∾Fmt∘⊢∾")"˙
  tr ← ("translate"Fn p) ∾ 0⊸≠◶⟨"","rotate"⊸Fn⟩t
  tp ← "textPath"Attr∘‿2⥊⟨"href","#"∾id,"startOffset","%"∾˜FmtNum 25+6×l⟩
  Ell  ← ∾"maa"∾⟜Fmt¨0⌾(¯1⊸⊑)⊸{⟨-𝕨⟩∾(𝕩∾0‿1∾¬o)⊸∾¨2‿¯2×<𝕨}
  Path ← "path" Elt ∾⟜("d"⋈Ell∘+⟜r)
  ("g"Attr"transform"‿tr≍"class"‿c) Enc ⟨
    el Path 0
    (∘‿2⥊⟨"style","display:none","id",id⟩) Path 9
    (txt Attr"class"‿c) Enc tp Enc n
  ⟩
}
To ← {
  PlPos ← ((⊑¨pl)⊑∘⊐<)⊑(1⊑¨pl)˙
  n‿f‿t‿c ← 𝕩
  f ↩ PlPos f ⋄ t ↩ (@≤⊑)◶⟨f⊸+, PlPos⟩ t
  w ← 1‿¯1×⌽ u ← v ÷ l ← +´⌾(×˜) v ← -˜´ p ← 10×f‿t
  q ← ∾⟜⌽1=↕4 ⋄ m←l-50
  a ← +˝w‿u× -⟜»˘ ((c×2¨˝⊸»)×⎉1·×⟜¬¯1⊸⊏÷m˙)⊸+ +`˘ ⍉>∾⟜(⌽1‿¯1⊸×¨)⟨¯5‿¯1,1.5‿m,¯4‿¯1,7.5‿14⟩
  d ← ⟨"d", ∾("M"∾q⊏"lq")∾⟜Fmt¨⟨(⊑p)+0‿4-˜(c×w)+26×u⟩∾((c×w)+÷⟜2)⊸∾¨⌾(q⊸/)a⟩
  lab ← (0<≠)◶⟨⟩‿{⟨
    ("text"At"font-size=8|dy=-0.2em") Enc ("textPath"At"href=#arr|startOffset=80%") Enc 𝕩
  ⟩} n
  path ← "path" At "stroke=currentColor|fill=none|opacity=0.9|stroke-width="∾FmtNum 0.9+0.4×¬≠lab
  ⟨path At⟜"id=arr"⍟(≠lab)⊸Elt d⟩ ∾ lab
}

0‿0‿512‿512 SVG gr Enc ∾⟨
  ⋈("text"Attr"font-size"‿"24"∾Pos 256‿38) Enc """Functional programming"""
  ('0'+↕∘≠)⊸(Circ¨) cat
  Enc˜⟜("text" Attr ·Pos 10⊸×)´¨ pl
  ∾To¨ arr
⟩
-->

The term *functional programming* is more contentious, and has many meanings some of which can be vague. Here I use it for what might be called *first-class functional programming*, programming that makes significant use of first-class functions; in this usage, Scheme is probably the archetypal functional programming language. However, other definitions are also worth mentioning. APL is often called a functional programming language on the grounds that functions can be assigned and manipulated, and called recursively, all characteristics it shares with Lisp. I prefer the term *function-level programming* for this usage. A newer usage, which I call *pure functional programming*, restricts the term "function" to mathematical functions, which have no side effects, so that functional programming is programming with no side effects, often using monads to accumulate effects as part of arguments and results instead. Finally, *typed functional programming* is closely associated with pure functional programming and refers to languages influenced by type theory such as [Haskell](https://www.haskell.org/), [F#](https://fsharp.org/), and [Idris](https://www.idris-lang.org/) (the last of which even supports *[dependently-typed](https://en.wikipedia.org/wiki/Dependent_type) functional programming*, but I already said "finally" so we'll stop there). Of these, BQN supports first-class functional and function-level programming, allows but doesn't encourage pure functional programming, and does not support typed functional programming, as it's dynamically and not statically typed.

Another topic we are interested in is *lexical scoping* and *closures*. [Lexical scoping](lexical.md) means that the realm in which a variable exists is determined by its containing context (in BQN, the surrounding set of curly braces `{}`, if any) within the source code. A closure is really an implementation mechanism, but it's often used to refer to a property of lexical scoping that appears when functions defined in a particular block can be accessed after the block finishes execution. For example, they might be returned from a function or assigned to a variable outside of that function's scope. In this case the functions can still access variables in the original scope. I consider this property to be a requirement for a correct lexical scoping implementation, but it's traditionally not a part of APL: implementation might not have lexical scoping (for example, J and I believe [A+](https://aplwiki.com/wiki/A+) use static scoping where functions can't access variables in containing scopes) or might cut off the scope once execution ends, leading to value errors that one wouldn't predict from the rules of lexical scoping.

## Functions in APL

This seems like a good place for a brief and entirely optional discussion of how APL handles functions and why it does it this way. As mentioned above, APL's functions are second class rather than first class. But the barriers to making functions first-class objects have been entirely syntactic and conceptual, not technical. In fact, the J language has for a long time had [a bug](http://www.jsoftware.com/pipermail/programming/2013-January/031260.html) that allows an array containing a function to be created: by selecting from the array, the function itself can even be passed through tacit functions as an argument!

The primary reason why APL doesn't allow functions to be passed as arguments is probably syntax: in particular, there's no way to say that a function should be used as the left argument to another function, as an expression like `F G x` with functions `F` and `G` and an array `x` will simply be evaluated as two monadic function applications. However, there's no syntactic rule that prevents a function from returning a function, and Dyalog APL for example allows this (so `⍎'+'` returns the function `+`). Dyalog's `⎕OR` is another interesting phenomenon in this context: it creates an array from a function or operator, which can then be used as an element or argument like any array. The mechanism is essentially the same as BQN's first class functions, and in fact `⎕OR`s even share a form of BQN's [syntactic type erasure](../commentary/problems.md#syntactic-type-erasure), as a `⎕OR` of a function passed as an operand magically becomes a function again. But outside of this property, it's cumbersome and slow to convert functions to and from `⎕OR`s, so they don't work very well as a first-class function mechanism.

Another reason for APL's reluctance to adopt first-class functions is that Iverson and others seemed to believe that functions fundamentally are not a kind of data, because it's impossible to uniquely represent, compare, and order them. One effect of this viewpoint is J's gerund mechanism, which converts a function to an array representation, primarily so that lists of gerunds can be created. Gerunds are nested arrays containing character vectors at the leaves, so they are arrays as Iverson thought of them. However, I consider this conversion of functions to arrays, intended to avoid arrays that contain "black box" functions, to be a mistake: while it doesn't compromise the purity of arrays, it gives the illusion that a function corresponds to a particular array, which is not true from the mathematical perspective of functions as mappings from an arbitrary input to an output. I also think the experience of countless languages with first-class functions shows that there is no practical issue with arrays that contain functions. While having all arrays be concrete entities with a unique canonical representation seems desirable, I don't find the existence of arrays without this property to be detract from working with arrays that do have it.

## Functional programming in BQN

*Reminder: I am discussing only first-class functional programming here, and not other concepts like pure or typed functional programming!*

What does functional programming in BQN look like? How is it different from the typical APL style of manipulating functions with operators?

### Working with roles

First, let's look at the basics: a small program that has functions as its argument and result. The function `Lin` below gives a [linear approximation](https://en.wikipedia.org/wiki/Linear_approximation) to its function argument based on the values at 0 and 1. To find these two values, we call the argument as a function by using its uppercase spelling, `𝕏`.

    Lin ← {
      v0 ← 𝕏 0
      v0 + ((𝕏 1) - v0) × ⊢
    }

We can pass it the [exponential](arithmetic.md#basic-arithmetic) function as an argument by giving it the name `Exp` and then referring to it in lowercase (that is, in a subject role). The result is a [train](train.md) that adds 1 to *e*-1 times the argument (we'll discuss only tacit functions here; for blocks see [lexical scoping](lexical.md)).

        Lin ← { v0←𝕏0 ⋄ v0+((𝕏1)-v0)×⊢ }  # (copy of above)
        Exp ← ⋆
        Lin exp

As with all functions, the result of `Lin` has a subject role. To use it as a function, we give it a name and then use that name with an uppercase spelling.

        expLin ← Lin exp
        ExpLin 5

A tricker but more compact method is to use the 1-modifier `{𝔽}`, as the input to a modifier can have a subject or function role but its output always has a function role.

        (Lin exp){𝔽} 5

Not the most accurate approximation, though.

        Exp 5

Note also in this case that we could have used a modifier with a very similar definition to `Lin`. The modifier is identical in definition except that `𝕏` is replaced with `𝔽`.

    _lin ↩ {
      v0 ← 𝔽 0
      v0 + ((𝔽 1) - v0) × ⊢
    }

Its call syntax is simpler as well. In other cases, however, the function version might be preferable, for example when dealing with arrays of functions or many arguments including a function.

        _lin ↩ { v0←𝔽0 ⋄ v0+((𝔽1)-v0)×⊢ }  # (copy again)
        Exp _lin 5

### Arrays of functions

It's very convenient to put a function in an array, which is fortunate because this is one of the most important uses of functions as subjects. Here's an example of an array of functions with a [fold](fold.md) applied to it, composing them together.

        {𝕎∘𝕏}´ ⋆‿-‿(×˜)

Like any function, this one can be given a name and then called. A quirk of this way of defining a function is that it has a subject role (it's the result of the function `{𝕎∘𝕏}´`) and so must be defined with a lowercase name.

        gauss ← {𝕎∘𝕏}´ ⋆‿-‿(×˜)
        Gauss 2

Another, and probably more common, use of arrays of functions is to apply several different functions to one or more arguments. Here we apply three different functions to the number 9:

        ⟨√, 2⊸≍, ⊢-⋆⟩ {𝕎𝕩}¨ 9

The 2-modifier Choose (`◶`) relies on arrays of functions to… function. It's very closely related to Pick `⊑`, and in fact when the left operand and the elements of the right operand are all data there's no real difference: Choose returns the constant function `𝕗⊑𝕘`.

        2◶"abcdef" "arg"

When the operands contain functions, however, the potential of Choose as a ternary-or-more operator opens up. Here's a function for a step in the Collatz sequence, which halves an even input but multiplies an odd input by 3 and adds 1. To get the sequence for a number, we can apply the same function many times. It's an [open problem](https://en.wikipedia.org/wiki/Collatz_conjecture) whether the sequence always ends with the repetition 4, 2, 1, but it can take a surprisingly long time to get there—try 27 as an argument.

        (2⊸|)◶⟨÷⟜2,1+3×⊢⟩¨ 6‿7
        (2⊸|)◶⟨÷⟜2,1+3×⊢⟩⍟(↕10) 6
