BQN's grammar is given below. All terms except `braceVal`, `BraceFunc`, `_braceMod`, and `_braceComp_` are defined in a [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) variant; distinguishing these four terms is possible but difficult in BNF and they are explained near the end.

The symbols `v`, `F`, `_m`, and `_c_` are identifier tokens with value, function, modifier, and composition classes respectively. Similarly, `vl`, `Fl`, `_ml`, and `_cl_` refer to value literals (numeric and character literals, or primitives) of those classes. While names in the BNF here follow the identifier naming scheme, this is informative only: syntactic classes are no longer used after parsing and cannot be inspected in a running program.

A program is a list of statements. Almost all statements are expressions. However, explicit definitions and valueless results stemming from `·`, or `𝕨` in a monadic brace function, can be used as statements but not expressions.

    PROGRAM  = ⋄? ( ( STMT ⋄ )* STMT ⋄? )?
    STMT     = EXPR | DEF | nothing
    ⋄        = ( "⋄" | "," | \n )+
    EXPR     = valExpr | FuncExpr | _modExpr | _cmpExp_

Here we define the "atomic" forms of functions and operators, which are either single tokens or enclosed in paired symbols. Stranded vectors with `‿`, which binds more tightly than any form of execution, are also included.

    ANY      = atom    | Func     | _mod     | _comp_
    _comp_   = _c_ | _cl_ | "(" _cmpExp_ ")" | _braceComp_
    _mod     = _m  | _ml  | "(" _modExpr ")" | _braceMod  
    Func     =  F  |  Fl  | "(" FuncExpr ")" |  BraceFunc 
    atom     =  v  |  vl  | "(" valExpr  ")" |  braceVal
             | "⟨" ⋄? ( ( EXPR ⋄ )* EXPR ⋄? )? "⟩"
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
             | lhs ASGN valExpr
             | lhs Derv "↩" valExpr         ⍝ Modified assignment

In an explicit definition, the left hand side looks like application of a function, modifier, or combinator. As with assignment, it is restricted to a simple form with no extra parentheses. The full list syntax is allowed for arguments.

    DEF      = VALDEF | FUNCDEF
    VALDEF   = valLHS  "⇐" valExpr
    FUNCDEF  = FuncLHS "⇐" FuncExpr
    FuncLHS  = F _m
             | F _c_ F
    valLHS   = lhs? ( F | FuncLHS ) lhs

The terms `braceVal`, `BraceFunc`, `_braceMod`, and `_braceComp_` all obey the syntax for `BRACED` given below. Then the class is determined by the presence of `𝕨`, `𝕩`, `𝕗`, and `𝕘` (including alternate class spellings) at the top level, that is, not contained within further pairs of braces. If `𝕘` is present, it is a `_braceCmp_`; otherwise, if `𝕗` is present it is a `_braceMod`; otherwise is is a `BraceFunc` if `𝕨` or `𝕩` are present and a `braceVal` if no special names appear.

    BRACED   = "{" ⋄? ( STMT ⋄ )* EXPR ⋄? "}"

This rule can be expressed in BNF by making many copies of all the rules above. For each "level" (no special names; arguments; `𝕗`; `𝕘`), a new version of every rule should be made that allows that level but not higher ones, and another version should be made that requires exactly that level. The values themselves should be included in `v`, `F`, `_m`, and `_c_` for these copies. Then the "allowed" rules are made simply by replacing the terms they contain with the same "allowed" versions, and "required" rules are constructed using both "allowed" and "required" rules. For every part of a production rule, an alternative should be created that requires the relevant name in that part while allowing it in the others. For example, `( value | nothing )? Derv arg` would be transformed to

    arg_req1 = valExpr_req1
             | ( value_req1 | nothing_req1 ) Derv_allow1 arg_allow1
             | ( value_allow1 | nothing_allow1 )? Derv_req1 arg_allow1
             | ( value_allow1 | nothing_allow1 )? Derv_allow1 arg_req1

Quite tedious. The explosion of rules is partly due to the fact that the brace-typing rule falls into a weaker class of grammars than the other rules. The rest of BQN is [deterministic context-free](https://en.wikipedia.org/wiki/Deterministic_context-free_grammar) while brace-typing is not, only context-free. Fortunately brace typing does not introduce the parsing difficulties that can be present in a general context-free grammar, and it can easily be performed in linear time: after [scanning](token.md) but before parsing, move through the source code maintaining a stack of the current top-level set of braces. Whenever a special name is encountered, annotate that set of braces to indicate that the name is present. When a closing brace is encountered and the top brace is popped off the stack, the type can be found based on which names were present. One way to present this information to the parser is to replace the brace tokens with new tokens that indicate the type.
