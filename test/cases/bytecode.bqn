# Tests of bytecode operations. Compile with cjs.bqn.

# Tests are meant to be run in order; comments indicate new instructions
# introduced by each.

5  % 5            #  0 PUSH, 25 RETN
3  % 4⋄3          # 14 POPS
5  % a←5          # 22 LOCM, 11 SETN
2  % a←2⋄b←3⋄a    # 21 LOCO
1  % a←1⋄A 4      # 16 FN1O
2  % a←2⋄3 A 4    # 17 FN2O
6  % {𝕩}6         # 15 DFND
3  % A←{𝕨}⋄3 A 4  
7  % a‿b←7‿2⋄a    #  3 ARRO,  4 ARRM
4  % 4{𝔽}6        #  7 OP1D
