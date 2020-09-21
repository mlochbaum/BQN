*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/implementation/vm.html).*

# The BQN virtual machine and runtime

BQN's self-hosted compiler and runtime mean that only a small amount of native code is needed to run BQN on any given platform. For example, the [Javascript environment](../docs/bqn.js) requires about 200 lines of Javascript code even though it compiles BQN bytecode to Javascript, a more complex strategy than interpreting it directly. This makes it fairly easy to port BQN to new platforms, allowing BQN to run "natively" within other programming languages and interact with arrays in those languages.

## Bytecode

The BQN implementation here and dzaima/BQN share a stack-based bytecode format used to represent compiled code. dzaima/BQN can interpret this bytecode or convert it to [JVM](https://en.wikipedia.org/wiki/Java_virtual_machine) bytecode, while the Javascript VM previously interpreted bytecode but now always compiles it.

Since interpretation is a simpler strategy, it may be helpful to use the [old Javascript bytecode interpreter](https://github.com/mlochbaum/BQN/blob/f74d9223ef880f2914030c2375f680dcc7e8c92b/bqn.js#L36) as a reference when implementing a BQN virtual machine.

### Components

The complete bytecode for a program consists of the following:
* A bytecode sequence `bytes`
* A list `consts` of constants that can be loaded
* *(dzaima/BQN only) A list of identifier names*
* A list `blocks` of block information, described in the next section.

### Blocks

Each block in `blocks` is a list of the following properties:
* Block type: (0) function/immediate, (1) 1-modifier, (2) 2-modifier
* Block immediateness: (1) immediate or (0) deferred
* *(dzaima/BQN only) List of local identifier names*
* Block starting index in `bytes`

Compilation separates blocks so that they are not nested in bytecode. All compiled code is contained in some block. The self-hosted compiler compiles the entire program into an immediate block, and the program is run by evaluating this block. Blocks are terminated with the RETN instruction.

In dzaima/BQN, the block type is one of `'f'` `'m'` `'d'` rather than 0, 1, or 2.

The starting index refers to the position where execution starts in order to evaluate the block. When the block is evaluated depends on its type and immediateness. An immediate block (0,1) is evaluated as soon as it is pushed; a function (0,0) is evaluated when called on arguments, an immediate modifier (1 or 2, 1) is evaluated when called on operands, and a deferred modifier (1 or 2, 0) creates a derived function when called on operands and is evaluated when this derived function is called on arguments.

### Instructions

The following instructions are defined by dzaima/BQN. The ones emitted by the self-hosted BQN compiler are marked in the "used" column.

|  B | Name | Used | Like | Args     | Description
|----|------|------|------|----------|------------
|  0 | PUSH |  X   |      | `I`      | Push object `I`
|  1 | VARO |      |      | `I`      | Push named variable `I`
|  2 | VARM |      |      | `I`      | Push named variable `I` reference
|  3 | ARRO |  X   |      | `N`      | Create length-`N` list
|  4 | ARRM |  X   |   3  | `N`      | Create length-`N` reference list
|  5 | FN1C |      |      |          | Monadic function call
|  6 | FN2C |      |      |          | Dyadic function call
|  7 | OP1D |  X   |      |          | 1-modifier call
|  8 | OP2D |  X   |      |          | 2-modifier call
|  9 | TR2D |  X   |      |          | Create 2-train
| 10 | TR3D |      |      |          | Create 3-train
| 11 | SETN |  X   |      |          | Define variable
| 12 | SETU |  X   |      |          | Change variable
| 13 | SETM |  X   |      |          | Modify variable
| 14 | POPS |  X   |      |          | Pop and discard top of stack
| 15 | DFND |  X   |      | `I`      | Localize and push block `I`
| 16 | FN1O |  X   |   5  |          | Monadic call, checking for `·`
| 17 | FN2O |  X   |   6  |          | Dyadic call, checking for `·`
| 18 | CHKV |      |      |          | Error if top of stack is `·`
| 19 | TR3O |  X   |  10  |          | Create 3-train, checking for `·`
| 20 | OP2H |      |      |          | Bind right operand to 2-modifier
| 21 | LOCO |  X   |      | `D`, `I` | Push local variable `I` from `D` frames up
| 22 | LOCM |  X   |      | `D`, `I` | Push local variable reference `I` from `D` frames up
| 23 | VFYM |      |      |          | Convert to matcher (for header tests)
| 24 | SETH |      |      |          | Test header
| 25 | RETN |  X   |      |          | Returns top of stack

Stack effects for most instructions are given below. Instructions 16, 17, and 19 are identical to 5, 6, and 10 except that the indicated values in the higher-numbered instructions may be `·`. The lower-numbered instructions are not yet emitted by the self-hosted compiler and can be implemented simply by making them identical to the higher-numbered ones; however, it may be possible to make them faster by not checking for Nothing.

|  B | Name | Stack effect          | Comments
|----|------|-----------------------|--------
|  0 | PUSH | `→ (i⊑consts)`        |
|  3 | ARRO | `x0 … xm → ⟨x0 … xm⟩` | `N` total variables (`m=n-1`)
|  5 | FN1C | `𝕩 𝕤 → (𝕊 𝕩)`         | 16: `𝕩` may be `·`
|  6 | FN2C | `𝕩 𝕤 𝕨 → (𝕨 𝕊 𝕩)`     | 17: `𝕨` or `𝕩` may be `·`
|  7 | OP1D | `𝕣 𝕗 → (𝔽 _𝕣)`        |
|  8 | OP2D | `𝕘 𝕣 𝕗 → (𝔽 _𝕣_ 𝔾)`   |
|  9 | TR2D | `g f → (F G)`         |
| 10 | TR3D | `h g f → (F G H)`     | 19: `F` may be `·`
| 11 | SETN | `x r → (r←x)`         | `r` is a reference
| 12 | SETU | `x r → (r↩x)`         | `r` is a reference
| 13 | SETM | `x f r → (r F↩ x)`    | `r` is a reference
| 14 | POPS | `x →`                 |
| 15 | DFND | `→ (i⊑blocks)`        | Also sets block's parent scope
| 20 | OP2H | `𝕘 𝕣 → (_𝕣_ 𝕘)`       |
| 21 | LOCO | `→ x`                 | Local variable value
| 22 | LOCM | `→ r`                 | Local variable reference
| 25 | RETN | `x → x`               | Returns from current block

Many instructions just call functions or modifiers or otherwise have fairly obvious implementations. Instructions to handle variables and blocks are more complicated (although very typical of bytecode representations for lexically-scoped languages) and are described in more detail below.

### Local variables: DFND LOCO LOCM RETN

The bytecode representation is designed with the assumption that variables will be stored in frames, one for each instance of a block. dzaima/BQN has facilities to give frame slots names, in order to support dynamic execution, but self-hosted BQN doesn't. A new frame is created when the block is evaluated (see [#blocks](#blocks)) and in general has to be cleaned up by garbage collection, because a lexical closure might need to refer to the frame even after the corresponding block finishes. Lexical closures can form loops, so simple reference counting can leak memory, but it could be used in addition to less frequent tracing garbage collection or another strategy.

A frame is a mutable list of *slots* for variable values. It has slots for any special names that are available during the blocks execution followed by the local variables it defines. Special names use the ordering `𝕤𝕩𝕨𝕣𝕗𝕘`; the first three of these are available in non-immediate blocks while `𝕣` and `𝕗` are available in modifiers and `𝕘` in 2-modifiers specifically.

When a block is pushed with **DFND**, an instance of the block is created, with its *parent frame* set to be the frame of the currently-executing block. Setting the parent frame when the block is first seen, instead of when it's evaluated, is what distinguishes lexical from dynamic scoping. If it's an immediate block, it's evaluated immediately, and otherwise it's pushed onto the stack. When the block is evaluated, its frame is initialized using any arguments passed to it, the next instruction's index is pushed onto the return stack, and execution moves to the first instruction in the block. When the RETN instruction is encountered, an index is popped from the return stack and execution returns to this location. As an alternative to maintaining an explicit return stack, a block can be implemented as a native function that creates a new execution stack and returns the value in it when the **RETN** instruction is reached. This approach uses the implementation language's call stack for the return stack.

Local variables are manipulated with the **LOCO** and **LOCM** instructions, which load the value of a variable and a reference to it (see the next section) respectively. These instructions reference variables by *frame depth* and *slot index*. The frame depth indicates in which frame the variable is found: the current frame has depth 0, its block's parent frame has depth 1, and so on. The slot index is an index within that frame.

Slots should be initialized with some indication they are not yet defined. The variable can be defined with SETN only if it hasn't been defined yet, and can be accessed with LOCO or modified with SETU or SETM only if it *has* been defined.

### Variable references: ARRM LOCM SETN SETU SETM

A *variable reference* indicates a particular frame slot in a way that's independent of the execution context. For example, it could be a pointer to the slot, or a reference to the frame along with the index of the slot. **LOCM** pushes a variable reference to the stack.

A *reference list* is a list of variable references or reference lists. It's created with the **ARRM** instruction. In the Javascript VM there's no difference between a reference list and an ordinary BQN list other than the contents.

The **SETN**, **SETU**, and **SETM** instructions set a value for a reference. If the reference is to a variable, they simply set its value. For a reference list, the value needs to be destructured. It must be a list of the same length, and each reference in the reference list is set to the corresponding element of the value list.

**SETM** additionally needs to get the current value of a reference. For a variable reference this is its current value (with an error if it's not defined yet); for a reference list it's a list of the values of each reference in the list.
