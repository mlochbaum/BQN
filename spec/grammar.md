*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/grammar.html).*

BQN's grammar is given below. Terms are defined in a [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) variant. However, handling special names properly is possible but difficult in BNF, so they are explained in text along with the braced block grammar.

The symbols `s`, `F`, `_m`, and `_c_` are identifier tokens with subject, function, 1-modifier, and 2-modifier classes respectively. Similarly, `sl`, `Fl`, `_ml`, and `_cl_` refer to literals and primitives of those classes. While names in the BNF here follow the identifier naming scheme, this is informative only: syntactic classes are no longer used after parsing and cannot be inspected in a running program.

A program is a list of statements. Almost all statements are expressions. However, explicit definitions and valueless results stemming from `·`, or `𝕨` in a monadic brace function, can be used as statements but not expressions.

    PROGRAM  = ⋄? ( ( STMT ⋄ )* STMT ⋄? )?
    STMT     = EXPR | DEF | nothing
    ⋄        = ( "⋄" | "," | \n )+
    EXPR     = subExpr | FuncExpr | _m1Expr | _m2Expr_

Here we define the "atomic" forms of functions and modifiers, which are either single tokens or enclosed in paired symbols. Stranded vectors with `‿`, which binds more tightly than any form of execution, are also included.

    ANY      = atom    | Func     | _mod1    | _mod2_
    _mod2_   = _c_ | _cl_ | "(" _m1Expr_ ")" | _brMod2_
    _mod1    = _m  | _ml  | "(" _m2Expr  ")" | _brMod1
    Func     =  F  |  Fl  | "(" FuncExpr ")" |  BrFunc
    atom     =  s  |  sl  | "(" subExpr  ")" |  brSub | list
    list     = "⟨" ⋄? ( ( EXPR ⋄ )* EXPR ⋄? )? "⟩"
    subject  = atom | ANY ( "‿" ANY )+

Starting at the highest-order objects, modifiers have fairly simple syntax. In most cases the syntax for `←` and `↩` is the same, but only `↩` can be used for modified assignment.

    ASGN     = "←" | "↩"
    _m2Expr_ = _mod2_
             | _c_ ASGN _m2Expr_
    _m1Expr  = _mod1
             | _mod2_ ( subject | Func )  # Right partial application
             | Operand _mod2_             # Left partial application
             | _m  ASGN _m1Expr

Functions can be formed by fully applying modifiers or as trains. modifiers are left-associative, so that the left operand (`Operand`) can include modifier applications but the right operand (`subject | Func`) cannot. Trains are right-associative, but bind less tightly than modifiers. Assignment is not allowed in the top level of a train: it must be parenthesized.

    Derv     = Func
             | Operand _mod1
             | Operand _mod2_ ( subject | Func )
    Operand  = subject
             | Derv
    Fork     = Derv
             | Operand Derv Fork          # 3-train
             | nothing Derv Fork          # 2-train
    Train    = Fork
             | Derv Fork                  # 2-train
    FuncExpr = Train
             | F ASGN FuncExpr

Subject expressions are complicated by the possibility of list assignment. We also define nothing-statements, which have very similar syntax to subject expressions but do not permit assignment.

    arg      = subExpr
             | ( subject | nothing )? Derv arg
    nothing  = "·"
             | ( subject | nothing )? Derv nothing
    LHS_ANY  = lhsSub | F | _m | _c_
    LHS_ATOM = LHS_ANY | "(" lhsStr ")"
    LHS_ELT  = LHS_ANY | lhsStr
    lhsSub   = s
             | "⟨" ⋄? ( ( LHS_ELT ⋄ )* LHS_ELT ⋄? )? "⟩"
    lhsStr   = LHS_ATOM ( "‿" LHS_ATOM )+
    lhs      = lhsSub | lhsStr
    subExpr  = arg
             | lhs ASGN subExpr
             | lhs Derv "↩" subExpr       # Modified assignment

A header looks like a name for the thing being headed, or its application to inputs (possibly twice in the case of modifiers). As with assignment, it is restricted to a simple form with no extra parentheses. The full list syntax is allowed for arguments. As a special rule, a monadic function header specifically can omit the function when the argument is not just a name (as this would conflict with a subject label). The following cases define only headers with arguments, which are assumed to be special cases; there can be any number of these. Headers without arguments can only refer to the general case—note that operands are not pattern matched—so there can be at most two of these kinds of headers, indicating the monadic and dyadic cases.

    headW    = subject | "𝕨"
    headX    = subject | "𝕩"
    HeadF    = F | "𝕗" | "𝔽"
    HeadG    = F | "𝕘" | "𝔾"
    Mod1H1   = HeadF ( _m  | "_𝕣"  )
    Mod2H1   = HeadF ( _c_ | "_𝕣_" ) HeadG
    FuncHead = headW? ( F | "𝕊" ) headX
             | sl | "(" subExpr ")" | brSub | list   # subject,
             | ANY ( "‿" ANY )+                      # but not s
    _m1Head  = headW? Mod1H1 headX
    _m2Head_ = headW? Mod2H1 headX

A braced block contains bodies, which are lists of statements, separated by semicolons and possibly preceded by headers, which are separated from the body with a colon. Multiple bodies allow different handling for various cases, which are pattern-matched by headers. For an immediate block there are no inputs, so there can only be one possible case and one body. Functions and modifiers allow any number of "matched" bodies, with headers that have arguments, followed by at most two "main" bodies with either no headers or headers without arguments. If there is one main body, it is ambivalent, but two main bodies refer to the monadic and dyadic cases.

    BODY     = ⋄? ( STMT ⋄ )* EXPR ⋄?
    FCase    = ⋄? FuncHead ":" BODY
    _mCase   = ⋄? _m1Head  ":" BODY
    _cCase_  = ⋄? _m2Head_ ":" BODY
    FMain    = ( ⋄?    F             ":" )? BODY
    _mMain   = ( ⋄? ( _m  | Mod1H1 ) ":" )? BODY
    _cMain_  = ( ⋄? ( _c_ | Mod2H1 ) ":" )? BODY
    brSub    = "{" ( ⋄? s ":" )? BODY "}"
    BrFunc   = "{" (  FCase  ";" )* (  FCase  |  FMain ( ";"  FMain )? ) "}"
    _brMod1  = "{" ( _mCase  ";" )* ( _mCase  | _mMain ( ";" _mMain )? ) "}"
    _brMod2_ = "{" ( _cCase_ ";" )* ( _cCase_ | _cMan_ ( ";" _cMan_ )? ) "}"

Two additional rules apply to blocks, based on the special name associations in the table below. First, each block allows the special names in its column to be used as the given token types within `BODY` terms (not headers). Except for the spaces labelled "None", each column is cumulative and a given entry also includes all the entries above it. Second, for `BrFunc`, `_brMod1`, and `_brMod2_` terms, if no header is given, then at least one `BODY` term in it *must* contain one of the names on, and not above, the corresponding row. Otherwise the syntax would be ambiguous, since for example a simple `"{" BODY "}"` sequence could have any type.

| Term               | `s`    | `F`    | `_m`    | `_c_`    | other
|--------------------|--------|--------|---------|----------|-------
| `brSub`, `PROGRAM` | None   | None   | None    | None     |
| `BrFunc`           | `𝕨𝕩𝕤`  | `𝕎𝕏𝕊`  |         |          | `";"`
| `_brMod1`          | `𝕗𝕣`   | `𝔽`    | `_𝕣`    |          |
| `_brMod2_`         | `𝕘`    | `𝔾`    | None    | `_𝕣_`    |

The rules for special name can be expressed in BNF by making many copies of all expression rules above. For each "level", or row in the table, a new version of every rule should be made that allows that level but not higher ones, and another version should be made that requires exactly that level. The values themselves should be included in `s`, `F`, `_m`, and `_c_` for these copies. Then the "allowed" rules are made simply by replacing the terms they contain (excluding `brSub` and so on) with the same "allowed" versions, and "required" rules are constructed using both "allowed" and "required" rules. For every part of a production rule, an alternative should be created that requires the relevant name in that part while allowing it in the others. For example, `( subject | nothing )? Derv arg` would be transformed to

    arg_req1 = subExpr_req1
             | ( subject_req1 | nothing_req1 ) Derv_allow1 arg_allow1
             | ( subject_allow1 | nothing_allow1 )? Derv_req1 arg_allow1
             | ( subject_allow1 | nothing_allow1 )? Derv_allow1 arg_req1

Quite tedious. The explosion of rules is partly due to the fact that the brace-typing rule falls into a weaker class of grammars than the other rules. Most of BQN is [deterministic context-free](https://en.wikipedia.org/wiki/Deterministic_context-free_grammar) but brace-typing is not, only context-free. Fortunately brace typing does not introduce the parsing difficulties that can be present in a general context-free grammar, and it can easily be performed in linear time: after [scanning](token.md) but before parsing, move through the source code maintaining a stack of the current top-level set of braces. Whenever a colon or special name is encountered, annotate that set of braces to indicate that it is present. When a closing brace is encountered and the top brace is popped off the stack, the type is needed if there was no colon, and can be found based on which names were present. One way to present this information to the parser is to replace the brace tokens with new tokens that indicate the type.
