*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/<enclose less.html).*

# Lesser Than (`<`)

`< 𝕩`: Enclose  

Create a unit array containing `𝕩`. (`(≢𝕩) ≡ ⟨⟩`)


      <1
    ┌·   
    · 1  
        ┘
    
      ≢<1
    ⟨⟩


`𝕨 < 𝕩`: Lesser Than

`𝕨` and `𝕩` can both be either numbers or characters.

[Pervasive.](https://mlochbaum.github.io/BQN/doc/arithmetic.html#pervasion)

      1 < 3
    1
      2‿3‿0 < 3‿1‿0
    ⟨ 1 0 0 ⟩

