Bootstrapping chain for BQN. The following gets you a full compiler:

- Files boot2.bqn and boot1.bqn here, and ../c.bqn
- A compiler capable of building boot2.bqn
- Primitive support sufficient to run all of the above

Each compiler can compile the previous one, but not ones before that.
Run verify.bqn to check that object code produced at each step matches
the full compiler's output.

The compiler boot2.bqn uses an easy-to-compile subset of BQN syntax.
Syntax restrictions for the full chain are listed below.

Full compiler, boot 0
  No headers or namespaces (or decimals) . :;? ⇐
  No high-rank array syntax []
  No useless parentheses that enclose a single value

Boot -1
  No stranding ‿ or character literals '
  No " in comment: comments can safely be parsed before strings
  No _: token role determined by first character
  No Nothing: · doesn't appear and 𝕨 always has a value
  Only 𝕊𝕩𝕨 for special names

Boot -2
  Single-scope
  No modified or list assignment
  No 2-modifiers at all

Boot -3
  Not easier to compile, just cut down further
