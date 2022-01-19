Left Multimap (`⟜`)

`𝔽⟜𝕘 𝕩`: Bind 

Supply `𝕘` as a right argument to `𝔽` (`𝕩 𝔽 𝕘`).

`𝕘` must be a value, `F` must be dyadic.
```
   -⟜3 9
6
   - 3 9
Error
   9 - 3
6
```

`𝔽⟜𝔾 𝕩`: After

Apply `𝔾` to `𝕩`, and supply it as a right argument to `𝔽` (`𝕩 𝔽 (𝔾 𝕩)`). 

`𝔽` must be dyadic, `𝔾` must be monadic.
```
   ×⟜- 9
¯81
   × - 9
¯1
   9 × (- 9)
¯81
```

`𝕨 𝔽⟜𝔾 𝕩`: Dyadic After

Apply `𝔾` to `𝕩`, and supply it as a right argument to `𝔽` (`𝕨 𝔽 (𝔾 𝕩)`). 

`𝔽` must be dyadic, `𝔾` must be monadic.
```
   2 ×⟜- 1
¯2
   2 × (- 1)
¯2
```