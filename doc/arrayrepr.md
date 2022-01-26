*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/arrayrepr.html).*

# Array notation and display

This page documents ways arrays are represented in BQN: the notation you can use to write them and the way the REPL displays them.

Array display is a feature of a BQN environment such as a REPL. You can also access it with `•Fmt`, which takes a value and returns a string indicating how it would be formatted. Array notation is of course part of BQN source code, but you can also go from an array to one possible source code for it using the similar system function `•Repr`.

## Array display

Although it's really part of the language environment and not BQN itself, let's look at display first so it's clear what arrays we're talking about later on. The BQN REPL prints arrays in a way that's meant to unambiguously show the structure and data, but doesn't correspond to BQN source code. A few examples are given below; of course, displays like this appear all over the documentation.

        ↕ 3‿4             # Array of lists

        <@                # Enclosed null

        ⟨↕3, "xy", ↕2‿0⟩  # A list of three arrays

There are several different ways to show arrays: as a string `""`, with brackets `⟨⟩`, or with corners `┌` and `┘`. We'll start with the most general, the corners. These show arrays of any rank while the other two ways are special cases for lists.

Array displays show only the array shape and elements. The [fill](fill.md) is an inferred property and the display never indicates or depends on it.

### Corners

Those top-left and bottom-right corners are a distinctive part of BQN's display, as other systems almost always completely enclose the contents. BQN could add the other two corners, naturally; it just doesn't. Within the corners, elements are separated by whitespace only, and generally aligned to the top left.

        ⟨2,"xy"⟩≍⟨2‿2⥊"abcd",4⟩  # Nested 2×2 array

The lack of extra separation is to make it clear that the corners enclose the array rather than any of its elements (elements are still distinguishable becase an individual element won't contain whitespace except maybe between quotes). Now every set of corners indicates one array. This is a good fit for the [based array model](based.md), where data doesn't have to be in an array.

#### Rank indicator

The top left corner indicates the rank of an array. Here's a neat way using [Fold](fold.md) (`´`) and [Prefixes](prefixes.md) (`↑`) to nest ranks 0 through 6 together:

        0 ⥊⟜<´ ↑6⥊1

Up to one axis can be oriented horizontally, and then all the rest are laid out vertically. So the horizontal line indicates either no axis with `·` or one with `─`, and the vertical one extends this to multiple segments. The outermost level, a plain [enclosed](enclose.md) array, has no axes—it's a unit—so it has `·` in both directions. The next is a list, with only a horizontal axis, then a table with one axis in each direction. It keeps adding line segments to show more axes up to four vertical axes, or rank 5. After this the rank is just printed as a number. Here are the same corners flattened out and labelled.

     0     1     2     3     4     5
    ┌·    ┌─    ┌─    ┌─    ┌─    ┌─    ┌6    ┌7  …
    ·     ·     ╵     ╎     ┆     ┊     ┊     ┊   …

#### High-rank layout

We've seen already that elements of a list are placed side by side, while the rows of a table (rank-2 array) are stacked on top of each other.

        <¨ ↕5        # A list of units

        2‿3‿4≍1‿0‿5  # A table

The 2-cells of a rank 3 array are *also* stacked on top of each other, but separated by a space. Below is a list of two examples. The second cell in the character array is marked with a `·` to indicate that the gap above it really separates cells as opposed to just being a row of space characters.

        0‿'a' + <2‿3‿4 ⥊ ↕24

The pattern continues: 3-cells are separated by 2 spaces, 4-cells by 3, and so on.

        'a' + 2‿2‿2‿1‿9 ⥊ ↕26  # Rank 5

#### Empty arrays

The top-left corner can show the rank of an array but not its shape; the shape must be seen from the data. An empty array has no data, and it's hard to tell shape from a bunch of blank space. In general, an empty array is printed as `↕shape`. An empty list is shown using brackets `⟨⟩`, which are discussed in the next section.

        ↕¨ ⟨0‿4, 3‿0‿1, 2‿0‿0, 0⟩

A special case is an array of rank 2 where the second axis is empty. Here a row is naturally a blank line, so the shape of the array *can* be inferred from the number of lines between the corners. BQN displays such arrays with a top-right corner wrapping around to indicate the special case. Shown below are arrays with length 0 to 3.

        ↑↕3‿0

### Simple lists

In two cases BQN might use a different format to display a list on one line. The first is for a string (that is, a list of just characters), which is displayed using the exact source code that would generate it. This is different from the array display, which doesn't escape quotes, and substitutes control characters to make sure things stay horizontal.

        "tab(	)+quote("")"

        ≍"tab(	)+quote("")"

The second is for lists with simple enough elements, which are displayed on one line with enclosing `⟨⟩` instead of corners. For this case each element's display needs to fit on one line; the elements might also be bracketed lists but the display will never nest brackets three layers deep.

        ⟨ ↕3, "012", "01"‿"12" ⟩

        ⟨⟨⟨0⟩⟩⟩  # Can't go three levels deep

        ""

This case also covers empty lists, which are shown as `⟨⟩`. This includes an empty string, as the only difference between an empty string and any other empty list is its fill element and array displays don't depend on the fill.

## List literals

*The tutorial section [here](../tutorial/list.md#list-notation) also covers this topic.*

There are three kinds literal notation for lists: strings, list notation, and stranding. Strings indicate character lists (with space for the [fill](fill.md)) and the other two can combine any sequence of elements.

### Strings

A **string** consists of a sequence of characters surrounded by double quotes `""`. The only rule for the characters inside is that any double quote must be escaped by repeating it twice; otherwise the string ends at that point.

        "-'×%""*"

        "-'×%"*"  # Escaping failure

Even special characters like a newline can appear in a string literal, so that string literals are automatically multi-line.

### Brackets

**List notation** uses angle brackets `⟨⟩`. The contents are structurally identical to those of a [block](block.md), that is, a list of expressions [separated](syntax.md#separators) by `,` or `⋄` or newlines. Unlike a block, a list doesn't need to have any expressions: `⟨⟩` or `⟨⋄⟩` or `⟨,,⋄,⟩` will create an empty list. Other differences are that a list doesn't introduce a new [scope](lexical.md) and all of the expressions have to result in a value, not [Nothing](expression.md#nothing) (`·`).

Entries in a list are evaluated in source order, and the value will be the list of those results. The list has a subject role, even if it contains expressions with other roles. Any value can be an element.

        ⟨@, ⍉˘, ≍"abc"⟩

BQN's separator rules give list notation a very flexible structure. You can put all the elements on one line or spread them across lines, with the option of adding blank lines between elements. A separator at the end of a line is never needed but leading and trailing separators are allowed.

    ⟨
      "e0", "e1"
      ⟨
        'e'
        '2'
      ⟩
      "e3", "e4", "e5"

      "e6"
    ⟩

### Strands

**Strand notation** is another way to write lists of length two or more. The elements are connected with the ligature character `‿`. It has a precedence lower than the [namespace](namespace.md) dot but higher than anything else other than paired brackets `()`, `{}`, and `⟨⟩`, so compound elements generally need to be placed in parentheses. Expressions joined by ligatures behave exactly the same as those in list notation: they are evaluated in order and placed in a list.

        +‿´‿∘‿×

        +‿´‿∘‿×  ≡  ⟨+,´,∘,×⟩

Strand notation is mainly useful for simple elements that don't require parentheses. A strand with one set of parentheses is no shorter than using list notation (but could look nicer), and one with more parentheses will be longer.

#### Why not whitespace?

In APL two or more arrays that are next to each other in the code are combined into a list, a convention known as [stranding](https://aplwiki.com/wiki/Strand_notation). So `2 3 5 + 1` adds a list to a number. This looks substantially cleaner than a BQN list, so it's reasonable to ask: why give it up? I admit I've been jealous of that clean look at times. But I'm also finding I view it with a certain unease: what's hiding in that space?

This feeling comes because the language is doing something I didn't ask it to, and it's well justified. Consider the BQN expression `a +˝∘×⎉1‿∞ b` for a matrix product. If we remove the space then we have `…⎉1 ∞ b`. There's no good rule to say which of the three subjects `1`, `∞`, and `b` to strand together. For modifiers like Rank and [Depth](depth.md#the-depth-modifier) we'd like stranding to bind more tightly than modifier application, but in order to actually use arguments for these modifiers the modifier application should take precedence. Similar but simpler cases show up more often when binding an argument to a function. The difference between the following two statements is obvious in BQN, but with space-for-stranding one of them would require a complicating parenthesis.

        3 1⊸+⊸× 5

        3‿1⊸+⊸× 5

Explicit stranding is also more general, because it applies equally to elements of any role. `2‿+‿3` is a perfectly fine list in BQN—maybe it's part of an AST—while `2 + 3` is clearly not a list. Meanwhile J and K restrict their stranding even further, to numbers only. It does mean that issues with stranding show up in fewer cases, but it also means that changing one element of a list from a constant to a variable requires rewriting the whole list.

Why couldn't the more explicit list notation `⟨a,b,c⟩` drop the separators? This is also largely for reasons of generality—even more important here since `⟨⟩` is the more general-purpose list notation. Writing `⟨÷,-,4⟩` without the `,` won't go well. For something like `⟨2×c,b-1⟩`, maybe the interpreter could sort it out but it would be pretty confusing. Pretty soon you're going through the list character by character trying to figure out which space is actually a separator. And cursing, probably.

Fortunately, I find that after a reasonable period of adjustment typing ligatures instead of spaces doesn't feel strange, and reading code is improved overall by the more explicit notation. A minor note is that lists of literal numbers, where APL-style stranding is best, tend to show up more in the snippets that beginners write to test out the language than in programs even in the tens of lines. So this issue sticks out in first experiences with BQN, but will come up less later on.

### Array notation?

BQN has literal notation for lists only right now. To get an array with rank other than 1, either [reshape](reshape.md) a list, or [merge](couple.md#merge-and-array-theory) a list of arrays:

        ∘‿2 ⥊ ⟨2,3, 4,1, 0,5⟩

        > ⟨2‿3, 4‿1, 0‿5⟩

The characters `[]` are reserved to potentially combine list notation with merging, allowing the above to be written `[2‿3, 4‿1, 0‿5]`. This would allow non-empty arrays with rank one or more to be written without a primitive, but not rank 0 or empty arrays. Since creating arrays in general would still require primitives like `<` or `⥊`, it's not clear whether this notation is worth it. General array notation is a surprisingly complicated topic; see the article about it [on the APL Wiki](https://aplwiki.com/wiki/Array_notation).
