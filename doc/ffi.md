*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/doc/ffi.html).*

# Foreign Function Interface (FFI)

BQN's [foreign function interface](https://en.wikipedia.org/wiki/Foreign_function_interface) allows it to interface with libraries written in C, or other languages that support a compatible format. It's invoked with `•FFI`, which performs the necessary lookups and conversions to call a function from a dynamic shared library (extension .so in Unix-like systems and .dll in Windows). This function is [specified](../spec/system.md#foreign-function-interface-ffi) by BQN and implemented by CBQN—without support for all possible types, but enough for practical use.

Warning: object code is unsafe by nature. The OS will hopefully prevent it from exceeding the privileges of the BQN interpreter, but anything code in the interpreter could do is fair game. It might crash, write files, corrupt BQN arrays resulting in "impossible" behavior later on, or read everything in your home directory and email it to someone. Be careful when invoking the FFI!

## Basic usage

`•FFI` takes the path of the object file as `𝕨`, with local paths resolved relative to the source file as in `•Import`. `𝕩` describes the specific function requested from this file and its type signature, and the result is a BQN function that calls it. While a major purpose of `•FFI` is to be called with files like libpng.so that you may already have on your system, we'll start by writing some C to make it clear what's happening on both sides of the interface. A factorial function is pretty short, so let's start there:

    #include "stdint.h"

    int32_t fac32(int32_t n) { return n ? n * fac32(n - 1) : 1; }

To follow along on Linux, save as fac.c and compile with `gcc fac.c -shared -o fac.so`. On other operating systems, do whatever does the same thing as that I guess. Then you can call it from BQN like this:

    fac32 ← "fac.so" •FFI "i32"‿"fac32"‿"i32"
    •Show Fac32 ⟨5⟩  # 120

This assumes the BQN code is running in the same directory as fac.so. The use of `fac32` on the first line and `Fac32` on the second is [syntactic role](expression.md#syntactic-role) manipulation: we have to treat the result of a function such as `•FFI` as a subject when it's first created, but then we put it in a function role to call it (see also [functional programming](functional.md#functional-programming-in-bqn)). Elements of `•FFI`'s right argument follow the form of a C declaration: result type, function name, and then argument types. C functions can take any number of arguments, so for consistency `Fac32` takes a list as its argument instead of taking a number directly. But using a `Fac32∘⋈` wrapper would be annoying and add a little overhead, so a special `>` declaration on the type indicates that the BQN argument should be used directly. Now our function has the same interface as `•math.Fact`, making it easy to verify that it was pointless work:

    fac32 ← "fac.so" •FFI "i32"‿"fac32"‿">i32"
    ! (Fac32 ≡ •math.Fact) 5

And because the C function `fac32` takes a signed integer but doesn't test for negative arguments, running `Fac32 ¯1` shows some potential negative effects of a bad FFI call. When I compile with no optimization as shown above, it runs out of stack space and crashes BQN with a segmentation fault. With `-O2` or higher, it takes several seconds to wrap around to positivies and eventually returns 0, but signed overflow is undefined behavior, so anything could happen really.

### Using pointers

For a more complicated example, here's a function that counts the number of cycles in a permutation, by tracing each cycle starting at its lowest index. In typical C fashion, it takes its argument as a length and then a pointer to the permutation indices, since a pointer by itself doesn't have any length information.

    #include "stdint.h"

    uint32_t cycles(uint32_t len, uint32_t* p) {
        uint32_t count = 0;
        for (uint32_t i = 0; i < len; i++) {
            uint32_t j = i, pj = p[j];
            count += pj >= i;
            while (pj > i) {
                p[j] = i;
                j = pj;
                pj = p[j];
            }
        }
        return count;
    }

With that compiled to `cyc.so`, we can call it using the following BQN code. The pointer type is represented with the asterisk at the beginning rather than at the end, so that reading from left to right reveals the outermost structure first.

    cycC ← "cyc.so" •FFI "u32"‿"cycles"‿"u32"‿"*u32"
    •Show p ← ⍋"cycle"  # ⟨ 0 2 4 3 1 ⟩
    •Show CycC ≠⊸⋈ p    # 3
    •Show p             # ⟨ 0 2 4 3 1 ⟩

The cycles are 0, 124, and 3, so that checks out. But `cycles` modifies its argument `p`, with the line `p[j] = i`. Is the BQN list `p` changed when this happens? The check on the last line says no, which is good because BQN arrays are supposed to be immutable. What happens is that BQN copies the data into temporary memory in order to pass it in to C (here it also converts from 8 bits for each element to 32).

But what if we want to see those modifications? Many C functions use pointer modification as a way to return multiple values, so the FFI supports this. With `&` instead of `*`, the values after calling the function are returned as an extra result.

    cycles ← "cyc.so" •FFI "u32"‿"cycles"‿"u32"‿"&u32"
    •Show Cycles ≠⊸⋈ ⍋"cycle"  # ⟨ 3 ⟨ 0 1 1 3 1 ⟩ ⟩

The original result might not be wanted in this case. You can ignore it by using `""` for the result type, but then you get a 1-element list, for consistency with the case with multiple `&` arguments. Similar to `>` on a single argument, you can use `"&"` for the result to get a single mutated argument returned directly.

    cycI ← "cyc.so" •FFI "&"‿"cycles"‿"u32"‿"&u32"
    •Show CycI ≠⊸⋈ ⍋"cycle"  # ⟨ 0 1 1 3 1 ⟩

(And now `⊔⊐` gives a list of lists indicating which indices form each cycle, although that's not the same as a cycle decomposition, which would also indicate their ordering within the cycle.)

## Type specification

So the format of `𝕩` is result type, function name, argument types. And the function name isn't complicated, it's just a string. Types have more rules. Here's the quick rundown:

- Numeric types are formatted like `i32`, with `i`, `u`, or `f`.
- Another basic type, `a`, exposes BQN values directly.
- Typed pointers are written `*t` or `&t`, and untyped pointers as `*` or `&`.
- Fixed-size arrays are written like `[25]t`.
- Structs are written like `{r,s,t}`.
- A `:` suffix like `:c16` indicates a corresponding BQN type.

The numeric qualities are `i` for signed integer, `u` for unsigned integer, and `f` for floating-point number. CBQN supports integer widths from 8 to 64, and float widths 32 and 64. `u8` can be used for `bool`.

Other than `a`, which is implementation-dependent, all of these types have a direct correspondence to C. For example, `{[2]f32,**i8}` is a struct whose two fields are a list of two 32-bit floats and a pointer to pointers to 8-bit integers.

Shared libraries don't include type signatures, so `•FFI` can't verify that the type signature for a given function is correct: it just passes the arguments however it should for that type signature. One consequence is that an imprecise type signature may still work. Pointers are all passed the same way, so their element types don't matter on the C side of the FFI; it's fine to use whatever's most convenient on the BQN side.

### Type conversions

So what do all these C types mean in BQN? The FFI tries to define sensible conversions. But BQN can't always represent every value directly, so it also provides [explicit conversions](#explicit-type-conversion) with `:` using the underlying bit representation, giving a way to safely store any value.

On to implicit conversions, let's start with **numbers**. CBQN numbers are 64-bit floats, which are a superset of integer types up to 32 bits, and 32-bit floats. So conversions from all these types are exact with no problems. Converting to a smaller integer type requires the float value to fit in that type, while converting to a smaller float type rounds.

Issues show up with **64-bit integer** types because 64-bit floats only have full integer precision from `-2⋆53` to `2⋆53`. _Some_ integers beyond this range are representable, but others aren't: for example `1+2⋆53` rounds to `2⋆53`. For this reason numbers with absolute value `2⋆53` and greater error when converting between float and integer. Bare `u64` and `i64` types are fine when working with lengths and other things that can't reasonably be that large, but when all the bits are used they should be converted with `i64:u32` or similar.

An **array** or **struct** corresponds to a BQN list, easy enough.

A BQN list or pointer object can be converted to a **pointer**, and a C pointer is always converted to a pointer object—it can't be converted to a list because the length is unknown, but sometimes a mutable pointer is a convenient way to get a list from a C function. [Pointer objects](#pointer-objects) are BQN values designed specifically to encapsulate C pointers. If passed as an argument, its type needs to be compatible with the type for that argument, if it has one. When an argument has an _untyped_ pointer type `*` or `&`, it can't take a list as input (what would the elements be converted to?) but any pointer object will be accepted.

### Explicit type conversion

Either the type as a whole, or any member of a struct, can have a conversion specification like `:u32` at the end. The type after the colon uses the same format as C numeric types, with the quality `c` allowed for characters in addition to `i`, `u`, and `f`. Here CBQN supports the types it uses internally for arrays: `u1` for booleans, `i8` to `i32` and `c8` to `c32`, and `f64`.

With explicit conversion, each C value corresponds to a list of BQN values with the same bit representation. For example, you might use `u64:u1` to represent a 64-bit number as 64 bits (little-endian or least significant first), or `u64:c8` to represent it as 8 characters. Similarly, a pointer can be turned into plain bits and back with `*:u1`. The `:` also applies to compound values; another case is an argument such as `*i64:i32`, which will be cast from a BQN list of 32-bit ints to a C list of 64-bit ints that's half as long (with an error if the length wasn't even). And `&` can be used instead of `*` to get mutated values out, converting back to i32 on the way. Other compound cases have some complications and aren't supported in CBQN currently.

## Argument and result formats

This section covers how FFI arguments and results are structured in BQN, and collects the ways to tweak it.

The normal case is that `𝕩` is a list of the arguments. You can pass in `𝕨` if you really want, but is has to be an empty list. No arguments have been specified as coming from `𝕨`! You can control where a C argument comes from by sticking `𝕨` or `𝕩` to the front (`𝕩` does nothing, it's already the default). So for example, arguments of `"i32"‿"𝕨i32"‿"𝕩i32"` mean the function has to be called like `⟨2⟩ Fn 3‿4`. Then if a C argument is the only one included in its BQN argument, it can have a `>` at the beginning (either before or after the `𝕨`/`𝕩`) meaning that the BQN argument should be that value directly instead of the 1-element list.

If there are no mutable arguments, the result is what it is. Unless it isn't: a result type of `""` results in a result value of `@`.

Mutable arguments (those with `&`) all have to be returned as part of the result. If there are any of these, the result is a list consisting of the C result followed by each mutable argument, mutatis mutandis, in the order they appeared in the arguments. Again, the result type can be `""` to leave it out, so that the result just includes mutable values. It can also be `"&"` if there's exactly one such value, which means it won't be returned as a list.

In the table of examples below, `5`, `1`, `0.5`, and `3` are used as values for `i8`, `u1`, `f64`, and `i64` respectively, and `a` and `b` are possible list arguments with `am` and `bm` indicating modified versions of these.

| Res     | Args                | Call             | Result
|---------|---------------------|------------------|-------
| `"i64"` | `"i8"‿"u1"‿"f64"`   | `Fn ⟨5,1,0.5⟩`   | `3`
| `"i64"` | `"𝕨i8"‿"𝕨u1"‿"f64"` | `⟨5,1⟩ Fn ⟨0.5⟩` | `3`
| `""`    | `"i8"‿"u1"‿">𝕨f64"` | `0.5 Fn ⟨5,1⟩`   | `@`
| `"i64"` | `"&i8"‿"u1"‿"&f64"` | `Fn ⟨a,1,b⟩`     | `⟨3,am,bm⟩`
| `""`    | `"&i8"‿"u1"‿"&f64"` | `Fn ⟨a,1,b⟩`     | `⟨am,bm⟩`
| `"&"`   | `"&i8"‿"u1"‿"f64"`  | `Fn ⟨a,1,0.5⟩`   | `am`

### Pointer objects

[specification](../spec/system.md#pointer-objects)
