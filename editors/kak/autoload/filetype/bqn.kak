# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.bqn %{
    set-option buffer filetype bqn
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=bqn %¹
    require-module bqn

    hook window InsertChar \n -group bqn-indent bqn-indent-on-new-line
    hook window InsertChar [}⟩\]] -group bqn-indent bqn-indent-on-closing
    set-option buffer matching_pairs ( ) { } [ ] ⟨ ⟩

    declare-user-mode bqn
    map buffer insert '\' '<esc>:enter-user-mode bqn<ret>' -docstring 'enter bqn character'

    evaluate-commands %sh²
        a='`1234567890=' ;a+='~!@#$%^&*()_+'
        a+='qwertyuiop[]';a+='QWERTYUIOP{}'
        a+='asdfghjkl;\' ;a+='ASDFGHJKL:"|'
        a+='zxcvbnm,./'  ;a+='ZXCVBNM<>?'

        b='˜˘¨⁼⌜´˝7∞¯•×' ;b+='¬⎉⚇⍟◶⊘⎊⍎⍕⟨⟩√⋆'
        b+='⌽𝕨∊↑∧y⊔⊏⊐π←→';b+='↙𝕎⍷𝕣⍋YU⊑⊒⍳⊣⊢'
        b+='⍉𝕤↕𝕗𝕘⊸∘○⟜⋄\' ;b+='↖𝕊D𝔽𝔾«J⌾»·˙|'
        b+='⥊𝕩↓∨⌊n≡∾≍≠'  ;b+='Z𝕏C⍒⌈N≢≤≥⇐'

        for (( i=0; i<${#a}; i++ )); do
            o=${b:$i:1}
            echo "map buffer bqn '${a:$i:1}' ':exec i$o<ret>' -docstring '$o'"
        done
    ²
    map buffer bqn <minus> ':exec i÷<ret>' -docstring '÷'
    map buffer bqn "'"     ':exec i↩<ret>' -docstring '↩'
    map buffer bqn <space> ':exec i‿<ret>' -docstring '‿'

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window bqn-.+ }
¹

hook -group bqn-highlight global WinSetOption filetype=bqn %{
    add-highlighter window/bqn ref bqn
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/bqn }
}


provide-module bqn %~

# Highlighters & Completion
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/bqn regions
add-highlighter shared/bqn/code default-region group
add-highlighter shared/bqn/comment region "#" "$" fill comment
add-highlighter shared/bqn/string  region '"' '"' fill string
add-highlighter shared/bqn/char    region "'.'" "()" fill string

add-highlighter shared/bqn/code/ regex "[{}]" 0:meta
add-highlighter shared/bqn/code/ regex "[⋄,]" 0:meta
add-highlighter shared/bqn/code/ regex "[⟨⟩\[\]‿]" 0:magenta
add-highlighter shared/bqn/code/ regex "[()]" 0:bright-black
add-highlighter shared/bqn/code/ regex "[:;?]" 0:bright-black
add-highlighter shared/bqn/code/ regex "[←⇐↩→]" 0:normal
add-highlighter shared/bqn/code/ regex "·" 0:value
add-highlighter shared/bqn/code/ regex "@" 0:string
add-highlighter shared/bqn/code/ regex "(?<![A-Z_a-z0-9π∞¯])¯?((\d+\.)?\d+(e¯?\d+)?|π|∞)(i¯?((\d+\.)?\d+(e¯?\d+)?|π|∞))?" 0:value
add-highlighter shared/bqn/code/ regex "\." 0:normal
add-highlighter shared/bqn/code/ regex "[𝕗𝕘𝕨𝕩𝕤]" 0:normal
add-highlighter shared/bqn/code/ regex "•|•?\b[a-z][A-Z_a-z0-9π∞¯]*|𝕣" 0:normal
add-highlighter shared/bqn/code/ regex "[𝔽𝔾𝕎𝕏𝕊+\-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!⍕⍎]" 0:green
add-highlighter shared/bqn/code/ regex "•?\b[A-Z][A-Z_a-z0-9π∞¯]*" 0:green
add-highlighter shared/bqn/code/ regex "[˙˜˘¨⌜⁼´˝`]" 0:magenta
add-highlighter shared/bqn/code/ regex "•?\b_[A-Za-z][A-Z_a-z0-9π∞¯]*|_𝕣" 0:magenta
add-highlighter shared/bqn/code/ regex "[∘○⊸⟜⌾⊘◶⎉⚇⍟⎊]" 0:yellow
add-highlighter shared/bqn/code/ regex "•?\b_[A-Za-z][A-Z_a-z0-9π∞¯]*_|_𝕣_" 0:yellow

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden bqn-indent-on-new-line %`
    evaluate-commands -draft -itersel %_
        # preserve previous line indent
        try %{ execute-keys -draft <semicolon> K <a-&> }
        # copy # comments prefix
        try %{ execute-keys -draft <semicolon><c-s>k<a-x> s ^\h*\K#+\h* <ret> y<c-o>P<esc> }
        # indent after lines ending with { ⟨ [
        try %( execute-keys -draft k<a-x> <a-k> [{⟨\[]\h*$ <ret> j<a-gt> )
        # cleanup trailing white spaces on the previous line
        try %{ execute-keys -draft k<a-x> s \h+$ <ret>d }
     _
`

define-command -hidden bqn-indent-on-closing %`
    evaluate-commands -draft -itersel %_
        # align to opening bracket
        try %( execute-keys -draft <a-h> <a-k> ^\h*[}⟩\]]$ <ret> h m <a-S> 1<a-&> )
    _
`

~
