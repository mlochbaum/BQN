# Compiler simplified twice
# Suitable for compiling once-simplified compiler
# Single-scope; no modified or list assignment; no 2-modifiers
{
  charSet←∾chars←⟨
    "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!" # Function
    "˙˜˘¨⌜⁼´˝`"           # 1-modifier
    "∘○⊸⟜⌾⊘◶⎉⚇⍟⎊"         # 2-modifier
    "⋄,"∾lf←@+10          # Separator
    "←↩"                  # Gets
    "(){}⟨⟩"              # Bracket
    "𝕊𝕩𝕨"                 # Input
    "¯π∞"                 # Numeric
    (⊑"0")+↕10            # Digit
    ⥊"aA"+⌜↕na←26         # Alphabetic
    " "                   # Whitespace
    sc←@+⟨35,34,64⟩       # Preprocessed characters: hash, double quote, @
  ⟩
  cm←((0»+`)⋈¨⊢)cgl←≠¨chars
  bS←3⊑cm⋄bG←4⊑cm⋄bB←5⊑cm⋄bN←7⊑cm⋄bA←9⊑cm⋄bW←10⊑cm
  sep←⊑bS
  vi←⊑bN  # Start of identifier numbering
  charRole←∾cgl⥊¨⟨1,2,3,¯1,¯3,⟨¯1,0⟩,⟨1,0,0⟩,0,0,26/⟨0,1⟩,4,0⟩
  TT←⌈`× ⋄ IT←(↕≠)TT⊢ ⋄ I1T←(1+(↕≠))TT⊢

  # Comments and strings
  s←≠`dd←𝕩=1⊑sc
  f←s<(I1T s<𝕩=⊑sc)≤I1T𝕩=lf                 # Filter comments
  chr←@¨ci←/f∧𝕩=2⊑sc                        # Characters (indices ci)
  f↩f>qe←dd∧«sd←s∧dd                        # Quote Escape
  si←sd>»qe                                 # String indices
  str←𝕩⊔˜1-˜(+`si∾1)×(si<s)∾1               # Strings

  # Extract words: identifiers and numbers
  t←charSet⊐f/𝕩                             # Tokens
  r←t⊏charRole                              # Role
  l←(t≥⊑bN)∧t<⊑bW⋄w←l>»l                    # Word chars l, start w
  wi←(⊑bA)≤w/t                              # Type: 0 number, 1 identifier
  t↩t-na×l∧r=1                              # Case-insensitive
  n←l∧(+`w)⊏0∾¬wi                           # Number mask
  ide←(1-˜(l>n)×+`w>n)⊔t⊏charSet            # Identifiers

  # Numbers, at most 2 digits
  nt←((⊢∨«)0∾n)/0∾t×l                       # Number tokens separated by 0
  nn←nt=⊑bN⋄m←¬nn∨0=nt                      # Mask for ¯; digits
  nl←(0∾⟨π,∞⟩∾↕10)⊏˜m×nt-⊑bN                # Digit lookup
  ns←⟨1,¯1⟩⊏˜(m>»m)/»nn                     # Negate if ¯
  num←ns×(m>«m)/nl+10×»nl                   # Numeric values

  # Deduplicate literals and identifiers; other cleanup
  # Identifiers then literal tokens are numbered starting at vi
  ki←((⍒wi)⊏/w)∾(ci∾/si)⊏+`»f               # Indices in t
  k←⟨ide,⟨⟩,num,chr,str⟩                    # Constants
  k↩k/¨˜(⊢>¯1»⌈`)¨j←⊐¨k                     # IDs j into uniques k
  wr←w∨¬l∨t=⊑bW⋄r↩wr/r⋄c←≠t
  t↩wr/(c↑⍋(⊢+c×⊒)ki∾↕c)⊏(∾j++`vi»≠¨k)∾t    # Add IDs; remove words/whitespace
  t↩t-(t<+´bS)×(⊢×0≤⊢)t-⊑bS                 # Separators are equivalent
  pb←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)t=sep              # Separator group boundaries (excludes leading and trailing)
  eb←⟨3,5⟩+⊑bB                              # End brackets that allow separators
  sk←sb/˜pb>(⊢∨«)eb∊˜pb+(sb-pb)⊏t           # Keep the first of each group that's not just inside a bracket
  sr←((≠t)↑/⁼sk)∨t≠sep⋄r↩sr/r⋄t↩sr/t        # Remove the rest
  𝕩↩t⋄nv←≠⊑k
  # End of tokenization!

  # Bracket roles
  # Open brackets initially have role ¯1 and closed ones have role 0
  gb←⍋+`p←(¯1-2×r)×(𝕩≥⊑bB)∧𝕩<+´bB           # Paren (actually any bracket type) depth and grade
  r↩r+𝕩=3+⊑bB                               # Assume blocks are functions
  cp←𝕩=1+⊑bB                                # Closed paren
  rp←(⍋gb)⊏(≠gb)»gb                         # Position of previous, for roles
  ir←((IT cp≤⊢)⊏⊢)(rp⊏0∾˜3=r)∨0<r           # Role of the expression ending at each position
  r↩r+cp×»ir                                # Roles at cp were 0; set them now

  # Reorder for parsing
  # Permutation to reverse each expression: *more* complicated than it looks
  rev←⍋+`¯1↓(¯1∾gb)((⍋⊣)⊏((⍋⊢)⊏⊣)¬⊏˜)⍋(+`+⊢)1∾gb⊏r=¯1
  gf←⍋fd←+`br←rev⊏p×𝕩∊⟨2,3⟩+⊑bB             # Order by brace depth fd to de-nest blocks
  rev↩gf⊏rev⋄fd↩gf⊏fd⋄br↩gf⊏br
  xv←rev⊏𝕩-vi                               # Save for lexical resolution
  g←⍋+`br-˜rev⊏p                            # Order by non-brace bracket depth
  gr←g⊏rev⋄gi←⍋g                            # Final parsing ordering
  b←br>0⋄bc←/br<0                           # Block Begin (mask) and Close (index), in matching order
  𝕩↩gr⊏𝕩⋄r↩gr⊏r⋄ir↩gr⊏ir

  # Parsing part 1
  a←r=¯3⋄ps←r=¯1                            # a: assignment, ps: part separator
  tr←ir⊏˜IT»ps                              # tr: train or modifier expression
  oa←⌽/op←r≥2⋄ro←op∨«op∧r=3                 # op: active modifiers; ro: mod or right operand
  xs←𝕩=sep⋄fo←𝕩=2+⊑bB                       # Separators, function open {
  ls←xs∧(IT fo)<IT lo←𝕩=4+⊑bB               # List Separators: after ⟨lo, not {fo
  ma←tr<(𝕩=1+⊑bG)∧«ir≥1                     # Modified assignment
  os←⌽(↕≠ro)(⊣-TT)⌽¬ro∨ma                   # Operator skip: distance rightward to derived function start
  at←1+(⊢+os⊏˜⊢)ai←/a                       # Assignment target
  ao←(⊑bG)-˜ai⊏𝕩+ma                         # Assignment opcode
  ak←gi⊏(«-⊢)(⍋⍷at∾↕≠𝕩)⊏(≠𝕩)↑1+ao           # Class of assignment: 1←? 2↩? 3+↩?
  aa←0<g⊏ac←»+`ak×1(»∨⊢)0=+`ak              # Broadcast ak to the entire target

  # Lexical resolution (independent of parsing part 2 below)
  id←/(0≤xv)∧xv<nv                          # Identifier indices in xv
  sp←/(¯3≤xv)∧xv<0                          # Special name indices
  d←1=id⊏ac                                 # Which accesses are definitions
  fi←+`b⋄fsc←3×fx←0∾1¨bc                    # Body index fi, immediacy ¬fx, special name count
  idf←id⊏fi⋄idv←id⊏xv                       # Function index and name ID
  dn←((df←d/idf)∾≠fx)⊔dv←d/idv              # Identifier name ID, per-block
  # Order every referenced identifier, and an undeclaration for each declaration
  ixf←(idf⊏¯1∾b/gf)∾df⊏(≠𝕩)∾1-˜bc⊏gf        # First order by block index, open for real and closed for virtual
  ig←((⍋(idv∾dv)⊏˜⊢)⊏⊢)⍋ixf                 # Then order by name
  ig↩(⊢/˜(≠d)>⊢)(⍋+`ig⊏d∾¯1¨dv)⊏ig          # Last order by declaration depth
  d↩ig⊏d⋄id↩ig⊏id
  ia←0<(id∾sp)⊏ac                           # Which are assignments
  idd←(⊢-(IT d)⊏⊢)id⊏fd                     # Identifier frame depth
  idi←((¯1+`d)⊏(⍋⍋d/ig)⊏⊢)(⊒+⊢⊏fsc˙)df      # Slot within frame
  spi←3+sp⊏xv                               # Special name index
  uu←(1«d)∧d((+`⊣)⊏1(∾/∾˜)(∨/⊣))0<idd       # Unused marker
  uu↩uu∾⌽∊⌽spi+6×sp⊏fi                      # ...for special names
  idor←∾3/⟨id∾sp⟩                           # Identifier bytecode ordering
  idoc←⟨32+uu(⊢+2×>)ia,idd∾0¨sp,idi∾spi⟩    # Identifier bytecode: instruction, depth, slot

  # Parsing part 2
  ta←tr∧2(>∨|)ps(⊢-TT)+`¬ro                 # Train argument (first-level)
  fa←/(ta∨ro∨(«∨⊢)ps<aa)<(r=1)∨»op          # Active functions
  dy←fa⊏«(tr∧r≥0)∨ro<r=0                    # Dyadic
  pr←𝕩⊏˜pi←/𝕩<sep⋄ob←pr⊐˜u←∧⍷pr             # Objects to be loaded
  cn←pi∾lt←/𝕩≥cl←vi+nv⋄ob↩ob∾(cl-˜≠u)+lt⊏𝕩  # Constants
  bk←bc⊏gi                                  # Block loads
  lb←/𝕩=5+⊑bB                               # List starts
  ll←(¬lo/1«ps)+(⊢-»)1↓(lo∾1)/+`ls∾0        # List Length
  dr←/xs>ls⋄rt←/fo                          # Drop (block separator) and return
  fl←(⊢+dy×⊢⊏os˙)fa+dy                      # Function application site

  # Object code generation: numbers oc ordered by source location (after rev) oi
  or←⍋idor∾g⊏˜∾⟨cn,cn,bk,bk,lb,lb,at,dr,oa+1⌈oa⊏os,fl,rt⟩
  oc←or⊏∾idoc∾⟨0¨cn,ob,1¨bk,1+↕≠bk,11+lb⊏aa,ll,48+ao,6¨dr
               24+oa⊏r,16+dy+4×fa⊏tr,¯1↓rc←7¨fx⟩
  # Output
  fz←⟨0¨fx,¬fx,↕≠fx⟩                        # Per-function data
  cz←⟨/1∾or≥(≠oc)-≠rt,fsc+≠¨dn,dn,0¨¨dn⟩    # Per-body data
  ⟨oc∾¯1⊑rc,∾⟨u⊏𝕨⟩∾1↓k,<˘⍉>fz,<˘⍉>cz⟩       # Overall output
}
