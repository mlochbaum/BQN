*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/running.html).*

# How to run BQN

BQN is in an early stage of development, and no implementation is complete yet. However, it's a relatively simple language to implement, and a few implementations come close. At the moment, dzaima/BQN is the most usable version, with good performance and error reporting.

### BQN

This repository contains a BQN implementation written mainly in BQN: the bytecode [compiler](src/c.bqn) is completely self-hosted, and the [majority of the runtime](src/r.bqn) is written in BQN except that it is allowed to define primitives; some preprocessing turns the primitives into identifiers. The remaining part, a VM, can be implemented in any language to obtain a version of BQN running in that language. A [Javascript implementation](docs/bqn.js) allows BQN to be run as a [client-side REPL](https://mlochbaum.github.io/BQN/try.html) or in Node.js as a library.

The bytecode is also the same as dzaima/BQN's format, and [an extension](dc.bqn) to the compiler adjusts the slightly different block declarations to target dzaima+reference BQN. There is also [an earlier experiment](wc.bqn) targetting [WebAssembly](https://en.wikipedia.org/wiki/WebAssembly) that works only on a very small subset of BQN.

This version is not yet suitable for serious programming. The runtime has full error checking but the compiler does not, so syntax errors can go unreported. It does not yet support function headers or multiple bodies. The Javascript-based compiler is also slow, taking about 0.05 seconds plus 1 second per kilobyte of source (this is purely due to the slow runtime, as dzaima+reference achieves 3ms/kB with the same compiler once warmed up).

All versions have automated tests in the [test](test/) directory, with the self-hosted version ([test/tj.js](test/tj.js)) and WebAssembly backend  ([test/t.js](test/t.js)) tested with Javascript using Node and the dzaima/BQN backend tested with BQN itself ([test/bt](test/bt)).

### dzaima/BQN

[dzaima/BQN](https://github.com/dzaima/BQN/) is an implementation in Java created by modifying the existing dzaima/APL. It should be easy to run on desktop Linux and Android. It is still in development and has almost complete syntax support but incomplete primitive support.

### dzaima+reference BQN

This repository contains a dzaima/BQN script `dzref` that fills in the gaps in primitive support using BQN implementations of primitives that are not yet up to spec ([reference implementations](spec/reference.bqn) of all primitives starting from a small set of pre-existing functions are part of BQN's specification).

You can run `dzref` from ordinary dzaima/BQN using the `•EX` command; see for example [wcshim.bqn](wcshim.bqn). For testing, it is run as a Unix script, in which case it depends on an executable `dbqn` that runs dzaima/BQN on a file argument. I use the following script, using the path to a clone of dzaima/BQN for the jar file.

    #! /bin/bash
    
    java -jar /path/to/dzaima/BQN/BQN.jar -f "$@"

The left argument for `•EX` or the shell arguments can contain up to two arguments for the script. The first is a file to run, and the second is BQN code to be run after it.

### BQN2NGN

[BQN2NGN](https://github.com/mlochbaum/BQN2NGN) is a prototype implementation in Javascript build to experiment with the langauge, which is now abandoned. It can be used online [here](https://mlochbaum.github.io/BQN2NGN/web/index.html). Major differences are that it has no Fold and Insert is spelled `´` even though current BQN uses `˝`, that it has a different version of [Group](doc/group.md) (`⊔`), and that it is missing Choose (`◶`). There are also some spelling differences, with Deduplicate (`⍷`) spelled with `∪` and Valences (`⊘`) spelled with `⍠`. It is missing value blocks and function headers.
