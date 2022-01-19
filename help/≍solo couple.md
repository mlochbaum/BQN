Tape (`≍`)

`≍ 𝕩`: Solo 

Add a dimension to `𝕩`.
```
  ≍ 1
⟨ 1 ⟩
  
  ≍≍ 1
┌─   
╵ 1  
    ┘
  
 ≍≍≍ 1
┌─   
╎ 1  
    ┘
  
 ≍≍ 1‿2‿3‿4
┌─         
╵ 1 2 3 4  
          ┘
  
 ≍≍≍ 1‿2‿3‿4
┌─         
╎ 1 2 3 4  
          ┘
```

`𝕨 ≍ 𝕩`: Couple

Join `𝕨` and `𝕩` along a newly created axis.
```
   1 ≍ 3
⟨ 1 3 ⟩
   1‿2 ≍ 2‿3
┌─     
╵ 1 2  
  2 3  
      ┘
```