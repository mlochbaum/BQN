Ring Operator (`∘`)

`𝔽∘𝔾 𝕩`: Atop

Apply `𝔾` to `𝕩`, then apply `𝔽` (`𝔽 𝔾 𝕩`).

`𝔽` and `𝔾` must be monadic.
```
   -∘- 5
5
   - - 5
5
```

`𝕨 𝔽∘𝔾 𝕩`: Dyadic Atop

Apply `𝔾` to `𝕨` and `𝕩`, then apply `𝔽` (`𝔽 (𝕨 𝔾 𝕩)`).

`𝔽` must be monadic, and `𝔾` must be dyadic.
```
   1 -∘+ 2
¯3
   1 - + 2
¯1
   - 1 + 2
¯3
```