Circle Backslash (`⍉`)

`⍉ 𝕩`: Transpose 

Move the first axis of `𝕩` to the end.
```
   a ← 3‿3 ⥊ ↕9
┌─       
╵ 0 1 2  
  3 4 5  
  6 7 8  
        ┘
   ⍉ a
┌─       
╵ 0 3 6  
  1 4 7  
  2 5 8  
        ┘
   b ← 1‿2‿3 ⥊ ↕6
┌─       
╎ 0 1 2  
  3 4 5  
        ┘
   ≢⍉ b
⟨ 2 3 1 ⟩
```

`𝕨 ⍉ 𝕩`: Dyad

Rearrange the axes of `𝕩` as per the axis indices in `𝕨`.
```
   ≢ a ← 2‿3‿4‿5‿6 ⥊1
⟨ 2 3 4 5 6 ⟩
   ≢ 1‿3‿2‿0‿4 ⍉ a
⟨ 5 2 4 3 6 ⟩
```