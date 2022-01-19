Square Image Of (`⊏`)

`⊏ 𝕩`: First Cell

First major cell of `𝕩`.
```
   ⊏ ⟨1, 2, 3⟩
┌·   
· 1  
    ┘
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   ⊏ a
⟨ 0 1 2 ⟩
```

`𝕨 ⊏ 𝕩`: Select

Select the major cells of `𝕨` at the indices in `𝕩`.
```
   2‿0 ⊏ ⟨1, 2, 3⟩
⟨ 3 1 ⟩
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   2‿0 ⊏ a
┌─       
╵ 6 7 8  
  0 1 2  
        ┘
```