*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/help/⌜table.html).*

# Top Left Corner (`⌜`)

`𝕨 𝔽⌜ 𝕩`: Each

Apply `𝔽` between every possible pair of the elements of the arguments.

       1‿2‿3‿4 +⌜ 4‿5‿6‿7
    ┌─           
    ╵ 5 6  7  8  
      6 7  8  9  
      7 8  9 10  
      8 9 10 11  
                ┘
       "abc" ∾⌜ "xyz"
    ┌─                
    ╵ "ax" "ay" "az"  
      "bx" "by" "bz"  
      "cx" "cy" "cz"  
                     ┘

