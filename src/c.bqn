func‿mod1‿mod2 ← •args
lf←@+10
charSet‿cgl←(∾ ⋈ ≠¨)⟨
  func                  # Function
  mod1                  # 1-modifier
  mod2                  # 2-modifier
  "⋄,"∾lf               # Separator
  ":;?"                 # Header punctuation
  "⇐←↩"                 # Gets
  "(){}⟨⟩"              # Bracket
  "‿"                   # Ligature
  "·"                   # nOthing
  # Use last character in case of UTF-16 (like dzaima/BQN)
  ¯1⊏˘11‿∘⥊"𝕊𝕏𝕎𝔽𝔾𝕤𝕩𝕨𝕣𝕗𝕘"# Input
  ".¯π∞"                # Numeric
  '0'+↕10               # Digit
  "_"∾˜⥊"aA"+⌜↕na←26    # Alphabetic
  "•"∾(¯1↓"𝕨")∾" "∾@+9  # Whitespace (or special name prefix in UTF-16)
  "#'""@"               # Preprocessed characters
⟩
bF‿b1‿b2‿bS‿bH‿bG‿bB‿bL‿bO‿bX‿bN‿bD‿bA‿bW‿bP←⋈¨˜⟜(0»+`)cgl
M←1⊸⊑(0⊸≤∧>)-⟜⊑   # ∊ for an init,length pair 𝕩 as above
sep←⊑bS
pred←2+⊑bH
bI←bX+⋈⟜-5⋄bR←8+⊑bX
Pl←∾⟜("s"/˜1<≠)   # Pluralize
_tmpl←{∾𝕗{𝕎𝕩}¨<𝕩} # Template
# Convert characters to numbers, mostly the same as tokens
CharCode←charSet{
  ErrUnknownChars←!⟨"Unknown character"⊸Pl,": ",⊢⟩_tmpl
  Chk ← ⊢⊣ErrUnknownChars∘(≠/⊣)⍟≢⟜(⊏⟜𝕗)
  g←⍋𝕗 ⋄ ⊢ Chk g⊏˜1-˜1⌈(g⊏𝕗)⍋⊢
}
swap_undo←CharCode∊⟜mod1⊸/"˜⁼"

vd←1+vi←⊑bN  # Start of identifier numbering (plus dot)
charRole←4∾˜∾⥊¨˜⟜(≠↑cgl˙)⟨1,2,3,¯1,¯1,¯3,¯1‿0,¯2,0,¬/5‿6⟩ # For first vd chars
T←⌈`× ⋄ IT←↕∘≠⊸T ⋄ I1T←(1+↕∘≠)⊸T
PN←1(∾/∾˜)(∨/⊣)  # Partitioned-none: partitions where 𝕨<𝕩 is never 1

# Source to ⟨tokens, roles, number of identifiers, literals⟩
# Identifiers then literal tokens are numbered starting at vi
Tokenize←{System‿vars←𝕨
  # Resolve comments and strings
  c←𝕩='#'⋄s←/0‿0⊸«⊸∧sm←𝕩='''⋄d←/dm←𝕩='"'
  g←⍋q←∾⟨  s⋄¯1↓d⋄/c⟩ ⋄q↩g⊏q                # Open indices
  e← g⊏∾⟨2+s⋄ 1↓d⋄-⟜»∘⊏⟜(0∾+`c)⊸//(𝕩=lf)∾1⟩ # Matching close indices
  Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟(0=¯1⊑⊢)       # Mark reachable openings
  St←(≠𝕩)↑·/⁼((≠↑∾⟜≠Se 1∾0¨)q⍋e)⊸/          # All indices → reached mask
  a←St q⋄b←St e⋄f←1≠`ab←a∨b                 # Open/close masks; filter
  {!⟨⊑/𝕩,"Unclosed quote"⟩}⍟(∨´)(sm∨dm)∧b<f

  # Extract character and string literals
  u←f∧𝕩='@'⋄ci←/u∨»a∧sm
  chr←(⊏⟜𝕩-('@'-@)×⊏⟜u)ci                   # Characters (indices ci)
  f>↩qe←dm∧«a∧↩dm                           # Quote Escape ""
  str←𝕩⊔˜1-˜(si←a>»qe)(⊣+`⊸×○(∾⟜1)<)≠`dm∧ab # Strings (indices /si)

  # Extract words: identifiers and numbers
  ie←/f⋄is←ie≠⊸↑/1»f                        # Token start and end
  is-↩is(-×⊏⟜c)ie                           # Comment → ending newline only
  t←CharCode ie⊏𝕩
  nd←(t=⊑bN)>«t M bD⋄rr←t=bR                # Namespace dot; 𝕣
  w←»⊸<l←rr∨nd<t M bN(⊣⋈-˜)○⊑bW             # Word chars l, start w
  us←t=¯1++´bA⋄sy←t=⊑bW                     # Underscore, system dot
  {!⟨/us∧w+`⊸⊏0∾𝕩,"Words can't only have underscores"⟩}⍟(∨´)w(/<1(⊢/«)(∨/⊣))l>us
  wk←(¬w/rr)×na⌊∘÷˜(⊑bA)-˜w/t               # Kind of word from first char
  t-↩na×l∧t≥na+⊑bA                          # Case-insensitive
  {!⟨𝕩/is,"System dot with no name"⟩}⍟(∨´)sy>«l
  w≠↩»⊸∨sy                                  # Start system word at dot
  wi←0<wt←(2×wk≥0)(×⟜¬+⊢)w/sy               # Type: 0 number, 1 system, 2 identifier
  i←l>n←l∧(+`w)⊏0∾¬wi                       # Identifier/Number masks
  num←is ReadNums○(((0∾us)<∨⟜«0∾n)/0⊸∾) t×l # Numbers
  ir←(us/˜«⊸<i)(⊢+∧⟜(2⊸=))wi/wk             # Identifier role
  if←(»⌈`)⊸<ig←(i>us)×+`w>n                 # Identifier groups and first character
  fr←(1=wi/wt)<if/rr                        # Identifier is 𝕣-based
  w↩if∨n∧w0←w⋄ws←1=0⊸<⊸/wt/˜↩¬w/rr          # Don't produce an identifier for 𝕣
  {!⟨𝕩/is,"𝕣 can't be used with other word characters"⟩}⍟(∨´)(i>us)∧(rr⊸≠∨if⊸<)ig⊏0∾fr
  {!⟨is⊏˜𝕩/𝕨,"Numbers can't start with underscores"⟩}⍟(∨´⊢)⟜(ws<(⊑bA)>⊏⟜t)/rr<if
  ig⊏↩1-˜0∾+`⊸×¬fr
  id←vars⊸∾⌾⊑(ws∾2)⊔ig⊔t⊏charSet            # ⟨Identifiers, system values⟩

  # Deduplicate literals and identifiers; other cleanup
  ki←(wt⍒⊸⊏/w>rr)∾(ci∾/si)⊏+`»f             # Indices in t
  k←id∾num‿chr‿str⋄k(⊢>¯1»⌈`)⊸/¨˜↩j←⊐¨k     # IDs j into uniques k
  k↩System⌾(1⊸⊑)k                           # System value lookup
  wf←¬l∨t M bW⋄is/˜↩wf∨w0⋄ie/˜↩wf∨>⟜«l      # Index management for...
  t↩(w∨wf)/(vars≠⊸↓∾j++`vd»kk←≠¨k)⌾(ki⊸⊏)t  # Add IDs; remove words/whitespace
  t-↩t(M×-⟜⊑)bS                             # Separators are equivalent
  p←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)t=sep               # Separator group boundaries (excludes leading and trailing)
  sk←sb/˜p>∨⟜«(M⟜bH∨(3‿5+⊑bB)∊˜p⊸+)(sb-p)⊏t # Keep the first of each group that's not just inside a bracket
  t{is/˜↩𝕨⋄ie/˜↩𝕨⋄𝕨/𝕩}˜↩1¨⌾(sk⊸⊏)t≠sep      # Remove the rest
  im←(t=bR)∨t M vd⋈+´2↑kk                   # Identifier (or 𝕣) mask
  r←ir⌾(im⊸/)(vd⌊t)⊏charRole∾0              # Role
  t+↩(⊑bX)((⊢M⋈⟜5)×5+3⊸+⊸≤)t                # Case-insensitive special names
  t-↩vi(<+10×=)t                            # Shift . to bX and variables back one
  ⟨t,r,k,is,ie⟩
}

# 𝕩 is a list of tokens that contains the numeric literals, each
# preceded by 0. Return the numbers.
ReadNums←{
  _err_←{(!/⟜𝔾⋈𝔽)⍟(∨´)}
  EChars←⟨"Letter"⊸Pl," """,⊏⟜charSet,""" not allowed in numbers"⟩_tmpl
  e‿d‿n‿p‿i←=⟜𝕩¨((⊑bA)+-´"ea")∾+⟜↕´bN       # Masks for e.¯π∞
  EChars∘(/⟜𝕩)_err_𝕨 (𝕩=bR)∨¬e∨𝕩<⊑bA
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


Parse ← {r‿vn‿i‿e‿def←𝕨⋄nv←≠vn
  ErrMismatchedBrackets←{
    Lcs ← ∧○(0<≠)◶⟨0, ¯1 ⊑ 0¨∘⊢ {𝕩⌈⌈`𝕨+»𝕩}˝ =⌜⟜⌽⟩
    _mis_ ← {"Missing "∾𝕗∾" "∾charSet⊏˜𝕘+⊢/˜≠∘⊣=⊒}
    Msg ← >○≠◶⟨"opening"_mis_ 0, "closing"_mis_ 1˜⟩
    ! 𝕨 (Lcs<⌊○≠)◶⟨Msg,"Malformed bracket nesting"⟩ 𝕩
  }
  _err_←{(!(∧∘⍉(i≍e˙)⊏⎉1˜/⟜𝔾)⋈𝔽)⍟(∨´⍟=)}

  # Bracket and ligature validation and handling
  # Open brackets have role ¯1 and closed ones have role 0
  "Empty program" ! 0<≠𝕩
  g←⍋pd←+`p←(¯1-2×r)×𝕩 M bB⋄gb←g⊏r=¯1       # Paren (actually any bracket type) depth and grade
  (g⊏p)(>⟜0⊸/ErrMismatchedBrackets⍟≢1-˜<⟜0⊸/)gx←g⊏𝕩
  "Swapped open and closed brackets" ! 0≤(⊑g)⊑pd
  "Parentheses can't contain separators"_err_(gb/G) ((⊑bB)⊸=»⊸∧pred⊸=∨sep⊸=)gbx←gb/gx
  "Predicates can't be placed inside lists"_err_((sep≠GBX)/gb/G) ((4+⊑bB)⊸=»⊸∧pred⊸=)sep⊸≠⊸/gbx
  {"Empty statement or expression"_err_(𝕩/0∾G) (4+⊑bB)≠𝕩/0∾gx}1⊸«⊸∧1∾gb
  dl←«⊸∨dc←r=4                              # Dot left
  r-↩(𝕩=⊑bG)>ec←«dc<0≤r+p                   # Role ¯4 for exports: ⊑bG is ⇐
  "Invalid assignment or stranding use"_err_(↕≠) ((¯4⊸<∧≤⟜¯2)r)>(ec∨𝕩=2+⊑bG)∧»dc<0≤r
  "Can't use export statement as predicate"_err_(↕≠) (»¯4=r)∧𝕩=pred
  "Dot must be followed by a name"_err_(↕≠) dc>«𝕩 M vi‿nv
  sr←»⌾(((⍋⊏⟜dl)⊸⊏g)⊸⊏)sl←«⊸∨r=¯2⋄ns←¬sl∨sr # Strand right and left; not stranded
  cp←𝕩=1+⊑bB                                # Closed paren
  nr←(IT¬cp)⊏(𝕩=2+⊑bI)+2×𝕩=⊑bO              # Nothingness role: 1 for 𝕨, 2 for ·
  nx←0 ⋄ nei←↕≠nr ⋄ _nerr←{𝕗 _err_ nei 2=nx⌈↩𝕩}
  g⊏˜↩⍋g⊏sdl←sl∨dl                          # Avoid reordering strands and dots in rev
  rp←≠⊸»⌾(g⊸⊏)↕≠r                           # Position of previous, for roles
  # Permutation to reverse each expression: *more* complicated than it looks
  rev←⍋+`¯1↓(¯1∾g)(⊣⍋⊸⊏⊏˜⟜⍋¬⊏˜)⍋+`⊸+1∾g⊏sdl∨r=¯1
  gf←⍋fd←+`br←rev⊏p×𝕩M⟨2+⊑bB,2⟩             # Order by brace depth fd to de-nest blocks
  rev⊏˜↩gf⋄fd⊏˜↩gf⋄br⊏˜↩gf
  𝕩⊏˜↩rev⋄dc⊏˜↩rev⋄i⊏˜↩rev⋄e⊏˜↩rev

  # Compute parsing ordering gr≡g⊏rev
  g↩⍋+`p↩br-˜rev⊏p⋄g⊏˜↩⍋g⊏«⊸∨dc⋄gr←g⊏rev    # Order by non-brace bracket depth, then dots
  sll←1+2÷˜0(<-○/>)gr⊏sr-sl⋄l←/g⊏𝕩=5+⊑bB    # Strand length; list starts
  b←br>0⋄c←/br<0                            # Block Begin (mask) and Close (index), in matching order
  bp←⟨/b,c⟩∾¨0(<≍○(</⟜g)>)g⊏p               # Bracket pairs
  g⊏˜↩gs←⍋gr⊏sl⋄gr↩g⊏rev⋄gi←⍋g              # Send strand prefixes *‿ to the end

  # Headers
  hh←𝕩=⊑bH⋄cs←𝕩=1+⊑bH⋄qm←𝕩=pred             # Case header : and separator ; and predicate ?
  "Punctuation : ; ? not allowed outside blocks"_err_(↕≠) (∨`b)<hh∨cs∨qm
  fi←+`cb←b∨cs⋄H←cb¬∘PN⊢                    # Body index fi; which bodies Have a property
  cq←(H qm)∨ch←H hh                         # ch: body has : header ; cq: or ? predicate
  cf←1∾¬co←cb/cs⋄cm←0∾∨⟜«co                 # cf: body is first; cm: body is one of multiple
  "Header-less bodies must come last"_err_(/CB) 1(-⊸↓<co∧↓)cq
  "At most two header-less bodies allowed"_err_(/CB) »⊸∧co>¯1↓cq
  cc←(⍋⍋«co)⊏c∾/cs                          # Case close
  hi←/hf←hh⊏˜⟜IT⌾((⌽g)⊸⊏)cb∨hh              # Header component indices
  un←0=us←swap_undo(≠∘⊣-⊐)hi⊏𝕩
  "Invalid Undo header syntax"_err_(HI) un<(»⊸≥∨(1»un)∧2⊸=)us
  ut←un/»us⋄hi/˜↩0=us                       # Undo type: 0 normal, 1 ⁼, 2 ˜⁼
  hr←(⊏⟜ns×⊏⟜r)rev⊏˜hi                      # Header component roles
  hl←2=hn←(1⊸»+«)hc←¯1=hr                   # hl: is label, hc: is :
  "Only one header per body allowed"_err_(hc/HI) (1+hc/hi)⊏hf
  ho←(»∨·«(hr=3)∧⊢)hl<hy←2≤hr               # Header operands
  "Missing operand in header"_err_(HI) (ut∧hr=3)∨ho∧hc∨hy
  hm←¬ho∨ha←ho<(0=hr)∧1=hn                  # Mask for main name; header arguments
  "Invalid header structure"_err_(hm/HI) 1⊸»⊸=hm/hc
  hk←3|1-˜(+`bI∾nv)⍋ht←hi⊏𝕩×¬rev⊏sr         # Kind: 0 special, 1 name, 2 compound
  hma←hm>hla←hl∧(0=hr)∧1≠hk⋄hr+↩hla⋄hl>↩hla # Lone non-name subject is 𝕩 with 𝕊 omitted
  hv←(hla+ha×1+«hc)+(ho×4+«3=hr)+hma×3×1-˜2⌊hr # Special name for position
  "Incorrect special name"_err_(HI) (0=hk)∧ht≠hv+⊑bI
  hk×↩¬hc∨hl∧0=hr                           # Treat subject labels like special names
  hm>↩hc⋄hr/˜↩hm⋄hx←(1»hc)/ha               # Header-derived role hr and immediacy ¬hx
  ut-↩-⟜»ut×ho                              # Shift ⁼ from right operand to main name
  "Invalid Undo header syntax"_err_(HI) hm<×ut
  "Header left argument without right"_err_(HI) ha>hc+`⊸⊏hx∾0
  "Header operation must be a plain name"_err_(HI) hma>hk≠2
  ut/˜↩hm⋄hx∨↩1=hr
  "Header with ⁼ must take arguments"_err_(hm/HI) hx<×ut
  cwh←hc/»hl⌈ha×1+he←0≠hk                   # Body 𝕨 for just headers
  "Header with ˜⁼ must have left argument"_err_(HI) (0=cwh)∧ut2←2=ut
  cw←(cwh⌈2×ut2)⌾(ch⊸/)1+-⟜«(»cq)<1(⊢<«)cf  # Body 𝕨: 0 no, 1 allowed, 2 required
  hl/˜↩hm⋄hu←(¬he)⌾(hi⊸⊏)hf                 # hu: mask of header special names
  hj←gi⊏˜he/hi⋄hd←2=he/hk                   # hj: header assignments; hd: which ones destructure

  # Block properties
  ss←0‿3‿5‿6⍋(⊢+(0<hk)×hv⊸-)⌾(hi⊸⊏)𝕩-⊑bI    # Special name
  ss+↩(rev⊏r=3)∧𝕩=3+⊑bI                     # Treat _𝕣_ as 3, like 𝕘
  HS←(¯1+`cf)⊏b¬∘PN=⟜ss⋄sp←/hu<𝕩 M bI       # Has-special (𝕤𝕩𝕨/𝕣𝕗/𝕘); indices of specials
  fx←HS 1⋄fr←(fx∨0⊸<)⊸+ft←2(⊣⌈2×⊢)○HS 3     # Body immediacy ¬fx, type ft, role fr
  "Block header type conflict"_err_(ch/0∾/∘CB) (hr<ch/fr)∨hl<hx<ch/fx
  ft⌈↩1-˜fr↩hr⌾(ch⊸/)fr⋄fx↩hx⊸⌈⌾(ch⊸/)fx
  "Special name outside of any block"_err_(/{(0=fi)∧𝕩 M bI}∘𝕩) 0<⊑fr
  "Unreachable body"_err_(/CB) 1↓(»⊸∨(¬hl)⌾(ch⊸/)cq)<cm>fx
  fsc←(ft⊏0‿2‿3)+3×fx                       # Special name count
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
  "Dot must be preceded by a subject"_err_(⍋∘rev) (r=4)>»r=0
  r(×⟜¬-⊢)↩dl                               # Namespace and dot to ¯1

  # Prep for lexical resolution before reordering 𝕩
  xv←𝕩-vi
  {i↩(𝕨⊏i)⌾(𝕩⊸⊏)i⋄e↩(𝕩⊏e)⌾(𝕨⊸⊏)e}´bp        # Highlight all contents of a pair when error reporting
  𝕩⊏˜↩g⋄hg←g⊏hf⋄r⊏˜↩gr⋄ir⊏˜↩gr⋄l↩(l⊏⍋gs)∾/gr⊏sr>sl

  # Parsing part 1
  a←(¯5⊸<∧≤⟜¯3)r⋄ps←a<r<0                   # a: assignment, ps: part separator
  tr←1≤er←ir⊏˜IT»ps                         # er: expression role; tr: train or modifier expression
  no←0⌈-ir⋄ne←0⌈-er⋄nei↩g⋄nx⊏˜↩gr           # Nothing value; expression
  "Nothing (·) cannot be assigned"_nerr ne×a
  "Can't use Nothing (·) as predicate"_nerr ne×𝕩=pred
  oa←⌽/hg<op←(er<2)∧r≥2⋄ro←op∨«op∧m2←r=3    # op: active modifiers; ro: mod or right operand
  "Missing operand"_nerr op×2(«⌈m2×»)no⌈2×m2≥ro∨r∊↕2
  s←𝕩=sep⋄fo←𝕩∊⟨2+⊑bB,1+⊑bH⟩                # Separators, function open { or ;
  ls←s∧fo<○IT lo←𝕩=4+⊑bB                    # List Separators: after ⟨lo, not {fo
  "Double subjects (missing ‿?)"_err_(G) ∧⟜«ro»⊸∨⊸<r=0
  mm←𝕩=2+⊑bG⋄ma←tr<mm∧«ir≥1⋄mm∧↩1»ps        # Modified assignment; monadic modified
  "No right-hand side in non-modified assignment"_err_(G) ma<mm
  os←↕∘≠⊸(⊣-T)⌾⌽¬ro∨ma                      # Operator skip: distance rightward to derived function start
  at←1+⊏⟜os⊸+ai←/a⋄af←¯4≠ai⊏r⋄ar←at⊏r       # Assignment target; af for actual (non-export) assignment
  "Role of the two sides in assignment must match"_err_(at⊏G) af∧ar≠0⌈at⊏er
  ak←af+(0≤ar)+(ai⊏ma)+(⊑bG)-˜ai⊏𝕩          # Class of assignment: 1⇐ 2⇐? 3←? 4↩? 5+↩?
  at∾↩hj⋄ac←«⊸-(ak∾6¨hj)⌾(at⊸⊏)0¨𝕩          # Header assignment is 6 temporarily
  aa←×gac←g⊏ac↩»+`(1⊸»⊸∨0=+`)⊸×gi⊏ac        # Broadcast ac to the entire target
  api←/(𝕩=⊑bO)∧ap←aa∧2=no                   # Assignment placeholder
  "Can't use Nothing (·) in lists"_nerr (¬ap)×no×(gr⊏¬ns)∨»lo∨ls
  ac-↩3×ah←6=ac                             # Assignment is header; 6→3
  nx⌈↩aa×1=no                               # Prevent assignment to 𝕨 if it's ·
  nf←H ac<xv=vi-˜⊑bG                        # Namespace bodies
  fw←H gi⊏nx                                # Bodies where 𝕨 must be defined
  {"Can't return Nothing (·)"_err_(𝕩⊏⍋∘Rev) 2=fw⌈↩nf¬⊸×𝕩⊏nr} 1-˜0∾cc⊏rev
  fv←fw⋄fw≥○I1T↩cf                          # If a body fails on 𝕨, later ones won't see 𝕨
  (∨´(1↓fv)⊸<)◶"Invalid use of 𝕨 in monadic case"‿"Unreachable body"_err_(/CB) 1↓fw∧cw=0
  cw⌈↩2×fw⋄cw×↩fx
  nn←g⊏fi⊏2=cw⋄no(⊣-=)↩nn⋄ne(⊣-=)↩nn        # 2=cw indicates 𝕨 is never Nothing
  aid←(¯6⊸≤∧<⟜nv)𝕩-vi                       # Assignable identifer
  hq←/hp←(g⊏ah)∧𝕩≥nv+vi                     # Header constant
  atc←(hg<ps<«aa∧r≥0)<aid∨hp∨(ps>«𝕩=⊑bL)∨𝕩(=⟜(3+⊑)<M)bB
  "Assignment target must be a name or list of targets"_err_(G) (a∨atc∨ap)<aa
  "Can't nest assignments (write aliases with ⇐)"_err_(ai⊏G) ((5≠ai⊏gac)∧ak=2)<ai⊏aa
  "Can't use result of function/modifier assignment without parentheses"_err_(G) hg<(0<er)∧(0≤r)∧»⊸>aa
  af>↩alm←ai⊏aa⋄al←alm/ai                   # aliases al
  ai/˜↩af⋄at/˜↩af∾1¨hj

  # Lexical resolution (independent of parsing part 2 below)
  di←/dm←»dc                                # Dots aren't scoped
  id←/(hu∨dm∨gi⊏«aa∧a)<(0⊸≤∧<⟜nv)xv         # Identifier indices in xv
  sa←0<sc←sp⊏ac⋄d←(ic←id⊏ac)M 2‿2           # Which accesses are definitions
  "Can't define special name"_err_(SP) sa∧sc<4
  idf←id⊏fi⋄idv←id⊏xv                       # Function index and name ID
  dp←d∧(0=idf)∧idv<≠def                     # Definitions of vars in def
  "Redefinition"_err_(dp/ID) 0=dpf←(dp/idv)⊏def
  d↩(0≤dpf)⌾(dp⊸/)d⋄zda←0¨da←/def≤0         # Turn def ¯1 ← into ↩
  dn←(dg←zda∾(df←d/idf)∾≠fsc)⊔da∾dv←d/idv   # Identifier name ID, per-block
  # Order every referenced identifier, and an undeclaration for each declaration
  ixf←((1=ic)+idf⊏¯1∾cb/gf)∾df⊏(≠𝕩)∾1-˜cc⊏gf# First order by block index, open for real and closed for virtual
  ig←(⍋⊏⟜(ixx←idv∾dv))⊸⊏⍋ixf                # Then order by name
  {"Redefinition"_err_(𝕩⊏·∾⟜(d⊸/)ID) ¬ixx∨○(»⊸≠𝕩⊸⊏)ixf} (≠d)⊸≤⊸/ig
  ig↩<⟜(≠d)⊸/(⍋ds←+`ig⊏d∾¯1¨dv)⊏ig          # Last order by declaration depth
  d⊏˜↩ig⋄id⊏˜↩ig⋄ic⊏˜↩ig
  du←+´¬»⊸∨0<ds⋄uv←(du↑ig)⊏idv              # Number undefined (always sorted to front)
  ("Undefined identifier"Pl·⍷/⟜uv)_err_(du↑ID) uv≥≠def
  ix←(ic<3)∧ia←0<ic                         # Which are exports, assignments
  idd←(⊢-(uv⊏ded←-0⌈def)∾(du↓IT d)⊸⊏)id⊏fd  # Identifier frame depth
  "Can't export from surrounding scope"_err_(ID) ix∧0<idd
  dx←dg⊔zda∾(dig←⍋d/ig)⊏ixa←d(/≥1↓PN)ix     # Exported identifier mask
  idi←(uv⊸⊏∾(¯1+`du↓d)⊏dig⍋⊸⊏da≠⊸↓⊢)(⊏⟜fsc+⊒)ded∾df # Slot within frame
  uu←(ia<1«d)∧d(⊣+`⊸⊏(1∾ixa)<PN)0<idd       # Unused marker
  spi←((spf←sp⊏fi)⊏3×fx)+3+sp⊏xv            # Special name index
  uu∾↩∊⌾⌽spi+6×spf                          # and unused marker
  idor←∾3‿2‿3/⟨1+g⊏˜hj-1, di, id∾sp⟩        # Identifier bytecode ordering
  ido←32+uu(⊢+2×>)ia∾sa                     # Opcode
  idoc←⟨32¨hj,0¨hj,he/hv
        64¨di,di⊏xv, ido,idd∾0¨sp,idi∾spi⟩  # Identifier bytecode: instruction, depth, slot

  # Parsing part 2
  ta←tr∧2(>∨|)ps(⊢-T)+`¬ro                  # Train argument (first-level)
  fa←/(fe←hg∨ta∨ro∨«⊸∨ps<aa)<ff←(r=1)∨»op   # Active functions: cases fe are excluded
  "Second-level parts of a train must be functions"_err_(G) tr>fe∨ff
  dy←2≠ny←fa⊏2«no⌈2×¬(tr∧r≥0)∨ro<r=0        # Dyadic
  ob←pr⊏/¯1(⊢-»)u←⍷∧pr←𝕩⊏˜pi←/hg<𝕩<sep      # Objects to be loaded
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
  or←⍋oi←idor∾g⊏˜∾⟨cn,cn,bk,bk,hq,api,2/l,at,dr,qp,al+1,al+1,oa+1⌈oa⊏os,fl,rt⟩
  oc←or⊏∾idoc∾⟨0¨cn,ob,1¨bk,1+↕≠bk,43¨hq,44¨api,⥊⍉(11+l⊏aa)≍ll,ao,6¨dr,42¨qp,66¨al,vi-˜(al-1)⊏𝕩
               24+oa⊏r,16+(fn/dy+2×fm⌈1=ny)+4×0<fa⊏er,¯1↓rc←7+nf⟩
  # Instruction source positions
  MI←-⊸↓˜⟜≠∾g⊏˜⊢⋄oj←(rt-∘≠⊸⌽oi⌊1-˜≠i)Mi∾⟨1-˜at,oa,fa⟩
  ind←⟨oj,oj Mi fa⊏IT»¬ro∨ma⟩(¯1∾˜or⊏(≠rt)⊸⌽)⊸⊏¨i‿e
  # Indices for multi-body blocks
  cm∨↩(fx∧1≠cw)∨0<ut↩ut⌾(ch⊸/)ch            # Dyad- and inverse-only generate as multiple
  cj←/cv←1+1=ciw←cw⊏˜ci←/cm                 # Number of copies
  ck←4⌊(2×ci⊏ut)+1<ciw                      # Position
  cg←¯1+`cif←ci⊏cf                          # Which block
  ckt←(2-¬(cf∧cm)/fx)⌈(cif/·⍋⊏⟜cg)⊸⊏∘⍒⊸⊏cv+ck
  ci↩ckt/⊸⊔(¯1(↑∾˜cj(⊒∘⊣+⊏)ck+cg⊏↓)0∾+`ckt)⊔cj⊏ci
  # Output
  fz←⟨cf/ft,cf/¬fx,ci⌾((cf/cm)⊸/)/cf⟩       # Per-function data
  cz←⟨/1∾or≥oc-○≠rt,fsc+≠¨dn,dn,dx⟩         # Per-body data
  ⟨oc∾¯1⊑rc,u,fz,cz,ind⟩                    # Overall output
}

Compile←{
  defaults←⟨⟩‿(!∘"System values not supported"¨)‿⟨⟩‿(↕0)
  prims‿Sys‿vars‿redef ← ∾⟜(≠↓defaults˙) ⋈⍟(4<≠)𝕨
  ⟨tok,role,val,t0,t1⟩←tx←sys‿vars Tokenize 𝕩
  ⟨oc,prim,blk,bdy,oi⟩←⟨role,⊑val,t0,t1,redef»0¨vars⟩ Parse tok
  ⟨oc, ∾⟨prim⊏prims⟩∾1↓val, <˘⍉>blk, <˘⍉>bdy, oi, tx⟩
}
