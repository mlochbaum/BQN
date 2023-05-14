*View this file with results and syntax highlighting [here](https://mlochbaum.github.io/BQN/commentary/stability.html).*

# Is BQN stable?

The short answer is that code running online or in CBQN is unlikely to break. "Core" BQN consists of everything other than system values and is basically done: a few additions to namespace syntax are likely for spec version 1.1 (some listed [here](https://topanswers.xyz/apl?q=1888)), and otherwise I don't expect it to change. System values (the `•` things) are slightly less reliable, and in rare cases we add experimental ones before we're ready to commit to a particular design; read further for details and check on the forums if you'd like to know the status of any particular functionality.

I have thousands of lines of running BQN code including the self-hosted sources, website generator, and Singeli compiler. There are also now many BQN examples and REPL links [spread](../community/README.md) across the web which would be harder to change. So there is a strong reason to maintain compatibility for common or even moderately used features. Because BQN's been designed in a conservative way, avoiding fiddly decisions by keeping things simple, it seems that few compatibility breaks will be required. The history so far seems to bear this out.

Various edge cases were fixed when I first ran the primitive specifications through unit tests(!) in February 2021. Since then there have been the following core BQN compatibility breaks, that is, changes from one intentional (i.e. excluding bugs) non-error behavior to a different behavior.
- 2021-08-07: Pick (`⊑`) of empty array and Reshape (`⥊`) of empty array to non-empty changed from using fill elements to errors.
- 2022-05-03: Don't always preserve fill of `𝕩` in structural Under, such as `arr⌾⊢ <fill` to set fill element (was unspecified but intentionally implemented).
- 2022-06-16: Don't allow aliases within strands (against syntax spec but intentional).
- 2022-09-05: Change `⟨⟩↕a` for atom `a` to be `<a` instead of `a` (bug in reference.bqn).

System functions change more frequently. Some system functions are considered stable and others experimental. At the time of writing, the following seems to hold: system functions that are included in two out of three among the specification, JS REPL, and CBQN are stable. Others may or may not be stable; please ask about these on the forums (or by another channel) if you want to rely on them. Stable system functions are still much more likely to change than syntax or primitives. However, before making a change we'll try to find if there's code that relies on them and notify the owner. As this procedure doesn't scale well, if a system function reaches widespread use we'll be unwilling to change it without a strong reason.
