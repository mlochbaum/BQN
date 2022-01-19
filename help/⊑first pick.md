Square Image Of Or Equal To (`⊑`)

`⊑ 𝕩`: First

First element of `𝕩`.
```
   ⊑ ⟨1, 2, 3⟩
1
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   ⊑ a
0
```

`𝕨 ⊑ 𝕩`: Pick

Pick the element of `𝕨` at index `𝕩`.
```
   2 ⊑ ⟨1, 2, 3⟩
3
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   2‿0 ⊑ a
6
```