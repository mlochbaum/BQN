*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/∾join jointo.html).*

# Lazy S (`∾`)

`∾ 𝕩`: Join  

Join all elements of `𝕩` together.

Element ranks must be compatible.

       ∾ ⟨1‿2, 3, 4‿5⟩
    ⟨ 1 2 3 4 5 ⟩
       m ← (3‿1≍⌜4‿2‿5) ⥊¨ 2‿3⥊↕6
    ┌─                                   
    ╵ ┌─          ┌─      ┌─             
      ╵ 0 0 0 0   ╵ 1 1   ╵ 2 2 2 2 2    
        0 0 0 0     1 1     2 2 2 2 2    
        0 0 0 0     1 1     2 2 2 2 2    
                ┘       ┘             ┘  
      ┌─          ┌─      ┌─             
      ╵ 3 3 3 3   ╵ 4 4   ╵ 5 5 5 5 5    
                ┘       ┘             ┘  
                                        ┘
       ∾ m
    ┌─                       
    ╵ 0 0 0 0 1 1 2 2 2 2 2  
      0 0 0 0 1 1 2 2 2 2 2  
      0 0 0 0 1 1 2 2 2 2 2  
      3 3 3 3 4 4 5 5 5 5 5  
                            ┘


`𝕨 ∾ 𝕩`: Join

Join `𝕨` to `𝕩` along the first axis.

       "abcd" ∾ "EFG"
    "abcdEFG"
       a ← 3‿3 ⥊ ↕9
    ┌─       
    ╵ 0 1 2  
      3 4 5  
      6 7 8  
            ┘
       c ← 4‿3 ⥊ ↕12 
    ┌─         
    ╵ 0  1  2  
      3  4  5  
      6  7  8  
      9 10 11  
              ┘
       a∾c
    ┌─         
    ╵ 0  1  2  
      3  4  5  
      6  7  8  
      0  1  2  
      3  4  5  
      6  7  8  
      9 10 11  
              ┘

