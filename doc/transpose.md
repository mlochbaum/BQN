*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/transpose.html).*

# Transpose

As in APL, Transpose (`⍉`) is a tool for rearranging the axes of an array. BQN's version is tweaked to align better with the leading axis model and make common operations easier.

## Monadic Transpose

Transposing a matrix exchanges its axes, mirroring it across the diagonal. APL extends the function to any rank by reversing all axes, but this generalization isn't very natural and is almost never used. The main reason for it is to maintain the equivalence `a MP b ←→ a MP⌾⍉ b`, where `MP ← (+´<˘)∘×⎉1‿∞` is the generalized matrix product. But even here APL's Transpose is suspect. It does much more work than it needs to, as we'll see.

BQN's transpose takes the first axis of its argument and moves it to the end.

        ≢ a23456 ← ↕2‿3‿4‿5‿6
    ⟨ 2 3 4 5 6 ⟩
        ≢ ⍉ a23456
    ⟨ 3 4 5 6 2 ⟩

On the argument's ravel, this looks like a simple 2-dimensional transpose: one axis is exchanged with a compound axis made up of the other axes. Here we transpose a rank 3 matrix:

        a322 ← 3‿2‿2⥊↕12
        ≍○<⟜⍉ a322

But, reading in ravel order, the argument and result have exactly the same element ordering as for the rank 2 matrix `⥊˘ a322`:

        ≍○<⟜⍉ ⥊˘ a322

To exchange multiple axes, use the Power modifier. Like Rotate, a negative power will move axes in the other direction. In particular, to move the last axis to the front, use Inverse (as you might expect, this exactly inverts `⍉`).

        ≢ ⍉⍟3 a23456
    ⟨ 5 6 2 3 4 ⟩
        ≢ ⍉⁼ a23456
    ⟨ 6 2 3 4 5 ⟩

In fact, we have `≢⍉⍟k a ←→ k⌽≢a` for any number `k` and array `a`.

To move axes other than the first, use the Rank modifier in order to leave initial axes untouched. A rank of `k>0` transposes only the last `k` axes while a rank of `k<0` ignores the first `|k` axes.

        ≢ ⍉⎉3 a23456
    ⟨ 2 3 5 6 4 ⟩

And of course, Rank and Power can be combined to do more complicated transpositions: move a set of contiguous axes with any starting point and length to the end.

        ≢ ⍉⁼⎉¯1 a23456
    ⟨ 2 6 3 4 5 ⟩

Using these forms, we can state BQN's generalized matrix product swapping rule:

    a MP b  ←→  ⍉⍟(≠≢a) a ⍉⁼⊸MP⟜⍉ b

Certainly not as concise as APL's version, but not a horror either. BQN's rule is actually more parsimonious in that it only performs the axis exchanges necessary for the computation: it moves the two axes that will be paired with the matrix product into place before the product, and directly exchanges all axes afterwards. Each of these steps is equivalent in terms of data movement to a matrix transpose, the simplest nontrivial transpose to perform. Also remember that for two-dimensional matrices both kinds of transposition are the same, and APL's rule holds in BQN.

Axis permutations of the types we've shown generate the complete permutation group on any number of axes, so you could produce any transposition you want with the right sequence of monadic transpositions with Rank. However, this can be unintuitive and tedious. What if you want to transpose the first three axes, leaving the rest alone? With monadic Transpose you have to send some axes to the end, then bring them back to the beginning. For example [following four or five failed tries]:

        ≢ ⍉⁼⎉¯2 ⍉ a23456  # Restrict Transpose to the first three axes
    ⟨ 3 4 2 5 6 ⟩

In a case like this BQN's Dyadic transpose is much easier.

## Dyadic Transpose

Transpose also allows a left argument that specifies a permutation of the right argument's axes. For each index `p←i⊏𝕨` in the left argument, axis `i` of the argument is used for axis `p` of the result. Multiple argument axes can be sent to the same result axis, in which case that axis goes along a diagonal of the argument array, and the result will have a lower rank than the argument.

        ≢ 1‿3‿2‿0‿4 ⍉ a23456
    ⟨ 5 2 4 3 6 ⟩
        ≢ 1‿2‿2‿0‿0 ⍉ a23456  # Don't worry too much about this case though
    ⟨ 5 2 3 ⟩

Since this kind of rearrangement can be counterintuitive, it's often easier to use `⍉⁼` when specifying all axes. If `p≡○≠≢a`, then we have `≢p⍉⁼a ←→ p⊏≢a`.

        ≢ 1‿3‿2‿0‿4 ⍉⁼ a23456
    ⟨ 3 5 4 2 6 ⟩

So far, all like APL. BQN makes one little extension, which is to allow only some axes to be specified. The left argument will be matched up with leading axes of the right argument. Those axes are moved according to the left argument, and remaining axes are placed in order into the gaps between them.

        ≢ 0‿2‿4 ⍉ a23456
    ⟨ 2 5 3 6 4 ⟩

In particular, the case with only one argument specified is interesting. Here, the first axis ends up at the given location. This gives us a much better solution to the problem at the end of the last section.

        ≢ 2 ⍉ a23456  # Restrict Transpose to the first three axes
    ⟨ 3 4 2 5 6 ⟩

Finally, it's worth noting that, as monadic Transpose moves the first axis to the end, it's equivalent to dyadic Transpose with a "default" left argument: `(≠∘≢-1˜)⊸⍉`.

## Definitions

Here we define the two valences of Transpose more precisely.

A non-array right argument to Transpose is always enclosed to get a scalar array before doing anything else.

Monadic transpose is identical to `(≠∘≢-1˜)⊸⍉`, except that for scalar arguments it returns the array unchanged rather than giving an error.

In Dyadic transpose, the left argument is a number or numeric array of rank 1 or less, and `𝕨≤○≠≢𝕩`. Define the result rank `r←(≠≢𝕩)-+´¬∊𝕨` to be the argument rank minus the number of duplicate entries in the left argument. We require `∧´𝕨<r`. Bring `𝕨` to full length by appending the missing indices: `𝕨∾↩𝕨(¬∘∊˜/⊢)↕r`. Now the result shape is defined to be `⌊´¨𝕨⊔≢𝕩`. Element `i⊑z` of the result `z` is element `(𝕨⊏i)⊑𝕩` of the argument.
