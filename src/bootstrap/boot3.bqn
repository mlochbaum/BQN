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
  wr←w∨¬l∨t M bW⋄r↩wr/r                     # Remove words/whitespace
  t↩wr/(∾j++`vi»≠¨k)⌾(ki⊸⊏)t                # Add IDs
  pb←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)ts←t M bS          # Separator group boundaries (excludes leading and trailing)
  eb←⟨3,5⟩+⊑bB                              # End brackets that allow separators
  sk←sb/˜pb>∨⟜«eb∊˜pb+(sb-pb)⊏t             # Keep the first of each group that's not just inside a bracket
  sr←ts≤t≠⊸↑/⁼sk⋄r↩sr/r⋄t↩sr/t              # Remove the rest
  𝕩↩t⋄ev←vi+≠⊑k

  # Bracket roles
  # Open brackets initially have role ¯1 and closed ones have role 0
  gb←⍋+`p←(¯1-2×r)×𝕩 M bB                   # Paren (actually any bracket type) depth and grade
  r↩r+𝕩=3+⊑bB                               # Assume blocks are functions
  cp←𝕩=1+⊑bB                                # Closed paren
  r↩r+cp×»(IT cp⊸≤)⊸⊏0<r                    # Propagate functions through parens

  # Reverse each expression: *more* complicated than it looks
  rev←⍋+`¯1↓(¯1∾gb)(⊣⍋⊸⊏⊏˜⟜⍋¬⊏˜)⍋+`⊸+1∾gb⊏r=¯1
  gr←rev⊏˜g←⍋+`rev⊏p                        # Then order by bracket depth
  𝕩↩gr⊏𝕩⋄r↩gr⊏r

  # Constants
  u←∧⍷pr←𝕩⊏˜pi←/𝕩<⊑bS⋄lt←/𝕩≥ev              # Primitives and literals
  cn←pi∾lt⋄ob←(u⊐pr)∾(ev-˜≠u)+lt⊏𝕩          # Locations and object numbers
  # Blocks and lists
  xs←𝕩 M bS⋄ps←r=¯1                         # Separator token; part separator includes {⟨
  bk←/𝕩=2+⊑bB⋄rt←bk                         # Block load and return
  lb←/𝕩=5+⊑bB                               # List starts
  ls←xs∧∨`lo←𝕩=4+⊑bB                        # List Separators after ⟨lo
  dr←/ls<xs                                 # Drop at block separators
  ll←(¬lo/1«ps)+-⟜»1↓(lo∾1)/+`ls∾0          # List Length
  # Assignment
  at←/aa←»a←r=¯3                            # Assignment target
  ao←(a/𝕩)-⊑bG                              # Assignment opcode
  v←/(𝕩≥⊑bI)∧𝕩<ev                           # Variable indices
  vs←(v⊏𝕩)-⊑bI                              # Variable slot
  # Functions and modifiers
  tr←0<r⊏˜IT»ps                             # Train
  oa←/op←r=2                                # Modifier
  ta←tr∧2(>∨|)ps(⊢-TT)+`¬op                 # Train argument (first-level)
  fa←/(ta∨op∨aa)<(r=1)∨»op                  # Active function
  os←⌽↕∘≠⊸(⊣-TT)⌽¬op                        # Operator skip: distance rightward to derived function start
  dy←fa⊏«(tr∧r≥0)∨op<r=0                    # Dyadic
  fl←(dy×⊏⟜os)⊸+fa+dy                       # Function application site
  ol←⊏⟜os⊸+oa                               # Modifier application site

  # Object code generation: numbers oc ordered by source location after rev
  fsc←3×fx←↕2                               # Body immediacy ¬fx, special name count
  or←⍋g⊏˜∾⟨v,v,v,cn,cn,bk,bk,lb,lb,at,dr,ol,fl,rt⟩
  oc←or⊏ ∾⟨32+v⊏aa,0¨v,vs,0¨cn,ob,1¨bk,1+↕≠bk,11+lb⊏aa,ll,48+ao,6¨dr
           24+oa⊏r,16+dy+4×fa⊏tr,¯1↓rc←7¨fx⟩
  # Output
  fz←⟨0¨fx,¬fx,↕≠fx⟩                        # Per-function data
  lc←0⋈+´0=ao                               # Body locals count
  cz←⟨/1∾or≥oc-○≠rt,fsc+lc,↕¨lc,⥊⟜0¨lc⟩     # Per-body data
  ⟨oc∾¯1⊑rc,∾⟨u⊏𝕨⟩∾1↓k,<˘⍉>fz,<˘⍉>cz⟩       # Overall output
}
