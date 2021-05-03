*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/running.html).*

# How to run BQN

There are currently two active BQN implementations: the self-hosted one in this repository, and the independent dzaima/BQN. Neither is entirely complete but they are quite capable for pure programming tasks (say, implementing a compiler). dzaima/BQN has good performance while self-hosted is a few hundred times slower. I tend to develop parts of applications in the online REPL and move to dzaima/BQN scripts in order to run them.

### Self-hosted BQN

The online REPL is [here](https://mlochbaum.github.io/BQN/try.html). The file [docs/bqn.js](docs/bqn.js) is zero-dependency Javascript, and can be loaded from HTML or Node.js. For command line use, call the Node.js script [bqn.js](bqn.js), passing a file and `•args`, or `-e` to execute all remaining arguments directly and print the results. [This notebook](https://observablehq.com/@lsh/bqn) shows how to run it in an Observable notebook.

Fully supports all primitives except a few cases of structural Under (`⌾`), but still missing some advanced features: namespaces, block headers and multiple body syntax, derived 1-modifiers, and block returns.

This version of BQN is [implemented](implementation/README.md) mainly in BQN itself, but a host language supplies basic functionality and can also replace primitives for better performance. This also allows [embedding](doc/embed.md), where programs in the host language can include BQN code. Support in the following languages has been implemented:
- Javascript; see above. Slow (compiles at ~5kB/s) but usable.
- dzaima/BQN ([bqn.bqn](bqn.bqn)), mainly for testing.
- [C](https://github.com/dzaima/CBQN), for an eventual high-performace implementation. Currently slower than dzaima/BQN and missing usability features.
- [Erlang](https://github.com/cannadayr/ebqn), intended for embedding. Too slow to be practical yet: minutes to compile short programs.

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
