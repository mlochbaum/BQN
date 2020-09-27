lf←@+10
charSet‿cgl←(∾ ≍○< ≠¨)⟨
  "+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!" # Function
  "˙˜˘¨⌜⁼´˝`"           # Modifier
  "∘○⊸⟜⌾⊘◶⎉⚇⍟"          # Composition
  lf∾"⋄,"               # Separator
  "←↩→"                 # Gets
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
bF‿bM‿bC‿bS‿bG‿bB‿bL‿bO‿bI‿bD‿bN‿bA‿bW‿bP←≍¨˜⟜(+`»)cgl
M←1⊸⊑(0⊸≤∧>)-⟜⊑  # ∊ for an init,length pair 𝕩 as above
# CharCode converts characters to numbers, mostly the same as tokens
ErrUnknownChars←{
  ⟨"Unknown character","s"/˜1<≠𝕩,": ",𝕩⟩∾⊸!0
}
CharCode←charSet{
  Chk ← ⊢⊣ErrUnknownChars∘(≠/⊣)⍟≢⟜(⊏⟜𝕗)
  g←⍋𝕗 ⋄ ⊢ Chk g⊏˜1-˜1⌈(g⊏𝕗)⍋⊢
}

vi←⊑bD  # Start of identifier numbering
charRole←∾⥊¨˜⟜(≠↑cgl˙)⟨1,2,3,¯1,¯1,¯1‿0,¯1,0,5/⌽↕2⟩ # For first vi chars
T←⌈`× ⋄ IT←↕∘≠⊸T ⋄ I1T←(1+↕∘≠)⊸T

# Source to ⟨tokens, roles, number of identifiers, literals⟩
# Identifiers then literal tokens are numbered starting at vi
Tokenize←{
  # Resolve comments and strings
  r←𝕩='#'⋄s←/0‿0⊸«⊸∧sm←𝕩='''⋄d←/dm←𝕩='"'
  g←⍋q←∾⟨  s⋄¯1↓d⋄/r⟩ ⋄q↩g⊏q                # Open indices
  e← g⊏∾⟨2+s⋄ 1↓d⋄-⟜»∘⊏⟜(0∾+`r)⊸//(𝕩=lf)∾1⟩ # Matching close indices
  Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟(0=¯1⊑⊢)       # Mark reachable openings
  St←(≠𝕩)↑·/⁼((≠↑∾⟜≠Se 1∾0¨)q⍋e)⊸/          # All indices → reached mask
  a←St q⋄b←St e⋄f←¬≠`ab←a∨b                 # Open/close masks; filter
  "Unclosed quote"!¬∨´(sm∨dm)∧b<f

  # Extract character and string literals
  u←f∧𝕩='@'⋄ci←/u∨»a∧sm
  chr←(⊏⟜𝕩-('@'-@)×⊏⟜u)ci                   # Characters (indices ci)
  f>↩qe←dm∧«a∧↩dm                           # Quote Escape ""
  str←1↓¨𝕩⊔˜1-˜(+`si←a>»qe)×≠`dm∧ab         # Strings (indices /si)

  # Extract words: identifiers and numbers
  c←CharCode f/𝕩
  w←»⊸<l←c M bD(⊣≍-˜)○⊑bW⋄us←c=¯1++´bA      # Word chars l, start w
  tw←na⌊∘÷˜(⊑bA)-˜w/c                       # Type of word from first char
  c-↩na×l∧c≥na+⊑bA                          # Case-insensitive
  i←l>n←l∧(+`w)⊏0∾tw<0                      # Identifier/Number masks
  num←ReadNums n∨⟜«⊸/○(0⊸∾)c×l              # Numbers
  ir←(us/˜«⊸<i)(⊢+∧⟜(2⊸=))0⊸≤⊸/tw           # Identifier role
  id←(1-˜(i>us)×+`w>n)⊔c                    # Identifiers

  # Deduplicate literals and identifiers; other cleanup
  ki←((⍋⊏⟜n)⊸⊏/w)∾(ci∾/si)⊏+`»f             # Indices in c
  k←id‿num‿chr‿str⋄k(⊢>¯1»⌈`)⊸/¨˜↩j←⊐¨k     # IDs j into uniques k
  c↩(w∨¬l∨c M bW)/(∾j++`vi»≠¨k)⌾(ki⊸⊏)c     # Add IDs; remove words/whitespace
  c/˜↩¬(1»(c∊2‿4+⊑bB)∨⊢)⊸∧c M bS            # Remove repeated and leading separators
  c/˜↩¬(1«c∊3‿5+⊑bB)∧c M bS                 # ...and trailing ones. In sequence for repeated trailing.
  cr←ir⌾((c M vi∾≠⊑k)⊸/)(vi⌊c)⊏charRole∾0   # Role
  c+↩5×c M⟨⊑bI,5⟩                           # Case-insensitive special names
  ⟨c,cr,≠⊑k,∾1↓k⟩
}

# 𝕩 is a list of tokens that contains the numeric literals, each
# preceded by 0. Return the numbers.
ErrNumericChars←{
  ⟨"Letter","s"/˜1<≠𝕩," """,𝕩⊏charSet,""" not allowed in numbers"⟩∾⊸!0
}
ReadNums←{
  e‿p‿i‿n‿d←=⟜𝕩¨((⊑bA)+-´"ea")∾+⟜↕´bN       # Masks for eπ∞¯.
  ErrNumericChars∘(/⟜𝕩)⍟(∨´) ¬e∨𝕩<⊑bA
  m←¬n∨s←d∨c←e∨z←0=𝕩
  "Negative sign in the middle of a number" ! ∧´n≤»c
  "Portion of a number is empty" ! ¬∨´(»¬m)∧s
  "Ill-formed decimal or exponent use" ! ∧´(0⊸=∨»⊸<)s/𝕩
  "π and ∞ must occur alone" ! ∧´(p∨i)≤1(»∧(p∧«e)∨«)z∨n
  l←(¯1∾π‿1∾˜↕10)⊏˜(¬d)/m×𝕩-1-˜⊑bD          # Digit lookup, with ∞ as 1 to avoid ∞×0
  v←(>⟜«0≤l)/(0⊸≤××⟜10⊸+)`»«l               # Numeric values—mantissas and exponents
  v×↩1‿¯1⊏˜(r←>⟜»d∨m)/»n                    # Negate if ¯
  vm←c/z                                    # Mask of mantissas in l
  dp←vm/(»⊸<×-)⟜(⊏⟜(I1T d∾0))(≠«/)c         # Decimal position
  t←10⋆|ee←dp-˜vm/«v×¬vm                    # Power of 10
  t÷˜⌾((0>ee)⊸/)t×⌾((0<ee)⊸/)vm/v×(r/i)⊏1‿∞ # Correct ∞ then ×10⋆ee
}


ErrMismatchedBrackets←{
  Lcs ← ¯1 ⊑ 0˘∘⊢ {𝕩⌈⌈`𝕨+«𝕩}˝ =⌜
  _mis_ ← {"Missing "∾𝕗∾" "∾charSet⊏˜𝕘+⊢/˜≠∘⊣=⊒}
  Msg ← >○≠◶⟨"opening"_mis_ 0, "closing"_mis_ 1˜⟩
  0 !˜ 𝕨 (Lcs<⌊○≠)◶⟨Msg,"Malformed bracket nesting"⟩ 𝕩
}
ErrUndeclared←{
  0 !˜ "Undefined identifier"∾(1<≠𝕩)/"s"
}
Parse ← {r‿nv←𝕨
  g←⍋pd←+`p←(¯1-2×r)×𝕩 M bB⋄br←p×𝕩M⟨2+⊑bB,2⟩
  p(=⟜1⊸/ErrMismatchedBrackets⍟≢1-˜=⟜¯1⊸/)○(g⊸⊏)𝕩
  "Swapped open and closed brackets" ! 0≤(⊑g)⊑pd
  sl←«⊸∨𝕩 M bL⋄sr←»⌾(g⊸⊏)sl⋄sa←sl∨sr
  g⊏˜↩⍋g⊏sl⋄o←p>0
  pt←sa<𝕩=1+⊑bB
  rev←⍋+`1+¯1↓g((¯1∾⊣)(⊣⍋⊸⊏⊏˜-⊏˜⟜⍋)⟜⍋1(+`∘∾-∾˜)⊏)o∨sl∨𝕩 M bS

  gf←⍋fd←+`rev⊏br
  rev⊏˜↩gf⋄fd⊏˜↩gf
  𝕩⊏˜↩rev⋄bv←rev⊏br⋄b←/bv<0⋄fi←+`c←bv>0

  H←¬·1⊸«⊸/c(∨/⊣)=
  ft←(0∾1⊸H+2×2⊸H⌈2×3⊸H)(0‿3‿4‿5+5+⊑bI)⍋𝕩
  fsc←ft⊏⥊3‿5‿6-⌜3‿0
  r↩sl-˜sa¬⊸×((1↓ft)⊏(1+2⊸≤)⊸/↕4)⌾((b⊏rev)⊸⊏)r
  r+↩pt(⊣∧≤=○I1T⊢)(»⌾(g⊸⊏)3=r)∨1≤r

  id←/idm←(0⊸≤∧<⟜nv)xv←𝕩-vi⋄idx←id⊏𝕩⋄sp←/𝕩 M bI
  ad←(𝕩 M bG)IT⊸⊏𝕩=⊑bG

  g↩⍋+`rev⊏p-br⋄gr←g⊏rev⋄sll←1+2÷˜0(<-○/>)gr⊏sr-sl⋄l←/g⊏𝕩=5+⊑bB
  g⊏˜↩gs←⍋gr⊏sl⋄gr↩g⊏rev⋄𝕩⊏˜↩g⋄r⊏˜↩gr⋄o⊏˜↩gr⋄si←/gr⊏sr>sl
  gi←⍋g⋄l⊏↩⍋gs
  s←𝕩 M bS⋄ps←s∨o∨gr⊏sl⋄a←𝕩M⟨⊑bG,2⟩
  op←r≥2⋄fe←(r≥1)∨«r=3
  tr←(IT»ps)⊏fe
  ma←tr<(𝕩=1+⊑bG)∧«fe
  ro←op∨a<«r=3⋄os←⌽↕∘≠⊸(⊣-T)⌽¬ro∨ma⋄at←(⊢+1+⊏⟜os)/a
  aa←g⊏asn←»+`gi⊏-⟜»(≠𝕩)↑/⁼at-1⋄r↩¯1¨⌾(aa⊸/)r
  tf←(a≤○I1T ps)∧(⊢∧2(|<≤)ps(⊢-T)+`)¬ro
  opa←op>«ps∨a
  oa←⌽/opa⋄fa←/(«aa)<(tf∨¬tr)∧(ro∧«opa)<(r=1)∨op<»opa
  dy←fa⊏«(𝕩≠⊑bO)∧(tr∧r≥0)∨ro<r=0
  n←𝕩≥vi+nv⋄cn←/n∨𝕩<⊑bS⋄u←∧⍷ob←cn⊏𝕩
  lo←(o/𝕩)=4+⊑bB⋄ll←1+lo/1(↓--⊸↓)(o∾1)/+`(s∾0)-(1∾o)∧ps∾1
  dr←/s>o+`⊸⊏0∾lo⋄rt←/𝕩=2+⊑bB

  d←id⊏dec←idm∧ad∧asn⋄lc←-⟜»(c∾1)/+`dec∾0
  ixf←(⊏⟜(¯1∾c/gf)∾d⊸/⊏((≠𝕩)∾b⊏gf)˜)id⊏fi
  ig←(⍋⊏⟜(ixx←∾⟜(d⊸/)idx))⊸⊏⍋ixf
  "Multiple definitions" ! 1∧´ixx∨○(»⊸≠((≠id)⊸≤⊸/ig)⊏⊢)ixf
  ig↩<⟜(≠id)⊸/(⍋+`∘⊏⟜(d∾-/˜d))⊸⊏ig
  d⊏˜↩ig⋄ErrUndeclared∘/˜⍟(0∨´⊢)⟜(d<»⊸≠)ig⊏idx
  ui←(IT d)⊸⊏⌾(ig⊸⊏)id
  ii←(ui⊏(fi⊏fsc)-c⊸T⊸¬+`dec)∾((sp⊏fi)⊏3×2|ft)++⟜(0⊸≤)2+sp⊏xv
  idor←∾3⥊<is←id∾sp
  idbc←⟨21+is⊏asn,(id-○(⊏⟜fd)ui)∾0¨sp,ii⟩

  b⊏↩gi
  or←⍋idor∾g⊏˜∾⟨cn,cn,b,b,dr,l,l,si,si,at,oa+1⌈oa⊏os,(dy×⊏⟜os)⊸+fa+dy,rt⟩
  bc←or⊏∾idbc∾⟨0¨cn,u⊐ob,15¨b,1+↕≠b,14¨dr,3+l⊏aa,ll,3+si⊏aa,sll
               (11-⊑bG)+a/ma+𝕩,5+oa⊏r,(⊢+9×10⊸=)16+dy-7×fa⊏tr,25¨rt⟩
  bcl‿el←LEB bc∾25
  fs←(ft⊏⥊3≍⌜⟜⌽○↕2)∾¨(el/˜1∾or≥bc-○≠rt)≍¨lc+fsc
  ⟨bcl,u,fs⟩
}

LEB←{
  b←128
  s←+`»i←1+l←⌊b⋆⁼1⌈𝕩
  o←⍋⍋↕∘≠⊸-i/s
  v←o⊏l{f←×𝕨⋄(𝕨-1)(b⊸(×⟜f+|)∾𝕊⟜(⌊÷⟜b)○(f⊸/))⍟(∨´f)𝕩}𝕩
  v‿s
}

Compile←{
  ⟨t,r,nVar,const⟩←Tokenize𝕩
  ⟨bc,u,blk⟩←r‿nVar Parse t
  o←(u-(vi+nVar-≠𝕨)×u≥vi)⊏𝕨∾const
  ⟨bc,o,blk⟩
}
