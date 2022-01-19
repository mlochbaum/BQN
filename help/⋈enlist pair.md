*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/⋈enlist pair.html).*

# Bow Tie (`⋈`)

`⋈ 𝕩`: Enlist 

Put `𝕩` in a single element list. (`⟨𝕩⟩`)

      ⋈ 1
    ⟨ 1 ⟩
      ⋈ 4‿4 ⥊ 3‿67‿8‿0
    ┌─              
    · ┌─            
      ╵ 3 67 8 0    
        3 67 8 0    
        3 67 8 0    
        3 67 8 0    
                 ┘  
                   ┘


`𝕨 ⋈ 𝕩`: Pair

Put `𝕨` and `𝕩` in a two element list. (`⟨𝕨, 𝕩⟩`)

      1 ⋈ 2
    ⟨ 1 2 ⟩
      1 ⋈ "dsdasdas"
    ⟨ 1 "dsdasdas" ⟩
      (3‿3 ⥊ 3) ⋈ 67‿'a'‿"example"
    ┌─                                
    · ┌─        ⟨ 67 'a' "example" ⟩  
      ╵ 3 3 3                         
        3 3 3                         
        3 3 3                         
              ┘                       
                                     ┘

