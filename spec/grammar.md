*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/grammar.html).*

# Specification: BQN grammar

BQN's grammar is given below. Terms are defined in a [BNF](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) variant, with [tokens](token.md) for terminals. However, handling special names properly is possible but difficult in BNF, so they are explained in text along with the block grammar.

The symbols `s`, `F`, `_m`, and `_c_` are identifier tokens with subject, function, 1-modifier, and 2-modifier roles respectively. Similarly, `sl`, `Fl`, `_ml`, and `_cl_` refer to literals and primitives of those roles. While names in the BNF here follow the identifier naming scheme, this is informative only: syntactic roles are no longer used after parsing and cannot be inspected in a running program.

A program is a list of statements. Almost all statements are expressions. Namespace export statements, and valueless results stemming from `·`, or `𝕨` in a monadic block function, can be used as statements but not expressions.

    PROGRAM  = ⋄? ( STMT ⋄ )* STMT ⋄?
    STMT     = EXPR | noExpr | EXPORT
    ⋄        = ( "⋄" | "," | LF | CR )+
    EXPR     = subExpr | FuncExpr | _m1Expr | _m2Expr_
    EXPORT   = LHS_ELT? "⇐"

Here we define the "atomic" forms of functions and modifiers, which are either single tokens or enclosed in paired symbols. Stranded lists with `‿`, which binds more tightly than any form of execution, are also included.

    ANY      = atom | Func | _mod1 | _mod2_
    _mod2_   = ( atom "." )? _c_ | _cl_ | "(" _m2Expr_ ")" | _blMod2_
    _mod1    = ( atom "." )? _m  | _ml  | "(" _m1Expr  ")" | _blMod1
    Func     = ( atom "." )?  F  |  Fl  | "(" FuncExpr ")" |  BlFunc
    atom     = ( atom "." )?  s  |  sl  | "(" subExpr  ")" |  blSub | array
    nothing  =                     "·"  | "(" noExpr   ")"
    array    = "⟨" ⋄? ( ( EXPR ⋄ )* EXPR ⋄? )? "⟩"
             | "[" ⋄?   ( EXPR ⋄ )* EXPR ⋄?    "]"
    subject  = atom | ANY ( "‿" ANY )+

Starting at the highest-order objects, modifiers have simple syntax. In most cases the syntax for `←` and `↩` is the same, but only `↩` can be used for modified assignment. The export arrow `⇐` can be used in the same ways as `←`, but it can also be used at the beginning of a header to force a namespace result, or with no expression on the right in an `EXPORT` statement.

    ASGN     = "←" | "⇐" | "↩"
    _m2Expr_ = _mod2_
             | _c_ ASGN _m2Expr_
    _m1Expr  = _mod1
             | _m  ASGN _m1Expr

Functions can be formed by applying modifiers, or with trains. Modifiers are left-associative, so that the left operand (`Operand`) can include modifier applications but the right operand (`subject | Func`) cannot. Trains are right-associative, but bind less tightly than modifiers. Assignment is not allowed in the top level of a train: it must be parenthesized.

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

Subject expressions consist mainly of function application. We also define nothing-statements, which have very similar syntax to subject expressions but do not permit assignment. They can be used as an `STMT` or in place of a left argument.

    arg      = subject
             | ( subject | nothing )? Derv subExpr
    noExpr   = nothing
             | ( subject | nothing )? Derv noExpr
    subExpr  = arg
             | lhs ASGN subExpr
             | lhs Derv "↩" subExpr?      # Modified assignment

The target of subject assignment can be compound to allow for destructuring. List and namespace assignment share the nodes `lhsList` and `lhsStr` and cannot be completely distinguished until execution. The term `sl` in `LHS_SUB` is used for header inputs below: as an additional rule, it cannot be used in the `lhs` term of a `subExpr` node.

    NAME     = s | F | _m | _c_
    LHS_SUB  = "·" | lhsList | lhsArray | sl
    LHS_ANY  = NAME | LHS_SUB | "(" LHS_ELT ")"
    LHS_ATOM = LHS_ANY | "(" lhsStr ")"
    LHS_ELT  = LHS_ANY | lhsStr
    LHS_ENTRY= LHS_ELT | lhs "⇐" NAME
    lhsStr   = LHS_ATOM ( "‿" LHS_ATOM )+
    lhsList  = "⟨" ⋄? ( ( LHS_ENTRY ⋄ )* LHS_ENTRY ⋄? )? "⟩"
    lhsArray = "[" ⋄? ( ( LHS_ELT   ⋄ )* LHS_ELT   ⋄? )? "]"
    lhsComp  = LHS_SUB | lhsStr | "(" lhs ")"
    lhs      = s | lhsComp

A header looks like a name for the thing being headed, or its application to inputs (possibly twice in the case of modifiers). As with assignment, it is restricted to a simple form with no extra parentheses. The full list syntax is allowed for arguments. A plain name is called a label and can be used for a block with or without arguments. First we define headers `IMM_HEAD` that include no arguments.

    headW    = lhs | "𝕨"
    headX    = lhs | "𝕩"
    HeadF    = lhs | F | "𝕗" | "𝔽"
    HeadG    = lhs | F | "𝕘" | "𝔾"
    FuncLab  = F | "𝕊"
    Mod1Lab  = _m  | "_𝕣"
    Mod2Lab  = _c_ | "_𝕣_"
    FuncName = FuncLab
    Mod1Name = HeadF Mod1Lab
    Mod2Name = HeadF Mod2Lab HeadG
    LABEL    =         FuncLab  | Mod1Lab  | Mod2Lab
    IMM_HEAD = LABEL | FuncName | Mod1Name | Mod2Name

There are some extra possibilities for a header that specifies arguments. As a special rule, a monadic function header specifically can omit the function when the argument is not just a name (as this would conflict with a subject label). Additionally, an inference header doesn't affect evaluation of the function, but describes how an inferred property ([Undo](inferred.md#undo)) should be computed. Here `"˜"` and `"⁼"` are both specific instances of the `_ml` token.

    ARG_HEAD = LABEL
             | headW? IMM_HEAD      "⁼"? headX
             | headW  IMM_HEAD "˜"  "⁼"  headX
             |        FuncName "˜"? "⁼"
             | lhsComp

A block is written with braces. It contains bodies, which are lists of statements, separated by semicolons. Multiple bodies can handle different cases, as determined by headers and predicates. A header is written before its body with a separating colon, and an expression other than the last in a body can be made into a predicate by following it with the separator-like `?`.

An `I_CASE`, `A_CASE`, or `S_CASE` is called a *general case* or *general body* if it has no header or predicate, or, more formally, it doesn't directly include a `":"` token and its `BODY` node doesn't use the `EXPR ⋄? "?" ⋄?` case. A program must satisfy some additional rules regarding general cases, but these are not needed to resolve the grammar and shouldn't strictly be considered part of it. First, no general body can appear before a body that isn't general in a block. Second, a `IMM_BLK` or `blSub` can directly contain at most one general body and an `ARG_BLK` at most two (these are monadic and dyadic cases).

    BODY     = ⋄? ( STMT ⋄ | EXPR ⋄? "?" ⋄? )* STMT ⋄?
    I_CASE   = ( ⋄? IMM_HEAD ⋄? ":" )? BODY
    A_CASE   = ( ⋄? ARG_HEAD ⋄? ":" )? BODY
    S_CASE   = ( ⋄? s        ⋄? ":" )? BODY
    IMM_BLK  = "{" ( I_CASE ";" )* I_CASE "}"
    ARG_BLK  = "{" ( A_CASE ";" )* A_CASE "}"
    blSub    = "{" ( S_CASE ";" )* S_CASE "}"
    BlFunc   =           ARG_BLK
    _blMod1  = IMM_BLK | ARG_BLK
    _blMod2_ = IMM_BLK | ARG_BLK

Three additional rules apply to blocks, allowing the ambiguous grammar above to be disambiguated. They are shown in the table below. First, each block type allows the special names in its row to be used as the given token types within `BODY` terms (not headers). Except for the spaces labelled "None", each of these four columns is cumulative, so that a given entry also includes all the entries above it. Second, a block can't contain one of the tokens from the "label" column of a different row. Third, each `BlFunc`, `_blMod1`, and `_blMod2_` term *must* contain one of the names on, and not above, the corresponding row (including the "label" column).

| Term               | `s`    | `F`    | `_m`    | `_c_`    | label
|--------------------|--------|--------|---------|----------|-------
| `blSub`, `PROGRAM` | None   | None   | None    | None     | None
| `BlFunc`           | `𝕨𝕩𝕤`  | `𝕎𝕏𝕊`  |         |          | `FuncLab`
| `_blMod1`          | `𝕗𝕣`   | `𝔽`    | `_𝕣`    |          | `Mod1Lab`
| `_blMod2_`         | `𝕘`    | `𝔾`    | None    | `_𝕣_`    | `Mod2Lab`

The rules for special names can be expressed in BNF by making many copies of all expression rules above. For each "level", or row in the table, a new version of every rule should be made that allows that level but not higher ones, and another version should be made that requires exactly that level. The values themselves should be included in `s`, `F`, `_m`, and `_c_` for these copies. Then the "allowed" rules are made simply by replacing the terms they contain (excluding `blSub` and so on) with the same "allowed" versions, and "required" rules are constructed using both "allowed" and "required" rules. For every part of a production rule, an alternative should be created that requires the relevant name in that part while allowing it in the others. For example, the definition of `arg` as `subject | ( subject | nothing )? Derv subExpr` would be transformed to

    arg_req1 = subject_req1
             | ( subject_req1 | nothing_req1 ) Derv_allow1 subExpr_allow1
             | ( subject_allow1 | nothing_allow1 )? Derv_req1 subExpr_allow1
             | ( subject_allow1 | nothing_allow1 )? Derv_allow1 subExpr_req1

Quite tedious. The explosion of rules is partly due to the fact that the block-typing rule falls into a weaker class of grammars than the other rules. Most of BQN is [deterministic context-free](https://en.wikipedia.org/wiki/Deterministic_context-free_grammar) but block-typing is not, only context-free. Fortunately block typing does not introduce the parsing difficulties that can be present in a general context-free grammar, and it can easily be performed in linear time: after [scanning](token.md) but before parsing, move through the source code maintaining a stack of the current top-level set of braces. Whenever a colon or special name is encountered, annotate that set of braces to indicate that it is present. When a closing brace is encountered and the top brace is popped off the stack, the type is needed if there was no colon, and can be found based on which names were present. One way to present this information to the parser is to replace the brace tokens with new tokens that indicate the type.
