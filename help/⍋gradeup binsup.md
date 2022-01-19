Delta Stile (`⍋`)

`⍋ 𝕩`: Grade Up

Indices of `𝕩` that would sort its major cells in ascending order.
```
   a ← 3‿2‿1
⟨ 3 2 1 ⟩
   ⍋ a
⟨ 2 1 0 ⟩
   (⍋a) ⊏ a
⟨ 1 2 3 ⟩
   
```

`𝕨 ⍋ 𝕩`: Bins Up

Binary search for each element of `𝕩` in `𝕨`, and return the index found, if any. 

`𝕨` must be sorted in ascending order.
```
   3‿4‿5‿7 ⍋ 2
┌·   
· 0  
    ┘
   3‿4‿5‿7 ⍋ 2‿6
⟨ 0 3 ⟩
```