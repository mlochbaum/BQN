*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/assert.html).*

# Assert and Catch

BQN provides some simple facilities for dealing with errors. Errors are an unusual sort of control flow; if possible, prefer to work with functions that return normally.

## Assert

BQN takes the position that errors exist to indicate exceptional conditions that the developer of a given program didn't expect. However, the types of errors that BQN naturally checks for, such as mismatched shapes in Couple (`≍`), aren't always enough to detect exceptional conditions. Issues like numeric values that don't make physical sense will slip right through. BQN makes it easy for a programmer to check for these sorts of problems by building in the primitive Assert, written `!`. This function checks whether `𝕩` matches `1`: if it does, then it does nothing and returns `𝕩`, and otherwise it gives an error.

        ! 2=2  # Passed
        ! 2=3  # Failed

To pass, the right argument must be exactly the number `1`; any other value causes an error. For example, an array of `1`s still causes an error; use `∧´⥊` to convert a boolean array to a single boolean that indicates whether all of its values are true.

        ! (∧=∨⌾¬)⌜˜ ↕2
        ! ∧´⥊ (∧=∨⌾¬)⌜˜ ↕2

Assert can take a left argument, which gives a message to be associated with the error. It's typical to use a string for the left argument in order to display it to the programmer, but the left argument can be any value.

        "Message" ! 0
        ⟨∘,"abc",˜⟩ ! '0'

### Computing the error message on demand

Because the left argument to a function is always computed before the function is called, Assert [doesn't let you](../commentary/problems.md#assert-has-no-way-to-compute-the-error-message) compute the error message only if there's an error. This might be a problem if the error message computation is slow or has side effects. There are a few ways to work around the issue:
- Handle errors with ordinary if-then logic (perhaps using [control structures](control.md)). This is probably the best path for user-facing applications where displaying an error goes through the user interface.
- Write a function `Message` to compute the message, and call `𝕨 Message⊸!⍟(1⊸≢) 𝕩` or similar instead of `!`.
- If the error will be caught elsewhere in the program, use a closure for the message and evaluate it when caught. With a function `Message` as above, `message ! 𝕩` works, and `{…}˙⊸! 𝕩` is a convenient syntax for block functions.

## Catch

The `Catch` modifier allows you to handle errors in BQN (at present, it's the only way to do so). It evaluates the function `𝔽` normally. If this function completes without an error, Catch just returns that result. If not, it stops the error, and calls `𝔾` with the original arguments instead.

        ⌽⎊'x' "abcd"  # No error

        ⌽⎊'x' 2       # Can't reverse a unit

        0.5 ⌽⎊⊣ ↕6    # A two-argument example

Catch doesn't know anything about what an error *is*, just whether there was one or not. In fact, the idea of error message doesn't feature at all in core BQN: it's purely part of the language environment. So you need a system value to access information about the error. Right now the only one is `•CurrentError`, which is a function that returns a message for the error currently caught (if any).

        ⌽⎊•CurrentError 2
