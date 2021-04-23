Compile ← (↕62)⊸((•Import"../src/glyphs.bqn") •Import "../src/c.bqn")
DrawEval ← Compile⊸(•Eval •FChars "../src/e.bqn")
