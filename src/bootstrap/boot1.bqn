# Comiler simplified once
# Full compiler minus error checking and index tracking
# Syntax simplified to avoid _ · ‿ ' 𝕏𝕎𝔽𝔾𝕗 and double quote in comment
# Already didn't have . [] :;? ⇐ 𝕣𝕤𝕘
# Blocks are functions; no empty list literals; no useless parentheses
na←¯1⊑≢alph←("aA"+⌜↕26)∾˘"àÀ"+⌜(↕23)∾24+↕7
lf←@+⟨10,13⟩
⟨charSet,cgl⟩←(∾ ⋈ ≠¨)⟨
  "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!" # Function
  mod1←"˙˜˘¨⌜⁼´˝`"      # 1-modifier
  "∘○⊸⟜⌾⊘◶⎉⚇⍟⎊"         # 2-modifier
  "⋄,"∾lf               # Separator
  ":;?"                 # Header punctuation
  "⇐←↩"                 # Gets
  "(){}⟨⟩[]"            # Bracket
  "‿"                   # Ligature
  "·"                   # nOthing
  "𝕊𝕏𝕎𝔽𝔾𝕤𝕩𝕨𝕣𝕗𝕘"         # Input
  ".¯π∞"                # Numeric
  (⊑"0")+↕10            # Digit
  "_"∾˜⥊alph            # Alphabetic
  "• "∾@+9              # Whitespace
  ⟨cc,qs,qd,nc⟩←"#'""@" # Preprocessed characters
⟩
⟨bF,b1,b2,bS,bH,bG,bB,bL,bO,bX,bN,bD,bA,bW,bP⟩←⋈¨˜⟜(0»+`)cgl
M←1⊸⊑(0⊸≤∧>)-⟜⊑   # ∊ for an init,length pair 𝕩 as above
sep←⊑bS
pred←2+⊑bH
bI←bX+⋈⟜-5⋄bR←8+⊑bX
# Convert characters to numbers, mostly the same as tokens
cgf←(cgr←⍋charSet)⊏charSet
CharCode←cgr⊏˜1-˜1⌈cgf⍋⊢
swapundo←CharCode∊⟜mod1⊸/"˜⁼"

vd←1+vi←⊑bN  # Start of identifier numbering (plus dot)
charRole←4∾˜∾⥊¨˜⟜(≠↑cgl˙)⟨1,2,3,¯1,¯1,¯3,⟨¯1,0⟩,¯2,0,¬/⟨5,6⟩⟩ # For first vd chars
T←⌈`× ⋄ IT←↕∘≠⊸T ⋄ I1T←(1+↕∘≠)⊸T
PN←1(∾/∾˜)(∨/⊣)  # Partitioned-none: partitions where 𝕨<𝕩 is never 1

# Source to ⟨tokens, roles, number of identifiers, literals⟩
# Identifiers then literal tokens are numbered starting at vi
Tokenize←{⟨System,vars⟩←𝕨
  # Resolve comments and strings
  c←𝕩=cc⋄s←/⟨0,0⟩⊸«⊸∧sm←𝕩=qs⋄d←/dm←𝕩=qd
  g←⍋q←∾⟨  s⋄¯1↓d⋄/c⟩ ⋄q↩g⊏q                # Open indices
  e← g⊏∾⟨2+s⋄ 1↓d⋄-⟜»∘⊏⟜(0∾+`c)⊸//(𝕩∊lf)∾1⟩ # Matching close indices
  Se←≠(>/⊢)∾⟜≠{(⊏˜𝕨)𝕊⍟(≠○(¯1⊸⊑))𝕩∾𝕩⊏𝕨}⟨0⟩˙  # Find reachable openings
  St←(≠𝕩)↑(/⁼(Se q⍋e)⊸⊏)                    # All indices → reached mask
  a←St q⋄b←St e⋄f←1≠`ab←a∨b                 # Open/close masks; filter

  # Extract character and string literals
  u←f∧𝕩=nc⋄ci←/u∨»a∧sm
  chr←(⊏⟜𝕩-(nc-@)×⊏⟜u)ci                    # Characters (indices ci)
  f>↩qe←dm∧«a∧↩dm                           # Quote Escape
  str←𝕩⊔˜1-˜(si←a>»qe)(⊣+`⊸×○(∾⟜1)<)≠`dm∧ab # Strings (indices /si)

  # Extract words: identifiers and numbers
  t←CharCode f/𝕩
  nd←(t=⊑bN)>«t M bD⋄rr←t=bR                # Namespace dot; 𝕣
  w←»⊸<l←rr∨nd<t M bN(⊣⋈-˜)○⊑bW             # Word chars l, start w
  us←t=¯1++´bA⋄sy←t=⊑bW                     # Underscore, system dot
  wk←(¬w/rr)×na⌊∘÷˜(⊑bA)-˜w/t               # Kind of word from first char
  t-↩na×l∧t≥na+⊑bA                          # Case-insensitive
  w≠↩»⊸∨sy                                  # Start system word at dot
  wi←0<wt←(2×wk≥0)(×⟜¬+⊢)w/sy               # Type: 0 number, 1 system, 2 identifier
  i←l>n←l∧(+`w)⊏0∾¬wi                       # Identifier/Number masks
  num←ReadNums○(((0∾us)<∨⟜«0∾n)/0⊸∾) t×l    # Numbers
  ir←(us/˜«⊸<i)(⊢+∧⟜(2⊸=))wi/wk             # Identifier role
  if←(»⌈`)⊸<ig←(i>us)×+`w>n                 # Identifier groups and first character
  fr←(1=wi/wt)<if/rr                        # Identifier is 𝕣-based
  w↩if∨n∧w⋄ws←1=0⊸<⊸/wt/˜↩¬w/rr             # Don't produce an identifier for 𝕣
  ig⊏↩1-˜0∾+`⊸×¬fr
  id←vars⊸∾⌾⊑(ws∾2)⊔ig⊔t⊏charSet            # ⟨Identifiers, system values⟩

  # Deduplicate literals and identifiers; other cleanup
  ki←(wt⍒⊸⊏/w>rr)∾(ci∾/si)⊏+`»f             # Indices in t
  k←id∾⟨num,chr,str⟩⋄k(⊢>¯1»⌈`)⊸/¨˜↩j←⊐¨k   # IDs j into uniques k
  k↩System⌾(1⊸⊑)k                           # System value lookup
  wf←¬l∨t M bW                              # Index management for...
  t↩(w∨wf)/(vars≠⊸↓∾j++`vd»kk←≠¨k)⌾(ki⊸⊏)t  # Add IDs; remove words/whitespace
  t-↩t(M×-⟜⊑)bS                             # Separators are equivalent
  p←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)t=sep               # Separator group boundaries (excludes leading and trailing)
  eb←⟨3,5,7⟩+⊑bB                            # End brackets that allow separators
  sk←sb/˜p>∨⟜«(M⟜bH∨eb∊˜p⊸+)(sb-p)⊏t        # Keep the first of each group that's not just inside a bracket
  t/˜↩1¨⌾(sk⊸⊏)t≠sep      # Remove the rest
  im←(t=bR)∨t M vd⋈+´2↑kk                   # Identifier (or 𝕣) mask
  r←ir⌾(im⊸/)(vd⌊t)⊏charRole∾0              # Role
  t+↩(⊑bX)((⊢M⋈⟜5)×5+3⊸+⊸≤)t                # Case-insensitive special names
  t-↩vi(<+10×=)t                            # Shift . to bX and variables back one
  ⟨t,r,k⟩
}

# 𝕩 is a list of tokens that contains the numeric literals, each
# preceded by 0. Return the numbers.
ReadNums←{
  ⟨e,d,n,p,i⟩←=⟜𝕩¨((⊑bA)+-´"ea")∾+⟜↕´bN     # Masks for e.¯π∞
  c←e∨z←0=𝕩⋄m←¬n∨c
  f←(17≥¬(⊢-T)+`)⊸∧g←(«≤(d<𝕩≠⊑bD)>○I1T¬)⊸∧m # No leading 0s; max 17 digits
  l←(¯1∾⟨π,1⟩∾↕10)⊏˜(¬d)/f×𝕩-1+⊑bN          # Digit lookup, with ∞ as 1 to avoid ∞×0
  v←(>⟜«0≤l)/0(0⊸≤××⟜10⊸+)`l                # Numeric values—mantissas and exponents
  v×↩⟨1,¯1⟩⊏˜(r←>⟜»m)/»n                    # Negate if ¯
  vm←c/z                                    # Mask of mantissas in l
  dp←vm/f(--»⊸-(<×⊢)⊏⟜(I1T«d)⊸-)○(/>⟜«)g    # Decimal position
  t←10⋆|ee←dp-˜vm/«v×¬vm                    # Power of 10
  t÷˜⌾((0>ee)⊸/)t×⌾((0<ee)⊸/)vm/v×(r/i)⊏1⋈∞ # Correct ∞ then ×10⋆ee
}


Parse ← {⟨r,vn,def⟩←𝕨⋄nv←≠vn
  # Bracket and ligature validation and handling
  # Open brackets have role ¯1 and closed ones have role 0
  g←⍋+`p←(¯1-2×r)×𝕩 M bB                    # Paren (actually any bracket type) depth and grade
  dl←«⊸∨dc←r=4                              # Dot left
  r-↩(𝕩=⊑bG)>«dc<0≤r+p                      # Role ¯4 for exports: ⊑bG is ⇐
  sr←»⌾(((⍋⊏⟜dl)⊸⊏g)⊸⊏)sl←«⊸∨r=¯2⋄ns←¬sl∨sr # Strand right and left; not stranded
  cp←𝕩=1+⊑bB                                # Closed paren
  nr←(IT¬cp)⊏(𝕩=2+⊑bI)+2×𝕩=⊑bO              # Nothingness role: 1 for 𝕨, 2 for ·
  nx←0
  g⊏˜↩⍋g⊏sdl←sl∨dl                          # Avoid reordering strands and dots in rev
  rp←≠⊸»⌾(g⊸⊏)↕≠r                           # Position of previous, for roles
  # Permutation to reverse each expression: *more* complicated than it looks
  rev←⍋+`¯1↓(¯1∾g)(⊣⍋⊸⊏⊏˜⟜⍋¬⊏˜)⍋+`⊸+1∾g⊏sdl∨r=¯1
  gf←⍋fd←+`br←rev⊏p×𝕩M⟨2+⊑bB,2⟩             # Order by brace depth fd to de-nest blocks
  rev⊏˜↩gf⋄fd⊏˜↩gf⋄br⊏˜↩gf
  𝕩⊏˜↩rev⋄dc⊏˜↩rev

  # Compute parsing ordering gr≡g⊏rev
  BE←=∨+⟜2⊸=                                # Bracket equals: match ⟨[ or ⟩] given ⟨ or ⟩ only
  g↩⍋+`p↩br-˜rev⊏p⋄bp←0(<⋈○(/⟜g)>)g⊏p       # Order by non-brace bracket depth
  g⊏˜↩⍋g⊏«⊸∨dc⋄gr←g⊏rev                     # Now by dots
  sll←1+2÷˜0(<-○/>)gr⊏sr-sl⋄l←/g⊏𝕩BE˜5+⊑bB  # Strand length; list starts
  b←br>0⋄c←/br<0⋄bp∾¨↩⟨/b,c⟩                # Block Begin (mask) and Close (index), in matching order
  g⊏˜↩gs←⍋gr⊏sl⋄gr↩g⊏rev⋄gi←⍋g              # Send strand prefixes *‿ to the end

  # Headers
  hh←𝕩=⊑bH⋄cs←𝕩=1+⊑bH                       # Case header : and separator ;
  fi←+`cb←b∨cs⋄H←cb¬∘PN⊢                    # Body index fi; which bodies Have a property
  cq←(H𝕩=pred)∨ch←H hh                      # ch: body has : header ; cq: or ? predicate
  cf←1∾¬co←cb/cs⋄cm←0∾∨⟜«co                 # cf: body is first; cm: body is one of multiple
  cc←(⍋⍋«co)⊏c∾/cs                          # Case close
  hi←/hf←hh⊏˜⟜IT⌾((⌽g)⊸⊏)cb∨hh              # Header component indices
  un←0=us←swapundo(≠∘⊣-⊐)hi⊏𝕩
  ut←un/»us⋄hi/˜↩0=us                       # Undo type: 0 normal, 1 ⁼, 2 ˜⁼
  hr←(⊏⟜ns×⊏⟜r)rev⊏˜hi                      # Header component roles
  hl←2=hn←(1⊸»+«)hc←¯1=hr                   # hl: is label, hc: is :
  ho←(»∨(«(hr=3)∧⊢))hl<2≤hr                 # Header operands
  hm←¬ho∨ha←ho<(0=hr)∧1=hn                  # Mask for main name; header arguments
  hk←3|1-˜(+`bI∾nv)⍋hi⊏𝕩×¬rev⊏sr            # Kind: 0 special, 1 name, 2 compound
  hma←hm>hla←hl∧(0=hr)∧1≠hk⋄hr+↩hla⋄hl>↩hla # Lone non-name subject is 𝕩 with 𝕊 omitted
  hv←(hla+ha×1+«hc)+(ho×4+«3=hr)+hma×3×1-˜2⌊hr # Special name for position
  hk×↩¬hc∨hl∧0=hr                           # Treat subject labels like special names
  hm>↩hc⋄hr/˜↩hm⋄hx←(1»hc)/ha               # Header-derived role hr and immediacy ¬hx
  ut-↩-⟜»ut×ho                              # Shift ⁼ from right operand to main name
  ut/˜↩hm⋄hx∨↩1=hr
  cwh←hc/»hl⌈ha×1+he←0≠hk                   # Body 𝕨 for just headers
  ut2←2=ut
  cw←(cwh⌈2×ut2)⌾(ch⊸/)1+-⟜«(»cq)<1(⊢<«)cf  # Body 𝕨: 0 no, 1 allowed, 2 required
  hl/˜↩hm⋄hu←(¬he)⌾(hi⊸⊏)hf                 # hu: mask of header special names
  hj←gi⊏˜he/hi⋄hd←2=he/hk                   # hj: header assignments; hd: which ones destructure

  # Block properties
  ss←⟨0,3,5,6⟩⍋(⊢+(0<hk)×hv⊸-)⌾(hi⊸⊏)𝕩-⊑bI  # Special name
  ss+↩(rev⊏r=3)∧𝕩=3+⊑bI                     # Treat _𝕣_ as 3, like 𝕘
  HS←(¯1+`cf)⊏b¬∘PN=⟜ss⋄sp←/hu<𝕩 M bI       # Has-special (𝕤𝕩𝕨/𝕣𝕗/𝕘); indices of specials
  fx←HS 1⋄fr←(fx∨0⊸<)⊸+ft←2(⊣⌈2×⊢)○HS 3     # Body immediacy ¬fx, type ft, role fr
  ft⌈↩1-˜fr↩hr⌾(ch⊸/)fr⋄fx↩hx⊸⌈⌾(ch⊸/)fx
  fsc←(ft⊏⟨0,2,3⟩)+3×fx                     # Special name count
  hv-↩(»+`hc)⊏3×¬ch/fx                      # Header variable slot

  # Propagate roles through parentheses
  # ir is the role of the expression ending at each position (truncated to the right)
  r↩sl-˜ns×(1↓cf/fr)⌾((c⊏rev)⊸⊏)r           # Add block roles; make strand elements ¯1
  pt←cp∧ns                                  # Pass-through parentheses: not in strands
  pp←pt∧»es←rp⊏1∾˜r<0                       # Parens enclosing one object (maybe with assignment) don't change roles
  ir←((rp⊏0∾˜(1+es)×3=⊢)⌈⊢-es<2≤⊢)r+pp×(IT¬pp)⊏r # Propagate modifier roles
  ir⌈↩(IT¬pt∧ir=0)((⊏-⊢)⟜(+`¬pp)(⊢⌊1⌈+)⊏)ir # ...and function roles
  r+↩pt×»ir                                 # Roles at pt were 0; set them now
  nr×↩¬nx∨↩(0≠ir)∧1=nr                      # Assume 𝕎 can't be Nothing
  ir↩(ir×0=nr)-nr                           # Include nothingness
  r-↩(r=¯4)∧1»r=¯1                          # Lone ⇐ to role ¯5
  r(×⟜¬-⊢)↩dl                               # Namespace and dot to ¯1

  # Reorder for parsing
  xv←𝕩-vi                                   # Save for lexical resolution
  𝕩⊏˜↩g⋄hg←g⊏hf⋄r⊏˜↩gr⋄ns⊏˜↩gr⋄ir⊏˜↩gr
  l↩(l0←l⊏⍋gs)∾/gr⊏sr>sl                    # Indices of list literals
  lm←(0¨sll)∾˜(5+⊑bB)-˜l0⊏𝕩                 # List merge, adding 2 for []

  # Parsing part 1
  a←(¯5⊸<∧≤⟜¯3)r⋄ps←a<r<0                   # a: assignment, ps: part separator
  tr←1≤er←ir⊏˜IT»ps                         # er: expression role; tr: train or modifier expression
  no←0⌈-ir⋄ne←0⌈-er⋄nx⊏˜↩gr                 # Nothing value; expression
  nx⌈↩ne×a
  nx⌈↩ne×𝕩=pred
  oa←⌽/hg<op←(er<2)∧r≥2⋄ro←op∨«op∧m2←r=3    # op: active modifiers; ro: mod or right operand
  nx⌈↩op×2(«⌈m2×»)no⌈2×m2≥ro∨r∊↕2
  s←𝕩=sep⋄fo←𝕩∊⟨2+⊑bB,1+⊑bH⟩                # Separators, function open { or ;
  ls←s∧fo<○IT lo←𝕩BE˜4+⊑bB                  # List Separators: after ⟨lo, not {fo
  mm←𝕩=2+⊑bG⋄ma←tr<mm∧«ir≥1⋄mm∧↩1»ps        # Modified assignment; monadic modified
  os←↕∘≠⊸(⊣-T)⌾⌽¬ro∨ma                      # Operator skip: distance rightward to derived function start
  at←1+⊏⟜os⊸+ai←/a                          # Assignment target
  af←¯4≠ai⊏r⋄ar←at⊏r                        # af for actual (non-export) assignment; assignment role
  ak←af+(0≤ar)+(ai⊏ma)+(⊑bG)-˜ai⊏𝕩          # Class of assignment: 1⇐ 2⇐? 3←? 4↩? 5+↩?
  at∾↩hj⋄ac←«⊸-(ak∾6¨hj)⌾(at⊸⊏)0¨𝕩          # Header assignment is 6 temporarily
  aa←0<gac←g⊏ac↩»+`(1⊸»⊸∨0=+`)⊸×gi⊏ac       # Broadcast ac to the entire target
  api←/(𝕩=⊑bO)∧ap←aa∧2=no                   # Assignment placeholder
  nx⌈↩no×ap<ns≤»lo∨ls
  ac-↩3×6=ac⋄ah←6=gac                       # Assignment is header; 6→3
  nx⌈↩aa×1=no                               # Prevent assignment to 𝕨 if it's ·
  nf←H ac<xv=vi-˜⊑bG                        # Namespace bodies
  fw←H gi⊏nx                                # Bodies where 𝕨 must be defined
  fw⌈↩nf¬⊸×(1-˜0∾cc⊏rev)⊏nr
  fw≥○I1T↩cf                                # If a body fails on 𝕨, later ones won't see 𝕨
  cw⌈↩2×fw⋄cw×↩fx
  nn←g⊏fi⊏2=cw⋄no(⊣-=)↩nn⋄ne(⊣-=)↩nn        # 2=cw indicates 𝕨 is never Nothing
  hq←/ah∧𝕩≥nv+vi                            # Header constant
  af>↩alm←ai⊏aa⋄al←alm/ai                   # aliases al
  ai/˜↩af⋄at/˜↩af∾1¨hj

  # Lexical resolution (independent of parsing part 2 below)
  di←/dm←»dc                                # Dots aren't scoped
  id←/(hu∨dm∨gi⊏«aa∧a)<(0⊸≤∧<⟜nv)xv         # Identifier indices in xv
  sa←0<sp⊏ac⋄d←(ic←id⊏ac)M⟨2,2⟩             # Which accesses are definitions
  idf←id⊏fi⋄idv←id⊏xv                       # Function index and name ID
  dp←d∧(0=idf)∧idv<≠def                     # Definitions of vars in def
  dpf←(dp/idv)⊏def
  d↩(0≤dpf)⌾(dp⊸/)d⋄zda←0¨da←/def≤0         # Turn def ¯1 ← into ↩
  dn←(dg←zda∾(df←d/idf)∾≠fsc)⊔da∾dv←d/idv   # Identifier name ID, per-block
  # Order every referenced identifier, and an undeclaration for each declaration
  ixf←((1=ic)+idf⊏¯1∾cb/gf)∾df⊏(≠𝕩)∾1-˜cc⊏gf# First order by block index, open for real and closed for virtual
  ig←(⍋⊏⟜(idv∾dv))⊸⊏⍋ixf                    # Then order by name
  ig↩<⟜(≠d)⊸/(⍋ds←+`ig⊏d∾¯1¨dv)⊏ig          # Last order by declaration depth
  d⊏˜↩ig⋄id⊏˜↩ig⋄ic⊏˜↩ig
  du←+´¬»⊸∨0<ds⋄uv←(du↑ig)⊏idv              # Number undefined (always sorted to front)
  ix←(ic<3)∧ia←0<ic                         # Which are exports, assignments
  idd←(⊢-(uv⊏ded←-0⌈def)∾(du↓IT d)⊸⊏)id⊏fd  # Identifier frame depth
  dx←dg⊔zda∾(dig←⍋d/ig)⊏ixa←d(/≥1↓PN)ix     # Exported identifier mask
  idi←(uv⊸⊏∾(¯1+`du↓d)⊏dig⍋⊸⊏da≠⊸↓⊢)(⊏⟜fsc+⊒)ded∾df # Slot within frame
  uu←(ia<1«d)∧d(⊣+`⊸⊏(1∾ixa)<PN)0<idd       # Unused marker
  spi←((spf←sp⊏fi)⊏3×fx)+3+sp⊏xv            # Special name index
  uu∾↩∊⌾⌽spi+6×spf                          # and unused marker
  idor←∾⟨3,2,3⟩/⟨1+g⊏˜hj-1, di, id∾sp⟩      # Identifier bytecode ordering
  ido←32+uu(⊢+2×>)ia∾sa                     # Opcode
  idoc←⟨32¨hj,0¨hj,he/hv
        64¨di,di⊏xv, ido,idd∾0¨sp,idi∾spi⟩  # Identifier bytecode: instruction, depth, slot

  # Parsing part 2
  ta←tr∧2(>∨|)ps(⊢-T)+`¬ro                  # Train argument (first-level)
  fa←/(hg∨ta∨ro∨«⊸∨ps<aa)<(r=1)∨»op         # Active functions: cases fe are excluded
  dy←2≠ny←fa⊏2«no⌈2×¬(tr∧r≥0)∨ro<r=0        # Dyadic
  ob←pr⊐˜u←∧⍷pr←𝕩⊏˜pi←/hg<𝕩<sep             # Objects to be loaded
  cn←pi∾lt←/𝕩≥cl←vi+nv⋄ob∾↩(cl-˜≠u)+lt⊏𝕩    # Constants
  bk←c⊏gi                                   # Block loads
  ll←sll∾˜(¬lo/1«ps)+-⟜»1↓(lo∾1)/+`ls∾0     # List Length
  dr←(hd¬⊸/hj)∾/s>(2=ne)∨ls∨»r=¯5⋄rt←/fo    # Drop (block separator) and return
  qp←/𝕩=pred                                # Predicate
  fl←(dy×⊏⟜os)⊸+fa+dy                       # Function application site
  dr∾↩((1+dy)×fn←2=fm←fa⊏ne)/fl             # Turn function applications on · to drops
  fn↩¬fn⋄fa/˜↩fn⋄fl/˜↩fn                    # And remove them

  # Object code generation: numbers oc ordered by source location (after rev) oi
  ao←48+(0⌈(1+⊑bG)-˜ai⊏𝕩+ma+mm)∾-hd         # Assignment opcode
  or←⍋idor∾g⊏˜∾⟨cn,cn,bk,bk,hq,api,2/l,at,dr,qp,al+1,al+1,oa+1⌈oa⊏os,fl,rt⟩
  oc←or⊏∾idoc∾⟨0¨cn,ob,1¨bk,1+↕≠bk,43¨hq,44¨api,⥊⍉(11+lm+l⊏aa)≍ll,ao,6¨dr,42¨qp,66¨al,vi-˜(al-1)⊏𝕩
               24+oa⊏r,16+(fn/dy+2×fm⌈1=ny)+4×0<fa⊏er,¯1↓rc←7+nf⟩
  # Indices for multi-body blocks
  cm∨↩(fx∧1≠cw)∨0<ut↩ut⌾(ch⊸/)ch            # Dyad- and inverse-only generate as multiple
  cj←/cv←1+1=ciw←cw⊏˜ci←/cm                 # Number of copies
  ck←4⌊(2×ci⊏ut)+1<ciw                      # Position
  cg←¯1+`cif←ci⊏cf                          # Which block
  ckt←(2-¬(cf∧cm)/fx)⌈(cif/⍋∘⊏⟜cg)⊸⊏∘⍒⊸⊏cv+ck
  ci↩ckt/⊸⊔(¯1(↑∾˜cj(⊒∘⊣+⊏)ck+cg⊏↓)0∾+`ckt)⊔cj⊏ci
  # Output
  fz←⟨cf/ft,cf/¬fx,ci⌾((cf/cm)⊸/)/cf⟩       # Per-function data
  cz←⟨/1∾or≥oc-○≠rt,fsc+≠¨dn,dn,dx⟩         # Per-body data
  ⟨oc∾¯1⊑rc,u,fz,cz⟩                        # Overall output
}

Compile←{
  defaults←⟨↕0,(!∘"System values not supported"¨),↕0,↕0⟩
  ⟨prims,Sys,vars,redef⟩ ← ∾⟜(≠↓defaults˙) ⋈⍟(4<≠)𝕨
  ⟨tok,role,val⟩←⟨sys,vars⟩ Tokenize 𝕩
  ⟨oc,prim,blk,bdy⟩←⟨role,⊑val,redef»0¨vars⟩ Parse tok
  ⟨oc, ∾⟨prim⊏prims⟩∾1↓val, <˘⍉>blk, <˘⍉>bdy⟩
}
