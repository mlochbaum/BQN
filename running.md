*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/running.html).*

# How to run BQN

[CBQN](https://github.com/dzaima/CBQN) is the primary offline implementation. Scripts in this repository start with `#! /usr/bin/env bqn` in order to look up the user's `bqn` executable, which is expected to be CBQN.

Third-party packages to build some BQN implementations are available for both Nix and Arch Linux. For general use I recommend `cbqn` from nixpkgs (Nix) and `cbqn-git` from the AUR (Arch).

There are many websites where you can run BQN as well. All but Attempt This Online are based on Javascript BQN.
- [The main online REPL](https://mlochbaum.github.io/BQN/try.html).
- [BQNPAD](https://bqnpad.mechanize.systems/) is a fancy syntax-highlighted REPL (preview results as you type!).
- Razetime's simpler [alternative](https://razetime.github.io/bqn-repl/) also runs as a continuous session.
- Try It Online format: [Attempt This Online](https://ato.pxeger.com/run?1=m704qTBvwYKlpSVpuhZoFJQGAA) runs CBQN server-side; [Do Stuff Online](https://dso.surge.sh/#bqn) runs JS BQN locally.
- This [Observable notebook](https://observablehq.com/@lsh/bqn) can be imported into other notebooks.
- [BQN-80](https://dancek.github.io/bqn-80): make animations with BQN.

### Self-hosted BQN

See the subsections below for instructions on specific implementations.

This version of BQN is [implemented](implementation/README.md) mainly in BQN itself, but a host language supplies basic functionality and can also replace primitives for better performance. This also allows [embedding](doc/embed.md), where programs in the host language can include BQN code. It fully supports all functionality specified so far (really it's ahead of the spec, which has some flaws to be addressed). System value support varies at it's implemented separately in each host.

Support in the following languages has been implemented:
- [C](https://github.com/dzaima/CBQN), targetting high performance. Usually fairly fast.
- Javascript, in this repository. Slow (compiles at ~5kB/s) but usable.
- BQN ([bqn.bqn](bqn.bqn)), for testing without a build step.
- [C++](https://github.com/ashermancinelli/cxbqn), planning to enable GPU use. Still slow; some cool features.
- [Rust](https://github.com/cannadayr/rsbqn/), motivated by web use (an [Erlang](https://github.com/cannadayr/ebqn) version is abandoned as too slow).
- [Julia](https://git.sr.ht/~andreypopp/BQN.jl) embedding, with common primitives implemented natively. Slow startup.

#### Javascript

The file [docs/bqn.js](docs/bqn.js) is zero-dependency Javascript, and can be loaded from HTML or Node.js. For command line use, call the Node.js script [bqn.js](bqn.js), passing a file and `•args`, or `-e` to execute all remaining arguments directly and print the results.

#### CBQN

C sources are kept in the [CBQN](https://github.com/dzaima/CBQN) repository, but it also depends on bytecode from the BQN sources here. Running `make` gets a working copy right away with saved bytecode. Then to use the latest bytecode, call `$ ./BQN genRuntime …/BQN`, where `…/BQN` points to this repository, and run `make` again.

`genRuntime` can also be run with another BQN implementation (the Node.js one works but takes up to a minute), and plain `./genRuntime` uses your system's `bqn` executable. I symlink `…/CBQN/BQN` to `~/bin/bqn` so I can easily use CBQN for scripting.

CBQN uses the self-hosted runtime to achieve full primitive coverage, and implements specific primitives or parts of primitives natively to speed them up. This means primitives with native support—including everything used by the compiler—are fairly fast while others are much slower.

### dzaima/BQN

[dzaima/BQN](https://github.com/dzaima/BQN/) is an implementation in Java created by modifying the existing dzaima/APL, and should be easy to run on desktop Linux and Android. It was historically the main implementation, but is now updated only to stay up to date with language changes. Major missing functionality is dyadic Depth (`⚇`) and set functions `⊐⊒∊⍷` with rank >1, and there are various small differences from the BQN spec, mostly to do with rank, handling of atoms, fills, and headers. It uses UTF-16 instead of UTF-32, so that characters like `𝕩` don't behave correctly.

To get an executable that works like CBQN, make a script with the following contents. Scripts may use `#! /usr/bin/env dbqn` to run with dzaima/BQN specifically, but this is rare now (in this repository, only `test/dzaima` does it).

    #! /bin/bash

    java -jar /path/to/dzaima/BQN/BQN.jar "$@"

If compiled with Native Image, `nBQN` can be used directly instead.

### BQN2NGN

[BQN2NGN](https://github.com/mlochbaum/BQN2NGN) is a prototype implementation in Javascript built to experiment with the langauge. It's now abandoned.
