*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/running.html).*

# How to run BQN

[CBQN](https://github.com/dzaima/CBQN) is now the primary offline implementation, and can be used everywhere in this repository, except test/dzaima which is specifically for testing with dzaima/BQN. Scripts start with `#! /usr/bin/env bqn` in order to look up the user's `bqn` executable.

For Nix users, nixpkgs now has repositories for several implementations; `cbqn` is recommended for general use.

### Self-hosted BQN

See the subsections below for instructions on specific implementations.

This version of BQN is [implemented](implementation/README.md) mainly in BQN itself, but a host language supplies basic functionality and can also replace primitives for better performance. This also allows [embedding](doc/embed.md), where programs in the host language can include BQN code. It fully supports all primitives except a few cases of structural Under (`⌾`), and is missing some minor syntax features such as derived 1-modifiers and block returns.

Support in the following languages has been implemented:
- Javascript, in this repository. Slow (compiles at ~5kB/s) but usable.
- [C](https://github.com/dzaima/CBQN), targetting high performance. Many parts are fast, some are not.
- [C++](https://github.com/ashermancinelli/cxbqn), planning to enable GPU use. It works but is still early-stage.
- BQN ([bqn.bqn](bqn.bqn)), for testing the compiler easily.
- [Erlang](https://github.com/cannadayr/ebqn), intended for embedding. Too slow to be practical; a [Rust version](https://github.com/cannadayr/ebqn-rs/) is in progress to fix this.

#### Javascript

The online REPL is [here](https://mlochbaum.github.io/BQN/try.html). The file [docs/bqn.js](docs/bqn.js) is zero-dependency Javascript, and can be loaded from HTML or Node.js. For command line use, call the Node.js script [bqn.js](bqn.js), passing a file and `•args`, or `-e` to execute all remaining arguments directly and print the results. [This notebook](https://observablehq.com/@lsh/bqn) shows how to run it in an Observable notebook.

#### CBQN

C sources are kept in the [CBQN](https://github.com/dzaima/CBQN) repository, but it also depends on bytecode from the BQN sources here. Running `make` gets a working copy right away with saved bytecode. Then to use the latest bytecode, call `$ ./BQN genRuntime …/BQN`, where `…/BQN` points to this repository, and run `make` again.

`genRuntime` can also be run with another BQN implementation (the Node.js one works but takes up to a minute), and plain `./genRuntime` uses your system's `bqn` executable. I symlink `…/CBQN/BQN` to `~/bin/bqn` so I can easily use CBQN for scripting.

CBQN uses the self-hosted runtime to achieve full primitive coverage, and implements specific primitives or parts of primitives natively to speed them up. This means primitives with native support—including everything used by the compiler—are fairly fast while others are much slower.

### dzaima/BQN

[dzaima/BQN](https://github.com/dzaima/BQN/) is an implementation in Java created by modifying the existing dzaima/APL, and should be easy to run on desktop Linux and Android. It may be abandoned as dzaima is now working on CBQN. It has almost complete syntax support but incomplete primitive support: major missing functionality is dyadic Depth (`⚇`), Windows (`↕`), and many cases of set functions (`⊐⊒∊⍷`, mostly with rank >1).

In this repository and elsewhere, dzaima/BQN scripts are called with `#! /usr/bin/env dbqn`. This requires an executable file `dbqn` somewhere in your path with the following contents:

    #! /bin/bash

    java -jar /path/to/dzaima/BQN/BQN.jar "$@"

If compiled with Native Image, `nBQN` can be used directly instead.

### BQN2NGN

[BQN2NGN](https://github.com/mlochbaum/BQN2NGN) is a prototype implementation in Javascript build to experiment with the langauge, which is now abandoned.
