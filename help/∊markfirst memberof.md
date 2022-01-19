Element Of (`∊`)

`∊ 𝕩`: Unique Mask

Mark the first occurrence of each major cell in `𝕩` with a 1, and all other occurrences with a 0.
```
   ∊ 4‿5‿6‿6‿4‿7‿5
⟨ 1 1 1 0 0 1 0 ⟩
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   ∊ a
⟨ 1 1 1 ⟩
```

`𝕨 ∊ 𝕩`: Member Of

Is each element in `𝕨` a major cell of `𝕩`?
```
   ⟨1⟩ ∊ ↕9
⟨ 1 ⟩
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   ⟨0‿1‿2⟩ ∊ a
┌·   
· 0  
    ┘
   ⟨1‿3 ⥊ 0‿1‿2⟩ ∊ a
⟨ 1 ⟩
```