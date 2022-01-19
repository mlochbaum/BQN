Solidus (`/`)

`/ 𝕩`: Indices

Repeat the index of each element in `𝕩` by the element's value. `𝕩` must be rank 1.
```
   / 1‿2‿3
⟨ 0 1 1 2 2 2 ⟩
   / 1‿0‿1
⟨ 0 2 ⟩
```

`𝕨 / 𝕩`: Replicate

Repeat each major cell in `𝕩` by the corresponding element in `𝕨`.

Atomic `𝕨` applies to all elements.
```
   3 / "copy"
"cccooopppyyy"
   1‿0‿1 / 1‿2‿3
⟨ 1 3 ⟩
```