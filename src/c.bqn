func‿mod1‿mod2 ← •args
lf←@+10
charSet‿cgl←(∾ ≍○< ≠¨)⟨
  func                  # Function
  mod1                  # 1-modifier
  mod2                  # 2-modifier
  "⋄,"∾lf               # Separator
  "⇐←↩"                 # Gets
  "(){}⟨⟩"              # Bracket
  "‿"                   # Ligature
  "·"                   # nOthing
  # Use last character in case of UTF-16 (like dzaima/BQN)
  ¯1⊏˘10‿∘⥊"𝕊𝕏𝕎𝔽𝔾𝕤𝕩𝕨𝕗𝕘" # Input (𝕣 pending; ℝ not allowed)
  ".¯π∞"                # Numeric
  '0'+↕10               # Digit
  "_"∾˜⥊"aA"+⌜↕na←26    # Alphabetic
  "•"∾(¯1↓"𝕨")∾" "∾@+9  # Whitespace (or special name prefix in UTF-16)
  "#'""@"               # Preprocessed characters
⟩
bF‿b1‿b2‿bS‿bG‿bB‿bL‿bO‿bX‿bN‿bD‿bA‿bW‿bP←≍¨˜⟜(0»+`)cgl
M←1⊸⊑(0⊸≤∧>)-⟜⊑   # ∊ for an init,length pair 𝕩 as above
sep←⊑bS
bI←5≍⟜-⊸+bX
Pl←∾⟜("s"/˜1<≠)   # Pluralize
_tmpl←{∾𝕗{𝕎𝕩}¨<𝕩} # Template
# Convert characters to numbers, mostly the same as tokens
CharCode←charSet{
  ErrUnknownChars←0!˜⟨"Unknown character"⊸Pl,": ",⊢⟩_tmpl
  Chk ← ⊢⊣ErrUnknownChars∘(≠/⊣)⍟≢⟜(⊏⟜𝕗)
  g←⍋𝕗 ⋄ ⊢ Chk g⊏˜1-˜1⌈(g⊏𝕗)⍋⊢
}

vd←1+vi←⊑bN  # Start of identifier numbering (plus dot)
charRole←4∾˜∾⥊¨˜⟜(≠↑cgl˙)⟨1,2,3,¯1,¯3,¯1‿0,¯2,0,5/⌽↕2⟩ # For first vd chars
T←⌈`× ⋄ IT←↕∘≠⊸T ⋄ I1T←(1+↕∘≠)⊸T

# Source to ⟨tokens, roles, number of identifiers, literals⟩
# Identifiers then literal tokens are numbered starting at vi
Tokenize←{
  # Resolve comments and strings
  c←𝕩='#'⋄s←/0‿0⊸«⊸∧sm←𝕩='''⋄d←/dm←𝕩='"'
  g←⍋q←∾⟨  s⋄¯1↓d⋄/c⟩ ⋄q↩g⊏q                # Open indices
  e← g⊏∾⟨2+s⋄ 1↓d⋄-⟜»∘⊏⟜(0∾+`c)⊸//(𝕩=lf)∾1⟩ # Matching close indices
  Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟(0=¯1⊑⊢)       # Mark reachable openings
  St←(≠𝕩)↑·/⁼((≠↑∾⟜≠Se 1∾0¨)q⍋e)⊸/          # All indices → reached mask
  a←St q⋄b←St e⋄f←1≠`ab←a∨b                 # Open/close masks; filter
  {⟨⊑/𝕩,"Unclosed quote"⟩!0}⍟(∨´)(sm∨dm)∧b<f

  # Extract character and string literals
  u←f∧𝕩='@'⋄ci←/u∨»a∧sm
  chr←(⊏⟜𝕩-('@'-@)×⊏⟜u)ci                   # Characters (indices ci)
  f>↩qe←dm∧«a∧↩dm                           # Quote Escape ""
  str←𝕩⊔˜1-˜(si←a>»qe)(⊣+`⊸×○(∾⟜1)<)≠`dm∧ab # Strings (indices /si)

  # Extract words: identifiers and numbers
  ie←/f⋄is←ie≠⊸↑/1»f⋄Fs←{is/˜↩𝕨⋄𝕨/𝕩}        # Token start and end
  is-↩is(-×⊏⟜c)ie                           # Comment → ending newline only
  t←CharCode ie⊏𝕩
  nd←(t=⊑bN)>«t M bD                        # Namespace dot
  w←»⊸<l←nd<t M bN(⊣≍-˜)○⊑bW                # Word chars l, start w
  us←t=¯1++´bA⋄sy←t=⊑bW                     # Underscore, system dot
  {⟨/us∧w+`⊸⊏0∾𝕩,"Words can't only have underscores"⟩!0}⍟(∨´)w(/<1(⊢/«)(∨/⊣))l>us
  wk←na⌊∘÷˜(⊑bA)-˜w/t                       # Kind of word from first char
  t-↩na×l∧t≥na+⊑bA                          # Case-insensitive
  {⟨𝕩/is,"System dot with no name"⟩!0}⍟(∨´)sy>«l
  w≠↩»⊸∨sy                                  # Start system word at dot
  wi←0<wt←(2×wk≥0)(×⟜¬+⊢)w/sy               # Type: 0 number, 1 system, 2 identifier
  i←l>n←l∧(+`w)⊏0∾¬wi                       # Identifier/Number masks
  num←is ReadNums○(((0∾us)<∨⟜«0∾n)/0⊸∾) t×l # Numbers
  ir←(us/˜«⊸<i)(⊢+∧⟜(2⊸=))wi/wk             # Identifier role
  ws←1=wi/wt⋄ig←1-˜(i>us)×+`w>n             # Identifier groups
  {⟨is⊏˜𝕩/𝕨,"Numbers can't start with underscores"⟩!0}⍟(∨´⊢)⟜(ws<(⊑bA)>⊏⟜t)/(¯1»⌈`)⊸<ig
  id←(ws∾2)⊔ig⊔t⊏charSet                    # ⟨Identifiers, system values⟩

  # Deduplicate literals and identifiers; other cleanup
  ki←(wt⍒⊸⊏/w)∾(ci∾/si)⊏+`»f                # Indices in t
  k←id∾num‿chr‿str⋄k(⊢>¯1»⌈`)⊸/¨˜↩j←⊐¨k     # IDs j into uniques k
  k↩𝕎⌾(1⊸⊑)k                                # System value lookup
  wf←¬l∨t M bW⋄ie/˜↩wf∨>⟜«l                 # Index management for...
  t↩(w∨wf)Fs(∾j++`vd»kk←≠¨k)⌾(ki⊸⊏)t        # Add IDs; remove words/whitespace
  t-↩t(M×-⟜⊑)bS                             # Separators are equivalent
  p←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)t=sep               # Separator group boundaries (excludes leading and trailing)
  sk←sb/˜p>∨⟜«(p+(sb-p)⊏t)∊3‿5+⊑bB          # Keep the first of each group that's not just inside a bracket
  t{ie/˜↩𝕨⋄𝕨Fs𝕩}˜↩1¨⌾(sk⊸⊏)t≠sep            # Remove the rest
  r←ir⌾((t M vd≍+´2↑kk)⊸/)(vd⌊t)⊏charRole∾0 # Role
  t+↩5×t M⟨⊑bX,5⟩                           # Case-insensitive special names
  t-↩vi(<+10×=)t                            # Shift . to bX and variables back one
  ⟨t,r,k,is,ie⟩
}

# 𝕩 is a list of tokens that contains the numeric literals, each
# preceded by 0. Return the numbers.
ReadNums←{
  _err_←{(0!˜/⟜𝔾≍○<𝔽)⍟(∨´)}
  EChars←⟨"Letter"⊸Pl," """,⊏⟜charSet,""" not allowed in numbers"⟩_tmpl
  e‿d‿n‿p‿i←=⟜𝕩¨((⊑bA)+-´"ea")∾+⟜↕´bN       # Masks for e.¯π∞
  EChars∘(/⟜𝕩)_err_𝕨 ¬e∨𝕩<⊑bA
  s←d∨c←e∨z←0=𝕩⋄m←¬n∨c
  "Negative sign in the middle of a number"_err_𝕨 n>»c
  "Portion of a number is empty"_err_𝕨 (1«s)∧n∨s
  "Ill-formed decimal or exponent use"_err_(s/𝕎) ¬(0⊸=∨»⊸<)s/𝕩
  "π and ∞ must occur alone"_err_𝕨 (p∨i)>1(»∧(p∧«e)∨«)z∨n>»e
  f←(17≥¬(⊢-T)+`)⊸∧g←(«≤(d<𝕩≠⊑bD)>○I1T¬)⊸∧m # No leading 0s; max 17 digits
  l←(¯1∾π‿1∾↕10)⊏˜(¬d)/f×𝕩-1+⊑bN            # Digit lookup, with ∞ as 1 to avoid ∞×0
  v←(>⟜«0≤l)/0(0⊸≤××⟜10⊸+)`l                # Numeric values—mantissas and exponents
  v×↩1‿¯1⊏˜(r←>⟜»m)/»n                      # Negate if ¯
  vm←c/z                                    # Mask of mantissas in l
  dp←vm/f(--»⊸-(<×⊢)⊏⟜(I1T«d)⊸-)○(/>⟜«)g    # Decimal position
  t←10⋆|ee←dp-˜vm/«v×¬vm                    # Power of 10
  t÷˜⌾((0>ee)⊸/)t×⌾((0<ee)⊸/)vm/v×(r/i)⊏1‿∞ # Correct ∞ then ×10⋆ee
}


Parse ← {r‿vn‿i‿e←𝕨⋄nv←≠vn
  ErrMismatchedBrackets←{
    Lcs ← ∧○(0<≠)◶⟨0, ¯1 ⊑ 0¨∘⊢ {𝕩⌈⌈`𝕨+»𝕩}˝ =⌜⟜⌽⟩
    _mis_ ← {"Missing "∾𝕗∾" "∾charSet⊏˜𝕘+⊢/˜≠∘⊣=⊒}
    Msg ← >○≠◶⟨"opening"_mis_ 0, "closing"_mis_ 1˜⟩
    0 !˜ 𝕨 (Lcs<⌊○≠)◶⟨Msg,"Malformed bracket nesting"⟩ 𝕩
  }
  _err_←{(0!˜(∧∘⍉(i≍e˙)⊏⎉1˜/⟜𝔾)≍○<𝔽)⍟(∨´⍟=)}

  # Bracket and ligature validation and handling
  # Open brackets have role ¯1 and closed ones have role 0
  "Empty program" ! 0<≠𝕩
  g←⍋pd←+`p←(¯1-2×r)×𝕩 M bB⋄gb←g⊏r=¯1       # Paren (actually any bracket type) depth and grade
  (g⊏p)(>⟜0⊸/ErrMismatchedBrackets⍟≢1-˜<⟜0⊸/)gx←g⊏𝕩
  "Swapped open and closed brackets" ! 0≤(⊑g)⊑pd
  "Parentheses can't contain separators"_err_(gb/G) ((⊑bB)⊸=»⊸∧sep⊸=)gb/gx
  {"Empty statement or expression"_err_(𝕩/0∾G) (4+⊑bB)≠𝕩/0∾gx}1⊸«⊸∧1∾gb
  r-↩(𝕩=⊑bG)>ec←«0≤r+p                      # Role ¯4 for exports: ⊑bG is ⇐
  "Invalid assignment or stranding use"_err_(↕∘≠) ((¯4⊸<∧≤⟜¯2)r)>ec∧»0≤r
  "Dot must be followed by a name"_err_(↕∘≠) (r=4)>«𝕩 M vi‿nv
  dl←«⊸∨dc←r=4                              # Dot left
  sr←»⌾(((⍋⊏⟜dl)⊸⊏g)⊸⊏)sl←«⊸∨r=¯2⋄ns←¬sl∨sr # Strand right and left; not stranded
  cp←𝕩=1+⊑bB                                # Closed paren
  nr←(IT¬cp)⊏𝕩=⊑bO                          # Nothingness role: 1 for · (handle 𝕨 later?)
  "Can't strand Nothing (·)"_err_(↕∘≠) ns<nr
  g⊏˜↩⍋g⊏sdl←sl∨dl                          # Avoid reordering strands and dots in rev
  # Permutation to reverse each expression: *more* complicated than it looks
  rev←⍋+`¯1↓(¯1∾g)(⊣⍋⊸⊏⊏˜⟜⍋¬⊏˜)⍋+`⊸+1∾g⊏sdl∨r=¯1
  gf←⍋fd←+`br←rev⊏p×𝕩M⟨2+⊑bB,2⟩             # Order by brace depth fd to de-nest blocks
  rev⊏˜↩gf⋄fd⊏˜↩gf⋄br⊏˜↩gf
  𝕩⊏˜↩rev⋄p⊏˜↩rev⋄i⊏˜↩rev⋄e⊏˜↩rev
  fi←+`b←br>0⋄c←/br<0                       # Block Begin (mask) and Close (index), in matching order

  # Block properties
  PN←1(∾/∾˜)(∨/⊣)⋄H←b¬∘PN=                  # Which blocks have a property
  sn←(0‿3‿4‿5+⊑bI)⍋𝕩⋄sp←/𝕩 M bI             # Special name index
  fx←1 H sn⋄fr←(fx∨0⊸<)⊸+ft←(2⊸H⌈2×3⊸H)sn   # Block immediacy ¬fx and type ft
  "Special name outside of any block"_err_(/{(0=fi)∧𝕩 M bI}∘𝕩) 0<⊑fr
  nf←(⊑bG)H𝕩                                # Namespace blocks
  {"Can't return Nothing (·)"_err_𝕩 𝕩⊏nr} 1-˜nf¬⊸/0∾c⊏rev
  fsc←(ft⊏0‿2‿3)+3×fx                       # Special name count

  # Propagate roles through parentheses
  # ir is the role of the expression ending at each position (truncated to the right)
  r↩sl-˜ns×(1↓fr)⌾((c⊏rev)⊸⊏)r              # Add block roles; make strand elements ¯1
  pt←cp∧ns                                  # Pass-through parentheses: not in strands
  pp←pt∧»es←1⊸»⌾(g⊸⊏)r<0                    # Parens enclosing one object (maybe with assignment) don't change roles
  ir←((»⌾(g⊸⊏)(1+es)×3=⊢)⌈⊢-es<2≤⊢)r+pp×(IT¬pp)⊏r # Propagate modifier roles
  ir⌈↩(IT¬pt∧ir=0)((⊏-⊢)⟜(+`¬pp)(⊢⌊1⌈+)⊏)ir # ...and function roles
  r+↩pt×»ir                                 # Roles at pt were 0; set them now
  ir(×⟜¬-⊢)↩nr                              # Include nothingness (doesn't handle 𝕎)
  r-↩(r=¯4)∧1»r=¯1                          # Lone ⇐ to role ¯5
  "Dot must be preceded by a subject"_err_(⍋∘rev) dc>»r=0
  r(×⟜¬-⊢)↩dl⋄dc⊏˜↩rev                      # Namespace and dot to ¯1

  # Prep for lexical resolution before reordering 𝕩
  di←/dm←»dc                                # Dots aren't scoped
  idv←xv⊏˜id←/idm←dm<(0⊸≤∧<⟜nv)xv←𝕩-vi

  # Parsing part 1
  p-↩br⋄g↩⍋+`p⋄g⊏˜↩⍋g⊏«⊸∨dc⋄gr←g⊏rev        # Order by non-brace bracket depth, then dots
  sll←1+2÷˜0(<-○/>)gr⊏sr-sl⋄l←/g⊏𝕩=5+⊑bB    # Strand length; list starts
  bp←⟨/b,c⟩∾¨0(<≍○(</⟜g)>)g⊏p               # Bracket pairs
  {i↩(𝕨⊏i)⌾(𝕩⊸⊏)i⋄e↩(𝕩⊏e)⌾(𝕨⊸⊏)e}´bp        # Highlight all contents of a pair when error reporting
  g⊏˜↩gs←⍋gr⊏sl⋄gr↩g⊏rev⋄gi←⍋g              # Send strand prefixes *‿ to the end
  𝕩⊏˜↩g⋄r⊏˜↩gr⋄ir⊏˜↩gr⋄l↩(l⊏⍋gs)∾/gr⊏sr>sl
  a←(¯5⊸<∧≤⟜¯3)r⋄ps←a<r<0                   # a: assignment, ps: part separator
  tr←1≤er←ir⊏˜IT»ps                         # er: expression role; tr: train or modifier expression
  no←ir<0⋄ne←er<0                           # Nothing value; expression
  "Nothing (·) cannot be assigned"_err_(G) ne∧a
  oa←⌽/op←(er<2)∧r≥2⋄ro←op∨«op∧m2←r=3       # op: active modifiers; ro: mod or right operand
  "Missing operand"_err_(G) op>(«∧m2≤»)no<m2<ro∨r∊↕2
  "Double subjects (missing ‿?)"_err_(G) ∧⟜«ro»⊸∨⊸<r=0
  ma←tr<(𝕩=2+⊑bG)∧«ir≥1                     # Modified assignment
  os←↕∘≠⊸(⊣-T)⌾⌽¬ro∨ma                      # Operator skip: distance rightward to derived function start
  at←1+⊏⟜os⊸+ai←/a⋄af←¯4≠ai⊏r               # Assignment target; af for actual (non-export) assignment
  "Role of the two sides in assignment must match"_err_(at⊏G) af∧(0⌈at⊏er)≠ar←at⊏r
  aid←(¯5⊸≤∧<⟜nv)𝕩-vi                       # Assignable identifer
  ak←(0≤ar)+af+(⊑bG)-˜ai⊏𝕩                  # Class of assignment: 1⇐ 2⇐? 3←? 4↩?
  aa←×g⊏ac←»+`gi⊏«⊸-ak⌾(at⊸⊏)0¨𝕩            # ac broadcasts it to the entire target
  "Assignment target must be a name or list of targets"_err_(G) (aid∨ps∨𝕩(=⟜(3+⊑)<M)bB)<aa
  "Can't use result of function/modifier assignment without parentheses"_err_(G) (0<er)∧(0≤r)∧»⊸>aa

  # Lexical resolution (independent of parsing part 2 below)
  ip←id⊏ac⋄d←id⊏dd←ac M 2‿2⋄xm←ip M 1‿2     # Assignment classes; which are definitions, exports
  "Can't define special name"_err_(SP) sp⊏dd
  idn←(idg←(d/id⊏fi)∾≠fsc)⊔d/idv            # Numbers for each identifier, per-block
  # Order every referenced identifier, and an undeclaration for each declaration
  ixf←(((1=ip)+⊏⟜(¯1∾b/gf))∾d⊸/⊏((≠𝕩)∾c⊏gf)˙)id⊏fi # First order by block index, open for real and closed for virtual
  ig←(⍋⊏⟜(ixx←∾⟜(d⊸/)idv))⊸⊏⍋ixf            # Then order by name
  {"Redefinition"_err_(𝕩⊏·∾⟜(d⊸/)ID) ¬ixx∨○(»⊸≠𝕩⊸⊏)ixf} (≠d)⊸≤⊸/ig
  ig↩<⟜(≠d)⊸/(⍋+`∘⊏⟜(d∾-/˜d))⊸⊏ig           # Last order by declaration depth
  d⊏˜↩ig
  ("Undefined identifier"Pl/)_err_(ig⊏ID) d<¯1⊸»⊸≠ig⊏idv
  idx←idg⊔(⍋d/ig)⊏d(/≥1↓PN)ig⊏xm            # Exported identifier mask
  ui←(IT d)⊸⊏⌾(ig⊸⊏)id                      # Index of definition (⊐ for identifiers)
  lc←(1«b)/dn←b(⊢-T)+`idm∧dd                # Locals Count
  idd←(id-○(⊏⟜fd)ui)∾0¨sp                   # Identifier frame depth
  "Can't export from surrounding scope"_err_(ID) xm∧0<id≠⊸↑idd
  idi←(ui⊏(fi⊏fsc)+dn-1)∾((sp⊏fi)⊏3×fx)+0⊸≤⊸+2+sp⊏xv # Slot within frame
  uu←ip(((1«d)∧0=⊣)∧d(⊣+`⊸⊏PN)0<⊢)⌾(ig⊸⊏)idd# Unused marker
  idor←∾2‿3/⟨di,id∾sp⟩                      # Identifier bytecode ordering
  idbc←⟨26¨di,di⊏xv
        21+(10×uu)+0<ip∾sp⊏ac,idd,idi⟩      # Identifier bytecode: instruction, depth, slot

  # Parsing part 2
  ta←tr∧2(>∨|)ps(⊢-T)+`¬ro                  # Train argument (first-level)
  fa←/(fe←ta∨ro∨«⊸∨ps<aa)<ff←(r=1)∨»op      # Active functions: cases fe are excluded
  "Second-level parts of a train must be functions"_err_(G) tr>fe∨ff
  dy←fa⊏«no<(tr∧r≥0)∨ro<r=0                 # Dyadic
  ob←pr⊏/¯1(⊢-»)u←⍷∧pr←𝕩⊏˜pi←/𝕩<sep         # Objects to be loaded
  cn←pi∾lt←/𝕩≥ci←vi+nv⋄ob∾↩(ci-˜≠u)+lt⊏𝕩    # Constants
  bk←c⊏gi                                   # Block loads
  s←𝕩=sep⋄fo←𝕩=2+⊑bB⋄ls←s∧fo<○IT lo←𝕩=4+⊑bB # List Separators: after ⟨lo, not {fo
  "Can't use Nothing (·) in lists"_err_(G) (»lo∨ls)∧ne
  ll←sll∾˜(¬lo/1«ps)+-⟜»1↓(lo∾1)/+`ls∾0     # List Length
  dr←/(ne∨»r=¯5)<ls<s⋄rt←/fo                # Drop (block separator) and return
  fl←(dy×⊏⟜os)⊸+fa+dy                       # Function application site
  dr∾↩((1+dy)×fn←fa⊏ne)/fl                  # Turn function applications on · to drops
  fn↩¬fn⋄fa/˜↩fn⋄dy/˜↩fn⋄fl/˜↩fn            # And remove them

  # Bytecode generation: numbers bc ordered by source location (after rev) oi
  or←⍋oi←idor∾g⊏˜∾⟨cn,cn,bk,bk,2/l,dr,af/at,oa+1⌈oa⊏os,fl,rt⟩
  bc←or⊏∾idbc∾⟨0¨cn,ob,15¨bk,1+↕≠bk,⥊⍉(3+l⊏aa)≍ll,14¨dr
               11⌈(11-1+⊑bG)+(af/ai)⊏ma+𝕩,5+oa⊏r,(⊢+9×10⊸=)16+dy-7×fa⊏er,¯1↓rc←25+4×nf⟩
  # Instruction source positions
  MI←-⊸↓˜⟜≠∾g⊏˜⊢⋄oj←(rt-∘≠⊸⌽oi⌊1-˜≠i)Mi∾⟨1-˜af/at,oa,fa⟩
  ind←⟨oj,oj Mi fa⊏IT»¬ro∨ma⟩(¯1∾˜or⊏(≠rt)⊸⌽)⊸⊏¨i‿e
  # Function metadata and overall output
  ⟨bc∾¯1⊑rc,u,⟨ft,¬fx,/1∾or≥bc-○≠rt,lc+fsc,idn,idx⟩,ind⟩
}

Compile←{
  prims‿Sys←{⟨𝕩,("System values not supported"!0˙)¨¨⟩}⍟(2≠≠)𝕨
  ⟨tok,role,val,t0,t1⟩←tx←sys Tokenize 𝕩
  ⟨bc,prim,blk,oi⟩←⟨role,⊑val,t0,t1⟩ Parse tok
  ⟨bc, ∾⟨prim⊏prims⟩∾1↓val, <˘⍉>blk, oi, tx⟩
}
