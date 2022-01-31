*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/block.html).*

# Blocks

In BQN, a *block* is any piece of code surrounded with curly braces `{}`. Blocks can be used simply to group statements, or can define functions or modifiers. They are the sole large-scale structure used to organize programs. An important aspect of organization is [namespaces](namespace.md), which are created with blocks but not discussed on this page.

Blocks are most commonly used to define functions by including one of the special names for arguments, `𝕨` or `𝕩`. With the operands `𝔽` or `𝔾`, they can also define 1-modifiers or 2-modifiers.

        {𝕩+1} 3
        ×{𝕩𝔽𝕩} 4

Because they use [lexical scoping](lexical.md), blocks can also be used to encapsulate code. If a block uses only variables that it initializes, then it has no dependence on its environment and would work the same way if defined anywhere. But it can also use external variables, defined in a containing block.

        a←b←"outer"
        { a←"inner" ⋄ a‿b }

## Headerless blocks

In the simplest case a block is just a list of statements, which are executed to *evaluate* the block. A block with no special names like `𝕨` or `𝕩` is called an *immediate block*, and is evaluated as soon as it is reached. The only thing such a block does is group some statements, and create a scope for them so that definitions made there are discarded when the block finishes. Even this small amount of functionality could be useful; as an example the following program can build up an array from named components without polluting the rest of the program with those names.

        updown ← { up←↕5 ⋄ down←⌽up ⋄ up∾down }
        updown

An immediate block is only ever evaluated once, and can't be used for control flow in a program. Including special names in a headerless block lets us define functions and modifiers, which have a broader range of uses. All special names are listed below:

| Lowercase | Uppercase | Meaning
|-----------|-----------|---------
| `𝕩`       | `𝕏`       | Right [argument](#arguments)
| `𝕨`       | `𝕎`       | Left [argument](#arguments), or [Nothing](expression.md#nothing) (`·`)
| `𝕤`       | `𝕊`       | Function [self-reference](#self-reference)
| `𝕗`       | `𝔽`       | Left [operand](#operands)
| `𝕘`       | `𝔾`       | Right [operand](#operands)
| `𝕣`       | none      | Modifier [self-reference](#self-reference)

Of these, `𝕣` is sort of a "more special" character, as we'll discuss below. Except for `𝕣`, every special name is a single character and can't have underscores added to spell it as a modifier. This allows a modifier to be applied to a special name with no spacing, as in `𝕗_m`, where it couldn't be with ordinary names.

### Arguments

The names `𝕨` and `𝕩`, and their uppercase spellings, represent function arguments. As the argument to a function is typically data, it's more common to use the lowercase forms for these. Having either of these names turns an immediate block into a function (or an immediate modifier into a deferred one; see the next section). Instead of being evaluated as soon as it appears in the source, a function is evaluated when it's called, with the special names set to appropriate values. Their values can be changed like ordinary variables.

        {'c'=𝕩} "abcd"
        { 𝕩+↩2 ⋄ 0≍𝕩 } 3
        4 { ⟨𝕩⋄-𝕨⟩ } 5

A function with `𝕨` in its definition doesn't have to be called with two arguments. If it has only one, then `𝕨` is given the special value [Nothing](expression.md#nothing), or `·`. This is the only time a variable can ever be Nothing, as an assignment such as `v←·` is not allowed.

        3 { (2×𝕨)-𝕩 } 1
          { (2×𝕨)-𝕩 } 1

In the second function, `𝕨` behaves just like `·`, so that the function `2×𝕨` is not evaluated and `-` doesn't have a left argument. It has a similar effect when used as the left argument to a function in a train.

        "abc" { (𝕨≍⌽) 𝕩 } "def"
              { (𝕨≍⌽) 𝕩 } "def"

However, `·` can only be used as an argument, and not a list element or operand. Don't use `𝕨` in these ways in a function that could be called monadically. Another potential issue is that `⊸` and `⟜` don't work the way you might expect.

        { 𝕨 ⋆⊸- 𝕩 } 5

Called dyadically, this function will expand to `(⋆𝕨)-𝕩`, so we might expect the monadic result to be `-𝕩`. This sort of expansion isn't right with `·` on the left. `⋆⊸-` taken as a whole is a function, so `· ⋆⊸- 𝕩` is just `⋆⊸- 𝕩`, or `(⋆𝕩)-𝕩`, giving the large result seen above.

### Operands

The special names `𝔽` and `𝔾`, and their lowercase forms, represent operands. Since operands are more often functions, they're typically shown with the uppercase spelling. If `𝔽` is present in a block then it defines a 1-modifier or 2-modifier depending on whether `𝔾` is present; if `𝔾` is there it's always a 2-modifier.

        4 {×˜𝕗}
        2 {𝕗+𝕘} 3

As shown above, modifiers without `𝕨`, `𝕩`, or `𝕤` behave essentially like functions with a higher precedence. These *immediate modifiers* take operands and return a result of any type. The result is given a function role, so it's most common to return a function, rather than a number as shown above.

        _dot_ ← {𝔽´∘𝔾}
        1‿2‿3 +_dot_× 1‿0‿1

However, if one of these names is included, then a *deferred modifier* is created instead: rather than evaluate the contents when the modifier is called, the operands are bound to it to create a derived function. When this function is called, the statements in the block are evaluated.

        +{𝕩𝔽𝕩} 6
        2 ⥊{⟨𝔽𝕨,𝔾𝕩⟩}- 5

The distinction between an immediate and deferred modifier only matters inside the braces. Once defined, the object is simply a modifier that can be called on operands to return a result. For a deferred modifier this result will always be a function; for an immediate modifier it could be anything.

### Self-reference

If a block is assigned a name after it is created, this name can be used for recursion:

        Fact ← { 𝕩 × (0⊸<)◶1‿Fact 𝕩-1 }
        Fact 7
        (×´1+↕) 7  # There's often a simpler solution than recursion

This is somewhat unsatisfying because it is external to the function being defined, even though it doesn't depend on outside information. Instead, the special name `𝕊` can be used to refer to the function it appears in. This allows anonymous recursive functions to be defined.

        { 𝕩 × (0⊸<)◶1‿𝕊 𝕩-1 } 7

For modifiers, `𝕣` refers to the containing modifier. `𝕊` makes the modifier a deferred modifier like `𝕨` and `𝕩` do, and refers to the derived function. For example, this tail-recursive factorial function uses the operand to accumulate a result, a task that is usually done with a second `factorial_helper` function in elementary Scheme.

        Fact_mod ← 1 { (0⊸<)◶⟨𝕗, (𝕗×𝕩)_𝕣⟩ 𝕩-1 }
        Fact_mod 7

Because `𝕣` only ever refers to a 1-modifier or 2-modifer, it can never make sense to refer to it as a function, and the uppercase letter `ℝ` is not recognized by BQN. In order to allow `𝕣` to be spelled as a 1-modifier `_𝕣` or 2-modifier `_𝕣_`, it is treated as an ordinary identifier character, so it must be separated from letters or numbers by spaces.

## Block headers

As a program becomes larger, it often becomes necessary to name inputs to blocks rather than just using special names. It can also become difficult to identify what kind of block is being defined, as it requires scanning through the block for special names. A *block header*, which is separated from the body of a block by a colon `:`, specifies the kind of block and can declare names for the block and its inputs.

    Fact ← { F n:
      n × (0⊸<)◶1‿F n-1
    }

Its syntax mirrors an application of the block. As suggested by the positioning, the names given in a header apply only inside the block: for example `F` above is only defined inside the `{}` braces while `Fact` could be used either outside or inside. Some other possibilites are given below.

    # A dyadic function that refers to itself as Func
    { l Func r:
      …

    # A deferred 1-modifier with a list argument
    { Fn _apply ⟨a,b⟩:
      …

    # A monadic function with no names given
    { 𝕊𝕩:
      …

    # An immediate 2-modifier with some destructuring
    { F _op_ ·‿val:
      …

In all cases special names still work just like in a headerless function. In this respect the effect of the header is the same as a series of assignments at the beginning of a function, such as the following translation of the second header above:

    { # Fn _apply ⟨a,b⟩:
      Fn ← 𝔽
      _apply ← _𝕣
      ⟨a,b⟩ ← 𝕩
      …

Unlike these assignments, the header also constrains what inputs the block can take: a monadic 1-modifier like the one above can't take a right operand or left argument, and consequently its body can't contain `𝔾` or `𝕨`. Calling it with a left argument, or a right argument that isn't a two-element list, will result in an error.

### Destructuring

Arguments and operands allow [destructuring](expression.md#destructuring) like assignment does. While assignment only tolerates lists of variables, header destructuring also allows constants. The argument must match the given structure, including the constants where they appear, or an error results.

        Destruct ← { 𝕊 a‿1‿⟨b,·,2⟩: a≍b }
        Destruct       5‿1‿⟨7,π,2⟩

### Special names in headers

Any element of a function or modifier header can be left nameless by using the corresponding special name in that position, instead of an identifier. For example, the header `𝕨 𝔽_𝕣_𝔾 𝕩:` incorporates as much vagueness as possible. It indicates a deferred 2-modifier, but provides no other information.

The name `𝕨` in this context can refer to either a left argument or no left argument, allowing a header with arguments to be used even for an ambiguous function. Recall that `𝕨` is the only token other than `·` that can have no value. If an identifier or list is given as the left argument, then the function must be called with a left argument.

### Short headers

A header can also be a plain name with no inputs, called a *label*. A label specifies the type of the block and gives an internal name that can be used to refer to it, but doesn't specify the inputs.

    { b:   # Block
    { 𝕊:   # Function
    { _𝕣:  # 1-Modifier
    { _𝕣_: # 2-Modifier

For immediate blocks, this is the only type of header possible, and it must use an identifier as there is no applicable special name. However, the name can't be used in code: it doesn't make sense to refer to a value while it is still being computed!

## Multiple bodies

Blocks can include more than one body, separated by semicolons `;`. The body used for a particular evaluation is chosen based on the arguments the the block. One special case is that functions and deferred modifiers can have two headerless bodies (that is, no headers or predicates—see below): the first applies when there's one argument and the second when there are two.

        Ambiv ← { ⟨1,𝕩⟩ ; ⟨2,𝕨,𝕩⟩ }
        Ambiv 'a'
        'a' Ambiv 'b'

Bodies with headers come before any that don't have them. When a block is called, its headers are checked in order for compatibility with the arguments, and the first body with a compatible header is used.

        CaseAdd ← { 2𝕊3:0‿5 ; 2𝕊𝕩:⟨1,2+𝕩⟩ ; 𝕊𝕩:2‿𝕩 }
        2 CaseAdd 3
        2 CaseAdd 4
          CaseAdd 4

If no header is compatible, the call results in an error.

        3 CaseAdd 3

### Case headers

A special rule allows for convenient case-matching syntax for one-argument functions. In any function header with one argument, the function name can be omitted as long as the argument is *not* a plain identifier—it must be `𝕩` or a compound value like a list to distinguish it from an immediate block label.

    Test ← {
      "abc": "string" ;
      ⟨2,b⟩: ⌽𝕩       ;
      5:     "number" ;
      𝕩:     "default"
    }

These case-style headers function exactly the same as if they were preceded by `𝕊`, and can be mixed with other kinds of headers.

### Predicates

Destructuring with a header is quite limited, only allowing matching structure and data with exact equality. A predicate, written with `?`, allows you to test an arbitrary property before evaluating the rest of the body, and also serves as a limited kind of control flow. It can be thought of as an extension to a header, so that for example the following function requires the argument to have two elements and for the first to be less than the second before using the first body. Otherwise it moves to the next body, which is unconditional.

        CheckPair ← { 𝕊⟨a,b⟩: a<b? "ok" ; "not ok" }

        CheckPair ⟨3,8⟩    # Fails destructuring
        CheckPair ⟨1,4,5⟩  # Not a pair
        CheckPair ⟨3,¯1⟩   # Not ascending

The body where the predicate appears doesn't need to start with a header, and there can be other statements before it. In fact, `?` functions just like a separator (like `⋄` or `,`) with a side effect.

        { r←⌽𝕩 ⋄ 't'=⊑r ? r ; 𝕩 }¨ "test"‿"this"

So `r` is the reversed argument, and if its first character (the last one in `𝕩`) is `'t'` then it returns `r`, and otherwise we abandon that line of reasoning and return `𝕩`. This sounds a lot like an if statement. And `{ a<b ? a ; b }`, which computes `a⌊b` the hard way, shows how the syntax can be similar to a ternary operator. This is an immediate block with multiple bodies, something that makes sense with predicates but not headers. But `?;` offers more possibilities. It can support any number of options, with multiple tests for each one—the structure below is "if \_ and \_ then \_; else if \_ then \_; else \_".

        Thing ← { 𝕩≥3? 𝕩≤8? 2|𝕩 ; 𝕩=0? @ ; ∞ }

        (⊢ ≍ Thing¨) ↕10  # Table of arguments and results

This structure is still constrained by the rules of block bodies: each instance of `;` is a separate scope, so that variables defined before a `?` don't survive past the `;`.

        { 0=n←≠𝕩 ? ∞ ; n } "abc"

This is the main drawback of predicates relative to guards in APL dfns (also written with `?`), while the advantage is that it allows multiple expressions, or extra conditions, after a `?`. It's not how I would have designed it if I just wanted to make a syntax for if statements, but it's a natural fit for the header system.
