Documentation for BQN's implementation is at ../implementation/.

BQN sources for BQN. Object code obtained from these sources is run with
a VM to obtain a BQN implementation. This is done in Javascript in
../docs/bqn.js and ../docs/repl.js.

- c.bqn  Compiler
- r.bqn  Runtime
- f.bqn  Formatter
- e.bqn  Expression syntax explainer

Helper code used to obtain Javascript-formatted object code:

- pr.bqn   Preprocess the runtime
- cjs.bqn  Format compiler output as Javascript literals
