func‿mod1‿mod2 ← •args
na←¯1⊑≢alph←("aA"+⌜↕26)∾˘"àÀ"+⌜(↕23)∾24+↕7
lf←@+10‿13
charSet‿cgl←(∾ ⋈ ≠¨)⟨
  func                  # Function
  mod1                  # 1-modifier
  mod2                  # 2-modifier
  "⋄,"∾lf               # Separator
  ":;?"                 # Header punctuation
  "⇐←↩"                 # Gets
  "(){}⟨⟩[]"            # Bracket
  "‿"                   # Ligature
  "·"                   # nOthing
  # Use last character in case of UTF-16 (like dzaima/BQN)
  ¯1⊏˘11‿∘⥊"𝕊𝕏𝕎𝔽𝔾𝕤𝕩𝕨𝕣𝕗𝕘"# Input
  ".¯π∞"                # Numeric
  '0'+↕10               # Digit
  "_"∾˜⥊alph            # Alphabetic
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
  FmtChar ← (1<≠)◶⟨"'"⊸(∾∾⊣), 30(⌊⟜≠↑⊢)⟜⍷⍟(<⟜≠)⊢⟩
  ErrUnknownChars←!⟨"Unknown character"⊸Pl,": ",FmtChar⟩_tmpl
  Chk ← ⊢⊣ErrUnknownChars∘(≠/⊣)⍟≢⟜(⊏⟜𝕗)
  (! "Character set conflict: "∾gf/˜0⊸∾)⍟(∨´) 1(↓=-⊸↓)gf←(g←⍋𝕗)⊏𝕗
  ⊢ Chk g⊏˜1-˜1⌈gf⍋⊢
}
swap_undo←CharCode∊⟜mod1⊸/"˜⁼"

vd←1+vi←⊑bN  # Start of identifier numbering (plus dot)
charRole←4∾˜∾⥊¨˜⟜(≠↑cgl˙)⟨1,2,3,¯1,¯1,¯3,¯1‿0,¯2,0,¬/5‿6⟩ # For first vd chars
T←⌈`× ⋄ IT←↕∘≠⊸T ⋄ I1T←(1+↕∘≠)⊸T
PN←1(∾/∾˜)(∨/⊣)  # Partitioned-none: partitions where 𝕨<𝕩 is never 1

# Source to ⟨tokens, roles, values, start indices, end indices⟩
# Values are ⟨names, system values, numbers, characters, strings⟩
# Tokens ≥vi index into ∾values; start/end indices map back to source
Tokenize←{System‿vars←𝕨
  # Resolve comments and strings
  c←𝕩='#'⋄s←/0‿0⊸«⊸∧sm←𝕩='''⋄d←/dm←𝕩='"'
  g←⍋q←∾⟨  s⋄¯1↓d⋄/c⟩ ⋄q↩g⊏q                # Open indices
  e← g⊏∾⟨2+s⋄ 1↓d⋄-⟜»∘⊏⟜(0∾+`c)⊸//(𝕩∊lf)∾1⟩ # Matching close indices
  Se←≠(>/⊢)∾⟜≠{(⊏˜𝕨)𝕊⍟(≠○(¯1⊸⊑))𝕩∾𝕩⊏𝕨}⟨0⟩˙  # Find reachable openings
  St←(≠𝕩)↑·/⁼(Se q⍋e)⊸⊏                     # All indices → reached mask
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
  {!⟨𝕩/is,"𝕣 can only appear as 𝕣, _𝕣, or _𝕣_"⟩}⍟(∨´)rr∧((»<«)us)∨(»∨«)us(<∨∧⟜(»∧«))sy∨l
  {!⟨is/˜us∧w+`⊸⊏0∾𝕩,"Words can't only have underscores"⟩}⍟(∨´)w(/<1(⊢/«)(∨/⊣))l>us
  wk←(¬w/rr)×na⌊∘÷˜(⊑bA)-˜w/t               # Kind of word from first char
  t-↩na×l∧t≥na+⊑bA                          # Case-insensitive
  {!⟨𝕩/is,"System dot with no name"⟩}⍟(∨´)sy>«l
  w≠↩»⊸∨sy                                  # Start system word at dot
  wi←0<wt←(2×wk≥0)(×⟜¬+⊢)w/sy               # Type: 0 number, 1 system, 2 identifier
  i←l>n←l∧(+`w)⊏0∾¬wi                       # Identifier/Number masks
  num←is ReadNums○(((0∾us)<∨⟜«0∾n)/0⊸∾) t×l # Numbers
  ir←(us/˜«⊸<i)(⊢+∧⟜(2⊸=))wi/wk             # Identifier role
  iu←w>n∨fr←rr∨us∧«rr                       # Starts of 𝕣 tokens, and non-𝕣 identifiers
  if←(»⌈`)⊸<ig←(i>us∨rr)×+`iu               # Identifier groups and first character
  wu←if∨n∧w⋄ws←iu/sy                        # Starts of non-𝕣 words; system identifiers
  {!⟨is⊏˜𝕩/𝕨,"Numbers can't start with underscores"⟩}⍟(∨´⊢)⟜(ws<(⊑bA)>⊏⟜t)/if
  id←vars⊸∾⌾⊑(ws∾2)⊔(ig-1)⊔t⊏charSet        # ⟨Identifiers, system values⟩

  # Deduplicate literals and identifiers; other cleanup
  ki←((wt/˜¬w/fr)⍒⊸⊏/wu)∾(ci∾/si)⊏+`»f      # Indices in t
  k←id∾num‿chr‿str⋄k(⊢>¯1»⌈`)⊸/¨˜↩j←⊐¨k     # IDs j into uniques k
  k↩System⌾(1⊸⊑)k                           # System value lookup
  wf←¬l∨t M bW⋄is/˜↩wf∨w⋄ie/˜↩wf∨>⟜«l       # Index management for...
  t↩(vars≠⊸↓∾j++`vd»kk←≠¨k)⌾(ki⊸⊏)t         # Add IDs
  t/˜↩rr∨wu∨wf                              # Remove words/whitespace
  t-↩t(M×-⟜⊑)bS                             # Separators are equivalent
  p←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)t=sep               # Separator group boundaries (excludes leading and trailing)
  eb←3‿5‿7+⊑bB                              # End brackets that allow separators
  sk←sb/˜p>∨⟜«(M⟜bH∨eb∊˜p⊸+)(sb-p)⊏t        # Keep the first of each group that's not just inside a bracket
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
  e‿i‿d‿n‿p‿q←=⟜𝕩¨((⊑bA)+"ei"-'a')∾+⟜↕´bN   # Masks for ei.¯π∞
  EChars∘(/⟜𝕩)_err_𝕨 (𝕩=bR)∨¬e∨i∨𝕩<⊑bA
  s←d∨c←e∨z←i∨0=𝕩⋄m←¬n∨c
  "Negative sign in the middle of a number"_err_𝕨 n>»c
  "Portion of a number is empty"_err_𝕨 (1«s)∧n∨s
  "Ill-formed decimal or exponent use"_err_(s/𝕎) ¬(0⊸=∨»⊸<)s/𝕩×¬i
  "Can't use i more than once in a number"_err_(z/𝕎) »⊸∧z/i
  "π and ∞ must occur alone"_err_𝕨 (p∨q)>1(»∧(p∧«e)∨«)z∨n>»e
  l←(¬(⊢-T)·+`d⊸<)g←(«≤(d<y←𝕩≠⊑bD)>○I1T¬)⊸∧m# No leading 0s
  la←d×(»¬(⊢-T)+`)⌾⌽¬g∨y                    # Adjust dp for dropped 0s after decimal
  k‿dp←d¬⊸(/⋈1⊸»⊸/)○((d∨>⟜«g)⊸/)l-la        # Length, decimal position
  NN←(1«0⊸=)/0(0⊸≤××⟜10⊸+)`⊏⟜(¯1∾π‿1∾↕10)   # Digit lookup has ∞ as 1 to avoid ∞×0
  PN←NN(«⊸>∨d⊸<)/(𝕩-1+⊑bN)⊸×                # Evaluate numbers given mask
  va←(∨´k>15)◶PN‿{                          # Numeric values—mantissas and exponents
    𝕩∧↩20≥l⋄k⌊↩20                           # Cap at 20 digits
    𝕩>↩f←𝕩∧l≤(+`»⊸<𝕩)⊏0∾te←0⌈k-15           # Handle trailing ≤15 normally
    (1e15×PN f)⊸+⌾((te>0)⊸/) PN 𝕩           # Leading part
  } g
  v←va×1‿¯1⊏˜(r←>⟜»m)/»n                    # Negate if ¯
  vm←c/○(1»«)z                              # Mask of mantissas in v
  mn←vm/v×(r/q)⊏1‿∞                         # Mantissa, correcting ∞
  ee←vm/(k-dp)-˜«v×¬vm                      # Power of 10
  a←(0⌈ee)+ee-b←ee⌈¯308                     # Subnormal handling
  u←b÷⟜(10⋆-)˜⌾((0>b)⊸/)a 10⊸⋆⊸×⌾((0≠a)⊸/)mn# mn×10⋆ee
  (z/i)(¬⊸/+¯1√⊸×⊣¬⊸/0«×)⍟(∨´⊣)u
}


Parse ← {r‿nv‿i‿e‿def←𝕨
  ErrMismatchedBrackets←{
    # Horrible stack-based algorithm
    S←⊑⟜𝕩 ⋄ K‿D←{⋈∾¨⟜(𝕏⋈)˜}¨↓‿↑     # Select; Keep; Discard
    Ma←⋈¯1⊸↓⌾⊑ ⋄ DT←¯1‿0⊸(↓¨∾¨·⌽↑¨) # Match; Discard Top
    Upd ← {𝕨(2|S)◶⟨K,(0<≠∘⊑∘⊢)◶⟨D,(1≠-○S⟜(¯1⊑⊑))◶⟨Ma⊢, D∾𝕊⟜DT⟩⟩⟩𝕩}
    i ← ((⊑⊢⊐⌊´)≠¨)⊸⊑ ∾¨ (⋈⋈˜↕0) ((64⌊≠)⊸↑·(∊⊑¨)⊸/·∾Upd¨)´⌽ /𝕩 M bB
    ("Unmatched bracket" Pl i) _err_ i 1
  }
  _err_←{(!(∧∘⍉(i≍e˙)⊏⎉1˜/⟜𝔾)⋈𝔽)⍟(∨´⍟=)}

  # Bracket and ligature validation and handling
  # Open brackets have role ¯1 and closed ones have role 0
  "Empty program" ! 0<≠𝕩
  g←⍋pd←+`p←(¯1-2×r)×𝕩 M bB⋄gb←g⊏r=¯1       # Paren (actually any bracket type) depth and grade
  ErrMismatchedBrackets∘𝕩⍟¬ (gp←g⊏p)(>⟜0⊸/≡1-˜<⟜0⊸/)gx←g⊏𝕩
  "Swapped open and closed brackets"_err_(1↑G) 0>(⊑g)⊑pd
  "Parentheses can't contain separators"_err_(gb/G) ((⊑bB)⊸=»⊸∧sep⊸=)gb/gx
  bt←(1=gp)(+`∘⊣⊏2∾(2+⊑bB)=/)gx             # Surrounding bracket type: 1 block, 2 none
  "Punctuation : ; ? outside block top level"_err_(G) (1=bt)<gx M bH
  {"Empty statement or expression"_err_(𝕩/0∾G) (4+⊑bB)>𝕩/0∾gx}1⊸«⊸∧1∾gb
  dl←«⊸∨dc←r=4                              # Dot left
  r-↩(𝕩=⊑bG)>(»r≤¯2)∨ec←«dc<0≤r+p           # Role ¯4 for exports: ⊑bG is ⇐
  "Invalid assignment or stranding use"_err_(↕≠) ((¯4⊸<∧≤⟜¯2)r)>(ec∨𝕩=2+⊑bG)∧»dc<0≤r
  "Can't use export statement as expression"_err_(G) (0<bt)<g⊏¯4=r
  "Can't use export statement as predicate"_err_(↕≠) (»¯4=r)∧𝕩=pred
  "Dot must be followed by a name (or digit to form a number)"_err_(↕≠) dc>«𝕩 M vi‿nv
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
  BE←=∨+⟜2⊸=                                # Bracket equals: match ⟨[ or ⟩] given ⟨ or ⟩ only
  g↩⍋+`p↩br-˜rev⊏p⋄bp←0(<⋈○(/⟜g)>)g⊏p       # Order by non-brace bracket depth
  g⊏˜↩⍋g⊏«⊸∨dc⋄gr←g⊏rev                     # Now by dots
  sll←1+2÷˜0(<-○/>)gr⊏sr-sl⋄l←/g⊏𝕩BE˜5+⊑bB  # Strand length; list starts
  b←br>0⋄c←/br<0⋄bp∾¨↩⟨/b,c⟩                # Block Begin (mask) and Close (index), in matching order
  g⊏˜↩gs←⍋gr⊏sl⋄gr↩g⊏rev⋄gi←⍋g              # Send strand prefixes *‿ to the end

  # Headers
  hh←𝕩=⊑bH⋄cs←𝕩=1+⊑bH                       # Case header : and separator ;
  fi←+`cb←b∨cs⋄H←cb¬∘PN⊢                    # Body index fi; which bodies Have a property
  ca←(cq←H𝕩=pred)∨ch←H hh                   # ch: body has : header ; ca: or ? predicate
  cf←1∾¬co←cb/cs⋄cm←0∾∨⟜«co                 # cf: body is first; cm: body is one of multiple
  "Header-less bodies must come last"_err_(/CB) 1(-⊸↓<co∧↓)ca
  "At most two header-less bodies allowed"_err_(/CB) »⊸∧co>¯1↓ca
  cc←(⍋⍋«co)⊏c∾/cs                          # Case close
  hiu←/hf←hh⊏˜⟜IT⌾((⌽g)⊸⊏)cb∨hh             # Header component indices
  un←0=us←swap_undo(≠∘⊣-⊐)hiu⊏𝕩
  ut←un/»us⋄hi←un/hiu                       # Undo type: 0 normal, 1 ⁼, 2 ˜⁼
  hr←(⊏⟜ns×⊏⟜r)rev⊏˜hi                      # Header component roles
  hl←2=hn←(1⊸»+«)hc←¯1=hr                   # hl: is label, hc: is :
  "Only one header per body allowed"_err_(hc/HI) (g⊏˜1+gi⊏˜hc/hi)⊏hf
  "Invalid Undo header syntax"_err_(HIU) un<(»⊸≥∨(1»un)∧2⊸=)us
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
  "Invalid Undo header syntax"_err_(HI) hm<0<ut
  "Header left argument without right"_err_(HI) ha>hc+`⊸⊏hx∾0
  "Header operation must be a plain name"_err_(HI) hma>hk≠2
  ut/˜↩hm⋄hx∨↩1=hr
  "Header with ⁼ must take arguments"_err_(hm/HI) hx<0<ut
  cwh←hc/»hl⌈ha×1+he←0≠hk                   # Body 𝕨 for just headers
  "Header with ˜⁼ must have left argument"_err_(hm/HI) (0=cwh)∧ut2←2=ut
  cw←(cwh⌈2×ut2)⌾(ch⊸/)1+-⟜«(»ca)<1(⊢<«)cf  # Body 𝕨: 0 no, 1 allowed, 2 required
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
  "Unreachable body"_err_(/CB) 1↓(»⊸∨hl⊸≤⌾(ch⊸/)cq)<cm>fx
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
  Nei↩⍋∘rev⋄"Dot must be preceded by a subject"_nerr (r=4)∧2»nr⌈2×r≠0
  r(×⟜¬-⊢)↩dl                               # Namespace and dot to ¯1

  # Reorder for parsing
  xv←𝕩-vi                                   # Save for lexical resolution
  {i↩(𝕨⊏i)⌾(𝕩⊸⊏)i⋄e↩(𝕩⊏e)⌾(𝕨⊸⊏)e}´bp        # Highlight all contents of a pair when error reporting
  𝕩⊏˜↩g⋄hg←g⊏hf⋄r⊏˜↩gr⋄ns⊏˜↩gr⋄ir⊏˜↩gr
  l↩(l0←l⊏⍋gs)∾/gr⊏sr>sl                    # Indices of list literals
  lm←(0¨sll)∾˜(5+⊑bB)-˜l0⊏𝕩                 # List merge, adding 2 for []

  # Parsing part 1
  a←(¯5⊸<∧≤⟜¯3)r⋄am←𝕩=2+⊑bG⋄ps←a<r<0        # a: assignment; am: modify; ps: part separator
  tr←1≤er←ir⊏˜IT»ps                         # er: expression role; tr: train or modifier expression
  no←0⌈-ir⋄ne←0⌈-er⋄nei↩g⋄nx⊏˜↩gr           # Nothing value; expression
  "Nothing (·) cannot be assigned"_nerr ne×a
  "Can't use Nothing (·) as predicate"_nerr ne×𝕩=pred
  "Invalid 2-modifier use or modifier assignment"_err_(G) »⊸∧(er<2)<r≥0
  oa←⌽/oe←hg<op←(»am<a)<(er<2)∧r≥2          # op: active modifiers; oa: applied
  ro←op∨«op∧m2←r=3                          # ro: mod or right operand; m2: 2-modifier
  "Missing operand"_nerr oe×2(«⌈m2×»)no⌈2×m2≥ro∨r∊↕2
  s←𝕩=sep⋄fo←𝕩∊⟨2+⊑bB,1+⊑bH⟩                # Separators, function open { or ;
  ls←s∧fo<○IT lo←𝕩BE˜4+⊑bB                  # List Separators: after ⟨lo, not {fo
  "Double subjects (missing ‿?)"_err_(G) ∧⟜«ro»⊸∨⊸<r=0
  "Can't use export statement as expression"_err_(G) ps<0‿0»¯4=r
  ma←tr<am∧«ir≥1⋄mm←am∧1»ps        # Modified assignment; monadic modified
  "No right-hand side in non-modified assignment"_err_(G) ma<mm
  os←↕∘≠⊸(⊣-T)⌾⌽¬ro∨ma                      # Operator skip: distance rightward to derived function start
  at←1+⊏⟜os⊸+ai←/a                          # Assignment target
  "Assignment role mismatch or missing modified assignment target"_err_(at-⟜1⊸⊏G) at⊏ps∾1
  af←¯4≠ai⊏r⋄ar←at⊏r                        # af for actual (non-export) assignment; assignment role
  "Role of the two sides in assignment must match"_err_(at⊏G) af∧ar≠0⌈at⊏er
  ak←af+(0≤ar)+(ai⊏ma)+(⊑bG)-˜ai⊏𝕩          # Class of assignment: 1⇐ 2⇐? 3←? 4↩? 5+↩?
  at∾↩hj⋄ac←«⊸-(ak∾6¨hj)⌾(at⊸⊏)0¨𝕩          # Header assignment is 6 temporarily
  aa←0<gac←g⊏ac↩»+`(1⊸»⊸∨0=+`)⊸×gi⊏ac       # Broadcast ac to the entire target
  mat←5=gac                                 # Modified assignment target
  api←/(𝕩=⊑bO)∧ap←aa∧2=no                   # Assignment placeholder
  "Can't use Nothing (·) in lists"_nerr no×ap<ns≤»lo∨ls
  "Can't modify Nothing (·)"_err_(G) mat∧ap
  "Square brackets can't be empty"_err_(G) (mat<aa)<(𝕩=6+⊑bB)∧1«ps
  ac-↩3×6=ac⋄ah←6=gac                       # Assignment is header; 6→3
  nx⌈↩aa×1=no                               # Prevent assignment to 𝕨 if it's ·
  nf←H ac<xv=vi-˜⊑bG                        # Namespace bodies
  fw←H gi⊏nx                                # Bodies where 𝕨 must be defined
  {"Can't return Nothing (·)"_err_(𝕩⊏⍋∘Rev) 2=fw⌈↩nf¬⊸×𝕩⊏nr} 1-˜0∾cc⊏rev
  fv←fw⋄fw∨↩cf≤○I1T(cw=1)∧fw                # If a body fails without 𝕨, later ones won't be called without 𝕨
  (∨´(1↓fv)⊸<)◶"Invalid use of 𝕨 in monadic case"‿"Unreachable body"_err_(/CB) 1↓fw∧cw=0
  cw⌈↩2×fw⋄cw×↩fx
  nn←g⊏fi⊏2=cw⋄no(⊣-=)↩nn⋄ne(⊣-=)↩nn        # 2=cw indicates 𝕨 is never Nothing
  aid←(¯6⊸≤∧<⟜nv)𝕩-vi                       # Assignable identifer
  hq←/hp←ah∧𝕩≥nv+vi                         # Header constant
  atc←(hg<ps<«aa∧r≥0)<aid∨hp∨(ps>«𝕩=⊑bL)∨𝕩(=⟜(3+⊑)<M)bB
  "Assignment target must be a name or list of targets"_err_(G) aa>((g⊏dc)∨ro>ah∨op)<a∨atc∨ap
  "Can't nest assignments (write aliases with ⇐)"_err_(ai⊏G) ((ai⊏mat)<ak=2)<ai⊏aa
  "Can't use result of function/modifier assignment without parentheses"_err_(G) hg<(0<er)∧(0≤r)∧»⊸>aa
  af>↩alm←ai⊏aa⋄al←alm/ai                   # aliases al
  "Alias must have a name on the right and appear within ⟨⟩"_err_(al⊏G) ¬(al-1)⊏aid∧ns∧»ls∨𝕩=4+⊑bB
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
  idi←((0¨ded)∾df⊏fsc)+⊒ded∾df              # Slot within frame
  idi↩(uv⊸⊏∾(¯1+`du↓d)⊏dig⍋⊸⊏da≠⊸↓⊢)idi
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
  or←⍋oi←idor∾g⊏˜∾oil←⟨cn,cn,bk,bk,hq,api,2/l,at,qp,al+1,al+1,oa+1⌈oa⊏os,fl,dr,rt⟩
  oc←or⊏∾idoc∾⟨0¨cn,ob,1¨bk,1+↕≠bk,43¨hq,44¨api,⥊⍉(11+lm+l⊏aa)≍ll,ao,42¨qp,66¨al,vi-˜(al-1)⊏𝕩
               24+oa⊏r,16+(fn/dy+2×fm⌈1=ny)+4×0<fa⊏er,6¨dr,¯1↓rc←7+nf⟩
  # Instruction source positions
  ui←8‿12‿13(⊏⟜(0»+`)+⟜↕¨⊏)(≠idor)∾≠¨oil    # at,oa+…,fl locations
  oj←(∾1⊸+⌾(2⊸⊑)⊏⟜g¨⟨at-1‿0/˜≠¨ai‿hj,oa,fa-1⟩)⌾((∾ui)⊸⊏)oi
  ind←⟨oj,(g⊏˜fa⊏IT»¬ro∨ma)⌾((¯1⊑ui)⊸⊏)oj⟩(¯1∾˜or⊸⊏)⊸⊏¨i‿e
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
  ⟨oc,prim,blk,bdy,oi⟩←⟨role,≠⊑val,t0,t1,redef»0¨vars⟩ Parse tok
  ⟨oc, ∾⟨prim⊏prims⟩∾1↓val, <˘⍉>blk, <˘⍉>bdy, oi, tx⟩
}
