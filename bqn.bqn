#! /usr/bin/env bqn

# A BQN interpreter implemented in BQN
# ./bqn.bqn ( files | -e source )

# Unlike a compiler, a self-hosted interpreter is kind of silly. This
# script is mostly just evidence that the BQN components found in this
# repository do add up to a full implementation. The same idea more
# usefully applied in test/unit.bqn, which can build an interpreter
# using some or all of them in order to test it.

# BQN's compiler is truly self-hosting, but targets a BQN-specific
# object code rather than machine code (as does Java). The virtual
# machine interprets this object code. Finally, the compiler takes
# primitive values as input in order to include them in the object code.
# As all primitives are available in BQN we could just use these, but
# for more self-hostingness the BQN-based runtime is used instead, so
# that the interpreter relies on a smaller set of core functions.

#⌜
# Assemble the components
gl ← •Import "src/glyphs.bqn"
compile ← gl •Import "src/c.bqn"  # Compiler: source → object code
vm      ←    •Import "vm.bqn"     # VM: interprets object code
runtime ←    •Import "rt.bqn"     # Runtime: primitives available to VM

# Define system values later, to include BQN
BQN ← ⟨runtime, {System 𝕩}⟩ ⊸ (VM Compile)

#⌜
# System values
IsPrim ← ∊⟜runtime⌾<
Glyph ← runtime⊸⊐⌾<⊑(∾gl)˙
Decompose ← IsPrim◶⟨•Decompose,0⊸≍⟩

# Formatter
tn ← "*"⊸(∾∾⊣)¨"array"‿"function"‿"1-modifier"‿"2-modifier"‿"namespace"
Fmt‿Repr ← (•Import "src/f.bqn"){𝔽} ⟨
  •Type
  Decompose
  IsPrim◶⟨tn⊑˜•Type-2˙, Glyph⟩ # Format operation/namespace
  •Repr                        # Format number
⟩
Show ← •Out∘Fmt⊸⊢⊢

# Lookup table
FindSys ← {
  i ← 𝕨⊐𝕩
  { ! ∾⟨"Unknown system value",(1≠≠𝕩)/"s",":"⟩∾" •"⊸∾¨𝕩 }∘/⟜𝕩⍟(∨´) i=≠𝕨
  i
}
system ← {𝕨⊸FindSys⊏𝕩˙}´⟨
  "bqn"‿"type"‿"glyph"‿"decompose"‿"repr"‿"fmt"‿"out"‿"show"
   BQN ‿•Type ‿ Glyph ‿ Decompose ‿ Repr ‿ Fmt ‿•Out ‿ Show
⟩

#⌜
# Evaluate
{
  0 < ≠•args ?
  t ← ⊑ "-e"‿"-p" ⊐ ⊏•args
  Show⍟(t=1)∘BQN¨ (t<2)◶⟨•file.Chars¨, 1⊸↓⟩ •args
;@}

BQN  # Return the evaluator so it can be •Include d from BQN
