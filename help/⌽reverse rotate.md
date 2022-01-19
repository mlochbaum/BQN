Circle Stile (`⌽`)

`⌽ 𝕩`: Reverse  

Reverse the first axis of `𝕩`.
```
   ⌽ 1‿2‿3
⟨ 3 2 1 ⟩
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   ⌽ a
┌─       
╵ 6 7 8  
  3 4 5  
  0 1 2  
        ┘
```

`𝕨 ⌽ 𝕩`: Dyad

Move the first `𝕨` elements of `𝕩` to its end. Negative `𝕨` reverses the direction of rotation.
```
   2 ⌽ 1‿2‿3
⟨ 3 1 2 ⟩
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   2 ⌽ a
┌─       
╵ 6 7 8  
  0 1 2  
  3 4 5  
        ┘
```