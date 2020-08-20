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

# Index of first zero, or number of leading 1s in a boolean list
Lead ← ⊑ ⊐⟜0

# 𝕨 is a list of lists. Find the first of these lists each cell of 𝕩
# belongs to.
FindGroup ← {
  i ← (∾𝕨) ⊐ 𝕩  # Index in all cells of 𝕨
  e ← +`≠¨𝕨     # Index past the end of each group of 𝕨
  e ⍋ i         # How many end-indices does each element pass?
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

# Remove leading (∧`) and trailing (∧`⌾⌽) spaces
Trim ← { 𝕩 /˜ ¬ (∧` ∨ ∧`⌾⌽) ' '=𝕩 }

# Find whether 𝕨 was true at the last index where 𝕩 was false, in each
# position.
PrecedesGroup ← {
  # We prepend a 0 to 𝕨, so that 0 is the "before start" index, with a
  # false value, and normal indices are increased by 1.
  𝕨 ∾˜↩ 0
  inds ← 1 + ↕≠𝕩
  # Zero out indices where x was true, and find the greatest index so
  # far at each position.
  last ← ⌈` inds × ¬𝕩
  last ⊏ 𝕨
}

# 𝕨 is a list of possible expression start indices in any order and 𝕩 is
# the corresponding endpoints. The expressions are mutually exclusive
# and do not nest, and are enabled in index order. Return a shape ·‿2
# array where the rows give the start and end of each enabled expression
# in index order.
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

# Join lines with newline characters. Include a trailing newline.
JoinLines ← ∾ ∾⟜lf¨

# Create an html node from a tag name and interior text.
Html ← {open 𝕊 contents:
  close ← (⊑open⊐" ") ↑ open
  ∾ ⟨"<",open,">" , contents , "</",close,">"⟩
}

# Insert and remove things from the list 𝕩:
# - include is the mask of elements to keep in 𝕩
# - add is a list of lists to be inserted
# - pos is the list of positions where they should start
# Elements are added just after the given position in 𝕩, in the order
# they appear in ∾add.
Modify ← { ⟨include,add,pos⟩𝕊𝕩:
  ((/include)∾(≠¨add)/pos) ⍋⊸⊏ (include/𝕩)∾∾add
}


################################
Markdown ← {filename𝕊𝕩:
  extensions ← filename ≢ 0
  path ← extensions◶""‿(⊢/˜·∨`⌾⌽'/'⊸=) filename

  ######
  # First we classify each line based on the type of block it can start.
  ClassifyLine ← (0<≠)◶(0‿0)‿{
    ind ← ⊑ lineChars FindGroup ⊏𝕩
    getLen ← ind ⊑ lineClas∾⟨0˜⟩
    l ← GetLen 𝕩
    ⟨ind ∧ l>0 ⋄ l⟩
  }

  # Character entity escaping
  # In order to use this with other modifications such as highlighting,
  # CharEntities returns a mask of characters to be escaped, and their
  # corresponding escapes.
  CharEntities ← {1¨⊸𝕊𝕩;  # 𝕨 gives characters to potentially escape
    # The string gives escapes and their names, separated by spaces.
    # First split it on the first character.
    ce ← (1-˜¬×+`)∘=⟜⊑⊸⊔ " ""quot &amp <lt >gt"
    # Characters to escape are given first
    chars ← ⊑¨ce
    # HTML character entities start with & and end with ;
    entities ← ("&"∾∾⟜";")¨ 1↓¨ce

    # Replace a character if 𝕨 is not set and it's on our list.
    ind ← chars ⊐ 𝕩
    useEntity ← 𝕨 ∧ ind < ≠chars
    ⟨¬ useEntity , entities ⊏˜ useEntity/ind , /useEntity⟩
  }

  # Non-empty lines in code blocks have 4 leading spaces
  ProcCode ← {
    # Strip the leading spaces
    𝕩 ↩ 4 ↓¨ 𝕩
    code ← JoinLines 𝕩

    # Highlight and unescape html-unsafe characters
    c‿ci ← extensions◶(2⥊<⟨⟩)‿GetHighlights code
    em‿e‿ei ← CharEntities code

    # If every line is indented by at least 4 additional spaces, we will
    # execute each one and insert the results.
    addRslt ← ∧´ ' ' = ∾ 4 (⌊⟜≠ ↑ ⊢)¨ 𝕩
    # Don't show assignment results by default
    ShowRslt ← {
      depth ← +` "(){}⟨⟩" (⊣(≠⊸>×¯1⋆2|⊢)⊐) 𝕩
      𝕩 /˜↩ ¬ ∨`⌾⌽ (0=depth) ∧ 𝕩∊"⋄,"  # Just the last statement
      g ← 𝕩∊"←↩"
      (⊑g⊐1) (<⟜(≠g))◶⟨1,¬(" "∾∾idChars)∧´∘∊˜↑⟩ 𝕩
    }
    r‿ri ← addRslt◶(2⥊<⟨⟩)‿{
      ⟨ (ShowRslt ⊣◶⟨"",(⥊∾⟜lf⎉1)∘Fmt∘⊢⟩ CodeExec)⍟(0<≠)¨ 𝕩
        1 -˜ +` 1 + ≠¨ 𝕩   ⟩ # Don't forget the trailing newline
    } 𝕩

    mod ← ⟨em,e∾c∾r,ei∾ci∾ri⟩ Modify code
    "pre" Html "code" Html⍟(¬extensions) mod
  }
  CodeExec ← X  # dzaima+reference exec. Should be {⍎}

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
    # Add an id, containing only a-z, digits, and hyphens
    Slugify ← {
      𝕩 ↩ '-'¨⌾((𝕩=' ')⊸/) 𝕩  # Replace spaces with dashes
      bounds ← ⥊ +⌜⟜0‿26⌾•UCS "Aa"  # Of the upper and lowercase alphabet
      # Lowercase alphabetic characters and remove special characters
      b ← bounds ⍋ 𝕩
      ((2|b)∨∊⟜("-"∾•d))⊸/ +⟜(32×1=b)⌾•UCS 𝕩
    }
    extensions { tag ∾↩ " id="∾""""(∾∾⊣) Slugify 𝕩 }⍟⊣ 𝕩
    tag Html ProcInline Trim 𝕩
  }⟜⊑

  # List items start with a bullet (unordered) or number (ordered).
  LenBullet ← +⟜× ·≤⟜4⊸× ·Lead ' '=1⊸↓
  ProcBullet ← {
    "ul" Html lf ∾ JoinLines ("li" Html ProcInline)¨ 𝕨 ↓¨ 𝕩
  }
  LenListNum ← { # Not used yet
    n ← Lead 𝕩∊•d
    l ← (1≤n) ∧ (9≥n)
    ' ' = n ↓ 𝕩
    t ← n↓(n+2)↑𝕩
    l ∧ (" " ≡ 1↓t) ∧ ⊑(")." ∊˜ 1↑t)
  }

  # Table detection handled specially because the spec is... special
  CutTableRow ← {
    b ← '|' = 𝕩            # Mask of bars
    o ← (¬b) ≠○Lead ' '=𝕩  # Leading | omitted
    r ← b > 0 Shl '\' = 𝕩  # Non-escaped bars
    1 -˜ (¬r∨1⌽b>r) × o + +` r
  }
  ProcTable ← {
    rows ← (Trim¨ CutTableRow⊸⊔)¨ 𝕩
    inc ← ¬ rule ← ∧´∘∾¨'-'=rows
    rows ↩ ProcInline¨¨⌾(inc⊸/) rows
    rows ↩ (⊏rows) (⊢ ∾ ⟨""⟩ /˜ 0⌈-○≠)¨ rows
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
  ProcHtmlBlock ← {
    codeMask ← "<code>" ¯6⊸⌽⊸(>○(⌈`(1+↕∘≠)⊸×))○(⍷⟜𝕩 ∾ 0⥊˜1-˜≠) "</code>"
    (1¨ <⊸∾ codeMask⊸GetMultiHighlights)⊸Modify 𝕩
  }⍟extensions⟜JoinLines

  lineChars‿lineClas‿procFns ← <˘⍉>⟨
    ""    ‿ (!∘0)       ‿ ProcParagraph
    "#"   ‿ LenHeading  ‿ ProcHeading
    ""    ‿ 0           ‿ ProcCode
    ""    ‿ 0           ‿ ProcTable
    "-+*" ‿ LenBullet   ‿ ProcBullet
  # •d    ‿ LenListNum  ‿ ProcListNum
    "<"   ‿ IsHtmlBlock ‿ ProcHtmlBlock
  ⟩

  ######
  # Inline elements
  ProcInline ← {
    I2M ← (≠𝕩) ↑ /⁼  # Index to mask
    punc ← 𝕩 ∊ "!""#$%&'()*+,-./:;<=>?@[\]^_`{|}~"
    actual ← ¬ punc ∧ IsEscaped 𝕩  # backtick or *actual* backtick?

    # Code spans
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
    codeMask ← ≠` I2M ⥊ codeBounds ← 1‿2⊸⊏˘ ctInds
    𝕩 ↩ ' '¨⌾((codeMask∧𝕩=lf)⊸/) 𝕩
    # If span has both a leading and a trailing space, they are removed.
    remSpace ← I2M ⥊ ((1<-˜˝˘)∧·∧˝˘' '=⊏⟜𝕩)⊸/ -⟜0‿1˘ codeBounds
    codeMask ∧↩ ¬ remSpace
    ⟨code,codePos⟩ ← codeMask extensions◶(2⥊<⟨⟩)‿GetMultiHighlights 𝕩
    include ← ¬ remSpace ∨ ≠` I2M ⥊ ctInds
    codeBounds ↩ ⥊ -⟜1‿0˘ codeBounds
    unused ← actual ∧ include ∧ ¬ codeMask

    # Links
    ghPath ← "https://github.com/mlochbaum/BQN/blob/master/"∾path
    ReplaceMDSub ← { ¯2 ("md"≡↑)◶(ghPath⊸∾)‿("README"•_r_"index"∘↓∾"html"˜)⍟(':'∧´∘≠⊢) 𝕩 }
    ReplaceMD ← { ReplaceMDSub⍟(0<≠)⌾((⊑𝕩⊐"#")⊸↑) 𝕩 }
    ProcLink ← { ∾⟨"<a href=""",(ReplaceMD 𝕩),""">",ProcInline 𝕨,"</a>"⟩ }
    # Find matched-depth [] and () pairs, then join adjacent ones
    brak ← (unused ∧ 𝕩⊸=)¨ 2‿2⥊"[]()"
    depth ← (+`-0⌊⊢)∘(-´)˘ brak
    FindPairs ← ⟨⟩‿2 ⥊ 1⊸⊏ /˜ 2⊸⊏ ≠ (¯∞⊸Shl⊸=(∧+⊢)∞⊸Shr⊸=)∘⊏
    pairs ← depth <∘(FindPairs⍟(0<≠))∘⍉∘(∧(⊏˜≍˘⊢)⟜∾∾˘·/≠¨∘⊢)˘ /¨brak
    JoinPairs ← {
      e←1+1⊏˘𝕨 ⋄ b←⊏˘𝕩 ⋄ m←(≠b)>i←b⊐e
      (m/𝕨) ∾˘ (m/i)⊏𝕩
    }
    lInds ← ∧○(0<≠)◶(0‿4⥊0)‿JoinPairs´ pairs
    linkPos ← ⊏˘ lInds
    lInds +⎉1↩ 1‿0‿1‿0
    unused ∧↩ include ∧↩ ¬ ≠` I2M ⥊ (¯1‿1+0‿3⊸⊏)˘ lInds
    linkGroup ← 1 -˜ (1‿0⥊˜≢)⊸(/ (⊣×>)○(+`I2M) ¬⊸/) ⥊lInds
    links ← <∘ProcLink´˘ (lInds≠⊸∾2) (⊣⥊×´⊸↑) linkGroup ⊔ 𝕩

    # Emphasis (still rudimentary)
    eMasks ← (unused ∧ 𝕩⊸=)¨ "*_"
    eMasks ↩ 0⊸Shr⊸∧¨⊸(⊣∾˜0⊸Shl⊸∨⊸<¨) eMasks
    eInds ← (⊢-2|⊢)∘≠⊸↑∘/¨ eMasks
    include ∧↩ ¬ I2M ∧ ∾ eInds∾1+2↓eInds
    eInds ∾↩ ⟨codeBounds⟩
    eTags ← ∾ eInds ≠⊸⥊¨ 2‿2‿1 / ("<"‿"</"∾¨·<∾⟜">")¨ "em"‿"strong"‿"code"
    eInds ↩ ∾ eInds

    # Remove backslashes used for escaping
    include ∧↩ codeMask ∨ 1 ⌽ actual

    em‿ent‿ei ← include CharEntities 𝕩
    include ∧↩ em

    add ← ∾⟨eTags,ent,code,links⟩         # Text to be added
    pos ← ∾⟨eInds,ei,codePos,linkPos⟩     # Where to add it
    ⟨include,add,pos⟩ Modify 𝕩
  }

  ######
  # Create the block structure using line classifications.

  # First remove the html link line: the output *is* the html file.
  𝕩 ↩ 2⊸↓⍟("*View this file" (⊣ ≡ ⌊○≠↑⊢) ⊑) 𝕩

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

  # Tables are made up of rows that would otherwise be paragraph rows.
  # They are indicated by the delimiter row, consisting of only a few
  # allowed characters, preceded (!) by a header row with the same
  # number of cells.
  IsTD ← (∧´ ∊ ∾ ⊣ ∊˜ 2↑⊢)⟜"-|: "
  tableMask ← (0⌾⊑ nonEmptyMask) ∧ paragraphMask ∧¬ codeMask
  tableDelimMask ← { 𝕩 IsTD¨∘⊣⌾(𝕨⊸/) 𝕨 }⟜𝕩 tableMask
  delimValid ← (⊢ =○(≠∘⊔∘CutTableRow¨ ⊏⟜𝕩) -⟜1) / tableDelimMask
  headerMask ← 1 ⌽ delimValid⌾(tableDelimMask⊸/) 0¨𝕩
  tableMask ↩ headerMask (⊢ ∧ ⊣ ∨ ⊣ PrecedesGroup <) tableMask
  lineType ↩ 3¨⌾(tableMask⊸/) lineType

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

# Characters in identifiers. These are also used in ProcCode to detect
# if a statement is an assignment.
idChars ← ⟨
  •d∾"¯.π∞"
  ' '+⌾•UCS•a
  •a
  "_"
⟩

# Return BQN highlights for an string 𝕩, as an ⟨add,pos⟩ list for Modify
# (include will be all 1s).
GetHighlights ← {
  # Characters used by BQN, and the HTML class they are associated with.
  classes‿chars ← <˘ ⍉ ⟨⟩‿2⥊⟨
    0             , " "∾•UCS 9‿10  # Should never be highlighted
    "Value"       , ¯1⊏˘5‿2⥊"𝕨𝕩𝕗𝕘𝕤"# Hack around UTF-16
    "Function"    , "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!"∾¯1⊏˘5‿2⥊"𝕎𝕏𝔽𝔾𝕊"
    "Modifier"    , "˜˘¨⌜⁼´˝`"
    "Modifier2"   , "∘○⊸⟜⌾⊘◶⎉⚇⍟⎊"
    "Number"      , ∾idChars       # Will be classified among ↑↑ later
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
  # Turn non-whitespace classes into ⟨open,close⟩ html tags.
  classTag ← ""‿"" ∾ > {⟨"<span class='"∾𝕩∾"'>","</span>"⟩}¨ 1↓classes

  # Find each character's group, sending quotes to 0 and unknowns to 1.
  col ← (1-˜≠chars) | chars FindGroup 𝕩

  # Locate comments and strings.
  c ← 𝕩='#'
  le← /(𝕩=lf)∾1
  # Line endings (le) end every comment (/c) on the line, so take a copy
  # for each # before that line but not the previous.
  ce← le /˜ -⟜(0⊸Shl) c/⊸⍋le
  # A single quote can only be used if there's another two places down.
  s ← /0‿0⊸Shr⊸∧𝕩='''
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
  col ⌈↩ +´ (1‿2-˜≠classes) × ToMask¨ tc

  # Color numeric literals and identifiers
  id ← col=5                 # ←→ 𝕩∊idChars
  w  ← 0⊸Shl⊸< id            # Word (identifier or number) beginning mask
  wt ← idChars FindGroup w/𝕩 # Type based on first character
  wt+↩ '_' = (0⊸Shr⊸<id)/𝕩   # Modifier1 to Modifier2 based on word end
  wt+↩ 5×0=wt                # Shift 0 to Number
  wi ← 1-˜+`id/w             # Index of word containing each of /id
  col↩(wi⊏wt)⌾(id⊸/) col

  # UTF-16 hack: first half of a special name needs to match the second
  col↩ (1⌽col) ⊣⌾((𝕩=⊑"𝕩")⊸/) col

  # Tags are placed at boundaries between different colors
  boundary ← ¯1⊸Shl⊸≠ col
  bcol ← boundary / col
  # Windows gives us rows of start,end where the end position of one
  # color is the start of the next
  # Subtract one to place before the starting character
  pos ← 2 ↕ 1-˜/boundary∾1
  # Remove class 0 regions, as these don't use tags
  (⥊ (0<bcol)⊸/)¨ ⟨bcol⊏classTag, pos⟩
}

# Return highlights for areas in 𝕩 where 𝕨 is true.
GetMultiHighlights ← {
  start ← 0⊸Shl⊸< 𝕨
  groups ← (1 -˜ 𝕨 × +` start) ⊔ 𝕩
  <∘∾˘ ⍉ ((≠∾2˜) ⥊ ·> (/start) {𝕨⊸+⌾(1⊸⊑)𝕩}⟜GetHighlights¨ ⊢) groups
}


################################
# Format an array to a character matrix
# Won't work on functions until we can catch errors
Fmt ← {
  # Vertical padding for arrays of rank greater than 2
  PadV ← {
    # Leading shape
    ls ← ¯1↓≢𝕩
    # Empty lines after each row: 1 if it's at the end of a 2-cell, plus
    # 1 if it's at the end of a 2-cell and a 3-cell, and so on
    p ← ⥊ +⎉¯1‿∞´ ×⌜˜`⌾⌽ (-1⌈ls)↑¨1
    # But none at the very end
    p ↩ 0⌾(¯1⊸⊑) p
    Pad ← {i←/1+𝕨 ⋄ (¯1¨⌾((¬∊i)⊸/)i) ⊏ 𝕩∾(¯1⊑≢𝕩)⥊" "}
    p (⊑0∊ls)◶⟨Pad,+´⊸↑⟩ ((×´ls)∾¯1⊑≢𝕩) ⥊ 𝕩
  }⍟(2 < =)
  # Horizontal padding: just some spaces on either side
  PadH ← {
    (𝕨/" ") (∾⎉1∾⎉1⊣) 𝕩
  }
  Pad ← PadH⟜PadV
  Enframe ← {(1≠𝕨)∨(1≠≠𝕩)∨⊑2∊+`-˝"⟨⟩"=⌜⊏𝕩}◶{
    ≍"⟨"∾(¯1↓1↓⊏𝕩)∾"⟩"
  }‿{
    l ← ¯1 ⊑ ≢𝕩
    ∾ ⟨ # "┼╒╛╪"
      1‿l↑∾⟨"┌",(5⊸<)◶⟨⥊"·─"⊏˜1⌊⊢,⍕⟩𝕨⟩
      ((4⌊0⌈𝕨-1)⊑"·╵╎┆┊")⌾⊑ 𝕩
      (1∾-l)↑"┘"
    ⟩
  }
  FmtEmpty ← (0‿0≢≢)◶("┌┐"≍"└┘")‿(((2≠=)∨0=≠)◶{
    '┐'⌾(0‿¯1⊸⊑) 2 Enframe 1 PadH " "¨𝕩
  }‿{
    ≍"⟨⟩"∾˜(1<≠)◶⟨"",'⥊'⌾(¯1⊸⊑)·∾·∾⟜"‿"¨⍕¨⟩≢𝕩
  })
  PaddingJoin ← {1𝕊𝕩;
    s ← ≢¨ 𝕩
    w ← ⌈˝⍟(=-1˜)1⊑¨s
    h ← ⌈˝⎉1 ⊑¨s
    ∾⎉2 ≍⍟(0⌈2-=) (h ∾⌜ 𝕨×w¬(-𝕨×≠w)↑1) ↑¨ 𝕩
  }
  FmtMixed ← {
    (=𝕩) Enframe 2 Pad 𝕨 PaddingJoin F¨𝕩
  }
  F ← (2⌊≡)◶(≍≤⟜∞◶⟨"'"⊸(∾∾⊣),⍕⟩)‿{
    num ← 𝕩≤∞ ⋄ r ← =𝕩
    ((≠(0⊸<+≤)+´)⥊num)◶{
      # All characters
      k ← -≠ c ← ¯1↓≢𝕩
      q ← '"'
      𝕩 ↩ (1+q=⊢)⊸/⍟(k=0) 𝕩
      (r Enframe 1 PadH PadV)⍟(1≠r) ≍ (c↑q) ∾⎉k 𝕩 ∾⎉k ⌽⌾⥊c↑q
    }‿{
      # Not homogeneous, or empty
      (∨´0=≢)◶FmtMixed‿FmtEmpty 𝕩
    }‿{
      # All numbers
      ¯1 FmtMixed 𝕩
    } 𝕩
  }‿FmtMixed
  F 𝕩
}


################################
# Creating HTML files
Head ← "<head><link href="""∾("../"/˜"/"⊑∘∊⊢)∾"style.css"" rel=""stylesheet""/></head>"∾lf˜
nav  ← "<div class=""nav""><a href=""https://github.com/mlochbaum/BQN"">BQN</a></div>"∾lf
ConvertFile ← Head ∾ nav ∾ Markdown⟜(•LNS •path∾⊢)
