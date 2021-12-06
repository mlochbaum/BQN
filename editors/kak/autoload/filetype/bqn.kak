# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.bqn %{
    set-option buffer filetype bqn

    set-option buffer matching_pairs ( ) { } [ ] ⟨ ⟩

    map buffer insert '\' '<esc>:enter-user-mode bqn<ret>' -docstring 'enter bqn character'
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=bqn %¹
    require-module bqn

    hook window InsertChar \n -group bqn-indent bqn-indent-on-new-line
    hook window InsertChar [}⟩\]] -group bqn-indent bqn-indent-on-closing

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window bqn-.+ }
¹

hook -group bqn-highlight global WinSetOption filetype=bqn %{
    add-highlighter window/bqn ref bqn
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/bqn }
}

provide-module bqn %¹

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
add-highlighter shared/bqn/code/ regex "(?<![A-Z_a-z0-9π∞¯])¯?(¯_*)?((\d[\d_]*(\.\d[\d_]*)?|π_*)(e_*(¯_*)?\d[\d_]*)?|∞_*)(i_*(¯_*)?((\d[\d_]*(\.\d[\d_]*)?|π_*)(e_*(¯_*)?\d[\d_]*)?|∞_*))?" 0:value
add-highlighter shared/bqn/code/ regex "\." 0:normal
add-highlighter shared/bqn/code/ regex "[𝕗𝕘𝕨𝕩𝕤]" 0:normal
add-highlighter shared/bqn/code/ regex "•|•?\b[a-z][A-Z_a-z0-9π∞¯]*|𝕣" 0:normal
add-highlighter shared/bqn/code/ regex "[𝔽𝔾𝕎𝕏𝕊+\-×÷⋆√⌊⌈|¬∧∨<>≠=≤≥≡≢⊣⊢⥊∾≍⋈↑↓↕«»⌽⍉/⍋⍒⊏⊑⊐⊒∊⍷⊔!⍕⍎]" 0:green
add-highlighter shared/bqn/code/ regex "•?\b[A-Z][A-Z_a-z0-9π∞¯]*" 0:green
add-highlighter shared/bqn/code/ regex "[˙˜˘¨⌜⁼´˝`]" 0:magenta
add-highlighter shared/bqn/code/ regex "•?\b_[A-Za-z][A-Z_a-z0-9π∞¯]*|_𝕣" 0:magenta
add-highlighter shared/bqn/code/ regex "[∘○⊸⟜⌾⊘◶⎉⚇⍟⎊]" 0:yellow
add-highlighter shared/bqn/code/ regex "•?\b_[A-Za-z][A-Z_a-z0-9π∞¯]*_|_𝕣_" 0:yellow

declare-user-mode bqn

#               +              +                   + Conjugate      | Add
#               -              -                   - Negate         | Subtract
map global bqn '='     ':exec i×<ret>' -docstring '× Sign           | Multiply'
map global bqn <minus> ':exec i÷<ret>' -docstring '÷ Recipical      | Divide'
map global bqn '+'     ':exec i⋆<ret>' -docstring '⋆ Exponential    | Power'
map global bqn '_'     ':exec i√<ret>' -docstring '√ Square root    | Root'
map global bqn 'b'     ':exec i⌊<ret>' -docstring '⌊ Floor          | Minimum'
map global bqn 'B'     ':exec i⌈<ret>' -docstring '⌈ Ceiling        | Maximum'
map global bqn 't'     ':exec i∧<ret>' -docstring '∧ SortUp         | And'
map global bqn 'v'     ':exec i∨<ret>' -docstring '∨ SortDown       | Or'
map global bqn '~'     ':exec i¬<ret>' -docstring '¬ Not            | Span'
#               |              |                   | AbsoluteValue  | Modulus
map global bqn '<'     ':exec i≤<ret>' -docstring '≤                | LessOrEqual'
#               <              <                   < Enclose        | LessThan
#               >              >                   > Merge          | GreaterThan
map global bqn '>'     ':exec i><ret>' -docstring '>                | GreaterOrEqual'
#               =              =                   = Rank           | Equal
map global bqn '/'     ':exec i≠<ret>' -docstring '≠ Length         | NotEqual'
map global bqn 'm'     ':exec i≡<ret>' -docstring '≡ Depth          | Match'
map global bqn 'M'     ':exec i≢<ret>' -docstring '≢ Shape          | NotMatch'
map global bqn '{'     ':exec i⊣<ret>' -docstring '⊣ Identity       | Left'
map global bqn '}'     ':exec i⊢<ret>' -docstring '⊢ Identity       | Right'
map global bqn 'z'     ':exec i⥊<ret>' -docstring '⥊ Deshape        | Reshape'
map global bqn ','     ':exec i∾<ret>' -docstring '∾ Join           | JoinTo'
map global bqn '.'     ':exec i≍<ret>' -docstring '≍ Solo           | Couple'
map global bqn 'Z'     ':exec i⋈<ret>' -docstring '⋈ Enclose        | Pair'
map global bqn 'r'     ':exec i↑<ret>' -docstring '↑ Prefixes       | Take'
map global bqn 'c'     ':exec i↓<ret>' -docstring '↓ Suffixes       | Drop'
map global bqn 'd'     ':exec i↕<ret>' -docstring '↕ Range          | Windows'
map global bqn 'H'     ':exec i«<ret>' -docstring '« ShiftBefore    | ReplaceEnd'
map global bqn 'L'     ':exec i»<ret>' -docstring '» ShiftAfter     | ReplaceStart'
map global bqn 'q'     ':exec i⌽<ret>' -docstring '⌽ Reverse        | Rotate'
map global bqn 'a'     ':exec i⍉<ret>' -docstring '⍉ Transpose      | ReorderAxis'
map global bqn 'T'     ':exec i⍋<ret>' -docstring '⍋ GradeUp        | BinsUp'
map global bqn 'V'     ':exec i⍒<ret>' -docstring '⍒ GradeDown      | BinsDown'
map global bqn 'i'     ':exec i⊏<ret>' -docstring '⊏ FirstCell      | Select'
map global bqn 'I'     ':exec i⊑<ret>' -docstring '⊑ First          | Pick'
map global bqn 'o'     ':exec i⊐<ret>' -docstring '⊐ Classify       | IndexOf'
map global bqn 'O'     ':exec i⊒<ret>' -docstring '⊒ VisitCount     | AdvanceIndexOf'
map global bqn 'e'     ':exec i∊<ret>' -docstring '∊ MarkFirst      | MemberOf'
map global bqn 'E'     ':exec i⍷<ret>' -docstring '⍷ Deduplicate    | Find'
map global bqn 'u'     ':exec i⊔<ret>' -docstring '⊔ GroupIndices   | Group'
#               /              /                   / Indices        | Replicate
#               !              !                   ! Assert         | AssertMsg

map global bqn '"'     ':exec i˙<ret>' -docstring '˙ _constant'
map global bqn '`'     ':exec i˜<ret>' -docstring '˜ _self          | _swap'
map global bqn '1'     ':exec i˘<ret>' -docstring '˘ _cells'
map global bqn '2'     ':exec i¨<ret>' -docstring '¨ _each'
map global bqn '3'     ':exec i⁼<ret>' -docstring '⁼ _undo'
map global bqn '4'     ':exec i⌜<ret>' -docstring '⌜ _table'
map global bqn '5'     ':exec i´<ret>' -docstring '´ _fold'
map global bqn '6'     ':exec i˝<ret>' -docstring '˝ _insert'
#               `              `                   ` _scan
map global bqn 'j'     ':exec i∘<ret>' -docstring '∘ _atop_'
map global bqn 'k'     ':exec i○<ret>' -docstring '○ _over_'
map global bqn 'h'     ':exec i⊸<ret>' -docstring '⊸ _bind_before_'
map global bqn 'l'     ':exec i⟜<ret>' -docstring '⟜ _bind_after_'
map global bqn 'K'     ':exec i⌾<ret>' -docstring '⌾ _under_'
map global bqn '%'     ':exec i⊘<ret>' -docstring '⊘ _valences_'
map global bqn '$'     ':exec i◶<ret>' -docstring '◶ _choose_'
map global bqn '^'     ':exec i⎊<ret>' -docstring '⎊ _catch_'
map global bqn '!'     ':exec i⎉<ret>' -docstring '⎉ _rank_'
map global bqn '@'     ':exec i⚇<ret>' -docstring '⚇ _depth_'
map global bqn '#'     ':exec i⍟<ret>' -docstring '⍟ _repeat_'
map global bqn '['     ':exec i←<ret>' -docstring '← DEFINE'
map global bqn '?'     ':exec i⇐<ret>' -docstring '⇐ EXPORT'
map global bqn "'"     ':exec i↩<ret>' -docstring '↩ CHANGE'
map global bqn ';'     ':exec i⋄<ret>' -docstring '⋄ SEPERATOR'
map global bqn '('     ':exec i⟨<ret>' -docstring '⟨ BEGIN LIST'
map global bqn ')'     ':exec i⟩<ret>' -docstring '⟩ END LIST'
map global bqn <space> ':exec i‿<ret>' -docstring '‿ STRAND'
map global bqn ':'     ':exec i·<ret>' -docstring '· NOTHING'
map global bqn '0'     ':exec i•<ret>' -docstring '• SYSTEM'

map global bqn 'w'     ':exec i𝕨<ret>' -docstring '𝕨 left argument'
map global bqn 'W'     ':exec i𝕎<ret>' -docstring '𝕎 left argument function'
map global bqn 'x'     ':exec i𝕩<ret>' -docstring '𝕩 right argument'
map global bqn 'X'     ':exec i𝕏<ret>' -docstring '𝕏 right argument function'
map global bqn 'f'     ':exec i𝕗<ret>' -docstring '𝕗 left operand'
map global bqn 'F'     ':exec i𝔽<ret>' -docstring '𝔽 left operand function'
map global bqn 'g'     ':exec i𝕘<ret>' -docstring '𝕘 right operand'
map global bqn 'G'     ':exec i𝔾<ret>' -docstring '𝔾 right operand function'
map global bqn 's'     ':exec i𝕤<ret>' -docstring '𝕤 self'
map global bqn 'S'     ':exec i𝕊<ret>' -docstring '𝕊 self function'
map global bqn 'R'     ':exec i𝕣<ret>' -docstring '𝕣 self modifier'

map global bqn '9'     ':exec i¯<ret>' -docstring '¯ minus'
map global bqn 'p'     ':exec iπ<ret>' -docstring 'π constant pi'
map global bqn '8'     ':exec i∞<ret>' -docstring '∞ constant infinity'
#               @              @                   @ constant null character
#               #              #                   # COMMENT

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

¹
