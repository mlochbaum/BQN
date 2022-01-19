Del Stile (`⍒`)

`⍒ 𝕩`: Grade Down

Indices of `𝕩` that would sort its major cells in descending order.
```
   a ← 1‿2‿3
⟨ 1 2 3 ⟩
   ⍒ a
⟨ 2 1 0 ⟩
   (⍒a) ⊏ a
⟨ 3 2 1 ⟩ 
```

`𝕨 ⍒ 𝕩`: Bins Down

Binary search for each element of `𝕩` in `𝕨`, and return the index found, if any. 

`𝕨` must be sorted in descending order.

[Right Pervasive.](https://mlochbaum.github.io/BQN/doc/arithmetic.html#pervasion)
```
   7‿5‿4‿3 ⍒ 2
┌·   
· 4  
    ┘
   7‿5‿4‿3 ⍒ 2‿6
⟨ 4 1 ⟩
```