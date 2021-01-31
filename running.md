*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/running.html).*

# How to run BQN

There are currently two active BQN implementations: the self-hosted one in this repository, and the independent dzaima/BQN. Neither is entirely complete but they are quite capable for pure programming tasks (say, implementing a compiler). For scripting, only dzaima/BQN has the required I/O such as file functions. I tend to develop parts of applications in the online REPL and move to dzaima/BQN scripts in order to run them.

### BQN

The online REPL is [here](https://mlochbaum.github.io/BQN/try.html). The file [docs/bqn.js](docs/bqn.js) is zero-dependency Javascript, and can be loaded from HTML or Node.js. It can also be called directly from the command line (using Node); in this case each argument is evaluated as BQN code and the result is printed.

The version of BQN in this repository is implemented mainly in BQN itself—the compiler is entirely self-hosted, while the runtime is built from a small number of starting functions using preprocessed BQN. It completely supports the core language except for block headers and multiple body syntax, and a few cases of structural Under (`⌾`). The Javascript-based compiler is also slow, taking about 0.05 seconds plus 1 second per kilobyte of source (this is purely due to the slow runtime, as dzaima+reference achieves 1ms/kB with the same compiler once warmed up).

Because self-hosted BQN requires only a simple virtual machine to run, it is [fairly easy](implementation/vm.md) to embed it in another programming language by implementing this virtual machine. The way data is represented is part of the VM implementation: it can use native arrays or a custom data structure, depending on what the language supports. An initial implementation will be very slow, but can be improved by replacing functions from the BQN-based runtime with native code. As the VM system can be hard to work with if you're not familiar with it, I advise you to contact me to discuss this option it you are interested.

### dzaima/BQN

[dzaima/BQN](https://github.com/dzaima/BQN/) is an implementation in Java created by modifying the existing dzaima/APL. It should be easy to run on desktop Linux and Android. It is still in development and has almost complete syntax support but incomplete primitive support.

### dzaima+reference BQN

This repository contains a dzaima/BQN script `dzref` that fills in the gaps in primitive support using BQN implementations of primitives that are not yet up to spec ([reference implementations](spec/reference.bqn) of all primitives starting from a small set of pre-existing functions are part of BQN's specification).

You can run `dzref` from ordinary dzaima/BQN using the `•Import` command; see for example [wcshim.bqn](wcshim.bqn). For testing, it is run as a Unix script, in which case it depends on an executable `dbqn` that runs dzaima/BQN on a file argument. I use the following script, using the path to a clone of dzaima/BQN for the jar file.

    #! /bin/bash
    
    java -jar /path/to/dzaima/BQN/BQN.jar -f "$@"

The left argument for `•Import` or the shell arguments can contain up to two arguments for the script. The first is a file to run, and the second is BQN code to be run after it.

### BQN2NGN

[BQN2NGN](https://github.com/mlochbaum/BQN2NGN) is a prototype implementation in Javascript build to experiment with the langauge, which is now abandoned.
