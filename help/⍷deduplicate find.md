*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/⍷deduplicate find.html).*

# Epsilon Underbar (`⍷`)

`⍷ 𝕩`: Deduplicate

Unique major cells of `𝕩`.

       ⍷ 4‿5‿6‿6‿4‿7‿5
    ⟨ 4 5 6 7 ⟩
       a ← 3‿3 ⥊ ↕6
    ┌─       
    ╵ 0 1 2  
      3 4 5  
      0 1 2  
            ┘
       ⍷ a
    ┌─       
    ╵ 0 1 2  
      3 4 5  
            ┘


`𝕨 ⍷ 𝕩`: Find

Mark the top left location of the occurrences of `𝕨` in `𝕩` with a 1, and other locations with 0.

Result is the same shape as `(≢𝕨)↕x`.

        "string" ⍷ "substring"
    ⟨ 0 0 0 1 ⟩
       "loooooong" ⍷ "short"
    ⟨⟩
       a ← 7 (4|⋆˜)⌜○↕ 9
    ┌─                   
    ╵ 1 1 1 1 1 1 1 1 1  
      0 1 2 3 0 1 2 3 0  
      0 1 0 1 0 1 0 1 0  
      0 1 0 3 0 1 0 3 0  
      0 1 0 1 0 1 0 1 0  
      0 1 0 3 0 1 0 3 0  
      0 1 0 1 0 1 0 1 0  
                        ┘
       b ← (0‿3‿0≍0‿1‿0)
    ┌─       
    ╵ 0 3 0  
      0 1 0  
            ┘
       b ⍷ a
    ┌─               
    ╵ 0 0 0 0 0 0 0  
      0 0 0 0 0 0 0  
      0 0 0 0 0 0 0  
      0 0 1 0 0 0 1  
      0 0 0 0 0 0 0  
      0 0 1 0 0 0 1  
                    ┘

