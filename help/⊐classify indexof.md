Square Original Of (`⊐`)

`⊐ 𝕩`: Classify  

First index of each major cell of `𝕩` in `𝕩`.
```
   ⊐ 5‿6‿2‿2‿5‿1
⟨ 0 1 2 2 0 3 ⟩
   a ← 3‿3 ⥊ 0‿1‿2‿9‿0‿9‿0‿1‿2
┌─       
╵ 0 1 2  
  9 0 9  
  0 1 2  
        ┘
   ⊐ a
⟨ 0 1 0 ⟩
```

`𝕨 ⊐ 𝕩`: Index Of

First index of each major cell of `𝕩` in `𝕨`. Rank of `𝕩` must be at least cell rank of 𝕨`.

If a cell is not found in `𝕨`, that position will contain the length of `𝕨` (`≠𝕨`). 
```
   5‿6‿2‿2‿5‿1 ⊐ 5‿2‿1‿6
⟨ 0 2 5 1 ⟩
   a ← 3‿3 ⥊ 0‿1‿2‿9‿0‿9‿0‿1‿2
┌─       
╵ 0 1 2  
  9 0 9  
  0 1 2  
        ┘
   a ⊐ ⟨9‿0‿9⟩
┌·   
· 3  
    ┘
```