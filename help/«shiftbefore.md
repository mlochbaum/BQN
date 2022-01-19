Left Pointing Double Angle Quotation (`«`)

`« 𝕩`: Shift Before

Remove the first element of `𝕩`,  add a cell of fill values to the end of the first axis of `𝕩`.
```
   78 « 1‿2‿3
⟨ 1 2 78 ⟩
   « 1‿2‿3
⟨ 2 3 0 ⟩
   « 3‿3 ⥊ 9
┌─       
╵ 9 9 9  
  9 9 9  
  0 0 0  
        ┘
```

`𝕨 « 𝕩`: Shift Before

Remove the first `≠𝕨` (length) major cells from `𝕩`, join `𝕨` to the end of `𝕩`. Ranks must match.
```
   8‿5 « 1‿2‿3
⟨ 3 8 5 ⟩
   a ← 3‿3 ⥊ 9
┌─       
╵ 9 9 9  
  9 9 9  
  9 9 9  
        ┘
   1‿2‿3 « a
┌─       
╵ 9 9 9  
  9 9 9  
  1 2 3  
        ┘
```