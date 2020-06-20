BQN's grammar is given below. All terms except `BraceFunc` `_braceMod` `_braceComp_` are defined in a [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) variant; distinguishing these three terms is not strictly context-free and they are explained near the end.

The symbols `v`, `F`, `_m`, and `_c_` are identifier tokens with value, function, modifier, and composition classes respectively. Similarly, `vl`, `Fl`, `_ml`, and `_cl_` refer to value literals (numeric and character literals, or primitives) of those classes. While names in the BNF here follow the identifier naming scheme, this is informative only: syntactic classes are no longer used after parsing and cannot be inspected in a running program.

A program is a list of statements. Almost all statements are expressions. However, valueless results stemming from `·`, or `𝕨` in a monadic brace function, can be used as statements but not expressions.

    PROGRAM  = ⋄? ( ( STMT ⋄ )* STMT ⋄? )?
    STMT     = EXPR | nothing
    ⋄        = ( "⋄" | "," | \n )+
    EXPR     = valExpr | FuncExpr | _modExpr | _cmpExp_

Here we define the "atomic" forms of functions and operators, which are either single tokens or enclosed in paired symbols. Stranded vectors with `‿`, which binds more tightly than any form of execution, are also included.

    ANY      = atom    | Func     | _mod     | _comp_
    _comp_   = _c_ | _cl_ | _braceComp_ | "(" _cmpExp_ ")"
    _mod     = _m  | _ml  | _braceMod   | "(" _modExpr ")"
    Func     =  F  |  Fl  |  BraceFunc  | "(" FuncExpr ")"
    atom     =  v  |  vl  |  list       | "(" valExpr  ")"
    list     = "⟨" ⋄? ( ( EXPR ⋄ )* EXPR ⋄? )? "⟩"
    value    = atom | ANY ( "‿" ANY )+

Starting at the highest-order objects, modifiers and compositions have fairly simple syntax. In most cases the syntax for `←` and `↩` is the same, but only `↩` can be used for modified assignment.

    ASGN     = "←" | "↩"
    _cmpExp_ = _comp_
             | _c_ ASGN _cmpExp_
    _modExpr = _mod
             | _comp_ ( value | Func )    ⍝ Right partial application
             | Operand _comp_             ⍝ Left partial application
             | _m  ASGN _modExpr

Functions can be formed by fully applying operators or as trains. Operators are left-associative, so that the left operand (`Operand`) can include operators but the right operand (`value | Func`) cannot. Trains are right-associative, but bind less tightly than operators. Assignment is not allowed in the top level of a train: it must be parenthesized.

    Derv     = Func
             | Operand _mod
             | Operand _comp_ ( value | Func )
    Operand  = value
             | Derv
    Fork     = Func
             | Operand Func Fork          ⍝ 3-train
    Train    = Fork
             | Func Fork                  ⍝ 2-train
    FuncExpr = Train
             | F ASGN FuncExpr

Value expressions are complicated by the possibility of list assignment. We also define nothing-statements, which have very similar syntax to value expressions but do not permit assignment.

    arg      = valExpr
             | ( value | nothing )? Derv arg
    nothing  = "·"
             | ( value | nothing )? Derv nothing
    LHS_ANY  = lhsValue | F | _m | _c_
    LHS_ATOM = LHS_ANY | "(" lhsStr ")"
    LHS_ELT  = LHS_ANY | lhsStr
    lhsValue = v
             | "⟨" ⋄? ( ( LHS_ELT ⋄ )* LHS_ELT ⋄? )? "⟩"
    lhsStr   = LHS_ATOM ( "‿" LHS_ATOM )+
    lhs      = lhsValue | lhsStr
    valExpr  = arg
             | v ASGN valExpr
             | v Derv "↩" valExpr         ⍝ Modified assignment

One aspect of BQN grammar is not context-free: determining the syntactic class of a brace definition. The terms `BraceFunc` `_braceMod` `_braceComp_` all obey the syntax for `BRACED` given below. Then the class is determined by the presence of `𝕗` and `𝕘` (including alternate class spellings) at the top level, that is, not contained within further pairs of braces. If `𝕘` is present, it is a `_braceCmp_`; otherwise, if `𝕗` is present it it a `_braceMod` and otherwise a `BraceFunc`. The presence of `𝕨` or `𝕩` has an effect on the evaluation of modifiers and combinators but not their syntactic class.

    BRACED   = "{" ⋄? ( STMT ⋄ )* EXPR ⋄? "}"
