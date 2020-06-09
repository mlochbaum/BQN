#!/usr/bin/env bqn

⊔↩((↕1+(>⌈´))=¨<)∘⊣ /¨⟜< ↕∘≠⍠⊢

Parse←{
  ⟨⟩Parse𝕩;args←𝕨⋄x←𝕩
  lf‿tab←•UCS 10‿9
  x(/˜)↩¬(x∊' '∾tab)∨<○(⌈`↕∘≠⊸×)´(lf∾'⍝')=⌜x
  seps←"⋄,"∾lf⋄x(/˜)↩¬(1⌾⊑1⌽1⌾⊑)⊸∧x∊seps
  a←x∊"←↩"⋄at←1⌽a⋄vars←at/x⋄x(/˜)↩¬a⋄a(/˜)↩¬at
  l←≠x⋄sep←x∊seps⋄x↩'⋄'¨⌾(sep⊸/)x
  o←x='('⋄c←x=')'⋄v←a-˜x∊•d∾args∾vars⋄f←¬o∨c∨v∨sep
  na←(2×sep)+f×1+l↑0∾c∨v
  e←/c⋄d←+`o-c
  ed←e⊏d⋄b←(⍋⍋ed)⊏(⍋⊏⟜d)⊸⊏/o
  g←⊔ed∾0⋄s←e-(e⊏˜∾(⍋⊏⊣)¨´⍉2↕g)⌾((∾1↓g)⊸⊏)l¨e
  fe←f×(l-1)++`(-⊸≍s)⌾((e≍b)⊸⊏)l⥊0
  fe⌊↩(l-1)-l↑(⌈`↕∘≠⊸×)⌾⌽1∾˜sep
  ia←+`l↑0∾f-l↑/⁼∧f/fe
  sel←¬∘⊏⟜(o∨c)⊸/⍋(fe⌈↕l)-ia
  ⟨sel⊸⊏¨x‿na,args∾vars,vars⟩
}

f64←127-3
GenFn←{
  ⟨x‿na,vars,locs⟩←𝕩
  D←16⊥(•d∾"ABCDEF")⊸⊐
  fns←{
    n←•d⊐<𝕩
    n=≠•d:(D"20")∾vars⊐<𝕩
    n=0:8⥊0
    l←2(⌊⋆⁼)n
    (D"44")∾2⊥˘⌽8‿8(⊣⥊×´⊸↑)∾⟨⥊0,(11⥊2)⊤1023+l,(2⥊˜0⌈l)⊤n⟩
  }‿{
    v←vars⊐<𝕩⋄v<≠vars:(D"22")∾v
    ((<(D"10")∾1)∾˜⥊¨(D"99")+((↕4)∾6))⊑˜"|-⌈⌊√÷"⊐<𝕩
  }‿{
    (⥊¨(D"1A")∾(D"A0")+↕6)⊑˜"⋄+-×÷⌊⌈"⊐<𝕩
  }
  ((≠∾∾)⟨locs≠⊸∾f64⟩)∾(D"0B")∾˜∾na⊑⟜fns⊸{𝕎𝕩}¨x
}

Gen←{
  LEB←{0≡𝕩:⥊0⋄128⊸+⌾(¯1⊸↓) 2⊥⌽⍉ (∨`⌾⌽∨´˘)⊸/ 10‿7(⊣⥊×´⊸↑) ⍉⌽(8⥊2)⊤𝕩}
  C←LEB∘≠⊸∾
  S←∾⟜C
  V←≠∾∾
  I←C∘•UCS
  t‿n‿b←𝕩
  ∾⟨
   0∾(•UCS"asm")∾4↑1
   1 S V (96∾⟜∾C¨)¨t
   3 S V ⥊¨↕≠b
   7 S V I⊸(⊣∾0∾⊢)¨⟜(↕∘≠)n
  10 S V C¨ b
  ⟩
}

Compile←{
  body←GenFn∘Parse 𝕩
  rcp←"x" GenFn∘Parse "1÷x"
  (1↓∾)(","∾⥊∘⍕)¨ Gen ⟨⟨0‿1,1‿1⟩/¨¨f64 ⋄ ⥊<"fn" ⋄ ⟨body,rcp⟩⟩
}
•←Compile "b←3⋄d←(b×b)-4×2×1⋄((-b)+√d)÷2×2"
