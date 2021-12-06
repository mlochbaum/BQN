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

    #               +              +                   + Conjugate      | Add
    #               -              -                   - Negate         | Subtract
    map buffer bqn '='     ':exec i×<ret>' -docstring '× Sign           | Multiply'
    map buffer bqn <minus> ':exec i÷<ret>' -docstring '÷ Reciprocal     | Divide'
    map buffer bqn '+'     ':exec i⋆<ret>' -docstring '⋆ Exponential    | Power'
    map buffer bqn '_'     ':exec i√<ret>' -docstring '√ Square root    | Root'
    map buffer bqn 'b'     ':exec i⌊<ret>' -docstring '⌊ Floor          | Minimum'
    map buffer bqn 'B'     ':exec i⌈<ret>' -docstring '⌈ Ceiling        | Maximum'
    map buffer bqn 't'     ':exec i∧<ret>' -docstring '∧ SortUp         | And'
    map buffer bqn 'v'     ':exec i∨<ret>' -docstring '∨ SortDown       | Or'
    map buffer bqn '~'     ':exec i¬<ret>' -docstring '¬ Not            | Span'
    #               |              |                   | AbsoluteValue  | Modulus
    map buffer bqn '<'     ':exec i≤<ret>' -docstring '≤                | LessOrEqual'
    #               <              <                   < Enclose        | LessThan
    #               >              >                   > Merge          | GreaterThan
    map buffer bqn '>'     ':exec i><ret>' -docstring '>                | GreaterOrEqual'
    #               =              =                   = Rank           | Equal
    map buffer bqn '/'     ':exec i≠<ret>' -docstring '≠ Length         | NotEqual'
    map buffer bqn 'm'     ':exec i≡<ret>' -docstring '≡ Depth          | Match'
    map buffer bqn 'M'     ':exec i≢<ret>' -docstring '≢ Shape          | NotMatch'
    map buffer bqn '{'     ':exec i⊣<ret>' -docstring '⊣ Identity       | Left'
    map buffer bqn '}'     ':exec i⊢<ret>' -docstring '⊢ Identity       | Right'
    map buffer bqn 'z'     ':exec i⥊<ret>' -docstring '⥊ Deshape        | Reshape'
    map buffer bqn ','     ':exec i∾<ret>' -docstring '∾ Join           | JoinTo'
    map buffer bqn '.'     ':exec i≍<ret>' -docstring '≍ Solo           | Couple'
    map buffer bqn 'Z'     ':exec i⋈<ret>' -docstring '⋈ Enclose        | Pair'
    map buffer bqn 'r'     ':exec i↑<ret>' -docstring '↑ Prefixes       | Take'
    map buffer bqn 'c'     ':exec i↓<ret>' -docstring '↓ Suffixes       | Drop'
    map buffer bqn 'd'     ':exec i↕<ret>' -docstring '↕ Range          | Windows'
    map buffer bqn 'H'     ':exec i«<ret>' -docstring '« ShiftBefore    | ReplaceEnd'
    map buffer bqn 'L'     ':exec i»<ret>' -docstring '» ShiftAfter     | ReplaceStart'
    map buffer bqn 'q'     ':exec i⌽<ret>' -docstring '⌽ Reverse        | Rotate'
    map buffer bqn 'a'     ':exec i⍉<ret>' -docstring '⍉ Transpose      | ReorderAxis'
    map buffer bqn 'T'     ':exec i⍋<ret>' -docstring '⍋ GradeUp        | BinsUp'
    map buffer bqn 'V'     ':exec i⍒<ret>' -docstring '⍒ GradeDown      | BinsDown'
    map buffer bqn 'i'     ':exec i⊏<ret>' -docstring '⊏ FirstCell      | Select'
    map buffer bqn 'I'     ':exec i⊑<ret>' -docstring '⊑ First          | Pick'
    map buffer bqn 'o'     ':exec i⊐<ret>' -docstring '⊐ Classify       | IndexOf'
    map buffer bqn 'O'     ':exec i⊒<ret>' -docstring '⊒ VisitCount     | AdvanceIndexOf'
    map buffer bqn 'e'     ':exec i∊<ret>' -docstring '∊ MarkFirst      | MemberOf'
    map buffer bqn 'E'     ':exec i⍷<ret>' -docstring '⍷ Deduplicate    | Find'
    map buffer bqn 'u'     ':exec i⊔<ret>' -docstring '⊔ GroupIndices   | Group'
    #               /              /                   / Indices        | Replicate
    #               !              !                   ! Assert         | AssertMsg

    map buffer bqn '"'     ':exec i˙<ret>' -docstring '˙ _constant'
    map buffer bqn '`'     ':exec i˜<ret>' -docstring '˜ _self          | _swap'
    map buffer bqn '1'     ':exec i˘<ret>' -docstring '˘ _cells'
    map buffer bqn '2'     ':exec i¨<ret>' -docstring '¨ _each'
    map buffer bqn '3'     ':exec i⁼<ret>' -docstring '⁼ _undo'
    map buffer bqn '4'     ':exec i⌜<ret>' -docstring '⌜ _table'
    map buffer bqn '5'     ':exec i´<ret>' -docstring '´ _fold'
    map buffer bqn '6'     ':exec i˝<ret>' -docstring '˝ _insert'
    #               `              `                   ` _scan
    map buffer bqn 'j'     ':exec i∘<ret>' -docstring '∘ _atop_'
    map buffer bqn 'k'     ':exec i○<ret>' -docstring '○ _over_'
    map buffer bqn 'h'     ':exec i⊸<ret>' -docstring '⊸ _bind_before_'
    map buffer bqn 'l'     ':exec i⟜<ret>' -docstring '⟜ _bind_after_'
    map buffer bqn 'K'     ':exec i⌾<ret>' -docstring '⌾ _under_'
    map buffer bqn '%'     ':exec i⊘<ret>' -docstring '⊘ _valences_'
    map buffer bqn '$'     ':exec i◶<ret>' -docstring '◶ _choose_'
    map buffer bqn '^'     ':exec i⎊<ret>' -docstring '⎊ _catch_'
    map buffer bqn '!'     ':exec i⎉<ret>' -docstring '⎉ _rank_'
    map buffer bqn '@'     ':exec i⚇<ret>' -docstring '⚇ _depth_'
    map buffer bqn '#'     ':exec i⍟<ret>' -docstring '⍟ _repeat_'
    map buffer bqn '['     ':exec i←<ret>' -docstring '← DEFINE'
    map buffer bqn '?'     ':exec i⇐<ret>' -docstring '⇐ EXPORT'
    map buffer bqn "'"     ':exec i↩<ret>' -docstring '↩ CHANGE'
    map buffer bqn ';'     ':exec i⋄<ret>' -docstring '⋄ SEPARATOR'
    map buffer bqn '('     ':exec i⟨<ret>' -docstring '⟨ BEGIN LIST'
    map buffer bqn ')'     ':exec i⟩<ret>' -docstring '⟩ END LIST'
    map buffer bqn <space> ':exec i‿<ret>' -docstring '‿ STRAND'
    map buffer bqn ':'     ':exec i·<ret>' -docstring '· NOTHING'
    map buffer bqn '0'     ':exec i•<ret>' -docstring '• SYSTEM'

    map buffer bqn 'w'     ':exec i𝕨<ret>' -docstring '𝕨 left argument'
    map buffer bqn 'W'     ':exec i𝕎<ret>' -docstring '𝕎 left argument function'
    map buffer bqn 'x'     ':exec i𝕩<ret>' -docstring '𝕩 right argument'
    map buffer bqn 'X'     ':exec i𝕏<ret>' -docstring '𝕏 right argument function'
    map buffer bqn 'f'     ':exec i𝕗<ret>' -docstring '𝕗 left operand'
    map buffer bqn 'F'     ':exec i𝔽<ret>' -docstring '𝔽 left operand function'
    map buffer bqn 'g'     ':exec i𝕘<ret>' -docstring '𝕘 right operand'
    map buffer bqn 'G'     ':exec i𝔾<ret>' -docstring '𝔾 right operand function'
    map buffer bqn 's'     ':exec i𝕤<ret>' -docstring '𝕤 self'
    map buffer bqn 'S'     ':exec i𝕊<ret>' -docstring '𝕊 self function'
    map buffer bqn 'R'     ':exec i𝕣<ret>' -docstring '𝕣 self modifier'

    map buffer bqn '9'     ':exec i¯<ret>' -docstring '¯ minus'
    map buffer bqn 'p'     ':exec iπ<ret>' -docstring 'π constant pi'
    map buffer bqn '8'     ':exec i∞<ret>' -docstring '∞ constant infinity'
    # @ constant null character
    # # COMMENT

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
