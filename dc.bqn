#! ./spec/dzref

nl‿tab←•UCS 10‿9
charSet←∾charGroups←⟨
  chF←"+-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔" # Function
  "˜˘¨⌜⁼´`"             # Modifier
  "∘○⊸⟜⌾⊘◶⎉⚇⍟"          # Composition
  ¯1⊏˘10‿2⥊"𝕨𝕎𝕩𝕏𝕗𝔽𝕘𝔾𝕤𝕊" # Input (𝕣 pending; ℝ not allowed)
  nl∾"⋄,"               # Separator
  "←↩→"                 # Gets
  "(){}⟨⟩"              # Bracket
  "‿"                   # Ligature
  •d # +⟜(↕10)⌾•UCS'0'  # Digit
  "¯.π∞"                # Numeric
  "_"∾˜' '(+∾⊢)⌾•UCS•a  # Alphabetic
  1↑"𝕨"                 # Prefix for input (hack around UTF-16)
  " "∾tab               # Whitespace
# #'" eliminated during tokenization
⟩
bF‿bM‿bC‿bI‿bS‿bG‿bB‿bL‿bD‿bN‿bA‿bP‿bW←⊔/≠¨charGroups
vi←+´≠¨8↑charGroups
charRole←(vi+1)↑(/0∾≠¨3↑charGroups)∾10⥊↕2

Tokenize←{
  r←𝕩='#'⋄s←/(≠↑2⊸↓)⊸∧𝕩=⊑"'"⋄d←/𝕩='"'
  g←⍋q←∾⟨  s⋄¯1↓d⋄/r⟩ ⋄q↩g⊏q
  e← g⊏∾⟨2+s⋄ 1↓d⋄(⊢-¯1↓0∾⊢)∘⊏⟜(0∾+`r)⊸//(𝕩=nl)∾1⟩
  Se←{(⊏˜𝕨)Se 1¨⌾((𝕩/𝕨)⊸⊏)𝕩}⍟{0=⊑⌽𝕩}
  st←¯1↓Se⟜(1↑˜≠)∾⟜≠q⊸⍋¨e⋄b←st/q∾˘e
  ToI←¯1↓·/⁼(≠𝕩)∾˜⥊⋄f←¬≠`ToI b
  cb←(¬(st/q)⊏r)/b
  nl←≠lu←⍷lit←𝕩⊔˜1-˜(+`ToI⊑˘cb)×≠`ToI cb
  cl←f/ToI⊑∘⌽˘cb

  args←charSet⊸⊐¨𝕨⋄c←charSet⊐f/𝕩
  w←(≠↑0∾⊢)⊸<l←c∊∾bD‿bN‿bA
  i←(1-˜l×+`w)⊔c
  na←≠•a⋄us←¯1⊑bA
  in←us⊸≠⊸/¨na(⊢-⊣×+⟜(⊑bA)⊸≤)i
  id←⍷args∾(bA∊˜w/c)⍒⊸⊏in⋄nv←+´bA∊˜⊑¨id

  c↩(w∨¬l∨c∊bP∾bW)/(vi+id⊐in)⌾(w⊸/)(vi+(≠id)+lu⊐lit)⌾(cl⊸/)c
  c/˜↩¬(1⌾⊑1⌽1⌾⊑)⊸∧c∊bS
  ti←(us=¯1⊸⊑¨i)(⊢+∧⟜(2⊸=))0⌈na⌊∘÷˜(⊑bA)-˜⊑¨i
  t←ti⌾(((0⊸≤∧<⟜(≠id))c-vi)⊸/)(vi⌊c)⊏charRole
  ⟨c,t,nv,nv-≠args,(nv↓id)∾lu⟩
}

Parse←{
  a←𝕩∊(2↑bG)⋄at←1⌽a⋄𝕩/˜↩¬a⋄a/˜↩¬at
  l←≠𝕩⋄sep←𝕩∊bS⋄𝕩↩(bF⊑˜⥊chF⊐<'⊣')¨⌾(sep⊸/)𝕩⋄sep∨↩𝕩=2⊑bB
  o←𝕩=0⊑bB⋄c←𝕩=1⊑bB⋄v←a-˜𝕩≥vi⋄f←¬o∨c∨v∨sep
  na←(2×sep)+f×1+l↑0∾c∨v
  d←+`o-c⋄fe←(+`⌾((⍋d)⊸⊏)o)⊏l∾(⍋⊏⟜d)⊸⊏/c
  fe⌊↩l-l↑⌽⌈`↕∘≠⊸×⌽1∾˜sep
  sel←¬∘⊏⟜(o∨c)⊸/⍋((f×fe)⌈↕l)-+`f-l↑/⁼∧f/fe
  sel⊸⊏¨𝕩‿na
}

Base←{+⟜(𝕨⊸×)´𝕩}
Enc2←{2|⌊∘÷⟜2⍟(↕𝕨)𝕩}

Hex←16 Base⟜⌽ (•d∾"ABCDEF")⊸⊐

ReadNum←10 Base⟜⌽ bD⊸⊐
GenF64←{
  0:8⥊0;
  l←2(⌊⋆⁼)𝕩
  (Hex"44")∾2 Base˘8‿8⥊∾⟨¯52↑(0⌈l)Enc2𝕩,11 Enc2 1023+l,⥊0⟩
}
MakeTab←{{⊑∘(∾⟜0)¨¯1↓(chF⊐𝕨)⊔○(∾⟜(≠chF))𝕩}○∾⟜(⥊¨∘⥊¨)´<˘⍉(2(÷˜∾⊣)≢)⊸⥊𝕩}
tab1←MakeTab⟨
  "⊣⊢"     , 2⥊<⟨⟩
  "|-⌈⌊√"  , (Hex"99")+(↕4)∾6
  "÷"      , <(Hex"10")∾0
  "¬"      , <∾⥊¨⟨Hex"9A",GenF64 1,Hex"A0"⟩
⟩
tab2←MakeTab⟨
  "⊣"      , Hex"1A"
  "+-×÷⌊⌈∧", (Hex"A0")+(↕6)∾2
  "¬"      , <∾⥊¨⟨Hex"A1",GenF64 1,Hex"A0"⟩
  "∨"      , <(Hex"10")∾1
⟩
fntab←⍉(0¨tab1)∾tab1≍tab2
f64←127-3

GenFn←{
  ⟨⟩GenFn𝕩;
  ⟨t,r,nVar,nLoc,lits⟩←𝕨Tokenize𝕩
  t⊏˜↩⍋+`-´<˘(2‿3⊏bB)=⌜t
  nd←+´c←t=3⊑bB
  t↩((vi+nVar+≠lits)+↕∘≠)⌾(c⊸/)t
  ⟨a,na⟩←Parse t
  ops←⥊∾⟨
    ∾⟜(0⥊˜3∾˜vi-≠)fntab
    ⍉(Hex¨"20"‿"22"‿"21")∾⌜↕nVar
    ⊣⌜⟜(↕3)(GenF64∘ReadNum¨lits)∾(Hex"10")∾¨3+↕nd
  ⟩
  (((≠∾∾)⟨nLoc∾f64⟩)∾(Hex"0B")∾˜∾)¨((⊢-˜¬×+`)a=2⊑bB)⊔(na+3×a)⊏ops
}

Gen←{
  LEB←{0:⥊0;128⊸+⌾(¯1⊸↓) 2 Base˘ (⌽·∨`·⌽∨´˘)⊸/ 10‿7(⊣⥊×´⊸↑) 64 Enc2 𝕩}
  C←LEB∘≠⊸∾
  S←∾⟜C
  V←≠∾∾
  I←C∘•UCS
  t‿n‿b←𝕩
  ∾⟨
   0∾(•UCS"asm")∾4↑1
   1 S V (96∾⟜∾C¨)¨t
   3 S V ⥊¨↕≠b
   7 S V ⥊<"fn"I⊸(⊣∾0∾⊢)n
  10 S V C¨ b
  ⟩
}

rcp←⟨"x"⟩ GenFn "1÷x"
or←⟨"w","x"⟩ GenFn "(w+x)-w∧x"
Compile←{
  body←GenFn 𝕩
  f←⟨rcp,or,body⟩
  Gen ⟨(≠¨f)/(1‿2‿0∾¨1)⥊¨¨f64 ⋄ 2 ⋄ ∾f⟩
}


# Targetting dzaima/BQN bytecode:

RevE←{
  g←⍋d←+`p←bB(⊣(≠⊸>×¯1⋆2|⊢)⊐)𝕩
  i←(⍋⊏⟜d)⊸⊏/p>0⋄f←(⍋⊏⟜d)⊸⊏/p<0
  l←1+(f-i)⌾((g⊏p<0)⊸/)0¨𝕩
  ps←g⊏(𝕩∊bS)∨p>0
  sl←-⟜(≠↑0∾⊢)(ps∾1)/+`l∾1
  PL←{sl⌾(𝕩⊸/)0¨𝕩}
  ⍋¯1↓+`(⍋0∾1+g)⊏1+((1⊸∾+○PL∾⟜1)ps)-(1⊸∾+∾⟜1)l
}
DParse ← {nv‿r𝕊𝕩:
  rev←RevE𝕩⋄𝕩⊏˜↩rev⋄r⊏˜↩rev
  o←𝕩=0⊑bB⋄g←⍋d←+`o-𝕩=1⊑bB⋄o∨↩𝕩∊bS⋄ps←g⊏o
  xf←⌽(¬o)=○(⌈`(1+↕∘≠)⊸×)○⌽(¯1⌽2≤r)∨1≤r
  𝕩⊏˜↩g⋄r⊏˜↩g⋄v←𝕩≥vi⋄a←𝕩∊2↑bG⋄op←r≥2⋄f←(¯1↓0∾1+g)⊏xf∾0
  tr←ps+`⊸⊏(0∾ps/g)⊏xf
  tf←tr∧2(|<≤)ps(⊢-⌈`∘×)+`¬op
  opa←op>1↓0∾˜ps∨a⋄os←⌽↕∘≠⊸(⊣-⌈`∘×)⌽¬(1⌽r=3)∨¯1⊸⌽⊸∨op
  oa←⌽/opa⋄fa←/(1⌽opa∧r=3)<((tr∨op)<f∨¯1⌽opa)∨tf∧a<○(⌈`(1+↕∘≠)⊸×)ps
  dy←fa⊏1↓0∾˜(tr>tf∨ps)∨v∨f<𝕩=1⊑bB
  n←𝕩≥vi+nv⋄id←/v-n⋄cn←/n∨𝕩≤¯1⊑bC⋄u←⍷ob←cn⊏𝕩
  s←/(𝕩∊bS)>dl←+`(𝕩=4⊑bB)-cl←𝕩=5⊑bB⋄l←/cl⋄ll←1+´¨(dl-1)⊔𝕩∊bS
  or←⍋g⊏˜∾⟨cn,cn,id,id,1+/a,s,l,l,oa+1⌈1-˜oa⊏os,fa+dy⟩
  bc←or⊏∾⟨0¨cn,u⊐ob,1+(id-1)⊏a,vi-˜id⊏𝕩,(11-⊑bG)+a/𝕩
            14¨s,3¨l,ll,5+oa⊏r,5+dy+4×fa⊏tr⟩
  bc‿u
}

prims←⟨
  +,-,×,÷,⋆,√,⌊,⌈,|,¬,∧,∨,<,>,≠,=,≤,≥,≡,≢,⊣,⊢,⥊,∾,≍,↑,↓,↕,⌽,⍉,/,⍋,⍒,⊏,⊑,⊐,⊒,∊,⍷,⊔
  ˜,˘,¨,⌜,⁼,´,`
  ∘,○,⊸,⟜,⌾,⊘,◶,⎉,⚇,⍟
⟩
DGenFn←{
  ⟨t,r,nVar,nLoc,lits⟩←⟨⟩Tokenize𝕩
  ⟨bc,u⟩←nVar‿r DParse t
  o←(u-(vi+nVar-≠prims)×u≥vi)⊏prims∾ReadNum¨lits
  ⟨bc,o,nVar↑•a,⟨⟩⟩
}
DRun←{
  'a' •COMP DGenFn 𝕩
}
