Test scripts:

  Script            Compiler host   Output host
- js [-prim]        Self-host       BQN on Javascript
- dz_comp [-prim]   dzaima/BQN      dzaima/BQN
- dz_rt             dzaima/BQN      BQN on dzaima/BQN
- dz_wasm.js        dzaima/BQN      WebAssembly

Test cases:
                  js    dz_comp   dz_rt      dz_wasm.js
- cases.bqn        *       *                     *
- bcases.bqn       *       *
- prim.bqn       -prim   -prim      *

Contents of bin/dbqn follow (3 lines). Replace "/path/to/dzaima/" with
your path.

#! /bin/bash

java -jar /path/to/dzaima/BQN/BQN.jar -f "$@"
