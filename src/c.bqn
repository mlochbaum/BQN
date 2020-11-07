lf←@+10
charSet‿cgl←(∾ ≍○< ≠¨)⟨
  "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!" # Function
  "˙˜˘¨⌜⁼´˝`"           # 1-modifier
  "∘○⊸⟜⌾⊘◶⎉⚇⍟"          # 2-modifier
  "⋄,"∾lf               # Separator
  "⇐←↩"                 # Gets
  "(){}⟨⟩"              # Bracket
  "‿"                   # Ligature
  "·"                   # nOthing
  # Use last character in case of UTF-16 (like dzaima/BQN)
  ¯1⊏˘10‿∘⥊"𝕊𝕏𝕎𝔽𝔾𝕤𝕩𝕨𝕗𝕘" # Input (𝕣 pending; ℝ not allowed)
  '0'+↕10               # Digit
  "π∞¯."                # Numeric
  "_"∾˜⥊"aA"+⌜↕na←26    # Alphabetic
  (¯1↓"𝕨")∾" "∾@+9      # Whitespace (or special name prefix in UTF-16)
  "#'""@"               # Preprocessed characters
⟩
bF‿b1‿b2‿bS‿bG‿bB‿bL‿bO‿bI‿bD‿bN‿bA‿bW‿bP←≍¨˜⟜(+`»)cgl
M←1⊸⊑(0⊸≤∧>)-⟜⊑   # ∊ for an init,length pair 𝕩 as above
sep←⊑bS
Pl←∾⟜("s"/˜1<≠)   # Pluralize
_tmpl←{∾𝕗{𝕎𝕩}¨<𝕩} # Template
# Convert characters to numbers, mostly the same as tokens
CharCode←charSet{
  ErrUnknownChars←0!˜⟨"Unknown character"⊸Pl,": ",⊢⟩_tmpl
  Chk ← ⊢⊣ErrUnknownChars∘(≠/⊣)⍟≢⟜(⊏⟜𝕗)
  g←⍋𝕗 ⋄ ⊢ Chk g⊏˜1-˜1⌈(g⊏𝕗)⍋⊢
}

vi←⊑bD  # Start of identifier numbering
charRole←∾⥊¨˜⟜(≠↑cgl˙)⟨1,2,3,¯1,¯3,¯1‿0,¯2,0,5/⌽↕2⟩ # For first vi chars
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
  a←St q⋄b←St e⋄f←¬≠`ab←a∨b                 # Open/close masks; filter
  {⟨⊑/𝕩,"Unclosed quote"⟩!0}⍟(∨´)(sm∨dm)∧b<f

  # Extract character and string literals
  u←f∧𝕩='@'⋄ci←/u∨»a∧sm
  chr←(⊏⟜𝕩-('@'-@)×⊏⟜u)ci                   # Characters (indices ci)
  f>↩qe←dm∧«a∧↩dm                           # Quote Escape ""
  str←1↓¨𝕩⊔˜1-˜(+`si←a>»qe)×≠`dm∧ab         # Strings (indices /si)

  # Extract words: identifiers and numbers
  ie←/f⋄is←ie≠⊸↑/1»f⋄Fs←{is/˜↩𝕨⋄𝕨/𝕩}        # Token start and end
  is-↩is(-×⊏⟜c)ie                           # Comment → ending newline only
  t←CharCode ie⊏𝕩
  w←»⊸<l←t M bD(⊣≍-˜)○⊑bW⋄us←t=¯1++´bA      # Word chars l, start w
  wk←na⌊∘÷˜(⊑bA)-˜w/t                       # Kind of word from first char
  t-↩na×l∧t≥na+⊑bA                          # Case-insensitive
  i←l>n←l∧(+`w)⊏0∾wk<0                      # Identifier/Number masks
  num←is ReadNums○((∨⟜«0∾n)/0⊸∾) t×l        # Numbers
  ir←(us/˜«⊸<i)(⊢+∧⟜(2⊸=))0⊸≤⊸/wk           # Identifier role
  id←(1-˜(i>us)×+`w>n)⊔t                    # Identifiers

  # Deduplicate literals and identifiers; other cleanup
  ki←((⍋⊏⟜n)⊸⊏/w)∾(ci∾/si)⊏+`»f             # Indices in t
  k←id‿num‿chr‿str⋄k(⊢>¯1»⌈`)⊸/¨˜↩j←⊐¨k     # IDs j into uniques k
  wf←¬l∨t M bW⋄ie/˜↩wf∨>⟜«l                 # Index management for...
  t↩(w∨wf)Fs(∾j++`vi»≠¨k)⌾(ki⊸⊏)t           # Add IDs; remove words/whitespace
  t-↩t(M×-⟜⊑)bS                             # Separators are equivalent
  p←≠`1¨sb←¯1↓1↓/1(∾≠∾˜)t=sep               # Separator group boundaries (excludes leading and trailing)
  sk←sb/˜p>∨⟜«(p+(sb-p)⊏t)∊3‿5+⊑bB          # Keep the first of each group that's not just inside a bracket
  t{ie/˜↩𝕨⋄𝕨Fs𝕩}˜↩1¨⌾(sk⊸⊏)t≠sep            # Remove the rest
  r←ir⌾((t M vi∾≠⊑k)⊸/)(vi⌊t)⊏charRole∾0    # Role
  t+↩5×t M⟨⊑bI,5⟩                           # Case-insensitive special names
  ⟨t,r,k,is,ie⟩
}

# 𝕩 is a list of tokens that contains the numeric literals, each
# preceded by 0. Return the numbers.
ReadNums←{
  ind←𝕨 ⋄ _err_←{(0!˜/⟜𝔾⟜ind≍○<𝔽)⍟(∨´∘⊢)}
  EChars←⟨"Letter"⊸Pl," """,⊏⟜charSet,""" not allowed in numbers"⟩_tmpl
  e‿p‿i‿n‿d←=⟜𝕩¨((⊑bA)+-´"ea")∾+⟜↕´bN       # Masks for eπ∞¯.
  EChars∘(/⟜𝕩)_err_⊢ ¬e∨𝕩<⊑bA
  s←d∨c←e∨z←0=𝕩⋄m←¬n∨c
  "Negative sign in the middle of a number"_err_⊢ n>»c
  "Portion of a number is empty"_err_⊢ (1«s)∧n∨s
  "Ill-formed decimal or exponent use"_err_(s⊸/) ¬(0⊸=∨»⊸<)s/𝕩
  "π and ∞ must occur alone"_err_⊢ (p∨i)>1(»∧(p∧«e)∨«)z∨n
  f←(17≥¬(⊢-T)+`)⊸∧(«≤(d<𝕩≠⊑bD)>○I1T¬)⊸∧m   # No leading 0s; max 17 digits
  l←(¯1∾π‿1∾˜↕10)⊏˜(¬d)/f×𝕩-1-˜⊑bD          # Digit lookup, with ∞ as 1 to avoid ∞×0
  v←(>⟜«0≤l)/(0⊸≤××⟜10⊸+)`»«l               # Numeric values—mantissas and exponents
  v×↩1‿¯1⊏˜(r←>⟜»m)/»n                      # Negate if ¯
  vm←c/z                                    # Mask of mantissas in l
  dp←vm/(»⊸<×-)⟜(⊏⟜(I1T d∾0))1+/>⟜«f        # Decimal position
  t←10⋆|ee←dp-˜vm/«v×¬vm                    # Power of 10
  t÷˜⌾((0>ee)⊸/)t×⌾((0<ee)⊸/)vm/v×(r/i)⊏1‿∞ # Correct ∞ then ×10⋆ee
}


Parse ← {r‿vn‿ind←𝕨⋄nv←≠vn
  ErrMismatchedBrackets←{
    Lcs ← ¯1 ⊑ 0˘∘⊢ {𝕩⌈⌈`𝕨+«𝕩}˝ =⌜
    _mis_ ← {"Missing "∾𝕗∾" "∾charSet⊏˜𝕘+⊢/˜≠∘⊣=⊒}
    Msg ← >○≠◶⟨"opening"_mis_ 0, "closing"_mis_ 1˜⟩
    0 !˜ 𝕨 (Lcs<⌊○≠)◶⟨Msg,"Malformed bracket nesting"⟩ 𝕩
  }
  ErrUndeclared←{
    0 !˜ "Undefined identifier"Pl𝕩
  }

  g←⍋pd←+`p←(¯1-2×r)×𝕩 M bB⋄gp←g⊏p⋄gb←g⊏r=¯1⋄gx←g⊏𝕩
  gp(>⟜0⊸/ErrMismatchedBrackets⍟≢1-˜<⟜0⊸/)gx
  _err_←{(0!˜/⟜𝔾⟜ind≍○<𝔽)⍟(∨´∘⊢)}
  "Swapped open and closed brackets" ! 0≤(⊑g)⊑pd
  "Parentheses can't contain separators"_err_(gb/g⊸⊏) ((⊑bB)⊸=»⊸∧sep⊸=)gb/gx
  {"Empty statement or expression"_err_(𝕩/0∾g⊸⊏) (4+⊑bB)≠𝕩/0∾gx}1⊸«⊸∧1∾gb
  r-↩(𝕩=⊑bG)>ec←«0≤r+p
  "Invalid assignment or stranding use"_err_⊢ ((¯4⊸<∧≤⟜¯2)r)>ec∧»0≤r
  sr←»⌾(g⊸⊏)sl←«⊸∨r=¯2⋄cp←𝕩=1+⊑bB
  g⊏˜↩⍋g⊏sl
  rev←⍋+`¯1↓(¯1∾g)(⊣⍋⊸⊏⊏˜⟜⍋¬⊏˜)⍋+`⊸+1∾g⊏sl∨r=¯1

  gf←⍋fd←+`rev⊏br←p×𝕩M⟨2+⊑bB,2⟩
  rev⊏˜↩gf⋄fd⊏˜↩gf
  𝕩⊏˜↩rev⋄ind⊏˜↩rev⋄bv←rev⊏br⋄b←/bv<0⋄fi←+`c←bv>0

  H←¬1(∾/∾˜)c(∨/⊣)=
  sn←(0‿3‿4‿5+5+⊑bI)⍋𝕩⋄fx←1 H sn⋄fr←(fx∨0⊸<)⊸+ft←(2⊸H⌈2×3⊸H)sn
  {⟨ind/˜(0=fi)∧𝕩 M bI,"Special name outside of any block"⟩!0}⍟(0<⊑fr) 𝕩
  nf←(⊑bG)H𝕩
  {⟨ind/˜(fi⊏0≠fr)∧𝕩=⊑bG,"Can't export from a non-immediate block"⟩!0}⍟(∨´nf>fr=0) 𝕩
  fsc←(ft⊏0‿2‿3)+3×fx
  pt←cp∧ns←¬sl∨sr
  r↩sl-˜ns×(1↓fr)⌾((b⊏rev)⊸⊏)r
  pp←pt∧»no←1⊸»⌾(g⊸⊏)r<0
  ir←((»⌾(g⊸⊏)(1+no)×3=⊢)⌈⊢-no<2≤⊢)r+pp×(IT¬pp)⊏r
  ir⌈↩(IT¬pt∧ir=0)((⊏-⊢)⟜(+`¬pp)(⊢⌊1⌈+)⊏)ir
  r+↩pt×»ir

  idx←𝕩⊏˜id←/idm←(0⊸≤∧<⟜nv)xv←𝕩-vi⋄sp←/𝕩 M bI

  g↩⍋+`rev⊏p-br⋄gr←g⊏rev⋄sll←1+2÷˜0(<-○/>)gr⊏sr-sl⋄l←/g⊏𝕩=5+⊑bB
  g⊏˜↩gs←⍋gr⊏sl⋄gr↩g⊏rev⋄gi←⍋g
  𝕩⊏˜↩g⋄r⊏˜↩gr⋄ir⊏˜↩gr⋄l↩(l⊏⍋gs)∾/gr⊏sr>sl
  ni←1+(1↓nf)/bk←b⊏gi
  "Modules must be immediately assigned"_err_(ni⊏g⊸⊏)∘(∨˝¯3‿0‿¯1≠r∾⟜¯1‿1⊸(⊏˜)(↕3)+⌜⊢)⍟(0<≠)ni
  "Modules must be destructured"_err_(ni⊏g⊸⊏) (⊏⟜idm>⊏⟜rev⊏sr˙)(ni+1)⊏g
  a←r≤¯3⋄ps←a<r<0⋄tr←1≤er←ir⊏˜IT»ps
  oa←⌽/op←(er<2)∧r≥2⋄ro←op∨«op∧r=3
  ma←tr<(𝕩=2+⊑bG)∧«ir≥1
  os←↕∘≠⊸(⊣-T)⌾⌽¬ro∨ma⋄at←1+⊏⟜os⊸+ai←/a⋄af←¯4≠ai⊏r
  "Role of the two sides in assignment must match"_err_(at⊏g⊸⊏) (at⊏er)≠ar←at⊏r
  "Function or modifier assignment to a non-name"_err_(at⊏g⊸⊏) ¬(ar=0)∨(at⊏g)⊏idm
  aa←×g⊏ac←»+`gi⊏«⊸-(1+af+(ai∊ni)+2×(⊑bG)-˜ai⊏𝕩)⌾(at⊸⊏)0¨𝕩

  ip←id⊏ac⋄d←ip M 2‿4⋄zic←0¨ic←id/˜icf←2(<∧|)ip
  il←ic⊏+`bv<0⋄ex←il⊏(/∾≠)c
  ixf←(((1=ip)+⊏⟜(¯1∾c/gf))∾(il∾d⊸/)⊏((≠𝕩)∾b⊏gf)˜)id⊏fi
  d∾↩zic⋄idx∾↩icf/idx
  ig←(⍋⊏⟜(ixx←∾⟜(d⊸/)idx))⊸⊏⍋ixf
  "Multiple definitions" ! ∧´ixx∨○(»⊸≠((≠d)⊸≤⊸/ig)⊸⊏)ixf
  ig↩<⟜(≠d)⊸/(⍋+`∘⊏⟜(d∾-/˜d))⊸⊏ig
  d⊏˜↩ig⋄idx⊏˜↩ig
  ErrUndeclared∘/⟜idx⍟(∨´)d<»⊸≠idx
  "Imports must have been exported" ! ∧´2>-⟜»(d∨×)⊸/ig⊏(ip M 1‿3)∾2¨ic
  ui←(IT d)⊸⊏⌾(ig⊸⊏)id∾ex
  lc←(1«c)/dn←c(⊢-T)+`idm∧ac M 2‿4
  ii←(ui⊏(fi⊏fsc)+dn-1)∾((sp⊏fi)⊏3×fx)++⟜(0⊸≤)2+sp⊏xv
  ib←⟨21+0<ip∾zic∾sp⊏ac,(id-○(⊏⟜fd)id≠⊸↑ui)∾zic∾0¨sp,ii⟩
  ed←/¯1⊸»⊸<ex
  idor←∾¯1⌽1‿3/⟨3/id∾ex∾sp,ed⊏ex⟩
  idbc←¯1⌽⟨⥊⍉>ib,3¨ed,ex≠⊸(«-⊢)ed,14¨ed⟩

  ta←tr∧2(>∨|)ps(⊢-T)+`¬ro
  fa←/(ta∨ro∨«⊸∨ps<aa)<(r=1)∨»op
  dy←fa⊏«(𝕩=⊑bO)<(tr∧r≥0)∨ro<r=0
  ob←pr⊏/¯1(⊢-»)u←⍷∧pr←𝕩⊏˜pi←/𝕩<sep
  cn←pi∾lt←/𝕩≥ci←vi+nv⋄ob∾↩(ci-˜≠u)+lt⊏𝕩
  s←𝕩=sep⋄fo←𝕩=2+⊑bB⋄ls←s∧fo<○IT lo←𝕩=4+⊑bB
  ll←sll∾˜(¬lo/1«ps)+-⟜»1↓(lo∾1)/+`ls∾0
  dr←/ls<s⋄rt←/fo

  or←⍋oi←idor∾g⊏˜∾⟨cn,cn,bk,bk,dr,2/l,af/at,oa+1⌈oa⊏os,(dy×⊏⟜os)⊸+fa+dy,rt⟩
  bc←or⊏∾idbc∾⟨0¨cn,ob,15¨bk,1+↕≠bk,14¨dr,⥊⍉(3+l⊏aa)≍ll
               11⌈(11-1+⊑bG)+(af/ai)⊏ma+𝕩,5+oa⊏r,(⊢+9×10⊸=)16+dy-7×fa⊏er,25¨rt⟩
  bcl‿el‿ol←LEB bc∾25
  ⟨bcl,u,⟨ft,¬fx,el/˜1∾or≥bc-○≠rt,lc+fsc⟩, ol/(¯1∾˜or⊏oi)⊏¯1(⊢∾⊏)ind⟩
}

LEB←{
  b←128
  s←+`»i←1+l←⌊b⋆⁼1⌈𝕩
  o←⍋⍋↕∘≠⊸-i/s
  v←o⊏l{f←×𝕨⋄(𝕨-1)(b⊸(×⟜f+|)∾𝕊⟜(⌊÷⟜b)○(f⊸/))⍟(∨´f)𝕩}𝕩
  v‿s‿i
}

Compile←{
  ⟨tok,role,val,inds,inde⟩←tx←Tokenize 𝕩
  ⟨bc,prim,blk,indb⟩←⟨role,⊑val,inds⟩ Parse tok
  ⟨bc, ∾⟨prim⊏𝕨⟩∾1↓val, <˘⍉>blk, indb, tx⟩
}
