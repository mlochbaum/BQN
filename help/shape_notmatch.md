*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/shape_notmatch.html).*

# Not Identical To (`≢`)
    
## `≢ 𝕩`: Shape
    
Length of each dimension of x.
    
          ≢ 1

          ≢ 1‿2

          ≢ 1‿2 ≍ 3‿4

    
    
## `𝕨 ≢ 𝕩`: Not Match
    
Does `𝕨` not exactly match `𝕩`?
    
          1 ≢ ⟨1⟩

          ⟨1⟩ ≢ ⟨1⟩

    
