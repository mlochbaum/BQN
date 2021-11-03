*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/take.html).*

# Take and Drop

<!--GEN
xt ← '''(Highlight∾∾⊣)¨ "startend"
wv ← 5
d ← 56‿80

rc ← At "class=code|stroke-width=1.5|rx=12"
Ge ← "g"⊸At⊸Enc
g  ← "fill=currentColor|stroke-linecap=round|text-anchor=middle|font-family=BQN,monospace"
cg ← "font-size=25px"
bg ← "class=bluegreen|stroke-width=3|style=fill:none|opacity=0.8"
ag ← "class=green|stroke-width=3|style=fill:none|opacity=0.8"
lg ← "class=red|stroke-width=2.5|stroke-dasharray=9 9|opacity=0.9"

Text ← ("text" Attr "dy"‿"0.32em"∾ ·Pos d⊸×)⊸Enc
Line ← "line" Elt ("xy"≍⌜"12")≍˘○⥊ ·FmtNum d×⊢

_brak ← {
  P ← ∾"M l l "∾¨ ·FmtNum∘⥊ ∾
  "path" Elt "d"⋈ ∾ (𝕨((0‿¯1×𝕗)+d×≍)⌜𝕩) P¨ ⋈⟜⌽ -⌾⊑⊸≍𝕗
}
ab ← ¯25‿12

tx ← ↕≠xt ⋄ ay ← 0.54 + ty ← 0
wm ← 0‿1 ⊑ bp ← 2↕(÷2)-˜⟨0,wv,≠xt⟩
tp ← (¯1.2∾2÷˜+˝bp) ≍¨ ty+/1‿2
dim ← ⟨2+≠tx,1.96⟩ ⋄ sh ← ¯1.8‿¯0.5

((∾˜d)×((-∾+˜)1‿0.3)+sh∾dim) SVG g Ge ⟨
  "rect" Elt rc ∾ (Pos d×sh)∾"width"‿"height"≍˘FmtNum d×dim
  cg Ge tp Text⟜Highlight¨ (<∾"↑"‿"↓"((•Repr wv)∾∾)¨<) "𝕩"
  "font-size=21px" Ge (tx≍¨ty) Text¨ xt
  bg Ge ((-⊸≍0.4)+0‿¯1⊏tx) 6‿15 _brak ty
  ag Ge ⟨
    ((-⊸≍0.9)+wm) ab _brak ay
    Line∘≍⟜(≍˜ay)¨ <˘ bp + -∘⌽⊸≍⟨0.9+ab÷○⊑d,¯0.2⟩
  ⟩
  lg Ge Line wm ≍˜⊸≍ ¯0.3‿1.2+ty
⟩
-->

The basic idea of Take (`↑`) is to get the first few elements of a list, while Drop (`↓`) removes those and returns the rest. Then they are extended in like a billion ways.

- `𝕩` can be an atom, or array of any rank (the result will be an array).
- `𝕨` can be negative to take or drop from the end instead of the beginning.
- For Take, if `𝕨` is larger than the length of `𝕩`, then [fills](fill.md) are added.
- `𝕨` can have multiple numbers corresponding to leading axes of `𝕩`.
- `𝕨` is allowed to be longer than the rank of `𝕩`; `𝕩` will be extended to fit.

These extensions can be combined as well, so there are a lot of possibilities. A good picture to have in mind is cutting out a corner of the array `𝕩`. This is because the result `𝕨↑𝕩` or `𝕨↓𝕩` always aligns with one side of `𝕩` along each axis, so it aligns with the corner where those sides meet.

The result `d↓𝕩` is always the same as `t↑𝕩` for some other argument `t`, but computing `t` wouldn't be too convenient. The reverse isn't true: only Take can insert fills, so results that include them can't come from Drop.

## One axis

Let's start with a natural number `𝕨`. Take gives the first `𝕨` major cells of `𝕩` (or elements of a list), while Drop gives all but the first `𝕨`.

        4 ↑ "take and drop"
        4 ↓ "take and drop"

        1 ↓ >"maj"‿"orc"‿"ell"

If `𝕨` is too large it's usually not a problem. For Take, [fill elements](fill.md) are added to the end to bring `𝕩` up to the required length—although this *will* fail if `𝕩` has no fill element. For Drop, the result is an empty array.

        ↕6

        10 ↑ ↕6

        10 ↓ ↕6

        ≢ 5 ↓ ↕3‿9‿2

If `𝕩` is an atom or unit array, it's converted to a list first. For Take this is useful to make an array of mostly fills; for Drop it's pretty much useless.

        10 ↑ 9

        3 ↓ <"element"

### Negative argument

If `𝕨` is negative then wraps around the other side to take or drop from the end of `𝕩`. It's a lot like negative indices in [Select](select.md) (`⊏`), but while negative indices are asymmetric—`0` is the first entry but `¯1` is the last—this case is symmetric. It's because the place to cut is always *before* the index `𝕨`, cancelling out the negative index asymmetry.

        3 ↑ "abcdeEDCBA"

        ¯3 ↑ "abcdeEDCBA"  # Last three

        ¯3 ↓ "abcdeEDCBA"  # All but the last three

What about `0`? It behaves like it's both positive *and* negative. For Take, the first 0 and last 0 cells are indistinguishable, because they're both empty. For Drop, if you remove 0 cells it doesn't matter whether you start at the front or the back, because you're not going to do anything either way.

        0 ↑ 4‿3‿2  # Nothing

        0 ↓ 4‿3‿2  # Everything

If `|𝕨` is too large, then Take will insert fills at the beginning to keep the result aligned with `𝕩` at the end. Drop returns an empty array as in the positive case. So unlike [Rotate](reverse.md) (`⌽`), which is completely cyclical, Take and Drop work cyclically only around 0.

        ¯6 ↑ "xy"

## Multiple axes

In the general case `𝕨` is a list of integers. They're matched with the leading axes of `𝕩`, so that each affects one axis independently from the others.

        ⊢ m ← (10×↕5) +⌜ ↕7

        ¯4‿2 ↑ m  # Last four rows; first two columns

        ¯4‿2 ↓ m

Now Take and Drop taken together don't include the whole array. Take includes the elements that are selected on *every* axis, while Drop excludes the ones selected on *any* axis. They are opposite corners that meet at some point in the middle of the array (here, at the spot between `2` and `11`).

Any integer values at all can be used, in any combination. Here one axis is shortened and the other's padded with fills. The result of Take has shape `|𝕨`, maybe plus some trailing axes from `𝕩`. Of course, if that's too big for your available memory, your BQN implementation probably can't compute it for you!

        3‿¯12 ↑ m

        ≢ 9‿¯4 ↑ ↕7‿6‿5  # Trailing shape example

If the rank of `𝕩` is *smaller* than the length of `𝕨`, then length-1 axes are added to the beginning until it's equal. Mostly this will be used with Take when `𝕩` is a unit, producing an array that contains `𝕩` and a lot of fills.

        3‿4 ↑ <1‿1

This property also enables a nice little trick with Drop. If `𝕨` is a list of zeros, Drop won't do anything—except extend the rank of `𝕩`. So `(r⥊0)↓a`, or `r ⥊⟜0⊸↓ a`, ensures `a` is an array with rank at least `r` but doesn't change any of the elements. As a special case, `⟨⟩↓v` [Encloses](enclose.md) an atom argument but otherwise has no effect.

        ≢ (3⥊0) ↓ 3

        ≢ (3⥊0) ↓ ↕3

        ≢ (3⥊0) ↓ ↕5‿4‿3‿2
