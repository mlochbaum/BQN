#! /usr/bin/env bqn

# WebAssembly backend (very incomplete)

i←"⟨cgl,charSet,Tokenize⟩"
⟨cgl,charSet,Tokenize⟩ ← ⟨•path,"",•Import"src/glyphs.bqn"⟩ •BQN i∾˜•FChars"src/c.bqn"
chF←(⊑cgl)↑charSet
bF‿b1‿b2‿bS‿bH‿bG‿bB‿bL‿bO‿bX‿bN‿bD‿bA‿bW‿bP←≍¨˜⟜(0»+`)cgl
M←1⊸⊑(0⊸≤∧>)-⟜⊑
vi←⊑bN

WParse←{
  a←𝕩M(2≍˜⊑bG)⋄at←1⌽a⋄𝕩/˜↩¬a⋄a/˜↩¬at
  l←≠𝕩⋄sep←𝕩M bS⋄𝕩↩(bF⊑⊸+⊑chF⊐<'⊣')¨⌾(sep⊸/)𝕩⋄sep∨↩𝕩=2+⊑bB
  o←𝕩=⊑bB⋄c←𝕩=1+⊑bB⋄v←a-˜𝕩≥vi⋄f←¬o∨c∨v∨sep
  na←(2×sep)+f×1+l↑0∾c∨v
  d←+`o-c⋄fe←(+`⌾((⍋d)⊸⊏)o)⊏l∾(⍋⊏⟜d)⊸⊏/c
  fe⌊↩l-l↑⌽⌈`↕∘≠⊸×⌽1∾˜sep
  sel←¬∘⊏⟜(o∨c)⊸/⍋((f×fe)⌈↕l)-+`f-l↑/⁼∧f/fe
  sel⊸⊏¨𝕩‿na
}

Base←{+⟜(𝕨⊸×)´𝕩}
Enc2←{2|⌊∘÷⟜2⍟(↕𝕨)𝕩}

Hex←16 Base⟜⌽ (∾"0A"+⟜↕¨10‿6)⊸⊐

GenF64←{
  0:8⥊0;
  l←2(⌊⋆⁼)𝕩
  (Hex"44")∾2 Base˘8‿8⥊∾⟨¯52↑(0⌈l)Enc2𝕩,11 Enc2 1023+l,⥊0⟩
}
MakeTab←{{⊑∘(∾⟜0)¨¯1↓(chF⊐𝕨)⊔○(∾⟜(≠chF))𝕩}○∾⟜(⥊¨∘⥊¨)˝⍉(2(÷˜∾⊣)≢)⊸⥊𝕩}
tab1←MakeTab⟨
  "⊣⊢"     , 2⥊<⟨⟩
  "|-⌈⌊√"  , (Hex"99")+(↕4)∾6
  "÷"      , <(Hex"10")≍0
  "¬"      , <∾⥊¨⟨Hex"9A",GenF64 1,Hex"A0"⟩
⟩
tab2←MakeTab⟨
  "⊣"      , Hex"1A"
  "+-×÷⌊⌈∧", (Hex"A0")+(↕6)∾2
  "¬"      , <∾⥊¨⟨Hex"A1",GenF64 1,Hex"A0"⟩
  "∨"      , <(Hex"10")≍1
⟩
fntab←⍉(0¨tab1)∾tab1≍tab2
f64←127-3

GenFn←{
  ⟨t,r,k⟩←3↑⟨!∘0¨¨,⟨⟩⟩Tokenize𝕩
  nVar←≠⊑k⋄lits←∾1↓k
  nLoc←nVar-𝕨⊢0
  t⊏˜↩⍋+`-˝(2‿3+⊑bB)=⌜t
  nd←+´c←t=3+⊑bB
  t↩((vi+nVar+≠lits)+↕∘≠)⌾(c⊸/)t
  ⟨a,na⟩←WParse t
  ops←⥊∾⟨
    ∾⟜(0⥊˜3≍˜vi-≠)fntab
    ⍉(Hex¨"20"‿"22"‿"21")≍⌜↕nVar
    ⊣⌜⟜(↕3)(GenF64¨lits)∾(Hex"10")≍¨3+↕nd
  ⟩
  (((≠∾∾)⟨nLoc‿f64⟩)∾(Hex"0B")∾˜∾)¨((⊢-˜¬×+`)a=2+⊑bB)⊔(na+3×a)⊏ops
}

Gen←{
  LEB←{0:⥊0;128⊸+⌾(¯1⊸↓) 2 Base˘ (∨`⌾⌽∨˝˘)⊸/ 10‿7(⊣⥊×´⊸↑) 64 Enc2 𝕩}
  C←LEB∘≠⊸∾
  S←∾⟜C
  V←≠∾∾
  I←C-⟜@
  t‿n‿b←𝕩
  ∾⟨
   0∾("asm"-@)∾4↑1
   1 S V (96∾⟜∾C¨)¨t
   3 S V ⥊¨↕≠b
   7 S V ⥊<"fn"I⊸(⊣∾0≍⊢)n
  10 S V C¨ b
  ⟩
}

rcp←1 GenFn "1÷x"
or ←2 GenFn "(w+x)-w∧x"
WCompile←{
  body←GenFn 𝕩
  f←⟨rcp,or,body⟩
  Gen ⟨(≠¨f)/(1‿2‿0≍¨1)⥊¨¨f64 ⋄ 2 ⋄ ∾f⟩
}

•Out ∾((@+10)«·∾(" "∾•Repr)¨)∘WCompile¨ •args
