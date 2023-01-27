# Compiles the twice-simplified compiler
# This file isn't part of the bootstrapping chain as its syntax is
# more complicated than boot2. It shows how boot2 can be compiled.
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
    sc←"#""@"             # Preprocessed characters
  ⟩
  cm←⋈¨˜⟜(0»+`)cgl←≠¨chars
  bS←3⊑cm⋄bG←4⊑cm⋄bB←5⊑cm⋄bI←6⊑cm⋄bN←7⊑cm⋄bA←9⊑cm⋄bW←10⊑cm
  M←1⊸⊑(0⊸≤∧>)-⟜⊑   # ∊ for an init,length pair 𝕩 as above
  sep←⊑bS
  vi←⊑bN  # Start of identifier numbering
  charRole←∾cgl⥊¨⟨1,2,3,¯1,¯3,⟨¯1,0⟩,⟨1,0,0⟩,0,0,26/⟨0,1⟩,4,0⟩
  TT←⌈`× ⋄ IT←↕∘≠⊸TT

  # Comments and strings
  s←≠`dd←𝕩=1⊑sc⋄ss←s∧dd                     # Strings; string start
  f←s<(s<𝕩=⊑sc)≤○((1+↕∘≠)⊸TT)𝕩=lf           # Filter comments
  chr←@¨ci←/f∧𝕩=2⊑sc                        # Characters (indices ci)
  str←𝕩⊔˜1-˜(+`ss∾1)×(ss<s)∾1               # Strings

  # Extract words: identifiers and numbers
  t←charSet⊐f/𝕩                             # Tokens
  r←t⊏charRole                              # Role
  w←»⊸<l←t M bN(⊣⋈-˜)○⊑bW                   # Word chars l, start w
  wi←(⊑bA)≤w/t                              # Type: 0 number, 1 identifier
  t↩t-na×l∧r=1                              # Case-insensitive
  n←l∧(+`w)⊏0∾¬wi                           # Number mask
  ide←(1-˜(l>n)×+`w>n)⊔t⊏charSet            # Identifiers

  # Numbers, at most 2 digits
  nt←(∨⟜«0∾n)/0∾t×l                         # Number tokens separated by 0
  nn←nt=⊑bN⋄nm←¬nn∨0=nt                     # Mask for ¯; digits
  nl←(0∾⟨π,∞⟩∾↕10)⊏˜nm×nt-⊑bN               # Digit lookup
  ns←⟨1,¯1⟩⊏˜(>⟜»nm)/»nn                    # Negate if ¯
  num←ns×(>⟜«nm)/(10×»)⊸+nl                 # Numeric values

  # Deduplicate literals and identifiers; other cleanup
  # Identifiers then literal tokens are numbered starting at vi
  ki←(wi⍒⊸⊏/w)∾(ci∾/ss)⊏+`»f                # Indices in t
  k←⟨ide,⟨⟩,num,chr,str⟩                    # Constants
  k↩k(⊢>¯1»⌈`)⊸/¨˜j←⊐¨k                     # IDs j into uniques k
  wr←w∨¬l∨t M bW⋄r↩wr/r
  t↩wr/(∾j++`vi»≠¨k)⌾(ki⊸⊏)t                # Add IDs; remove words/whitespace
  t↩t-t(M×-⟜⊑)bS                            # Separators are equivalent
  pb←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)t=sep              # Separator group boundaries (excludes leading and trailing)
  eb←⟨3,5⟩+⊑bB                              # End brackets that allow separators
  sk←sb/˜pb>∨⟜«eb∊˜pb+(sb-pb)⊏t             # Keep the first of each group that's not just inside a bracket
  sr←(t≠⊸↑/⁼sk)∨t≠sep⋄r↩sr/r⋄t↩sr/t         # Remove the rest
  𝕩↩t⋄nv←≠⊑k
  # End of tokenization!

  # Bracket roles
  # Open brackets initially have role ¯1 and closed ones have role 0
  gb←⍋+`p←(¯1-2×r)×𝕩 M bB                   # Paren (actually any bracket type) depth and grade
  r↩r+𝕩=3+⊑bB                               # Assume blocks are functions
  cp←𝕩=1+⊑bB                                # Closed paren
  ir←(IT cp⊸≤)⊸⊏0<r                         # Role of the expression ending at each position
  r↩r+cp×»ir                                # Roles at cp were 0; set them now

  # Reverse each expression: *more* complicated than it looks
  rev←⍋+`¯1↓(¯1∾gb)(⊣⍋⊸⊏⊏˜⟜⍋¬⊏˜)⍋+`⊸+1∾gb⊏r=¯1

  # Lexical resolution, no nesting
  rx←rev⊏𝕩
  iv←/(rx≥⊑bI)∧rx<vi+nv                     # Variable indices
  vv←(iv⊏rx)-vi                             # Variable name
  ii←3↓⊐(¯3+↕3)∾vv                          # Slot within frame
  vb←bG M˜ va←iv⊏»rx                        # Variable assignment, if it's there
  idor←∾3/⟨iv⟩                              # Identifier bytecode ordering
  idoc←⟨32+vb,0¨ii,ii⟩                      # Identifier bytecode: instruction, depth, slot
  dn←⟨⟨⟩,(va=⊑bG)/vv⟩                       # Identifier name ID, per-block

  # Parsing
  gr←rev⊏˜g←⍋+`rev⊏p                        # Order by bracket depth
  𝕩↩gr⊏𝕩⋄r↩gr⊏r⋄ir↩gr⊏ir
  at←/aa←»a←¯3=r                            # Assignment target
  ao←(a/𝕩)-⊑bG                              # Assignment opcode
  tr←ir⊏˜IT»ps←a<r<0                        # tr: train or modifier expression, ps: part separator
  oa←⌽/op←r=2                               # op: active modifiers; op: mod or right operand
  xs←𝕩=sep⋄fo←𝕩=2+⊑bB                       # Separators, function open {
  ls←xs∧fo<○IT lo←𝕩=4+⊑bB                   # List Separators: after ⟨lo, not {fo
  ta←tr∧2(>∨|)ps(⊢-TT)+`¬op                 # Train argument (first-level)
  fa←/(ta∨op∨aa)<(r=1)∨»op                  # Active functions
  dy←fa⊏«(tr∧r≥0)∨op<r=0                    # Dyadic
  pr←𝕩⊏˜pi←/𝕩<sep⋄ob←pr⊐˜u←∧⍷pr             # Objects to be loaded
  cn←pi∾lt←/𝕩≥cl←vi+nv⋄ob↩ob∾(cl-˜≠u)+lt⊏𝕩  # Constants
  bk←/𝕩=2+⊑bB                               # Block loads
  lb←/𝕩=5+⊑bB                               # List starts
  ll←(¬lo/1«ps)+-⟜»1↓(lo∾1)/+`ls∾0          # List Length
  dr←/xs>ls⋄rt←/fo                          # Drop (block separator) and return
  os←⌽↕∘≠⊸(⊣-TT)⌽¬op                        # Operator skip: distance rightward to derived function start
  fl←(dy×⊏⟜os)⊸+fa+dy                       # Function application site

  # Object code generation: numbers oc ordered by source location (after rev) oi
  fsc←3×fx←↕2                               # Body immediacy ¬fx, special name count
  or←⍋idor∾g⊏˜∾⟨cn,cn,bk,bk,2/lb,at,dr,oa+1⌈oa⊏os,fl,rt⟩
  oc←or⊏∾idoc∾⟨0¨cn,ob,1¨bk,1+↕≠bk,⥊⍉(11+lb⊏aa)≍ll,48+ao,6¨dr
               24+oa⊏r,16+dy+4×fa⊏tr,¯1↓rc←7¨fx⟩
  # Output
  fz←⟨0¨fx,¬fx,↕≠fx⟩                        # Per-function data
  cz←⟨/1∾or≥oc-○≠rt,fsc+≠¨dn,dn,0¨¨dn⟩      # Per-body data
  ⟨oc∾¯1⊑rc,∾⟨u⊏𝕨⟩∾1↓k,<˘⍉>fz,<˘⍉>cz⟩       # Overall output
}
