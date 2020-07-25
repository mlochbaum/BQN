# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.bqn %{
    set-option buffer filetype bqn
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=bqn %`
    require-module bqn

    hook window InsertChar \n -group bqn-indent bqn-indent-on-new-line
    hook window InsertChar [}⟩\]] -group bqn-indent bqn-indent-on-closing
    set-option buffer matching_pairs ( ) { } [ ] ⟨ ⟩

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window bqn-.+ }
`

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
add-highlighter shared/bqn/code/ regex "[:;]" 0:bright-black
add-highlighter shared/bqn/code/ regex "[←↩→]" 0:normal
add-highlighter shared/bqn/code/ regex "·" 0:value
add-highlighter shared/bqn/code/ regex "¯?\b((\d+\.)?\d+(e¯?\d+)?|π|∞)(i¯?((\d+\.)?\d+(e¯?\d+)?|π|∞))?" 0:value
add-highlighter shared/bqn/code/ regex "[𝕗𝕘𝕨𝕩𝕤]" 0:normal
add-highlighter shared/bqn/code/ regex "•|•?\b[a-z][A-Z_a-z0-9]*|𝕣" 0:normal
add-highlighter shared/bqn/code/ regex "[𝔽𝔾𝕎𝕏𝕊+\-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍↑↓↕⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!⍕⍎]" 0:green
add-highlighter shared/bqn/code/ regex "•?\b[A-Z][A-Z_a-z0-9]*" 0:green
add-highlighter shared/bqn/code/ regex "[˜˘¨⌜⁼´˝`]" 0:magenta
add-highlighter shared/bqn/code/ regex "•?\b_[A-Za-z][A-Z_a-z0-9]*|_𝕣" 0:magenta
add-highlighter shared/bqn/code/ regex "[∘○⊸⟜⌾⊘◶⎉⚇⍟⎊]" 0:yellow
add-highlighter shared/bqn/code/ regex "•?\b_[A-Za-z][A-Z_a-z0-9]*_|_𝕣_" 0:yellow

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
