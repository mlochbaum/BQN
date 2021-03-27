*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/system.html).*

# Specification: BQN system-provided values

This portion of the spec is still potentially subject to major changes.

The `•` symbol is used to access values other than primitives provided by BQN.

All system values described in the BQN specification are optional: an implementation does not have to include any of them. However, if a system value with one of the names given below is included, then it must have the specified behavior.

## Scripts

| Name       | Summary
|------------|---------------------
| `•Import`  | Load a script file
| `•args`    | Arguments passed to current file
| `•path`    | Current file's path
| `•name`    | Current filename

`•Import` loads another BQN script. The script is evaluated in its own isolated scope, and its result is either the result of the last line, or a module if it exports with `⇐` at the top level. If it is a module, then it must be destructured immediately unless first-class namespaces are possible.

The right argument is a filename, which may be relative or absolute. Relative paths are taken relative to the source file where this instance of `•Import` was written. The left argument, if given, is the list of arguments that should be passed through to the file as `•args`. If no left argument is given then `⟨⟩` is used for `•args`. However, the behavior is different in this case. The same file will only be loaded once in a given BQN program by `•Import` calls with no left argument: the first such call saves the returned value, even if it is mutable, and subsequent calls return this saved value. To avoid this and reload the file, pass a left argument of `⟨⟩`.

`•args` is the arguments passed as the file was invoked, either from the command line or `•Import`. For command line calls it is a list of strings.

`•path` simply gives the path of the file in which it appears. It includes a trailing slash but not the name of the file itself.

`•name` gives the name, including the extension, of the file in which it appears. It doesn't include the path.

## File access

| Name       | Summary
|------------|--------------------------
| `•FChars`  | Read from or write to an entire file, as characters
| `•FLines`  | Read from or write to an entire file, as lines
| `•FBytes`  | Read from or write to an entire file, as bytes

As with `•Import`, file paths may be relative or absolute, and relative paths are relative to `•path`.

Functions `•FChars`, `•FLines`, and `•FBytes` are all ambivalent. If only one argument is given, then it must be the name of a file, and the result is the contents of the file in the appropriate format. If there are two arguments, then the left argument is the filename and the right is the desired contents. These are written to the file, overwriting its contents, and the filename `𝕨` is returned. The three formats are:

- Chars: BQN characters, or UTF-32. The file is assumed to be UTF-8 encoded.
- Lines: BQN strings. The file is decoded as with chars, then split into lines by CR, LR, or CRLF line endings.
- Bytes: Single-byte values, stored as BQN characters from `@` to `@+255`.

## Execution and scope manipulation

| Name          | Summary
|---------------|--------------------------
| `•BQN`        | Evaluate the argument string in an isolated scope
| `•Eval`       | Evaluate the argument string in the current scope
| `•ScopedEval` | Evaluate the argument string in a child scope
| `•Using`      | Import all values from the argument namespace

The effect of `•Eval` should be the same as if its argument were written as source code in the scope where `•Eval` appears. It can define variables, and modify those in the current scope or a parent.

`•ScopedEval` creates as new scope for evaluation as it is loaded. Other than its syntactic role, it is effectively equivalent to `{•Eval}`. Parent scopes are visible from the created scope; to make a scope without this property use `•BQN"•Eval"` or `•BQN"•ScopedEval"`.

## Input and output

| Name   | Summary
|--------|----------------------
| `•Out` | Print argument string
| `•Fmt` | Format value for printing

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

`•Decompose` breaks down one level of a compound function or modifier, returning a list with a code giving what kind of structure it has (as listed in the table below) followed by each of its components. Non-operations do not cause an error, but return code -1, then the argument as a single component. The result is thus a list of length 2 to 4, and `•Decompose` cannot cause an error.

| Kind          | Code | Components
|---------------|------|-----------
| Non-operation | -1   | `𝕩`
| Primitive     |  0   | `𝕩`
| Block         |  1   | `𝕩`
| 2-train       |  2   | `  g,h`
| 3-train       |  3   | `f,g,h`
| 1-mod         |  4   | `𝕗,𝕣`
| 2-mod         |  5   | `𝕗,𝕣,𝕘`
| Left partial  |  6   | `𝕗,𝕣`
| Right partial |  7   | `  𝕣,𝕘`

## Time

| Name          | Summary
|---------------|--------------------------
| `•UnixTime`   | Time between Unix epoch and function call
| `•MonoTime`   | Monotonically-increasing time counter for relative measurement
| `•Delay`      | Wait at least `𝕩` seconds, and return the actual wait time
| `•_timed`     | Call `𝔽` on `𝕩` `𝕨⊣1` times, and return the average duration
| `•_maxTime_`  | Call `𝔽` on the arguments, but fail if it takes over `𝕨𝔾𝕩` seconds

All times are measured in seconds.

The [Unix epoch](https://en.wikipedia.org/wiki/Unix_time) is 1970-01-01 00:00:00 UTC. `•UnixTime` is intended for absolute time measurement and should be implemented with the method that gives the most accurate result at any given time. `•MonoTime` is intended for relative measurement and should use the method that gives the most precise time differences over the course of the program. Its return value must never decrease between calls.

`•_timed` returns the total time taken divided by the number of function calls (`𝕨` if provided and 1 otherwise), including the overhead required for the outer loop that counts iterations (which will typically be negligible in comparison to the BQN code).

More accurately the modifier `•_maxTime_` *may* fail if execution of `𝔽` takes over `𝕨𝔾𝕩` seconds, and should fail as quickly as it is practically able to. The most likely way to implement this modifier is to interrupt execution at the given time. If `𝔽` completes before the interrupt there is no need to measure the amount of time it actually took.
