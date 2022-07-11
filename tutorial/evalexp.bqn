drawEval ← {
  compile ← (•Import"../src/glyphs.bqn") •Import "../src/c.bqn"
  explain ← Eval •FChars "../src/e.bqn"
  # Left argument is list of pre-defined names
  {(𝕨⊢⊘(!¨˙⊸⋈⊸(∾˜))⟨↕62⟩) Compile 𝕩} Explain ⊢
}
