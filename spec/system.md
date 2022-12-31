*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/system.html).*

# Specification: BQN system-provided values

This portion of the spec is still potentially subject to major changes.

The `•` symbol is used to access values other than primitives provided by BQN.

All system values described in the BQN specification are optional: an implementation does not have to include any of them. However, if a system value with one of the names given below is included, then it must have the specified behavior. For namespaces this rule applies to individual fields as well: a namespace may be provided with only some of the fields, but a field with one of the given names must behave as specified.

| Section | Contents
|---------|---------
| [Execution](#execution) | `•BQN`, `•ReBQN`, `•primitives`
| [Scripts](#scripts) | `•Import`, `•args`, `•Exit`, …
| [Files](#files) ([paths](#file-paths), [metadata](#file-metadata), [access](#file-access), [opened](#open-file-object)) | `•file`, `•FChars`, `•FLines`, `•FBytes`
| [Input and output](#input-and-output) ([terminal](#terminal-io)) | `•Out`, `•Show`, `•Repr`, `•Fmt`, …, `•term`
| [Interface](#interface) ([FFI](#foreign-function-interface)) | `•SH`, `•FFI`
| [Operation properties](#operation-properties) | `•Type`, `•Glyph`, `•Source`, `•Decompose`
| [Time](#time) | `•UnixTime`, `•Delay`, `•_timed`, …
| [Math](#math) | `•math`
| [Random generation](#random-generation) | `•rand`, `•MakeRand`
| [Bitwise operations](#bitwise-operations) | `•bit`

## Execution

| Name          | Summary
|---------------|--------------------------
| `•BQN`        | Evaluate the argument string in an isolated scope
| `•ReBQN`      | Create a BQN-like evaluation function with options `𝕩`
| `•primitives` | List of primitives as glyph-value pairs

The left argument to `•BQN` or the result of `•ReBQN`, if given, is a list of up to three elements, giving a prefix of `•state` (see next section) during evaluations of that function. Thus `⟨"","xyz"⟩•BQN"•name"` returns `"xyz"`.

`•ReBQN` accepts a namespace `𝕩`. The following options are specified if supported:

| Option        | Values (default first)
|---------------|--------------------------
| `repl`        | `"none"`, `"strict"`, `"loose"`
| `primitives`  | List of glyph-value pairs; default `•primitives`
| `system`      | `"all"`, `"none"`, `"safe"` or list of names
| `scope`       | `"none"`, `"read"`, `"modify"` or list of name-setting pairs

The option `repl` indicates how variables are retained across calls: with "none" they are not saved; with "strict", they are saved and can't be redefined; and with "loose" they may be redefined. Each element in `primitives` gives the glyph and value for a primitive to be made available. The value must have an operation type and its type determines the primitive's role. `system` in general gives the list of system values to be made available, with shorthand values to indicate all currently-available ones, none of them, or only a subset that cannot be used to interact with anything outside of the execution context. `scope` indicates allowed interaction with the scope in which `•ReBQN` is *called* (not loaded): with "read" variables may be read and with "modify" they may be read or modified.

## Scripts

| Name       | Summary
|------------|---------------------
| `•Import`  | Load a script file
| `•state`   | `⟨•path, •name, •args⟩`
| `•args`    | Arguments passed to current file
| `•path`    | Current file's path
| `•name`    | Current filename
| `•wdpath`  | Shell's working directory path
| `•Exit`    | Leave the top-level running program

`•Import` loads another BQN script. The script is evaluated in its own isolated scope, and its result is either the result of the last line, or a module if it exports with `⇐` at the top level. If it is a module, then it must be destructured immediately unless first-class namespaces are possible.

The right argument is a filename, which may be relative or absolute. Relative paths are taken relative to the source file where this instance of `•Import` was written. The left argument, if given, is the list of arguments that should be passed through to the file as `•args`. If no left argument is given then `⟨⟩` is used for `•args`. However, the behavior is different in this case. The same file will only be loaded once in a given BQN program by `•Import` calls with no left argument: the first such call saves the returned value, even if it is mutable, and subsequent calls return this saved value. To avoid this and reload the file, pass a left argument of `⟨⟩`.

`•args` is the arguments passed as the file was invoked, either from the command line or `•Import`. For command line calls it is a list of strings.

`•path` simply gives the path of the file in which it appears. It includes a trailing slash but not the name of the file itself.

`•name` gives the name, including the extension, of the file in which it appears. It doesn't include the path.

`•wdpath` returns the path of the current working directory, like the Unix `pwd` command, but including a trailing slash.

`•Exit` immediately terminates the running BQN process. If the argument is a valid return code (on Unix, an integer), it is returned; otherwise, the default return code (the one returned when the end of the program is reached) is used.

## Files

The system namespace value `•file` deals with file operations. For the purposes of `•file`, paths in the filesystem are always strings. As with `•Import`, file paths may be relative or absolute, and relative paths are relative to `•path`, except in `•file.At` which allows `𝕨` to specify an alternate base directory. The value `•path` used for a particular instance of `•file` is determined by the file that contains that instance.

When a `•file` function returns a file path or portion of a path, the path is always absolute and canonical, with `.` and `..` components removed.

Possible fields of `•file` are given in the subsections below.

### File paths

The following functions manipulate paths and don't access files. Each takes a relative or absolute path `𝕩`, and `At` may also take a base directory `𝕨`.

| Name        | Summary
|-------------|--------------------------
| `path`      | Path of this source file, that is, `•path`
| `At`        | Join base path `𝕨`, or `•path` if not given, to `𝕩`
| `Name`      | File name including extension
| `Parent`    | Path of the containing directory, with trailing backslash
| `BaseName`  | File name, with dot and extension removed
| `Extension` | File extension, including leading dot
| `Parts`     | List of parent, base name, and extension

### File metadata

Metadata functions may query information about a file or directory but do not read to or write from it. Each takes a path `𝕩`, and some functions also allow new data in `𝕨`. The returned data in any case is the specified property.

| Name          | Summary
|---------------|--------------------------
| `Exists`      | `1` if the file exists and `0` otherwise
| `Type`        | A character indicating the file's type
| `Created`     | Time created
| `Accessed`    | Time of last access
| `Modified`    | Time of last modification
| `Size`        | Total size in bytes
| `Permissions` | Query or set file permissions
| `Owner`       | Query or set owner user ID and group ID number

Times are Unix timestamps, that is, non-leap seconds since the Unix epoch, as used by [time](#time) system values. File permissions on Unix are a three-element list of numbers giving the permissions for the owner, group, and other users. The file type is one of the following characters for the POSIX file types, matching Unix `ls -l` with `'f'` instead of `'-'`.

- `'f'`: File
- `'d'`: Directory
- `'l'`: Symlink
- `'p'`: Pipe (FIFO)
- `'s'`: Socket
- `'b'`: Block device
- `'c'`: Character device

### File access

File access functions read or write files, either by manipulating files as a whole or interacting with the contents. Whole-file functions cannot overwrite target files: that is, `Rename` and `Copy` must give an error if a file exists at `𝕨`, and `CreateDir` if a file exists at `𝕩`, while `Chars`, `Lines`, and `Bytes` can overwrite the contents of an existing file `𝕨`. However, these three functions must give an error if `𝕨` exists and is a directory.

| Name        | Summary
|-------------|--------------------------
| `Open`      | Return an open file object based on `𝕩`
| `Rename`    | Rename file `𝕩` with path `𝕨`
| `Copy`      | Copy file `𝕩` to path `𝕨`
| `CreateDir` | Create a directory at path `𝕩`
| `Remove`    | Delete file `𝕩`
| `RemoveDir` | Recursively delete directory `𝕩` and all contents
| `List`      | Return names of all files in directory `𝕩`
| `Chars`     | Read from or write to entire file, as characters
| `Lines`     | Read from or write to entire file, as lines
| `Bytes`     | Read from or write to entire file, as bytes
| `MapBytes`  | Create a memory-mapped array aliasing the file

`Rename`, `Copy`, and `CreateDir` return the path of the new file. `Remove` and `RemoveDir` return `1` to indicate successful removal (and error otherwise).

`List` returns filenames only, without full paths. It lists all files and directories including hidden ones, but not the current and parent directory names `.` and `..`.

Functions `Chars`, `Lines`, and `Bytes` are all ambivalent. If only `𝕩` is given, then it is a filename, and the result is the contents of the file in the appropriate format. If there are two arguments, then `𝕨` is the filename and `𝕩` is the desired contents. These are written to the file, overwriting its contents, and the absolute filename `𝕨` is returned. The three formats are:

- Chars: BQN characters, or UTF-32. The file is assumed to be UTF-8 encoded.
- Lines: BQN strings. The file is decoded as with chars, then split into lines by CR, LR, or CRLF line endings.
- Bytes: Single-byte values, stored as BQN characters from `@` to `@+255`.

The `MapBytes` function only takes one argument, a filename, and returns an array matching the result of `Bytes`. However, the array data should be [memory-mapped](https://en.wikipedia.org/wiki/Memory-mapped_file) allowing it to be loaded into memory on use. The array and arrays derived from it (such as slices) may change in value if the underlying file is modified after `MapBytes` is called.

The following short names can also be provided for file access. They can be provided, and use the definitions from above even if `•file` is not provided.

| Name       | Equivalent
|------------|---------------
| `•FChars`  | `•file.Chars`
| `•FLines`  | `•file.Lines`
| `•FBytes`  | `•file.Bytes`

### Open file object

Not yet specified.

## Input and output

| Name          | Summary
|---------------|----------------------
| `•Out`        | Print argument string
| `•Show`       | Print argument value
| `•Repr`       | String representation of `𝕩`, if possible
| `•Fmt`        | Format value for printing
| `•ParseFloat` | Convert from string to floating point number

`•Out` prints a string to stdout, with a trailing newline. `•Show` displays a BQN value to the programmer (the representation is not specified, and does not need to be plain text). `•Fmt` returns a string (not a character table: lines are separated by linefeeds) indicating how `𝕩` would be printed by the interactive environment. Both `•Show` and `•Fmt` may take a left argument configuring how the value should be formatted.

`•Repr` attempts to return a string so that `•BQN •Repr 𝕩` matches `𝕩`. If `𝕩` contains any mutable values (operations or namespaces), this is not possible. However, if such a values is stateless, in the sense that they don't access variables outside of their own scopes, it is permissible for `•Repr` to return source code that would create a value with identical behavior.

`•ParseFloat` returns the numeric value given by a string `𝕩` in integer, decimal, or scientific notation. The whole of `𝕩` must match the regular expression `-?(\.[0-9]+|[0-9]+\.?[0-9]*)([eE][-+]?[0-9]+)?` or an error is given. This format is similar to BQN's numeric literals but with many differences. Only `-` (not `¯`) can be used for a negative sign, and a positive exponent may be optionally preceded by `+`. A dot `.` indicates the decimal regardless of locale, and digits can be absent either before or after it, but not both. The function should make an effort to return the nearest possible value to the exact one represented, but is not required to round perfectly in all cases.

### Terminal I/O

The system namespace `•term` gives fine-grained control of input and output when running in a terminal emulator or similar text-based interface.

| Name      | Summary
|-----------|----------------------
| `Flush`   | Flush output buffer
| `RawMode` | Set raw mode (no input processing) if `1`, unset if `0`
| `CharB`   | Read a character, blocking until one is available
| `CharN`   | Read a character if available but return `0` if not

## Interface

The function `•SH` allows BQN to call other programs, as an operating system shell would. `•FFI` allows it to call functions compiled by C or compatible languages—these are stored in files that traditionally have names like `lib*.so` in Unix. In both cases the callee can run unrestricted code, so only trusted programs and functions should be called this way.

| Name    | Summary
|---------|----------------------
| `•SH`   | Execute shell command and return `exitcode‿stdout‿stderr`
| `•FFI`  | Load a native function from a shared object file

The argument to `•SH` is a list of strings giving the command and its arguments (for example `"mv"‿"old"‿"new"`). The command is executed synchronously, and the result is a list of three elements: the command's exit code, text written to stdout, and text written to stderr. In both cases the text is a plain string containing all text emitted by the program. Text is interpreted as UTF-8, with an error if it's not valid UTF-8.

The arguments to `•FFI` are a file path for `𝕨` (interpreted relative to `•path` if necessary, like `•file` functions), and a function descriptor for `𝕩`, which gives the function name, argument and result types, and information about how to convert these values. The format of `𝕩` is described in the next section. The result is a BQN function that calls the specified function. This call can crash, mutate values, or invoke other unexpected behavior if the function interferes with memory used by BQN.

### Foreign Function Interface

In a call to `•FFI`, `𝕩` follows the pattern `"result"‿"fn"‿"arg0"‿"arg1"‿...`, that is, a string for the *result type*, one for the *function name*, and any number of strings indicating *argument types*. `𝕩` must always be a list.

The function name is an arbitrary string. In order to look up the appropriate function in shared object file `𝕨`, it's encoded as UTF-8.

Types are to be interpreted according to the C ABI appropriate for the platform used. The grammar for a result or argument type is given below, using BNF as in the BQN grammar. Quoted values here are single characters: the type isn't tokenized and can't contain spaces. A `•FFI` implementation does not need to support all combinations of types.

    conv  = type ( ":" bqn )?
    type  = ( "i" | "u" | "f" ) nat          # number
          | "a"                              # BQN object
          | "*"                              # opaque pointer
          | ( "*" | "&" ) type               # pointer
          | "[" nat "]" type                 # array
          | "{" ( conv ( "," conv )* )? "}"  # struct
    bqn   = ( "i" | "u" | "f" | "c" ) nat

    nat   = digit+
    digit = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9"

By default, the returned function takes a list of arguments `𝕩`, requires `𝕨` to be an empty list if present, and returns a value corresponding to the C result. Some argument-specific rules can change this:
- The result type may also be the empty string `""`, indicating a void or ignored result, or `"&"`, indicating an ignored result, using a mutable argument for the BQN result, as discussed below. It can't contain any instance of the pointer rule `( "*" | "&" ) type`.
- An argument type may be preceded by up to one `>`, and up to one `𝕨` or `𝕩`, in any order. Arguments with `𝕨` are taken from `𝕨` in order, and the others from `𝕩`. If no arguments come from `𝕨`, the BQN function may be called monadically. If an argument type contains `>`, it must be the only value in its BQN argument (`𝕨` or `𝕩`), and that argument will be treated not as a list but as an entire value.

Beginning with the type declarations themselves, a **number** such as `f32` corresponds to a C type with the given quality (`i` for signed integer, `u` for unsigned, `f` for floating-point) and width in bits. The corresponding BQN value is a number, and should be converted exactly for integers and with rounding for decreasing-type conversions. For conversions to or from an integer type, attempting to convert a value to a type that can't contain it, or one outside of the exactly representable integer range (`-2⋆53` to `2⋆53` for IEEE doubles), results in an error.

A **pointer** such as `*u8` comes from a BQN list. If the symbol `&` is used rather than `*`, the pointer is called **mutable** and its contents after the function call completes are also returned as an element of the result. If there is any mutable pointer, the result is a list, unless the result type is `"&"`, in which case there must be exactly one mutable pointer and the result is its value alone. These prefixes can only be used in arguments, meaning that a BQN value is provided, and this value determines the length of both the input and the mutable result.

The letter `a` indicates that a **BQN value** is to be passed directly, interpreted in whatever way makes sense for the implementation. A plain `*` indicates an **opaque pointer**, to be mapped to a BQN value of namespace type. The behavior of this value is not yet specified. The **array** and **struct** types indicate C structs and arrays, and correspond to BQN lists.

The `bqn` value in a `conv` term indicates a BQN element type to be used. It can be appear after the whole type, or any member of a struct, and applies to the final component (that is, `type` term) of the type *and* one preceding `*`, `&`, or `[n]` if present (if a type ends in `**`, it applies to both `*`s). This portion of the type corresponds to a BQN list of the given element type, interpreted much like [bitwise](#bitwise-operations) conversion `•bit._cast`. The C type is treated as pure data, a stream of bits. For a prefix `*` or `&`, the data in question is the region of memory pointed to.

## Operation properties

| Name         | Summary
|--------------|--------------------------
| `•Type`      | Return a number indicating type
| `•Glyph`     | Return the glyph for a primitive
| `•Source`    | Return the source of a block, as a string
| `•Decompose` | Show the parts of a compound function

Each function in this section is monadic.

`•Type` gives its argument's type, as a number from the table below:

| Number | Type
|--------|-----
| 0      | Array
| 1      | Number
| 2      | Character
| 3      | Function
| 4      | 1-modifier
| 5      | 2-modifier
| 6      | Namespace

`•Glyph` gives the glyph corresponding to a primitive as a single character, for example returning `'+'` given an argument matching `+`. It causes an error if the argument is not a primitive.

`•Source` gives a string containing a block's source, including the enclosing braces `{}`. It causes an error if the argument is not a block. In contrast to `•Glyph`, this function does not give full information about `𝕩` because the result cannot convey environment or mutable identity.

`•Decompose` breaks down one level of a compound function, returning a list with a code giving what kind of structure it has followed by each of its components. Possible codes are listed in the table below according to the rule that forms the function—train or modifier application. Non-function values, and some functions, can't be broken down. They are still classified with a code: -1 for a non-operation, 0 for a primitive, and 1 for other operations. "Other" includes blocks and system operations. The result is thus a list of length 2 to 4, and `•Decompose` cannot cause an error.

| Kind          | Code | Components
|---------------|------|-----------
| Non-operation | -1   | `𝕩`
| Primitive     |  0   | `𝕩`
| Other         |  1   | `𝕩`
| 2-train       |  2   | `  g,h`
| 3-train       |  3   | `f,g,h`
| 1-mod         |  4   | `𝕗,𝕣`
| 2-mod         |  5   | `𝕗,𝕣,𝕘`

## Time

| Name          | Summary
|---------------|--------------------------
| `•UnixTime`   | Time between Unix epoch and function call
| `•MonoTime`   | Monotonically-increasing time counter for relative measurement
| `•Delay`      | Wait at least `𝕩` seconds, and return the actual wait time
| `•_timed`     | Call `𝔽` on `𝕩` `𝕨⊣1` times, and return the average duration
| `•_maxTime_`  | Call `𝔽` on the arguments, but fail if it takes over `𝕨𝔾𝕩` seconds

All times are measured in seconds.

The [Unix epoch](https://en.wikipedia.org/wiki/Unix_time) is 1970-01-01 00:00:00 UTC, and [Unix time](https://en.wikipedia.org/wiki/Unix_time) is the number of seconds since this epoch, with adjustments for leap seconds. `•UnixTime` is intended for absolute time measurement and should use the source most accurate reflects Unix time when it's called. `•MonoTime` is intended for relative measurement and should use the method that gives the most precise time differences over the course of the program. Its return value must never decrease between calls.

`•_timed` returns the total time taken divided by the number of function calls (`𝕨` if provided and 1 otherwise), including the overhead required for the outer loop that counts iterations (which will typically be negligible in comparison to the BQN code).

More accurately the modifier `•_maxTime_` *may* fail if execution of `𝔽` takes over `𝕨𝔾𝕩` seconds, and should fail as quickly as it is practically able to. The most likely way to implement this modifier is to interrupt execution at the given time. If `𝔽` completes before the interrupt there is no need to measure the amount of time it actually took.

## Math

System namespace `•math` contains mathematical utilities that are not easily implemented with basic arithmetic, analogous to C's `math.h`.

Correctly-rounded arithmetic functions: monadic `Cbrt⇐3⊸√`, `Log2⇐2⋆⁼⊢`, `Log10⇐10⋆⁼⊢`, `Log1p⇐⋆⁼1⊸+`, `Expm1⇐1-˜⋆`; dyadic `Hypot⇐+⌾(×˜)`.

Standard trigonometric functions `Sin`, `Cos`, `Tan`, `Sinh`, `Cosh`, `Tanh`, with inverses preceded by `a` (`ASin`, etc.) and accessable with `⁼`. Additionally, the dyadic function `ATan2` giving the angle of vector `𝕨‿𝕩` relative to `1‿0`. All trig functions measure angles in radians.

Special functions `Fact` and `LogFact` giving the factorial and its natural logarithm, possibly generalized to reals as the gamma function Γ(1+𝕩), and `Comb` giving the binomial function "`𝕨` choose `𝕩`". Also the error function `Erf` and its complement `ErfC`. The implementations `LogFact ← ⋆⁼Fact` and `ErfC ← 1-Erf` are mathematically correct but these two functions should support greater precision for a large argument.

The greatest common divison `GCD` and least common multiple `LCM` of two numbers. Behavior for arguments other than natural numbers is not yet specified.

## Random generation

`•MakeRand` initializes a deterministic pseudorandom number generator with seed value `𝕩`. `•rand`, if it exists, is a globally accessible generator initialized at first use; this initialization should use randomness from an outside source if available. These random generators aren't required to be cryptographically secure and should always be treated as insecure. A random generator has the following member functions:

| Name      | Summary
|-----------|------------------------------
| `Range`   | A number, or array of shape `𝕨`, selected from `↕𝕩`
| `Deal`    | A simple random sample of `𝕨⊣𝕩` elements of `↕𝕩`
| `Subset`  | A sorted SRS of `↕𝕩`, with `𝕨` elements if given

For each of these functions, `𝕩` is a natural number. For `Range`, `𝕨` must be a valid shape (natural number, or list or unit array of natural numbers) if given, and for `Deal` and `Subset` it's a natural number less than or equal to `𝕩`. All selections are made uniformly at random, that is, each possible result is equally likely. A simple random sample (SRS) of `k` elements from list `s` is a list of `k` distinct elements of `s` in any order. Both the choice of elements and their ordering must be uniformly random. [Recommended algorithms](../implementation/primitive/random.md#simple-random-sample) for SRS selection are variants of a partial Knuth shuffle.

When `𝕨` isn't given, `Deal`'s result contains all elements of `↕𝕩`, making it a random shuffle of those values, or random permutation. In `Subset`, a random choice is made uniformly from the `2⋆𝕩` subsets of `↕𝕩`, so that a subset of any length may be returned.

In `Range`, `𝕩` may be `0`. In this case the result consists of floating-point numbers in the unit interval from 0 to 1. The numbers should have an overall uniform distribution, but their precision and whether the endpoints 0 and 1 are possible may depend on the implementation.

Ranges up to `2⋆32` must be supported (that is, a maximum integer result of `(2⋆32)-1`) if the number system accommodates it. In implementations based on double-precision floats it's preferable but not required to support ranges up to `2⋆53`.

## Bitwise operations

The system namespace `•bit` gives functions for efficiently applying bitwise and two's complement integer operations to arrays of data. These functions should compute result values with native CPU instructions, preferably SIMD if available.

| Name     | Args | Type     | Behavior
|----------|------|----------|---------
| `_not`   | 1    | bit      | `¬`
| `_and`   | 2    | bit      | `∧`
| `_or`    | 2    | bit      | `∨`
| `_xor`   | 2    | bit      | `≠`
| `_neg`   | 1    | integer  | `-`
| `_add`   | 2    | integer  | `+`
| `_sub`   | 2    | integer  | `-`
| `_mul`   | 2    | integer  | `×`
| `_cast`  | 1    | any      | identity

The `_cast` modifier is special and not considered an operation; see below. Each operation is exposed as a 1-modifier that takes up to four numbers for its operand.
- Operation width
- Result element width
- Right argument element width
- Left argument element width
The operand is extended to length 3 for monadic operations, and 4 for dyadic operations, by repeating the last element (like `»⟜(4⥊⊢´)`). It must be a number, or array of numbers with rank at most 1.

An example call is `a 16‿1•bit._add b`, to perform 16-bit additions on two boolean arrays with a boolean result.

To apply a bitwise operation, each argument is represented as a stream of bits based on the width given for it, then split into units whose width is the operation width. The operation is applied to these units. The result is again treated as a stream of bits and split according to the result width, with each unit forming a result element.

The operation width, along with the "Type" column above, determines what operation is performed. For bit operations it has no effect, except to constrain the argument sizes according to the shape rules below. Integer operations support widths of 8 and above, and should support higher values such as 128 if available. For all of them, there is no difference between wrapping signed and unsigned operations given that the argument and result widths are the same.

Argument and result widths correspond to little-endian binary representations according to the following table (operation widths don't—see the "type" field in the table above). Here "boolean" indicates value 0 or 1, "signed integer" indicates two's complement representation, and "character" is a code point in an unsigned representation. Either type may be used for an argument, but the result will always use a primary type.

| Width | Primary type    | Also
|-------|-----------------|------
| 1     | Boolean         |
| 8     | Signed integer  | Character
| 16    | Signed integer  | Character
| 32    | Signed integer  | Character
| 64    | IEEE 754 double |

An argument must be an array of numbers or an array of characters. Its elements must fit into the appropriate type. The "cell size" is the length in bits of a 1-cell, that is, `width×¯1⊑1∾≢arg`, and must be a multiple of the operation width. The "leading shape" is `¯1↓≢arg`. For two-argument functions one argument can be scalar-extended if it has rank 1 and cell size equal to the operation width. Otherwise both arguments must have the same cell size, and the same leading shape. The result shape is the leading shape of any non-extended argument followed by its cell size divided by the result element width. As a scalar-extended argument indicates a single operation input, it's reused every time the operation is applied.

Another tool is provided for performing direct conversions, with no operation applied. The 1-modifier `•bit._cast` takes a two-element operand and one argument, for example `⟨8,16‿'c'⟩•bit._cast ints` to convert each pair of numbers in `ints` into a 2-byte character. Each element of `𝕗` is a number or number-character pair giving width and type. The argument is encoded according to the first and decoded according to the second.
