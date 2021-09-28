*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/vm.html).*

# The BQN virtual machine and runtime

BQN's self-hosted compiler and runtime mean that only a small amount of native code is needed to run BQN on any given platform. The [Javascript environment](../docs/bqn.js) requires about 500 lines of Javascript code including system functions and performance improvements; probably around 250 would be required just to run the core language. This makes it fairly easy to port BQN to new platforms, allowing BQN to be [embedded](../doc/embed.md) within other programming languages and interact with arrays or functions in those languages.

The way data is represented is part of the VM implementation: it can use native arrays or a custom data structure, depending on what the language supports. An initial implementation will be very slow, but can be improved by replacing functions from the BQN-based runtime with native code. As the VM system can be hard to work with if you're not familiar with it, I advise you to contact me to discuss implementing a VM if you are interested.

## Bytecode

The BQN implementation here and dzaima/BQN share a stack-based object code format used to represent compiled code. This format is a list of numbers of unspecified precision (small precision will limit the length of list literals and number of locals per block, blocks, and constants). Previously it was encoded as bytes with the [LEB128](https://en.wikipedia.org/wiki/LEB128) format; while it no longer has anything to do with bytes it's called a "bytecode" because this is shorter than "object code".

The self-hosted compiler uses a simpler, and less capable, format for block and variable data than dzaima/BQN. Only this format is described here; [dc.bqn](../dc.bqn) adapts it to be compatible with dzaima/BQN.

dzaima/BQN can interpret bytecode or convert it to [JVM](https://en.wikipedia.org/wiki/Java_virtual_machine) bytecode, while the Javascript VM previously interpreted bytecode but now always compiles it. Since interpretation is a simpler strategy, it may be helpful to use the [old Javascript bytecode interpreter](https://github.com/mlochbaum/BQN/blob/f74d9223ef880f2914030c2375f680dcc7e8c92b/bqn.js#L36) as a reference (for bytecode execution only) when implementing a BQN virtual machine.

### Components

The complete bytecode for a program consists of the following:
* A bytecode sequence `code`
* A list `consts` of constants that can be loaded
* A list `blocks` of per-block information, described in the next section
* A list `bodies` of per-body information, described in the section after
* Optionally, source locations for each instruction
* Optionally, tokenization information

#### Blocks

Each entry in `blocks` is a list of the following properties:
* Block type: (0) function/immediate, (1) 1-modifier, (2) 2-modifier
* Block immediateness: (1) immediate or (0) deferred
* Index or indices in `bodies`

Compilation separates blocks so that they are not nested in bytecode. A block consists of bodies, so that all compiled code is contained in some body of a block. The self-hosted compiler compiles the entire program into an immediate block, and the program is run by evaluating this block. Bodies are terminated with a RETN or RETD instruction.

When the block is evaluated depends on its type and immediateness. An immediate block (0,1) is evaluated as soon as it is pushed; a function (0,0) is evaluated when called on arguments, an immediate modifier (1 or 2, 1) is evaluated when called on operands, and a deferred modifier (1 or 2, 0) creates a derived function when called on operands and is evaluated when this derived function is called on arguments.

The last property can be a single number, or, if it's a deferred block, might be a pair of lists. For a single number the block is always evaluated by evaluating the body with the given index. For a pair, the first element gives the monadic case and the second the dyadic one. A given valence should begin at the first body in the appropriate list, moving to the next one if a header test (SETH instruction) fails.

#### Bodies

Bodies in a block are separated by `;`. Each entry in `bodies` is a list containing:
* Starting index in `code`
* Number of variables the block needs to allocate
* Variable names, as indices into the program's symbol list
* A mask indicating which variables are exported

The starting index refers to the position in bytecode where execution starts in order to evaluate the block. Different bodies will always have the same set of special names, but the variables they define are unrelated, so of course they can have different counts. The given number of variables includes special names, but list of names and export mask don't.

The program's symbol list is included in the tokenization information `t`: it is `0⊑2⊑t`. Since the entire program (the source code passed in one compiler call) uses this list, namespace field accesses can be performed with indices alone within a program. The symbol list is needed for cross-program access, for example if `•BQN` returns a namespace.

### Instructions

The following instructions are defined by dzaima/BQN. The ones emitted by the self-hosted BQN compiler are marked in the "used" column. Instructions marked `NS` are used only in programs with namespaces, and so are not needed to support the compiler or self-hosted runtime. Similarly, `SETH` is only needed in programs with destructuring headers.

|  B | Name | Used | Like | Args     | Description
|---:|------|:----:|-----:|:---------|------------
| 00 | PUSH |  X   |      | `I`      | Push object `I`
| 01 | DFND |  X   |      | `I`      | Localize and push block `I`
| 02 | SYSV |      |  00  | `I`      | Push dynamic system value `I`
| 03 |      |      |      | `D`      | Push return function for lexical depth `D`
| 06 | POPS |  X   |      |          | Pop and discard top of stack
| 07 | RETN |  X   |      |          | Returns top of stack
| 08 | RETD |  NS  |  07  |          | Return the running scope's namespace
| 0B | ARRO |  X   |      | `N`      | Create length-`N` list
| 0C | ARRM |  X   |  0B  | `N`      | Create length-`N` reference list
| 0E |      |  X   |      |          | Merge top of stack (for `[]`)
| 10 | FN1C |  X   |      |          | Monadic function call
| 11 | FN2C |  X   |      |          | Dyadic function call
| 12 | FN1O |  X   |  10  |          | Monadic call, checking for `·`
| 13 | FN2O |  X   |  11  |          | Dyadic call, checking for `·`
| 14 | TR2D |  X   |      |          | Create 2-train
| 15 | TR3D |  X   |      |          | Create 3-train
| 16 | CHKV |  X   |      |          | Error if top of stack is `·`
| 17 | TR3O |  X   |  15  |          | Create 3-train, checking for `·`
| 1A | MD1C |  X   |      |          | 1-modifier call
| 1B | MD2C |  X   |      |          | 2-modifier call
| 1C | MD2L |      |      |          | Bind left operand to 2-modifier
| 1D | MD2R |      |      |          | Bind right operand to 2-modifier
| 20 | VARO |  X   |      | `D`, `I` | Push local variable `I` from `D` frames up
| 21 | VARM |  X   |      | `D`, `I` | Push local variable reference `I` from `D` frames up
| 22 | VARU |  X   |  21  | `D`, `I` | Push and clear local variable `I` from `D` frames up
| 26 | DYNO |      |      | `I`      | Push named variable `I`
| 27 | DYNM |      |      | `I`      | Push named variable `I` reference
| 2A | PRED |      |  06  |          | Check predicate and drop
| 2B | VFYM |  X   |      |          | Convert constant to matcher (for headers)
| 2F | SETH |  X   |  30  |          | Test and set header
| 30 | SETN |  X   |      |          | Define variable
| 31 | SETU |  X   |      |          | Change variable
| 32 | SETM |  X   |      |          | Modify variable
| 33 | SETC |  X   |      |          | Monadic modify variable
| 40 | FLDO |  NS  |      | `I`      | Read field `I` from namespace
| 41 | FLDM |      |  40  | `I`      | Push mutable field `I` from namespace
| 42 | ALIM |  NS  |      | `I`      | Mutable target aliases field `I`

Stack effects for most instructions are given below. Instructions `FN1O`, `FN2O`, and `TR3O` are identical to `FN1C`, `FN2C`, and `TR3D` except that the indicated values in the higher-numbered instructions may be `·`. The non-checking instructions can be implemented using the checking ones, but avoiding the check could improve speed. `VARU` is identical to `VARM` but indicates that the local variable's value will never be used again, which may be useful for optimization.

|  B | Name | Stack effect          | Comments
|---:|------|-----------------------|--------
| 00 | PUSH | `→ (i⊑consts)`        |
| 01 | DFND | `→ (i⊑blocks)`        | Also sets block's parent scope
| 06 | POPS | `x →`                 |
| 07 | RETN | `x → x`               | Returns from current block
| 08 | RETD | `x? → n`              | Clears stack, dropping 0 or 1 value
| 0B | ARRO | `x0 … xm → ⟨x0 … xm⟩` | `N` total variables (`m=n-1`)
| 10 | FN1C | `𝕩 𝕤 → (𝕊 𝕩)`         | 12: `𝕩` may be `·`
| 11 | FN2C | `𝕩 𝕤 𝕨 → (𝕨 𝕊 𝕩)`     | 13: `𝕨` or `𝕩` may be `·`
| 14 | TR2D | `g f → (F G)`         |
| 15 | TR3D | `h g f → (F G H)`     | 17: `F` may be `·`
| 1A | MD1C | `𝕣 𝕗 → (𝔽 _𝕣)`        |
| 1B | MD2C | `𝕘 𝕣 𝕗 → (𝔽 _𝕣_ 𝔾)`   |
| 1C | MD2L | `𝕣 𝕗 → (𝕗 _𝕣_)`       |
| 1D | MD2R | `𝕘 𝕣 → (_𝕣_ 𝕘)`       |
| 20 | VARO | `→ x`                 | Local variable value
| 21 | VARM | `→ r`                 | Local variable reference
| 2B | VFYM | `c → r`               | Constant to match reference
| 30 | SETN | `x r → (r←x)`         | `r` is a reference; 2F: no result
| 31 | SETU | `x r → (r↩x)`         | `r` is a reference
| 32 | SETM | `x f r → (r F↩ x)`    | `r` is a reference
| 33 | SETC | `f r → (r F↩)`        | `r` is a reference
| 40 | FLDO | `n → n.i`             |
| 42 | ALIM | `r → s`               | Reference `s` gets field `i` and puts in `r`

Many instructions just call functions or modifiers or otherwise have fairly obvious implementations. Instructions to handle variables and blocks are more complicated (although very typical of bytecode representations for lexically-scoped languages) and are described in more detail below.

### Local variables: DFND VARO VARU VARM RETN

The bytecode representation is designed with the assumption that variables will be stored in frames, one for each time an instance of a block is run. dzaima/BQN has facilities to give frame slots names, in order to support dynamic execution, but self-hosted BQN doesn't. A new frame is created when the block is evaluated (see [#blocks](#blocks)) and in general has to be cleaned up by garbage collection, because a lexical closure might need to refer to the frame even after the corresponding block finishes. Lexical closures can form loops, so simple reference counting can leak memory, but it could be used in addition to less frequent tracing garbage collection or another strategy.

A frame is a mutable list of *slots* for variable values. It has slots for any special names that are available during the blocks execution followed by the local variables it defines. Special names use the ordering `𝕤𝕩𝕨𝕣𝕗𝕘`; the first three of these are available in non-immediate blocks while `𝕣` and `𝕗` are available in modifiers and `𝕘` in 2-modifiers specifically.

When a block is pushed with **DFND**, an instance of the block is created, with its *parent frame* set to be the frame of the currently-executing block. Setting the parent frame when the block is first seen, instead of when it's evaluated, is what distinguishes lexical from dynamic scoping. If it's an immediate block, it's evaluated immediately, and otherwise it's pushed onto the stack. When the block is evaluated, its frame is initialized using any arguments passed to it, the next instruction's index is pushed onto the return stack, and execution moves to the first instruction in the block. When the RETN instruction is encountered, an index is popped from the return stack and execution returns to this location. As an alternative to maintaining an explicit return stack, a block can be implemented as a native function that creates a new execution stack and returns the value in it when the **RETN** instruction is reached. This approach uses the implementation language's call stack for the return stack.

Local variables are manipulated with the **VARO** (or **VARU**) and **VARM** instructions, which load the value of a variable and a reference to it (see the next section) respectively. These instructions reference variables by *frame depth* and *slot index*. The frame depth indicates in which frame the variable is found: the current frame has depth 0, its block's parent frame has depth 1, and so on. The slot index is an index within that frame.

Slots should be initialized with some indication they are not yet defined. The variable can be defined with SETN only if it hasn't been defined yet, and can be accessed with VARO or VARU or modified with SETU, SETM, or SETC only if it *has* been defined.

### Variable references: ARRM VARM SETN SETU SETM SETC

A *variable reference* indicates a particular frame slot in a way that's independent of the execution context. For example, it could be a pointer to the slot, or a reference to the frame along with the index of the slot. **VARM** pushes a variable reference to the stack.

A *reference list* is a list of variable references or reference lists. It's created with the **ARRM** instruction. In the Javascript VM there's no difference between a reference list and an ordinary BQN list other than the contents.

The **SETN**, **SETU**, **SETM**, and **SETC** instructions set a value for a reference. If the reference is to a variable, they simply set its value. For a reference list, the value needs to be destructured. It must be a list of the same length, and each reference in the reference list is set to the corresponding element of the value list.

**SETM** and **SETC** additionally need to get the current value of a reference. For a variable reference this is its current value (with an error if it's not defined yet); for a reference list it's a list of the values of each reference in the list.

### Bodies: SETH VFYM PRED

**SETH** is a modification of SETN for use in header destructuring. It differs in that it doesn't place its result on the stack (making it more like SETN followed by POPS), and that if the assignment fails because the reference and value don't conform then it moves on to the next eligible body in the block rather than giving an error. **VFYM** converts a BQN value `c` to a special reference: assigning a value `v` to it should check if `v≡c` but do no assignment. Only SETH needs to accept these references, and it should treat non-matching values as failing assignment.

**PRED** drops the top value of the stack, but also checks whether it matches the number 1. If it does match, execution continues; if not, evaluation of the current body ends and evaluation moves to the next eligible body.

### Namespaces: FLDO FLDM ALIM RETD

A *namespace* is the collection of variables in a particular scope, along with an association mapping some exported *symbols* (case- and underscore-normalized strings) to a subset of these. It can be represented using a frame for the variables, plus the variable name list and mask of exported variables from that block's properties in the bytecode. **RETD** finishes executing the block and returns the namespace for that execution.

The variable name list is split into a program-level list of names and a list of indices into these names: within-program field accesses can be done with the indices only while cross-program ones must use names. One way to check whether an access is cross-program is to compare the accessor's program-level name list with the one for the accessed namespace as references or pointers. Then a lookup should be performed as appropriate. A persistent lookup table is needed to make this efficient.

**FLDO** reads a field from a namespace. The parameter `I` is a program-level identifier index for this field. The VM must ensure that the field is exported, possibly by leaving unexported identifiers out of the namespace's lookup table. **FLDM** does the same but pushes a reference to the field, to be modified by assignment.

**ALIM** is used for aliased assignment such as `⟨a‿b⇐c⟩←ns`. It tags a reference with a namespace field, identified with a program-level index. A value assigned to the tagged reference must be a namespace. The relevant field is extracted, and then stored in the original reference.

## Runtime

Primitive functions and modifiers used in a program are stored in its `consts` array. The compiler needs to be passed a *runtime* with the value of every primitive so that these functions and modifiers are available.

While it's perfectly possible to implement the runtime from scratch, the pseudo-BQN files [r0.bqn](../src/r0.bqn) and [r1.bqn](../src/r1.bqn) implement the full runtime in terms of a *core runtime* consisting of a smaller number of much simpler functions. [pr.bqn](../src/pr.bqn) converts this file so that it can be compiled. It changes values in the core runtime to primitives and primitives to generated identifiers, so that the first 22 values in the output's `consts` array are exactly the core runtime, and no other primitives are required. The result is a list of two elements: first the list of all primitive values, and then a function that can be called to pass in two additional core functions used for inferred properties.

The contents of a core runtime are given below. The names given are those used in r1.bqn; the environment only provides a list of values and therefore doesn't need to use the same names. For named functions a description is given. For primitives, the implementation should match the BQN specification for that primitive on the specified domain, or the entire domain if left empty. They won't be called outside that domain except if there are bugs in the BQN sources.

| Ind | Name       | Description / restrictions
|----:|------------|---------------------------
|   0 | `Type`     | `•Type`
|   1 | `Fill`     | Get or set the fill value for array `𝕩`
|   2 | `Log`      | `⋆⁼` (natural or base-`𝕨` logarithm) for atomic arguments
|   3 | `GroupLen` | `≠¨⊔𝕩` for a valid list `𝕩`, with minimum length `𝕨`
|   4 | `GroupOrd` | `∾⊔𝕩` provided `𝕨` is `l GroupLen 𝕩` (any `l`)
|   5 | `!`        |
|   6 | `+`        | On two atoms
|   7 | `-`        | On one or two atoms
|   8 | `×`        | On two atoms
|   9 | `÷`        | On one or two atoms
|  10 | `⋆`        | On one or two atoms
|  11 | `⌊`        | On one atom
|  12 | `=`        | On one value or two atoms
|  13 | `≤`        | On two atoms
|  14 | `≢`        | For array `𝕩`
|  15 | `⥊`        | For array `𝕩` with no `𝕨` or `𝕨=○(×´)≢𝕩`
|  16 | `⊑`        | For atom `𝕨` and list `𝕩`
|  17 | `↕`        | For natural number `𝕩`
|  18 | `⌜`        | On arrays
|  19 | `` ` ``    |
|  20 | `_fillBy_` | `𝔽` with result fill computed using `𝔾`
|  21 | `⊘`        |
|   — | `Decompose`| `•Decompose`
|   — | `PrimInd`  | Index for primitive `𝕩`

To define the final two functions, call the second returned element as a function, with argument `Decompose‿PrimInd`. The function `PrimInd` gives the index of `𝕩` in the list of all primitives (defined as `glyphs` in pr.bqn), or the length of the runtime if `𝕩` is not a primitive. The two functions are only needed for computing inferred properties, and are defined by default so that every value is assumed to be a primitive, and `PrimInd` performs a linear search over the returned runtime. If the runtime is used directly, then this means that without setting `Decompose‿PrimInd`, function inferred properties will work slowly and for primitives only; if values from the runtime are wrapped then function inferred properties will not work at all.

Remember that `+` and `-` can also work on characters in some circumstances, under the rules of affine characters. Other arithmetic functions should only accept numbers. `=` must work on any atoms including functions and modifiers. `≤` must work on numbers and characters.

### GroupLen and GroupOrd

GroupLen and GroupOrd, short for Group length and Group order, are used to implement [Group](../doc/group.md) (`⊔`) and also to grade small-range lists and invert permutations (the inverse of a permutation `p` is `1¨⊸GroupOrd p`). Each of these only needs to work on lists of integers. Shown below are efficient implementations using BQN extended with the notation `(i⊑l) Fn↩ x` meaning `l ↩ Fn⟜x⌾(i⊸⊑) l`, where `Fn` is `⊢` if omitted. Since these special assignments only change one element of `l`, each can be a fast constant-time operation.

    GroupLen ← {
      l ← ¯1 ⌈´ 𝕩
      r ← (l+1) ⥊ 0
      { (𝕩⊑r) +↩ 1 }⍟(0⊸≤)¨ 𝕩
      (𝕨⌈≠r) ↑ r
    }

    GroupOrd ← {
      # 𝕨 ≡ GroupLen 𝕩
      s ← 0 ∾ +` 𝕨
      r ← (¯1⊑s) ⥊ @   # Every element will be overwritten
      (↕≠𝕩) { ((𝕩⊑s)⊑r)↩𝕨 ⋄ (𝕩⊑s)+↩1 }⍟(0⊸≤)¨ 𝕩
      r
    }

## Assembly

The full BQN implementation is made up of the two components above—virtual machine and core runtime—and the compiled runtime, compiler, and formatter. Since the compiler unlikely to work right away, I suggest initially testing the virtual machine on smaller pieces of code compiled by an existing, working, BQN implementation.

BQN sources are compiled with [cjs.bqn](../src/cjs.bqn), which runs under [dzaima/BQN](https://github.com/dzaima/BQN/) as a Unix-style script. It has two modes. If given a command-line argument `r`, `c`, or `fmt`, it compiles one of the source files. With any other command-line arguments, it will compile each one, and format it as a single line of output. The output is in a format designed for Javascript, but it can be adjusted to work in other languages either by text replacement on the output or changes to the formatting functions in cjs.bqn.

### Structure

The following steps give a working BQN system, assuming a working VM and core runtime:
* Evaluate the bytecode `$ src/cjs.bqn r`, passing the core runtime `provide` in the constants array. The result is a BQN list of a full runtime, and a function `SetPrims`.
* Optionally, call `SetPrims` on a two-element list `⟨Decompose, PrimInd⟩`.
* Evaluate the bytecode `$ src/cjs.bqn c`, which uses primitives from the runtime in its constants array. This is the compiler.
* Evaluate the bytecode `$ src/cjs.bqn f`. This returns a 1-modifier. To obtain the formatter, call it on a four-element operand list `⟨Type, Decompose, Glyph, FmtNum⟩`.

The compiler takes the runtime as `𝕨` and source code as `𝕩`. To evaluate BQN source code, convert it into a BQN string (rank-1 array of characters), pass this string and runtime to the compiler, and evaluate the result as bytecode. Results can be formatted with the formatter for use in a REPL, or used from the implementation language.

Two formatter arguments `Glyph` and `FmtNum` are not part of the runtime. `Glyph` assumes `𝕩` is a primitive and returns the character (not string) that represents it, and `FmtNum` assumes `𝕩` is a number and returns a string representing it.

### Testing

I recommend roughly the following sequence of tests to get everything working smoothly. It can be very difficult to figure out where in a VM things went wrong, so it's important to work methodically and make sure each component is all right before moving to the next.

Because the compiler works almost entirely with lists of numbers, a correct fill implementation is not needed to run the compiler. Instead, you can define `Fill` as `0⊘⊢` and `_fillBy_` as `{𝔽}` to always use a fill element of 0.

* Test core runtime functions directly by calling them within the implementation language.
* Test the virtual machine with the output of `src/cjs.bqn` on the primitive-less test expressions in [test/cases/bytecode.bqn](../test/cases/bytecode.bqn).
* Now test the self-hosted compiler by running it directly on small expressions.
* For a larger test, use [test/cases/prim.bqn](../test/cases/prim.bqn). The result should be an empty list `⟨⟩` indicating no failed tests.
* Now, if you haven't already, add a call to `SetPrims`. Test for inferred properties: identity, under, and undo.
* If all tests pass you can probably compile the compiler.
