*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/suffixes_drop.html).*

# Down Arrow (`↓`)
    
## `↓ 𝕩`: Suffixes
    
Suffixes of array `𝕩` along its first axis.
    
           ↓ 1‿2‿3‿4

           a ← 3‿3 ⥊ ↕9

           ↓ a

    
    
## `𝕨 ↓ 𝕩`: Drop
    
For each integer in `𝕨`, drop that many elements from the beginning of each dimension of `𝕩`.
    
Negative numbers drop from the end.
    
           3 ↓ 1‿3‿5‿67

           a ← 4‿4 ⥊ ↕16

           3‿3 ↓ a

           5‿5 ↓ a


           3‿¯3 ↓ a

    
