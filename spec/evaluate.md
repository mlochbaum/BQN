*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/evaluate.html).*

# Specification: BQN evaluation

This page describes the semantics of the code constructs whose grammar is given in [grammar.md](grammar.md). The formation rules there are not named, and here they are identified by either the name of the term or by copying the rule entirely if there are several alternative productions.

Here we assume that the referent of each identifier, or equivalently the connections between identifiers, have been identified according to the [scoping rules](scope.md).

### Programs and blocks

The result of parsing a valid BQN program is a `PROGRAM`, and the program is run by evaluating this term.

A `PROGRAM` or `BODY` is a list of `STMT`s (for `BODY`, the last must be an `EXPR`, a particular kind of `STMT`), which are evaluated in program order. The statement `EXPR` evaluates some APL code and possibly assigns the results, while `nothing` evaluates any `subject` or `Derv` terms it contains but discards the results.

A block consists of several `BODY` terms, some of which may have an accompanying header describing accepted inputs and how they are processed. An immediate block `brImm` can only have one `BODY`, and is evaluated by evaluating the code in it. Other types of blocks do not evaluate any `BODY` immediately, but instead return a function or modifier that obtains its result by evaluating a particular `BODY`. The `BODY` is identified and evaluated once the block has received enough inputs (operands or arguments), which for modifiers can take one or two calls: if two calls are required, then on the first call the operands are simply stored and no code is evaluated yet. Two calls are required if there is more than one `BODY` term, if the `BODY` contains the special names `𝕨𝕩𝕤𝕎𝕏𝕊`, or if its header specifies arguments (the header-body combination is a `_mCase` or `_cCase_`). Otherwise only one is required.

To evaluate a block when enough inputs have been received, first the correct case must be identified. To do this, first each special case (`FCase`, `_mCase`, or `_cCase_`) is checked in order to see if its arguments are strucurally compatible with the given arguments. That is, is `headW` is a `subject`, there must be a left argument matching that structure, and if `headX` is a `subject`, the right argument must match that structure. This means that `𝕨` not only matches any left argument but also no argument. The test for compatibility is the same as for multiple assignment described below, except that the header may contain constants, which must match the corresponding part of the given argument.If no special case matches, then an appropriate general case (`FMain`, `_mMain`, or `_cMain_`) is used: if there are two, the first is used with no left argument and the second with a left argument; if there are one, it is always used, and if there are none, an error results.

The only remaining step before evaluating the `BODY` is to bind the inputs and other names. Special names are always bound when applicable: `𝕨𝕩𝕤` if arguments are used, `𝕨` if there is a left argument, `𝕗𝕘` if operands are used, and `_𝕣` and `_𝕣_` for modifiers and combinators, respectively. Any names in the header are also bound, allowing multiple assignment for arguments.

If there is no left argument, but the `BODY` contains `𝕨` at the top level, then it is conceptually re-parsed with `𝕨` replaced by `·` to give a monadic version before application; this modifies the syntax tree by replacing some instances of `arg` with `nothing`. However, it also causes an error if, in a function that is called with no left argument, `𝕨` is used as an operand or list element, where `nothing` is not allowed by the grammar. The same effect can also be achieved dynamically by treating `·` as a value and checking for it during execution. If it is used as a left argument, then the function should instead be called with no left argument (and similarly in trains); it it is used as a right argument, then the function and its left argument are evaluated but rather than calling the function `·` is "returned" immediately; and if it is used in another context then it causes an error.

### Assignment

An *assignment* is one of the four rules containing `ASGN`. It is evaluated by first evaluating the right-hand-side `subExpr`, `FuncExpr`, `_m1Expr`, or `_m2Exp_` expression, and then storing the result in the left-hand-side identifier or identifiers. The result of the assignment expression is the result of its right-hand side. Except for subjects, only a lone identifier is allowed on the left-hand side and storage sets it equal to the result. For subjects, *multiple assignment* with a list left-hand side is also allowed. Multiple assignment is performed recursively by assigning right-hand-side values to the left-hand-side targets, with single-identifier (`s`) assignment as the base case. When matching the right-hand side to a list left-hand side, the left hand side is treated as a list of `lhs` targets. The evaluated right-hand side must be a list (rank-1 array) of the same length, and is matched to these targets element-wise.

*Modified assignment* is the subject assignment rule `lhs Derv "↩" subExpr`. In this case, `lhs` should be evaluated as if it were a `subExpr` (the syntax is a subset of `subExpr`), and the result of the function application `lhs Derv subExpr` should be assigned to `lhs`, and is also the result of the modified assignment expression.

### Expressions

We now give rules for evaluating an `atom`, `Func`, `_mod1` or `_mod2_` expression (the possible options for `ANY`). A literal or primitive `sl`, `Fl`, `_ml`, or `_cl_` has a fixed value defined by the specification ([literals](literal.md) and [built-ins](primitive.md)). An identifier `s`, `F`, `_m`, or `_c_` is evaluated by returning its value; because of the scoping rules it must have one when evaluated. A parenthesized expression such as `"(" _modExpr ")"` simply returns the result of the interior expression. A braced construct such as `BraceFunc` is defined by the evaluation of the statements it contains after all parameters are accepted. Finally, a list `"⟨" ⋄? ( ( EXPR ⋄ )* EXPR ⋄? )? "⟩"` or `ANY ( "‿" ANY )+` consists grammatically of a list of expressions. To evaluate it, each expression is evaluated in source order and their results are placed as elements of a rank-1 array. The two forms have identical semantics but different punctuation.

Rules in the table below are function and modifier evaluation.
|  L  | Left                      | Called   | Right                 |  R  | Types
|-----|---------------------------|----------|-----------------------|-----|-----------
| `𝕨` | `( subject \| nothing )?` | `Derv`   | `arg`                 | `𝕩` | Function, subject
| `𝕗` | `Operand`                 | `_mod1`  |                       |     | 1-Modifier
| `𝕗` | `Operand`                 | `_mod2_` | `( subject \| Func )` | `𝕘` | 2-Modifier

In each case the constituent expressions are evaluated in reverse source order: Right, then Called, then Left. Then the expression's result is obtained by calling the Called value on its parameters. A left argument of `nothing` is not used as a parameter, leaving only a right argument in that case. The type of the Called value must be appropriate to the expression type, as indicated in the "Types" column. For function application, a data type (number, character, or array) is allowed. It is called simply by returning itself. Although the arguments are ignored in this case, they are still evaluated. A braced construct is evaluated by binding the parameter names given in columns L and R to the corresponding values. Then if all parameter levels present have been bound, its body is evaluated to give the result of application.

The following rules derive new functions or modifiers from existing ones.
| Left       | Center    | Right                 | Result
|------------|-----------|-----------------------|--------------
|            | `_mod2_`  | `( subject \| Func )` | `{𝔽 _C_ R}`
| `Operand`  | `_mod2_`  |                       | `{L _C_ 𝔽}`
| `Operand`  |  `Derv`   | `Fork`                | `{(𝕨L𝕩)C(𝕨R𝕩)}`
| `nothing?` |  `Derv`   | `Fork`                | `{     C(𝕨R𝕩)}`

As with applications, all expressions are evaluated in reverse source order before doing anything else. Then a result is formed without calling the center value. Its value in BQN is given in the rightmost column, using `L`, `C`, and `R` for the results of the expressions in the left, center, and right columns, respectively. For the first two rules (*partial application*), the given operand is bound to the 2-modifier: the result is a 1-modifier that, when called, calls the center 2-modifier with the bound operand on the same side it appeared on and the new operand on the remaining side. A *train* is a function that, when called, calls the right-hand function on all arguments, then the left-hand function, and calls the center function with these results as arguments. In a modifier partial application, the result will fail when applied if the center value does not have the 2-modifier type, and in a fork, it will fail if any component has a modifier type (that is, cannot be applied as a function). BQN implementations are not required to check for these types when forming the result of these expressions, but may give an error on formation even if the result will never be applied.
