Compile ← (↕62)⊸(•Import "../src/c.bqn")
DrawEval ← Compile⊸(⍎ ∾∾⟜(@+10)¨ •LNS "../src/e.bqn")
