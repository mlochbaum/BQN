*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/under.html).*

# Under

<!--GEN
d ← 94‿50

Text ← ("text" Attr "dy"‿"0.31em"∾·Pos d⊸×)⊸Enc
Path ← ("path" Attr "class"⊸⋈≍"style"‿"fill:none"˙)⊸Elt⟜("d"⊸⋈)

vals ← ((-´"Aa")+⌽){≍⟜(𝔾¨) ⊢⋈𝔽⌾𝔾}(2↑1⊸↓) "udner"

g  ← "font-size=20px|text-anchor=middle|fill=currentColor"
rc ← At "class=code|stroke-width=1|rx=12"
fc ← "font-size=18px|font-family=BQN,monospace"

Ge ← "g"⊸At⊸Enc
_arrow ← {
  a ← ((⊢≍-⌾⊑∘⌽)÷⟜(+´⌾(×˜))𝕨) +˝∘×⎉1‿∞˜ 𝕗≍-⌾⊑𝕗
  ∾"M l m l l "∾¨ FmtNum ∾⥊¨⟨𝕩-𝕨, 𝕨, -⊏a, a⟩
}
Arr ← 15‿8 _arrow
cut ← 0.24‿0.17
ars ← (×⟜(¬2×cut) Arr○(d⊸×) ×⟜(-cut)⊸+)¨⟜((<-1‿1)⊸++0‿0≍˘⌽) 2×=⟜<↕2

dim ← 5.4‿4×d
rdim ← 4‿4×d
((¯4↑d×0‿0.6)+∾÷⟜¯2‿1<20+dim) SVG g Ge ⟨
  "rect" Elt rc∾(Pos rdim÷¯2)∾"width"‿"height"≍˘FmtNum rdim
  0‿2.4 Text "Under"
  "stroke-width=2.6"‿"stroke-width=2" Ge¨ "purple"‿"yellow" Path⟜∾¨ 0‿1‿1‿1⊔⥊ars
  fc Ge ⟨
    "font-size=20px"⊸Ge⌾⊑ (⍉-⊸≍1.44‿1.2×⌽<⊸=↕2) Text⟜Highlight¨ "𝔽⌾𝔾"‿"𝔽"≍⋈˜"𝔾"
    "class=string" Ge (⋈⌜˜-⟜¬↕2) Text¨ ⍉0‿¯1⌽¨(⌈´∘⥊≠¨)⊸(↑¨) •Repr¨ vals
  ⟩
⟩
-->

The Under 2-modifier expresses the idea of modifying *part* of an array, or applying a function in a different domain, such as working in logarithmic space. It works with a transformation `𝔾` that applies to the original argument `𝕩`, and a function `𝔽` that applies to the result of `𝔾` (and if `𝕨` is given, `𝔾𝕨` is used as the left argument to `𝔽`). Under does the "same thing" as `𝔽`, but to the original argument, by applying `𝔾`, then `𝔽`, then undoing `𝔾` somehow.

It's not always possible to undo `𝔾`, so only some right operands will work. BQN supports two cases. **Computational** Under tries the [Undo](undo.md) modifier, so that `𝔽⌾𝔾` is `𝔾⁼∘𝔽○𝔾`.

        3 +⌾(×˜) 4  # Square root of sum of squares

**Structural** Under is used when `𝔾` selects part of the array. BQN tracks what was selected and puts the results from `𝔽` back where they came from.

        +`⌾∾ ⟨3‿1‿0, 2‿5, 0‿0‿6⟩  # Prefix sum, keeping structure

Structural Under is an essential part of BQN because of how it can "change" an immutable [array](array.md), and it supports more functions and is always well defined. Computational Under's nice, but not so important. The reason they can both be supported as a single primitive is that they follow this unifying principle:

    (𝔾 𝕨𝔽⌾𝔾𝕩) ≡ 𝕨𝔽○𝔾𝕩

That is, when you apply `𝔽⌾𝔾` *before* applying `𝔾`, you get the value that comes from applying `𝔽` *after* `𝔾`. The definition of computational under comes from applying `𝔾⁼` to both sides and cancelling `𝔾⁼𝔾`, which solves the constraint but doesn't have to be a unique solution. For structural Under, the reason this works is that `𝔾` selects out the parts of `𝔽⌾𝔾` that were placed back in by Under. Other parts are defined to be the same as it was in `𝕩`, so the result is fully specified.

## Structural Under

A *structural function* is one that moves elements around without performing computation on them. It's okay if it performs computation, but it has to be based on the structure of its argument—shape, and element structure—and not on the values of atoms in it. As an example, the function `⊏˘` selects the first column of an array.

        ⊢ a ← 4‿3⥊↕12

        1⊸⌽⌾(⊏˘) a

When used with Under, the function `1⊸⌽` applies to the first column, [rotating](reverse.md#rotate) it. The result of `𝔽` needs to be compatible with the selection function, so Rotate works but trying to drop an element is no good:

        1⊸↓⌾(⊏˘) a

BQN can detect lots of structural functions when written [tacitly](tacit.md); see the list of recognized forms [in the spec](../spec/inferred.md#required-structural-inverses). You can also include computations on the shape. For example, here's a function to reverse the first half of a list.

        ⌽⌾(⊢↑˜≠÷2˙) "abcdef"

But you can't use a computation that uses array values, such as `10⊸+⌾((<⟜5)⊸/)` to add 10 to each element below 5. This is because Under can change the array values, so that the function `𝔾` doesn't select the same elements before and after applying it (contrarily, Under can't change array structure, or at least not the parts that matter to `𝔾`). To use a dynamic selection function, compute the mask or indices based on a copy of the argument and use those as part of `𝔾`.

        {10⊸+⌾((𝕩<5)⊸/)𝕩} 3‿8‿2‿2‿6

        (<⟜5)⊸/ 3‿8‿2‿2‿6

        (<⟜5)⊸/ {10⊸+⌾((𝕩<5)⊸/)𝕩} 3‿8‿2‿2‿6

Under is useful with [scans](scan.md), as discussed in a section on [reverse scan](scan.md#reverse-scan). In this case, `⌽` is exactly invertible, so `⌾` can just as easily be seen as computational Under. When `𝔾` has an exact inverse, there can only be one solution to the constraint on Under, and both forms must be the same.

        ∧`⌾⌽ 1‿0‿1‿0‿1‿1‿1

Structural Under is the same concept as a (lawful) [lens](https://ncatlab.org/nlab/show/lens+%28in+computer+science%29) in functional programming (see also [bidirectional transformation](https://en.wikipedia.org/wiki/Bidirectional_transformation)). Lenses are usually defined as getter/setter pairs, but BQN's restriction to structural functions makes an implicit setter work even for polymorphic array functions.

## Computational Under

Computational Under is based on [Undo](undo.md) (`⁼`), and applies whenever structural Under doesn't. It's still limited, because Undo doesn't work on many or even most functions. One common use is with the square function `×˜`, for computations such as finding the magnitude of a vector, or a [root-mean-square](https://en.wikipedia.org/wiki/Root_mean_square) average like the one below.

        (+´÷≠)⌾(×˜) 2‿3‿4‿5

This average is the square root of the average of the squares of the arguments, and `⌾` lets us combine the two square-y steps. Here there are two possible solutions because `¯3.67…` has the same square as the positive result; BQN of course uses the principal root. Similarly, `⌾÷` can be used for a harmonic sum or mean (you might notice that computational Under is a lot more mathy than the structural one).

Under is the idiomatic way to do a round-to-nearest function:

        ⌊⌾(10⊸×) 3.524‿6.799‿2.031

See how it works? `⌊` rounds down to an integer, but we can get it to round down to a decimal by first multiplying by 10 (so that single decimals become integers), then rounding, then undoing that multiplication. A related idea is to not just round but produce a range. Suppose I want the arithmetic progression 4, 7, 10, ... <20. If I had the right range `↕n`, then it would be `4+3×↕n`, or `(4+3×⊢)↕n`. By using the *inverse* of this transformation function on the desired endpoint, I can make sure it's applied on the way out, and BQN figures out what to do on the way in as if by magic.

        ↕∘⌈⌾((4+3×⊢)⁼) 20

Well, really it's some simple algebra, but if it wants to wear a pointy hat and wave a wand around I won't judge.

## Left argument

When called dyadically, Under applies `𝔽` dyadically, like [Over](compose.md#over). This doesn't affect the undoing part of Under, which still tries to put the result of `𝔽` back into `𝕩` for structural Under or invert `𝔾` for computational. In fact, `𝕨 𝔽⌾𝔾 𝕩` is equivalent to `(𝔾𝕨)˙⊸𝔽⌾𝔾 𝕩` so no exciting language stuff is happening here at all.

But you can still do cool things with it! One pattern is simply to set `𝔽` to `⊣`, the [identity](identity.md) function that just returns its left argument. Now structural Under will replace everything that `𝔾` selects from `𝕩` with the corresponding values in `𝕨`. Here's an example that replaces elements with indices `1` and `2`.

        "abcd" ⊣⌾(1‿2⊸⊏) "0123"

This method can replace deeper structure too. Below, `𝔾` is `¯1⊑¨2↑⊢`, selecting the last element of each of the first two elements of its argument. The elements that aren't selected don't have to match up.

        ⟨"ab", "cde", "fg"⟩ ⊣⌾(¯1⊑¨2↑⊢) ↕¨3‿2‿1‿1

In fact, the elements that *are* selected don't really have to match up before being selected. So here's an example with [Join](join.md) where the same pattern is used to "re-flow" `𝕨` into the structure of `𝕩`.

        ⟨"ab", "cde", "fg"⟩ ⊣⌾∾ ⟨"---", "----"⟩

### And getting it not to do that

The Over-based action on `𝕨` shows up more than you might think, but sometimes you just want to pass a left argument to `𝔽` without `𝔾` getting involved. In this case you have to [bind](hook.md#bind) it in: call `𝕨⊸𝔽⌾𝔾 𝕩`.

        1‿2‿3⊸+⌾(1‿1‿0‿1⊸/) 10‿20‿30‿40

This [gets bad](../problems.md#underbind-combination-is-awkward) when you want `𝕨` to be an argument. In the worst case you might need to write out an operator `{𝕨⊸𝔽⌾𝔾𝕩}`.
