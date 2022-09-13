*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/running.html).*

# How to run BQN

[CBQN](https://github.com/dzaima/CBQN) is the primary offline implementation. Scripts in this repository start with `#! /usr/bin/env bqn` in order to look up the user's `bqn` executable, which is expected to be CBQN.

Some Linux distributions have third-party BQN packages: for general use I recommend `cbqn` from nixpkgs (Nix), `cbqn-git` from the AUR (Arch), and `bqn` in development Guix (not 1.3.0). There are also third party [Windows builds](https://github.com/actalley/WinBQN) hosted on Github.

For tools related to running BQN, see the [editor plugins](editors/README.md) and [fonts page](https://mlochbaum.github.io/BQN/fonts.html).

All these websites run BQN (on your computer, except Attempt This Online):

| Link | Style | Engine | Comments
|------|-------|--------|---------
| [Online REPL](https://mlochbaum.github.io/BQN/try.html) | One-shot | JS | "Explain", error marker
| [BQNPAD](https://bqnpad.mechanize.systems/)      | Session  | JS, Wasm | Preview, syntax coloring
| [Attempt This Online](https://ato.pxeger.com/run?1=m704qTBvwYKlpSVpuhZoFJQGAA) | TIO | CBQN | Server-side
| [Do Stuff Online](https://dso.surge.sh/#bqn)     | TIO | JS
| [Razetime](https://razetime.github.io/bqn-repl/) | Session  | JS
| [ktye/zoo](https://ktye.github.io/zoo/index.html#bqn) | Session | JS | Many array languages
| [Observable](https://observablehq.com/@lsh/bqn)  | Notebook | JS | For import in Observable
| [BQN-80](https://dancek.github.io/bqn-80)        | One-shot | JS | Create animations

Further details in the sections below.

### Self-hosted BQN

This version of BQN is [implemented](implementation/README.md) mainly in BQN itself, but a host language supplies basic functionality and can also replace primitives for better performance. This also allows [embedding](doc/embed.md), where programs in the host language can include BQN code. It fully supports all functionality specified so far. System value support varies as it's implemented separately in each host.

Support in the following languages has been implemented (details in the subsections below):
- [C](https://github.com/dzaima/CBQN), targeting high performance. Usually fairly fast.
- Javascript, in this repository. Slow (compiles at ~5kB/s) but usable.
- BQN ([bqn.bqn](bqn.bqn)), for testing without a build step.
- [Julia](https://github.com/andreypopp/BQN.jl) embedding, with common primitives implemented natively. Slow startup.
- [C++](https://github.com/ashermancinelli/cxbqn), planning to enable GPU use. Still slow; some cool features.
- [Rust](https://github.com/cannadayr/rsbqn/), motivated by web use (an [Erlang](https://github.com/cannadayr/ebqn) version is abandoned as too slow). Note that CBQN [embeds in Rust](https://detegr.github.io/cbqn-rs/cbqn/) as well.

#### Javascript

The file [docs/bqn.js](docs/bqn.js) is zero-dependency Javascript, and can be loaded from HTML or Node.js. For command line use, call the Node.js script [bqn.js](bqn.js), passing a file and `•args`, or `-e` to execute all remaining arguments directly and print the results.

#### CBQN

C sources are kept in the [CBQN](https://github.com/dzaima/CBQN) repository, but it also depends on bytecode from the BQN sources here. Running `make` gets a working copy right away with saved bytecode. Then to use the latest bytecode, call `$ ./BQN genRuntime …/BQN`, where `…/BQN` points to this repository, and run `make` again.

CBQN is developed on Linux, and as-is will only run on Unix-like systems (including macOS). To run on Windows, [WSL](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) has the best support but there are also native builds based on each of Cygwin and Mingw [here](https://github.com/actalley/WinBQN).

`genRuntime` can also be run with another BQN implementation (the Node.js one works but takes up to a minute), and plain `./genRuntime` uses your system's `bqn` executable. I symlink `…/CBQN/BQN` to `~/bin/bqn` so I can easily use CBQN for scripting.

CBQN has native support for most primitive functionality and falls back to the self-hosted runtime to fill the gaps. The most important operations are fast, and it's almost always possible to write code that sticks to them. However, some cases, particularly those that deal with multiple axes, are much slower (although still fine for most use cases).

### dzaima/BQN

[dzaima/BQN](https://github.com/dzaima/BQN/) is an implementation in Java created by modifying the existing dzaima/APL, and should be easy to run on desktop Linux and Android. It was historically the main implementation, but is now updated only to stay up to date with language changes. Major missing functionality is dyadic Depth (`⚇`) and set functions `⊐⊒∊⍷` with rank >1, and there are various small differences from the BQN spec, mostly to do with rank, handling of atoms, fills, and headers. It uses UTF-16 instead of UTF-32, so that characters like `𝕩` don't behave correctly.

To get an executable that works like CBQN, make a script with the following contents. Scripts may use `#! /usr/bin/env dbqn` to run with dzaima/BQN specifically, but this is rare now (in this repository, only `test/dzaima` does it).

    #! /bin/bash

    java -jar /path/to/dzaima/BQN/BQN.jar "$@"

If compiled with Native Image, `nBQN` can be used directly instead.

### BQN2NGN

[BQN2NGN](https://github.com/mlochbaum/BQN2NGN) is a prototype implementation in Javascript built to experiment with the language. It's now abandoned.
