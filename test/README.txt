Does your BQN work? Run

$ bqn test/this.bqn

to see. There are additional tests here used for development:

  Script        Compiler host     Output host/VM
- this.bqn      bqn               Self
- js            docs/bqn.js       Self
- unit.bqn      bqn               Self + repo
- dzaima        dzaima/BQN        Self + repo
- wasm.js       bqn               WebAssembly

"bqn" can be any implementation that supports the necessary system
functions (•file.List, •file.Lines, •args, •Out, •BQN, •Repr).

unit.bqn and dzaima can test components from this repostory, by default
the compiler only. The following options are supported:

- -nocomp: native execution
- default: compiler (src/c.bqn)
- -rt:     compiler and runtime (src/r*.bqn)
- -ref:    compiler and primitive specification (spec/reference.bqn)

Every script but wasm.js can be run on a specified set of tests by
passing the test names as arguments. this.bqn and unit.bqn run on all
tests by default; other scripts use the following default tests:

Test cases (cases/):
                  js    dzaima   wasm.js
- simple.bqn      *       *        *
- syntax.bqn      *       *
- prim.bqn                *
