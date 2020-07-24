scripte utf-8
let b:keymap_name=expand('<sfile>:t:r')

" Configurable prefix key; backslash by default
let p=exists('g:bqn_prefix_key')?g:bqn_prefix_key:'\'

let a ='`1234567890-= ~!@#$%^&*()_+'
let a.='qwertyuiop[]  QWERTYUIOP{} '
let a.='asdfghjkl;''\ ASDFGHJKL:"| '
let a.='zxcvbnm,./    ZXCVBNM<>?   '

let b ='˜˘¨⁼⌜´˝7∞¯•÷× ¬⎉⚇⍟◶⊘⎊⍎⍕⟨⟩√⋆'
let b.='⌽𝕨∊↑∧y⊔⊏⊐π←→  ↙𝕎⍷𝕣⍋YU⊑⊒⍳⊣⊢ '
let b.='⍉𝕤↕𝕗𝕘⊸∘○⟜⋄↩\  ↖𝕊D𝔽𝔾HJ⌾L·˙| '
let b.='⥊𝕩↓∨⌊n≡∾≍≠    Z𝕏C⍒⌈N≢≤≥?   '

let[A,B]=map([a,b],"split(v:val,'\\zs *')")
for i in range(len(A))|exe escape('lno<buffer>'.p.A[i].' '.B[i],'|')|endfor
for i in range(len(A))|exe escape('cno<buffer>'.p.A[i].' '.B[i],'|')|endfor
lno<buffer>\<space> ‿
cno<buffer>\<space> ‿
unl a b A B i p
