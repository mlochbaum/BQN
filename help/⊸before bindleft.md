Multimap (`⊸`)

`𝕗⊸𝔾 𝕩`: Bind Left

Supply `𝕗` as a left argument to `𝔾` (`𝕗 𝔾 𝕩`).

`𝕗` must be a value, `𝔾` must be dyadic.
```
   3⊸- 9
¯6
   3 - 9
¯6
```

`𝔽⊸𝔾 𝕩`: Before

Apply `𝔽` to `𝕩`, and supply it as a left argument to `𝔾` (`(𝔽 𝕩) 𝔾 𝕩`). 

`𝔽` must be monadic, `𝔾` must be dyadic.
```
   -⊸+ 9
0
   - + 9
¯9
   (- 9) + 9
0
```

`𝕨 𝔽⊸𝔾 𝕩`: Dyadic Before

Apply `𝔽` to `𝕨`, and supply it as a left argument to `𝔾` (`(𝔽 𝕨) 𝔾 𝕩`).

`𝔽` must be monadic, `𝔾` must be dyadic.
```
   2 -⊸+ 1
¯1
   2 - + 1
1
   (- 2) + 1
¯1
```