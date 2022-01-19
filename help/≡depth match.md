Identical To (`≡`)

`≡ 𝕩`: Depth

Highest level of nesting in `𝕩`.
```
  ≡ 2‿3‿4
1
  ≡ ⟨2,<3,4,<<<5⟩
4
  ≡ 9
0
```

`𝕨 ≡ 𝕩`: Match

Does `𝕨` exactly match `𝕩`?
```
  1 ≡ ⟨1⟩
0
  ⟨1⟩ ≡ ⟨1⟩
1
```