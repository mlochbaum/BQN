*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/⎉rank.html).*

# Circled Horizontal Bar With Notch (`⎉`)

`𝔽⎉𝕘 𝕩`, `𝕨 𝔽⎉𝕘 𝕩`: Rank

Apply `𝔽` to cells at ranks given in `𝕘`.

The ranks applied are given by the following:

- `⎉ c`    Rank-c cells of `𝕩` (monadic) or both arguments (dyadic)
- `⎉ b‿c`   ⍝ Rank-b cells of `𝕨` and rank-c cells of `𝕩` (dyadic)
- `⎉ a‿b‿c`   ⍝ Rank-a cells of `𝕩` (monadic), b-cells of `𝕨` and c-cells of `𝕩` (dyadic)


       a ← 3‿2‿4⥊"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    ┌─      
    ╎"ABCD  
      EFGH  
            
     ·IJKL  
      MNOP  
            
     ·QRST  
      UVWX" 
           ┘
       ⌽⎉2 a
    ┌─      
    ╎"EFGH  
      ABCD  
            
     ·MNOP  
      IJKL  
            
     ·UVWX  
      QRST" 
           ┘

