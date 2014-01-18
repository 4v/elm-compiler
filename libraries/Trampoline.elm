module Trampoline (Trampoline, trampoline)
       where

{-| Trampolining loops for unbounded recursion.
Since most javascript implementations lack tail-call elimination, deeply tail-recursive functions will result in a stack overflow.

```haskell
fac' : Int -> Int -> Int
fac' n acc = if n <= 0 
             then acc
             else fac' (n - 1) (n * acc)

fac : Int -> Int
fac n = fac' n 1

-- Stack overflow
main = asText <| fac 1000000000000
```

Trampolining allows for long-running tail-recursive loops to be run without pushing calls onto the stack:
```haskell
facT : Int -> Int -> Trampoline Int
facT n acc = Trampoline <| if n <= 0 
                           then Left acc
                           else Right <| \() -> facT (n - 1) (n * acc)
fac : Int -> Int
fac n = trampoline <| facT n 0

-- Doesn't stack overflow
main = asText <| fac 1000000000000
```
# Trampoline
@docs Trampoline, trampoline
 -}
import Native.Trampoline
import open Either

{-| A computation that might loop. A trampoline is either the resulting value or a thunk that needs to be run more. -}
data Trampoline a = Trampoline (Either a (() -> Trampoline a))

{-| Run a trampolining loop in constant space. -}
trampoline : Trampoline a -> a
trampoline = Native.Trampoline.trampoline
