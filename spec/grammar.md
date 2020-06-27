BQN's grammar is given below. Terms are defined in a [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) variant. However, handling special names properly is possible but difficult in BNF, so they are explained in text along with the braced block grammar.

The symbols `v`, `F`, `_m`, and `_c_` are identifier tokens with value, function, modifier, and composition classes respectively. Similarly, `vl`, `Fl`, `_ml`, and `_cl_` refer to value literals (numeric and character literals, or primitives) of those classes. While names in the BNF here follow the identifier naming scheme, this is informative only: syntactic classes are no longer used after parsing and cannot be inspected in a running program.

A program is a list of statements. Almost all statements are expressions. However, explicit definitions and valueless results stemming from `·`, or `𝕨` in a monadic brace function, can be used as statements but not expressions.

    PROGRAM  = ⋄? ( ( STMT ⋄ )* STMT ⋄? )?
    STMT     = EXPR | DEF | nothing
    ⋄        = ( "⋄" | "," | \n )+
    EXPR     = valExpr | FuncExpr | _modExpr | _cmpExp_

Here we define the "atomic" forms of functions and operators, which are either single tokens or enclosed in paired symbols. Stranded vectors with `‿`, which binds more tightly than any form of execution, are also included.

    ANY      = atom    | Func     | _mod     | _comp_
    _comp_   = _c_ | _cl_ | "(" _cmpExp_ ")" | _brComp_
    _mod     = _m  | _ml  | "(" _modExpr ")" | _brMod  
    Func     =  F  |  Fl  | "(" FuncExpr ")" |  BrFunc 
    atom     =  v  |  vl  | "(" valExpr  ")" |  brVal | list
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
             | nothing Func Fork          ⍝ 2-train
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
             | lhs Derv "↩" valExpr       ⍝ Modified assignment

A header looks like a name for the thing being headed, or its application to inputs (possibly twice in the case of modifiers and compositions). As with assignment, it is restricted to a simple form with no extra parentheses. The full list syntax is allowed for arguments. As a special rule, a function header specifically can omit the function.

    headW    = value | "𝕨"
    headX    = value | "𝕩"
    HeadF    = F | "𝕗" | "𝔽"
    HeadG    = G | "𝕘" | "𝔾"
    ModH1    = HeadF ( _m  | "_𝕣"  )
    CmpH1    = HeadF ( _c_ | "_𝕣_" ) HeadG
    valHead  =  v
    FuncHead =  F  | headW? ( F | "𝕊" ) headX
             | vl | "(" valExpr ")" | brVal | list  ⍝ value but not v
    _modHead = _m  | ModH1 | headW? ModH1 headX
    _cmpHed_ = _c_ | CmpH1 | headW? CmpH1 headX

A braced block contains bodies, which are lists of statements, separated by semicolons and possibly preceded by headers, which are separated from the body with a colon. Multiple bodies allow different handling for various cases, which are pattern-matched by headers. For a value block there are no inputs, so there can only be one possible case and one body. Functions and operators allow any number of bodies with headers followed by at most two bodies without headers. These bodies refer to the general cases: ambivalent if there is only one and split into monadic and dyadic if there are two.

    BODY     = ⋄? ( STMT ⋄ )* EXPR ⋄?
    FuncCase = ⋄? FuncHead ":" BODY
    _modCase = ⋄? _modHead ":" BODY
    _cmpCas_ = ⋄? _cmpHed_ ":" BODY
    brVal    = "{" ( ⋄? valHead ":" )? BODY "}"
    BrFunc   = "{" ( FuncCase ";" )* ( FuncCase | BODY | BODY ";" BODY ) "}"
    _brMod   = "{" ( _modCase ";" )* ( _modCase | BODY | BODY ";" BODY ) "}"
    _brComp_ = "{" ( _cmpCas_ ";" )* ( _cmpCas_ | BODY | BODY ";" BODY ) "}"

Two additional rules apply to blocks, based on the special name associations in the table below. First, each block allows the special names in its column to be used as the given token types within `BODY` terms (not headers). Except for the spaces labelled "None", each column is cumulative and a given entry also includes all the entries above it. Second, for `BrFunc`, `_brMod`, and `_brComp_` terms, if no header is given, then at least one `BODY` term in it *must* contain one of the names on, and not above, the corresponding row. Otherwise the syntax would be ambiguous, since for example a simple `"{" BODY "}"` sequence could have any type.

| Term               | `v`    | `F`    | `_m`    | `_c_`    | other
|--------------------|--------|--------|---------|----------|-------
| `brVal`, `PROGRAM` | None   | None   | None    | None     |
| `BrFunc`           | `𝕨𝕩𝕤`  | `𝕎𝕏𝕊`  |         |          | `";"`
| `_brMod`           | `𝕗𝕣`   | `𝔽`    | `_𝕣`    |          |
| `_brComp_`         | `𝕘`    | `𝔾`    | None    | `_𝕣_`    |

The rules for special name can be expressed in BNF by making many copies of all expression rules above. For each "level", or row in the table, a new version of every rule should be made that allows that level but not higher ones, and another version should be made that requires exactly that level. The values themselves should be included in `v`, `F`, `_m`, and `_c_` for these copies. Then the "allowed" rules are made simply by replacing the terms they contain (excluding `brVal` and so on) with the same "allowed" versions, and "required" rules are constructed using both "allowed" and "required" rules. For every part of a production rule, an alternative should be created that requires the relevant name in that part while allowing it in the others. For example, `( value | nothing )? Derv arg` would be transformed to

    arg_req1 = valExpr_req1
             | ( value_req1 | nothing_req1 ) Derv_allow1 arg_allow1
             | ( value_allow1 | nothing_allow1 )? Derv_req1 arg_allow1
             | ( value_allow1 | nothing_allow1 )? Derv_allow1 arg_req1

Quite tedious. The explosion of rules is partly due to the fact that the brace-typing rule falls into a weaker class of grammars than the other rules. Most of BQN is [deterministic context-free](https://en.wikipedia.org/wiki/Deterministic_context-free_grammar) but brace-typing is not, only context-free. Fortunately brace typing does not introduce the parsing difficulties that can be present in a general context-free grammar, and it can easily be performed in linear time: after [scanning](token.md) but before parsing, move through the source code maintaining a stack of the current top-level set of braces. Whenever a colon or special name is encountered, annotate that set of braces to indicate that it is present. When a closing brace is encountered and the top brace is popped off the stack, the type is needed if there was no colon, and can be found based on which names were present. One way to present this information to the parser is to replace the brace tokens with new tokens that indicate the type.
