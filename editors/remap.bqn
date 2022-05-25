#! /usr/bin/env bqn

help ← 1↓"
Remap a BQN keyboard file from qwerty. Options:
  -h, --help: Print this message and exit
  -k: Output keyboard layout
  -i: Input file(s) in editors/
  -o: Output file(s); uses stdout if not given"

o ← "-h"‿"--help"‿"-k"‿"-i"‿"-o"
oo ← (≠o) = oi ← o ⊐ ar←•args
•Exit∘•Out∘help⍟(∨´2⊸>) oi
key‿inp‿out ← 2↓o≠⊸↑ ar ⊔˜ (¬-˜⊢× oi⊏˜ ↕∘≠⌈`∘×¬)oo

A ← {𝕩?@; •Out 𝕨 ⋄ •Exit 1}
"Can only specify one keyboard layout at a time!" A 1≥≠key
"No inputs!" A 0<≠inp
"Requires one output file for each input, or one input and no output to use stdout" A inp=⟜(⊢+0⊸=)○≠out

Map ← {𝕩⊏˜𝕨⊐⊢}
_sl_ ← {𝔽_𝕣_⟨a,b⟩: 𝔽∘((a↓b↓⊢)¨)⊸((a⊸↑∾⊣∾b⊸↑)¨)}

# Key layouts
qwerty ←   "`1234567890-=~!@#$%^&*()_+qwertyuiop[]QWERTYUIOP{}asdfghjkl;'ASDFGHJKL:""|zxcvbnm,./ZXCVBNM<>? "
keys ← ⟨
  "dvorak"‿"`1234567890[]~!@#$%^&*(){}',.pyfgcrl/=""<>PYFGCRL?+aoeuidhtns-AOEUIDHTNS_|;qjkxbmwvz:QJKXBMWVZ "
 "colemak"‿"`1234567890-=~!@#$%^&*()_+qwfpgjluy;[]QWFPGJLUY:{}arstdhneio'ARSTDHNEIO""|zxcvbkm,./ZXCVBKM<>? "
 "workman"‿"`1234567890-=~!@#$%^&*()_+qdrwbjfup;[]QDRWBJFUP:{}ashtgyneoi'ASHTGYNEOI""|zxmcvkl,./ZXMCVKL<>? "
⟩

# 2-modifier: source keymap as 𝕗 and target as 𝕘, file contents 𝕩
files ← ⟨
  "inputrc"‿{
    m ← 𝕗 Map○('"'⊸=◶⟨⥊,"\"⊸∾⟩¨) 𝕘
    {
      c‿d ← ¯6‿¯2
      ((=´c‿d⊸⊏)¨𝕩) (c⌾(d⊸⊑)↕∘≠)⊸⊏∘⊢⍟⊣¨ M _sl_ 3‿¯5 𝕩
    }⌾(9⊸↓)
  }
  "XCompose"‿{
    xc ← Map´ c‿l ← (⊑¨⋈1↓¨⊢) (¯1+`<⟜'a'∨'z'⊸<)⊸⊔ "`grave-minus=equal~asciitilde!exclam@at#numbersign$dollar%percent^circumflex&ampersand*asterisk(parenleft)parenright_underscore+plus[bracketleft]bracketright{braceleft}braceright:colon;semicolon""quotedbl,comma.period/slash<less>greater?question space'apostrophe"
    (𝕗 Map○{⥊¨XC⌾((𝕩∊c)⊸/)𝕩} 𝕘) _sl_ 25‿¯7⌾(4⊸↓)
  }
⟩

_lookup_ ← {
  opt‿res ← <˘⍉>𝕗
  err ← ∾"Invalid "‿𝕘‿"; options:"∾" "⊸∾¨opt
  res ⊏˜ ·(err A ·∧´(≠opt)⊸>)⊸⊢ opt⊸⊐
}
k    ← ⊑ keys  _lookup_ "key layout (-k)"  1↑key∾⟨"dvorak"⟩
conv ←   files _lookup_ "keymap file (-i)" inp
write ← ∾⟜⟨•Out¨⟩⍟(0=≠) {(•wdpath•file.At𝕩)⊸•file.Lines}¨out
{𝕊w‿c‿i: W qwerty _c_ k •file.Lines i}˘ ⍉>write‿conv‿inp
