Test scripts:

  Script            Compiler host   Output host/VM
- js [-prim]        Self-host       Javascript
- dz_comp [-prim]   dzaima/BQN      dzaima/BQN
- dz_wasm.js        dzaima/BQN      WebAssembly

dz_comp uses the self-hosted compiler ../src/c.bqn by default but not
the runtime ../src/r.bqn. Pass -rt to test with the runtime, and -comp
to test dzaima/BQN only (this doesn't pass as of the time of writing).

Test cases:
                  js    dz_comp   dz_wasm.js
- cases.bqn        *       *          *
- bcases.bqn       *       *
- prim.bqn       -prim   -prim

Contents of bin/dbqn follow (3 lines). Replace "/path/to/dzaima/" with
your path.

#! /bin/bash

java -jar /path/to/dzaima/BQN/BQN.jar -f "$@"
