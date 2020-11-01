# Syntax highlighting utilities for e.bqn; copied from ../md.bqn
# It should be getting this information from the tokenizer instead

Modify ← { ⟨include,add,pos⟩←𝕨
  ((/include)∾(≠¨add)/pos) ⍋⊸⊏ (include/𝕩)∾∾add
}

# Return BQN highlights for an string 𝕩, as an ⟨add,pos⟩ list for Modify
# (include will be all 1s).
lf ← @+10
FindGroup ← {
  i ← (∾𝕨) ⊐ 𝕩  # Index in all cells of 𝕨
  e ← +`≠¨𝕨     # Index past the end of each group of 𝕨
  e ⍋ i         # How many end-indices does each element pass?
}
Trace ← {
  # 𝕨 is a list with one index for each possible start, giving a later
  # start that is known to be enabled if that one is.
  # 𝕩 is a mask of all starts known to be enabled.
  # A "stop" position that follows all expressions tells when to stop.
  # At each step the distance from a start to its successor in 𝕨 is
  # doubled, so the maximum number of steps is about 2⋆⁼≠𝕩.
  En ← {
    𝕩 ↩ 1¨⌾((𝕩/𝕨)⊸⊏)𝕩  # Starts following from an enabled one are enabled
    𝕨 ↩ ⊏˜ 𝕨           # Double the number of steps in 𝕨
    𝕨 En 𝕩             # Repeat
  }⍟{0=¯1⊑𝕩}           #        until the stop is enabled

  g ← ⍋𝕨               # Order expressions by starting index
  start ← g⊏𝕨
  end   ← g⊏𝕩
  next ← start ⍋ end   # An expression's successor starts after it ends
  next ∾↩ ≠next        # The stop node is its own successor
  enabled ← ¯1 ↓ next En (≠next)↑1  # Search and remove the stop
  enabled / start≍˘end # List of enabled starts and ends
}
idChars ← ⟨
  ('0'+↕10)∾"¯.π∞"
  "𝕣"∾˜'a'+↕26
  'A'+↕26
  "_"
⟩
GetHighlights ← {
  # Characters used by BQN, and the HTML class they are associated with.
  classes‿chars ← <˘ ⍉ ∘‿2⥊⟨
    0             , " "∾@+9‿10  # Should never be highlighted
    "Value"       , ¯1⊏˘5‿2⥊"𝕨𝕩𝕗𝕘𝕤"# Hack around UTF-16
    "Function"    , "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!"∾¯1⊏˘5‿2⥊"𝕎𝕏𝔽𝔾𝕊"
    "Modifier"    , "˙˜˘¨⌜⁼´˝`"
    "Modifier2"   , "∘○⊸⟜⌾⊘◶⎉⚇⍟⎊"
    "Number"      , ∾idChars       # Will be classified among ↑↑ later
    "Gets"        , "←⇐↩→"
    "Paren"       , "()"
    "Bracket"     , "⟨⟩"
    "Brace"       , "{}"
    "Ligature"    , "‿"
    "Nothing"     , "·"
    "Separator"   , "⋄,"
    "String"      , "'""@"
    "Comment"     , "#"
  ⟩
  # Turn non-whitespace classes into ⟨open,close⟩ html tags.
  classTag ← ""‿"" ∾ > {⟨"<span class='"∾𝕩∾"'>","</span>"⟩}¨ 1↓classes

  # Find each character's group, sending unknowns to 1.
  col ← (≠chars) (⊢--⟜1×=) chars FindGroup 𝕩

  # Locate comments and strings.
  c ← 𝕩='#'
  le← /(𝕩=lf)∾1
  # Line endings (le) end every comment (/c) on the line, so take a copy
  # for each # before that line but not the previous.
  ce← le /˜ -⟜» c/⊸⍋le
  # A single quote can only be used if there's another two places down.
  s ← /0‿0⊸«⊸∧𝕩='''
  d ← /𝕩='"'
  css ← ⟨ s   ⋄ ¯1↓d ⋄ /c ⟩ # Comment or string start
  cse ← ⟨ 2+s ⋄  1↓d ⋄ ce ⟩ # Corresponding end indices
  # Now b is a table of (start,end) pairs
  b ← css Trace○∾ cse
  # Given a list of pairs, get a mask indicating included regions
  ToMask ← (≠`∨⊢) (≠𝕩)↑/⁼∘∾
  # Split rows and group into text‿comments
  tc ← ((⊏˘b)⊏c) 2{𝕗↑⊔○(∾⟜𝕗)} <˘b
  # Color with "String" and "Comment"
  col ⌈↩ +´ (2‿1-˜≠classes) × ToMask¨ tc

  # UTF-16 hack: first half of a special name needs to match the second
  col↩ («col) ⊣⌾((𝕩=⊑"𝕩")⊸/) col

  # Color numeric literals and identifiers
  id ← col=5                 # ←→ 𝕩∊idChars
  w  ← »⊸< id                # Word (identifier or number) beginning mask
  wt ← idChars FindGroup w/𝕩 # Type based on first character
  wt+↩ '_' = («⊸<id)/𝕩       # Modifier1 to Modifier2 based on word end
  wt+↩ 5×0=wt                # Shift 0 to Number
  wi ← 1-˜+`id/w             # Index of word containing each of /id
  col↩(wi⊏wt)⌾(id⊸/) col

  # Tags are placed at boundaries between different colors
  boundary ← ¯1⊸»⊸≠ col
  bcol ← boundary / col
  # Windows gives us rows of start,end where the end position of one
  # color is the start of the next
  # Subtract one to place before the starting character
  pos ← 2 ↕ 1-˜/boundary∾1
  # Remove class 0 regions, as these don't use tags
  (⥊ (0<bcol)⊸/)¨ ⟨bcol⊏classTag, pos⟩
}
