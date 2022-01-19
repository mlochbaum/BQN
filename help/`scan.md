*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/`scan.html).*

# Acute Accent (`` ` ``)

``𝔽` 𝕩``: Fold

Scan over `𝕩` with `𝔽` from left to right, producing intermediate values.


       +` 1‿2‿3
    ⟨ 1 3 6 ⟩
       ⟨1, 1+2, (1+2)+3⟩
    ⟨ 1 3 6 ⟩
       -` 1‿2‿3
    ⟨ 1 ¯1 ¯4 ⟩
       ⟨1, 1-2, (1-2)-3⟩
    ⟨ 1 ¯1 ¯4 ⟩

``𝕨 𝔽` 𝕩``: Scan With initial

Monadic scan, but use `𝕨` as initial left argument.

       5 +` 1‿2‿3
    ⟨ 6 8 11 ⟩
       ⟨5+1, (5+1)+2, ((5+1)+2)+3⟩
    ⟨ 6 8 11 ⟩
       5 -` 1‿2‿3
    ⟨ 4 2 ¯1 ⟩
       ⟨5-1, (5-1)-2, ((5-1)-2)-3⟩
    ⟨ 4 2 ¯1 ⟩

