Documentation for BQN's implementation is at ../implementation/.

BQN sources for BQN. Object code from these is run with a VM to obtain a
BQN implementation. The Javascript VM is ../docs/bqn.js.

Compiler toolchain:

- glyphs.bqn  Glyphs for all BQN primitives
- c.bqn       Compiler
- pp.bqn      General preprocessing
- pr.bqn      Preprocess the runtime
- cjs.bqn     Format compiler output as Javascript literals

Compilation targets:

- c.bqn  Compiler
- r0.bqn, r1.bqn  Runtime
- f.bqn  Formatter
- e.bqn  Expression syntax explainer
- p.bqn  Plot generator

Since it defines primitives, the runtime is only sort of BQN. This is
why pr.bqn is required to process it. It's also compiled with a custom
primitive set.

e.bqn and p.bqn also require the definitions from svg.bqn; they are
attached cjs.bqn.

Some of these files are also used elsewhere: pp.bqn preprocesses other
primitive-defining code in ../test/ref.bqn, and f.bqn is used to format
results in markdown while e.bqn generates diagrams for the tutorials.
