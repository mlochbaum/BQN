*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/↕range windows.html).*

# Up Down Arrow (`↕`)

`↕ 𝕩`: Range  

Return all indices to index into an array of shape `𝕩`, in the shape described by `𝕩`.

When given a single number, range from 0 to `𝕩-1`.

       ↕ 4
    ⟨ 0 1 2 3 ⟩
       ↕ 4‿5
    ┌─                                         
    ╵ ⟨ 0 0 ⟩ ⟨ 0 1 ⟩ ⟨ 0 2 ⟩ ⟨ 0 3 ⟩ ⟨ 0 4 ⟩  
      ⟨ 1 0 ⟩ ⟨ 1 1 ⟩ ⟨ 1 2 ⟩ ⟨ 1 3 ⟩ ⟨ 1 4 ⟩  
      ⟨ 2 0 ⟩ ⟨ 2 1 ⟩ ⟨ 2 2 ⟩ ⟨ 2 3 ⟩ ⟨ 2 4 ⟩  
      ⟨ 3 0 ⟩ ⟨ 3 1 ⟩ ⟨ 3 2 ⟩ ⟨ 3 3 ⟩ ⟨ 3 4 ⟩  
                                              ┘


`𝕨 ↕ 𝕩`: Windows

Overlapping slices of `𝕩` which are of shape `𝕨`.

       5 ↕ "abcdefg"
    ┌─       
    ╵"abcde  
      bcdef  
      cdefg" 
            ┘
       a ← 3‿3⥊↕9
    ┌─       
    ╵ 0 1 2  
      3 4 5  
      6 7 8  
            ┘
       2‿2 ↕ a
    ┌─     
    ┆ 0 1  
      3 4  
           
      1 2  
      4 5  
           
           
      3 4  
      6 7  
           
      4 5  
      7 8  
          ┘

