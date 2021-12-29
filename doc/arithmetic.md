*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/arithmetic.html).*

# Arithmetic functions

Since BQN's function syntax was designed to mirror mathematical operators, its arithmetic tends to look a lot like mathematical notation. Individual functions are listed below. As an array language, BQN applies arithmetic element-wise to arrays, a system known as [pervasion](#pervasion). A distinctive feature of BQN is its [character arithmetic](#character-arithmetic), which allows `+` and `-` to manipulate characters without explicitly transforming them to numbers.

Summary of other differences from APL:
- Exponentiation is represented with the star character `⋆`, since asterisk `*` is rendered inconsistently across fonts and sometimes appears as a superscript.
- There's a root function `√`.
- Not uses a different symbol `¬`, and binary logical functions `∧∨` (described on [their own page](logic.md)) are extended linearly in all arguments instead of using GCD or LCM.
- Dyadic arithmetic functions use [leading axis agreement](leading.md#leading-axis-agreement) like J.

## Basic arithmetic

*These functions are also introduced in the [first BQN tutorial](../tutorial/expression.md).*

BQN of course supports the elementary functions taught in schools everywhere:

Symbol | Dyad     | Monad
-------|----------|-------
`+`    | Add      | *(Conjugate)*
`-`    | Subtract | Negate
`×`    | Multiply | Sign
`÷`    | Divide   | Reciprocal
`⋆`    | Power    | Exponential
`√`    | Root     | Square root

The dyadic functions should all be familiar operations, and most likely you are familiar with the symbols `+-×÷√`. In fact the large `×` and `÷` might strike you as a regression to early school years, before division was written vertically and multiplication with a simple dot or no symbol at all (BQN reserves the distinction of having no symbol for application and composition). Like these, raising to a power or exponentiation is made regular by giving it the symbol `⋆`—a true Unicode star and *not* an asterisk. The Root function `√` is also modified to be a binary function, which raises `𝕩` to the power `÷𝕨`. In ASCII programming languages `×`, `÷`, and `⋆` are often written `*`, `/`, and `^` or `**`.

        2 + 3‿1‿0‿5

        2‿5 - 1‿9

        1.5‿2‿0.5 × 2

        3‿4‿1 ÷ 2

        3 ⋆ 0‿1‿2

        4 √ 81

Each of these functions also has a meaning with only one argument, although in mathematics only `-` does. The relationship of negation to addition is extended to division (relative to multiplication) as well, so that `÷𝕩` gives the reciprocal `1÷𝕩` of its argument. Power (`⋆`) is also extended with a default left argument of [Euler's number](https://en.wikipedia.org/wiki/E_(mathematical_constant)) *e*. The default left argument for Root is 2, giving the well-known Square Root.

        - 6

        ÷ 0‿1‿2

        ⋆ 0‿1‿2

        √ 0‿1‿2‿4

Take note of the difference between the function `-`, and the "high minus" character `¯`, which is a part of [numeric notation](syntax.md#constants). Also shown is the number `∞`, which BQN supports along with `¯∞` (but depending on implementation BQN may or may not keep track of `¯0`. Integer optimization loses the distinction so it's best not to rely on it).

The logarithm is written with Undo: `⋆⁼`. As with Power, the default base is *e*, giving a natural logarithm.

        ⋆⁼ 10

        2 ⋆⁼ 1024

Two other one-argument forms carried over from APL aren't based on default arguments. `+` is Complex Conjugate—which, given that no existing BQN implementation supports complex numbers, never does anything now. `×` returns the sign of its argument: `0` if it's equal to 0, `¯1` if it's less, and `1` if greater.

        + ∞‿¯2‿4‿0.1

        × ∞‿¯2‿¯0‿0‿4

### Character arithmetic

The Add and Subtract functions can be applied to [characters](types.md#characters) as well as numbers. While any two numbers (finite ones, at least) can be added or subtracted, character arithmetic has more restrictions.

<!--GEN
p ← 192‿32
dim ← (2×p) + 2 × d ← 128‿34
Pos ↩ Pos d⊸×
hp ← ÷4‿8

rc ← At "class=code|stroke-width=1|rx=6"
hc ← At "class=red|stroke-width=0.5|rx=3|opacity=0.5"
tg ← "g"At"fill=currentColor|font-size=14"
cg ← "g"At"text-anchor=middle|font-size=20px|font-family=BQN,monospace"
lg ← "g"At"stroke=currentColor|stroke-width=0.6|opacity=0.5"

Text ← ("text" Attr "dy"‿"0.35em"∾Pos)⊸Enc
types ← "Number"‿"Character"
t ← ((1-˜0.65⌊↕3)(0.25⊸+⊸≍¨⋈≍˜¨)1∾0.5+↕2) (Text¨⟜(<∾types˙))¨ "𝕨"‿"𝕩"

((-p+d×0.1‿0.3)∾dim) SVG ⟨
  "rect" Elt rc ∾ (Pos 0‿0)∾"width"‿"height"≍˘FmtNum 2×d
  ("rect" Elt hc ∾ ("width"‿"height"≍˘FmtNum d×¬2×hp)∾˜Pos∘+⟜hp)∘≍¨⟜⌽ ↕2
  tg Enc "end"‿"middle" ("g"Attr"text-anchor"⋈⊢)⊸Enc¨ t
  cg Enc (⥊≍⌜˜0.5+↕2) Text¨ 2‿1‿1 / Highlight¨ "+ -"‿"+  "‿"  -"
  lg Enc (<"xy"≍⌜"12") ("line" Elt ≍˘○⥊)⟜(FmtNum d×⊢)¨ ⋈⟜⌽ 1‿1≍¯0.5‿2.2
⟩
-->

The allowed operations are that a number can be added to or subtracted from a character, giving a character, and a character can be subtracted from another, giving a number.

        3 + "abcde"

        'c' - 2

        'c' - "abc"

It's not possible to add two characters or subtract a character from a number. Furthermore, an operation that results in a character will give an error if its code point would be invalid Unicode (either it's not a natural number or it's outside of the allowed ranges).

The literal `@` indicates the null character—code point 0—so that the character with code point `n` is `@+n` and the code point of a character `c` is `c-@`.

        'a' - @

## Additional arithmetic

Symbol | Monad          | Dyad
-------|----------------|-------
`⌊`    | Floor          | Minimum
`⌈`    | Ceiling        | Maximum
`\|`   | Absolute Value | Modulus

Now the monadic function symbols resemble those used in mathematics. In the case of Floor and Ceiling, this is because Ken Iverson invented them! As with other functions, he adapted them to use more uniform syntax in order to create APL\360, in this case by removing the paired closing version of each one.

        ⌊ π

        ⌈ ¯0.6‿3‿3.01

        | ¯∞‿¯6‿0‿2

Floor (`⌊`) returns the largest integer less than or equal to the argument, and Ceiling (`⌈`) returns the smallest one greater than or equal to it. For this purpose `¯∞` and `∞` are treated as integers, so that the floor or ceiling of an infinity is itself. Absolute value removes the argument's sign by negating it if it is less than 0, so that its result is always non-negative.

Minimum (`⌊`) returns the smaller of its two arguments, and Maximum (`⌈`) returns the larger. These functions are loosely related to Floor and Ceiling in their use of comparison, and can be defined similarly: for example, the minimum of two numbers is the largest number less than or equal to both of them. To take the minimum or maximum of an entire list, use a [fold](fold.md).

        3 ⌊ ↕8

        ⌽⊸⌈ ↕8

Modulus (`|`) is similar to the modular division operation written `%` in C-like languages, but it takes the arguments in the opposite order, and differs in its handling of negative arguments. It's defined to be `{𝕩-𝕨×⌊𝕩÷𝕨}`, except that the multiplication should always return 0 if its right argument is 0, even if `𝕨` is infinite.

        3 | ↕8

        3 | ¯5

Unlike in APL, a left argument of 0 fails or returns a not-a-number result. Set `𝕨` to `∞` to keep `𝕩` intact, but do note that if `𝕩<0` this will return `∞`.

## Comparisons

BQN uses the six standard comparison functions of mathematics. For each pair of atoms the result is 1 if the comparison is true and 0 if it's false. These functions do the obvious thing with numeric arguments, but are extended to other types as well.
     
| Name                     | Glyph | < | = | > | Domain
|--------------------------|:-----:|---|---|---|-------
| Equals                   | `=`   | 0 | 1 | 0 | Any
| Not Equals               | `≠`   | 1 | 0 | 1 | Any
| Less Than or Equal to    | `≤`   | 1 | 1 | 0 | Data
| Less Than                | `<`   | 1 | 0 | 0 | Data
| Greater Than             | `>`   | 0 | 0 | 1 | Data
| Greater Than or Equal to | `≥`   | 0 | 1 | 1 | Data

The *ordered* comparisons `≤<>≥` are defined on numbers and characters (and arrays, by pervasion); they give an error for operation or namespace arguments. They order numbers as you'd expect, and characters by their code points. A character is considered greater than any number, even `∞`.

        3‿4‿5‿6 ≤ 5

        'c' < "acbz"

        ¯∞‿π‿∞ ≥ @‿'0'‿'?'

Equals and Not Equals are the two *equality* comparisons. Equals tests for atomic equality between each pair of atoms, as [described](match.md#atomic-equality) in the Match documentation. Essentially, it returns `1` only if the two values are indistinguishable to BQN and `0` otherwise. Values of different types can never be equal, and characters are equal when they have the same code point.

        +‿-‿×‿÷ = ⊑⟨-⟩

        'b' ≠ "abacba"

## Pervasion

Arithmetic primitives act as though they are given [depth](depth.md#the-depth-modifier) 0, so that with array arguments they treat each atom independently. While the examples above use only numbers or lists of them, arithmetic applies to nested and high-rank arrays just as easily.

        × ≍˘⟨¯8,¯9⟩‿⟨⟨2,0⟩,4,5⟩

With two arguments many combinations are possible. Arrays of equal shape are matched element-wise, and an atom is matched to every element of an array.

        10‿20‿30 + 5‿6‿7

        10 × 4‿3‿2≍6‿7‿8

Arrays with different ranks can also be paired: they are matched by [leading axis agreement](leading.md#leading-axis-agreement). This means that one shape must be a prefix of the other, and elements of the lower-rank array are repeated to match up with cells of the higher-rank one.

        1‿2‿3 ⋆ >⟨0‿1,2‿4,3‿6⟩

This convention matches up with the way array nesting is handled: first, the leading "outer" axes are looped over, then later ones.

        1‿2‿3 ⋆ ⟨0‿1,2‿4,3‿6⟩
