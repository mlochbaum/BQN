Barb (`⥊`)

`⥊ 𝕩`: Deshape  

Put all elements of `𝕩` in a rank 1 array, converting to array if necessary.
```
  ⥊ 1
⟨ 1 ⟩
  ⥊ 1‿2 ≍ 3‿4
⟨ 1 2 3 4 ⟩
```

`𝕨 ⥊ 𝕩`: Reshape

Put all elements of `𝕩` in an array of shape `𝕨`, adding or removing elements if necessary.

A single element in `𝕩` can be a function, which will be replaced with an appropriate length:
- `∘` Exact fit
- `⌊` Round length down, discarding elements
- `⌽` Round length up
- `↑` Round length up, and use element fill to add extra elements.
```
  3‿3 ⥊ 3
┌─       
╵ 3 3 3  
  3 3 3  
  3 3 3  
        ┘
  2‿⌽‿2 ⥊ 1‿2‿3
┌─     
╎ 1 2  
       
  3 1  
      ┘
  2‿↑‿2 ⥊ 1‿2‿3
┌─     
╎ 1 2  
       
  3 0  
      ┘
```