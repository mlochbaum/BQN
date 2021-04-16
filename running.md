*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/running.html).*

# How to run BQN

There are currently two active BQN implementations: the self-hosted one in this repository, and the independent dzaima/BQN. Neither is entirely complete but they are quite capable for pure programming tasks (say, implementing a compiler). dzaima/BQN has good performance while self-hosted is about a thousand times slower. I tend to develop parts of applications in the online REPL and move to dzaima/BQN scripts in order to run them.

### BQN

The online REPL is [here](https://mlochbaum.github.io/BQN/try.html). The file [docs/bqn.js](docs/bqn.js) is zero-dependency Javascript, and can be loaded from HTML or Node.js. For command line use, call the Node.js script [bqn.js](bqn.js), passing a file and `•args`, or `-e` to execute all remaining arguments directly and print the results. [This notebook](https://observablehq.com/@lsh/bqn) shows how to run it in an Observable notebook.

The version of BQN in this repository is implemented mainly in BQN itself—the compiler is entirely self-hosted, while the runtime is built from a small number of starting functions using preprocessed BQN. It completely supports the core language except for block headers and multiple body syntax, and a few cases of structural Under (`⌾`). The Javascript-based compiler is also slow, taking about 0.05 seconds plus 1 second per kilobyte of source (this is purely due to the slow runtime, as dzaima+reference achieves 1ms/kB with the same compiler once warmed up).

Because self-hosted BQN requires only a simple virtual machine to run, it is [fairly easy](implementation/vm.md) to embed it in another programming language by implementing this virtual machine. The way data is represented is part of the VM implementation: it can use native arrays or a custom data structure, depending on what the language supports. An initial implementation will be very slow, but can be improved by replacing functions from the BQN-based runtime with native code. As the VM system can be hard to work with if you're not familiar with it, I advise you to contact me to discuss this option it you are interested.

In progress VMs are [CBQN](https://github.com/dzaima/CBQN) in C, and [ebqn](https://github.com/cannadayr/ebqn) in Erlang. Although both of these work (can compile and run code; only missing some fill support in CBQN), neither is considered useful for any purpose yet. CBQN is likely to become the main high-performance BQN implementation but is currently only a few times faster than Javascript and has an interface that's only useful for testing. ebqn is extremely slow—hours to compile.

### dzaima/BQN

[dzaima/BQN](https://github.com/dzaima/BQN/) is an implementation in Java created by modifying the existing dzaima/APL. It should be easy to run on desktop Linux and Android. It is still in development and has almost complete syntax support but incomplete primitive support: major missing functionality is dyadic Depth (`⚇`), Windows (`↕`), and many cases of set functions (`⊐⊒∊⍷`, mostly with rank >1).

In this repository and elsewhere, dzaima/BQN scripts are called with `#! /usr/bin/env dbqn`. This requires an executable file `dbqn` somewhere in your path with the following contents:

    #! /bin/bash

    java -jar /path/to/dzaima/BQN/BQN.jar "$@"

If compiled with Native Image, `nBQN` can be used directly instead.

#### dzaima+reference BQN

This repository contains a dzaima/BQN script `dzref` that fills in gaps in primitive support with BQN implementations. dzaima/BQN has good enough primitive support that I now almost never use this, but it's still needed for the website generator md.bqn. The command-line arguments are a script to run and followed by the `•args` to supply to it.

### BQN2NGN

[BQN2NGN](https://github.com/mlochbaum/BQN2NGN) is a prototype implementation in Javascript build to experiment with the langauge, which is now abandoned.
