# The Markdown function is a markdown to html converter for a "good
# enough" subset of Github-flavored markdown, as specified at
# https://github.github.com/gfm/ .
#
# Additionally, it highlights code sections as BQN, and executes
# sections that are doubly indented (eight spaces), placing their
# results below them.

# Not supported:
# - Thematic breaks like *** or ---
# - Setext headings (underlined with ==== or ----)
# - Fenced code blocks (marked off with ``` or ~~~)
# - HTML blocks
# - Link reference definitions (who uses these?)
# - Block quotes (start with >)
# - Task lists

# Here, a markdown file is represented as a list of its lines, which are
# strings (they don't include any line ending character).
# The html file is constructed directly as a string, using Html.

JoinLines ← ∾ ∾⟜lf¨

# Create an html node
Html ← {
  tag ← "<"‿"</" ∾¨ <𝕨∾">"
  ∾ ⟨⊑tag , 𝕩 , ¯1⊑tag⟩
}

Markdown ← {
  # ⌜
  # Utilities

  # Index of first zero, or number of leading 1s
  Lead ← ⊑ ⊐⟜0

  # Shift cells 𝕨 into array 𝕩, maintaining its total length
  Shl ←   ≠∘⊢ ↑ ∾   # From the left
  Shr ← -∘≠∘⊢ ↑ ∾˜  # From the right

  # Find whether 𝕨 was true at the last index where 𝕩 was false, in each
  # position.
  PrecedesGroup ← {
    (0 ∾ 𝕨) ⊏˜ ⌈` (1 + ↕≠𝕩) × ¬𝕩
  }

  # ⌜
  # First we classify each line based on the type of block it can start.
  ClassifyLine ← (0<≠)◶(0‿0)‿{
    FindGroup ← { ⊑ (+`≠¨𝕨) ⍋ 𝕨 ∾⊸⊐ 𝕩 }
    ind ← lineChars FindGroup ⊑𝕩
    getLen ← ind ⊑ lineClas∾⟨0˜⟩
    l ← GetLen 𝕩
    ⟨ind ∧ l>0 ⋄ l⟩
  }

  # Non-empty lines in code blocks have 4 leading spaces
  IsCode ← 4 (≤⟜≠)◶⟨0,∧´' '=↑⟩ ⊢
  ProcCode ← {
    lines ← JoinLines 4 ↓¨ 𝕩
    #lines ↩ ∾⥊¨ ("<>"⊸⊐ ⊑⟜⟨"&lt;","&gt;"⟩⍟(2>⊣)¨ ⊢) lines
    "pre" Html doHighlight◶⟨"code"⊸Html,Highlight⟩ lines
  }

  # Headings start with #, and require 1-6 #s followed by a space.
  # Any trailing #s are ignored.
  LenHeading ← {
    n ← Lead 𝕩='#'
    l ← (0<n) ∧ (6≥n)
    s ← n (<⟜≠)◶⟨1,' '=⊑⟩ 𝕩 # Character after hashes must be a space, if any
    n × l ∧ s
  }
  ProcHeading ← {
    tag ← "h" ∾ 𝕨⊏•d        # h3 for 3 hashes, etc.
    𝕩 ↓˜↩ 𝕨+1
    trsp ← ∧`⌾⌽ 𝕩=' '
    tail ← ∧`⌾⌽ trsp∨𝕩='#'  # Mask of trailing hashes
    f ← tail < 0 Shr tail   # Character before trailing hashes
    𝕩 /˜↩ ¬ f (⊑⟨"\"," ",""⟩⊐<f/𝕩)◶⟨⊣,⊢,⊢,0¨⊢⟩ tail
    𝕩 /˜↩ ¬ (∧` ∨ ∧`⌾⌽) ' '=𝕩
    tag Html ProcInline 𝕩
  }⟜⊑

  # List items start with a bullet (unordered) or number (ordered).
  LenBullet ← 2 × 1 (<⟜≠)◶⟨0,' '=⊑⟩ ⊢
  LenListNum ← {
    n ← Lead 𝕩∊•d
    l ← (1≤n) ∧ (9≥n)
    ' ' = n ↓ 𝕩
    t ← n↓(n+2)↑𝕩
    l ∧ (" " ≡ 1↓t) ∧ ⊑(")." ∊˜ 1↑t)
  }

  # Tables are not yet supported
  IsTable ← 0˜

  # Paragraphs
  ProcParagraph ← {
    Trsp ← { m←∧`⌾⌽𝕩=' ' ⋄ (m¬⊸/𝕩)∾(𝕨<∨´m)/"<br />" }
    𝕩 ↩ (/(≠𝕩)(-∾⊢)1) Trsp¨ 𝕩
    "p" Html ProcInline ¯1 ↓ JoinLines ((Lead ' '⊸=)+"\#"≡2⊸↑)⊸↓¨ 𝕩
  }

  # Inline elements
  ProcInline ← {
    s←"`*"=⌜𝕩
    d←<∘/˘s
    c←⊏s⋄r←¯1⌽l←≠`c⋄cs←l∧c
    code←Highlight⍟doHighlight¨(1-˜(l∧r)×+`cs)⊔𝕩
    inc←¬l∨∨´<˘s
    tags←∾d≠⊸⥊¨⟨"<code>"‿"</code>","<em>"‿"</em>"⟩
    ((/inc)∾(≠¨tags∾code)/(∾d)∾/cs) ⍋⊸⊏ (inc/𝕩)∾∾tags∾code
  }⍟doHighlight

  lineChars‿lineClas‿procFns ← <˘⍉>⟨
    ""    ‿ (!∘0)       ‿ ProcParagraph
    "#"   ‿ LenHeading  ‿ ProcHeading
    " "   ‿ IsCode      ‿ ProcCode
    "-+*" ‿ LenBullet   ‿ (∾⊢) # ProcBullet
    •d    ‿ LenListNum  ‿ (∾⊢) # ProcListNum
    "|"   ‿ IsTable     ‿ (∾⊢) # ProcTable
  ⟩

  # ⌜
  # We will also use the length and number of leading blanks.
  lengths ← ≠¨ 𝕩
  blanks ← (Lead ' '⊸=)¨ 𝕩
  nonEmptyMask ← blanks < lengths
  # Now let's use the line classifications to get the block structure.
  lineType‿lineDat ← <˘⍉ > ClassifyLine¨ blanks ↓¨ 𝕩

  # We will construct a mask of lines that start new blocks, blockStart.

  codeMask ← nonEmptyMask ∧ blanks ≥ 4
  lineType -↩ codeMask ∧ 1 = lineType
  paragraphMask ← nonEmptyMask ∧ 0 = lineType

  # Code blocks consist of indented lines, possibly with blank lines
  # in between. They must be separated from paragraphs by blank lines.
  codeMask ∧↩ ¬ paragraphMask PrecedesGroup codeMask
  codeMask ∨↩ codeMask (⊢ ∧ PrecedesGroup ∧ PrecedesGroup⌾⌽) ¬ nonEmptyMask
  lineType ↩ 2¨⌾(codeMask⊸/) lineType
  paragraphMask ∧↩ ¬ codeMask

  # Lists group together for now
  bulletListMask‿orderedListMask ← <˘ 3‿4 =⌜ lineType

  drop ← blanks × lineType < 2

  # Lines continue blocks if they are part of the same multi-line
  # type as the previous line, and otherwise start new ones.
  blockMasks ← codeMask‿bulletListMask‿orderedListMask‿paragraphMask
  blockStart ← nonEmptyMask ∧ ¬ ∨´ (⊢ ∧ 0⊸Shl)¨ blockMasks

  ProcBlock ← {t‿l G b: f←t⊑procFns ⋄ l F ⊑b }
  blocks ← (1 -˜ (nonEmptyMask ∨ codeMask) × +`blockStart) ⊔ drop ↓¨ 𝕩
  JoinLines (blockStart / lineType≍˘lineDat) <∘ProcBlock˘ blocks
}

# ⌜
# Testing
# Uses the test cases at https://spec.commonmark.org/0.29/spec.json
# since Github doesn't seem to have published theirs
TestSections ← {
  doHighlight ↩ 0
  tests ← ¯2 ↓˘ 8⊸(÷˜⟜≠∾⊣)⊸⥊2↓•LNS •path∾"../spec.json"
  tests ↩ ((⊑2+⊐⟜':')¨∘⊏ ((-','=¯1⊑⊢)↓↓)¨⎉1 ⊢) tests
  testSection ← (1↓¯1↓⊢)¨ 5⊏˘tests
  UnEsc ← {
    esc ← (2 | (1+↕∘≠) (⊣-⌈`∘×) '\'≠⊢) 𝕩
    esc ¬⊸/ (("\"""∾•UCS 9‿10)⊏˜"\""tn"⊐⊢)⌾((¯1⌽esc)⊸/) 𝕩
  }
  RunTest ← {
    in‿exp ← UnEsc∘(1↓¯1↓⊢)¨2↑𝕩
    out ← Markdown (•UCS 10) ((⊢-˜¬×+`)∘=⊔⊢) in
    ⟨exp≡out,in,exp,out,2⊑𝕩⟩
  }

  ignore ← (2 ⊏˘ tests) ∊ ⟨"47","85"⟩
  res ← 1 ↓˘ (¬⊏˘)⊸/ RunTest˘ tests /˜ ignore < testSection ∊ 𝕩
  doHighlight ↩ 1
  res
}

# ⌜
# Syntax highlighting
doHighlight ← 1
Highlight ← {
  idChars ← ⟨
    •d∾"¯.π∞"
    ' '+⌾•UCS•a
    •a
    "_"
  ⟩
  classes‿chars ← <˘ ⍉ 2⊸(÷˜⟜≠∾⊣)⊸⥊⟨
    0             , " "∾•UCS 9‿10
    "Value"       , ¯1⊏˘5‿2⥊"𝕨𝕩𝕗𝕘𝕤"
    "Function"    , "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!"∾¯1⊏˘5‿2⥊"𝕎𝕏𝔽𝔾𝕊"
    "Modifier"    , "˜˘¨⌜⁼´`"
    "Composition" , "∘○⊸⟜⌾⊘◶⎉⚇⍟"
    "Number"      , ∾idChars
    "Gets"        , "←↩→"
    "Paren"       , "()"
    "Bracket"     , "⟨⟩"
    "Brace"       , "{}"
    "Ligature"    , "‿"
    "Nothing"     , "·"
    "Separator"   , "⋄,"
    "Comment"     , "#"
    "String"      , "'"""
  ⟩
  classTag ← ""‿""∾>{⟨"<span class='"∾𝕩∾"'>","</span>"⟩}¨1↓classes
  FindGroup ← { (+`≠¨𝕨) ⍋ (∾𝕨) ⊐ 𝕩 }

  r←𝕩='#'⋄s←/(≠↑2⊸↓)⊸∧𝕩='''⋄d←/𝕩='"'
  g←⍋q←∾⟨  s⋄¯1↓d⋄/r⟩ ⋄q↩g⊏q
  e← g⊏∾⟨2+s⋄ 1↓d⋄(⊢-¯1↓0∾⊢)∘⊏⟜(0∾+`r)⊸//(𝕩=lf)∾1⟩
  Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟{0=⊑⌽𝕩}
  st←¯1↓Se⟜(1↑˜≠)∾⟜≠q⍋e⋄b←st/q∾˘e
  ToI←¯1↓·/⁼(≠𝕩)∾˜⥊
  sc←+´(1‿2-˜≠classes)×(≠`∨⊢)∘ToI∘>¨¯1↓((st/q)⊏r)⊔○(∾⟜2)<˘b
  col←sc⌈14|chars FindGroup 𝕩

  w←(≠↑0∾⊢)⊸<id←col=5
  idc←1+5|1-˜(idChars FindGroup w/𝕩)+'_'=((1↓∾⟜0)⊸<id)/𝕩
  col↩((id/+`w)⊏0∾idc)⌾(id⊸/)col

  col↩(1⌽col)⊣⌾((𝕩=⊑"𝕩")⊸/)col

  bd←(≠↑¯1∾⊢)⊸≠col
  f←0<bd/col
  tags←⥊f/(bd/col)⊏classTag
  pos←⥊f/2↕/bd∾1
  ((↕≠𝕩)∾˜(≠¨tags)/pos) ⍋⊸⊏ 𝕩∾˜∾tags
}

head ← "<head><link href=""style.css"" rel=""stylesheet""/></head>"∾lf
ConvertFile ← head ∾ Markdown∘•LNS
