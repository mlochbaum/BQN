#!/usr/bin/env bqn

thing ← {
    data ← •FLines 𝕩
    names ← (⊣∾", "∾⊢)´{(¬·∧`' '⊸=)⊸/⌾⌽(2+⊑/':'=𝕩)↓𝕩}¨("## "≡3⊸↑)¨⊸/data
    t‿d ←  ∾/¨(⊏data)=¨"()"
    sym ← (+`·»⊸-˝(¬»∧«)∘=⟜'`'∧⎉1"()"=⌜⊢)⊸/ 2⊑data
    sym (1+'|'⊸=)⊸(/+(-´"\|")×{«⊒/𝕨})↩
    "| " ∾ sym ∾ " | [" ∾ names ∾ "]("∾𝕩∾ ") |"
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
