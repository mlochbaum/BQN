Exclamation Mark (`!`)

`! 𝕩`: Assert

Throw an error if `𝕩` is not 1.
```
   ! 1
1
   ! 2
Error: Assertion error
at ! 2
   ^
   ! "hello"
Error: hello
at ! "hello"
```

`𝕨 ! 𝕩`: Dyad

Throw an error with message `𝕨` if `𝕩` is not 1.
```
   "hi" ! 1
1
   "two" ! 2
Error: two
at "two" ! 2
         ^
   "hello error" ! "hello"
Error: hello error
at "hello error" ! "hello"
```