*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/spec/system.html).*

# Specification: BQN system-provided values

This portion of the spec is still potentially subject to major changes.

The `•` symbol is used to access values other than primitives provided by BQN.

All system values described in the BQN specification are optional: an implementation does not have to include any of them. However, if a system value with one of the names given below is included, then it must have the specified behavior. For namespaces this rule applies to individual fields as well: a namespace may be provided with only some of the fields, but a field with one of the given names must behave as specified.

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
| `•Exit`    | Leave the top-level running program

`•Import` loads another BQN script. The script is evaluated in its own isolated scope, and its result is either the result of the last line, or a module if it exports with `⇐` at the top level. If it is a module, then it must be destructured immediately unless first-class namespaces are possible.

The right argument is a filename, which may be relative or absolute. Relative paths are taken relative to the source file where this instance of `•Import` was written. The left argument, if given, is the list of arguments that should be passed through to the file as `•args`. If no left argument is given then `⟨⟩` is used for `•args`. However, the behavior is different in this case. The same file will only be loaded once in a given BQN program by `•Import` calls with no left argument: the first such call saves the returned value, even if it is mutable, and subsequent calls return this saved value. To avoid this and reload the file, pass a left argument of `⟨⟩`.

`•args` is the arguments passed as the file was invoked, either from the command line or `•Import`. For command line calls it is a list of strings.

`•path` simply gives the path of the file in which it appears. It includes a trailing slash but not the name of the file itself.

`•name` gives the name, including the extension, of the file in which it appears. It doesn't include the path.

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
| `At`        | Absolute path of file, with optional base `𝕨`
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

Times are Unix timestamps, that is, seconds since the Unix epoch, as used by [time](#time) system values. File permissions on Unix are a three-element list of numbers giving the permissions for the owner, group, and other users. The file type is one of the following characters for the POSIX file types, matching Unix `ls -l` with `'f'` instead of `'-'`.

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

`Rename`, `Copy`, and `CreateDir` return the path of the new file. `Remove` and `RemoveDir` return `1` to indicate successful removal (and error otherwise).

`List` returns filenames only, without full paths. It lists all files and directories including hidden ones, but not the current and parent directory names `.` and `..`.

Functions `Chars`, `Lines`, and `Bytes` are all ambivalent. If only `𝕩` is given, then it is a filename, and the result is the contents of the file in the appropriate format. If there are two arguments, then `𝕨` is the filename and `𝕩` is the desired contents. These are written to the file, overwriting its contents, and the absolute filename `𝕨` is returned. The three formats are:

- Chars: BQN characters, or UTF-32. The file is assumed to be UTF-8 encoded.
- Lines: BQN strings. The file is decoded as with chars, then split into lines by CR, LR, or CRLF line endings.
- Bytes: Single-byte values, stored as BQN characters from `@` to `@+255`.

The following short names can also be provided for file access. They can be provided, and use the definitions from above even if `•file` is not provided.

| Name       | Equivalent
|------------|---------------
| `•FChars`  | `•file.Chars`
| `•FLines`  | `•file.Lines`
| `•FBytes`  | `•file.Bytes`

### Open file object

## Input and output

| Name    | Summary
|---------|----------------------
| `•Out`  | Print argument string
| `•Show` | Print argument value
| `•Repr` | String representation of `𝕩`, if possible
| `•Fmt`  | Format value for printing

`•Out` prints a string to stdout, with a trailing newline. `•Show` displays a BQN value to the programmer (the representation is not specified, and does not need to be plain text). `•Fmt` returns a string (not a character table: lines are separated by linefeeds) indicating how `𝕩` would be printed by the interactive environment. Both `•Show` and `•Fmt` may take a left argument configuring how the value should be formatted.

`•Repr` attempts to return a string so that `•BQN •Repr 𝕩` matches `𝕩`. If `𝕩` contains any mutable values (operations or namespaces), this is not possible. However, if such a values is stateless, in the sense that they don't access variables outside of their own scopes, it is permissible for `•Repr` to return source code that would create a value with identical behavior.

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

`•Decompose` breaks down one level of a compound function or modifier, returning a list with a code giving what kind of structure it has (as listed in the table below) followed by each of its components. "Other" includes blocks and system functions. Non-operations do not cause an error, but return code -1, then the argument as a single component. The result is thus a list of length 2 to 4, and `•Decompose` cannot cause an error.

| Kind          | Code | Components
|---------------|------|-----------
| Non-operation | -1   | `𝕩`
| Primitive     |  0   | `𝕩`
| Other         |  1   | `𝕩`
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
