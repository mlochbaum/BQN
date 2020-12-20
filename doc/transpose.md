*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/transpose.html).*

# Transpose

As in APL, Transpose (`⍉`) is a tool for rearranging the axes of an array. BQN's version is tweaked to align better with the leading axis model and make common operations easier.

## Transpose basics

The name for the primitive `⍉` comes from the [Transpose](https://en.wikipedia.org/wiki/Transpose) operation on matrices. Given a matrix as an array of rank 2, `⍉` will transpose it:

        ⊢ mat ← 2‿3 ⥊ ↕6
        ⍉ mat

Transpose is named this way because it exchanges the two axes of the matrix. Above you can see that while `mat` has shape `2‿3`, `⍉mat` has shape `3‿2`, and we can also check that the element at [index](indices.md) `i‿j` in `mat` is the same as the one at `j‿i` in `⍉mat`:

        1‿0 ⊑ mat
        0‿1 ⊑ ⍉ mat

With two axes the only interesting operation of this sort is to swap them (and with one or zero axes there's nothing interesting to do, and `⍉` just returns the argument array). But a BQN programmer may well want to work with higher-rank arrays—although such a programmer might call them "tensors"—and this means there are many more ways to rearrange the axes. Transpose extends to high-rank arrays to allow some useful special cases as well as completely general axis rearrangement, as described below.

## Monadic Transpose

APL extends matrix transposition to any rank by reversing all axes for its monadic `⍉`, but this generalization isn't very natural and is almost never used. The main reason for it is to maintain the equivalence `a MP b ←→ b MP⌾⍉ a`, where `MP ← +˝∘×⎉1‿∞` is the generalized matrix product. But even here APL's Transpose is suspect. It does much more work than it needs to, as we'll see.

BQN's transpose takes the first axis of its argument and moves it to the end.

        ≢ a23456 ← ↕2‿3‿4‿5‿6
        ≢ ⍉ a23456

In terms of the argument data as given by Deshape (`⥊`), this looks like a simple 2-dimensional transpose: one axis is exchanged with a compound axis made up of the other axes. Here we transpose a rank 3 matrix:

        a322 ← 3‿2‿2⥊↕12
        ≍○<⟜⍉ a322

But, ignoring the whitespace and going in reading order, the argument and result have exactly the same element ordering as for the rank 2 matrix `⥊˘ a322`:

        ≍○<⟜⍉ ⥊˘ a322

To exchange multiple axes, use the Power modifier. A negative power moves axes in the other direction, just like how Rotate handles negative left arguments. In particular, to move the last axis to the front, use Undo (as you might expect, this exactly inverts `⍉`).

        ≢ ⍉⍟3 a23456
        ≢ ⍉⁼ a23456

In fact, we have `≢⍉⍟k a ←→ k⌽≢a` for any whole number `k` and array `a`.

To move axes other than the first, use the Rank modifier in order to leave initial axes untouched. A rank of `k>0` transposes only the last `k` axes while a rank of `k<0` ignores the first `|k` axes.

        ≢ ⍉⎉3 a23456

And of course, Rank and Power can be combined to do more complicated transpositions: move a set of contiguous axes with any starting point and length to the end.

        ≢ ⍉⁼⎉¯1 a23456

Using these forms, we can state BQN's generalized matrix product swapping rule:

    a MP b  ←→  ⍉⍟(1-=a) (⍉b) MP (⍉⁼a)

Certainly not as concise as APL's version, but not a horror either. BQN's rule is actually more parsimonious in that it only performs the axis exchanges necessary for the computation: it moves the two axes that will be paired with the matrix product into place before the product, and directly exchanges all axes afterwards. Each of these steps is equivalent in terms of data movement to a matrix transpose, the simplest nontrivial transpose to perform. Also remember that for two-dimensional matrices both kinds of transposition are the same, so that APL's simpler rule `MP ≡ MP⌾⍉˜` holds in BQN.

Axis permutations of the types we've shown generate the complete permutation group on any number of axes, so you could produce any transposition you want with the right sequence of monadic transpositions with Rank. However, this can be unintuitive and tedious. What if you want to transpose the first three axes, leaving the rest alone? With monadic Transpose you have to send some axes to the end, then bring them back to the beginning. For example [following four or five failed tries]:

        ≢ ⍉⁼⎉¯2 ⍉ a23456  # Restrict Transpose to the first three axes

In a case like this BQN's Dyadic transpose is much easier.

## Dyadic Transpose

Transpose also allows a left argument that specifies a permutation of the right argument's axes. For each index `p←i⊏𝕨` in the left argument, axis `i` of the argument is used for axis `p` of the result. Multiple argument axes can be sent to the same result axis, in which case that axis goes along a diagonal of the argument array, and the result will have a lower rank than the argument.

        ≢ 1‿3‿2‿0‿4 ⍉ a23456
        ≢ 1‿2‿2‿0‿0 ⍉ a23456  # Don't worry too much about this case though

Since this kind of rearrangement can be counterintuitive, it's often easier to use `⍉⁼` when specifying all axes. If `p≡○≠≢a`, then we have `≢p⍉⁼a ←→ p⊏≢a`.

        ≢ 1‿3‿2‿0‿4 ⍉⁼ a23456

So far, all like APL. BQN makes one little extension, which is to allow only some axes to be specified. The left argument will be matched up with leading axes of the right argument. Those axes are moved according to the left argument, and remaining axes are placed in order into the gaps between them.

        ≢ 0‿2‿4 ⍉ a23456

In particular, the case with only one argument specified is interesting. Here, the first axis ends up at the given location. This gives us a much better solution to the problem at the end of the last section.

        ≢ 2 ⍉ a23456  # Restrict Transpose to the first three axes

Finally, it's worth noting that, as monadic Transpose moves the first axis to the end, it's equivalent to dyadic Transpose with a "default" left argument: `(=-1˙)⊸⍉`.

## Definitions

Here we define the two valences of Transpose more precisely.

Monadic transpose is identical to `(=-1˙)⊸⍉`, except that if the argument is a unit it is returned unchanged rather than giving an error.

An atom right argument to dyadic Transpose is always enclosed to get an array before doing anything else.

In dyadic Transpose, the left argument is a number or numeric array of rank 1 or less, and `𝕨≤○≠≢𝕩`. Define the result rank `r←(=𝕩)-+´¬∊𝕨` to be the argument rank minus the number of duplicate entries in the left argument. We require `∧´𝕨<r`. Bring `𝕨` to full length by appending the missing indices: `𝕨∾↩𝕨(¬∘∊˜/⊢)↕r`. Now the result shape is defined to be `⌊´¨𝕨⊔≢𝕩`. Element `i⊑z` of the result `z` is element `(𝕨⊏i)⊑𝕩` of the argument.
