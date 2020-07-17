# How to run BQN

BQN is in a very early stage of development, and there is currently no complete implementation of the language. However, it's a relatively simple language to implement, and a few implementations come close.

### BQN2NGN

[BQN2NGN](https://github.com/mlochbaum/BQN2NGN) is a prototype implementation in Javascript build to experiment with the langauge, which is now abandoned. Because you can [use it online](https://mlochbaum.github.io/BQN2NGN/web/index.html), this is probably the quickest way to get started with BQN. It has good primitive support, with the main issues being that it uses a J-style insert instead of BQN-style vector reduction, that it has a different version of [Group](doc/group.md) (`⊔`), and that it is missing Choose (`◶`). There are also some spelling differences, with Deduplicate (`⍷`) spelled with `∪` and Valences (`⊘`) spelled with `⍠`. It is missing value blocks and function headers.

For automated testing I run BQN2NGN using the `bqn` executable, which is just a symlink to `apl.js` in the BQN2NGN repository. It requires Node to run.

### dzaima/BQN

[dzaima/BQN](https://github.com/dzaima/BQN/) is an implementation in Java created by modifying the existing dzaima/APL. It should be easy to run on desktop Linux and Android. It is still in development and has almost complete syntax support but incomplete primitive support.

### dzaima+reference BQN

This repository contains a dzaima/BQN script `dzref` that fills in the gaps in primitive support using BQN implementations of primitives which are not yet up to spec ([reference implementations](spec/reference.bqn) of all primitives starting from a small set of pre-existing functions are part of BQN's specification). These alternate implementations can be very slow.

You can run `dzref` from ordinary dzaima/BQN using the `•EX` command; see for example [dcshim.bqn](dcshim.bqn). For testing, it is run as a Unix script, in which case it depends on an executable `dbqn` that runs dzaima/BQN on a file argument. I use the following script, using the path to a clone of dzaima/BQN for the jar file.

    #! /bin/bash
    
    java -jar /path/to/dzaima/BQN/BQN.jar -f "$@"

The left argument for `•EX` or the shell arguments can contain up to two arguments for the script. The first is a file to run, and the second is BQN code to be run after it.

### BQN

This repository contains the beginnings of a self-hosted compiler for BQN, which is not yet complete enough to do any real programming with. There are currently several versions of the compiler: [c.bqn](c.bqn) is run with BQN2NGN, while [dc.bqn](dc.bqn) is run with dzaima+reference. Both compilers have a backend targetting [WebAssembly](https://en.wikipedia.org/wiki/WebAssembly), and dc.bqn additionally has a backend that targets dzaima/BQN's own bytecode, so that the compiler uses only BQN, but the runtime uses the Java implementations of BQN primitives from dzaima/BQN.

All versions have automated tests in the [test](test/) directory, with the WebAssembly versions tested with Javascript using Node ([test/t.js](test/t.js) and [test/dt.js](test/dt.js) for BQN2NGN and dzaima/BQN respectively) and the dzaima/BQN backend tested with BQN itself ([test/bt](test/bt)).
