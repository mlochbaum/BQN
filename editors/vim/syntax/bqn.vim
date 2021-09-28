if exists('b:current_syntax')
  finish
endif

syn match bqnerr "[^ \r\n]"
syn match bqnblk "[{}]"
syn match bqnlst "[⟨⟩\[\]‿]"
syn match bqnpar "[()]"
syn match bqnhed "[:;?]"
syn match bqnsep "[⋄,]"
syn match bqnarw "[←⇐↩→]"
syn match bqnchr "'.'"
syn match bqn1md "[˙˜˘¨⌜⁼´˝`]"
syn match bqn2md "[∘○⊸⟜⌾⊘◶⎉⚇⍟⎊]"
syn match bqnfun "[𝔽𝔾𝕎𝕏𝕊+\-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!⍕⍎]"
syn match bqnsub "[𝕗𝕘𝕨𝕩𝕤]"
syn match bqnnot "·"
syn match bqnnul "@"
syn match bqnnum "\v\c¯?((\d+\.)?\d+(e¯?\d+)?|π|∞)(i¯?((\d+\.)?\d+(e¯?\d+)?|π|∞))?"
syn match bqnsid "\(•\|•\?[a-z][A-Z_a-z0-9π∞¯]*\|𝕣\)"
syn match bqnfid "•\?[A-Z][A-Z_a-z0-9π∞¯]*"
syn match bqn1id "\(•\?_[A-Za-z][A-Z_a-z0-9π∞¯]*\|_𝕣\)"
syn match bqn2id "\(•\?_[A-Za-z][A-Z_a-z0-9π∞¯]*_\|_𝕣_\)"
syn match bqndot "\."
syn match bqncom "#.*$"
syn match bqnquo /""/ contained
syn region bqnstr matchgroup=bqnstr start=/"/ end=/"/ contains=bqnquo
syn sync fromstart

hi link bqnerr error
hi link bqncom comment
hi link bqnblk special
hi link bqnhed delimiter
hi link bqnpar delimiter
hi link bqnlst preproc
hi link bqnsep preproc
hi link bqnarw normal
hi link bqnchr string
hi link bqnnul string
hi link bqnstr string
hi link bqnquo specialchar
hi link bqnnum number
hi link bqnnot constant
hi link bqndot normal
hi link bqnsub normal
hi link bqnsid normal
hi link bqnfun type
hi link bqnfid type
hi link bqn1md macro
hi link bqn1id macro
hi link bqn2md operator
hi link bqn2id operator

let b:current_syntax='bqn'
