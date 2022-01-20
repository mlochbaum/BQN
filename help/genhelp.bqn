#!/usr/bin/env cbqn

thing ← {
    data ← •FLines 𝕩
    names ← (⊣∾", "∾⊢)´{(¬·∧`' '⊸=)⊸/⌾⌽(2+⊑/':'=𝕩)↓𝕩}¨("## "≡3⊸↑)¨⊸/data
    t‿d ←  ∾/¨(⊏data)=¨"()"
    sym ← "`"∾˜"`"∾{'`':"` ` `"; '|':"\"∾𝕩 ; 𝕩}¯3⊑2⊑data
    •Show  "| " ∾ sym ∾ " | [" ∾ names ∾ "]("∾𝕩∾ ") |"
}¨•args(¬∘∊/⊣)⟨"README.md"⟩

head ← ⟨
"*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/index.html).*"
⟨⟩
"# REPL Help"
⟨⟩
"Symbols are listed in alphabetical order of page name, ignoring syntactical roles."
⟨⟩
"| Symbol | Link |"
"|--------|------|"
⟩
"README.md" •FLines head ∾ thing #rename once you have a proper file.