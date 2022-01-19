*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/↓suffixes drop.html).*

# Down Arrow (`↓`)

`↓ 𝕩`: Suffixes

Suffixes of array `𝕩` along its first axis.

       ↓ 1‿2‿3‿4
    ⟨ ⟨ 1 2 3 4 ⟩ ⟨ 2 3 4 ⟩ ⟨ 3 4 ⟩ ⟨ 4 ⟩ ⟨⟩ ⟩
       a ← 3‿3 ⥊ ↕9
    ┌─       
    ╵ 0 1 2  
      3 4 5  
      6 7 8  
            ┘
       ↓ a
    ┌─                                    
    · ┌─        ┌─        ┌─        ↕0‿3  
      ╵ 0 1 2   ╵ 3 4 5   ╵ 6 7 8         
        3 4 5     6 7 8           ┘       
        6 7 8           ┘                 
              ┘                           
                                         ┘


`𝕨 ↓ 𝕩`: Drop

For each integer in `𝕨`, drop that many elements from the beginning of each dimension of `𝕩`.

Negative numbers drop from the end.

       3 ↓ 1‿3‿5‿67
    ⟨ 67 ⟩
       a ← 4‿4 ⥊ ↕16
    ┌─             
    ╵  0  1  2  3  
       4  5  6  7  
       8  9 10 11  
      12 13 14 15  
                  ┘
       3‿3 ↓ a
    ┌─    
    ╵ 15  
         ┘
       5‿5 ↓ a
    ┌┐
    └┘
       3‿¯3 ↓ a
    ┌─    
    ╵ 12  
         ┘

