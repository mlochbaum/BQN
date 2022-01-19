Up Arrow (`↑`)

`↑ 𝕩`: Prefixes

Prefixes of array `𝕩` along its first axis.
```
   ↑ 1‿2‿3‿4
⟨ ⟨⟩ ⟨ 1 ⟩ ⟨ 1 2 ⟩ ⟨ 1 2 3 ⟩ ⟨ 1 2 3 4 ⟩ ⟩
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   ↑ a
┌─                                    
· ↕0‿3 ┌─        ┌─        ┌─         
       ╵ 0 1 2   ╵ 0 1 2   ╵ 0 1 2    
               ┘   3 4 5     3 4 5    
                         ┘   6 7 8    
                                   ┘  
                                     ┘
```

`𝕨 ↑ 𝕩`: Take

For each integer in `𝕨`, take that many elements from each dimension of `𝕩`.

Negative numbers take from the end.

If any of the elements in `𝕨` are greater than the length of their respective dimension, the dimension is extended with a fill value.
```
  3 ↑ 1‿3‿5‿67
⟨ 1 3 5 ⟩
  a ← 4‿4 ⥊ ↕16
┌─             
╵  0  1  2  3  
   4  5  6  7  
   8  9 10 11  
  12 13 14 15  
              ┘
  3‿3 ↑ a
┌─        
╵ 0 1  2  
  4 5  6  
  8 9 10  
         ┘
  5‿5 ↑ a
┌─               
╵  0  1  2  3 0  
   4  5  6  7 0  
   8  9 10 11 0  
  12 13 14 15 0  
   0  0  0  0 0  
                ┘
  3‿¯3 ↑ a
┌─         
╵ 1  2  3  
  5  6  7  
  9 10 11  
          ┘
```