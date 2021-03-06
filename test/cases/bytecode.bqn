# Tests of bytecode operations.
# These use no primitives, so that compiled code can be run directly in
# a correct VM even if it has no runtime.
# Compile with a command such as $ src/cjs.bqn "a←2⋄b←3⋄a"

# Tests are meant to be run in order; comments indicate new instructions
# introduced by each.

5  % 5                     #  0 PUSH, 25 RETN
3  % 4⋄3                   # 14 POPS
5  % a←5                   # 22 LOCM, 11 SETN
4  % a←5⋄a↩4               # 12 SETU
2  % a←2⋄b←3⋄a             # 21 LOCO
1  % a←1⋄A 4               # 16 FN1O
2  % a←2⋄3 A 4             # 17 FN2O
6  % {𝕩}6                  # 15 DFND
3  % A←{𝕨}⋄3 A 4           #    dyadic block function
7  % a‿b←7‿2⋄a             #  3 ARRO,  4 ARRM
4  % 4{𝔽}                  #  7 OP1D
6  % 4{𝔽⋄𝕩}6               #    deferred modifier
1  % 3{𝔾}{𝕩} 1             #  8 OP2D
2  % (2{𝔽}{𝕩})3            #  9 TR2D
3  % 3({a‿b←𝕩⋄a}{𝕨‿𝕩})4    #    dyadic 2-train
4  % 4({𝕨‿𝕩}{𝕩}{𝕨})5       # 19 TR3O
2  % a‿b←(2{𝕨‿𝕩}{𝕩})5⋄a    #    monadic, data in left branch
2  % ({a↩2⋄𝕩}{𝕩⋄a}{a↩3⋄𝕩})a←4 # ordering
8  % a←3⋄a{𝕩}↩8⋄a          # 13 SETM
5  % a←4⋄a{𝕨⋄5}↩6          #    returns new value
4  % a‿b←2‿1⋄a‿b{𝕩‿𝕨}↩4⋄a  #    lists

# Further tests for lexical scoping
1  % a←1⋄{a←2}⋄a
2  % a←1⋄{a↩2}⋄a
6  % f‿g←{a←2⋄{a↩𝕩}‿{𝕩⋄a}}⋄F 6⋄G 0
5  % L←{𝕩{𝕏𝕗}}⋄{𝕏𝕤}L L L 5
3  % _l←{𝕩{𝕏𝕗} 𝔽}⋄{𝕏𝕤} {𝕩}_l 3 _l 5
1  % 1{𝕨}{𝔽{𝕩𝔽𝕨}𝔾𝔽}{𝕩}0    # 0≠1 via Church booleans
2  % 0‿(0‿{𝕩}){{a‿b←𝕩⋄t←𝕤⋄{𝕤⋄T↩{𝕤⋄{a‿b←𝕩⋄a}}}{B𝕗}0⋄(T b){a‿b←𝕩⋄𝔽b}}𝕗} 0‿(1‿(2‿(3‿(4‿{𝕩}))))
