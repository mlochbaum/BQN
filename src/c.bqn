#! ./dzref

tab←'	'⋄nl←'
'
dig ← "0123456789"
alph ← "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
alow ← "abcdefghijklmnopqrstuvwxyz"
charSet←∾charGroups←⟨
  chF←"+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!" # Function
  "˜˘¨⌜⁼´˝`"            # Modifier
  "∘○⊸⟜⌾⊘◶⎉⚇⍟"          # Composition
  nl∾"⋄,"               # Separator
  "←↩→"                 # Gets
  "(){}⟨⟩"              # Bracket
  "‿"                   # Ligature
  "·"                   # nOthing
  "𝕊𝕏𝕎𝔽𝔾𝕤𝕩𝕨𝕗𝕘"          # Input (𝕣 pending; ℝ not allowed)
  dig                   # Digit
  "¯.π∞"                # Numeric
  alow∾alph∾"_"         # Alphabetic
  " "∾tab               # Whitespace
# #'" eliminated during tokenization
⟩
bF‿bM‿bC‿bS‿bG‿bB‿bL‿bO‿bI‿bD‿bN‿bA‿bW←⊔/≠¨charGroups
M←⊢(0⊸≤∧≠⊸>)-⟜⊑
vi←+´≠¨9↑charGroups
charRole←((vi-≠bI)↑/0∾≠¨3↑charGroups)∾(5/⌽↕2)∾0
spc←⥊3‿5‿6-⌜3‿0

Tokenize←{
  r←𝕩='#'⋄s←/(≠↑2⊸↓)⊸∧𝕩='''⋄d←/𝕩='"'
  g←⍋q←∾⟨  s⋄¯1↓d⋄/r⟩ ⋄q↩g⊏q
  e← g⊏∾⟨2+s⋄ 1↓d⋄(⊢-¯1↓0∾⊢)∘⊏⟜(0∾+`r)⊸//(𝕩=nl)∾1⟩
  Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟{0=⊑⌽𝕩}
  st←¯1↓Se⟜(1↑˜≠)∾⟜≠q⍋e⋄b←st/q∾˘e
  ToI←¯1↓·/⁼(≠𝕩)∾˜⥊⋄f←¬≠`ToI b
  cb←(¬(st/q)⊏r)/b
  lu←⍷lit←𝕩⊔˜1-˜(+`ToI⊑˘cb)×≠`ToI cb
  cl←f/ToI⊑∘⌽˘cb

  c←charSet⊐f/𝕩
  w←(≠↑0∾⊢)⊸<l←c M∾bD‿bN‿bA
  i←(1-˜l×+`w)⊔c
  na←≠alph⋄us←¯1⊑bA
  in←na(⊢-⊣×+⟜(⊑bA)⊸≤)us⊸≠⊸/¨i
  id←⍷(bA M˜w/c)⍒⊸⊏in⋄nv←+´bA M˜⊑¨id

  c↩(w∨¬l∨c M bW)/(vi+id⊐in)⌾(w⊸/)(vi+(≠id)+lu⊐lit)⌾(cl⊸/)c
  c/˜↩¬(≠↑1∾(c∊2‿4⊏bB)∨⊢)⊸∧c M bS⋄c/˜↩¬(1↓1∾˜c∊3‿5⊏bB)∧c M bS
  ti←(us=¯1⊸⊑¨i)(⊢+∧⟜(2⊸=))0⌈na⌊∘÷˜(⊑bA)-˜⊑¨i
  ic←(0⊸≤∧<⟜(≠id))c-vi⋄t←ti⌾(ic⊸/)(vi⌊c)⊏charRole
  c+↩5×c M 5↑bI
  ⟨c,t,nv,(nv↓id)∾lu⟩
}

ReadNum←{
  n‿d‿p‿i←bN  # ¯.π∞
  Nat←+⟜(10⊸×)´∘⌽ -⟜(⊑bD)
  Int←(n=⊑)◶⟨Nat,-·Nat 1⊸↓⟩
  Dec←⊐⟜(<d)⊸(Nat∘↑ + ·(0<≠)◶⟨0,Nat÷10⋆≠⟩+⟜1⊸↓)
  Pos←(⊑p‿i⊐⊏)◶⟨π,∞,Dec⟩
  e←⊑𝕩⊐charSet⊐<'e'
  m←(n=⊑)◶⟨Pos,-·Pos 1⊸↓⟩e↑𝕩
  𝕩×⟜(10⋆·Int(e+1)↓⊣)˜⍟(e<≠𝕩)m
}
LitVal←(⊑("'"∾'"')⊐⊏)◶⟨1⊸⊑,1⊸↓,ReadNum⟩


LEBv ← {
  b←128
  l←⌊b⋆⁼1⌈𝕩
  o←⍋⍋⊒/1+l
  o⊏l{f←×𝕨⋄(𝕨-1)(b⊸(×⟜f+|)∾𝕊⟜(⌊÷⟜b)○(f⊸/))⍟(∨´f)𝕩}𝕩
}

Parse ← {nv‿r←𝕨
  g←⍋+`p←bB(⊣(≠⊸>×¯1⋆2|⊢)⊐)𝕩⋄br←p×𝕩 M 2‿3⊏bB
  sl←1⊸⌽⊸∨𝕩 M bL⋄sr←¯1⊸⌽⌾(g⊸⊏)sl⋄sa←sl∨sr
  g⊏˜↩⍋g⊏sl⋄r×↩¬sa⋄o←p>0
  r+↩(sa<𝕩=1⊑bB)(⊣∧¬⊸∨=○(⌈`(1+↕∘≠)⊸×)⊢)(¯1⊸⌽⌾(g⊸⊏)3=r)∨1≤r
  rev←⍋+`1+¯1↓g((¯1∾⊣)(⊣⍋⊸⊏⊏˜-⊏˜⟜⍋)⟜⍋1(+`∘∾-∾˜)⊏)o∨sl∨𝕩 M bS

  gf←⍋fd←+`rev⊏br
  rev⊏˜↩gf⋄fd⊏˜↩gf
  𝕩⊏˜↩rev⋄bv←rev⊏br⋄b←/bv<0⋄fi←+`c←bv>0

  FC←-⟜(≠↑0∾⊢)(c∾1)/·+`∾⟜0
  H←0<1↓·FC𝕩 M (5⊑bI)+⊢
  ft←0∾(H↕3)+2×(H⥊3)⌈2×H⥊4
  r↩((1↓ft)⊏(1+2⊸≤)⊸/↕4)⌾(b⊸⊏)rev⊏r

  id←/idm←(0⊸≤∧<⟜nv)xv←𝕩-vi⋄idx←id⊏𝕩⋄sp←/𝕩 M bI
  ad←(⌈`↕∘≠⊸×𝕩 M bG)⊏𝕩=⊑bG

  g↩⍋+`rev⊏p-br⋄gr←g⊏rev⋄sll←1+2÷˜0(<-○/>)gr⊏sr-sl⋄l←/g⊏𝕩=5⊑bB
  g⊏˜↩gs←⍋gr⊏sl⋄gr↩g⊏rev⋄𝕩⊏˜↩g⋄r⊏˜↩g⋄o⊏˜↩gr⋄si←/gr⊏sr>sl
  gi←⍋g⋄l⊏↩⍋gs
  s←𝕩 M bS⋄ps←s∨o∨gr⊏sl⋄a←𝕩 M 2↑bG
  r-↩ps∨a⋄op←r≥2⋄fe←(r≥1)∨1⌽r=3
  tr←(⌈`↕∘≠⊸×¯1⌽ps)⊏fe
  ma←tr<(𝕩=1⊑bG)∧1⌽fe
  ro←op∨a<1⌽r=3⋄os←⌽↕∘≠⊸(⊣-⌈`∘×)⌽¬ro∨ma⋄at←(⊢+1+⊏⟜os)/a
  aa←g⊏asn←¯1⌽+`gi⊏-⟜(≠↑0∾⊢)(↕≠𝕩)∊at-1⋄r↩¯1¨⌾(aa⊸/)r
  tf←(a≤○(⌈`(1+↕∘≠)⊸×)ps)∧(⊢∧2(|<≤)ps(⊢-⌈`∘×)+`)¬ro
  opa←op>1↓0∾˜ps∨a
  oa←⌽/opa⋄fa←/(1⌽aa)<(tf∨¬tr)∧(ro∧1⌽opa)<(r=1)∨op<¯1⌽opa
  dy←fa⊏1↓0∾˜(𝕩≠⊑bO)∧(tr∧r≥0)∨ro<r=0
  n←𝕩≥vi+nv⋄cn←/n∨𝕩≤¯1⊑bC⋄u←∧⍷ob←cn⊏𝕩
  lo←(o/𝕩)=4⊑bB⋄ll←1+lo/1(↓--⊸↓)(o∾1)/+`(s∾0)-(1∾o)∧ps∾1
  dr←/s>o+`⊸⊏0∾lo⋄rt←/𝕩=2⊑bB

  d←id⊏dec←idm∧ad∧asn⋄lc←FC dec
  ig←⍋(⊏⟜(¯1∾c/gf)∾d⊸/⊏((≠𝕩)∾b⊏gf)˜)id⊏fi
  ig↩<⟜(≠id)⊸/(⍋+`∘⊏⟜(d∾-/˜d))⊸⊏(⍋⊏⟜(∾⟜(d⊸/)idx))⊸⊏ig
  ui←d(⌈`↕∘≠⊸×)⊸⊏⌾(ig⊸⊏)id
  ii←(ui⊏(fi⊏ft⊏spc)-(⌈`c⊸×)⊸¬+`dec)∾((sp⊏fi)⊏3×2|ft)++⟜(0⊸≤)2+sp⊏xv
  idor←∾3⥊<is←id∾sp
  idbc←⟨21+is⊏asn,(id-○(⊏⟜fd)ui)∾0¨sp,ii⟩

  b⊏↩gi
  or←⍋idor∾g⊏˜∾⟨cn,cn,b,b,rt,dr,l,l,si,si,at,oa+1⌈oa⊏os,(dy×⊏⟜os)⊸+fa+dy⟩
  bc0←∾idbc∾⟨0¨cn,u⊐ob,15¨b,1+↕≠b⟩
  bc←or⊏bc0∾∾⟨25¨rt,14¨dr,3+l⊏aa,ll,3+si⊏aa,sll,(11-⊑bG)+a/ma+𝕩,5+oa⊏r,(⊢+9×10⊸=)16+dy-7×fa⊏tr⟩
  fs←(ft⊏⥊3≍⌜⟜⌽○↕2)∾¨((+`0∾1+⌊128⋆⁼1⌈bc)⊏˜/1∾or∊bc0+⟜↕○≠rt)≍○<¨lc+ft⊏spc
  ⟨LEBv bc∾25,u,fs⟩
}

Compile←{
  ⟨t,r,nVar,lits⟩←Tokenize𝕩
  ⟨bc,u,blk⟩←nVar‿r Parse t
  o←(u-(vi+nVar-≠𝕨)×u≥vi)⊏𝕨∾LitVal¨lits
  ⟨bc,o,blk⟩
}
