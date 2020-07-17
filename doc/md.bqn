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

################################
# Utilities

# Shift cells 𝕨 into array 𝕩, maintaining its total length
Shl ←   ≠∘⊢ ↑ ∾   # From the left
Shr ← -∘≠∘⊢ ↑ ∾˜  # From the right

# 𝕨 is a list of lists. Find the first of these lists each cell of 𝕩
# belongs to.
FindGroup ← {
  i ← (∾𝕨) ⊐ 𝕩  # Index in all cells of 𝕨
  e ← +`≠¨𝕨     # Index past the end of each group of 𝕨
  e ⍋ i         # How many end-indices does each element pass?
}

# 𝕨 is a list of possible expression start indices in any order and 𝕩 is
# the corresponding endpoints. The expressions are mutually exclusive
# and do not nest, and are enabled in index order. Return a shape ·‿2
# array where the rows give the start and end of each enabled expression
# in index order.
Trace ← {
  Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟{0=⊑⌽𝕩}
  g←⍋𝕨 ⋄ s←g⊏𝕨 ⋄ e←g⊏𝕩
  st←¯1↓Se⟜(1↑˜≠)∾⟜≠s⍋e
  st/s≍˘e
}

# Count the number of consecutive true values up to the current element.
# To do this, subtract the index of the last false character from the
# current index.
CountRuns ← { (1+↕≠𝕩) (⊣ - ⌈`∘×) ¬𝕩 }

# 𝕩 is a string; return a mask of the characters that are escaped, that
# is, preceded by an odd number of backslashes (since a backslash can
# escape another backslash).
IsEscaped ← {
  0 Shl 2 | CountRuns 𝕩 = '\'
}

# Join lines with newline characters. Include the trailing newline.
JoinLines ← ∾ ∾⟜lf¨

# Create an html node from a tag name and interior text
Html ← {
  ∾ ⟨"<",𝕨,">" , 𝕩 , "</",(⊑⊐⟜" ")⊸↑𝕨,">"⟩
}

# Character entity escaping
# In order to use this with other modifications such as highlighting,
# CharEntities returns a mask of characters to be escaped, and their
# corresponding escapes.
CharEntities ← {1¨⊸𝕊𝕩;  # 𝕨 gives characters to potentially escape
  ce ← (1-˜¬×+`)∘=⟜⊑⊸⊔ " ""quot &amp <lt >gt"
  chars ← ⊑¨ce ⋄ entities ← ("&"∾∾⟜";")¨ 1↓¨ce
  ind ← chars ⊐ 𝕩
  useEntity ← 𝕨 ∧ ind < ≠chars
  ⟨useEntity , entities ⊏˜ useEntity / ind⟩
}
HtmlEsc ← {
  u‿e ← CharEntities 𝕩
  i ← / ¬u
  (⍋i∾(≠¨e)//u) ⊏ (i⊏𝕩)∾∾e
}

################################
Markdown ← {𝕊𝕩:1𝕊𝕩; extensions𝕊𝕩:
  ######
  # Utilities

  # Index of first zero, or number of leading 1s
  Lead ← ⊑ ⊐⟜0

  # Find whether 𝕨 was true at the last index where 𝕩 was true, in each
  # position.
  PrecedesGroup ← {
    # We prepend a 0 to 𝕨, so that 0 is the "before start" index, with a
    # false value, and normal indices are increased by 1.
    𝕨 ∾˜↩ 0
    inds ← 1 + ↕≠𝕩
    # Zero out indices where x was false, and find the greatest index so
    # far at each position.
    last ← ⌈` inds × ¬𝕩
    last ⊏ 𝕨
  }

  # Remove leading and trailing spaces
  Trim ← { 𝕩 /˜ ¬ (∧` ∨ ∧`⌾⌽) ' '=𝕩 }

  ######
  # First we classify each line based on the type of block it can start.
  ClassifyLine ← (0<≠)◶(0‿0)‿{
    ind ← ⊑ lineChars FindGroup ⊏𝕩
    getLen ← ind ⊑ lineClas∾⟨0˜⟩
    l ← GetLen 𝕩
    ⟨ind ∧ l>0 ⋄ l⟩
  }

  # Non-empty lines in code blocks have 4 leading spaces
  IsCode ← 4 (≤⟜≠)◶⟨0,∧´' '=↑⟩ ⊢
  ProcCode ← {
    lines ← JoinLines 4 ↓¨ 𝕩
    "pre" Html extensions◶⟨"code"Html HtmlEsc,Highlight⟩ lines
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
    # Add an id: lowercase the header, replacing non-•a with hyphens
    Slugify ← {
      ch ← •UCS "-Aa"
      bounds ← ⥊ (1↓ch) +⌜ 0‿26  # Of the upper and lowercase alphabet
      (bounds⊸⍋ {(⊑ch)¨⌾((¬2|𝕨)⊸/)𝕩+32×1=𝕨} ⊢)⌾•UCS 𝕩
    }
    extensions { tag ∾↩ " id="∾""""(∾∾⊣) Slugify 𝕩 }⍟⊣ 𝕩
    tag Html ProcInline Trim 𝕩
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

  # Any line that starts with a | is a table, at least in my lazy version
  IsTable ← 1˜
  ProcTable ← {
    rows ← (Trim¨ ((1-˜¬×+`)'|'⊸=)⊸⊔)¨ 𝕩
    inc ← ¬ rule ← ∧´∘∾¨'-'=rows
    rows ↩ ProcInline¨¨⌾(inc⊸/) rows
    rowType ← inc / +` rule  # Head or body
    DoRow ← { lf ∾ JoinLines 𝕨⊸Html¨ 𝕩 }
    rows ↩ (rowType ⊏ "th"‿"td") DoRow¨ inc/rows
    rowGroups ← ¯1 ↓ rowType ⊔○(∾⟜2) "tr"⊸Html¨ rows
    sections ← "thead"‿"tbody" Html⟜(lf ∾ JoinLines)¨ rowGroups
    "table" Html lf ∾ JoinLines (0 < ≠¨rowGroups) / sections
  }

  # Paragraphs
  ProcParagraph ← {
    "p" Html ProcInline ¯1 ↓ JoinLines Trim⌾(¯1⊸⊑) (Lead ' '⊸=)⊸↓¨ 𝕩
  }

  # HTML blocks
  # Lazy rule: if it starts with < and contains >, it's probably HTML
  IsHtmlBlock ← ⊑ ">"⊸∊
  ProcHtmlBlock ← JoinLines∘⊢

  lineChars‿lineClas‿procFns ← <˘⍉>⟨
    ""    ‿ (!∘0)       ‿ ProcParagraph
    "#"   ‿ LenHeading  ‿ ProcHeading
    " "   ‿ IsCode      ‿ ProcCode
  # "-+*" ‿ LenBullet   ‿ ProcBullet
  # •d    ‿ LenListNum  ‿ ProcListNum
    "|"   ‿ IsTable     ‿ ProcTable
    "<"   ‿ IsHtmlBlock ‿ ProcHtmlBlock
  ⟩

  ######
  # Inline elements
  ProcInline ← {
    I2M ← (≠𝕩) ↑ /⁼  # Index to mask
    punc ← 𝕩 ∊ "!""#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
    actual ← ¬ punc ∧ IsEscaped 𝕩  # backtick or *actual* backtick?

    # Code spans
    ProcCodeSpan ← {
      𝕩 ↩ ' '¨⌾((𝕩=lf)⊸/) 𝕩
      𝕩 ↩ (1↓¯1↓⊢)⍟((⊢<○(∧´)⊑∾⊑∘⌽) ' '⊸=) 𝕩
      "code" Html extensions◶HtmlEsc‿Highlight 𝕩
    }
    tick ← 𝕩 = '`'
    tend ← / (⊢ > 0⊸Shr) tick
    tcount ← CountRuns tick
    # 𝕨 are tick lengths and 𝕩 are positions, both sorted by length
    MatchTicks ← {
      # Tick runs other than the last of each length
      notLast ← (⊢=0⊸Shr) 𝕨
      # Ticks preceded by backslashes can't start code blocks, but can
      # end them. This approach is wrong for multiple ticks with a
      # leading backslash in front, which are excluded but should just
      # be treated as one shorter when leading.
      filter ← notLast / (𝕩¬𝕨) ⊏ actual
      # For leading ticks, filter by not-last; for trailing ones, rotate
      # by ¯1 to filter by not-first.
      (filter / ⌽⟜notLast / 𝕩˜)¨ 0‿¯1
    }
    tlen ← tend ⊏ tcount
    c ← Trace´ tlen MatchTicks○((⍋tlen)⊸⊏) tend
    cl ← (⊏˘c) ⊏ tcount
    ctInds ← ⥊˘ 1 + c -⌜˘ cl×⌜1‿0
    include ← ¬ ≠` I2M ⥊ 0‿3⊸⊏˘ ctInds
    codeStart ← I2M 1 ⊏˘ ctInds
    codeGroup ← 1 -˜ codeStart (⊣×>)○(+`) I2M 2 ⊏˘ ctInds
    code ← ProcCodeSpan¨ codeGroup ⊔ 𝕩

    # Links
    ReplaceMDSub ← { ¯2 (↓∾"html"˜)⍟(("md"≡↑)∧'/'∧´∘≠⊢) 𝕩 }
    ReplaceMD ← { ReplaceMDSub⌾((⊑𝕩⊐"#")⊸↑) 𝕩 }
    ProcLink ← { ∾⟨"<a href=""",(ReplaceMD 𝕩),""">",𝕨,"</a>"⟩ }
    brak ← /∘(actual ∧ include ∧ 𝕩⊸=)¨ "]()["
    link ← (∊/⊣)´ 0‿¯1 + 2 ↑ brak
    chains ← (⍋˜ ⊏ ⊢∾(≠𝕩)˜)` ¯1 ⌽ (<link) ∾ 2 ↓ brak
    chains ↩ > (∧´ (∊ ∧ <⟜(≠𝕩))¨ 1 ↓ chains)⊸/¨ chains
    linkStart ← I2M 0 ⊏ chains
    lInds ← 1‿0‿2‿0⊸+˘ (⥊2⊸↕)˘ ⍉ chains
    include ∧↩ ¬ ≠` I2M ⥊ (¯1‿1+0‿3⊸⊏)˘ lInds
    linkGroup ← 1 -˜ (1‿0⥊˜≢)⊸(/ (⊣×>)○(+`I2M) ¬⊸/) ⥊lInds
    links ← <∘ProcLink´˘ 2⊸(÷˜⟜≠∾⊣)⊸⥊ linkGroup ⊔ 𝕩

    # Emphasis (still rudimentary)
    eMasks ← (actual ∧ include ∧ 𝕩⊸=)¨ "*_"
    eInds ← (⊢-2|⊢)∘≠⊸↑∘/¨ eMasks
    include ∧↩ ¬∨´eMasks
    eTags ← ∾ eInds ≠⊸⥊¨ <"<em>"‿"</em>"

    # Remove backslashes used for escaping
    include ∧↩ 1 ⌽ actual

    em‿ent ← include CharEntities 𝕩
    include ∧↩ ¬ em

    new ← ∾⟨eTags,code,links,ent⟩           # Text to be added
    inds← ∾eInds∾/¨codeStart‿linkStart‿em   # Where to add it
    ((/include)∾(≠¨new)/inds) ⍋⊸⊏ (include/𝕩)∾∾new
  }

  ######
  # Create the block structure using line classifications.
  lengths ← ≠¨ 𝕩                   # Length of each line
  blanks ← (Lead ' '⊸=)¨ 𝕩         # Number of leading blanks
  nonEmptyMask ← blanks < lengths  # Empty ←→ all leading blanks

  # Get line classifications: type of line, and data to be passed into
  # the line processor. Note that leading blanks aren't passed in.
  lineType‿lineDat ← <˘⍉ > ClassifyLine¨ blanks ↓¨ 𝕩
  # Empty lines have type ¯1.
  lineType ↩ ¯1¨⌾((¬nonEmptyMask)⊸/) lineType

  # Lines that could be included in code blocks (will be refined)
  codeMask ← nonEmptyMask ∧ blanks ≥ 4
  paragraphMask ← 0 = lineType
  # A header can't have 4 spaces of indentation. If it doesn't become
  # part of a code block, it will be included in a paragraph.
  lineType -↩ codeMask ∧ 1 = lineType

  # Code blocks consist of indented lines, possibly with blank lines
  # in between. They must be separated from paragraphs by blank lines.
  codeMask ∧↩ ¬ paragraphMask PrecedesGroup codeMask
  codeMask ∨↩ codeMask (⊢ ∧ PrecedesGroup ∧ PrecedesGroup⌾⌽) lineType < 0
  lineType ↩ 2¨⌾(codeMask⊸/) lineType

  # Lines continue blocks if they are part of the same multi-line
  # type as the previous line, and otherwise start new ones.
  # Headers (type 1) always start new blocks.
  blockStart ← nonEmptyMask ∧ (1 = lineType) ∨ ¯1⊸Shl⊸≠ lineType
  # Headers and paragraphs ignore leading blanks.
  drop ← blanks × lineType < 2
  # Group blocks based on blockStart, with type ¯1 lines excluded.
  blocks ← (1 -˜ (lineType ≥ 0) × +`blockStart) ⊔ drop ↓¨ 𝕩

  # To process a block, pick the appropriate function from procFns.
  ProcBlock ← {t‿l G b: f←t⊑procFns ⋄ l F ⊑b }
  JoinLines (blockStart / lineType≍˘lineDat) <∘ProcBlock˘ blocks
}

################################
# Testing
# Uses the test cases at https://spec.commonmark.org/0.29/spec.json
# since Github doesn't seem to have published theirs
TestSections ← {
  tests ← ¯2 ↓˘ 8⊸(÷˜⟜≠∾⊣)⊸⥊2↓•LNS •path∾"spec.json"
  tests ↩ ((⊑2+⊐⟜':')¨∘⊏ ((-','=¯1⊑⊢)↓↓)¨⎉1 ⊢) tests
  testSection ← (1↓¯1↓⊢)¨ 5⊏˘tests
  UnEscape ← {
    EscapeChar ← { ("\""tn"⊐𝕩) ⊏ "\"""∾•UCS 9‿10 }
    esc ← IsEscaped 𝕩
    (¬1⌽esc) / EscapeChar⌾(esc⊸/) 𝕩
  }
  RunTest ← {
    in‿exp ← UnEscape∘(1↓¯1↓⊢)¨2↑𝕩
    out ← 0 Markdown (•UCS 10) ((⊢-˜¬×+`)∘=⊔⊢) in
    ⟨exp≡out,in,exp,out,2⊑𝕩⟩
  }

  ignore ← (2 ⊏˘ tests) ∊ ⟨"47","85"⟩
  res ← 1 ↓˘ (¬⊏˘)⊸/ RunTest˘ tests /˜ ignore < testSection ∊ 𝕩
  res
}

################################
# Syntax highlighting
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

  r←𝕩='#'⋄s←/(≠↑2⊸↓)⊸∧𝕩='''⋄d←/𝕩='"'
  b←⟨s⋄¯1↓d⋄/r⟩ Trace○∾ ⟨2+s⋄1↓d⋄(⊢-¯1↓0∾⊢)∘⊏⟜(0∾+`r)⊸//(𝕩=lf)∾1⟩
  sc←+´(1‿2-˜≠classes)×(≠`∨⊢)∘((≠𝕩)↑/⁼∘∾)¨2↑((⊏˘b)⊏r)⊔○(∾⟜2)<˘b
  col←sc⌈14|chars FindGroup 𝕩

  w←(≠↑0∾⊢)⊸<id←col=5
  idc←1+5|1-˜(idChars FindGroup w/𝕩)+'_'=((1↓∾⟜0)⊸<id)/𝕩
  col↩((id/+`w)⊏0∾idc)⌾(id⊸/)col

  col↩(1⌽col)⊣⌾((𝕩=⊑"𝕩")⊸/)col

  em‿ent ← CharEntities 𝕩
  inc ← ¬ em
  bd←(≠↑¯1∾⊢)⊸≠col
  f←0<bd/col
  add←ent  ∾˜⥊f/(bd/col)⊏classTag
  pos←(/em)∾˜⥊f/2↕/bd∾1
  ((/inc)∾˜(≠¨add)/pos) ⍋⊸⊏ (inc/𝕩)∾˜∾add
}

head ← "<head><link href=""style.css"" rel=""stylesheet""/></head>"∾lf
ConvertFile ← head ∾ Markdown∘•LNS
