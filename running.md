*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/running.html).*

# How to run BQN

CBQN is the primary offline implementation, and has [build instructions in its own repository](https://github.com/dzaima/CBQN). Here and elsewhere it's expected to be installed as `bqn`. For Windows, build in [WSL](https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux) or go to the [repository](https://github.com/vylsaz/cbqn-win-docker-build) for the docker builds linked below ([WinBQN](https://github.com/actalley/WinBQN) is another system that's currently unmaintained).

Third-party packages are available for several platforms. Because they run on an unknown target system, none of these packages except Spack+`o3n` are built with the highest-performance settings. If you need top speed (you probably don't!) you should compile CBQN for the target hardware instead.

| OS/distro         | Package                                      | Type
|-------------------|----------------------------------------------|--------------
| Windows download  | [docker build](https://github.com/vylsaz/cbqn-win-docker-build/releases) | Binary
| Arch AUR          | `cbqn-git`                                   | Source
| Alpine Linux Edge | `cbqn`                                       | Binary
| Nix               | `cbqn`                                       | Source/Binary
| Guix              | `cbqn`                                       | Source/Binary
| Spack             | `cbqn`                                       | Source
| iOS               | [Arrayground](https://apps.apple.com/us/app/arrayground/id6453522556) | App ([source](https://github.com/x86y/ibeacon))

For tools related to running BQN, see the [editor plugins](editors/README.md) and [fonts page](https://mlochbaum.github.io/BQN/fonts.html). Also, [Beacon](https://github.com/x86y/beacon) is a cross-platform IDE just for BQN!

All these websites run BQN, in your browser unless marked with "server-side" (JS is native Javascript; the Wasm engine is WebAssembly compiled from CBQN).

| Link | Style | Engine | Comments
|------|-------|--------|---------
| [Online REPL](https://mlochbaum.github.io/BQN/try.html) | One-shot | JS | "Explain", error marker
| [BQNPAD](https://bqnpad.mechanize.systems/)      | Session  | JS, Wasm | Preview, syntax coloring
| [BQN Editor](https://bqn.funmaker.moe/)          | One-shot | JS | Coloring, images, audio
| [Attempt This Online](https://ato.pxeger.com/run?1=m704qTBvwYKlpSVpuhZoFJQGAA) | TIO | CBQN | Server-side
| [Do Stuff Online](https://dso.surge.sh/#bqn)     | TIO | JS
| [Razetime](https://razetime.github.io/bqn-repl/) | Session  | JS
| [ktye/zoo](https://ktye.github.io/zoo/index.html#bqn) | Session | JS | Many array languages
| [Observable](https://observablehq.com/@lsh/bqn)  | Notebook | JS | For import in Observable
| [BQN-80](https://dancek.github.io/bqn-80)        | One-shot | JS | Create animations

Details about CBQN as well as the Javascript and other implementations follow.

## Self-hosted BQN

Both CBQN and JS BQN are [implemented](implementation/README.md) using components written in BQN itself: the compiler, and primitive implementations. The host language provides a bytecode VM and basic functionality for the primitives, and can replace primitives with native implementations for better performance. It also provides system values, so that which ones are supported depends on the host. This setup allows [embedding](doc/embed.md), where programs in the host language can evaluate BQN code.

Support in the following languages has been implemented:
- [CBQN](https://github.com/dzaima/CBQN) in C, targeting high [performance](implementation/perf.md) with mostly native primitives.
- Javascript, in this repository. Slow (compiles at ~5kB/s) but usable.
- BQN ([bqn.bqn](bqn.bqn)), for testing without a build step.
- [Julia](https://github.com/andreypopp/BQN.jl) embedding, with common primitives implemented natively. Slow startup.
- [C++](https://github.com/ashermancinelli/cxbqn), planning to enable GPU use. Still slow; some cool features.
- [Rust](https://github.com/cannadayr/rsbqn/), motivated by web use (an [Erlang](https://github.com/cannadayr/ebqn) version is abandoned as too slow). Note that CBQN [can run from Rust](https://detegr.github.io/cbqn-rs/cbqn/) as well.

The file [docs/bqn.js](docs/bqn.js) is zero-dependency Javascript, and can be loaded from HTML or Node.js. For command line use, call the Node.js script [bqn.js](bqn.js), passing a file and `•args`, or `-e` to execute all remaining arguments directly and print the results.

## BQN.rkt

[BQN.rkt](https://github.com/Nesuniken/BQN.rkt) is an independent implementation entirely in Racket, with primitives that operate on native Racket arrays (as these are multi-dimensional) and a compiler that converts from BQN to Racket syntax. It's incomplete as of this writing.

## dzaima/BQN

[dzaima/BQN](https://github.com/dzaima/BQN/) is an implementation in Java created by modifying the existing dzaima/APL, and should be easy to run on desktop Linux and Android. It was historically the main implementation, but is now updated only to stay up to date with language changes. Major missing functionality is dyadic Depth (`⚇`) and set functions `⊐⊒∊⍷` with rank >1, and there are various small differences from the BQN spec, mostly to do with rank, handling of atoms, fills, and headers. It uses UTF-16 instead of UTF-32, so that characters like `𝕩` don't behave correctly.

The only remaining dzaima/BQN script here is `test/dzaima`, which can be used to test the self-hosted primitives but has been superseded by `test/unit`.

## BQN2NGN

[BQN2NGN](https://github.com/mlochbaum/BQN2NGN) is a prototype implementation in Javascript built to experiment with the language. It's now abandoned.
