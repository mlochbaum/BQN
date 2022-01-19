*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/range_windows.html).*

# Up Down Arrow (`↕`)
    
## `↕ 𝕩`: Range  
    
Return all indices to index into an array of shape `𝕩`, in the shape described by `𝕩`.
    
When given a single number, range from 0 to `𝕩-1`.
    
           ↕ 4

           ↕ 4‿5

    
    
## `𝕨 ↕ 𝕩`: Windows
    
Overlapping slices of `𝕩` which are of shape `𝕨`.
    
           5 ↕ "abcdefg"

           a ← 3‿3⥊↕9

           2‿2 ↕ a

    
