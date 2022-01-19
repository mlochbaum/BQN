*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/˘cells.html).*

# Breve (`˘`)

`𝔽˘ 𝕩`, `𝕨 𝔽˘ 𝕩`: Cells

Apply `𝔽` to/between the major cells of the arguments. (`𝔽⎉¯1`)

       a ← 3‿3 ⥊ ↕9
    ┌─       
    ╵ 0 1 2  
      3 4 5  
      6 7 8  
            ┘
       <˘ a
    ⟨ ⟨ 0 1 2 ⟩ ⟨ 3 4 5 ⟩ ⟨ 6 7 8 ⟩ ⟩
       a ≍˘ a
    ┌─       
    ╎ 0 1 2  
      0 1 2  
             
      3 4 5  
      3 4 5  
             
      6 7 8  
      6 7 8  
            ┘

